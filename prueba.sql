


DROP DATABASE IF EXISTS "prueba-isabel-palacios-666";

CREATE DATABASE "prueba-isabel-palacios-666";

\c prueba-isabel-palacios-666;

CREATE TABLE peliculas(
    id SERIAL,
    nombre VARCHAR(255) DEFAULT NULL,
    anno INT DEFAULT NULL,
    PRIMARY KEY("id")
);

INSERT INTO peliculas(
    nombre,
    anno
    )
VALUES ('Trainwreck', 2018 ),
       ('Doctor Strange', 2022 ),
       ('IronMan' , 2008 ),
       ('Hulk', 2018 ),
       ('Thor Ragnarok', 2017 );

CREATE TABLE tags(
    id SERIAL,
    tag VARCHAR(32) DEFAULT NULL,
    PRIMARY KEY("id")
);

INSERT INTO tags(
    tag
    )
VALUES ('Acción' ),
       ('Romance' ),
       ('Animación' ),
       ('Infantil' ),
       ('Terror' );

CREATE TABLE PeliculasTags(
    id SERIAL,
    pelicula_id INT DEFAULT NULL,
    tag_id INT DEFAULT NULL,
    FOREIGN KEY("pelicula_id") REFERENCES "peliculas"("id"),
    FOREIGN KEY("tag_id") REFERENCES "tags"("id")
);

INSERT INTO PeliculasTags(
    pelicula_id,
    tag_id
    )
VALUES ( 1, 1 ),
       ( 1, 3 ),
       ( 1, 4 ),
       ( 2, 1 ),
       ( 2, 2 );

-- Cuenta la cantidad de tags que tiene cada película. Si una película no tiene tags debe mostrar 0.
SELECT p.nombre as Pelicula, COUNT(pt.pelicula_id) as numero_de_tags
FROM peliculas as p
LEFT JOIN PeliculasTags as pt
ON p.id = pt.pelicula_id
GROUP BY p.nombre ORDER BY numero_de_tags DESC;

-- *******************************************************************************************************************
-- *******************************************************************************************************************
CREATE TABLE Preguntas(
    id SERIAL,
    pregunta VARCHAR(255) DEFAULT NULL,
    respuesta_correcta VARCHAR DEFAULT NULL,
    PRIMARY KEY ("id")
);

CREATE TABLE Usuarios(
    id SERIAL,
    nombre VARCHAR(255) DEFAULT NULL,
    edad INT DEFAULT NULL,
    PRIMARY KEY ("id")
);

CREATE TABLE Respuestas(
    id SERIAL,
    respuesta  VARCHAR(255) DEFAULT NULL,
    usuario_id INT DEFAULT NULL,
    pregunta_id INT DEFAULT NULL,
    PRIMARY KEY ("id"),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(id),
    FOREIGN KEY (pregunta_id) REFERENCES Preguntas(id)
);

INSERT INTO Usuarios(
    nombre,
    edad
    )
VALUES ('Princesa', 18 ),
       ('Sirius Grey', 15 ),
       ('Jota 1' , 45 ),
       ('Burbuja', 18 ),
       ('Flor', 20 );

INSERT INTO Preguntas(
    pregunta,
    respuesta_correcta
    )
VALUES ('Que traduce 2teas2room222', 'Two Teas To Room Two Two Two' ),
       ('¿Cuanto es 6+2?', '8' ),
       ('¿Cuantos dias tiene un año?' , '365' ),
       ('Quien canta en la gloria de dios?', 'Evaluna con montaner' ),
       ('Cebolla perejil y ajo, que falta?', 'Tomate' );

INSERT INTO Respuestas(
    respuesta,
    usuario_id,
    pregunta_id
    )
VALUES ('Two Teas To Room Two Two Two', 1, 1 ),
       ('Two Teas To Room Two Two Two', 2, 1 ),
       ('8' , 3, 2 ),
       ('5', 4, 2 ),
       ('3', 1, 2 );

    --    Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta)

-- Entrega la cuenta de los usuarios en 0 cuando no tienen respuestas correctas
SELECT u.nombre, COALESCE(COUNT(respuestas.respuesta),0) as respuestas_correctas
FROM Usuarios as u
LEFT JOIN (
    SELECT r.usuario_id, r.respuesta
    FROM Respuestas as r
    INNER JOIN Preguntas p
    ON r.pregunta_id = p.id AND r.respuesta = p.respuesta_correcta
) AS respuestas ON u.id = respuestas.usuario_id
GROUP BY u.nombre ORDER BY respuestas_correctas DESC;
-- Entrega la cuenta solo de los usuarios con respuestas correctas
SELECT u.nombre, COUNT(r.respuesta) as respuestas_correctas
FROM Usuarios as u
LEFT JOIN Respuestas as r
ON r.usuario_id = u.id
INNER JOIN Preguntas p
ON r.pregunta_id = p.id AND r.respuesta = p.respuesta_correcta
GROUP BY u.nombre;

-- Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios tuvieron la respuesta correcta.
-- Usuarios con respuestas correctas no mas
SELECT p.pregunta, COUNT(u.id) as usuarios_con_respuestas_correctas
FROM Preguntas as p
LEFT JOIN Respuestas as r
ON p.id = r.pregunta_id
INNER JOIN Usuarios u
ON r.usuario_id = u.id AND r.respuesta = p.respuesta_correcta
GROUP BY p.pregunta;

-- cuenta de usuarios sin respuestas correctas en 0
SELECT p.pregunta, COALESCE(COUNT(usuarios.usuario_id),0) as usuarios_con_respuestas_correctas
FROM Preguntas as p
LEFT JOIN (
    SELECT r.usuario_id, r.respuesta
    FROM Respuestas as r
    INNER JOIN Usuarios u
    ON r.usuario_id = u.id AND  u.id = r.usuario_id
) AS usuarios ON usuarios.respuesta = p.respuesta_correcta
GROUP BY p.pregunta ORDER BY usuarios_con_respuestas_correctas DESC;

-- Implementa borrado en cascada de las respuestas al borrar un usuario y borrar el primer usuario para probar la implementación.
 ALTER TABLE Respuestas
 DROP CONSTRAINT respuestas_usuario_id_fkey,
 ADD CONSTRAINT respuestas_usuario_id_fkey
 FOREIGN KEY(usuario_id)
 REFERENCES Usuarios(id)
 ON DELETE CASCADE
 NOT VALID;

 DELETE FROM Usuarios WHERE id = 1;

--  Crea una restricción que impida insertar usuarios menores de 18 años en la base de datos.
ALTER TABLE Usuarios
ADD CONSTRAINT mayoriaDeEdad
CHECK ( edad >= 18);

INSERT INTO Usuarios(
    nombre,
    edad
    )
VALUES ('Fulanito', 18 );

INSERT INTO Usuarios(
    nombre,
    edad
    )
VALUES ('Perensejo', 15 );

-- Altera la tabla existente de usuarios agregando el campo email con la restricción de único.
ALTER TABLE Usuarios
ADD COLUMN email VARCHAR(500) UNIQUE;

UPDATE Usuarios
SET email = 'tomatito@gmail.com'
WHERE id = 3;

UPDATE Usuarios
SET email = 'cebollita@gmail.com'
WHERE id = 4;

UPDATE Usuarios
SET email = 'ajito@gmail.com'
WHERE id = 4;