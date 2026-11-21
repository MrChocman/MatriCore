-- 0. COMANDO DE LIMPIEZA TOTAL (Borra datos previos y reinicia secuencias)
TRUNCATE TABLE 
    AUDITORIA_MATRICULA, AUTORIZACION, MATRICULA, BOLETA_ELECTRONICA, PAGO_MATRICULA,
    CONDICION_ESPECIAL, ENFERMEDAD, ALERGIA, TELEFONO_EMERGENCIA, FICHA_MEDICA,
    TELEFONO_APODERADO, HOGAR, REPRESENTA, DESTINATARIO, APODERADO, ESTUDIANTE
RESTART IDENTITY CASCADE;

-- 1. ESTUDIANTES (30 REGISTROS: 70000001 al 70000030)
INSERT INTO ESTUDIANTE (DNI, Nombre, Apellido_Pat, Apellido_Mat, Fecha_nac) VALUES
('70000001', 'Mateo', 'Salas', 'Rivera', '2015-01-10'),
('70000002', 'Camila', 'Vargas', 'Lopez', '2014-05-22'),
('70000003', 'Sebastian', 'Perez', 'Gomez', '2015-08-30'),
('70000004', 'Lucia', 'Chavez', 'Zuniga', '2013-11-15'),
('70000005', 'Diego', 'Mamani', 'Quispe', '2016-02-28'),
('70000006', 'Valeria', 'Ramos', 'Delgado', '2014-07-19'),
('70000007', 'Joaquin', 'Salazar', 'Medina', '2015-04-05'),
('70000008', 'Mariana', 'Cruz', 'Paredes', '2013-09-12'),
('70000009', 'Gabriel', 'Torres', 'Fernandez', '2016-12-01'),
('70000010', 'Daniela', 'Flores', 'Rojas', '2015-06-25'),
('70000011', 'Lucas', 'Mendoza', 'Condori', '2014-03-08'),
('70000012', 'Fernanda', 'Gutierrez', 'Nina', '2015-10-14'),
('70000013', 'Matias', 'Cardenas', 'Silva', '2013-12-30'),
('70000014', 'Sofia', 'Rios', 'Caceres', '2016-08-20'),
('70000015', 'Rodrigo', 'Pinto', 'Aguilar', '2014-01-17'),
('70000016', 'Paula', 'Mejia', 'Huaman', '2015-11-03'),
('70000017', 'Alejandro', 'Velasquez', 'Morales', '2013-05-29'),
('70000018', 'Andrea', 'Castillo', 'Ortega', '2016-04-11'),
('70000019', 'Nicolas', 'Herrera', 'Paz', '2014-09-26'),
('70000020', 'Valentina', 'Guillen', 'Soto', '2015-02-18'),
('70000021', 'Renato', 'Valencia', 'Molina', '2015-03-14'),
('70000022', 'Isabella', 'Nunez', 'Campos', '2014-08-09'),
('70000023', 'Thiago', 'rodriguez', 'Apaza', '2016-01-21'),
('70000024', 'Abril', 'Sarmiento', 'Vega', '2013-10-05'),
('70000025', 'Emilio', 'Palomino', 'Ticona', '2015-07-11'),
('70000026', 'Ximena', 'Alvarez', 'Benavides', '2014-12-19'),
('70000027', 'Bruno', 'Esquivel', 'Zevallos', '2016-05-03'),
('70000028', 'Natalia', 'Cornejo', 'Farfan', '2013-06-27'),
('70000029', 'Gael', 'Montoya', 'Bellido', '2015-09-08'),
('70000030', 'Antonella', 'Gallegos', 'Pacheco', '2014-02-14');


