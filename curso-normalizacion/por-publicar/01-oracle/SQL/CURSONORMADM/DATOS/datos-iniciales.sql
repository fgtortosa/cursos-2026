-- =============================================================================
-- DATOS INICIALES — CURSONORMADM
-- Schema: ReserUA (versión curso normalización)
-- Generado: 2026-05-11
-- =============================================================================
-- INSTRUCCIONES:
--   Conectar como CURSONORMADM antes de ejecutar.
--   Los IDs son IDENTITY: no se insertan manualmente.
--   Ejecutar primero TRES_TIPO_RECURSO (necesario para la FK).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TRES_TIPO_RECURSO — Catálogo de tipos de recurso reservable
-- -----------------------------------------------------------------------------
-- Nota: sin ACTIVO ni borrado lógico. DELETE físico si no hay recursos asociados.

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('AULA', 'Aula', 'Aula', 'Classroom');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('LABORATORIO', 'Laboratorio', 'Laboratori', 'Laboratory');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('SALA_REUNIONES', 'Sala de reuniones', 'Sala de reunions', 'Meeting room');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('DESPACHO', 'Despacho', 'Despatx', 'Office');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('SALA_INFORMATICA', 'Sala de informática', 'Sala d''informàtica', 'Computer room');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('AUDITORIO', 'Auditorio', 'Auditori', 'Auditorium');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('SALA_ESTUDIO', 'Sala de estudio', 'Sala d''estudi', 'Study room');

INSERT INTO CURSONORMADM.TRES_TIPO_RECURSO (CODIGO, NOMBRE_ES, NOMBRE_CA, NOMBRE_EN)
VALUES ('ESPACIO_DEPORTIVO', 'Instalación deportiva', 'Instal·lació esportiva', 'Sports facility');

COMMIT;


-- -----------------------------------------------------------------------------
-- TRES_RECURSO — Recursos reservables específicos
-- -----------------------------------------------------------------------------
-- Columnas:
--   NOMBRE_ES / NOMBRE_CA / NOMBRE_EN      — obligatorias
--   DESCRIPCION_ES / _CA / _EN             — opcionales (CLOB)
--   GRANULIDAD                             — minutos mínimos de reserva (múltiplo)
--   DURACION                               — duración por defecto de la reserva (minutos)
--   ID_TIPO_RECURSO                        — FK a TRES_TIPO_RECURSO
--   ACTIVO  ('S'/'N')                      — borrado lógico
--   VISIBLE ('S'/'N')                      — aparece en el buscador público
--   ATIENDE_MISMA_PERSONA ('S'/'N')        — se asigna a una persona responsable
-- -----------------------------------------------------------------------------

-- ── AULA (ID 1) ──────────────────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Aula Magna', 'Aula Magna', 'Main Hall',
   'Aula de gran capacidad para actos académicos y conferencias. Aforo: 400 personas.',
   'Aula de gran capacitat per a actes acadèmics i conferències. Aforament: 400 persones.',
   'Large capacity hall for academic events and conferences. Capacity: 400 people.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AULA'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Aula 1.01 — Edificio A', 'Aula 1.01 — Edifici A', 'Room 1.01 — Building A',
   'Aula docente equipada con proyector y pizarra digital. Aforo: 60 personas.',
   'Aula docent equipada amb projector i pissarra digital. Aforament: 60 persones.',
   'Teaching room equipped with projector and smart board. Capacity: 60 people.',
   30, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AULA'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Seminario 002 — Edificio B', 'Seminari 002 — Edifici B', 'Seminar Room 002 — Building B',
   'Sala seminario para grupos reducidos. Aforo: 25 personas. Disponible con reserva previa.',
   'Sala seminari per a grups reduïts. Aforament: 25 persones. Disponible amb reserva prèvia.',
   'Seminar room for small groups. Capacity: 25 people. Available on prior booking.',
   30, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AULA'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Aula 3.12 — Edificio C (en obras)', 'Aula 3.12 — Edifici C (en obres)', 'Room 3.12 — Building C (under renovation)',
   'Aula temporalmente fuera de servicio por obras de renovación.',
   'Aula temporalment fora de servei per obres de renovació.',
   'Room temporarily out of service due to renovation works.',
   30, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AULA'),
   'N', 'N', 'N', SYSDATE);

