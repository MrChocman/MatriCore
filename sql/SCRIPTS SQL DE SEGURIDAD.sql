-- 1. LIMPIEZA PREVIA
DROP TRIGGER IF EXISTS trg_auditoria_matricula ON MATRICULA;
DROP TRIGGER IF EXISTS trg_generar_autorizacion_inicial ON MATRICULA;
DROP FUNCTION IF EXISTS fn_auditoria_matricula();
DROP FUNCTION IF EXISTS fn_generar_autorizacion_inicial();
DROP FUNCTION IF EXISTS fn_rep_10_auditoria_triggers();

DROP PROCEDURE IF EXISTS sp_registrar_matricula(VARCHAR, VARCHAR, VARCHAR, INT, VARCHAR, DATE);
DROP PROCEDURE IF EXISTS sp_actualizar_matricula(VARCHAR, VARCHAR, VARCHAR);
DROP PROCEDURE IF EXISTS sp_eliminar_matricula(VARCHAR);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_apoderado') THEN
        REVOKE ALL ON ALL TABLES IN SCHEMA public FROM rol_apoderado;
        REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM rol_apoderado;
        REVOKE ALL ON SCHEMA public FROM rol_apoderado;
        REVOKE CONNECT ON DATABASE matricula_la_salle FROM rol_apoderado;
        DROP ROLE rol_apoderado;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_secretaria') THEN
        REVOKE ALL ON ALL TABLES IN SCHEMA public FROM rol_secretaria;
        REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM rol_secretaria;
        REVOKE ALL ON SCHEMA public FROM rol_secretaria;
        REVOKE CONNECT ON DATABASE matricula_la_salle FROM rol_secretaria;
        DROP ROLE rol_secretaria;
    END IF;
END
$$;