-- 2. APODERADOS Y DESTINATARIOS
INSERT INTO APODERADO (DNI_Apod, Nombre, Apellido_Pat, Apellido_Mat, Ocupacion, Correo, Correo_verificado) VALUES
('40000001', 'Carlos', 'Salas', 'Mendez', 'Ingeniero', 'csalas@correo.com', 'Sí'),
('40000002', 'Maria', 'Vargas', 'Tito', 'Enfermera', 'mvargas@correo.com', 'Sí'),
('40000003', 'Jorge', 'Perez', 'Luna', 'Comerciante', 'jperez@correo.com', 'No'),
('40000004', 'Rosa', 'Chavez', 'Pina', 'Docente', 'rchavez@correo.com', 'Sí'),
('40000005', 'Luis', 'Mamani', 'Suca', 'Contador', 'lmamani@correo.com', 'No'),
('40000006', 'Ana', 'Ramos', 'Perez', 'Abogada', 'aramos@correo.com', 'Sí'),
('40000007', 'Jose', 'Salazar', 'Mora', 'Arquitecto', 'jsalazar@correo.com', 'Sí'),
('40000008', 'Carmen', 'Cruz', 'Linares', 'Medico', 'ccruz@correo.com', 'Sí'),
('40000009', 'Pedro', 'Torres', 'Soto', 'Administrador', 'ptorres@correo.com', 'No'),
('40000010', 'Elena', 'Flores', 'Quispe', 'Chef', 'eflores@correo.com', 'Sí'),
('40000011', 'Miguel', 'Mendoza', 'Cari', 'Taxista', 'mmendoza@correo.com', 'Sí'),
('40000012', 'Laura', 'Gutierrez', 'Paz', 'Banquera', 'lgutierrez@correo.com', 'No'),
('40000013', 'Andres', 'Cardenas', 'Ruiz', 'Policia', 'acardenas@correo.com', 'Sí'),
('40000014', 'Patricia', 'Rios', 'Gala', 'Periodista', 'prios@correo.com', 'Sí'),
('40000015', 'Raul', 'Pinto', 'Vega', 'Empresario', 'rpinto@correo.com', 'No'),
('40000016', 'Fernando', 'Valencia', 'Cruz', 'Economista', 'fvalencia@correo.com', 'Sí'),
('40000017', 'Gabriela', 'Nunez', 'Solis', 'Psicologa', 'gnunez@correo.com', 'Sí'),
('40000018', 'Hector', 'Rodriguez', 'Mamani', 'Transportista', 'hrodriguez@correo.com', 'Sí'),
('40000019', 'Silvia', 'Sarmiento', 'Lazo', 'Farmaceutica', 'ssarmiento@correo.com', 'Sí'),
('40000020', 'Oscar', 'Palomino', 'Ramos', 'Ingeniero Civil', 'opalomino@correo.com', 'Sí'),
('40000021', 'Monica', 'Alvarez', 'Tapia', 'Contadora', 'malvarez@correo.com', 'Sí'),
('40000022', 'Ricardo', 'Esquivel', 'Paredes', 'Odontologo', 'resquivel@correo.com', 'Sí'),
('40000023', 'Beatriz', 'Cornejo', 'Salas', 'Docente', 'bcornejo@correo.com', 'Sí'),
('40000024', 'Alvaro', 'Montoya', 'Castro', 'Analista TI', 'amontoya@correo.com', 'Sí'),
('40000025', 'Claudia', 'Gallegos', 'Ortiz', 'Diseñadora', 'cgallegos@correo.com', 'Sí');

INSERT INTO DESTINATARIO (DNI_destinatario, Destinatario, Correo_destinatario) VALUES
('40000001', 'Carlos Salas Mendez', 'csalas@correo.com'),
('40000002', 'Maria Vargas Tito', 'mvargas@correo.com'),
('40000003', 'Jorge Perez Luna', 'jperez@correo.com'),
('40000004', 'Rosa Chavez Pina', 'rchavez@correo.com'),
('40000005', 'Luis Mamani Suca', 'lmamani@correo.com'),
('40000006', 'Ana Ramos Perez', 'aramos@correo.com'),
('40000007', 'Jose Salazar Mora', 'jsalazar@correo.com'),
('40000008', 'Carmen Cruz Linares', 'ccruz@correo.com'),
('40000009', 'Pedro Torres Soto', 'ptorres@correo.com'),
('40000010', 'Elena Flores Quispe', 'eflores@correo.com'),
('40000011', 'Miguel Mendoza Cari', 'mmendoza@correo.com'),
('40000012', 'Laura Gutierrez Paz', 'lgutierrez@correo.com'),
('40000013', 'Andres Cardenas Ruiz', 'acardenas@correo.com'),
('40000014', 'Patricia Rios Gala', 'prios@correo.com'),
('40000015', 'Raul Pinto Vega', 'rpinto@correo.com'),
('40000016', 'Fernando Valencia Cruz', 'fvalencia@correo.com'),
('40000017', 'Gabriela Nunez Solis', 'gnunez@correo.com'),
('40000018', 'Hector Rodriguez Mamani', 'hrodriguez@correo.com'),
('40000019', 'Silvia Sarmiento Lazo', 'ssarmiento@correo.com'),
('40000020', 'Oscar Palomino Ramos', 'opalomino@correo.com'),
('40000021', 'Monica Alvarez Tapia', 'malvarez@correo.com'),
('40000022', 'Ricardo Esquivel Paredes', 'resquivel@correo.com'),
('40000023', 'Beatriz Cornejo Salas', 'bcornejo@correo.com'),
('40000024', 'Alvaro Montoya Castro', 'amontoya@correo.com'),
('40000025', 'Claudia Gallegos Ortiz', 'cgallegos@correo.com');

