/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: plumid
-- ------------------------------------------------------
-- Server version	10.6.5-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `feathers`
--

DROP TABLE IF EXISTS `feathers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `feathers` (
  `idfeathers` int(11) NOT NULL AUTO_INCREMENT,
  `side` varchar(45) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL,
  `body_zone` varchar(45) DEFAULT NULL,
  `species_idspecies` int(11) DEFAULT NULL,
  PRIMARY KEY (`idfeathers`),
  KEY `idx_feathers_species` (`species_idspecies`),
  CONSTRAINT `fk_feathers_species` FOREIGN KEY (`species_idspecies`) REFERENCES `species` (`idspecies`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feathers`
--

LOCK TABLES `feathers` WRITE;
/*!40000 ALTER TABLE `feathers` DISABLE KEYS */;
INSERT INTO `feathers` VALUES
(1,'test','test','test',522);
/*!40000 ALTER TABLE `feathers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pictures`
--

DROP TABLE IF EXISTS `pictures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pictures` (
  `idpictures` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) DEFAULT NULL,
  `longitude` varchar(45) DEFAULT NULL,
  `latitude` varchar(45) DEFAULT NULL,
  `date_collected` date DEFAULT NULL,
  `feathers_idfeathers` int(11) DEFAULT NULL,
  PRIMARY KEY (`idpictures`),
  KEY `idx_pictures_feathers` (`feathers_idfeathers`),
  CONSTRAINT `fk_pictures_feathers` FOREIGN KEY (`feathers_idfeathers`) REFERENCES `feathers` (`idfeathers`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pictures`
--

LOCK TABLES `pictures` WRITE;
/*!40000 ALTER TABLE `pictures` DISABLE KEYS */;
INSERT INTO `pictures` VALUES
(2,'on/est/là/hein','2°20\'55.68\"E','48°51\'12.28\"N','2025-12-10',1);
/*!40000 ALTER TABLE `pictures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `species`
--

DROP TABLE IF EXISTS `species`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `species` (
  `idspecies` int(11) NOT NULL AUTO_INCREMENT,
  `sex` char(1) DEFAULT NULL,
  `region` varchar(45) DEFAULT NULL,
  `environment` varchar(45) DEFAULT NULL,
  `information` varchar(255) DEFAULT NULL,
  `species_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idspecies`)
) ENGINE=InnoDB AUTO_INCREMENT=6972 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `species`
--

LOCK TABLES `species` WRITE;
/*!40000 ALTER TABLE `species` DISABLE KEYS */;
INSERT INTO `species` VALUES
(522,'F','prout','fabian','lpb','furye'),
(6969,'M','Toulouse','la rue tu connais','TPMP','Anass'),
(6970,'M','Occitanie','env2','toto','moi'),
(6971,'M','Occitanie','env2','toto','moi');
/*!40000 ALTER TABLE `species` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `idusers` int(11) NOT NULL AUTO_INCREMENT,
  `password_hash` varchar(100) NOT NULL,
  `role` varchar(45) DEFAULT NULL,
  `mail` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `username` varchar(100) DEFAULT NULL,
  `pictures_idpictures` int(11) DEFAULT NULL,
  `is_active` tinyint(4) DEFAULT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `is_verified` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`idusers`),
  UNIQUE KEY `uniq_users_mail` (`mail`),
  KEY `idx_users_pictures` (`pictures_idpictures`),
  CONSTRAINT `fk_users_pictures` FOREIGN KEY (`pictures_idpictures`) REFERENCES `pictures` (`idpictures`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'plumid'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2025-12-10 14:06:56
