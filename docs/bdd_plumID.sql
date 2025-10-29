-- Utiliser un jeu de caractères unicode moderne
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS bird_db CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE bird_db;

-- table species
CREATE TABLE species (
  idspecies INT NOT NULL AUTO_INCREMENT,
  sex VARCHAR(45),
  region VARCHAR(45),
  environment VARCHAR(45),
  information VARCHAR(255),
  species_name VARCHAR(100),
  PRIMARY KEY (idspecies)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- table feathers
CREATE TABLE feathers (
  idfeathers INT NOT NULL AUTO_INCREMENT,
  side VARCHAR(45),
  type VARCHAR(45),
  body_zone VARCHAR(45),
  species_idspecies INT,                    -- FK vers species
  PRIMARY KEY (idfeathers),
  INDEX idx_feathers_species (species_idspecies),
  CONSTRAINT fk_feathers_species
    FOREIGN KEY (species_idspecies)
    REFERENCES species (idspecies)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- table pictures
CREATE TABLE pictures (
  idpictures INT NOT NULL AUTO_INCREMENT,
  url VARCHAR(255),
  longitude VARCHAR(45),
  latitude VARCHAR(45),
  date_collected DATE,
  feathers_idfeathers INT,                  -- FK vers feathers
  PRIMARY KEY (idpictures),
  INDEX idx_pictures_feathers (feathers_idfeathers),
  CONSTRAINT fk_pictures_feathers
    FOREIGN KEY (feathers_idfeathers)
    REFERENCES feathers (idfeathers)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- table users
-- IMPORTANT: ne stocke jamais le mot de passe en clair. stocke le hash (bcrypt/argon2)
CREATE TABLE users (
  idusers INT NOT NULL AUTO_INCREMENT,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(45),
  mail VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  username VARCHAR(100),
  pictures_idpictures INT,                  -- FK vers pictures (ex: avatar / photo)
  PRIMARY KEY (idusers),
  UNIQUE KEY uniq_users_mail (mail),
  INDEX idx_users_pictures (pictures_idpictures),
  CONSTRAINT fk_users_pictures
    FOREIGN KEY (pictures_idpictures)
    REFERENCES pictures (idpictures)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