-- 3. REPRESENTA, HOGAR Y TELÉFONOS
INSERT INTO REPRESENTA (DNI_est, DNI_Apod, Parentesco) VALUES
('70000001', '40000001', 'Padre'), ('70000002', '40000002', 'Madre'),
('70000003', '40000003', 'Padre'), ('70000004', '40000004', 'Madre'),
('70000005', '40000005', 'Padre'), ('70000006', '40000006', 'Madre'),
('70000007', '40000007', 'Padre'), ('70000008', '40000008', 'Madre'),
('70000009', '40000009', 'Padre'), ('70000010', '40000010', 'Madre'),
('70000011', '40000011', 'Padre'), ('70000012', '40000012', 'Madre'),
('70000013', '40000013', 'Padre'), ('70000014', '40000014', 'Madre'),
('70000015', '40000015', 'Padre'), ('70000016', '40000001', 'Padre'),
('70000017', '40000002', 'Madre'), ('70000018', '40000003', 'Padre'),
('70000019', '40000004', 'Madre'), ('70000020', '40000005', 'Padre'),
('70000021', '40000016', 'Padre'), ('70000022', '40000017', 'Madre'),
('70000023', '40000018', 'Padre'), ('70000024', '40000019', 'Madre'),
('70000025', '40000020', 'Padre'), ('70000026', '40000021', 'Madre'),
('70000027', '40000022', 'Padre'), ('70000028', '40000023', 'Madre'),
('70000029', '40000024', 'Padre'), ('70000030', '40000025', 'Madre');

INSERT INTO HOGAR (DNI_Apod, Calle, Numero_vivienda, Distrito, Referencias) VALUES
('40000001', 'Av. Ejercito', '101', 'Yanahuara', 'Frente a la plaza'),
('40000002', 'Calle Misti', '202', 'Cayma', 'Cerca al banco'),
('40000003', 'Av. Dolores', '303', 'Bustamante', 'Lote 4'),
('40000004', 'Calle Mercaderes', '404', 'Cercado', 'Segundo piso'),
('40000005', 'Av. Parra', '505', 'Cercado', NULL),
('40000006', 'Calle Tronchadero', '606', 'Yanahuara', 'Casa verde'),
('40000007', 'Av. Bolognesi', '707', 'Cayma', NULL),
('40000008', 'Calle Pierola', '808', 'Cercado', 'Esquina'),
('40000009', 'Av. Salaverry', '909', 'Miraflores', 'Edificio blanco'),
('40000010', 'Calle Grande', '111', 'Sachaca', NULL),
('40000011', 'Av. Las Convenciones', '222', 'Bustamante', 'Lote 9'),
('40000012', 'Calle Grau', '333', 'Paucarpata', 'Frente al parque'),
('40000013', 'Av. Goyeneche', '444', 'Miraflores', NULL),
('40000014', 'Calle Rivero', '555', 'Cercado', 'Interior 3'),
('40000015', 'Av. Jesus', '666', 'Paucarpata', 'Esquina con cementerio'),
('40000016', 'Av. Cayma', '120', 'Cayma', 'Cerca al mall'),
('40000017', 'Calle Sucre', '215', 'Cercado', NULL),
('40000018', 'Av. Hartley', '340', 'Bustamante', 'Frente a parque'),
('40000019', 'Calle Bolivar', '412', 'Yanahuara', NULL),
('40000020', 'Av. Mariscal Castilla', '518', 'Miraflores', 'Edificio azul'),
('40000021', 'Calle Tacna', '622', 'Sachaca', NULL),
('40000022', 'Av. Colonial', '730', 'Paucarpata', 'Lote 12'),
('40000023', 'Calle San Francisco', '814', 'Cercado', NULL),
('40000024', 'Av. Trinidad Moran', '905', 'Cayma', 'Segundo piso'),
('40000025', 'Calle Quesada', '104', 'Yanahuara', 'Casa esquina');

