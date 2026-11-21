# MatriCore - Sistema de Gestión de Matrícula

Aplicación cliente de escritorio desarrollada en Python (Tkinter + psycopg) conectada directamente a PostgreSQL, diseñada para gestionar el flujo de matrícula escolar bajo un esquema normalizado en 3FN, control de acceso basado en roles (RBAC), transacciones ACID, borrado lógico, triggers de auditoría automática y un módulo de 10 reportes institucionales encapsulados en funciones almacenadas.

# Características Principales

* Arquitectura Nativa sin Frameworks:Comunicación directa mediante el controlador `psycopg` (Psycopg 3) invocando procedimientos almacenados (`CALL`) y funciones tabulares (`SELECT * FROM fn_...`) en PostgreSQL.
* Seguridad y Roles Nativos (RBAC):
  * `rol_apoderado`: Acceso restringido bajo el principio de mínimo privilegio; visualiza únicamente el historial de sus hijos vinculados y registra solicitudes validando pagos conciliados (`Pagado`).
  * `rol_secretaria`: Control operativo completo para filtrar expedientes, aprobar matrículas (`UPDATE`), ejecutar anulaciones mediante borrado lógico (`Anulado`) y consultar reportes institucionales.
* Integridad Transaccional (ACID) y Automatización:
  * `sp_registrar_matricula`: Valida en servidor la existencia y estado conciliado del voucher en `PAGO_MATRICULA` antes de insertar.
  * `sp_actualizar_matricula` y `sp_eliminar_matricula`: Encapsulan la modificación de estado y el borrado lógico (`Estado_matri = 'Anulado'`) preservando el historial.
  * Triggers automáticos:`trg_auditoria_matricula` registra cada movimiento en `AUDITORIA_MATRICULA`, y `trg_generar_autorizacion_inicial` crea automáticamente la autorización legal vinculada al expediente.
* Módulo de Reportes (10 Consultas): Incluye 7 consultas relacionales multi-tabla (`JOIN`) y 3 reportes estadísticos/auditoría ejecutados desde funciones almacenadas.

# Estructura del Proyecto
MatriCore/
├── sql/
│   ├── CREACION DE BD Y TABLAS.sql        # Esquema relacional en 3FN (15 tablas)
│   ├── INSERCION REGISTROS.sql            # Carga inicial de registros coherentes
│   └── SCRIPTS SQL DE SEGURIDAD.sql       # Roles RBAC, Triggers, SPs CRUD y 10 Reportes
├── config.py                              # Parámetros de conexión y constantes visuales
├── database.py                            # Capa de acceso a datos (DAO) hacia PostgreSQL
├── main.py                                # Punto de entrada y orquestador de vistas
├── ui_login.py                            # Interfaz de autenticación dual (Apoderado / Secretaría)
├── ui_dashboard.py                        # Panel operativo CRUD adaptado por rol
├── ui_reportes.py                         # Módulo de visualización de los 10 reportes
├── requirements.txt                       # Dependencias externas de Python
└── README.md                              # Documentación técnica del repositorio

# INSTALACION
Ejecutar los scripts de la carpeta sql/ en PostgreSQL en el siguiente orden:

CREACION DE BD Y TABLAS.sql ->
SCRIPTS SQL DE SEGURIDAD.sql ->
INSERCION REGISTROS.sql

Ejecutar MatriCore_Setup.exe y seguir el asistente de instalación.
Abrir la aplicación desde el acceso directo MatriCore generado en el Escritorio.