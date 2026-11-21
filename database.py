from __future__ import annotations
import psycopg
from datetime import date
import random
from config import DB_BASE, APODERADO_DB_USER, APODERADO_DB_PASS


class DatabaseManager:

    @staticmethod
    def conectar(usuario_db: str, password_db: str):
        config = DB_BASE.copy()
        config['user'] = usuario_db
        config['password'] = password_db
        return psycopg.connect(**config)

    @classmethod
    def autenticar_secretaria(cls, password: str) -> tuple[bool, str]:
        try:
            conn = cls.conectar("rol_secretaria", password)
            conn.close()
            return True, "Sesión iniciada con privilegios completos de Secretaría."
        except psycopg.OperationalError as e:
            msg = e.pgerror if e.pgerror else "Credenciales incorrectas o rol no configurado en PostgreSQL."
            return False, f"PostgreSQL rechazó el acceso:\n{msg}"
        except Exception as e:
            return False, repr(e)

    @classmethod
    def autenticar_apoderado(cls, dni_apod: str) -> tuple[bool, str]:
        try:
            conn = cls.conectar(APODERADO_DB_USER, APODERADO_DB_PASS)
        except psycopg.OperationalError as e:
            msg = e.pgerror if e.pgerror else "Fallo de autenticación con rol_apoderado en PostgreSQL."
            return False, f"Error de conexión:\n{msg}"
        except Exception as e:
            return False, f"Error inesperado:\n{repr(e)}"

        try:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT Nombre, Apellido_Pat, Apellido_Mat FROM APODERADO WHERE DNI_Apod = %s;",
                    (dni_apod,)
                )
                resultado = cur.fetchone()
                if resultado:
                    nombre = f"{resultado[0]} {resultado[1]} {resultado[2]}"
                    return True, nombre
                return False, "El DNI ingresado no figura como Apoderado registrado."
        finally:
            conn.close()

    @classmethod
    def obtener_matriculas(cls, credenciales: tuple, rol: str, dni_apod: str = None,
                           filtro_dni: str = "", filtro_estado: str = "Todos") -> list:
        """Consulta las matrículas mediante funciones almacenadas según el rol."""
        conn = cls.conectar(*credenciales)
        try:
            with conn.cursor() as cur:
                if rol == "Secretaria":
                    cur.execute(
                        "SELECT * FROM fn_listar_matriculas_secretaria(%s, %s);",
                        (filtro_dni, filtro_estado)
                    )
                else:
                    cur.execute(
                        "SELECT * FROM fn_listar_matriculas_apoderado(%s);",
                        (dni_apod,)
                    )
                return cur.fetchall()
        finally:
            conn.close()

    @classmethod
    def obtener_estudiantes_disponibles(cls, credenciales: tuple, rol: str, dni_apod: str = None) -> list:
        conn = cls.conectar(*credenciales)
        try:
            with conn.cursor() as cur:
                if rol == "Secretaria":
                    cur.execute("SELECT DNI, Nombre || ' ' || Apellido_Pat FROM ESTUDIANTE ORDER BY Apellido_Pat;")
                else:
                    cur.execute("""
                        SELECT e.DNI, e.Nombre || ' ' || e.Apellido_Pat
                        FROM ESTUDIANTE e
                        JOIN REPRESENTA r ON e.DNI = r.DNI_est
                        WHERE r.DNI_Apod = %s;
                    """, (dni_apod,))
                return [f"{row[0]} - {row[1]}" for row in cur.fetchall()]
        finally:
            conn.close()

    @classmethod
    def obtener_pagos_disponibles(cls, credenciales: tuple, rol: str, dni_apod: str = None) -> list:
        """Detecta únicamente pagos en estado 'Pagado' que aún no estén vinculados a una matrícula."""
        conn = cls.conectar(*credenciales)
        try:
            with conn.cursor() as cur:
                if rol == "Secretaria":
                    query = """
                        SELECT p.Nro_operacion, p.Monto, p.Medio_pago, p.Fecha_pago
                        FROM PAGO_MATRICULA p
                        LEFT JOIN MATRICULA m ON p.Nro_operacion = m.Nro_operacion
                        WHERE p.Estado_pago = 'Pagado' AND m.Nro_operacion IS NULL
                        ORDER BY p.Fecha_pago DESC;
                    """
                    cur.execute(query)
                else:
                    query = """
                        SELECT p.Nro_operacion, p.Monto, p.Medio_pago, p.Fecha_pago
                        FROM PAGO_MATRICULA p
                        LEFT JOIN MATRICULA m ON p.Nro_operacion = m.Nro_operacion
                        WHERE p.DNI_Apod = %s AND p.Estado_pago = 'Pagado' AND m.Nro_operacion IS NULL
                        ORDER BY p.Fecha_pago DESC;
                    """
                    cur.execute(query, (dni_apod,))
                return [
                    f"{row[0]} | S/ {row[1]:.2f} | {row[2]} ({row[3]})"
                    for row in cur.fetchall()
                ]
        finally:
            conn.close()

    @classmethod
    def registrar_matricula_acid(cls, credenciales: tuple, dni_est: str, nro_op: str,
                                 anio: int, grado: str) -> str:
        """Invoca sp_registrar_matricula (CREATE) activando triggers de auditoría y autorización."""
        id_matri = f"M-{anio}-{random.randint(1000, 9999)}"
        fecha_hoy = date.today()

        conn = cls.conectar(*credenciales)
        try:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute(
                    "CALL sp_registrar_matricula(%s, %s, %s, %s, %s, %s);",
                    (id_matri, dni_est, nro_op, anio, grado, fecha_hoy)
                )
            return id_matri
        finally:
            conn.close()

    @classmethod
    def actualizar_matricula(cls, credenciales: tuple, id_matri: str, nuevo_grado: str, nuevo_estado: str):
        """Invoca sp_actualizar_matricula (UPDATE) activando el trigger de auditoría."""
        conn = cls.conectar(*credenciales)
        try:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute(
                    "CALL sp_actualizar_matricula(%s, %s, %s);",
                    (id_matri, nuevo_grado, nuevo_estado)
                )
        finally:
            conn.close()

    @classmethod
    def anular_matricula_logico(cls, credenciales: tuple, id_matri: str):
        """Invoca sp_eliminar_matricula (BORRADO LÓGICO) pasando el expediente a 'Anulado'."""
        conn = cls.conectar(*credenciales)
        try:
            conn.autocommit = True
            with conn.cursor() as cur:
                cur.execute("CALL sp_eliminar_matricula(%s);", (id_matri,))
        finally:
            conn.close()

    @classmethod
    def ejecutar_reporte(cls, credenciales: tuple, indice_reporte: int) -> tuple[list, list]:
        """Invoca funciones almacenadas en PostgreSQL para los 10 reportes institucionales."""
        reportes = {
            0: (["ID Matrícula", "DNI Alumno", "Estudiante", "Grado", "Apoderado", "Parentesco"],
                "SELECT * FROM fn_rep_01_matriculados_apoderado();"),
            1: (["Medio de Pago", "Cantidad Operaciones", "Monto Total (S/)"],
                "SELECT * FROM fn_rep_02_recaudacion_medio();"),
            2: (["DNI", "Estudiante", "Grado", "Grupo Sang.", "Seguro", "Alergia Registrada"],
                "SELECT * FROM fn_rep_03_ficha_medica();"),
            3: (["ID Matrícula", "Estudiante", "Grado", "Nro. Operación", "Monto (S/)", "Fecha Trámite"],
                "SELECT * FROM fn_rep_04_pendientes_validacion();"),
            4: (["Serie-ID", "Nro. Operación", "Destinatario", "Correo", "Monto (S/)", "Fecha Emisión"],
                "SELECT * FROM fn_rep_05_boletas_destinatario();"),
            5: (["ID Matrícula", "Estudiante", "Tipo Autorización", "Estado Aut.", "Fecha"],
                "SELECT * FROM fn_rep_06_autorizaciones();"),
            6: (["Estudiante", "Grado", "Apoderado", "Teléfono", "Distrito", "Dirección"],
                "SELECT * FROM fn_rep_07_directorio_domicilio();"),
            7: (["Año Académico", "Grado", "Estado Matrícula", "Total Alumnos"],
                "SELECT * FROM fn_rep_08_estadistica_grados();"),
            8: (["Nro. Operación", "DNI Apoderado", "Monto (S/)", "Estado Pago", "Medio", "Fecha"],
                "SELECT * FROM fn_rep_09_estado_pagos();"),
            9: (["ID Log", "ID Matrícula", "Usuario BD", "Estado Ant.", "Estado Nuevo", "Fecha/Hora"],
                "SELECT * FROM fn_rep_10_auditoria_triggers();")
        }

        columnas, query = reportes[indice_reporte]
        conn = cls.conectar(*credenciales)
        try:
            with conn.cursor() as cur:
                cur.execute(query)
                return columnas, cur.fetchall()
        finally:
            conn.close()