INSERT INTO TELEFONO_APODERADO (DNI_Apod, Telefono) VALUES
('40000001', '900111222'), ('40000002', '900222333'), ('40000003', '900333444'),
('40000004', '900444555'), ('40000005', '900555666'), ('40000006', '900666777'),
('40000007', '900777888'), ('40000008', '900888999'), ('40000009', '900999000'),
('40000010', '911000111'), ('40000011', '911111222'), ('40000012', '911222333'),
('40000013', '911333444'), ('40000014', '911444555'), ('40000015', '911555666'),
('40000016', '922111222'), ('40000017', '922222333'), ('40000018', '922333444'),
('40000019', '922444555'), ('40000020', '922555666'), ('40000021', '922666777'),
('40000022', '922777888'), ('40000023', '922888999'), ('40000024', '922999000'),
('40000025', '933000111');

-- 4. FICHA MÉDICA Y MULTIVALUADOS (30 REGISTROS)
INSERT INTO FICHA_MEDICA (DNI_est, Grupo_sang, Seguro, Observaciones) VALUES
('70000001', 'O+', 'SIS', 'Ninguna'), ('70000002', 'A+', 'EsSalud', 'Requiere lentes'),
('70000003', 'B+', 'Privado', NULL), ('70000004', 'O-', 'SIS', 'Control anual'),
('70000005', 'AB+', 'EsSalud', NULL), ('70000006', 'A-', 'Privado', 'Asma controlada'),
('70000007', 'O+', 'SIS', NULL), ('70000008', 'B-', 'EsSalud', 'Ninguna'),
('70000009', 'O+', 'Privado', NULL), ('70000010', 'A+', 'SIS', 'Alergias menores'),
('70000011', 'O+', 'EsSalud', NULL), ('70000012', 'B+', 'Privado', 'Problemas auditivos leves'),
('70000013', 'O-', 'SIS', NULL), ('70000014', 'AB-', 'EsSalud', 'Ninguna'),
('70000015', 'A+', 'Privado', NULL), ('70000016', 'O+', 'SIS', NULL),
('70000017', 'B+', 'EsSalud', 'Miopia'), ('70000018', 'O+', 'Privado', NULL),
('70000019', 'A-', 'SIS', 'Ninguna'), ('70000020', 'O-', 'EsSalud', NULL),
('70000021', 'O+', 'Privado', NULL), ('70000022', 'A+', 'EsSalud', 'Ninguna'),
('70000023', 'B+', 'SIS', NULL), ('70000024', 'O-', 'Privado', 'Usa inhalador'),
('70000025', 'O+', 'EsSalud', NULL), ('70000026', 'A-', 'SIS', 'Ninguna'),
('70000027', 'AB+', 'Privado', NULL), ('70000028', 'O+', 'EsSalud', NULL),
('70000029', 'B-', 'SIS', 'Ninguna'), ('70000030', 'A+', 'Privado', NULL);

INSERT INTO TELEFONO_EMERGENCIA (DNI_est, Telefono_emer) VALUES
('70000001', '999111001'), ('70000002', '999111002'), ('70000003', '999111003'),
('70000004', '999111004'), ('70000005', '999111005'), ('70000006', '999111006'),
('70000007', '999111007'), ('70000008', '999111008'), ('70000009', '999111009'),
('70000010', '999111010'), ('70000011', '999111011'), ('70000012', '999111012'),
('70000013', '999111013'), ('70000014', '999111014'), ('70000015', '999111015'),
('70000016', '999111016'), ('70000017', '999111017'), ('70000018', '999111018'),
('70000019', '999111019'), ('70000020', '999111020'), ('70000021', '999111021'),
('70000022', '999111022'), ('70000023', '999111023'), ('70000024', '999111024'),
('70000025', '999111025'), ('70000026', '999111026'), ('70000027', '999111027'),
('70000028', '999111028'), ('70000029', '999111029'), ('70000030', '999111030');

