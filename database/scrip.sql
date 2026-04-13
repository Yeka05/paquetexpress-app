CREATE DATABASE IF NOT EXISTS paquetexpress_db;
USE paquetexpress_db;

-- ======================
-- TABLA AGENTES
-- ======================
CREATE TABLE agentes (
    id_agente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(250) NOT NULL,
    telefono VARCHAR(20),
    activo TINYINT(1) DEFAULT 1,
    fecha_de_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- TABLA PAQUETES
-- ======================
CREATE TABLE paquetes (
    id_paquete INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    direccion VARCHAR(250) NOT NULL,
    ciudad VARCHAR(100),
    estado VARCHAR(100),
    codigo_postal VARCHAR(10),
    destinatario VARCHAR(100),
    telefono_destinatario VARCHAR(20),
    estatus ENUM('pendiente','en_camino','entregado') DEFAULT 'pendiente',
    fecha_de_alta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- TABLA ENTREGAS
-- ======================
CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_paquete INT NOT NULL,
    id_agente INT NOT NULL,
    fecha_de_entrega TIMESTAMP NULL,
    foto_url TEXT,
    latitud FLOAT,
    longitud FLOAT,
    estado ENUM('entregado','no_entregado') NOT NULL,
    comentario TEXT,

    FOREIGN KEY (id_paquete) REFERENCES paquetes(id_paquete),
    FOREIGN KEY (id_agente) REFERENCES agentes(id_agente)
);