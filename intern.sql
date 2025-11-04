-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: internship_portal
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
-- Table structure for table `applications`
--

DROP TABLE IF EXISTS `applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applications` (
  `ApplicationID` int NOT NULL AUTO_INCREMENT,
  `PRN` varchar(20) DEFAULT NULL,
  `InternshipID` int DEFAULT NULL,
  `Status` varchar(20) DEFAULT NULL,
  `AppliedOn` date DEFAULT NULL,
  PRIMARY KEY (`ApplicationID`),
  KEY `PRN` (`PRN`),
  KEY `InternshipID` (`InternshipID`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`PRN`) REFERENCES `students` (`PRN`),
  CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`InternshipID`) REFERENCES `internships` (`InternshipID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applications`
--

LOCK TABLES `applications` WRITE;
/*!40000 ALTER TABLE `applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `companies` (
  `CompanyID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) DEFAULT NULL,
  `Contact` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`CompanyID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,'Texas Instruments','hr@ti.com'),(2,'Intel','careers@intel.com'),(3,'Qualcomm','interns@qualcomm.com'),(4,'Cadence','careers@cadence.com'),(5,'Analog Devices','interns@analog.com'),(6,'Synopsys','jobs@synopsys.com'),(7,'Samsung R&D','samsung@rnd.com'),(8,'NVIDIA','nvidia@careers.com'),(9,'Broadcom','apply@broadcom.com'),(10,'Micron','hr@micron.com');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `faculty` (
  `FacultyID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Password` varchar(50) DEFAULT NULL,
  `Department` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`FacultyID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
INSERT INTO `faculty` VALUES (1,'Dr. Ramesh Iyer','ramesh@uni.edu','fac123','ECE'),(2,'Dr. Kavita Menon','kavita@uni.edu','fac456','Electronics'),(3,'Dr. Priyanka Rao','priyanka@uni.edu','fac789','Computer'),(4,'Dr. Anil Tiwari','anil@uni.edu','fac321','IT');
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `internships`
--

DROP TABLE IF EXISTS `internships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `internships` (
  `InternshipID` int NOT NULL AUTO_INCREMENT,
  `Domain` varchar(50) DEFAULT NULL,
  `MinCGPA` float DEFAULT NULL,
  `Department` varchar(50) DEFAULT NULL,
  `CompanyID` int DEFAULT NULL,
  `FacultyID` int DEFAULT NULL,
  `Description` text,
  `RecommendedScore` float DEFAULT '0',
  PRIMARY KEY (`InternshipID`),
  KEY `CompanyID` (`CompanyID`),
  KEY `FacultyID` (`FacultyID`),
  CONSTRAINT `internships_ibfk_1` FOREIGN KEY (`CompanyID`) REFERENCES `companies` (`CompanyID`),
  CONSTRAINT `internships_ibfk_2` FOREIGN KEY (`FacultyID`) REFERENCES `faculty` (`FacultyID`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `internships`
--

LOCK TABLES `internships` WRITE;
/*!40000 ALTER TABLE `internships` DISABLE KEYS */;
INSERT INTO `internships` VALUES (1,'Signal Processing',7.5,'ECE',1,1,'Work on real-time DSP algorithms and filtering at Texas Instruments.',0),(2,'Signal Processing',8,'ECE',3,1,'Assist in 5G module testing at Qualcomm.',0),(3,'Signal Processing',7.8,'ECE',5,1,'Design analog filters at Analog Devices.',0),(4,'VLSI',8,'Electronics',2,2,'Work on chip design using Verilog at Intel.',0),(5,'VLSI',8.3,'Electronics',4,2,'RTL verification and synthesis at Cadence.',0),(6,'VLSI',8.5,'Electronics',6,2,'Develop CAD automation scripts at Synopsys.',0),(7,'VLSI',8.7,'Electronics',8,2,'GPU architecture design at NVIDIA.',0),(8,'Signal Processing',8,'ECE',7,1,'Audio compression algorithms for embedded systems at Samsung R&D.',0),(9,'Signal Processing',7.9,'ECE',9,1,'Model communication signal flow in MATLAB at Broadcom.',0),(10,'VLSI',8.2,'Electronics',10,2,'Memory chip design and simulation at Micron.',0);
/*!40000 ALTER TABLE `internships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `PRN` varchar(20) NOT NULL,
  `Name` varchar(50) DEFAULT NULL,
  `Department` varchar(50) DEFAULT NULL,
  `CGPA` float DEFAULT NULL,
  `DomainPreference` varchar(50) DEFAULT NULL,
  `Password` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`PRN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('2023CS001','Sanyukta','ECE',8,'Signal Processing','sanyukta123'),('2023CS002','Sachi','Electronics',8.5,'VLSI','sachi123'),('2023CS003','Rohit Verma','Computer',8.2,'AI/ML','rohit123'),('2023EE001','Aisha Khan','Electrical',8.7,'Communication','aisha123'),('2023IT001','Nisha Jain','IT',7.8,'Data Analyst','nisha123');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-03 19:44:08