INSERT INTO ALERGIA (DNI_est, Alergia) VALUES 
('70000001', 'Penicilina'), ('70000004', 'Polvo'), ('70000010', 'Mariscos'),
('70000015', 'Paracetamol'), ('70000022', 'Polen'), ('70000028', 'Lactosa');

INSERT INTO ENFERMEDAD (DNI_est, Enfermedad) VALUES 
('70000002', 'Varicela'), ('70000006', 'Bronquitis'), ('70000014', 'Hepatitis A'), ('70000024', 'Rinitis');

INSERT INTO CONDICION_ESPECIAL (DNI_est, Condicion) VALUES 
('70000006', 'Asma'), ('70000012', 'Hipoacusia'), ('70000018', 'TDAH'), ('70000024', 'Asma leve');

-- 5. PAGOS (30 OPERACIONES: OP-001 a OP-030)
--    - OP-001 a OP-016: Ya usados en matrículas
--    - OP-017 a OP-019 y OP-021 a OP-029: 12 PAGOS LIBRES ('Pagado') para probar en vivo
--    - OP-020 y OP-030: 2 PAGOS PENDIENTES ('Pendiente') para probar bloqueo ACID

INSERT INTO PAGO_MATRICULA (Nro_operacion, DNI_Apod, Monto, Estado_pago, Medio_pago, Fecha_pago) VALUES
('OP-001', '40000001', 250.00, 'Pagado', 'Banca virtual', '2026-12-01'),
('OP-002', '40000002', 250.00, 'Pagado', 'Agente', '2026-12-02'),
('OP-003', '40000003', 250.00, 'Pagado', 'Transferencia', '2026-12-03'),
('OP-004', '40000004', 250.00, 'Pagado', 'Caja', '2026-12-04'),
('OP-005', '40000005', 250.00, 'Pagado', 'Banca virtual', '2026-12-05'),
('OP-006', '40000006', 250.00, 'Pagado', 'Agente', '2026-12-06'),
('OP-007', '40000007', 250.00, 'Pagado', 'Transferencia', '2026-12-07'),
('OP-008', '40000008', 250.00, 'Pagado', 'Caja', '2026-12-08'),
('OP-009', '40000009', 250.00, 'Pagado', 'Banca virtual', '2026-12-09'),
('OP-010', '40000010', 250.00, 'Pagado', 'Agente', '2026-12-10'),
('OP-011', '40000011', 250.00, 'Pagado', 'Transferencia', '2026-12-11'),
('OP-012', '40000012', 250.00, 'Pagado', 'Caja', '2026-12-12'),
('OP-013', '40000013', 250.00, 'Pagado', 'Banca virtual', '2026-12-13'),
('OP-014', '40000014', 250.00, 'Pagado', 'Agente', '2026-12-14'),
('OP-015', '40000015', 250.00, 'Pagado', 'Transferencia', '2026-12-15'),
('OP-016', '40000001', 250.00, 'Pagado', 'Banca virtual', '2026-12-16'),
('OP-017', '40000002', 250.00, 'Pagado', 'Caja', '2026-12-17'),
('OP-018', '40000003', 250.00, 'Pagado', 'Agente', '2026-12-18'),
('OP-019', '40000004', 250.00, 'Pagado', 'Transferencia', '2026-12-19'),
('OP-020', '40000005', 250.00, 'Pendiente', 'Banca virtual', '2026-12-20'),
('OP-021', '40000016', 250.00, 'Pagado', 'Banca virtual', '2026-12-21'),
('OP-022', '40000017', 250.00, 'Pagado', 'Agente', '2026-12-21'),
('OP-023', '40000018', 250.00, 'Pagado', 'Transferencia', '2026-12-22'),
('OP-024', '40000019', 250.00, 'Pagado', 'Caja', '2026-12-22'),
('OP-025', '40000020', 250.00, 'Pagado', 'Banca virtual', '2026-12-23'),
('OP-026', '40000021', 250.00, 'Pagado', 'Agente', '2026-12-23'),
('OP-027', '40000022', 250.00, 'Pagado', 'Transferencia', '2026-12-24'),
('OP-028', '40000023', 250.00, 'Pagado', 'Caja', '2026-12-24'),
('OP-029', '40000024', 250.00, 'Pagado', 'Banca virtual', '2026-12-25'),
('OP-030', '40000025', 250.00, 'Pendiente', 'Agente', '2026-12-25');


