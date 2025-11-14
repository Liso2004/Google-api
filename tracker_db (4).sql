CREATE DATABASE  IF NOT EXISTS `tracker_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `tracker_db`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: tracker_db
-- ------------------------------------------------------
-- Server version	8.0.43

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_auth`
--

DROP TABLE IF EXISTS `account_auth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_auth` (
  `auth_id` int unsigned NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `failed_login_attempts` int unsigned DEFAULT '0',
  `lock_until` datetime DEFAULT NULL,
  `reset_token_hash` varbinary(64) DEFAULT NULL,
  `reset_expires` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `backup_email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`auth_id`),
  UNIQUE KEY `auth_id_UNIQUE` (`auth_id`),
  KEY `FKAuth_idx` (`employee_id`),
  CONSTRAINT `FKAuth` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_auth`
--

LOCK TABLES `account_auth` WRITE;
/*!40000 ALTER TABLE `account_auth` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_auth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emp_classification`
--

DROP TABLE IF EXISTS `emp_classification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emp_classification` (
  `classification_id` int unsigned NOT NULL AUTO_INCREMENT,
  `department` varchar(50) NOT NULL,
  `position` varchar(50) NOT NULL,
  `role` enum('HR','Employee','Manager') DEFAULT 'Employee',
  `employment_type` enum('Full-time','Part-time','Contract','Intern') DEFAULT 'Full-time',
  `employee_level` enum('Junior','Mid','Senior','Lead','Manager','Executive') DEFAULT 'Junior',
  PRIMARY KEY (`classification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emp_classification`
--

LOCK TABLES `emp_classification` WRITE;
/*!40000 ALTER TABLE `emp_classification` DISABLE KEYS */;
INSERT INTO `emp_classification` VALUES (1,'Human Resources','HR Specialist','HR','Full-time','Mid'),(2,'IT','Software Developer','Employee','Full-time','Junior'),(3,'Finance','Accountant','Employee','Part-time','Mid'),(4,'IT','Team Lead','Manager','Full-time','Senior'),(5,'Marketing','Marketing Coordinator','Employee','Intern','Junior'),(6,'Operations','Operations Manager','Manager','Full-time','Manager'),(7,'IT','System Administrator','Employee','Contract','Mid'),(8,'Finance','Finance Director','Manager','Full-time','Executive'),(9,'Sales','Sales Representative','Employee','Full-time','Junior'),(10,'Customer Support','Support Agent','Employee','Part-time','Junior');
/*!40000 ALTER TABLE `emp_classification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` int unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `contact_no` varchar(10) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(255) NOT NULL,
  `id` varchar(13) NOT NULL,
  `is_admin` tinyint DEFAULT '0',
  `date_hired` date NOT NULL,
  `supervisor_name` varchar(100) DEFAULT NULL,
  `leave_balance` decimal(5,2) DEFAULT '0.00',
  `classification_id` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`employee_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `FKEmployee_idx` (`classification_id`),
  CONSTRAINT `FKEmployee` FOREIGN KEY (`classification_id`) REFERENCES `emp_classification` (`classification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'Sarah','Daniels','0821234567','sarah.daniels@example.com','12 Main Rd, Cape Town','8306123993068',1,'2020-01-15','N/A',12.50,8),(2,'Michael','Smith','0822345678','michael.smith@example.com','45 Loop St, Cape Town','12257873021',0,'2021-03-10','Sarah Daniels',8.00,9),(3,'Aisha','Khan','0823456789','aisha.khan@example.com','78 Long St, Cape Town','9202080806014',0,'2019-07-22','Sarah Daniels',5.50,6),(4,'David','Mokoena','0824567890','david.mokoena@example.com','101 Bree St, Cape Town','9511176099049',0,'2022-05-01','Michael Smith',10.00,5),(5,'Emily','Johnson','0825678901','emily.johnson@example.com','22 Kloof St, Cape Town','311220367024',0,'2018-11-11','Sarah Daniels',0.00,4),(6,'Thabo','Nkosi','0826789012','thabo.nkosi@example.com','33 Strand St, Cape Town','9604025460072',0,'2020-09-14','Michael Smith',7.25,3),(7,'Jessica','Williams','0827890123','jessica.williams@example.com','56 Adderley St, Cape Town','9104021410080',0,'2021-12-01','Sarah Daniels',9.75,7),(8,'Ahmed','Patel','0828901234','ahmed.patel@example.com','77 Buitengracht St, Cape Town','9908196611037',0,'2017-06-30','Sarah Daniels',0.00,8),(9,'Lerato','Dlamini','0829012345','lerato.dlamini@example.com','88 Harrington St, Cape Town','9901291123032',0,'2022-08-20','Michael Smith',4.00,2),(10,'Daniel','Brown','0820123456','daniel.brown@example.com','99 Roeland St, Cape Town','9411205676075',0,'2023-02-05','Jessica Williams',6.50,10);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hours_management`
--

DROP TABLE IF EXISTS `hours_management`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hours_management` (
  `hrs_id` int unsigned NOT NULL,
  `employee_id` int unsigned NOT NULL,
  `week_start` date NOT NULL,
  `week_end` date NOT NULL,
  `expected_hours` int unsigned NOT NULL DEFAULT '40',
  `total_worked_hours` int unsigned NOT NULL,
  `hours_owed` int unsigned NOT NULL DEFAULT '0',
  `overtime` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`hrs_id`),
  UNIQUE KEY `hrs_id_UNIQUE` (`hrs_id`),
  KEY `FKHrsManage_idx` (`employee_id`),
  CONSTRAINT `FKHrsManage` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hours_management`
--

LOCK TABLES `hours_management` WRITE;
/*!40000 ALTER TABLE `hours_management` DISABLE KEYS */;
INSERT INTO `hours_management` VALUES (1,1,'2025-10-27','2025-10-31',40,40,0,0),(2,2,'2025-10-27','2025-10-31',0,42,0,0),(3,3,'2025-10-27','2025-10-31',40,40,0,0),(4,4,'2025-10-27','2025-10-31',40,35,5,0),(5,5,'2025-10-27','2025-10-31',40,40,0,0),(6,6,'2025-10-27','2025-10-31',0,0,0,0),(7,7,'2025-10-27','2025-10-31',40,44,0,0),(8,8,'2025-10-27','2025-10-31',40,40,0,0),(9,9,'2025-10-27','2025-10-31',40,33,7,0),(10,10,'2025-10-27','2025-10-31',0,0,0,0);
/*!40000 ALTER TABLE `hours_management` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nfctag_storage`
--

DROP TABLE IF EXISTS `nfctag_storage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nfctag_storage` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tag_uid` varchar(64) NOT NULL,
  `employee_id` int unsigned NOT NULL,
  `owner_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `tag_uid_UNIQUE` (`tag_uid`),
  KEY `FKNFCTag_idx` (`employee_id`),
  CONSTRAINT `FKNFCTag` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nfctag_storage`
--

LOCK TABLES `nfctag_storage` WRITE;
/*!40000 ALTER TABLE `nfctag_storage` DISABLE KEYS */;
INSERT INTO `nfctag_storage` VALUES (1,'1553587972',1,'Sarah Daniels'),(2,'1554173188',2,'Michael Smith'),(3,'1552511236',3,'Aisha Khan'),(4,'1554564356',4,'David Mokoena');
/*!40000 ALTER TABLE `nfctag_storage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications_records`
--

DROP TABLE IF EXISTS `notifications_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications_records` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `title` varchar(45) NOT NULL,
  `message` varchar(255) NOT NULL,
  `date_created` date NOT NULL,
  `is_broadcast` tinyint NOT NULL DEFAULT '0',
  `is_read` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`notification_id`),
  UNIQUE KEY `notification_id_UNIQUE` (`notification_id`),
  KEY `FKNotification_idx` (`employee_id`),
  CONSTRAINT `FKNotification` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications_records`
--

LOCK TABLES `notifications_records` WRITE;
/*!40000 ALTER TABLE `notifications_records` DISABLE KEYS */;
INSERT INTO `notifications_records` VALUES (1,1,'Test','Lorem Ipsum','2025-10-28',0,0),(2,4,'Test2','Lorem Ipsum2','2025-10-28',0,0),(3,8,'Test3','Lorem Ipsum3','2025-10-28',0,0),(4,2,'Test4','Lorem Ipsum4','2025-01-11',0,0),(5,6,'Test5','Lorem Ipsum5','2024-05-05',0,0);
/*!40000 ALTER TABLE `notifications_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record_backups`
--

DROP TABLE IF EXISTS `record_backups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `record_backups` (
  `record_id` int NOT NULL AUTO_INCREMENT,
  `employee_id` int unsigned NOT NULL,
  `full_name` varchar(50) DEFAULT NULL,
  `clockin_time` time DEFAULT NULL,
  `clockout_time` time DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `record_id_UNIQUE` (`record_id`),
  KEY `FKRecord_Backups_idx` (`employee_id`),
  CONSTRAINT `FKRecord_Backups` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `record_backups`
--

LOCK TABLES `record_backups` WRITE;
/*!40000 ALTER TABLE `record_backups` DISABLE KEYS */;
INSERT INTO `record_backups` VALUES (1,1,'Sarah Daniels','08:30:00','16:05:00','2025-10-23'),(2,5,'Emily Johnson','08:45:00','17:00:00','2025-10-23'),(3,5,'Emily Johnson','10:30:00','11:00:00','2025-10-23'),(4,5,'Emily Johnson','13:00:00','14:00:00','2025-10-23'),(5,1,'Sarah Daniels','10:15:00','10:50:00','2025-10-23'),(6,1,'Sarah Daniels','13:20:00','14:00:00','2025-10-23'),(7,8,'Ahmed Patel','09:00:00','16:30:00','2025-10-23'),(8,8,'Ahmed Patel','10:30:00','10:50:00','2025-10-23'),(9,8,'Ahmed Patel','12:45:00','14:00:00','2025-10-23');
/*!40000 ALTER TABLE `record_backups` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-07 15:29:41