-- ── LABORATORIO (ID 2) ───────────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Laboratorio de Química Orgánica', 'Laboratori de Química Orgànica', 'Organic Chemistry Laboratory',
   'Laboratorio equipado para prácticas de química orgánica. Aforo: 30 estudiantes. Requiere acreditación de seguridad.',
   'Laboratori equipat per a pràctiques de química orgànica. Aforament: 30 estudiants. Requereix acreditació de seguretat.',
   'Laboratory equipped for organic chemistry practicals. Capacity: 30 students. Safety accreditation required.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'LABORATORIO'),
   'S', 'S', 'S', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Laboratorio de Física Experimental', 'Laboratori de Física Experimental', 'Experimental Physics Laboratory',
   'Laboratorio de física con equipos de medición de precisión. Aforo: 24 estudiantes.',
   'Laboratori de física amb equips de mesura de precisió. Aforament: 24 estudiants.',
   'Physics laboratory with precision measurement equipment. Capacity: 24 students.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'LABORATORIO'),
   'S', 'S', 'S', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Laboratorio de Biología Molecular', 'Laboratori de Biologia Molecular', 'Molecular Biology Laboratory',
   'Laboratorio con equipamiento de biología molecular: PCR, electroforesis y microscopios. Aforo: 20 estudiantes.',
   'Laboratori amb equipament de biologia molecular: PCR, electroforesi i microscopis. Aforament: 20 estudiants.',
   'Laboratory with molecular biology equipment: PCR, electrophoresis and microscopes. Capacity: 20 students.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'LABORATORIO'),
   'S', 'S', 'S', SYSDATE);

-- ── SALA DE REUNIONES (ID 3) ─────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Juntas del Rectorado', 'Sala de Juntes del Rectorat', 'Rectorate Board Room',
   'Sala de representación institucional con videoconferencia integrada. Aforo: 20 personas.',
   'Sala de representació institucional amb videoconferència integrada. Aforament: 20 persones.',
   'Institutional representation room with integrated video conferencing. Capacity: 20 people.',
   30, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_REUNIONES'),
   'S', 'N', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Reuniones Decanato — Facultad de Ciencias', 'Sala de Reunions Deganat — Facultat de Ciències', 'Meeting Room — Faculty of Sciences Dean''s Office',
   'Sala de reuniones de uso interno del decanato. Aforo: 12 personas.',
   'Sala de reunions d''ús intern del deganat. Aforament: 12 persones.',
   'Internal meeting room for the dean''s office. Capacity: 12 people.',
   30, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_REUNIONES'),
   'S', 'N', 'N', SYSDATE);

-- ── DESPACHO (ID 4) ──────────────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Despacho de Tutorías A-201', 'Despatx de Tutories A-201', 'Tutorial Office A-201',
   'Despacho habilitado para tutorías y atención al estudiante. Aforo: 4 personas.',
   'Despatx habilitat per a tutories i atenció a l''estudiantat. Aforament: 4 persones.',
   'Office set up for tutorials and student support. Capacity: 4 people.',
   30, 30,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'DESPACHO'),
   'S', 'S', 'S', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Despacho de Tutorías B-105', 'Despatx de Tutories B-105', 'Tutorial Office B-105',
   'Despacho compartido para tutorías. Disponible en horario de mañana. Aforo: 4 personas.',
   'Despatx compartit per a tutories. Disponible en horari de matí. Aforament: 4 persones.',
   'Shared office for tutorials. Available in the morning. Capacity: 4 people.',
   30, 30,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'DESPACHO'),
   'S', 'S', 'S', SYSDATE);

-- ── SALA DE INFORMÁTICA (ID 5) ───────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Informática 1 — Edificio Politécnica II', 'Sala d''Informàtica 1 — Edifici Politècnica II', 'Computer Room 1 — Polytechnic Building II',
   'Sala con 40 puestos equipados con Windows 11 y software de desarrollo. Aforo: 40 estudiantes.',
   'Sala amb 40 llocs equipats amb Windows 11 i programari de desenvolupament. Aforament: 40 estudiants.',
   'Room with 40 workstations running Windows 11 and development software. Capacity: 40 students.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_INFORMATICA'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Informática 2 — Biblioteca General', 'Sala d''Informàtica 2 — Biblioteca General', 'Computer Room 2 — Main Library',
   'Sala de acceso libre con 30 equipos para trabajo de estudiantes. Aforo: 30 personas.',
   'Sala d''accés lliure amb 30 equips per a treball d''estudiants. Aforament: 30 persones.',
   'Open-access room with 30 computers for student use. Capacity: 30 people.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_INFORMATICA'),
   'S', 'S', 'N', SYSDATE);