-- 6. MATRÍCULAS, BOLETAS Y AUTORIZACIONES INICIALES
INSERT INTO MATRICULA (ID_Matri, DNI_est, Nro_operacion, Anio_academico, Grado_matricular, Estado_matri, Fecha_matri) VALUES
('M-2026-001', '70000001', 'OP-001', 2026, '2do Primaria', 'Matriculado', '2026-12-01'),
('M-2026-002', '70000002', 'OP-002', 2026, '2do Primaria', 'Matriculado', '2026-12-02'),
('M-2026-003', '70000003', 'OP-003', 2026, '1ro Primaria', 'Matriculado', '2026-12-03'),
('M-2026-004', '70000004', 'OP-004', 2026, '3ro Primaria', 'Matriculado', '2026-12-04'),
('M-2026-005', '70000005', 'OP-005', 2026, '1ro Primaria', 'Matriculado', '2026-12-05'),
('M-2026-006', '70000006', 'OP-006', 2026, '2do Primaria', 'Matriculado', '2026-12-06'),
('M-2026-007', '70000007', 'OP-007', 2026, '1ro Primaria', 'Matriculado', '2026-12-07'),
('M-2026-008', '70000008', 'OP-008', 2026, '4to Primaria', 'Matriculado', '2026-12-08'),
('M-2026-009', '70000009', 'OP-009', 2026, '1ro Primaria', 'Matriculado', '2026-12-09'),
('M-2026-010', '70000010', 'OP-010', 2026, '2do Primaria', 'Matriculado', '2026-12-10'),
('M-2026-011', '70000011', 'OP-011', 2026, '3ro Primaria', 'Matriculado', '2026-12-11'),
('M-2026-012', '70000012', 'OP-012', 2026, '2do Primaria', 'Matriculado', '2026-12-12'),
('M-2026-013', '70000013', 'OP-013', 2026, '4to Primaria', 'Pendiente', '2026-12-13'),
('M-2026-014', '70000014', 'OP-014', 2026, '1ro Primaria', 'Pendiente', '2026-12-14'),
('M-2026-015', '70000015', 'OP-015', 2026, '3ro Primaria', 'Pendiente', '2026-12-15'),
('M-2026-016', '70000016', 'OP-016', 2026, '2do Primaria', 'Pendiente', '2026-12-16'),
('M-2025-017', '70000001', 'OP-001', 2025, '1ro Primaria', 'Matriculado', '2025-12-01'),
('M-2025-018', '70000002', 'OP-002', 2025, '1ro Primaria', 'Matriculado', '2025-12-02'),
('M-2025-019', '70000004', 'OP-004', 2025, '2do Primaria', 'Matriculado', '2025-12-04'),
('M-2025-020', '70000008', 'OP-008', 2025, '3ro Primaria', 'Matriculado', '2025-12-08');

