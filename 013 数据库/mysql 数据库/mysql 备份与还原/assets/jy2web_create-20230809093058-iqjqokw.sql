create database jy2web default character set utf8mb4;
CREATE USER 'jy2web'@'%' IDENTIFIED BY 'Ninestar@123';
grant all privileges on jy2web.* to jy2web@'%';
flush privileges;

use jy2web;
DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `emp_no` int NOT NULL,
  `birth_date` date NOT NULL,
  `first_name` varchar(14) NOT NULL,
  `last_name` varchar(16) NOT NULL,
  `gender` enum('M','F') NOT NULL,
  `hire_date` date NOT NULL,
  PRIMARY KEY (`emp_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `employees` VALUES (001,'2000-09-02','sun','dongsheng','M','2089-06-26');
INSERT INTO `employees` VALUES (002,'1955-11-29','Behnaam','Zultner','F','1993-06-22');
INSERT INTO `employees` VALUES (003,'1962-01-06','JiYoung','Sherertz','M','1998-08-23');
INSERT INTO `employees` VALUES (004,'1961-04-13','Elzbieta','Bolsens','M','1994-12-27');
INSERT INTO `employees` VALUES (005,'1955-05-26','Toshimi','Laurillard','M','1995-07-27');
INSERT INTO `employees` VALUES (006,'1962-12-08','Takanari','Bugrara','M','1986-01-06');
INSERT INTO `employees` VALUES (007,'1960-03-24','Piyush','Leaver','F','1990-09-07');
INSERT INTO `employees` VALUES (008,'1954-12-29','Ranga','Hasenauer','M','1996-02-22');
INSERT INTO `employees` VALUES (009,'1954-12-16','Shakhar','Fontan','M','1989-08-08');
INSERT INTO `employees` VALUES (010,'1953-01-12','Moheb','Gewali','F','1995-07-20');
INSERT INTO `employees` VALUES (012,'1963-02-20','Shao','Cangellaris','F','1990-08-23');
INSERT INTO `employees` VALUES (013,'1954-08-07','Yongmao','Gewali','F','1985-10-22');

