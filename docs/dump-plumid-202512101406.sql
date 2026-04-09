DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `pictures`;
DROP TABLE IF EXISTS `feathers`;
DROP TABLE IF EXISTS `species`;

-- ======================
-- TABLE species
-- ======================
CREATE TABLE `species` (
  `idspecies` int(11) NOT NULL AUTO_INCREMENT,
  `region` varchar(45) DEFAULT NULL,
  `environment` varchar(45) DEFAULT NULL,
  `information` TEXT DEFAULT NULL,
  `species_name` varchar(100) DEFAULT NULL,
  `species_url_picture` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idspecies`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================
-- TABLE feathers
-- ======================
CREATE TABLE `feathers` (
  `idfeathers` int(11) NOT NULL AUTO_INCREMENT,
  `side` varchar(45) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL,
  `body_zone` varchar(45) DEFAULT NULL,
  `species_idspecies` int(11) DEFAULT NULL,
  PRIMARY KEY (`idfeathers`),
  KEY `idx_feathers_species` (`species_idspecies`),
  CONSTRAINT `fk_feathers_species`
    FOREIGN KEY (`species_idspecies`)
    REFERENCES `species` (`idspecies`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================
-- TABLE users
-- ======================
CREATE TABLE `users` (
  `idusers` int(11) NOT NULL AUTO_INCREMENT,
  `password_hash` varchar(100) NOT NULL,
  `role` varchar(45) DEFAULT NULL,
  `mail` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `username` varchar(100) DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `is_verified` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`idusers`),
  UNIQUE KEY `uniq_users_mail` (`mail`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================
-- TABLE pictures
-- ======================
CREATE TABLE `pictures` (
  `idpictures` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `longitude` varchar(45) DEFAULT NULL,
  `latitude` varchar(45) DEFAULT NULL,
  `date_collected` date DEFAULT NULL,
  `feathers_idfeathers` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`idpictures`),
  KEY `idx_pictures_feathers` (`feathers_idfeathers`),
  KEY `idx_pictures_user` (`user_id`),
  CONSTRAINT `fk_pictures_feathers`
    FOREIGN KEY (`feathers_idfeathers`)
    REFERENCES `feathers` (`idfeathers`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pictures_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`idusers`)
    ON DELETE SET NULL
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ======================
-- DATA
-- ======================

INSERT INTO `feathers` VALUES
(1,'test','test','test',522);

INSERT INTO `pictures` VALUES
(2,'on/est/là/hein', 2°20\'55.68\"E','48°51\'12.28\"N','2025-12-10',1,NULL);