INSERT INTO BOLETA_ELECTRONICA (Serie, Nro_operacion, DNI_destinatario, Fecha_emision, Tipo_de_servicio) VALUES
('B001', 'OP-001', '40000001', '2026-12-01', 'Matricula'), ('B001', 'OP-002', '40000002', '2026-12-02', 'Matricula'),
('B001', 'OP-003', '40000003', '2026-12-03', 'Matricula'), ('B001', 'OP-004', '40000004', '2026-12-04', 'Matricula'),
('B001', 'OP-005', '40000005', '2026-12-05', 'Matricula'), ('B001', 'OP-006', '40000006', '2026-12-06', 'Matricula'),
('B001', 'OP-007', '40000007', '2026-12-07', 'Matricula'), ('B001', 'OP-008', '40000008', '2026-12-08', 'Matricula'),
('B001', 'OP-009', '40000009', '2026-12-09', 'Matricula'), ('B001', 'OP-010', '40000010', '2026-12-10', 'Matricula'),
('B001', 'OP-011', '40000011', '2026-12-11', 'Matricula'), ('B001', 'OP-012', '40000012', '2026-12-12', 'Matricula'),
('B001', 'OP-013', '40000013', '2026-12-13', 'Matricula'), ('B001', 'OP-014', '40000014', '2026-12-14', 'Matricula'),
('B001', 'OP-015', '40000015', '2026-12-15', 'Matricula'), ('B001', 'OP-016', '40000001', '2026-12-16', 'Matricula'),
('B001', 'OP-017', '40000002', '2026-12-17', 'Matricula'), ('B001', 'OP-018', '40000003', '2026-12-18', 'Matricula'),
('B001', 'OP-019', '40000004', '2026-12-19', 'Matricula'), ('B001', 'OP-020', '40000005', '2026-12-20', 'Matricula'),
('B001', 'OP-021', '40000016', '2026-12-21', 'Matricula'), ('B001', 'OP-022', '40000017', '2026-12-21', 'Matricula'),
('B001', 'OP-023', '40000018', '2026-12-22', 'Matricula'), ('B001', 'OP-024', '40000019', '2026-12-22', 'Matricula'),
('B001', 'OP-025', '40000020', '2026-12-23', 'Matricula'), ('B001', 'OP-026', '40000021', '2026-12-23', 'Matricula'),
('B001', 'OP-027', '40000022', '2026-12-24', 'Matricula'), ('B001', 'OP-028', '40000023', '2026-12-24', 'Matricula'),
('B001', 'OP-029', '40000024', '2026-12-25', 'Matricula'), ('B001', 'OP-030', '40000025', '2026-12-25', 'Matricula');

INSERT INTO AUTORIZACION (ID_Matri, ID_Aut, DNI_Apod, Tipo, Fecha_aut, Estado_aut) VALUES
('M-2026-001', 'A-001', '40000001', 'Uso de imagen', '2026-12-01', 'Autorizado'),
('M-2026-002', 'A-002', '40000002', 'Salidas', '2026-12-02', 'Autorizado'),
('M-2026-003', 'A-003', '40000003', 'Uso de imagen', '2026-12-03', 'Autorizado'),
('M-2026-004', 'A-004', '40000004', 'Salidas', '2026-12-04', 'Autorizado'),
('M-2026-005', 'A-005', '40000005', 'Uso de imagen', '2026-12-05', 'Autorizado'),
('M-2026-006', 'A-006', '40000006', 'Salidas', '2026-12-06', 'Autorizado'),
('M-2026-007', 'A-007', '40000007', 'Uso de imagen', '2026-12-07', 'Autorizado'),
('M-2026-008', 'A-008', '40000008', 'Salidas', '2026-12-08', 'Autorizado'),
('M-2026-009', 'A-009', '40000009', 'Uso de imagen', '2026-12-09', 'Autorizado'),
('M-2026-010', 'A-010', '40000010', 'Salidas', '2026-12-10', 'Autorizado'),
('M-2026-011', 'A-011', '40000011', 'Uso de imagen', '2026-12-11', 'Autorizado'),
('M-2026-012', 'A-012', '40000012', 'Salidas', '2026-12-12', 'Autorizado'),
('M-2026-013', 'A-013', '40000013', 'Uso de imagen', '2026-12-13', 'Pendiente'),
('M-2026-014', 'A-014', '40000014', 'Salidas', '2026-12-14', 'Pendiente'),
('M-2026-015', 'A-015', '40000015', 'Uso de imagen', '2026-12-15', 'Pendiente'),
('M-2026-016', 'A-016', '40000001', 'Salidas', '2026-12-16', 'Pendiente'),
('M-2025-017', 'A-017', '40000001', 'Uso de imagen', '2025-12-01', 'Autorizado'),
('M-2025-018', 'A-018', '40000002', 'Salidas', '2025-12-02', 'Autorizado'),
('M-2025-019', 'A-019', '40000004', 'Uso de imagen', '2025-12-04', 'Autorizado'),
('M-2025-020', 'A-020', '40000008', 'Salidas', '2025-12-08', 'Autorizado');


TRUNCATE TABLE AUDITORIA_MATRICULA RESTART IDENTITY;