-- ── AUDITORIO (ID 6) ─────────────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Auditorio Principal del Campus', 'Auditori Principal del Campus', 'Main Campus Auditorium',
   'Auditorio con equipo de sonido profesional y sistema de traducción simultánea. Aforo: 500 personas.',
   'Auditori amb equip de so professional i sistema de traducció simultània. Aforament: 500 persones.',
   'Auditorium with professional sound equipment and simultaneous translation system. Capacity: 500 people.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AUDITORIO'),
   'S', 'S', 'S', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Actos — Facultad de Derecho', 'Sala d''Actes — Facultat de Dret', 'Event Hall — Faculty of Law',
   'Sala de actos con tarima y sistema audiovisual. Aforo: 200 personas.',
   'Sala d''actes amb tarima i sistema audiovisual. Aforament: 200 persones.',
   'Event hall with stage and audiovisual system. Capacity: 200 people.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'AUDITORIO'),
   'S', 'S', 'S', SYSDATE);

-- ── SALA DE ESTUDIO (ID 7) ───────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Estudio en Silencio — Biblioteca General', 'Sala d''Estudi en Silenci — Biblioteca General', 'Silent Study Room — Main Library',
   'Zona de estudio individual en silencio. Acceso con tarjeta universitaria. 80 puestos.',
   'Zona d''estudi individual en silenci. Accés amb targeta universitària. 80 llocs.',
   'Individual silent study area. Access with university card. 80 seats.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_ESTUDIO'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Sala de Trabajo en Grupo A', 'Sala de Treball en Grup A', 'Group Study Room A',
   'Sala reservable para trabajo en grupo. Capacidad: 8 personas. Pizarra y pantalla.',
   'Sala reservable per a treball en grup. Capacitat: 8 persones. Pissarra i pantalla.',
   'Bookable room for group work. Capacity: 8 people. Whiteboard and screen.',
   60, 120,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'SALA_ESTUDIO'),
   'S', 'S', 'N', SYSDATE);

-- ── ESPACIO DEPORTIVO (ID 8) ─────────────────────────────────────────────────
INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Pista de Pádel 1', 'Pista de Pàdel 1', 'Padel Court 1',
   'Pista de pádel cubierta. Reservable en franjas de 1 hora. Solo miembros de la comunidad universitaria.',
   'Pista de pàdel coberta. Reservable en franges d''1 hora. Només membres de la comunitat universitària.',
   'Indoor padel court. Bookable in 1-hour slots. University community members only.',
   60, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'ESPACIO_DEPORTIVO'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Pabellón Polideportivo — Pista Central', 'Pavelló Poliesportiu — Pista Central', 'Sports Hall — Main Court',
   'Pista polideportiva para baloncesto, voleibol y fútbol sala. Aforo: 300 espectadores.',
   'Pista poliesportiva per a bàsquet, voleibol i futbol sala. Aforament: 300 espectadors.',
   'Multi-sport court for basketball, volleyball and indoor football. Spectator capacity: 300.',
   60, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'ESPACIO_DEPORTIVO'),
   'S', 'S', 'N', SYSDATE);

INSERT INTO CURSONORMADM.TRES_RECURSO
  (NOMBRE_ES, NOMBRE_CA, NOMBRE_EN,
   DESCRIPCION_ES, DESCRIPCION_CA, DESCRIPCION_EN,
   GRANULIDAD, DURACION, ID_TIPO_RECURSO,
   ACTIVO, VISIBLE, ATIENDE_MISMA_PERSONA, FECHA_MODIFICACION)
VALUES
  ('Piscina Cubierta', 'Piscina Coberta', 'Indoor Swimming Pool',
   'Piscina olímpica cubierta de 25 metros. Uso académico y libre para la comunidad universitaria.',
   'Piscina olímpica coberta de 25 metres. Ús acadèmic i lliure per a la comunitat universitària.',
   '25-metre indoor Olympic swimming pool. Academic and open use for the university community.',
   60, 60,
   (SELECT ID_TIPO_RECURSO FROM CURSONORMADM.TRES_TIPO_RECURSO WHERE CODIGO = 'ESPACIO_DEPORTIVO'),
   'N', 'N', 'N', SYSDATE);

COMMIT;