-- 2. TABLA DE BITÁCORA PARA AUDITORÍA DE TRIGGERS
CREATE TABLE IF NOT EXISTS AUDITORIA_MATRICULA (
    ID_Auditoria SERIAL PRIMARY KEY,
    ID_Matri VARCHAR(15) NOT NULL,
    Accion VARCHAR(20) NOT NULL,          -- 'INSERT', 'UPDATE', 'BORRADO_LOGICO'
    Usuario_BD VARCHAR(50) NOT NULL,
    Estado_Anterior VARCHAR(15),
    Estado_Nuevo VARCHAR(15),
    Grado_Registrado VARCHAR(30),
    Fecha_Hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. FUNCIONES DISPARADORAS Y TRIGGERS SOBRE MATRICULA

-- TRIGGER 1: Auditoría automática ante INSERT, UPDATE o Borrado Lógico
CREATE OR REPLACE FUNCTION fn_auditoria_matricula()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO AUDITORIA_MATRICULA (ID_Matri, Accion, Usuario_BD, Estado_Anterior, Estado_Nuevo, Grado_Registrado)
        VALUES (NEW.ID_Matri, 'INSERT', current_user, NULL, NEW.Estado_matri, NEW.Grado_matricular);
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.Estado_matri = 'Anulado' AND OLD.Estado_matri <> 'Anulado' THEN
            INSERT INTO AUDITORIA_MATRICULA (ID_Matri, Accion, Usuario_BD, Estado_Anterior, Estado_Nuevo, Grado_Registrado)
            VALUES (NEW.ID_Matri, 'BORRADO_LOGICO', current_user, OLD.Estado_matri, NEW.Estado_matri, NEW.Grado_matricular);
        ELSE
            INSERT INTO AUDITORIA_MATRICULA (ID_Matri, Accion, Usuario_BD, Estado_Anterior, Estado_Nuevo, Grado_Registrado)
            VALUES (NEW.ID_Matri, 'UPDATE', current_user, OLD.Estado_matri, NEW.Estado_matri, NEW.Grado_matricular);
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_auditoria_matricula
AFTER INSERT OR UPDATE ON MATRICULA
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_matricula();

-- TRIGGER 2: Creación automática de autorización legal pendiente al matricular
CREATE OR REPLACE FUNCTION fn_generar_autorizacion_inicial()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_dni_apod VARCHAR(8);
    v_id_aut VARCHAR(10);
BEGIN
    SELECT DNI_Apod INTO v_dni_apod
    FROM PAGO_MATRICULA
    WHERE Nro_operacion = NEW.Nro_operacion;

    IF v_dni_apod IS NOT NULL THEN
        v_id_aut := 'A-' || LPAD(FLOOR(RANDOM() * 900 + 100)::TEXT, 3, '0');
        INSERT INTO AUTORIZACION (ID_Matri, ID_Aut, DNI_Apod, Tipo, Fecha_aut, Estado_aut)
        VALUES (NEW.ID_Matri, v_id_aut, v_dni_apod, 'Uso de imagen y datos', CURRENT_DATE, 'Pendiente');
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_generar_autorizacion_inicial
AFTER INSERT ON MATRICULA
FOR EACH ROW
EXECUTE FUNCTION fn_generar_autorizacion_inicial();

-- 4. PROCEDIMIENTOS ALMACENADOS PARA EL CRUD (CREATE, UPDATE, BORRADO LÓGICO)

-- PROCEDIMIENTO 1 (CREATE): Registrar Matrícula validando pago 'Pagado'
CREATE OR REPLACE PROCEDURE sp_registrar_matricula(
    p_id_matri VARCHAR,
    p_dni_est VARCHAR,
    p_nro_operacion VARCHAR,
    p_anio INT,
    p_grado VARCHAR,
    p_fecha DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_pago VARCHAR;
BEGIN
    SELECT Estado_pago INTO v_estado_pago
    FROM PAGO_MATRICULA
    WHERE Nro_operacion = p_nro_operacion;

    IF v_estado_pago IS NULL THEN
        RAISE EXCEPTION 'El número de operación % no existe en recaudación.', p_nro_operacion;
    END IF;

    IF v_estado_pago <> 'Pagado' THEN
        RAISE EXCEPTION 'El pago % no está conciliado (Estado actual: %).', p_nro_operacion, v_estado_pago;
    END IF;

    INSERT INTO MATRICULA (
        ID_Matri, DNI_est, Nro_operacion, Anio_academico, Grado_matricular, Estado_matri, Fecha_matri
    )
    VALUES (
        p_id_matri, p_dni_est, p_nro_operacion, p_anio, p_grado, 'Pendiente', p_fecha
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Transacción abortada en INSERT (ACID): %', SQLERRM;
END;
$$;

-- PROCEDIMIENTO 2 (UPDATE): Validar y actualizar grado/estado de Matrícula
CREATE OR REPLACE PROCEDURE sp_actualizar_matricula(
    p_id_matri VARCHAR,
    p_nuevo_grado VARCHAR,
    p_nuevo_estado VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MATRICULA WHERE ID_Matri = p_id_matri) THEN
        RAISE EXCEPTION 'El expediente de matrícula % no existe.', p_id_matri;
    END IF;

    UPDATE MATRICULA
    SET Grado_matricular = p_nuevo_grado,
        Estado_matri = p_nuevo_estado
    WHERE ID_Matri = p_id_matri;

    IF p_nuevo_estado = 'Matriculado' THEN
        UPDATE AUTORIZACION
        SET Estado_aut = 'Autorizado'
        WHERE ID_Matri = p_id_matri;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Transacción abortada en UPDATE (ACID): %', SQLERRM;
END;
$$;

-- PROCEDIMIENTO 3 (BORRADO LÓGICO): Anular expediente conservando historial
CREATE OR REPLACE PROCEDURE sp_eliminar_matricula(
    p_id_matri VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM MATRICULA WHERE ID_Matri = p_id_matri) THEN
        RAISE EXCEPTION 'No se encontró el expediente % para anular.', p_id_matri;
    END IF;

    -- Borrado lógico: cambia estado a 'Anulado' sin eliminar físicamente la fila
    UPDATE MATRICULA
    SET Estado_matri = 'Anulado'
    WHERE ID_Matri = p_id_matri;

    UPDATE AUTORIZACION
    SET Estado_aut = 'Anulado'
    WHERE ID_Matri = p_id_matri;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Transacción abortada en Borrado Lógico (ACID): %', SQLERRM;
END;
$$;


-- 5. FUNCIONES ALMACENADAS PARA CONSULTAS Y 10 REPORTES

CREATE OR REPLACE FUNCTION fn_listar_matriculas_secretaria(p_filtro_dni VARCHAR, p_filtro_estado VARCHAR)
RETURNS TABLE (id_matri VARCHAR, dni VARCHAR, estudiante TEXT, anio TEXT, grado VARCHAR, estado VARCHAR, nro_op VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(m.ID_Matri, 'Sin Trámite')::VARCHAR, e.DNI,
           (e.Nombre || ' ' || e.Apellido_Pat || ' ' || e.Apellido_Mat)::TEXT,
           COALESCE(m.Anio_academico::TEXT, '-'), COALESCE(m.Grado_matricular, '-')::VARCHAR,
           COALESCE(m.Estado_matri, 'No Matriculado')::VARCHAR, COALESCE(m.Nro_operacion, '-')::VARCHAR
    FROM ESTUDIANTE e
    LEFT JOIN MATRICULA m ON e.DNI = m.DNI_est
    WHERE (p_filtro_dni = '' OR e.DNI LIKE '%' || p_filtro_dni || '%')
      AND (p_filtro_estado = 'Todos' OR (p_filtro_estado = 'No Matriculado' AND m.Estado_matri IS NULL) OR (m.Estado_matri = p_filtro_estado))
    ORDER BY m.Fecha_matri DESC NULLS LAST, e.Apellido_Pat ASC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_listar_matriculas_apoderado(p_dni_apod VARCHAR)
RETURNS TABLE (id_matri VARCHAR, dni VARCHAR, estudiante TEXT, anio TEXT, grado VARCHAR, estado VARCHAR, nro_op VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT COALESCE(m.ID_Matri, 'Sin Trámite')::VARCHAR, e.DNI,
           (e.Nombre || ' ' || e.Apellido_Pat || ' ' || e.Apellido_Mat)::TEXT,
           COALESCE(m.Anio_academico::TEXT, '-'), COALESCE(m.Grado_matricular, '-')::VARCHAR,
           COALESCE(m.Estado_matri, 'No Matriculado')::VARCHAR, COALESCE(m.Nro_operacion, '-')::VARCHAR
    FROM REPRESENTA r
    JOIN ESTUDIANTE e ON r.DNI_est = e.DNI
    LEFT JOIN MATRICULA m ON e.DNI = m.DNI_est
    WHERE r.DNI_Apod = p_dni_apod
    ORDER BY m.Anio_academico DESC NULLS LAST;
END;
$$;

-- Reportes 1 al 10
CREATE OR REPLACE FUNCTION fn_rep_01_matriculados_apoderado()
RETURNS TABLE (id_matri VARCHAR, dni VARCHAR, estudiante TEXT, grado VARCHAR, apoderado TEXT, parentesco VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT m.ID_Matri, e.DNI, (e.Nombre || ' ' || e.Apellido_Pat)::TEXT,
           m.Grado_matricular, (a.Nombre || ' ' || a.Apellido_Pat)::TEXT, r.Parentesco
    FROM MATRICULA m
    JOIN ESTUDIANTE e ON m.DNI_est = e.DNI
    JOIN REPRESENTA r ON e.DNI = r.DNI_est
    JOIN APODERADO a ON r.DNI_Apod = a.DNI_Apod
    WHERE m.Estado_matri = 'Matriculado'
    ORDER BY m.Grado_matricular, e.Apellido_Pat;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_02_recaudacion_medio()
RETURNS TABLE (medio_pago VARCHAR, cantidad BIGINT, monto_total NUMERIC)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT p.Medio_pago, COUNT(m.ID_Matri), SUM(p.Monto)
    FROM PAGO_MATRICULA p
    JOIN MATRICULA m ON p.Nro_operacion = m.Nro_operacion
    WHERE p.Estado_pago = 'Pagado'
    GROUP BY p.Medio_pago
    ORDER BY SUM(p.Monto) DESC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_03_ficha_medica()
RETURNS TABLE (dni VARCHAR, estudiante TEXT, grado VARCHAR, grupo_sang VARCHAR, seguro VARCHAR, alergia VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT e.DNI, (e.Nombre || ' ' || e.Apellido_Pat)::TEXT, m.Grado_matricular,
           fm.Grupo_sang, fm.Seguro, COALESCE(al.Alergia, 'Ninguna')::VARCHAR
    FROM ESTUDIANTE e
    JOIN MATRICULA m ON e.DNI = m.DNI_est
    JOIN FICHA_MEDICA fm ON e.DNI = fm.DNI_est
    LEFT JOIN ALERGIA al ON e.DNI = al.DNI_est
    ORDER BY e.Apellido_Pat;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_04_pendientes_validacion()
RETURNS TABLE (id_matri VARCHAR, estudiante TEXT, grado VARCHAR, nro_op VARCHAR, monto NUMERIC, fecha DATE)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT m.ID_Matri, (e.Nombre || ' ' || e.Apellido_Pat)::TEXT, m.Grado_matricular,
           p.Nro_operacion, p.Monto, m.Fecha_matri
    FROM MATRICULA m
    JOIN ESTUDIANTE e ON m.DNI_est = e.DNI
    JOIN PAGO_MATRICULA p ON m.Nro_operacion = p.Nro_operacion
    WHERE m.Estado_matri = 'Pendiente'
    ORDER BY m.Fecha_matri ASC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_05_boletas_destinatario()
RETURNS TABLE (comprobante TEXT, nro_op VARCHAR, destinatario VARCHAR, correo VARCHAR, monto NUMERIC, fecha DATE)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT (b.Serie || '-' || b.ID_boleta)::TEXT, b.Nro_operacion, d.Destinatario,
           d.Correo_destinatario, p.Monto, b.Fecha_emision
    FROM BOLETA_ELECTRONICA b
    JOIN DESTINATARIO d ON b.DNI_destinatario = d.DNI_destinatario
    JOIN PAGO_MATRICULA p ON b.Nro_operacion = p.Nro_operacion
    ORDER BY b.ID_boleta ASC;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_06_autorizaciones()
RETURNS TABLE (id_matri VARCHAR, estudiante TEXT, tipo VARCHAR, estado VARCHAR, fecha DATE)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT m.ID_Matri, (e.Nombre || ' ' || e.Apellido_Pat)::TEXT,
           au.Tipo, au.Estado_aut, au.Fecha_aut
    FROM AUTORIZACION au
    JOIN MATRICULA m ON au.ID_Matri = m.ID_Matri
    JOIN ESTUDIANTE e ON m.DNI_est = e.DNI
    ORDER BY au.Estado_aut DESC, m.ID_Matri;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_07_directorio_domicilio()
RETURNS TABLE (estudiante TEXT, grado VARCHAR, apoderado TEXT, telefono VARCHAR, distrito VARCHAR, direccion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT (e.Nombre || ' ' || e.Apellido_Pat)::TEXT, m.Grado_matricular,
           (a.Nombre || ' ' || a.Apellido_Pat)::TEXT, COALESCE(ta.Telefono, '-')::VARCHAR,
           h.Distrito, (h.Calle || ' ' || h.Numero_vivienda)::TEXT
    FROM ESTUDIANTE e
    JOIN MATRICULA m ON e.DNI = m.DNI_est
    JOIN REPRESENTA r ON e.DNI = r.DNI_est
    JOIN APODERADO a ON r.DNI_Apod = a.DNI_Apod
    JOIN HOGAR h ON a.DNI_Apod = h.DNI_Apod
    LEFT JOIN TELEFONO_APODERADO ta ON a.DNI_Apod = ta.DNI_Apod
    ORDER BY m.Grado_matricular, e.Apellido_Pat;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_08_estadistica_grados()
RETURNS TABLE (anio INT, grado VARCHAR, estado VARCHAR, total BIGINT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT m.Anio_academico, m.Grado_matricular, m.Estado_matri, COUNT(*)
    FROM MATRICULA m
    GROUP BY m.Anio_academico, m.Grado_matricular, m.Estado_matri
    ORDER BY m.Anio_academico DESC, m.Grado_matricular;
END;
$$;

CREATE OR REPLACE FUNCTION fn_rep_09_estado_pagos()
RETURNS TABLE (nro_op VARCHAR, dni_apod VARCHAR, monto NUMERIC, estado VARCHAR, medio VARCHAR, fecha DATE)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT p.Nro_operacion, p.DNI_Apod, p.Monto, p.Estado_pago, p.Medio_pago, p.Fecha_pago
    FROM PAGO_MATRICULA p
    ORDER BY p.Estado_pago ASC, p.Fecha_pago DESC;
END;
$$;

-- Reporte 10: Bitácora de auditoría (sin columna Acción Trigger)
CREATE OR REPLACE FUNCTION fn_rep_10_auditoria_triggers()
RETURNS TABLE (id_log INT, id_matri VARCHAR, usuario VARCHAR, est_ant VARCHAR, est_nvo VARCHAR, fecha TEXT)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT a.ID_Auditoria, a.ID_Matri, a.Usuario_BD,
           COALESCE(a.Estado_Anterior, '-')::VARCHAR, COALESCE(a.Estado_Nuevo, '-')::VARCHAR,
           TO_CHAR(a.Fecha_Hora, 'YYYY-MM-DD HH24:MI:SS')::TEXT
    FROM AUDITORIA_MATRICULA a
    ORDER BY a.ID_Auditoria DESC;
END;
$$;


-- 6. ROLES NATIVOS Y PRIVILEGIOS (RBAC)
CREATE ROLE rol_apoderado WITH LOGIN PASSWORD 'apoderado_pass_seguro';
CREATE ROLE rol_secretaria WITH LOGIN PASSWORD 'secretaria_pass_seguro';

REVOKE ALL ON DATABASE matricula_la_salle FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE matricula_la_salle TO rol_apoderado, rol_secretaria;
GRANT USAGE ON SCHEMA public TO rol_apoderado, rol_secretaria;

GRANT SELECT ON APODERADO, ESTUDIANTE, REPRESENTA, MATRICULA, PAGO_MATRICULA, AUTORIZACION TO rol_apoderado;
GRANT INSERT ON MATRICULA, AUTORIZACION, AUDITORIA_MATRICULA TO rol_apoderado;
GRANT USAGE, SELECT ON SEQUENCE auditoria_matricula_id_auditoria_seq TO rol_apoderado;
GRANT EXECUTE ON PROCEDURE sp_registrar_matricula TO rol_apoderado;
GRANT EXECUTE ON FUNCTION fn_listar_matriculas_apoderado TO rol_apoderado;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO rol_secretaria;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_secretaria;
GRANT EXECUTE ON PROCEDURE sp_registrar_matricula, sp_actualizar_matricula, sp_eliminar_matricula TO rol_secretaria;
GRANT EXECUTE ON FUNCTION
    fn_listar_matriculas_secretaria, fn_listar_matriculas_apoderado,
    fn_rep_01_matriculados_apoderado, fn_rep_02_recaudacion_medio,
    fn_rep_03_ficha_medica, fn_rep_04_pendientes_validacion,
    fn_rep_05_boletas_destinatario, fn_rep_06_autorizaciones,
    fn_rep_07_directorio_domicilio, fn_rep_08_estadistica_grados,
    fn_rep_09_estado_pagos, fn_rep_10_auditoria_triggers
TO rol_secretaria;