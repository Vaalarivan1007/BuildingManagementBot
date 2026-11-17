/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `activealarms` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `correlationtype` int(11) DEFAULT NULL,
  `correlatedrecordids` text,
  `repeatcount` bigint(20) DEFAULT NULL,
  `firstoccurancetime` bigint(20) DEFAULT '0',
  `lastoccurancetime` bigint(20) DEFAULT '0',
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `assignedseverity` int(11) DEFAULT NULL,
  `ticketedusername` varchar(50) DEFAULT NULL,
  `ticketmessage` varchar(80) DEFAULT NULL,
  `clearedmessage` varchar(80) DEFAULT NULL,
  `clearedtime` bigint(20) DEFAULT '0',
  `alarmtypeid` bigint(20) DEFAULT NULL,
  `specificevent` int(11) DEFAULT NULL,
  PRIMARY KEY (`recordid`),
  KEY `neid` (`neid`),
  KEY `agentid` (`agentid`),
  KEY `alarmtypeid` (`alarmtypeid`),
  CONSTRAINT `activealarms_ibfk_1` FOREIGN KEY (`neid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `activealarms_ibfk_2` FOREIGN KEY (`agentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `activealarms_ibfk_3` FOREIGN KEY (`alarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `advertisementconfigurationdetails` (
  `advconfdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `advconfdetadvid` bigint(20) DEFAULT NULL,
  `advconffiletype` int(11) DEFAULT NULL,
  `advconffilename` varchar(250) DEFAULT NULL,
  `advconfduration` int(11) DEFAULT NULL,
  `advconfdetcreatedtime` bigint(20) DEFAULT '0',
  `advconfdetmodifiedtime` bigint(20) DEFAULT '0',
  `advconfdetcreatedby` varchar(50) DEFAULT NULL,
  `advconfdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`advconfdetrecid`),
  KEY `advconfdetadvid` (`advconfdetadvid`),
  CONSTRAINT `advertisementconfigurationdetails_ibfk_1` FOREIGN KEY (`advconfdetadvid`) REFERENCES `advertisementdetails` (`advdetrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `advertisementdetails` (
  `advdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `advdetname` varchar(250) DEFAULT NULL,
  `advdetstationid` varchar(50) DEFAULT NULL,
  `advdetplatformid` varchar(50) DEFAULT NULL,
  `advdetpikid` varchar(50) DEFAULT NULL,
  `advdetslot` varchar(250) DEFAULT NULL,
  `advdetfromtime` bigint(20) DEFAULT '0',
  `advdettotime` bigint(20) DEFAULT '0',
  `advdetapprvstatus` tinyint(4) DEFAULT NULL,
  `advdetdesc` text,
  `advdetadminsts` tinyint(4) DEFAULT NULL,
  `advdetmqttstatus` tinyint(4) DEFAULT NULL,
  `advdetcreatedtime` bigint(20) DEFAULT '0',
  `advdetmodifiedtime` bigint(20) DEFAULT '0',
  `advdetcreatedby` varchar(50) DEFAULT NULL,
  `advdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`advdetrecid`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `advertisementpikdetails` (
  `advpikdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `advpikdetadvid` bigint(20) DEFAULT NULL,
  `advpikdetpikid` bigint(20) DEFAULT NULL,
  `advpikdetcreatedtime` bigint(20) DEFAULT '0',
  `advpikdetcreatedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`advpikdetrecid`),
  KEY `advpikdetadvid` (`advpikdetadvid`),
  CONSTRAINT `advertisementpikdetails_ibfk_1` FOREIGN KEY (`advpikdetadvid`) REFERENCES `advertisementdetails` (`advdetrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `agentdetails` (
  `agentid` bigint(20) NOT NULL,
  `agentneid` bigint(20) DEFAULT NULL,
  `agentip` varchar(253) DEFAULT NULL,
  `agentport` int(11) DEFAULT NULL,
  `agentuserid` varchar(250) DEFAULT NULL,
  `agentmobilenumber` varchar(15) DEFAULT NULL,
  `agentminconnections` int(11) DEFAULT '1',
  `agentmaxconnections` int(11) DEFAULT '5',
  `agentversion` int(11) DEFAULT NULL,
  `agentreadcommunity` varchar(255) DEFAULT NULL,
  `agentwritecommunity` varchar(255) DEFAULT NULL,
  `agentretries` int(11) DEFAULT '3',
  `agenttimeout` int(11) DEFAULT '30',
  `agentalarminterval` int(11) DEFAULT '30',
  `agenturl` varchar(255) DEFAULT NULL,
  `agentcommtype` varchar(100) DEFAULT NULL,
  `agentlatitude` double DEFAULT '0',
  `agentlongitude` double DEFAULT '0',
  `agentcreationtime` bigint(20) DEFAULT '0',
  `agentmodifiedtime` bigint(20) DEFAULT '0',
  `agentcreatedby` varchar(50) DEFAULT NULL,
  `agentmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`agentid`),
  UNIQUE KEY `agentip` (`agentip`,`agentport`,`agenturl`,`agentcommtype`,`agentlatitude`,`agentlongitude`),
  KEY `agentneid` (`agentneid`),
  CONSTRAINT `agentdetails_ibfk_1` FOREIGN KEY (`agentneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmdetails` (
  `alarmid` bigint(20) NOT NULL,
  `alarmnesubtypeid` int(11) DEFAULT NULL,
  `alarmnesubtypealarmid` bigint(20) DEFAULT '-1',
  `alarmgrpid` int(11) DEFAULT NULL,
  `alarmmoc` varchar(128) DEFAULT NULL,
  `alarmclassname` varchar(128) DEFAULT NULL,
  `alarmeventtype` int(11) DEFAULT NULL,
  `alarmprobablecause` int(11) DEFAULT NULL,
  `alarmspecificproblem` int(11) DEFAULT NULL,
  `alarmperceivedseverity` int(11) DEFAULT NULL,
  `alarmassignedseverity` int(11) DEFAULT NULL,
  `alarmspecificevent` int(11) DEFAULT NULL,
  `alarmadditionaltext` varchar(80) DEFAULT NULL,
  `alarmadditionalattributes` text,
  `alarmdescription` text,
  `alarmmanualclear` int(11) DEFAULT '0',
  PRIMARY KEY (`alarmid`),
  KEY `alarmnesubtypeid` (`alarmnesubtypeid`),
  KEY `alarmgrpid` (`alarmgrpid`),
  KEY `alarmeventtype` (`alarmeventtype`),
  KEY `alarmprobablecause` (`alarmprobablecause`),
  KEY `alarmspecificproblem` (`alarmspecificproblem`),
  CONSTRAINT `alarmdetails_ibfk_1` FOREIGN KEY (`alarmnesubtypeid`) REFERENCES `nesubtypedetails` (`nesubtypeid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmdetails_ibfk_2` FOREIGN KEY (`alarmgrpid`) REFERENCES `alarmgroupdetails` (`alarmgrpid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmdetails_ibfk_3` FOREIGN KEY (`alarmeventtype`) REFERENCES `eventtypes` (`eventtypeid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmdetails_ibfk_4` FOREIGN KEY (`alarmprobablecause`) REFERENCES `probablecauses` (`probablecauseid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmdetails_ibfk_5` FOREIGN KEY (`alarmspecificproblem`) REFERENCES `specificproblems` (`specificproblemid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmemailconfig` (
  `alrmemailcfgid` int(11) NOT NULL,
  `alrmemailcfgname` varchar(56) DEFAULT NULL,
  `alrmemailcfgsubject` text,
  `alrmemailcfgbody` text,
  `alrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `alrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `alrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `alrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`alrmemailcfgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmgroupdetails` (
  `alarmgrpid` int(11) NOT NULL,
  `alarmgrpname` varchar(100) DEFAULT NULL,
  `alarmgrpdesc` varchar(255) DEFAULT NULL,
  `alarmgrpassignedseverity` int(11) DEFAULT NULL,
  `alarmgrpmanualclear` int(11) DEFAULT NULL,
  PRIMARY KEY (`alarmgrpid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmhistory` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `correlationtype` int(11) DEFAULT NULL,
  `correlatedrecordids` text,
  `repeatcount` bigint(20) DEFAULT NULL,
  `firstoccurancetime` bigint(20) DEFAULT '0',
  `lastoccurancetime` bigint(20) DEFAULT '0',
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `assignedseverity` int(11) DEFAULT NULL,
  `ticketedusername` varchar(50) DEFAULT NULL,
  `ticketmessage` varchar(80) DEFAULT NULL,
  `clearedmessage` varchar(80) DEFAULT NULL,
  `clearedtime` bigint(20) DEFAULT '0',
  `alarmtypeid` bigint(20) DEFAULT NULL,
  `specificevent` int(11) DEFAULT NULL,
  `nename` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`recordid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmlookup` (
  `alarmlookupid` bigint(20) NOT NULL AUTO_INCREMENT,
  `alarmlookupsrcalarmtypeid` bigint(20) DEFAULT NULL,
  `alarmlookupaction` varchar(100) DEFAULT NULL,
  `alarmlookuptargetalarmtypeid` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`alarmlookupid`),
  KEY `alarmlookupsrcalarmtypeid` (`alarmlookupsrcalarmtypeid`),
  KEY `alarmlookuptargetalarmtypeid` (`alarmlookuptargetalarmtypeid`),
  CONSTRAINT `alarmlookup_ibfk_1` FOREIGN KEY (`alarmlookupsrcalarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmlookup_ibfk_2` FOREIGN KEY (`alarmlookuptargetalarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=209 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmsmsconfig` (
  `alrmsmscfgid` int(11) NOT NULL,
  `alrmsmscfgname` varchar(56) DEFAULT NULL,
  `alrmsmscfgmessage` text,
  `alrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `alrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `alrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `alrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`alrmsmscfgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmtypedetails` (
  `alarmtypeid` bigint(20) NOT NULL,
  `alarmtypeneversionnumber` varchar(25) NOT NULL,
  `alarmtypealarmid` bigint(20) DEFAULT NULL,
  `alarmtypemanualclear` int(11) DEFAULT '0',
  `alarmtypeassignedseverity` int(11) DEFAULT '0',
  `alarmtypeadditionaltext` varchar(506) NOT NULL,
  `alarmtypeadminstate` int(11) DEFAULT '1',
  PRIMARY KEY (`alarmtypeid`),
  KEY `alarmtypealarmid` (`alarmtypealarmid`),
  KEY `alarmtypeneversionnumber` (`alarmtypeneversionnumber`),
  CONSTRAINT `alarmtypedetails_ibfk_1` FOREIGN KEY (`alarmtypealarmid`) REFERENCES `alarmdetails` (`alarmid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alarmtypedetails_ibfk_2` FOREIGN KEY (`alarmtypeneversionnumber`) REFERENCES `neversiondetails` (`neversionnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `alarmuserdetails` (
  `alarmuserdetlid` bigint(20) NOT NULL,
  `alarmuserdetlusername` varchar(100) DEFAULT NULL,
  `alarmuserdetlemailaddress` varchar(255) DEFAULT NULL,
  `alarmuserdetlmobilenumber` varchar(15) DEFAULT NULL,
  `alarmuserdetladminstate` int(11) DEFAULT NULL,
  `alarmuserdetlcreationtime` bigint(20) DEFAULT '0',
  `alarmuserdetlmodifiedtime` bigint(20) DEFAULT '0',
  `alarmuserdetlcreatedby` varchar(50) DEFAULT NULL,
  `alarmuserdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`alarmuserdetlid`),
  UNIQUE KEY `alarmuserdetlusername` (`alarmuserdetlusername`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `deletealarmuserassociation` AFTER DELETE ON `alarmuserdetails` FOR EACH ROW BEGIN
	SET @olduserid = OLD.alarmuserdetlid;
	SET @replaceuserid = CONCAT(",", OLD.alarmuserdetlid, ",");
	IF EXISTS (SELECT * FROM nesubtypealarmemailconfig WHERE FIND_IN_SET(@olduserid, nesubtypealrmemailcfgcriticalemails) OR FIND_IN_SET(@olduserid, nesubtypealrmemailcfgmajoremails) OR FIND_IN_SET(@olduserid, nesubtypealrmemailcfgminoremails) OR FIND_IN_SET(@olduserid, nesubtypealrmemailcfgwarningemails)) THEN
		UPDATE nesubtypealarmemailconfig SET nesubtypealrmemailcfgcriticalemails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmemailcfgcriticalemails, ','), @replaceuserid, ','))), nesubtypealrmemailcfgmajoremails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmemailcfgmajoremails, ','), @replaceuserid, ','))), nesubtypealrmemailcfgminoremails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmemailcfgminoremails, ','), @replaceuserid, ','))), nesubtypealrmemailcfgwarningemails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmemailcfgwarningemails, ','), @replaceuserid, ',')));
	END IF;
	
	IF EXISTS (SELECT * FROM groupalarmemailconfig WHERE FIND_IN_SET(@olduserid, grpalrmemailcfgcriticalemails) OR FIND_IN_SET(@olduserid, grpalrmemailcfgmajoremails) OR FIND_IN_SET(@olduserid, grpalrmemailcfgminoremails) OR FIND_IN_SET(@olduserid, grpalrmemailcfgwarningemails)) THEN
		UPDATE groupalarmemailconfig SET grpalrmemailcfgcriticalemails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmemailcfgcriticalemails, ','), @replaceuserid, ','))), grpalrmemailcfgmajoremails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmemailcfgmajoremails, ','), @replaceuserid, ','))), grpalrmemailcfgminoremails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmemailcfgminoremails, ','), @replaceuserid, ','))), grpalrmemailcfgwarningemails = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmemailcfgwarningemails, ','), @replaceuserid, ',')));
	END IF;
	
	IF EXISTS (SELECT * FROM nealarmemailconfig WHERE FIND_IN_SET(@olduserid, nealrmemailcfgcriticalemails) OR FIND_IN_SET(@olduserid, nealrmemailcfgmajoremails) OR FIND_IN_SET(@olduserid, nealrmemailcfgminoremails) OR FIND_IN_SET(@olduserid, nealrmemailcfgwarningemails)) THEN
		UPDATE nealarmemailconfig SET nealrmemailcfgcriticalemails=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmemailcfgcriticalemails, ','), @replaceuserid, ','))), nealrmemailcfgmajoremails=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmemailcfgmajoremails, ','), @replaceuserid, ','))), nealrmemailcfgminoremails=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmemailcfgminoremails, ','), @replaceuserid, ','))), nealrmemailcfgwarningemails=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmemailcfgwarningemails, ','), @replaceuserid, ',')));
	END IF;
	
	IF EXISTS (SELECT * FROM nesubtypealarmsmsconfig WHERE FIND_IN_SET(@olduserid, nesubtypealrmsmscfgcriticalnumbers) OR FIND_IN_SET(@olduserid, nesubtypealrmsmscfgmajornumbers) OR FIND_IN_SET(@olduserid, nesubtypealrmsmscfgminornumbers) OR FIND_IN_SET(@olduserid, nesubtypealrmsmscfgwarningnumbers)) THEN
		UPDATE nesubtypealarmsmsconfig SET nesubtypealrmsmscfgcriticalnumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmsmscfgcriticalnumbers, ','), @replaceuserid, ','))), nesubtypealrmsmscfgmajornumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmsmscfgmajornumbers, ','), @replaceuserid, ','))), nesubtypealrmsmscfgminornumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmsmscfgminornumbers, ','), @replaceuserid, ','))), nesubtypealrmsmscfgwarningnumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nesubtypealrmsmscfgwarningnumbers, ','), @replaceuserid, ',')));
	END IF;
	
	IF EXISTS (SELECT * FROM groupalarmsmsconfig WHERE FIND_IN_SET(@olduserid, grpalrmsmscfgcriticalnumbers) OR FIND_IN_SET(@olduserid, grpalrmsmscfgmajornumbers) OR FIND_IN_SET(@olduserid, grpalrmsmscfgminornumbers) OR FIND_IN_SET(@olduserid, grpalrmsmscfgwarningnumbers)) THEN
		UPDATE groupalarmsmsconfig SET grpalrmsmscfgcriticalnumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmsmscfgcriticalnumbers, ','), @replaceuserid, ','))), grpalrmsmscfgmajornumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmsmscfgmajornumbers, ','), @replaceuserid, ','))), grpalrmsmscfgminornumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmsmscfgminornumbers, ','), @replaceuserid, ','))), grpalrmsmscfgwarningnumbers = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', grpalrmsmscfgwarningnumbers, ','), @replaceuserid, ',')));
	END IF;
	
	IF EXISTS (SELECT * FROM nealarmsmsconfig WHERE FIND_IN_SET(@olduserid, nealrmsmscfgcriticalnumbers) OR FIND_IN_SET(@olduserid, nealrmsmscfgmajornumbers) OR FIND_IN_SET(@olduserid, nealrmsmscfgminornumbers) OR FIND_IN_SET(@olduserid, nealrmsmscfgwarningnumbers)) THEN
		UPDATE nealarmsmsconfig SET nealrmsmscfgcriticalnumbers=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmsmscfgcriticalnumbers, ','), @replaceuserid, ','))), nealrmsmscfgmajornumbers=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmsmscfgmajornumbers, ','), @replaceuserid, ','))), nealrmsmscfgminornumbers=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmsmscfgminornumbers, ','), @replaceuserid, ','))), nealrmsmscfgwarningnumbers=TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', nealrmsmscfgwarningnumbers, ','), @replaceuserid, ',')));
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `appsinprofiles` (
  `appsinprofprfid` int(11) NOT NULL,
  `appsinprofappid` int(11) NOT NULL,
  `appsinprofreadaccess` int(11) DEFAULT NULL,
  `appsinprofwriteaccess` int(11) DEFAULT NULL,
  `appsinprofcreationtime` bigint(20) DEFAULT '0',
  `appsinprofmodifiedtime` bigint(20) DEFAULT '0',
  `appsinprofcreatedby` varchar(50) DEFAULT NULL,
  `appsinprofmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`appsinprofprfid`,`appsinprofappid`),
  KEY `appsinprofappid` (`appsinprofappid`),
  CONSTRAINT `appsinprofiles_ibfk_1` FOREIGN KEY (`appsinprofprfid`) REFERENCES `profiledetails` (`profileid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `appsinprofiles_ibfk_2` FOREIGN KEY (`appsinprofappid`) REFERENCES `neapplicationmanager` (`neappmgrid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auditlogs` (
  `auditlogid` int(11) NOT NULL AUTO_INCREMENT,
  `auditlogusername` varchar(50) DEFAULT NULL,
  `auditlogtimestamp` bigint(20) DEFAULT '0',
  `auditlogmoduleid` varchar(7) DEFAULT NULL,
  `audithigherlevelobjname` varchar(50) DEFAULT NULL,
  `audithigherlevelobjinstanceid` varchar(50) DEFAULT NULL,
  `auditlogmanagedobjectclass` varchar(200) DEFAULT NULL,
  `auditlogmoduleinstanceid` varchar(250) DEFAULT NULL,
  `auditlogoperationtype` int(11) DEFAULT NULL,
  `auditlogoperationid` int(11) DEFAULT NULL,
  `auditlogmessage` text,
  `auditlognename` varchar(50) DEFAULT NULL,
  `auditlogoperationparams` text,
  `auditlogoperationoldparams` text,
  `auditlogoperationstatus` int(11) DEFAULT NULL,
  `auditlogoperationstatusstr` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`auditlogid`),
  KEY `auditlogtimestamp` (`auditlogtimestamp`),
  KEY `auditlogmoduleid` (`auditlogmoduleid`),
  KEY `auditlogoperationid` (`auditlogoperationid`),
  CONSTRAINT `auditlogs_ibfk_1` FOREIGN KEY (`auditlogmoduleid`) REFERENCES `auditmoduletypes` (`auditmoduleid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `auditlogs_ibfk_2` FOREIGN KEY (`auditlogoperationid`) REFERENCES `auditmoduleoperations` (`auditoprnid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5837 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auditmoduleoperations` (
  `auditoprnid` int(11) NOT NULL AUTO_INCREMENT,
  `auditoprnname` varchar(50) DEFAULT NULL,
  `auditoprndesc` varchar(200) DEFAULT NULL,
  `auditoprnhelpurl` varchar(250) DEFAULT NULL,
  `auditoprnlogenabled` int(11) DEFAULT NULL,
  `auditoprndefhigherlevelobjname` varchar(50) DEFAULT NULL,
  `auditoprndefhigherlevelobjinstance` varchar(50) DEFAULT NULL,
  `auditoprndefaultmanagedobjectclass` varchar(200) DEFAULT NULL,
  `auditoprndefaultmanagedobjectinstance` varchar(50) DEFAULT NULL,
  `auditoprnmoduleid` varchar(7) DEFAULT NULL,
  `auditoprnoperationtype` int(11) DEFAULT NULL,
  PRIMARY KEY (`auditoprnid`),
  KEY `auditoprnmoduleid` (`auditoprnmoduleid`),
  CONSTRAINT `auditmoduleoperations_ibfk_1` FOREIGN KEY (`auditoprnmoduleid`) REFERENCES `auditmoduletypes` (`auditmoduleid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=951 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `auditmoduletypes` (
  `auditmoduleid` varchar(7) NOT NULL,
  `auditmodulestr` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`auditmoduleid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `avlsserverspolldetails` (
  `avlsserverpdrecid` int(11) NOT NULL AUTO_INCREMENT,
  `avlsserverpdneid` bigint(20) DEFAULT NULL,
  `avlsserverpdagentid` bigint(20) DEFAULT NULL,
  `avlsserverpdcpuusage` bigint(20) DEFAULT NULL,
  `avlsserverpdmemoryusage` bigint(20) DEFAULT NULL,
  `avlsserverpddiskusage` bigint(20) DEFAULT NULL,
  `avlsserverpddpiconnection` bigint(20) DEFAULT NULL,
  `avlsserverpdtspsconnection` bigint(20) DEFAULT NULL,
  `avlsserverpdpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`avlsserverpdrecid`),
  UNIQUE KEY `avlsserverpdneid` (`avlsserverpdneid`,`avlsserverpdagentid`,`avlsserverpdpolledtimestamp`),
  KEY `avlsserverpdagentid` (`avlsserverpdagentid`),
  CONSTRAINT `avlsserverspolldetails_ibfk_1` FOREIGN KEY (`avlsserverpdneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `avlsserverspolldetails_ibfk_2` FOREIGN KEY (`avlsserverpdagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1505331 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buildingalarmconfig` (
  `buldalrmcfgid` int(11) NOT NULL,
  `buldalrmcfgbuildingid` bigint(20) DEFAULT NULL,
  `buldalrmcfgemail` int(11) DEFAULT '0',
  `buldalrmcfgsms` int(11) DEFAULT '0',
  `buldalrmcfgtrap` int(11) DEFAULT '0',
  `buldalrmcfgcreationtime` bigint(20) DEFAULT '0',
  `buldalrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `buldalrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `buldalrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`buldalrmcfgid`),
  UNIQUE KEY `buldalrmcfgbuildingid` (`buldalrmcfgbuildingid`),
  CONSTRAINT `buildingalarmconfig_ibfk_1` FOREIGN KEY (`buldalrmcfgbuildingid`) REFERENCES `buildingdetails` (`buldid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buildingalarmemailconfig` (
  `buldalrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `buldalrmemailcfgalarmid` int(11) DEFAULT NULL,
  `buldalrmemailcfgcritical` int(11) DEFAULT '0',
  `buldalrmemailcfgcriticalemails` text,
  `buldalrmemailcfgmajor` int(11) DEFAULT '0',
  `buldalrmemailcfgmajoremails` text,
  `buldalrmemailcfgminor` int(11) DEFAULT '0',
  `buldalrmemailcfgminoremails` text,
  `buldalrmemailcfgwarning` int(11) DEFAULT '0',
  `buldalrmemailcfgwarningemails` text,
  `buldalrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `buldalrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `buldalrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `buldalrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`buldalrmemailcfgid`),
  UNIQUE KEY `buldalrmemailcfgalarmid` (`buldalrmemailcfgalarmid`),
  CONSTRAINT `buildingalarmemailconfig_ibfk_1` FOREIGN KEY (`buldalrmemailcfgalarmid`) REFERENCES `buildingalarmconfig` (`buldalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buildingalarmsmsconfig` (
  `buldalrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `buldalrmsmscfgalarmid` int(11) DEFAULT NULL,
  `buldalrmsmscfgcritical` int(11) DEFAULT '0',
  `buldalrmsmscfgcriticalnumbers` text,
  `buldalrmsmscfgmajor` int(11) DEFAULT '0',
  `buldalrmsmscfgmajornumbers` text,
  `buldalrmsmscfgminor` int(11) DEFAULT '0',
  `buldalrmsmscfgminornumbers` text,
  `buldalrmsmscfgwarning` int(11) DEFAULT '0',
  `buldalrmsmscfgwarningnumbers` text,
  `buldalrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `buldalrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `buldalrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `buldalrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`buldalrmsmscfgid`),
  UNIQUE KEY `buldalrmsmscfgalarmid` (`buldalrmsmscfgalarmid`),
  CONSTRAINT `buildingalarmsmsconfig_ibfk_1` FOREIGN KEY (`buldalrmsmscfgalarmid`) REFERENCES `buildingalarmconfig` (`buldalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buildingdetails` (
  `buldid` bigint(20) NOT NULL,
  `buldname` varchar(30) NOT NULL,
  `buldshortname` varchar(20) NOT NULL,
  `buldaddress1` varchar(100) DEFAULT NULL,
  `buldaddress2` varchar(100) DEFAULT NULL,
  `buldneighbourhood` varchar(50) DEFAULT NULL,
  `buldcity` varchar(50) DEFAULT NULL,
  `buldstate` varchar(50) DEFAULT NULL,
  `buldcountry` varchar(50) DEFAULT NULL,
  `buldpincode` varchar(10) DEFAULT NULL,
  `buldpersonname` varchar(100) DEFAULT NULL,
  `buldmobilenumber` varchar(15) DEFAULT NULL,
  `buldphonenumber` varchar(15) DEFAULT NULL,
  `buldemail` varchar(255) DEFAULT NULL,
  `buldlat` double DEFAULT NULL,
  `buldlong` double DEFAULT NULL,
  `bulddesc` text,
  `buldbasements` int(11) DEFAULT NULL,
  `buldfloors` int(11) DEFAULT NULL,
  `buldgroupid` bigint(20) DEFAULT NULL,
  `buldcreationtime` bigint(20) DEFAULT '0',
  `buldmodifiedtime` bigint(20) DEFAULT '0',
  `buldcreatedby` varchar(50) DEFAULT NULL,
  `buldmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`buldid`),
  UNIQUE KEY `buldname` (`buldname`),
  UNIQUE KEY `buldshortname` (`buldshortname`),
  KEY `buldgroupid` (`buldgroupid`),
  CONSTRAINT `buildingdetails_ibfk_1` FOREIGN KEY (`buldgroupid`) REFERENCES `groupdetails` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `insertfloordetailsafterinsertbuilding` AFTER INSERT ON `buildingdetails` FOR EACH ROW BEGIN
	SET @i = 1;
	SET @id = NEW.buldid;
	SET @personname = NEW.buldpersonname;
	SET @mnumber = NEW.buldmobilenumber;
	SET @pnumber = NEW.buldphonenumber;
	SET @email = NEW.buldemail;
	SET @description = NEW.bulddesc;
	SET @noofbasements = NEW.buldbasements;
	SET @nooffloors = NEW.buldfloors;
	SET @creationtime = NEW.buldcreationtime;
	SET @createdby = NEW.buldcreatedby;
	WHILE @i <= @noofbasements 
	DO
		SET @floorname = CONCAT('Basement-', @i);
		INSERT INTO floordetails(floorname, floorshortname, floorpersonname, floormobilenumber, floorphonenumber, flooremail, floordesc, floorbuldid, floorcreationtime, floorcreatedby) VALUES(@floorname, @floorname, @personname, @mnumber, @pnumber, @email, @description, @id, @creationtime, @createdby);
		SET @i = @i + 1;
	END WHILE;
	SET @i = 0;
	WHILE @i <= @nooffloors
	DO
		IF (@i = 0) THEN
			SET @floorname = 'Ground Floor';
		ELSE IF (@i = @nooffloors) THEN
			SET @floorname = 'Terrace';
		ELSE
			SET @floorname = CONCAT("Floor-", @i);
		END IF;
		END IF;
		INSERT INTO floordetails(floorname, floorshortname, floorpersonname, floormobilenumber, floorphonenumber, flooremail, floordesc, floorbuldid, floorcreationtime, floorcreatedby) VALUES(@floorname, @floorname, @personname, @mnumber, @pnumber, @email, @description, @id, @creationtime, @createdby);
		SET @i = @i + 1;
	END WHILE;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `buildinglayoutdetails` (
  `buildinglayoutdetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `buildinglayoutdetlbuldid` bigint(20) DEFAULT NULL,
  `buildinglayoutdetlfileurl` varchar(512) DEFAULT NULL,
  `buildinglayoutdetllayoutsize` varchar(50) DEFAULT NULL,
  `buildinglayoutdetladminstate` int(11) DEFAULT NULL,
  `buildinglayoutdetlcreationtime` bigint(20) DEFAULT '0',
  `buildinglayoutdetlmodifiedtime` bigint(20) DEFAULT '0',
  `buildinglayoutdetlcreatedby` varchar(50) DEFAULT NULL,
  `buildinglayoutdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`buildinglayoutdetlrecordid`),
  UNIQUE KEY `buildinglayoutdetlfileurl` (`buildinglayoutdetlfileurl`),
  KEY `buildinglayoutdetlbuldid` (`buildinglayoutdetlbuldid`),
  CONSTRAINT `buildinglayoutdetails_ibfk_1` FOREIGN KEY (`buildinglayoutdetlbuldid`) REFERENCES `buildingdetails` (`buldid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cctvassociation` (
  `cctvassid` bigint(20) NOT NULL,
  `cctvassneid` bigint(20) DEFAULT NULL,
  `cctvassagentid` bigint(20) DEFAULT NULL,
  `cctvassused` int(11) DEFAULT NULL,
  `cctvassconnectedneid` bigint(20) DEFAULT NULL,
  `cctvassadminstate` int(11) DEFAULT NULL,
  `cctvasscreationtime` bigint(20) DEFAULT '0',
  `cctvassmodifiedtime` bigint(20) DEFAULT '0',
  `cctvasscreatedby` varchar(50) DEFAULT NULL,
  `cctvassmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cctvassid`),
  KEY `cctvassneid` (`cctvassneid`),
  KEY `cctvassagentid` (`cctvassagentid`),
  KEY `cctvassconnectedneid` (`cctvassconnectedneid`),
  CONSTRAINT `cctvassociation_ibfk_1` FOREIGN KEY (`cctvassneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cctvassociation_ibfk_2` FOREIGN KEY (`cctvassagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cctvassociation_ibfk_3` FOREIGN KEY (`cctvassconnectedneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cctvreadings` (
  `cctvrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `cctvneid` bigint(20) DEFAULT NULL,
  `cctvdisktotal` varchar(25) DEFAULT NULL,
  `cctvdiskused` varchar(25) DEFAULT NULL,
  `cctvlogtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`cctvrecdid`),
  KEY `cctvneid` (`cctvneid`),
  CONSTRAINT `cctvreadings_ibfk_1` FOREIGN KEY (`cctvneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cctvserverreadings` (
  `cctvserverrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `cctvserverneid` bigint(20) DEFAULT NULL,
  `cctvserverdisktotal` varchar(25) DEFAULT NULL,
  `cctvserverdiskused` double DEFAULT NULL,
  `cctvservercpuutil` double DEFAULT NULL,
  `cctvservermemoryutil` double DEFAULT NULL,
  `cctvserverbandwidth` varchar(25) DEFAULT NULL,
  `cctvserverlogtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`cctvserverrecdid`),
  KEY `cctvserverneid` (`cctvserverneid`),
  CONSTRAINT `cctvserverreadings_ibfk_1` FOREIGN KEY (`cctvserverneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `clearedalarms` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `correlationtype` int(11) DEFAULT NULL,
  `correlatedrecordids` text,
  `repeatcount` bigint(20) DEFAULT NULL,
  `firstoccurancetime` bigint(20) DEFAULT '0',
  `lastoccurancetime` bigint(20) DEFAULT '0',
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `assignedseverity` int(11) DEFAULT NULL,
  `ticketedusername` varchar(50) DEFAULT NULL,
  `ticketmessage` varchar(80) DEFAULT NULL,
  `clearedmessage` varchar(80) DEFAULT NULL,
  `clearedtime` bigint(20) DEFAULT '0',
  `alarmtypeid` bigint(20) DEFAULT NULL,
  `specificevent` int(11) DEFAULT NULL,
  PRIMARY KEY (`recordid`),
  KEY `neid` (`neid`),
  KEY `agentid` (`agentid`),
  KEY `alarmtypeid` (`alarmtypeid`),
  KEY `loggingtime` (`loggingtime`),
  CONSTRAINT `clearedalarms_ibfk_1` FOREIGN KEY (`neid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clearedalarms_ibfk_2` FOREIGN KEY (`agentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clearedalarms_ibfk_3` FOREIGN KEY (`alarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `clearedalarmspurged` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `correlationtype` int(11) DEFAULT NULL,
  `correlatedrecordids` text,
  `repeatcount` bigint(20) DEFAULT NULL,
  `firstoccurancetime` bigint(20) DEFAULT '0',
  `lastoccurancetime` bigint(20) DEFAULT '0',
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `assignedseverity` int(11) DEFAULT NULL,
  `ticketedusername` varchar(50) DEFAULT NULL,
  `ticketmessage` varchar(80) DEFAULT NULL,
  `clearedmessage` varchar(80) DEFAULT NULL,
  `clearedtime` bigint(20) DEFAULT '0',
  `alarmtypeid` bigint(20) DEFAULT NULL,
  `specificevent` int(11) DEFAULT NULL,
  PRIMARY KEY (`recordid`),
  KEY `neid` (`neid`),
  KEY `agentid` (`agentid`),
  KEY `alarmtypeid` (`alarmtypeid`),
  CONSTRAINT `clearedalarmspurged_ibfk_1` FOREIGN KEY (`neid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clearedalarmspurged_ibfk_2` FOREIGN KEY (`agentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clearedalarmspurged_ibfk_3` FOREIGN KEY (`alarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `debugalarms` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `alarmtypeid` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`recordid`),
  KEY `neid` (`neid`),
  KEY `agentid` (`agentid`),
  CONSTRAINT `debugalarms_ibfk_1` FOREIGN KEY (`neid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `debugalarms_ibfk_2` FOREIGN KEY (`agentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `definedincidentdetails` (
  `definedincidentdetlrecdid` bigint(20) NOT NULL,
  `definedincidentdetlsubsystem` varchar(50) DEFAULT NULL,
  `definedincidentdetleventname` varchar(100) DEFAULT NULL,
  `definedincidentdetlpriority` int(11) DEFAULT NULL,
  `definedincidentdetltype` int(11) DEFAULT NULL COMMENT '1 - System, 2 - Custom',
  `definedincidentdetladminstate` int(11) DEFAULT '1' COMMENT '0 - Disabled,\n1 - Enabled',
  `definedincidentdetlday` set('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','All') DEFAULT NULL,
  `definedincidentdetlfromtime` varchar(50) DEFAULT NULL,
  `definedincidentdetltotime` varchar(50) DEFAULT NULL,
  `definedincidentdetllocation` enum('Station','Building','Junction','NA','All') DEFAULT NULL,
  `definedincidentdetlassociatedid` varchar(500) DEFAULT NULL,
  `definedincidentdetldesc` text,
  `definedincidentdetlcreationtime` bigint(20) DEFAULT '0',
  `definedincidentdetlmodifiedtime` bigint(20) DEFAULT '0',
  `definedincidentdetlcreatedby` varchar(50) DEFAULT NULL,
  `definedincidentdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`definedincidentdetlrecdid`),
  UNIQUE KEY `definedincidentdetlsubsystem_2` (`definedincidentdetlsubsystem`,`definedincidentdetleventname`,`definedincidentdetlday`,`definedincidentdetlfromtime`,`definedincidentdetltotime`,`definedincidentdetllocation`,`definedincidentdetlassociatedid`),
  KEY `definedincidentdetlsubsystem` (`definedincidentdetlsubsystem`,`definedincidentdetleventname`,`definedincidentdetlpriority`,`definedincidentdetltype`,`definedincidentdetlday`,`definedincidentdetlfromtime`,`definedincidentdetltotime`,`definedincidentdetllocation`,`definedincidentdetlassociatedid`,`definedincidentdetlcreationtime`,`definedincidentdetlmodifiedtime`),
  KEY `definedincidentdetlpriority` (`definedincidentdetlpriority`),
  CONSTRAINT `definedincidentdetails_ibfk_1` FOREIGN KEY (`definedincidentdetlpriority`) REFERENCES `incidentprioritydetails` (`incidentprioritydetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `definedresolutiondetails` (
  `definedresdetlrecdid` bigint(20) NOT NULL,
  `definedresdetlincidentid` bigint(20) DEFAULT NULL,
  `definedresdetlincidentmsg` text,
  `definedresdetlseqno` float DEFAULT NULL,
  `definedresdetltype` int(11) DEFAULT NULL COMMENT '0 - Optional, 1 - Mandatory',
  `definedresdetlcreationtime` bigint(20) DEFAULT '0',
  `definedresdetlmodifiedtime` bigint(20) DEFAULT '0',
  `definedresdetlcreatedby` varchar(50) DEFAULT NULL,
  `definedresdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`definedresdetlrecdid`),
  UNIQUE KEY `definedresdetlincidentid_2` (`definedresdetlincidentid`,`definedresdetlseqno`),
  KEY `definedresdetlincidentid` (`definedresdetlincidentid`,`definedresdetlseqno`,`definedresdetltype`,`definedresdetlcreationtime`,`definedresdetlmodifiedtime`),
  CONSTRAINT `definedresolutiondetails_ibfk_1` FOREIGN KEY (`definedresdetlincidentid`) REFERENCES `definedincidentdetails` (`definedincidentdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `downtimehistory` (
  `recordId` bigint(20) NOT NULL AUTO_INCREMENT,
  `msgDate` date NOT NULL,
  `msgHour` tinyint(4) NOT NULL,
  `neId` bigint(20) NOT NULL,
  `downTimeMins` bigint(20) NOT NULL,
  `createdTime` datetime NOT NULL,
  `remark` text,
  PRIMARY KEY (`recordId`),
  UNIQUE KEY `neId` (`msgDate`,`msgHour`,`neId`),
  KEY `neId_2` (`neId`,`msgDate`,`msgHour`),
  CONSTRAINT `downTimeHistory_ibfk_1` FOREIGN KEY (`neId`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `dwrmoduleoperations` (
  `dwroprnid` int(11) NOT NULL AUTO_INCREMENT,
  `dwroprnname` varchar(50) DEFAULT NULL,
  `dwroprndesc` varchar(200) DEFAULT NULL,
  `dwroprnhelpurl` varchar(250) DEFAULT NULL,
  `dwroprnlogenabled` int(11) DEFAULT NULL,
  `dwroprnclass` varchar(500) DEFAULT NULL,
  `dwroprninstance` varchar(250) DEFAULT NULL,
  `dwroprnmethod` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`dwroprnid`)
) ENGINE=InnoDB AUTO_INCREMENT=804 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emailcfg` (
  `emailcfgid` int(11) NOT NULL,
  `emailcfgserver` varchar(253) DEFAULT NULL,
  `emailcfgserverport` int(11) DEFAULT NULL,
  `emailcfgauthreqd` int(11) DEFAULT NULL,
  `emailcfgauthusername` varchar(253) DEFAULT NULL,
  `emailcfgauthpassword` text,
  `emailcfgauthsecuritymethod` int(11) DEFAULT NULL,
  `emailcfgdefaultfromaddress` varchar(254) DEFAULT NULL,
  `emailcfgadminstate` int(11) DEFAULT '0',
  `emailcfgcreationtime` bigint(20) DEFAULT '0',
  `emailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `emailcfgcreatedby` varchar(50) DEFAULT NULL,
  `emailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`emailcfgid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emailsent` (
  `emailsentid` int(11) NOT NULL AUTO_INCREMENT,
  `emailsentfromaddress` varchar(254) DEFAULT NULL,
  `emailsenttoaddress` text,
  `emailsentccaddress` text,
  `emailsentbccaddress` text,
  `emailsentreplyto` text,
  `emailsentsubject` text,
  `emailsentmessage` text,
  `emailsentusername` varchar(500) DEFAULT NULL,
  `emailsentsendtime` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`emailsentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emergencycontact` (
  `emgcntrecid` int(11) NOT NULL,
  `emgcntstationid` bigint(20) DEFAULT NULL,
  `emgcnttype` int(11) DEFAULT NULL,
  `emgcntfilename` varchar(250) DEFAULT NULL,
  `emgcntadminstatus` int(11) DEFAULT NULL,
  `emgcntcreatedtime` bigint(20) DEFAULT '0',
  `emgcntcreatedby` varchar(50) DEFAULT NULL,
  `emgcntmodifiedtime` bigint(20) DEFAULT '0',
  `emgcntmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`emgcntrecid`),
  KEY `emgcntstationid` (`emgcntstationid`),
  CONSTRAINT `emergencycontact_ibfk_1` FOREIGN KEY (`emgcntstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emergencymessages` (
  `emrgncymsgrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `emrgncymsgmessages` varchar(255) DEFAULT NULL,
  `emrgncymsgpriority` tinyint(4) DEFAULT NULL,
  `emrgncymsgdescription` varchar(255) DEFAULT NULL,
  `emrgncymsgcreatedtime` bigint(20) DEFAULT '0',
  `emrgncymsgcreatedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`emrgncymsgrecid`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emergencyrequestmessages` (
  `emrgncyreqmsgrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `emrgncyreqmsgpikid` varchar(50) DEFAULT NULL,
  `emrgncyreqmsgstationid` varchar(50) DEFAULT NULL,
  `emrgncyreqmsgplatformid` varchar(50) DEFAULT NULL,
  `emrgncyreqmsgemrgncymsgid` bigint(20) DEFAULT NULL,
  `emrgncyreqmsgtag` bigint(20) DEFAULT NULL,
  `emrgncyreqmsgstatus` int(11) DEFAULT NULL,
  `emrgncyreqmsgscheduledat` bigint(20) DEFAULT NULL,
  `emrgncyreqmsgreason` bigint(20) DEFAULT NULL,
  `emrgncyreqmsgstarttime` datetime DEFAULT NULL,
  `emrgncyreqmsgendtime` datetime DEFAULT NULL,
  `emrgncyreqmsgtype` int(11) DEFAULT NULL,
  `emrgncyreqmsgemrgncymessages` varchar(250) DEFAULT NULL,
  `emrgncyreqmsgcreatedtime` bigint(20) DEFAULT '0',
  `emrgncyreqmsgmodifiedtime` bigint(20) DEFAULT '0',
  `emrgncyreqmsgcreatedby` varchar(50) DEFAULT NULL,
  `emrgncyreqmsgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`emrgncyreqmsgrecid`),
  KEY `emrgncyreqmsgemrgncymsgid` (`emrgncyreqmsgemrgncymsgid`),
  KEY `emrgncyreqmsgtag` (`emrgncyreqmsgtag`),
  CONSTRAINT `emergencyrequestmessages_ibfk_1` FOREIGN KEY (`emrgncyreqmsgemrgncymsgid`) REFERENCES `emergencymessages` (`emrgncymsgrecid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `emergencyrequestmessages_ibfk_2` FOREIGN KEY (`emrgncyreqmsgtag`) REFERENCES `joboperationdetails` (`jobopdtlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `emergenycontact` (
  `emgcntrecid` int(11) NOT NULL,
  `emgcnttype` int(11) DEFAULT NULL,
  `emgcntpikid` bigint(20) DEFAULT NULL,
  `emgcntname` varchar(250) DEFAULT NULL,
  `emgcntmobile` varchar(20) DEFAULT NULL,
  `emgcntadminstatus` int(11) DEFAULT NULL,
  `emgcntcreatedtime` bigint(20) DEFAULT '0',
  `emgcntcreatedby` varchar(50) DEFAULT NULL,
  `emgcntmodifiedtime` bigint(20) DEFAULT '0',
  `emgcntmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`emgcntrecid`),
  KEY `emgcntpikid_ibfk_1` (`emgcntpikid`),
  CONSTRAINT `emgcntpikid_ibfk_1` FOREIGN KEY (`emgcntpikid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `eventtypes` (
  `eventtypeid` int(11) NOT NULL AUTO_INCREMENT,
  `eventtypename` text,
  `eventtypedesc` text,
  PRIMARY KEY (`eventtypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `exportmoduleoperations` (
  `expoprnid` int(11) NOT NULL AUTO_INCREMENT,
  `expoprnname` varchar(50) DEFAULT NULL,
  `expoprndesc` varchar(200) DEFAULT NULL,
  `expoprnhelpurl` varchar(250) DEFAULT NULL,
  `expoprnlogenabled` int(11) DEFAULT NULL,
  `expoprnclass` varchar(500) DEFAULT NULL,
  `expoprninstance` varchar(250) DEFAULT NULL,
  `expoprnmethod` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`expoprnid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `feedbackdetails` (
  `feedbackrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `feedbackdettype` int(11) DEFAULT NULL,
  `feedbackfrommailid` varchar(250) NOT NULL,
  `feedbacktomailid` varchar(250) NOT NULL,
  `feedbacksubject` varchar(250) NOT NULL,
  `feedbackbody` text NOT NULL,
  `feedbackcreationtime` bigint(20) DEFAULT '0',
  `feedbackmodifiedtime` bigint(20) DEFAULT '0',
  `feedbackcreatedby` varchar(50) DEFAULT NULL,
  `feedbackmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`feedbackrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `findingdetails` (
  `findingdetlrecid` bigint(20) NOT NULL,
  `findingdetlname` varchar(100) NOT NULL,
  `findingdetlcreationtime` bigint(20) DEFAULT '0',
  `findingdetlmodifiedtime` bigint(20) DEFAULT '0',
  `findingdetlcreatedby` varchar(100) DEFAULT NULL,
  `findingdetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`findingdetlrecid`),
  UNIQUE KEY `findingdetlname` (`findingdetlname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `flooralarmconfig` (
  `flooralrmcfgid` int(11) NOT NULL,
  `flooralrmcfgfloorid` bigint(20) DEFAULT NULL,
  `flooralrmcfgemail` int(11) DEFAULT '0',
  `flooralrmcfgsms` int(11) DEFAULT '0',
  `flooralrmcfgtrap` int(11) DEFAULT '0',
  `flooralrmcfgcreationtime` bigint(20) DEFAULT '0',
  `flooralrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `flooralrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `flooralrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`flooralrmcfgid`),
  UNIQUE KEY `flooralrmcfgfloorid` (`flooralrmcfgfloorid`),
  CONSTRAINT `flooralarmconfig_ibfk_1` FOREIGN KEY (`flooralrmcfgfloorid`) REFERENCES `floordetails` (`floorid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `flooralarmemailconfig` (
  `flooralrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `flooralrmemailcfgalarmid` int(11) DEFAULT NULL,
  `flooralrmemailcfgcritical` int(11) DEFAULT '0',
  `flooralrmemailcfgcriticalemails` text,
  `flooralrmemailcfgmajor` int(11) DEFAULT '0',
  `flooralrmemailcfgmajoremails` text,
  `flooralrmemailcfgminor` int(11) DEFAULT '0',
  `flooralrmemailcfgminoremails` text,
  `flooralrmemailcfgwarning` int(11) DEFAULT '0',
  `flooralrmemailcfgwarningemails` text,
  `flooralrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `flooralrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `flooralrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `flooralrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`flooralrmemailcfgid`),
  UNIQUE KEY `flooralrmemailcfgalarmid` (`flooralrmemailcfgalarmid`),
  CONSTRAINT `flooralarmemailconfig_ibfk_1` FOREIGN KEY (`flooralrmemailcfgalarmid`) REFERENCES `flooralarmconfig` (`flooralrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `flooralarmsmsconfig` (
  `flooralrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `flooralrmsmscfgalarmid` int(11) DEFAULT NULL,
  `flooralrmsmscfgcritical` int(11) DEFAULT '0',
  `flooralrmsmscfgcriticalnumbers` text,
  `flooralrmsmscfgmajor` int(11) DEFAULT '0',
  `flooralrmsmscfgmajornumbers` text,
  `flooralrmsmscfgminor` int(11) DEFAULT '0',
  `flooralrmsmscfgminornumbers` text,
  `flooralrmsmscfgwarning` int(11) DEFAULT '0',
  `flooralrmsmscfgwarningnumbers` text,
  `flooralrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `flooralrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `flooralrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `flooralrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`flooralrmsmscfgid`),
  UNIQUE KEY `flooralrmsmscfgalarmid` (`flooralrmsmscfgalarmid`),
  CONSTRAINT `flooralarmsmsconfig_ibfk_1` FOREIGN KEY (`flooralrmsmscfgalarmid`) REFERENCES `flooralarmconfig` (`flooralrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `floordetails` (
  `floorid` bigint(20) NOT NULL AUTO_INCREMENT,
  `floorname` varchar(30) NOT NULL,
  `floorshortname` varchar(20) NOT NULL,
  `floorpersonname` varchar(100) DEFAULT NULL,
  `floormobilenumber` varchar(15) DEFAULT NULL,
  `floorphonenumber` varchar(15) DEFAULT NULL,
  `flooremail` varchar(255) DEFAULT NULL,
  `floordesc` text,
  `floorbuldid` bigint(20) DEFAULT NULL,
  `floorcreationtime` bigint(20) DEFAULT '0',
  `floormodifiedtime` bigint(20) DEFAULT '0',
  `floorcreatedby` varchar(50) DEFAULT NULL,
  `floormodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`floorid`),
  UNIQUE KEY `floorbuldid` (`floorbuldid`,`floorname`,`floorshortname`),
  CONSTRAINT `floordetails_ibfk_1` FOREIGN KEY (`floorbuldid`) REFERENCES `buildingdetails` (`buldid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `floorlayoutdetails` (
  `floorlayoutdetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `floorlayoutdetlfloorid` bigint(20) DEFAULT NULL,
  `floorlayoutdetlfileurl` varchar(512) DEFAULT NULL,
  `floorlayoutdetllayoutsize` varchar(50) DEFAULT NULL,
  `floorlayoutdetladminstate` int(11) DEFAULT NULL,
  `floorlayoutdetlcreationtime` bigint(20) DEFAULT '0',
  `floorlayoutdetlmodifiedtime` bigint(20) DEFAULT '0',
  `floorlayoutdetlcreatedby` varchar(50) DEFAULT NULL,
  `floorlayoutdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`floorlayoutdetlrecordid`),
  UNIQUE KEY `floorlayoutdetlfileurl` (`floorlayoutdetlfileurl`),
  KEY `floorlayoutdetlfloorid` (`floorlayoutdetlfloorid`),
  CONSTRAINT `floorlayoutdetails_ibfk_1` FOREIGN KEY (`floorlayoutdetlfloorid`) REFERENCES `floordetails` (`floorid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `fracasdetails` (
  `fracasdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `fracasdetleventime` varchar(512) DEFAULT NULL,
  `fracasdetldesc` text,
  `fracasdetllocid` bigint(20) DEFAULT NULL,
  `fracasdetlsecid` bigint(20) DEFAULT NULL,
  `fracasdetlfinding` text,
  `fracasdetlriskid` bigint(20) DEFAULT NULL,
  `fracasdetlstatus` int(11) DEFAULT NULL,
  `fracasdetlcreationtime` bigint(20) DEFAULT '0',
  `fracasdetlmodifiedtime` bigint(20) DEFAULT '0',
  `fracasdetldetlcreatedby` varchar(100) DEFAULT NULL,
  `fracasdetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fracasdetlrecdid`),
  KEY `fracasdetllocid` (`fracasdetllocid`),
  KEY `fracasdetlsecid` (`fracasdetlsecid`),
  KEY `fracasdetlriskid` (`fracasdetlriskid`),
  CONSTRAINT `fracasdetails_ibfk_1` FOREIGN KEY (`fracasdetllocid`) REFERENCES `locationdetails` (`locationdetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fracasdetails_ibfk_2` FOREIGN KEY (`fracasdetlsecid`) REFERENCES `sectiondetails` (`sectiondetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fracasdetails_ibfk_3` FOREIGN KEY (`fracasdetlriskid`) REFERENCES `riskdetails` (`riskdetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `onafteraddfracasdetails` AFTER INSERT ON `fracasdetails` FOR EACH ROW BEGIN
     SET @status = NEW.fracasdetlstatus;
     SET @fracasrecid = NEW.fracasdetlrecdid;
     IF @status = 0 THEN
		INSERT INTO fracashistorydetails(fracasdetlrecdid, fracasdetleventime, fracasdetldesc, fracasdetllocid, fracasdetlsecid, fracasdetlfinding, fracasdetlriskid, fracasdetlstatus, fracasdetlcreationtime, fracasdetlmodifiedtime, fracasdetldetlcreatedby, fracasdetlmodifiedby) SELECT * FROM fracasdetails WHERE fracasdetlrecdid = @fracasrecid;
		INSERT INTO fracashistoryfiledetails(fracashstryfiledetlrecid, fracashstryfiledetlfracashstryid, fracashstryfileurl, fracashstryfiledetlcreationtime, fracashstryfiledetlcreatedby) SELECT * FROM fracasfiledetails WHERE fracasfiledetlfracasid = @fracasrecid;
		DELETE FROM fracasfiledetails WHERE fracasfiledetlfracasid = @fracasrecid;
     END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `onafterupdatefracasdetails` AFTER UPDATE ON `fracasdetails` FOR EACH ROW BEGIN
     SET @status = NEW.fracasdetlstatus;
     SET @fracasrecid = NEW.fracasdetlrecdid;
     IF @status = 0 THEN
		INSERT INTO fracashistorydetails(fracasdetlrecdid, fracasdetleventime, fracasdetldesc, fracasdetllocid, fracasdetlsecid, fracasdetlfinding, fracasdetlriskid, fracasdetlstatus, fracasdetlcreationtime, fracasdetlmodifiedtime, fracasdetldetlcreatedby, fracasdetlmodifiedby) SELECT * FROM fracasdetails WHERE fracasdetlrecdid = @fracasrecid;
		INSERT INTO fracashistoryfiledetails(fracashstryfiledetlrecid, fracashstryfiledetlfracashstryid, fracashstryfileurl, fracashstryfiledetlcreationtime, fracashstryfiledetlcreatedby) SELECT * FROM fracasfiledetails WHERE fracasfiledetlfracasid = @fracasrecid;
		DELETE FROM fracasfiledetails WHERE fracasfiledetlfracasid = @fracasrecid;
     END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `fracasfiledetails` (
  `fracasfiledetlrecid` bigint(20) NOT NULL,
  `fracasfiledetlfracasid` bigint(20) DEFAULT NULL,
  `fracasfiledetlurl` varchar(512) DEFAULT NULL,
  `fracasfiledetlcreationtime` bigint(20) DEFAULT '0',
  `fracasfiledetlcreatedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`fracasfiledetlrecid`),
  UNIQUE KEY `fracasfiledetlurl` (`fracasfiledetlurl`),
  KEY `fracasfiledetlfracasid` (`fracasfiledetlfracasid`),
  CONSTRAINT `fracasfiledetails_ibfk_1` FOREIGN KEY (`fracasfiledetlfracasid`) REFERENCES `fracasdetails` (`fracasdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `fracashistorydetails` (
  `fracasdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `fracasdetleventime` varchar(512) DEFAULT NULL,
  `fracasdetldesc` text,
  `fracasdetllocid` bigint(20) DEFAULT NULL,
  `fracasdetlsecid` bigint(20) DEFAULT NULL,
  `fracasdetlfinding` text,
  `fracasdetlriskid` bigint(20) DEFAULT NULL,
  `fracasdetlstatus` int(11) DEFAULT NULL,
  `fracasdetlcreationtime` bigint(20) DEFAULT '0',
  `fracasdetlmodifiedtime` bigint(20) DEFAULT '0',
  `fracasdetldetlcreatedby` varchar(100) DEFAULT NULL,
  `fracasdetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fracasdetlrecdid`),
  KEY `fracasdetllocid` (`fracasdetllocid`),
  KEY `fracasdetlsecid` (`fracasdetlsecid`),
  KEY `fracasdetlriskid` (`fracasdetlriskid`),
  CONSTRAINT `fracashistorydetails_ibfk_1` FOREIGN KEY (`fracasdetllocid`) REFERENCES `locationdetails` (`locationdetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fracashistorydetails_ibfk_2` FOREIGN KEY (`fracasdetlsecid`) REFERENCES `sectiondetails` (`sectiondetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fracashistorydetails_ibfk_3` FOREIGN KEY (`fracasdetlriskid`) REFERENCES `riskdetails` (`riskdetlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `fracashistoryfiledetails` (
  `fracashstryfiledetlrecid` bigint(20) NOT NULL,
  `fracashstryfiledetlfracashstryid` bigint(20) DEFAULT NULL,
  `fracashstryfileurl` varchar(512) DEFAULT NULL,
  `fracashstryfiledetlcreationtime` bigint(20) DEFAULT '0',
  `fracashstryfiledetlcreatedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`fracashstryfiledetlrecid`),
  UNIQUE KEY `fracashstryfileurl` (`fracashstryfileurl`),
  KEY `fracashstryfiledetlfracashstryid` (`fracashstryfiledetlfracashstryid`),
  CONSTRAINT `fracashistoryfiledetails_ibfk_1` FOREIGN KEY (`fracashstryfiledetlfracashstryid`) REFERENCES `fracashistorydetails` (`fracasdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `generalhtmldetails` (
  `generalhtmdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `generalhtmdetfilename` varchar(250) DEFAULT NULL,
  `generalhtmdettype` bigint(20) DEFAULT NULL,
  `generalhtmdetlangtype` int(11) DEFAULT '1',
  `generalhtmdetadminsts` tinyint(4) DEFAULT NULL,
  `generalhtmdetcreatedtime` bigint(20) DEFAULT '0',
  `generalhtmdetmodifiedtime` bigint(20) DEFAULT '0',
  `generalhtmdetcreatedby` varchar(50) DEFAULT NULL,
  `generalhtmdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`generalhtmdetrecid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `groupalarmconfig` (
  `grpalrmcfgid` int(11) NOT NULL,
  `grpalrmcfggroupid` bigint(20) DEFAULT NULL,
  `grpalrmcfgemail` int(11) DEFAULT '0',
  `grpalrmcfgsms` int(11) DEFAULT '0',
  `grpalrmcfgtrap` int(11) DEFAULT '0',
  `grpalrmcfgcreationtime` bigint(20) DEFAULT '0',
  `grpalrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `grpalrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `grpalrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`grpalrmcfgid`),
  UNIQUE KEY `grpalrmcfggroupid` (`grpalrmcfggroupid`),
  CONSTRAINT `groupalarmconfig_ibfk_1` FOREIGN KEY (`grpalrmcfggroupid`) REFERENCES `groupdetails` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `groupalarmemailconfig` (
  `grpalrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `grpalrmemailcfgalarmid` int(11) DEFAULT NULL,
  `grpalrmemailcfgcritical` int(11) DEFAULT '0',
  `grpalrmemailcfgcriticalemails` text,
  `grpalrmemailcfgmajor` int(11) DEFAULT '0',
  `grpalrmemailcfgmajoremails` text,
  `grpalrmemailcfgminor` int(11) DEFAULT '0',
  `grpalrmemailcfgminoremails` text,
  `grpalrmemailcfgwarning` int(11) DEFAULT '0',
  `grpalrmemailcfgwarningemails` text,
  `grpalrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `grpalrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `grpalrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `grpalrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`grpalrmemailcfgid`),
  UNIQUE KEY `grpalrmemailcfgalarmid` (`grpalrmemailcfgalarmid`),
  CONSTRAINT `groupalarmemailconfig_ibfk_1` FOREIGN KEY (`grpalrmemailcfgalarmid`) REFERENCES `groupalarmconfig` (`grpalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `groupalarmsmsconfig` (
  `grpalrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `grpalrmsmscfgalarmid` int(11) DEFAULT NULL,
  `grpalrmsmscfgcritical` int(11) DEFAULT '0',
  `grpalrmsmscfgcriticalnumbers` text,
  `grpalrmsmscfgmajor` int(11) DEFAULT '0',
  `grpalrmsmscfgmajornumbers` text,
  `grpalrmsmscfgminor` int(11) DEFAULT '0',
  `grpalrmsmscfgminornumbers` text,
  `grpalrmsmscfgwarning` int(11) DEFAULT '0',
  `grpalrmsmscfgwarningnumbers` text,
  `grpalrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `grpalrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `grpalrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `grpalrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`grpalrmsmscfgid`),
  UNIQUE KEY `grpalrmsmscfgalarmid` (`grpalrmsmscfgalarmid`),
  CONSTRAINT `groupalarmsmsconfig_ibfk_1` FOREIGN KEY (`grpalrmsmscfgalarmid`) REFERENCES `groupalarmconfig` (`grpalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `groupdetails` (
  `groupid` bigint(20) NOT NULL,
  `groupname` varchar(30) NOT NULL,
  `groupcreationtime` bigint(20) DEFAULT '0',
  `groupmodifiedtime` bigint(20) DEFAULT '0',
  `groupcreatedby` varchar(50) DEFAULT NULL,
  `groupmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`groupid`),
  UNIQUE KEY `groupname` (`groupname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `guiapplicationdetails` (
  `guiappid` int(11) NOT NULL AUTO_INCREMENT,
  `guiappname` varchar(80) DEFAULT NULL,
  `guiappdesc` varchar(250) DEFAULT NULL,
  `guiappurl` varchar(500) DEFAULT NULL,
  `guiappiconcls` varchar(500) DEFAULT NULL,
  `guiapphorzloc` text,
  `guiapptreeloc` text,
  `guiappindex` bigint(20) DEFAULT NULL,
  `guiappoperatorid` varchar(100) DEFAULT NULL,
  `guiappadminstate` int(11) DEFAULT NULL,
  PRIMARY KEY (`guiappid`)
) ENGINE=InnoDB AUTO_INCREMENT=816 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `httpproxydetails` (
  `httpproxydetlid` int(11) NOT NULL AUTO_INCREMENT,
  `httpproxydetlhttphost` varchar(500) DEFAULT NULL,
  `httpproxydetlhttpport` int(11) DEFAULT NULL,
  `httpproxydetlhttpshost` varchar(500) DEFAULT NULL,
  `httpproxydetlhttpsport` int(11) DEFAULT NULL,
  `httpproxydetladminstate` int(11) DEFAULT NULL,
  `httpproxydetlcreationtime` bigint(20) DEFAULT '0',
  `httpproxydetlmodifiedtime` bigint(20) DEFAULT '0',
  `httpproxydetlcreatedby` varchar(50) DEFAULT NULL,
  `httpproxydetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`httpproxydetlid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentanalysisdetails` (
  `incidentanalysisdetlrecdid` bigint(20) NOT NULL,
  `incidentanalysisdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlincidenttype` int(11) DEFAULT NULL COMMENT '1 - Acked, 2 -\nConfirmed, 3 - In Progress, 4 - Resolved, 5 - Closed, 6 - Rejected',
  `incidentanalysisdetlincidentmsg` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlseqno` float DEFAULT NULL,
  `incidentanalysisdetltype` int(11) DEFAULT NULL COMMENT '0 - Optional, 1 - Mandatory',
  `incidentanalysisdetlat` bigint(20) DEFAULT '0',
  `incidentanalysisdetladditionalattributes` json DEFAULT NULL,
  `incidentanalysisdetlisstriked` int(11) DEFAULT '0',
  `incidentanalysisdetlstrikedreason` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcomments` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentanalysisdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentanalysisdetlrecdid`),
  KEY `incidentanalysisdetlincidentid` (`incidentanalysisdetlincidentid`,`incidentanalysisdetlincidenttype`,`incidentanalysisdetlseqno`,`incidentanalysisdetltype`,`incidentanalysisdetlat`,`incidentanalysisdetlisstriked`,`incidentanalysisdetlcreationtime`,`incidentanalysisdetlmodifiedtime`),
  CONSTRAINT `incidentanalysisdetails_ibfk_1` FOREIGN KEY (`incidentanalysisdetlincidentid`) REFERENCES `incidentdetails` (`incidentdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `onafterinsertincidentanalysisdetails` AFTER INSERT ON `incidentanalysisdetails` FOR EACH ROW BEGIN
     IF (NEW.incidentanalysisdetlincidenttype = 5 OR
NEW.incidentanalysisdetlincidenttype = 6)
     THEN
         DELETE FROM incidentdetails WHERE incidentdetlrecdid =
NEW.incidentanalysisdetlincidentid;
     END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentanalysisfiledetails` (
  `incidentanalysisdetlrecordid` bigint(20) NOT NULL,
  `incidentanalysisdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlanalysisid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlfileurl` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentanalysisdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentanalysisdetlrecordid`),
  UNIQUE KEY `incidentanalysisdetlfileurl` (`incidentanalysisdetlfileurl`),
  KEY `incidentanalysisdetlincidentid` (`incidentanalysisdetlincidentid`),
  KEY `incidentanalysisdetlanalysisid` (`incidentanalysisdetlanalysisid`),
  CONSTRAINT `incidentanalysisfiledetails_ibfk_1` FOREIGN KEY (`incidentanalysisdetlincidentid`) REFERENCES `incidentdetails` (`incidentdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `incidentanalysisfiledetails_ibfk_2` FOREIGN KEY (`incidentanalysisdetlanalysisid`) REFERENCES `incidentanalysisdetails` (`incidentanalysisdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentanalysishistorydetails` (
  `incidentanalysisdetlrecdid` bigint(20) NOT NULL,
  `incidentanalysisdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlincidenttype` int(11) DEFAULT NULL COMMENT '1 - Acked, 2 -\nConfirmed, 3 - In Progress, 4 - Resolved, 5 - Closed, 6 - Rejected',
  `incidentanalysisdetlincidentmsg` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlseqno` float DEFAULT NULL,
  `incidentanalysisdetltype` int(11) DEFAULT NULL COMMENT '0 - Optional, 1 - Mandatory',
  `incidentanalysisdetlat` bigint(20) DEFAULT '0',
  `incidentanalysisdetladditionalattributes` json DEFAULT NULL,
  `incidentanalysisdetlisstriked` int(11) DEFAULT '0',
  `incidentanalysisdetlstrikedreason` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcomments` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentanalysisdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentanalysisdetlrecdid`),
  KEY `incidentanalysisdetlincidentid` (`incidentanalysisdetlincidentid`,`incidentanalysisdetlincidenttype`,`incidentanalysisdetlseqno`,`incidentanalysisdetltype`,`incidentanalysisdetlat`,`incidentanalysisdetlisstriked`,`incidentanalysisdetlcreationtime`,`incidentanalysisdetlmodifiedtime`),
  CONSTRAINT `incidentanalysishistorydetails_ibfk_1` FOREIGN KEY (`incidentanalysisdetlincidentid`) REFERENCES `incidenthistorydetails` (`incidentdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentanalysishistoryfiledetails` (
  `incidentanalysisdetlrecordid` bigint(20) NOT NULL,
  `incidentanalysisdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlanalysisid` bigint(20) DEFAULT NULL,
  `incidentanalysisdetlfileurl` varchar(512) DEFAULT NULL,
  `incidentanalysisdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentanalysisdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentanalysisdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentanalysisdetlrecordid`),
  UNIQUE KEY `incidentanalysisdetlfileurl` (`incidentanalysisdetlfileurl`),
  KEY `incidentanalysisdetlincidentid` (`incidentanalysisdetlincidentid`),
  KEY `incidentanalysisdetlanalysisid` (`incidentanalysisdetlanalysisid`),
  CONSTRAINT `incidentanalysishistoryfiledetails_ibfk_1` FOREIGN KEY (`incidentanalysisdetlincidentid`) REFERENCES `incidenthistorydetails` (`incidentdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `incidentanalysishistoryfiledetails_ibfk_2` FOREIGN KEY (`incidentanalysisdetlanalysisid`) REFERENCES `incidentanalysishistorydetails` (`incidentanalysisdetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentdetails` (
  `incidentdetlrecdid` bigint(20) NOT NULL,
  `incidentdetldefinedincidentid` bigint(20) DEFAULT NULL,
  `incidentdetlpriority` int(11) DEFAULT NULL,
  `incidentdetltype` int(11) DEFAULT NULL COMMENT '1 - System, 2 - Custom',
  `incidentdetladminstate` int(11) DEFAULT '1' COMMENT '0 - Disabled, 1 -\nEnabled',
  `incidentdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentdetlassociatedneids` varchar(500) DEFAULT NULL,
  `incidentdetlassociatedcameraids` varchar(500) DEFAULT NULL,
  `incidentdetladditionalattributes` json DEFAULT NULL,
  `incidentdetlincidentoccuredat` varchar(512) DEFAULT NULL,
  `incidentdetlgroupid` varchar(15) DEFAULT NULL,
  `incidentdetldesc` text,
  `incidentdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentdetlrecdid`),
  KEY `incidentdetlpriority` (`incidentdetlpriority`),
  KEY `incidentdetldefinedincidentid` (`incidentdetldefinedincidentid`,`incidentdetlincidentid`,`incidentdetlincidentoccuredat`,`incidentdetlcreationtime`,`incidentdetlmodifiedtime`),
  CONSTRAINT `incidentdetails_ibfk_1` FOREIGN KEY (`incidentdetldefinedincidentid`) REFERENCES `definedincidentdetails` (`definedincidentdetlrecdid`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `incidentdetails_ibfk_2` FOREIGN KEY (`incidentdetlpriority`) REFERENCES `incidentprioritydetails` (`incidentprioritydetlrecdid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `onafterinsertincidentdetails` AFTER INSERT ON `incidentdetails` FOR EACH ROW BEGIN
      SET @i = 0;
      SET @id = NEW.incidentdetlrecdid;
      SET @occuredat = NEW.incidentdetlincidentoccuredat;
      SET @creationtime = NEW.incidentdetlcreationtime;
      SET @createdby = NEW.incidentdetlcreatedby;
      SET @incidenttype = NEW.incidentdetltype;
      SET @incidenttypeid = NEW.incidentdetltype;
      SET @definedincidentid = NEW.incidentdetldefinedincidentid;
      SELECT MAX(recdid) INTO @i FROM ((SELECT
COALESCE(MAX(incidentanalysisdetlrecdid), 0) AS recdid FROM
incidentanalysisdetails) UNION (SELECT
COALESCE(MAX(incidentanalysisdetlrecdid), 0) AS recdid FROM
incidentanalysishistorydetails)) AS T;
      IF @incidenttype = 1 THEN
          SET @i = @i + 1;
          INSERT INTO
incidentanalysisdetails(incidentanalysisdetlrecdid,
incidentanalysisdetlincidentid, incidentanalysisdetlincidenttype,
incidentanalysisdetlat, incidentanalysisdetlincidentmsg,
incidentanalysisdetlseqno, incidentanalysisdetltype,
incidentanalysisdetlcreationtime, incidentanalysisdetlcreatedby) VALUES
(@i, @id, 1, @creationtime, 'Automatically acked by system', 10, 1,
@creationtime, @createdby), (@i + 1, @id, 2, @creationtime,
'Automatically confirmed by system', 20, 1, @creationtime, @createdby);
          SET @i = @i + 1;
          INSERT INTO
incidentanalysisdetails(incidentanalysisdetlrecdid,
incidentanalysisdetlincidentid, incidentanalysisdetlincidenttype,
incidentanalysisdetlat, incidentanalysisdetlincidentmsg,
incidentanalysisdetlseqno, incidentanalysisdetltype,
incidentanalysisdetlcreationtime, incidentanalysisdetlcreatedby) SELECT
@j := @j + 1, @id, 3, @creationtime, definedresdetlincidentmsg,
definedresdetlseqno, definedresdetltype, @creationtime, @createdby FROM
definedresolutiondetails, (SELECT @j := @i) AS t WHERE
definedresdetlincidentid = @definedincidentid;
      ELSEIF @incidenttype = 2 THEN
          SET @i = @i + 1;
          INSERT INTO
incidentanalysisdetails(incidentanalysisdetlrecdid,
incidentanalysisdetlincidentid, incidentanalysisdetlincidenttype,
incidentanalysisdetlat, incidentanalysisdetlincidentmsg,
incidentanalysisdetlseqno, incidentanalysisdetltype,
incidentanalysisdetlcreationtime, incidentanalysisdetlcreatedby) VALUES
(@i, @id, 1, @creationtime, 'Automatically acked by system', 10, 1,
@creationtime, @createdby), (@i + 1, @id, 2, @creationtime,
'Automatically confirmed by system', 20, 1, @creationtime, @createdby);
          SET @i = @i + 1;
          INSERT INTO
incidentanalysisdetails(incidentanalysisdetlrecdid,
incidentanalysisdetlincidentid, incidentanalysisdetlincidenttype,
incidentanalysisdetlat, incidentanalysisdetlincidentmsg,
incidentanalysisdetlseqno, incidentanalysisdetltype,
incidentanalysisdetlcreationtime, incidentanalysisdetlcreatedby) SELECT
@j := @j + 1, @id, 3, @creationtime, definedresdetlincidentmsg,
definedresdetlseqno, definedresdetltype, @creationtime, @createdby FROM
definedresolutiondetails, (SELECT @j := @i) AS t WHERE
definedresdetlincidentid = @definedincidentid;
      END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `onbeforedeleteincidentdetails` BEFORE DELETE ON `incidentdetails` FOR EACH ROW BEGIN
     INSERT INTO incidenthistorydetails SELECT * FROM incidentdetails
WHERE incidentdetlrecdid = OLD.incidentdetlrecdid;
     INSERT INTO incidentanalysishistorydetails SELECT * FROM
incidentanalysisdetails WHERE incidentanalysisdetlincidentid =
OLD.incidentdetlrecdid;
     INSERT INTO incidentanalysishistoryfiledetails SELECT * FROM
incidentanalysisfiledetails WHERE incidentanalysisdetlincidentid =
OLD.incidentdetlrecdid;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidenthistorydetails` (
  `incidentdetlrecdid` bigint(20) NOT NULL,
  `incidentdetldefinedincidentid` bigint(20) DEFAULT NULL,
  `incidentdetlpriority` int(11) DEFAULT NULL,
  `incidentdetltype` int(11) DEFAULT NULL COMMENT '1 - System, 2 - Custom',
  `incidentdetladminstate` int(11) DEFAULT '1' COMMENT '0 - Disabled, 1 -\nEnabled',
  `incidentdetlincidentid` bigint(20) DEFAULT NULL,
  `incidentdetlassociatedneids` varchar(500) DEFAULT NULL,
  `incidentdetlassociatedcameraids` varchar(500) DEFAULT NULL,
  `incidentdetladditionalattributes` json DEFAULT NULL,
  `incidentdetlincidentoccuredat` varchar(512) DEFAULT NULL,
  `incidentdetlgroupid` varchar(15) DEFAULT NULL,
  `incidentdetldesc` text,
  `incidentdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentdetlrecdid`),
  KEY `incidentdetldefinedincidentid` (`incidentdetldefinedincidentid`,`incidentdetlincidentid`,`incidentdetlincidentoccuredat`,`incidentdetlcreationtime`,`incidentdetlmodifiedtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `incidentprioritydetails` (
  `incidentprioritydetlrecdid` int(11) NOT NULL,
  `incidentprioritydetlname` varchar(50) DEFAULT NULL,
  `incidentprioritydetldesc` varchar(255) DEFAULT NULL,
  `incidentprioritydetlcreationtime` bigint(20) DEFAULT '0',
  `incidentprioritydetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentprioritydetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentprioritydetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentprioritydetlrecdid`),
  KEY `incidentprioritydetlcreationtime` (`incidentprioritydetlcreationtime`,`incidentprioritydetlmodifiedtime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `jobdetails` (
  `jobdetailrecid` bigint(20) NOT NULL,
  `jobdetailfrom` bigint(20) DEFAULT NULL,
  `jobdetailgroup` varchar(256) DEFAULT NULL,
  `jobdetailname` varchar(256) DEFAULT NULL,
  `jobdetailclass` varchar(256) DEFAULT NULL,
  `jobdetailtype` int(11) DEFAULT NULL,
  `jobdetailat` text,
  `jobdetailpersistornot` int(11) DEFAULT '0',
  `jobdetailpriority` int(11) DEFAULT '5',
  `jobdetailarguments` text,
  `jobdetailttl` bigint(20) DEFAULT NULL,
  `jobdetailmisfiretype` int(11) DEFAULT '0',
  `jobdetailstatus` int(11) DEFAULT '0',
  `jobdetailadminstatus` int(11) DEFAULT '1',
  `jobdetailcreationtime` bigint(20) DEFAULT '0',
  `jobdetailmodifiedtime` bigint(20) DEFAULT '0',
  `jobdetailcreatedby` varchar(50) DEFAULT NULL,
  `jobdetailmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`jobdetailrecid`),
  UNIQUE KEY `jobdetailfrom` (`jobdetailfrom`,`jobdetailgroup`,`jobdetailname`),
  CONSTRAINT `jobdetails_ibfk_1` FOREIGN KEY (`jobdetailfrom`) REFERENCES `joboperationdetails` (`jobopdtlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `updateonjobdetails` AFTER UPDATE ON `jobdetails` FOR EACH ROW BEGIN    
	IF (NEW.jobdetailstatus = 4) THEN
		UPDATE jobdetailsstatus SET jobdtlstsstatus = 4, jobdtlstsabortedat = NEW.jobdetailmodifiedtime WHERE jobdtlstsjobid = NEW.jobdetailrecid AND jobdtlstsstatus = 2;
	END IF; 
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `jobdetailsstatus` (
  `jobdtlstsrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `jobdtlstsjobid` bigint(20) DEFAULT NULL,
  `jobdtlstsscheduledat` bigint(20) DEFAULT '0',
  `jobdtlstsinitiatedat` bigint(20) DEFAULT '0',
  `jobdtlstsabortedat` bigint(20) DEFAULT '0',
  `jobdtlstscompletedat` bigint(20) DEFAULT '0',
  `jobdtlstsstatus` int(11) DEFAULT NULL,
  `jobdtlstsstatusreason` text,
  `jobdtlstsstatusmessage` text,
  PRIMARY KEY (`jobdtlstsrecid`),
  UNIQUE KEY `jobdtlstsjobid` (`jobdtlstsjobid`),
  CONSTRAINT `jobdetailsstatus_ibfk_1` FOREIGN KEY (`jobdtlstsjobid`) REFERENCES `jobdetails` (`jobdetailrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7351 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `insertonjobdetailsstatus` BEFORE INSERT ON `jobdetailsstatus` FOR EACH ROW BEGIN
	IF EXISTS (SELECT * FROM jobdetailsstatus WHERE jobdtlstsjobid = NEW.jobdtlstsjobid) THEN
		INSERT INTO jobdetailsstatushistory(jobdtlstsjobid, jobdtlstsscheduledat, jobdtlstsinitiatedat, jobdtlstsabortedat, jobdtlstscompletedat, jobdtlstsstatus, jobdtlstsstatusreason, jobdtlstsstatusmessage) SELECT jobdtlstsjobid, jobdtlstsscheduledat, jobdtlstsinitiatedat, jobdtlstsabortedat, jobdtlstscompletedat, jobdtlstsstatus, jobdtlstsstatusreason, jobdtlstsstatusmessage FROM jobdetailsstatus WHERE jobdtlstsjobid = NEW.jobdtlstsjobid;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `updateonjobdetailsstatus` BEFORE UPDATE ON `jobdetailsstatus` FOR EACH ROW BEGIN
	IF (NEW.jobdtlstsstatus = 1) THEN
		INSERT INTO jobdetailsstatushistory(jobdtlstsjobid, jobdtlstsscheduledat, jobdtlstsinitiatedat, jobdtlstsabortedat, jobdtlstscompletedat, jobdtlstsstatus, jobdtlstsstatusreason, jobdtlstsstatusmessage) SELECT jobdtlstsjobid, jobdtlstsscheduledat, jobdtlstsinitiatedat, jobdtlstsabortedat, jobdtlstscompletedat, jobdtlstsstatus, jobdtlstsstatusreason, jobdtlstsstatusmessage FROM jobdetailsstatus WHERE jobdtlstsjobid = NEW.jobdtlstsjobid;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `jobdetailsstatushistory` (
  `jobdtlstsrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `jobdtlstsjobid` bigint(20) DEFAULT NULL,
  `jobdtlstsscheduledat` bigint(20) DEFAULT '0',
  `jobdtlstsinitiatedat` bigint(20) DEFAULT '0',
  `jobdtlstsabortedat` bigint(20) DEFAULT '0',
  `jobdtlstscompletedat` bigint(20) DEFAULT '0',
  `jobdtlstsstatus` int(11) DEFAULT NULL,
  `jobdtlstsstatusreason` text,
  `jobdtlstsstatusmessage` text,
  PRIMARY KEY (`jobdtlstsrecid`),
  KEY `jobdtlstsjobid` (`jobdtlstsjobid`),
  CONSTRAINT `jobdetailsstatushistory_ibfk_1` FOREIGN KEY (`jobdtlstsjobid`) REFERENCES `jobdetails` (`jobdetailrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14360 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `joboperationdetails` (
  `jobopdtlrecid` bigint(20) NOT NULL,
  `jobopdtlmodule` enum('SNMP_POLL_MANAGER','SANITY','TSPS','CCTV','MCS','AVLS','TETRA','UPS','NOTIFICATION_MESSAGE') NOT NULL,
  `jobopdtloperationname` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`jobopdtlrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `locationdetails` (
  `locationdetlrecid` bigint(20) NOT NULL,
  `locationdetlname` varchar(100) NOT NULL,
  `locationdetlcreationtime` bigint(20) DEFAULT '0',
  `locationdetlmodifiedtime` bigint(20) DEFAULT '0',
  `locationdetlcreatedby` varchar(100) DEFAULT NULL,
  `locationdetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`locationdetlrecid`),
  UNIQUE KEY `locationdetlname` (`locationdetlname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `logindetails` (
  `logindetrecid` int(11) NOT NULL AUTO_INCREMENT,
  `loginuserloginname` varchar(50) DEFAULT NULL,
  `logintime` bigint(20) DEFAULT '0',
  `logouttime` bigint(20) DEFAULT '0',
  `logoutreason` varchar(50) DEFAULT NULL,
  `loginipaddress` varchar(255) DEFAULT '127.0.0.1',
  PRIMARY KEY (`logindetrecid`),
  KEY `logintime` (`logintime`),
  KEY `logouttime` (`logouttime`)
) ENGINE=InnoDB AUTO_INCREMENT=3848 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `lrvpolldetails` (
  `lrvpdrecid` int(11) NOT NULL AUTO_INCREMENT,
  `lrvpdneid` bigint(20) DEFAULT NULL,
  `lrvpdsubsystemid` bigint(20) DEFAULT NULL,
  `lrvpdstatus` bigint(20) DEFAULT NULL,
  `lrvpdpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`lrvpdrecid`),
  KEY `lrvpdneid` (`lrvpdneid`),
  KEY `lrvpdsubsystemid` (`lrvpdsubsystemid`),
  KEY `lrvpdpolledtimestamp` (`lrvpdpolledtimestamp`),
  CONSTRAINT `lrvpolldetails_ibfk_1` FOREIGN KEY (`lrvpdneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `lrvpolldetails_ibfk_2` FOREIGN KEY (`lrvpdsubsystemid`) REFERENCES `subsystemdetails` (`subsystemdetlrecordid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54280737 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nealarmconfig` (
  `nealrmcfgid` int(11) NOT NULL,
  `nealrmcfgneid` bigint(20) DEFAULT NULL,
  `nealrmcfgemail` int(11) DEFAULT '0',
  `nealrmcfgsms` int(11) DEFAULT '0',
  `nealrmcfgtrap` int(11) DEFAULT '0',
  `nealrmcfgcreationtime` bigint(20) DEFAULT '0',
  `nealrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `nealrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `nealrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nealrmcfgid`),
  UNIQUE KEY `nealrmcfgneid` (`nealrmcfgneid`),
  CONSTRAINT `nealarmconfig_ibfk_1` FOREIGN KEY (`nealrmcfgneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nealarmemailconfig` (
  `nealrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `nealrmemailcfgalarmid` int(11) DEFAULT NULL,
  `nealrmemailcfgcritical` int(11) DEFAULT '0',
  `nealrmemailcfgcriticalemails` text,
  `nealrmemailcfgmajor` int(11) DEFAULT '0',
  `nealrmemailcfgmajoremails` text,
  `nealrmemailcfgminor` int(11) DEFAULT '0',
  `nealrmemailcfgminoremails` text,
  `nealrmemailcfgwarning` int(11) DEFAULT '0',
  `nealrmemailcfgwarningemails` text,
  `nealrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `nealrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `nealrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `nealrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nealrmemailcfgid`),
  UNIQUE KEY `nealrmemailcfgalarmid` (`nealrmemailcfgalarmid`),
  CONSTRAINT `nealarmemailconfig_ibfk_1` FOREIGN KEY (`nealrmemailcfgalarmid`) REFERENCES `nealarmconfig` (`nealrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nealarmsmsconfig` (
  `nealrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `nealrmsmscfgalarmid` int(11) DEFAULT NULL,
  `nealrmsmscfgcritical` int(11) DEFAULT '0',
  `nealrmsmscfgcriticalnumbers` text,
  `nealrmsmscfgmajor` int(11) DEFAULT '0',
  `nealrmsmscfgmajornumbers` text,
  `nealrmsmscfgminor` int(11) DEFAULT '0',
  `nealrmsmscfgminornumbers` text,
  `nealrmsmscfgwarning` int(11) DEFAULT '0',
  `nealrmsmscfgwarningnumbers` text,
  `nealrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `nealrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `nealrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `nealrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nealrmsmscfgid`),
  UNIQUE KEY `nealrmsmscfgalarmid` (`nealrmsmscfgalarmid`),
  CONSTRAINT `nealarmsmsconfig_ibfk_1` FOREIGN KEY (`nealrmsmscfgalarmid`) REFERENCES `nealarmconfig` (`nealrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `neapplicationdetails` (
  `neappid` int(11) NOT NULL AUTO_INCREMENT,
  `neappname` varchar(80) DEFAULT NULL,
  `neappdesc` varchar(250) DEFAULT NULL,
  `neappurl` varchar(500) DEFAULT NULL,
  `neappiconcls` varchar(500) DEFAULT NULL,
  `neapphorzloc` text,
  `neapptreeloc` text,
  `neappindex` bigint(20) DEFAULT NULL,
  `neappadminstate` int(11) DEFAULT NULL,
  PRIMARY KEY (`neappid`)
) ENGINE=InnoDB AUTO_INCREMENT=5008 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `neapplicationmanager` (
  `neappmgrid` int(11) NOT NULL AUTO_INCREMENT,
  `neappmgrneversionnumber` varchar(25) DEFAULT NULL,
  `neappmgrappid` int(11) DEFAULT NULL,
  PRIMARY KEY (`neappmgrid`),
  UNIQUE KEY `neappmgrneversionnumber` (`neappmgrneversionnumber`,`neappmgrappid`),
  KEY `neappmgrappid` (`neappmgrappid`),
  CONSTRAINT `neapplicationmanager_ibfk_1` FOREIGN KEY (`neappmgrneversionnumber`) REFERENCES `neversiondetails` (`neversionnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `neapplicationmanager_ibfk_2` FOREIGN KEY (`neappmgrappid`) REFERENCES `neapplicationdetails` (`neappid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3854 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nedetails` (
  `neid` bigint(20) NOT NULL,
  `nename` varchar(100) NOT NULL,
  `neversionnumber` varchar(25) DEFAULT NULL,
  `neadminstate` int(11) DEFAULT NULL,
  `neroomid` bigint(20) DEFAULT NULL,
  `neplatformid` bigint(20) DEFAULT NULL,
  `negroupid` bigint(20) DEFAULT NULL,
  `neidentifier` varchar(500) DEFAULT NULL,
  `nereferenceid` varchar(500) DEFAULT NULL,
  `necreationtime` bigint(20) DEFAULT '0',
  `nemodifiedtime` bigint(20) DEFAULT '0',
  `necreatedby` varchar(50) DEFAULT NULL,
  `nemodifiedby` varchar(50) DEFAULT NULL,
  `neshortname` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`neid`),
  UNIQUE KEY `nename` (`nename`),
  KEY `neroomid` (`neroomid`),
  KEY `neplatformid` (`neplatformid`),
  KEY `neversionnumber` (`neversionnumber`),
  KEY `negroupid` (`negroupid`),
  CONSTRAINT `nedetails_ibfk_1` FOREIGN KEY (`neroomid`) REFERENCES `roomdetails` (`roomid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nedetails_ibfk_2` FOREIGN KEY (`neplatformid`) REFERENCES `platformdetails` (`platformid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nedetails_ibfk_3` FOREIGN KEY (`neversionnumber`) REFERENCES `neversiondetails` (`neversionnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nedetails_ibfk_4` FOREIGN KEY (`negroupid`) REFERENCES `groupdetails` (`groupid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `deletenedetailsafterdeletepiksandmessage` AFTER DELETE ON `nedetails` FOR EACH ROW BEGIN
SET @id = OLD.neid;
SET @replaceneid = CONCAT(",", OLD.neid, ",");
 IF EXISTS (SELECT * FROM advertisementdetails WHERE FIND_IN_SET(@id, advdetpikid)) THEN
                UPDATE advertisementdetails SET advdetpikid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', advdetpikid, ','), @replaceneid, ',')));
 END IF;
 
 IF EXISTS (SELECT * FROM emergencyrequestmessages WHERE FIND_IN_SET(@id, emrgncyreqmsgpikid)) THEN
                UPDATE emergencyrequestmessages SET emrgncyreqmsgpikid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', emrgncyreqmsgpikid, ','), @replaceneid, ',')));
 END IF;
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nelayoutdetails` (
  `nelayoutdetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `nelayoutdetlneid` bigint(20) DEFAULT NULL,
  `nelayoutdetlagentid` bigint(20) DEFAULT NULL,
  `nelayoutdetlposition` varchar(50) DEFAULT NULL,
  `nelayoutdetladminstate` int(11) DEFAULT NULL,
  `nelayoutdetlcreationtime` bigint(20) DEFAULT '0',
  `nelayoutdetlmodifiedtime` bigint(20) DEFAULT '0',
  `nelayoutdetlcreatedby` varchar(50) DEFAULT NULL,
  `nelayoutdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nelayoutdetlrecordid`),
  KEY `nelayoutdetlneid` (`nelayoutdetlneid`),
  KEY `nelayoutdetlagentid` (`nelayoutdetlagentid`),
  CONSTRAINT `nelayoutdetails_ibfk_1` FOREIGN KEY (`nelayoutdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nelayoutdetails_ibfk_2` FOREIGN KEY (`nelayoutdetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nelayoutfiledetails` (
  `nelayoutfiledetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `nelayoutfiledetlneid` bigint(20) DEFAULT NULL,
  `nelayoutfiledetlfileurl` varchar(512) DEFAULT NULL,
  `nelayoutfiledetllayoutsize` varchar(50) DEFAULT NULL,
  `nelayoutfiledetladminstate` int(11) DEFAULT NULL,
  `nelayoutfiledetlcreationtime` bigint(20) DEFAULT '0',
  `nelayoutfiledetlmodifiedtime` bigint(20) DEFAULT '0',
  `nelayoutfiledetlcreatedby` varchar(32) DEFAULT NULL,
  `nelayoutfiledetlmodifiedby` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`nelayoutfiledetlrecordid`),
  UNIQUE KEY `nelayoutfiledetlfileurl` (`nelayoutfiledetlfileurl`),
  KEY `nelayoutfiledetlcreationtime` (`nelayoutfiledetlcreationtime`,`nelayoutfiledetlmodifiedtime`),
  KEY `nelayoutfiledetlneid` (`nelayoutfiledetlneid`),
  CONSTRAINT `nelayoutfiledetails_ibfk_1` FOREIGN KEY (`nelayoutfiledetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nelicensedetails` (
  `nelicid` int(11) NOT NULL AUTO_INCREMENT,
  `nelicsubtypeid` int(11) DEFAULT NULL,
  `nelicnumofnes` int(11) DEFAULT NULL,
  `nelicnumofagentsforne` int(11) DEFAULT NULL,
  PRIMARY KEY (`nelicid`),
  KEY `nelicsubtypeid` (`nelicsubtypeid`),
  CONSTRAINT `nelicensedetails_ibfk_1` FOREIGN KEY (`nelicsubtypeid`) REFERENCES `nesubtypedetails` (`nesubtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nestatus` (
  `nestatusrecid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nestatusneid` bigint(20) DEFAULT NULL,
  `nestatusagentid` bigint(20) DEFAULT NULL,
  `nestatusfirstoccurrencetime` bigint(20) unsigned DEFAULT '0',
  `nestatuslastoccurrencetime` bigint(20) unsigned DEFAULT '0',
  `nestatusnoofoccurrence` int(10) unsigned DEFAULT NULL,
  `nestatuseventtime` bigint(20) unsigned DEFAULT '0',
  `nestatuslastsuccessat` bigint(20) unsigned DEFAULT '0',
  `nestatusisreachable` tinyint(3) unsigned DEFAULT NULL,
  `nestatusinterval` smallint(5) unsigned DEFAULT '60',
  PRIMARY KEY (`nestatusrecid`),
  UNIQUE KEY `nestatusneid` (`nestatusneid`,`nestatusagentid`),
  KEY `nestatusneid_2` (`nestatusneid`),
  KEY `nestatusagentid` (`nestatusagentid`),
  KEY `nestatuseventtime` (`nestatuseventtime`),
  CONSTRAINT `nestatus_ibfk_1` FOREIGN KEY (`nestatusneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nestatus_ibfk_2` FOREIGN KEY (`nestatusagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=317604474 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `createnestatushistory` AFTER UPDATE ON `nestatus` FOR EACH ROW BEGIN
    IF (OLD.nestatusisreachable <> NEW.nestatusisreachable OR NEW.nestatusnoofoccurrence = 1) THEN
        INSERT INTO nestatushistory (nestatusneid, nestatusagentid, nestatusfirstoccurrencetime, nestatuslastoccurrencetime, nestatusnoofoccurrence, nestatuseventtime, nestatuslastsuccessat, nestatusisreachable, nestatusinterval) VALUES (OLD.nestatusneid, OLD.nestatusagentid, OLD.nestatusfirstoccurrencetime, OLD.nestatuslastoccurrencetime, OLD.nestatusnoofoccurrence, OLD.nestatuseventtime, OLD.nestatuslastsuccessat, OLD.nestatusisreachable, OLD.nestatusinterval);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nestatushistory` (
  `nestatusrecid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nestatusneid` bigint(20) DEFAULT NULL,
  `nestatusagentid` bigint(20) DEFAULT NULL,
  `nestatusfirstoccurrencetime` bigint(20) unsigned DEFAULT '0',
  `nestatuslastoccurrencetime` bigint(20) unsigned DEFAULT '0',
  `nestatusnoofoccurrence` int(10) unsigned DEFAULT NULL,
  `nestatuseventtime` bigint(20) unsigned DEFAULT '0',
  `nestatuslastsuccessat` bigint(20) unsigned DEFAULT '0',
  `nestatusisreachable` tinyint(3) unsigned DEFAULT NULL,
  `nestatusinterval` smallint(5) unsigned DEFAULT '60',
  PRIMARY KEY (`nestatusrecid`),
  KEY `nestatusneid` (`nestatusneid`),
  KEY `nestatusagentid` (`nestatusagentid`),
  KEY `nestatuseventtime` (`nestatuseventtime`),
  CONSTRAINT `nestatushistory_ibfk_1` FOREIGN KEY (`nestatusneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nestatushistory_ibfk_2` FOREIGN KEY (`nestatusagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23775 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nestatushistorytemp` (
  `nestatusrecid` int(11) NOT NULL AUTO_INCREMENT,
  `nestatusneid` bigint(20) DEFAULT NULL,
  `nestatusagentid` bigint(20) DEFAULT NULL,
  `nestatuseventtime` bigint(20) DEFAULT NULL,
  `nestatusrcvdtime` bigint(20) DEFAULT NULL,
  `nestatusisreachable` int(11) DEFAULT NULL,
  PRIMARY KEY (`nestatusrecid`),
  KEY `nestatusneid` (`nestatusneid`),
  KEY `nestatusagentid` (`nestatusagentid`),
  KEY `nestatuseventtime` (`nestatuseventtime`),
  KEY `nestatusrcvdtime` (`nestatusrcvdtime`),
  CONSTRAINT `nestatushistorytemp_ibfk_1` FOREIGN KEY (`nestatusneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nestatushistorytemp_ibfk_2` FOREIGN KEY (`nestatusagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1453621421 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nestatustemp` (
  `nestatusrecid` int(11) NOT NULL AUTO_INCREMENT,
  `nestatusneid` bigint(20) DEFAULT NULL,
  `nestatusagentid` bigint(20) DEFAULT NULL,
  `nestatuseventtime` bigint(20) DEFAULT NULL,
  `nestatusrcvdtime` bigint(20) DEFAULT NULL,
  `nestatusisreachable` int(11) DEFAULT NULL,
  PRIMARY KEY (`nestatusrecid`),
  UNIQUE KEY `nestatusneid` (`nestatusneid`,`nestatusagentid`),
  KEY `nestatusagentid` (`nestatusagentid`),
  KEY `nestatuseventtime` (`nestatuseventtime`),
  KEY `nestatusrcvdtime` (`nestatusrcvdtime`),
  CONSTRAINT `nestatustemp_ibfk_1` FOREIGN KEY (`nestatusneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nestatustemp_ibfk_2` FOREIGN KEY (`nestatusagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1453607461 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nesubtypalarmsmsconfig` (
  `nesubtypealrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `nesubtypealrmsmscfgalarmid` int(11) DEFAULT NULL,
  `nesubtypealrmsmscfgcritical` int(11) DEFAULT '0',
  `nesubtypealrmsmscfgcriticalnumbers` text,
  `nesubtypealrmsmscfgmajor` int(11) DEFAULT '0',
  `nesubtypealrmsmscfgmajornumbers` text,
  `nesubtypealrmsmscfgminor` int(11) DEFAULT '0',
  `nesubtypealrmsmscfgminornumbers` text,
  `nesubtypealrmsmscfgwarning` int(11) DEFAULT '0',
  `nesubtypealrmsmscfgwarningnumbers` text,
  `nesubtypealrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `nesubtypealrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `nesubtypealrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `nesubtypealrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nesubtypealrmsmscfgid`),
  UNIQUE KEY `nesubtypealrmsmscfgalarmid` (`nesubtypealrmsmscfgalarmid`),
  CONSTRAINT `nesubtypalarmsmsconfig_ibfk_1` FOREIGN KEY (`nesubtypealrmsmscfgalarmid`) REFERENCES `nesubtypealarmconfig` (`nesubtypealrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nesubtypealarmconfig` (
  `nesubtypealrmcfgid` int(11) NOT NULL,
  `nesubtypealrmcfgnesubtypeid` int(11) DEFAULT NULL,
  `nesubtypealrmcfgemail` int(11) DEFAULT '0',
  `nesubtypealrmcfgsms` int(11) DEFAULT '0',
  `nesubtypealrmcfgtrap` int(11) DEFAULT '0',
  `nesubtypealrmcfgcreationtime` bigint(20) DEFAULT '0',
  `nesubtypealrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `nesubtypealrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `nesubtypealrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nesubtypealrmcfgid`),
  UNIQUE KEY `nesubtypealrmcfgnesubtypeid` (`nesubtypealrmcfgnesubtypeid`),
  CONSTRAINT `nesubtypealarmconfig_ibfk_1` FOREIGN KEY (`nesubtypealrmcfgnesubtypeid`) REFERENCES `nesubtypedetails` (`nesubtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nesubtypealarmemailconfig` (
  `nesubtypealrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `nesubtypealrmemailcfgalarmid` int(11) DEFAULT NULL,
  `nesubtypealrmemailcfgcritical` int(11) DEFAULT '0',
  `nesubtypealrmemailcfgcriticalemails` text,
  `nesubtypealrmemailcfgmajor` int(11) DEFAULT '0',
  `nesubtypealrmemailcfgmajoremails` text,
  `nesubtypealrmemailcfgminor` int(11) DEFAULT '0',
  `nesubtypealrmemailcfgminoremails` text,
  `nesubtypealrmemailcfgwarning` int(11) DEFAULT '0',
  `nesubtypealrmemailcfgwarningemails` text,
  `nesubtypealrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `nesubtypealrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `nesubtypealrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `nesubtypealrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nesubtypealrmemailcfgid`),
  UNIQUE KEY `nesubtypealrmemailcfgalarmid` (`nesubtypealrmemailcfgalarmid`),
  CONSTRAINT `nesubtypealarmemailconfig_ibfk_1` FOREIGN KEY (`nesubtypealrmemailcfgalarmid`) REFERENCES `nesubtypealarmconfig` (`nesubtypealrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nesubtypedetails` (
  `nesubtypeid` int(11) NOT NULL AUTO_INCREMENT,
  `nesubtypenetypeid` int(11) DEFAULT NULL,
  `nesubtypename` varchar(100) DEFAULT NULL,
  `nesubtypedesc` varchar(250) DEFAULT NULL,
  `nesubtypemodel` varchar(100) DEFAULT NULL,
  `nesubtypemake` varchar(100) DEFAULT NULL,
  `nesubtypeversion` varchar(100) DEFAULT NULL,
  `nesubtypecommtype` int(11) DEFAULT NULL,
  `nesubtyperetries` int(11) DEFAULT NULL,
  `nesubtypetimeout` int(11) DEFAULT NULL,
  `nesubtypeminconnections` int(11) DEFAULT NULL,
  `nesubtypemaxconnections` int(11) DEFAULT NULL,
  `nesubtypeurl` text,
  PRIMARY KEY (`nesubtypeid`),
  KEY `nesubtypenetypeid` (`nesubtypenetypeid`),
  CONSTRAINT `nesubtypedetails_ibfk_1` FOREIGN KEY (`nesubtypenetypeid`) REFERENCES `netypedetails` (`netypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nesubtypethresholdconfig` (
  `nesubtypethresholdconfigid` bigint(20) NOT NULL,
  `nesubtypethresholdconfignesubtypeid` int(11) DEFAULT NULL,
  `nesubtypethresholdconfigname` varchar(100) DEFAULT NULL,
  `nesubtypethresholdconfigvalue1` double DEFAULT NULL,
  `nesubtypethresholdconfigvalue2` double DEFAULT NULL,
  `nesubtypethresholdconfigadminstate` int(11) DEFAULT NULL,
  `nesubtypethresholdconfigcreationtime` bigint(20) DEFAULT '0',
  `nesubtypethresholdconfigmodifiedtime` bigint(20) DEFAULT '0',
  `nesubtypethresholdconfigcreatedby` varchar(50) DEFAULT NULL,
  `nesubtypethresholdconfigmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nesubtypethresholdconfigid`),
  UNIQUE KEY `nesubtypethresholdconfigid` (`nesubtypethresholdconfigid`,`nesubtypethresholdconfignesubtypeid`,`nesubtypethresholdconfigname`),
  KEY `nesubtypethresholdconfignesubtypeid` (`nesubtypethresholdconfignesubtypeid`),
  KEY `nesubtypethresholdconfigname` (`nesubtypethresholdconfigname`,`nesubtypethresholdconfigcreationtime`,`nesubtypethresholdconfigmodifiedtime`),
  CONSTRAINT `nesubtypethresholdconfig_ibfk_1` FOREIGN KEY (`nesubtypethresholdconfignesubtypeid`) REFERENCES `nesubtypedetails` (`nesubtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `nethresholdconfig` (
  `nethresholdconfigid` bigint(20) NOT NULL,
  `nethresholdconfigneid` bigint(20) DEFAULT NULL,
  `nethresholdconfigagentid` bigint(20) DEFAULT NULL,
  `nethresholdconfigname` varchar(100) DEFAULT NULL,
  `nethresholdconfigvalue1` double DEFAULT NULL,
  `nethresholdconfigvalue2` double DEFAULT NULL,
  `nethresholdconfigcreationtime` bigint(20) DEFAULT '0',
  `nethresholdconfigmodifiedtime` bigint(20) DEFAULT '0',
  `nethresholdconfigcreatedby` varchar(50) DEFAULT NULL,
  `nethresholdconfigmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nethresholdconfigid`),
  UNIQUE KEY `nethresholdconfigid` (`nethresholdconfigid`,`nethresholdconfigneid`,`nethresholdconfigagentid`,`nethresholdconfigname`),
  KEY `nethresholdconfigneid` (`nethresholdconfigneid`),
  KEY `nethresholdconfigagentid` (`nethresholdconfigagentid`),
  KEY `nethresholdconfigname` (`nethresholdconfigname`,`nethresholdconfigcreationtime`,`nethresholdconfigmodifiedtime`),
  CONSTRAINT `nethresholdconfig_ibfk_1` FOREIGN KEY (`nethresholdconfigneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `nethresholdconfig_ibfk_2` FOREIGN KEY (`nethresholdconfigagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `netypedetails` (
  `netypeid` int(11) NOT NULL AUTO_INCREMENT,
  `netypename` varchar(25) DEFAULT NULL,
  `netypedesc` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`netypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `neversiondetails` (
  `neversionnumber` varchar(25) NOT NULL,
  `neversionnesubtypeid` int(11) NOT NULL,
  PRIMARY KEY (`neversionnumber`,`neversionnesubtypeid`),
  KEY `neversionnesubtypeid` (`neversionnesubtypeid`),
  CONSTRAINT `neversiondetails_ibfk_1` FOREIGN KEY (`neversionnesubtypeid`) REFERENCES `nesubtypedetails` (`nesubtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `northboundtrapsinkdetails` (
  `nrthbndtrapsinkid` int(11) NOT NULL,
  `nrthbndtrapsinkhost` varchar(500) DEFAULT NULL,
  `nrthbndtrapsinkport` int(11) DEFAULT NULL,
  `nrthbndtrapsinkversion` varchar(10) DEFAULT NULL,
  `nrthbndtrapsinkcommunity` varchar(10) DEFAULT NULL,
  `nrthbndtrapsinkretries` int(11) DEFAULT NULL,
  `nrthbndtrapsinktimeout` int(11) DEFAULT NULL,
  `nrthbndtrapsinkadminstate` int(11) DEFAULT NULL,
  `nrthbndtrapsinkcreationtime` bigint(20) DEFAULT '0',
  `nrthbndtrapsinkmodifiedtime` bigint(20) DEFAULT '0',
  `nrthbndtrapsinkcreatedby` varchar(50) DEFAULT NULL,
  `nrthbndtrapsinkmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`nrthbndtrapsinkid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `notificationmessagestatus` (
  `notifimsgid` bigint(20) NOT NULL AUTO_INCREMENT,
  `notifimsgschdledtag` bigint(20) DEFAULT NULL,
  `notifimsgneid` bigint(20) DEFAULT NULL,
  `notifimsgstatus` int(11) DEFAULT NULL,
  `notifimsgstatusreason` varchar(255) DEFAULT NULL,
  `notifimsgscheduledat` bigint(20) DEFAULT '0',
  `notifimsginitiatedat` bigint(20) DEFAULT '0',
  `notifimsgcompletedat` bigint(20) DEFAULT NULL,
  `notifimsgstoppedat` bigint(20) DEFAULT '0',
  `notifimsgcreationtime` bigint(20) DEFAULT '0',
  `notifimsgmodifiedtime` bigint(20) DEFAULT '0',
  `notifimsgcreatedby` varchar(32) DEFAULT NULL,
  `notifimsgmodifiedby` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`notifimsgid`),
  KEY `notifimsgneid` (`notifimsgneid`),
  KEY `notifimsgschdledtag` (`notifimsgschdledtag`),
  CONSTRAINT `notificationmessagestatus_ibfk_1` FOREIGN KEY (`notifimsgneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `notificationmessagestatus_ibfk_2` FOREIGN KEY (`notifimsgschdledtag`) REFERENCES `joboperationdetails` (`jobopdtlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `notificationmessagestatushistorytrigger` AFTER UPDATE ON `notificationmessagestatus` FOR EACH ROW BEGIN
    IF EXISTS (SELECT * FROM notificationmessagestatus WHERE notifimsgschdledtag = NEW.notifimsgschdledtag AND notifimsgneid = NEW.notifimsgneid)THEN
                SET @completeAtNew = NEW.notifimsgcompletedat;
                SET @stoppedAtNew = NEW.notifimsgstoppedat;
                SET @initiateAtNew = NEW.notifimsginitiatedat;
                SET @initiateAtOld = OLD.notifimsginitiatedat;
                IF((@initiateAtNew != 0 AND @stoppedAtNew != 0 ) OR (@initiateAtNew != 0 AND @completeAtNew != 0 )) THEN
                 INSERT INTO notificationmessagestatushistory(notifimsgstatshstrystatusid, notifimsgstatshstryschdledtag, notifimsgstatshstryneid, notifimsgstatshstrystatus, notifimsgstatshstrystatusreason, notifimsgstatshstryscheduledat, notifimsgstatshstryinitiatedat, notifimsgstatshstrycompletedat, notifimsgstatshstrystoppedat, notifimsgstatshstrycreationtime, notifimsgstatshstrymodifiedtime, notifimsgstatshstrycreatedby, notifimsgstatshstrymodifiedby) SELECT notifimsgid, notifimsgschdledtag, notifimsgneid, notifimsgstatus, notifimsgstatusreason, notifimsgscheduledat, notifimsginitiatedat, notifimsgcompletedat, notifimsgstoppedat, notifimsgcreationtime, notifimsgmodifiedtime, notifimsgcreatedby, notifimsgmodifiedby FROM notificationmessagestatus WHERE notifimsgschdledtag = NEW.notifimsgschdledtag AND notifimsgneid = NEW.notifimsgneid;
    END IF;
    END IF;  
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `notificationmessagestatushistory` (
  `notifimsgstatshstryid` bigint(20) NOT NULL AUTO_INCREMENT,
  `notifimsgstatshstrystatusid` bigint(20) DEFAULT NULL,
  `notifimsgstatshstryschdledtag` bigint(20) DEFAULT NULL,
  `notifimsgstatshstryneid` bigint(20) DEFAULT NULL,
  `notifimsgstatshstrystatus` int(11) DEFAULT NULL,
  `notifimsgstatshstrystatusreason` varchar(255) DEFAULT NULL,
  `notifimsgstatshstryscheduledat` bigint(20) DEFAULT '0',
  `notifimsgstatshstryinitiatedat` bigint(20) DEFAULT '0',
  `notifimsgstatshstrycompletedat` bigint(20) DEFAULT NULL,
  `notifimsgstatshstrystoppedat` bigint(20) DEFAULT '0',
  `notifimsgstatshstrycreationtime` bigint(20) DEFAULT '0',
  `notifimsgstatshstrymodifiedtime` bigint(20) DEFAULT '0',
  `notifimsgstatshstrycreatedby` varchar(32) DEFAULT NULL,
  `notifimsgstatshstrymodifiedby` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`notifimsgstatshstryid`),
  KEY `notifimsgstatshstrystatusid` (`notifimsgstatshstrystatusid`),
  CONSTRAINT `notificationmessagestatushistory_ibfk_1` FOREIGN KEY (`notifimsgstatshstrystatusid`) REFERENCES `notificationmessagestatus` (`notifimsgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `notifications` (
  `recordid` bigint(20) NOT NULL,
  `neid` bigint(20) DEFAULT NULL,
  `agentid` bigint(20) DEFAULT NULL,
  `moc` varchar(128) DEFAULT NULL,
  `moi` varchar(128) DEFAULT NULL,
  `eventtime` bigint(20) DEFAULT '0',
  `loggingtime` bigint(20) DEFAULT '0',
  `additionaltext` text,
  `probablecause` int(11) DEFAULT NULL,
  `specificproblem` int(11) DEFAULT NULL,
  `perceivedseverity` int(11) DEFAULT NULL,
  `eventtype` int(11) DEFAULT NULL,
  `additionalattributes` text,
  `agentsequencenumber` bigint(20) DEFAULT NULL,
  `alarmtypeid` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`recordid`),
  KEY `neid` (`neid`),
  KEY `agentid` (`agentid`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`neid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`agentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `notprocessedincidentdetails` (
  `incidentdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `incidentdetlattributes` json DEFAULT NULL,
  `incidentdetlcreationtime` bigint(20) DEFAULT '0',
  `incidentdetlmodifiedtime` bigint(20) DEFAULT '0',
  `incidentdetlcreatedby` varchar(50) DEFAULT NULL,
  `incidentdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`incidentdetlrecdid`)
) ENGINE=InnoDB AUTO_INCREMENT=67329 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `offlinehistoricalalaramdetails` (
  `offhistalarmid` int(11) NOT NULL AUTO_INCREMENT,
  `offhistalarmdate` date NOT NULL,
  `offhistalarmhour` tinyint(4) NOT NULL,
  `offhistalarmneid` bigint(20) NOT NULL,
  `offhistalarmtypeid` bigint(20) NOT NULL,
  `offhistalarmsevioritytype` int(11) NOT NULL,
  `offhistalarmcount` bigint(20) NOT NULL,
  `createdTime` datetime NOT NULL,
  `remark` text,
  PRIMARY KEY (`offhistalarmid`),
  UNIQUE KEY `offhistalarmneid` (`offhistalarmdate`,`offhistalarmhour`,`offhistalarmtypeid`,`offhistalarmsevioritytype`,`offhistalarmneid`),
  KEY `offhistalarmdetails_ibfk_1` (`offhistalarmneid`),
  KEY `offlinehistoricalalaramdetails_ibfk_2` (`offhistalarmtypeid`),
  KEY `offlinehistoricalalaramdetails_ibfk_3` (`offhistalarmsevioritytype`),
  CONSTRAINT `offhistalarmdetails_ibfk_1` FOREIGN KEY (`offhistalarmneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `offlinehistoricalalaramdetails_ibfk_2` FOREIGN KEY (`offhistalarmtypeid`) REFERENCES `alarmtypedetails` (`alarmtypeid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `offlinehistoricalalaramdetails_ibfk_3` FOREIGN KEY (`offhistalarmsevioritytype`) REFERENCES `perceivedseverity` (`perceivedseverityid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8916232 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `offlinehistoricalalaramdetails_tmp` (
  `offhistalarmdate` date DEFAULT NULL,
  `offhistalarmhour` tinyint(4) DEFAULT NULL,
  `offhistalarmneid` bigint(20) DEFAULT NULL,
  `offhistalarmtypeid` bigint(20) DEFAULT NULL,
  `offhistalarmsevioritytype` int(11) DEFAULT NULL,
  `offhistalarmcount` bigint(20) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `remark` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `offlinehistoricalincidentdetails` (
  `offhistincidentdate` date DEFAULT NULL,
  `offhistincidenthour` tinyint(4) DEFAULT NULL,
  `offhistincidenttypeid` bigint(20) DEFAULT NULL,
  `offhistincidentprioritytype` int(11) DEFAULT NULL,
  `offhistincidentcount` bigint(20) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `remark` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `offlinehistoricalincidentdetails_tmp` (
  `offhistincidentdate` date DEFAULT NULL,
  `offhistincidenthour` tinyint(4) DEFAULT NULL,
  `offhistincidenttypeid` bigint(20) DEFAULT NULL,
  `offhistincidentprioritytype` int(11) DEFAULT NULL,
  `offhistincidentcount` bigint(20) DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  `remark` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `operatortypes` (
  `oprtypeid` int(11) NOT NULL,
  `oprtypename` varchar(50) NOT NULL,
  `oprtypedesc` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`oprtypeid`),
  UNIQUE KEY `oprtypename` (`oprtypename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `perceivedseverity` (
  `perceivedseverityid` int(11) NOT NULL AUTO_INCREMENT,
  `perceivedseverityname` text,
  `perceivedseveritydesc` text,
  PRIMARY KEY (`perceivedseverityid`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `pikconfiguration` (
  `pikcfgrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `pikcfgimiid` varchar(250) DEFAULT NULL,
  `pikcfgneid` bigint(20) DEFAULT NULL,
  `pikcfgcreatedtime` bigint(20) DEFAULT '0',
  `pikcfgmodifiedtime` bigint(20) DEFAULT '0',
  `pikcfgcreatedby` varchar(50) DEFAULT NULL,
  `pikcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`pikcfgrecid`),
  KEY `pikcfgneid_ibfk_1` (`pikcfgneid`),
  CONSTRAINT `pikcfgneid_ibfk_1` FOREIGN KEY (`pikcfgneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `pikreadings` (
  `pikrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `pikneid` bigint(20) DEFAULT NULL,
  `pikcpuutil` double DEFAULT NULL,
  `pikmemorytotal` double DEFAULT NULL,
  `pikmemoryused` double DEFAULT NULL,
  `pikdisktotal` double DEFAULT NULL,
  `pikdiskused` double DEFAULT NULL,
  `piklogtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`pikrecid`),
  KEY `pikneid` (`pikneid`),
  CONSTRAINT `pikreadings_ibfk_1` FOREIGN KEY (`pikneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1415239 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `placeofinterestconfigurationdetails` (
  `plcinrstconfdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `plcinrstconfdetplcidid` bigint(20) DEFAULT NULL,
  `plcinrstconffilename` varchar(250) DEFAULT NULL,
  `plcinrstconfdesc` varchar(250) DEFAULT NULL,
  `plcinrstconfdetcreatedtime` bigint(20) DEFAULT '0',
  `plcinrstconfdetmodifiedtime` bigint(20) DEFAULT '0',
  `plcinrstconfdetcreatedby` varchar(50) DEFAULT NULL,
  `plcinrstconfdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`plcinrstconfdetrecid`),
  KEY `plcinrstconfdetplcidid` (`plcinrstconfdetplcidid`),
  CONSTRAINT `placeofinterestconfigurationdetails_ibfk_1` FOREIGN KEY (`plcinrstconfdetplcidid`) REFERENCES `placeofinterestdetails` (`plcinrstdetrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `placeofinterestdetails` (
  `plcinrstdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `plcinrstdetname` varchar(250) DEFAULT NULL,
  `plcinrstdetstationid` bigint(20) DEFAULT NULL,
  `plcinrstdetapprvstatus` tinyint(4) DEFAULT NULL,
  `plcinrstdetdesc` text,
  `plcinrstdetadminsts` tinyint(4) DEFAULT NULL,
  `plcinrstdetmqttstatus` tinyint(4) DEFAULT NULL,
  `plcinrstdetcreatedtime` bigint(20) DEFAULT '0',
  `plcinrstdetmodifiedtime` bigint(20) DEFAULT '0',
  `plcinrstdetcreatedby` varchar(50) DEFAULT NULL,
  `plcinrstdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`plcinrstdetrecid`),
  KEY `plcinrstdetstationid` (`plcinrstdetstationid`),
  CONSTRAINT `placeofinterestdetails_ibfk_1` FOREIGN KEY (`plcinrstdetstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `platformalarmconfig` (
  `platformalrmcfgid` int(11) NOT NULL,
  `platformalrmcfgplatformid` bigint(20) DEFAULT NULL,
  `platformalrmcfgemail` int(11) DEFAULT '0',
  `platformalrmcfgsms` int(11) DEFAULT '0',
  `platformalrmcfgtrap` int(11) DEFAULT '0',
  `platformalrmcfgcreationtime` bigint(20) DEFAULT '0',
  `platformalrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `platformalrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `platformalrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`platformalrmcfgid`),
  UNIQUE KEY `platformalrmcfgplatformid` (`platformalrmcfgplatformid`),
  CONSTRAINT `platformalarmconfig_ibfk_1` FOREIGN KEY (`platformalrmcfgplatformid`) REFERENCES `platformdetails` (`platformid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `platformalarmemailconfig` (
  `platformalrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `platformalrmemailcfgalarmid` int(11) DEFAULT NULL,
  `platformalrmemailcfgcritical` int(11) DEFAULT '0',
  `platformalrmemailcfgcriticalemails` text,
  `platformalrmemailcfgmajor` int(11) DEFAULT '0',
  `platformalrmemailcfgmajoremails` text,
  `platformalrmemailcfgminor` int(11) DEFAULT '0',
  `platformalrmemailcfgminoremails` text,
  `platformalrmemailcfgwarning` int(11) DEFAULT '0',
  `platformalrmemailcfgwarningemails` text,
  `platformalrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `platformalrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `platformalrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `platformalrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`platformalrmemailcfgid`),
  UNIQUE KEY `platformalrmemailcfgalarmid` (`platformalrmemailcfgalarmid`),
  CONSTRAINT `platformalarmemailconfig_ibfk_1` FOREIGN KEY (`platformalrmemailcfgalarmid`) REFERENCES `platformalarmconfig` (`platformalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `platformalarmsmsconfig` (
  `platformalrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `platformalrmsmscfgalarmid` int(11) DEFAULT NULL,
  `platformalrmsmscfgcritical` int(11) DEFAULT '0',
  `platformalrmsmscfgcriticalnumbers` text,
  `platformalrmsmscfgmajor` int(11) DEFAULT '0',
  `platformalrmsmscfgmajornumbers` text,
  `platformalrmsmscfgminor` int(11) DEFAULT '0',
  `platformalrmsmscfgminornumbers` text,
  `platformalrmsmscfgwarning` int(11) DEFAULT '0',
  `platformalrmsmscfgwarningnumbers` text,
  `platformalrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `platformalrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `platformalrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `platformalrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`platformalrmsmscfgid`),
  UNIQUE KEY `platformalrmsmscfgalarmid` (`platformalrmsmscfgalarmid`),
  CONSTRAINT `platformalarmsmsconfig_ibfk_1` FOREIGN KEY (`platformalrmsmscfgalarmid`) REFERENCES `platformalarmconfig` (`platformalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `platformdetails` (
  `platformid` bigint(20) NOT NULL,
  `platformname` varchar(30) NOT NULL,
  `platformshortname` varchar(20) NOT NULL,
  `platformdirection` enum('UP','DOWN','SINGLE','NONE') DEFAULT NULL,
  `platformlrvids` varchar(100) DEFAULT NULL,
  `platformstationid` bigint(20) DEFAULT NULL,
  `platformtrainstarttime` bigint(20) DEFAULT NULL,
  `platformtrainendtime` bigint(20) DEFAULT NULL,
  `platformcreationtime` bigint(20) DEFAULT '0',
  `platformmodifiedtime` bigint(20) DEFAULT '0',
  `platformcreatedby` varchar(50) DEFAULT NULL,
  `platformmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`platformid`),
  UNIQUE KEY `platformstationid` (`platformstationid`,`platformname`,`platformshortname`),
  UNIQUE KEY `platformlrvids` (`platformlrvids`),
  KEY `platformlrvids_2` (`platformlrvids`),
  CONSTRAINT `platformdetails_ibfk_1` FOREIGN KEY (`platformstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `deleteplatformdetailsafterdeletepiksandmessage` AFTER DELETE ON `platformdetails` FOR EACH ROW BEGIN
SET @id = OLD.platformid;
SET @replaceplatformid = CONCAT(",", OLD.platformid, ",");
 IF EXISTS (SELECT * FROM advertisementdetails WHERE FIND_IN_SET(@id, advdetplatformid)) THEN
                UPDATE advertisementdetails SET advdetplatformid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', advdetplatformid, ','), @replaceplatformid, ',')));
 END IF;
 
 IF EXISTS (SELECT * FROM emergencyrequestmessages WHERE FIND_IN_SET(@id, emrgncyreqmsgplatformid)) THEN
                UPDATE emergencyrequestmessages SET emrgncyreqmsgplatformid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', emrgncyreqmsgplatformid, ','), @replaceplatformid, ',')));
 END IF;
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `probablecauses` (
  `probablecauseid` int(11) NOT NULL AUTO_INCREMENT,
  `probablecausename` text,
  `probablecausedesc` text,
  PRIMARY KEY (`probablecauseid`)
) ENGINE=InnoDB AUTO_INCREMENT=270 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `profiledetails` (
  `profileid` int(11) NOT NULL,
  `profilename` varchar(80) DEFAULT NULL,
  `profiledesc` varchar(250) DEFAULT NULL,
  `profileneversionnumber` varchar(25) DEFAULT NULL,
  `profilenote` varchar(250) DEFAULT NULL,
  `profilesystemprofile` int(11) DEFAULT NULL,
  `profileoprtypeid` int(11) DEFAULT NULL,
  `profileadminstate` int(11) DEFAULT '0',
  `profilecreationtime` bigint(20) DEFAULT '0',
  `profilemodifiedtime` bigint(20) DEFAULT '0',
  `profilecreatedby` varchar(50) DEFAULT NULL,
  `profilemodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`profileid`),
  UNIQUE KEY `profilename` (`profilename`,`profileneversionnumber`),
  KEY `profileneversionnumber` (`profileneversionnumber`),
  KEY `profileoprtypeid` (`profileoprtypeid`),
  CONSTRAINT `profiledetails_ibfk_1` FOREIGN KEY (`profileneversionnumber`) REFERENCES `neversiondetails` (`neversionnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `profiledetails_ibfk_2` FOREIGN KEY (`profileoprtypeid`) REFERENCES `operatortypes` (`oprtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `riskdetails` (
  `riskdetlrecid` bigint(20) NOT NULL,
  `riskdetlname` varchar(100) NOT NULL,
  `riskdetlcreationtime` bigint(20) DEFAULT '0',
  `riskdetlmodifiedtime` bigint(20) DEFAULT '0',
  `riskdetlcreatedby` varchar(100) DEFAULT NULL,
  `riskdetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`riskdetlrecid`),
  UNIQUE KEY `riskdetlname` (`riskdetlname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `roomalarmconfig` (
  `roomalrmcfgid` int(11) NOT NULL,
  `roomalrmcfgroomid` bigint(20) DEFAULT NULL,
  `roomalrmcfgemail` int(11) DEFAULT '0',
  `roomalrmcfgsms` int(11) DEFAULT '0',
  `roomalrmcfgtrap` int(11) DEFAULT '0',
  `roomalrmcfgcreationtime` bigint(20) DEFAULT '0',
  `roomalrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `roomalrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `roomalrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`roomalrmcfgid`),
  UNIQUE KEY `roomalrmcfgroomid` (`roomalrmcfgroomid`),
  CONSTRAINT `roomalarmconfig_ibfk_1` FOREIGN KEY (`roomalrmcfgroomid`) REFERENCES `roomdetails` (`roomid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `roomalarmemailconfig` (
  `roomalrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `roomalrmemailcfgalarmid` int(11) DEFAULT NULL,
  `roomalrmemailcfgcritical` int(11) DEFAULT '0',
  `roomalrmemailcfgcriticalemails` text,
  `roomalrmemailcfgmajor` int(11) DEFAULT '0',
  `roomalrmemailcfgmajoremails` text,
  `roomalrmemailcfgminor` int(11) DEFAULT '0',
  `roomalrmemailcfgminoremails` text,
  `roomalrmemailcfgwarning` int(11) DEFAULT '0',
  `roomalrmemailcfgwarningemails` text,
  `roomalrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `roomalrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `roomalrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `roomalrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`roomalrmemailcfgid`),
  UNIQUE KEY `roomalrmemailcfgalarmid` (`roomalrmemailcfgalarmid`),
  CONSTRAINT `roomalarmemailconfig_ibfk_1` FOREIGN KEY (`roomalrmemailcfgalarmid`) REFERENCES `roomalarmconfig` (`roomalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `roomalarmsmsconfig` (
  `roomalrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `roomalrmsmscfgalarmid` int(11) DEFAULT NULL,
  `roomalrmsmscfgcritical` int(11) DEFAULT '0',
  `roomalrmsmscfgcriticalnumbers` text,
  `roomalrmsmscfgmajor` int(11) DEFAULT '0',
  `roomalrmsmscfgmajornumbers` text,
  `roomalrmsmscfgminor` int(11) DEFAULT '0',
  `roomalrmsmscfgminornumbers` text,
  `roomalrmsmscfgwarning` int(11) DEFAULT '0',
  `roomalrmsmscfgwarningnumbers` text,
  `roomalrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `roomalrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `roomalrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `roomalrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`roomalrmsmscfgid`),
  UNIQUE KEY `roomalrmsmscfgalarmid` (`roomalrmsmscfgalarmid`),
  CONSTRAINT `roomalarmsmsconfig_ibfk_1` FOREIGN KEY (`roomalrmsmscfgalarmid`) REFERENCES `roomalarmconfig` (`roomalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `roomdetails` (
  `roomid` bigint(20) NOT NULL,
  `roomname` varchar(30) NOT NULL,
  `roomshortname` varchar(20) NOT NULL,
  `roompersonname` varchar(100) DEFAULT NULL,
  `roommobilenumber` varchar(15) DEFAULT NULL,
  `roomphonenumber` varchar(15) DEFAULT NULL,
  `roomemail` varchar(255) DEFAULT NULL,
  `roomdesc` text,
  `roomfloorid` bigint(20) DEFAULT NULL,
  `roomcreationtime` bigint(20) DEFAULT '0',
  `roommodifiedtime` bigint(20) DEFAULT '0',
  `roomcreatedby` varchar(50) DEFAULT NULL,
  `roommodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`roomid`),
  UNIQUE KEY `roomfloorid` (`roomfloorid`,`roomname`,`roomshortname`),
  CONSTRAINT `roomdetails_ibfk_1` FOREIGN KEY (`roomfloorid`) REFERENCES `floordetails` (`floorid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sbiconfig` (
  `sbiconfigid` bigint(20) NOT NULL,
  `sbiconfigneid` bigint(20) DEFAULT NULL,
  `sbiconfigagentid` bigint(20) DEFAULT NULL,
  `sbiconfigusername` varchar(255) DEFAULT NULL,
  `sbiconfigpassword` varchar(255) DEFAULT NULL,
  `sbiconfigurl` varchar(255) DEFAULT NULL,
  `sbiconfigadminstate` int(11) DEFAULT NULL,
  `sbiconfigstate` int(11) DEFAULT NULL,
  `sbiconfigcreationtime` bigint(20) DEFAULT '0',
  `sbiconfigmodifiedtime` bigint(20) DEFAULT '0',
  `sbiconfigcreatedby` varchar(50) DEFAULT NULL,
  `sbiconfigmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`sbiconfigid`),
  KEY `sbiconfigneid` (`sbiconfigneid`),
  KEY `sbiconfigagentid` (`sbiconfigagentid`),
  CONSTRAINT `sbiconfig_ibfk_1` FOREIGN KEY (`sbiconfigneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sbiconfig_ibfk_2` FOREIGN KEY (`sbiconfigagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sectiondetails` (
  `sectiondetlrecid` bigint(20) NOT NULL,
  `sectiondetlname` varchar(100) NOT NULL,
  `sectiondetlcreationtime` bigint(20) DEFAULT '0',
  `sectiondetlmodifiedtime` bigint(20) DEFAULT '0',
  `sectiondetlcreatedby` varchar(100) DEFAULT NULL,
  `sectiondetlmodifiedby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`sectiondetlrecid`),
  UNIQUE KEY `sectiondetlname` (`sectiondetlname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `serverproperties` (
  `serverpropid` int(11) NOT NULL,
  `serverpropname` varchar(50) DEFAULT NULL,
  `serverpropval` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`serverpropid`),
  KEY `serverpropname` (`serverpropname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `signallingpolldetails` (
  `signallingpdrecid` int(11) NOT NULL AUTO_INCREMENT,
  `signallingpdneid` bigint(20) DEFAULT NULL,
  `signallingpdsubsystemid` bigint(20) DEFAULT NULL,
  `signallingpdstatus` bigint(20) DEFAULT NULL,
  `signallingpdpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`signallingpdrecid`),
  KEY `signallingpdneid` (`signallingpdneid`),
  KEY `signallingpdsubsystemid` (`signallingpdsubsystemid`),
  CONSTRAINT `signallingpolldetails_ibfk_1` FOREIGN KEY (`signallingpdneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `signallingpolldetails_ibfk_2` FOREIGN KEY (`signallingpdsubsystemid`) REFERENCES `subsystemdetails` (`subsystemdetlrecordid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43664576 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `smresponse` (
  `smresprecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `smrespaimedarrivaltime` varchar(50) DEFAULT NULL,
  `smrespaimeddeparturetime` varchar(50) DEFAULT NULL,
  `smrespexpectedarrivaltime` varchar(50) DEFAULT NULL,
  `smrespexpecteddeparturetime` varchar(50) DEFAULT NULL,
  `smresprecordedattime` varchar(50) DEFAULT NULL,
  `smrespvehicleatstop` varchar(50) DEFAULT NULL,
  `smrespmontoringrefnum` varchar(50) DEFAULT NULL,
  `smrespdestination` varchar(50) DEFAULT NULL,
  `smrespdummy1` varchar(50) DEFAULT NULL,
  `smrespdummy2` varchar(50) DEFAULT NULL,
  `smrespcreateddate` bigint(20) DEFAULT '0',
  `smrespuniqueval` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`smresprecid`),
  KEY `smrespcreateddate` (`smrespcreateddate`)
) ENGINE=InnoDB AUTO_INCREMENT=1599854334 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `smscfg` (
  `smscfgid` int(11) NOT NULL,
  `smscfgvendorid` int(11) DEFAULT NULL,
  `smscfgsenderid` varchar(11) DEFAULT NULL,
  `smscfgadminstate` int(11) DEFAULT '0',
  `smscfgcreationtime` bigint(20) DEFAULT '0',
  `smscfgmodifiedtime` bigint(20) DEFAULT '0',
  `smscfgcreatedby` varchar(50) DEFAULT NULL,
  `smscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`smscfgid`),
  KEY `smscfgvendorid` (`smscfgvendorid`),
  CONSTRAINT `smscfg_ibfk_1` FOREIGN KEY (`smscfgvendorid`) REFERENCES `smsvendordetails` (`smsvendordetlid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `smssent` (
  `smssentid` bigint(20) NOT NULL AUTO_INCREMENT,
  `smssentstatus` bigint(20) DEFAULT NULL,
  `smssentstatusreason` text,
  `smssentreason` text,
  `smssentmessage` text,
  `smssenttime` bigint(20) DEFAULT NULL,
  `smssentgatewayrefid` text,
  `smssentby` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`smssentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `smssentrecipients` (
  `smssentrcpntsid` bigint(20) NOT NULL AUTO_INCREMENT,
  `smssentrcpntssmssentid` bigint(20) DEFAULT NULL,
  `smssentrcpntname` varchar(250) DEFAULT NULL,
  `smssentrcpntnumber` varchar(250) DEFAULT NULL,
  `smssentrcpntdlvrystatus` int(11) DEFAULT NULL,
  `smssentrcpntdlvrystatusreason` text,
  `smssentrcpntdlvrecdtime` bigint(20) DEFAULT NULL,
  `smssentrcpntgatewayrefid` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`smssentrcpntsid`),
  KEY `smssentrcpntssmssentid` (`smssentrcpntssmssentid`),
  CONSTRAINT `smssentrecipients_ibfk_1` FOREIGN KEY (`smssentrcpntssmssentid`) REFERENCES `smssent` (`smssentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `smsvendordetails` (
  `smsvendordetlid` int(11) NOT NULL AUTO_INCREMENT,
  `smsvendordetlname` varchar(500) DEFAULT NULL,
  `smsvendordetlmsgurl` text,
  `smsvendordetlcampaignurl` text,
  `smsvendordetlusername` varchar(500) DEFAULT NULL,
  `smsvendordetlpassword` text,
  `smsvendordetlcreationtime` bigint(20) DEFAULT '0',
  `smsvendordetlmodifiedtime` bigint(20) DEFAULT '0',
  `smsvendordetlcreatedby` varchar(50) DEFAULT NULL,
  `smsvendordetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`smsvendordetlid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmpdiskinformationdetails` (
  `snmphrstoragedetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmphrstoragedetlneid` bigint(20) DEFAULT NULL,
  `snmphrstoragedetlagentid` bigint(20) DEFAULT NULL,
  `snmphrstoragedetlindex` bigint(20) DEFAULT NULL,
  `snmphrstoragedetltype` bigint(20) DEFAULT NULL,
  `snmphrstoragedetldescr` varchar(255) DEFAULT NULL,
  `snmphrstoragedetlallocationunits` bigint(20) DEFAULT NULL,
  `snmphrstoragedetlsize` bigint(20) DEFAULT NULL,
  `snmphrstoragedetlused` bigint(20) DEFAULT NULL,
  `snmphrstoragedetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmphrstoragedetlrecdid`),
  UNIQUE KEY `snmphrstoragedetlneid` (`snmphrstoragedetlneid`,`snmphrstoragedetlagentid`,`snmphrstoragedetlindex`,`snmphrstoragedetlpolledtimestamp`),
  KEY `snmphrstoragedetlagentid` (`snmphrstoragedetlagentid`),
  CONSTRAINT `snmpdiskinformationdetails_ibfk_1` FOREIGN KEY (`snmphrstoragedetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmpdiskinformationdetails_ibfk_2` FOREIGN KEY (`snmphrstoragedetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8964856 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmpdiskiodetails` (
  `snmpdiskiodetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmpdiskiodetlneid` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlagentid` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlindex` bigint(20) DEFAULT NULL,
  `snmpdiskiodetldevice` varchar(255) DEFAULT NULL,
  `snmpdiskiodetlndead` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlnwritten` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlreads` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlwrites` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlla1` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlla5` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlla15` bigint(20) DEFAULT NULL,
  `snmpdiskiodetllanreadx` bigint(20) DEFAULT NULL,
  `snmpdiskiodetllanwrittenx` bigint(20) DEFAULT NULL,
  `snmpdiskiodetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmpdiskiodetlrecdid`),
  UNIQUE KEY `snmpdiskiodetlneid` (`snmpdiskiodetlneid`,`snmpdiskiodetlagentid`,`snmpdiskiodetlindex`,`snmpdiskiodetlpolledtimestamp`),
  KEY `snmpdiskiodetlagentid` (`snmpdiskiodetlagentid`),
  CONSTRAINT `snmpdiskiodetails_ibfk_1` FOREIGN KEY (`snmpdiskiodetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmpdiskiodetails_ibfk_2` FOREIGN KEY (`snmpdiskiodetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54090 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmphardwareconfigdetails` (
  `snmphrdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmphrdetlneid` bigint(20) DEFAULT NULL,
  `snmphrdetlagentid` bigint(20) DEFAULT NULL,
  `snmphrdetlindex` bigint(20) DEFAULT NULL,
  `snmphrdetlmountpoint` bigint(20) DEFAULT NULL,
  `snmphrdetlremotemountpoint` bigint(20) DEFAULT NULL,
  `snmphrdetltype` bigint(20) DEFAULT NULL,
  `snmphrdetlaccess` bigint(20) DEFAULT NULL,
  `snmphrdetlbootable` bigint(20) DEFAULT NULL,
  `snmphrdetlstorageindex` bigint(20) DEFAULT NULL,
  `snmphrdetlLastfullbackupdate` bigint(20) DEFAULT NULL,
  `snmphrdetlLastpartialbackupdate` bigint(20) DEFAULT NULL,
  `snmphrdetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmphrdetlrecdid`),
  UNIQUE KEY `snmphrdetlneid` (`snmphrdetlneid`,`snmphrdetlagentid`,`snmphrdetlindex`,`snmphrdetlpolledtimestamp`),
  KEY `snmphrdetlagentid` (`snmphrdetlagentid`),
  CONSTRAINT `snmphardwareconfigdetails_ibfk_1` FOREIGN KEY (`snmphrdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmphardwareconfigdetails_ibfk_2` FOREIGN KEY (`snmphrdetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmpinterfacedetails` (
  `snmpifdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmpifdetlneid` bigint(20) DEFAULT NULL,
  `snmpifdetlagentid` bigint(20) DEFAULT NULL,
  `snmpifdetlindex` bigint(20) DEFAULT NULL,
  `snmpifdetldesc` varchar(255) DEFAULT NULL,
  `snmpifdetltype` varchar(255) DEFAULT NULL,
  `snmpifdetlmtu` bigint(20) DEFAULT NULL,
  `snmpifdetlspeed` bigint(20) DEFAULT NULL,
  `snmpifdetlphysaddress` varchar(255) DEFAULT NULL,
  `snmpifdetladminstatus` bigint(20) DEFAULT NULL,
  `snmpifdetloperationstatus` bigint(20) DEFAULT NULL,
  `snmpifdetllastchange` varchar(255) DEFAULT NULL,
  `snmpifdetlinoctets` bigint(20) DEFAULT NULL,
  `snmpifdetlinucastpkts` bigint(20) DEFAULT NULL,
  `snmpifdetlinnucastpkts` bigint(20) DEFAULT NULL,
  `snmpifdetlindiscards` bigint(20) DEFAULT NULL,
  `snmpifdetlinerrors` bigint(20) DEFAULT NULL,
  `snmpifdetlinunknownprotos` bigint(20) DEFAULT NULL,
  `snmpifdetloutoctets` bigint(20) DEFAULT NULL,
  `snmpifdetloutucastpkts` bigint(20) DEFAULT NULL,
  `snmpifdetloutnucastpkts` bigint(20) DEFAULT NULL,
  `snmpifdetloutdiscards` bigint(20) DEFAULT NULL,
  `snmpifdetlouterrors` bigint(20) DEFAULT NULL,
  `snmpifdetloutqlen` bigint(20) DEFAULT NULL,
  `snmpifdetlspecific` varchar(255) DEFAULT NULL,
  `snmpifdetlpolledtimestamp` bigint(20) DEFAULT '0',
  PRIMARY KEY (`snmpifdetlrecdid`),
  UNIQUE KEY `snmpifdetlneid` (`snmpifdetlneid`,`snmpifdetlagentid`,`snmpifdetlindex`,`snmpifdetlpolledtimestamp`),
  KEY `snmpifdetlagentid` (`snmpifdetlagentid`),
  CONSTRAINT `snmpinterfacedetails_ibfk_1` FOREIGN KEY (`snmpifdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmpinterfacedetails_ibfk_2` FOREIGN KEY (`snmpifdetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1219294547 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmploadaveragedetails` (
  `snmpladetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmpladetlneid` bigint(20) DEFAULT NULL,
  `snmpladetlagentid` bigint(20) DEFAULT NULL,
  `snmpladetlindex` bigint(20) DEFAULT NULL,
  `snmpladetlnames` varchar(255) DEFAULT NULL,
  `snmpladetlload` varchar(255) DEFAULT NULL,
  `snmpladetlconfig` varchar(255) DEFAULT NULL,
  `snmpladetlloadint` bigint(20) DEFAULT NULL,
  `snmpladetlloadfloat` double DEFAULT NULL,
  `snmpladetlerrorflag` bigint(20) DEFAULT NULL,
  `snmpladetlerrmessage` varchar(255) DEFAULT NULL,
  `snmpladetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmpladetlrecdid`),
  UNIQUE KEY `snmpladetlneid` (`snmpladetlneid`,`snmpladetlagentid`,`snmpladetlindex`,`snmpladetlpolledtimestamp`),
  KEY `snmpladetlagentid` (`snmpladetlagentid`),
  CONSTRAINT `snmploadaveragedetails_ibfk_1` FOREIGN KEY (`snmpladetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmploadaveragedetails_ibfk_2` FOREIGN KEY (`snmpladetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20307 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmpmemorydetails` (
  `snmpmemdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmpmemdetlneid` bigint(20) DEFAULT NULL,
  `snmpmemdetlagentid` bigint(20) DEFAULT NULL,
  `snmpmemdetlindex` bigint(20) DEFAULT NULL,
  `snmpmemdetlerrorname` varchar(255) DEFAULT NULL,
  `snmpmemdetltotalswap` bigint(20) DEFAULT NULL,
  `snmpmemdetlavailswap` bigint(20) DEFAULT NULL,
  `snmpmemdetltotalreal` bigint(20) DEFAULT NULL,
  `snmpmemdetlavailreal` bigint(20) DEFAULT NULL,
  `snmpmemdetltotalfree` bigint(20) DEFAULT NULL,
  `snmpmemdetlminimumswap` bigint(20) DEFAULT NULL,
  `snmpmemdetlbuffer` bigint(20) DEFAULT NULL,
  `snmpmemdetlcached` bigint(20) DEFAULT NULL,
  `snmpmemdetlswaperror` bigint(20) DEFAULT NULL,
  `snmpmemdetlswaperrormsg` varchar(255) DEFAULT NULL,
  `snmpmemdetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmpmemdetlrecdid`),
  UNIQUE KEY `snmpmemdetlneid` (`snmpmemdetlneid`,`snmpmemdetlagentid`,`snmpmemdetlindex`,`snmpmemdetlpolledtimestamp`),
  KEY `snmpmemdetlagentid` (`snmpmemdetlagentid`),
  CONSTRAINT `snmpmemorydetails_ibfk_1` FOREIGN KEY (`snmpmemdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmpmemorydetails_ibfk_2` FOREIGN KEY (`snmpmemdetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6783 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmppolldetails` (
  `snmppollid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmppollneversionnumber` varchar(25) DEFAULT NULL,
  `snmppolldataimporterquerynumber` int(11) DEFAULT NULL,
  `snmppollintervalinseconds` int(11) DEFAULT NULL,
  `snmppollattribnames` text,
  `snmppollattriboids` text,
  `snmppolltype` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`snmppollid`),
  UNIQUE KEY `snmppollneversionnumber` (`snmppollneversionnumber`,`snmppolldataimporterquerynumber`),
  CONSTRAINT `snmppolldetails_ibfk_1` FOREIGN KEY (`snmppollneversionnumber`) REFERENCES `neversiondetails` (`neversionnumber`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmppollstatus` (
  `snmppollid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmppollschdledtag` bigint(20) DEFAULT NULL,
  `snmppollneid` bigint(20) DEFAULT NULL,
  `snmppollstatus` int(11) DEFAULT NULL,
  `snmppollstatusreason` varchar(255) DEFAULT NULL,
  `snmppollscheduledat` bigint(20) DEFAULT NULL,
  `snmppollinitiatedat` bigint(20) DEFAULT NULL,
  `snmppolldownloadedat` bigint(20) DEFAULT NULL,
  `snmppollupgradedat` bigint(20) DEFAULT NULL,
  `snmppollabortedat` bigint(20) DEFAULT NULL,
  `snmppollcreationtime` bigint(20) DEFAULT NULL,
  `snmppollmodifiedtime` bigint(20) DEFAULT NULL,
  `snmppollcreatedby` varchar(50) DEFAULT NULL,
  `snmppollmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`snmppollid`),
  UNIQUE KEY `snmppollschdledtag` (`snmppollschdledtag`,`snmppollneid`),
  KEY `snmppollneid` (`snmppollneid`),
  CONSTRAINT `snmppollstatus_ibfk_1` FOREIGN KEY (`snmppollneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmppollstatus_ibfk_2` FOREIGN KEY (`snmppollschdledtag`) REFERENCES `joboperationdetails` (`jobopdtlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23686194 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `insertonsnmppollstatus` BEFORE INSERT ON `snmppollstatus` FOR EACH ROW BEGIN
	IF EXISTS (SELECT * FROM snmppollstatus WHERE snmppollschdledtag = NEW.snmppollschdledtag AND snmppollneid = NEW.snmppollneid) THEN
		INSERT INTO snmppollstatushistory(snmppollschdledtag, snmppollneid, snmppollstatus, snmppollstatusreason, snmppollscheduledat, snmppollinitiatedat, snmppolldownloadedat, snmppollupgradedat, snmppollabortedat, snmppollcreationtime, snmppollmodifiedtime, snmppollcreatedby, snmppollmodifiedby) SELECT snmppollschdledtag, snmppollneid, snmppollstatus, snmppollstatusreason, snmppollscheduledat, snmppollinitiatedat, snmppolldownloadedat, snmppollupgradedat, snmppollabortedat, snmppollcreationtime, snmppollmodifiedtime, snmppollcreatedby, snmppollmodifiedby FROM snmppollstatus WHERE snmppollschdledtag = NEW.snmppollschdledtag AND snmppollneid = NEW.snmppollneid;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `updateonsnmppollstatus` BEFORE UPDATE ON `snmppollstatus` FOR EACH ROW BEGIN
	IF EXISTS (SELECT * FROM snmppollstatus WHERE snmppollschdledtag = NEW.snmppollschdledtag AND snmppollneid = NEW.snmppollneid) THEN
		IF (NEW.snmppollstatus = 1) THEN
			INSERT INTO snmppollstatushistory(snmppollschdledtag, snmppollneid, snmppollstatus, snmppollstatusreason, snmppollscheduledat, snmppollinitiatedat, snmppolldownloadedat, snmppollupgradedat, snmppollabortedat, snmppollcreationtime, snmppollmodifiedtime, snmppollcreatedby, snmppollmodifiedby) SELECT snmppollschdledtag, snmppollneid, snmppollstatus, snmppollstatusreason, snmppollscheduledat, snmppollinitiatedat, snmppolldownloadedat, snmppollupgradedat, snmppollabortedat, snmppollcreationtime, snmppollmodifiedtime, snmppollcreatedby, snmppollmodifiedby FROM snmppollstatus WHERE snmppollschdledtag = NEW.snmppollschdledtag AND snmppollneid = NEW.snmppollneid;
		END IF;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmppollstatushistory` (
  `snmppollid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmppollschdledtag` bigint(20) DEFAULT NULL,
  `snmppollneid` bigint(20) DEFAULT NULL,
  `snmppollstatus` int(11) DEFAULT NULL,
  `snmppollstatusreason` varchar(255) DEFAULT NULL,
  `snmppollscheduledat` bigint(20) DEFAULT NULL,
  `snmppollinitiatedat` bigint(20) DEFAULT NULL,
  `snmppolldownloadedat` bigint(20) DEFAULT NULL,
  `snmppollupgradedat` bigint(20) DEFAULT NULL,
  `snmppollabortedat` bigint(20) DEFAULT NULL,
  `snmppollcreationtime` bigint(20) DEFAULT NULL,
  `snmppollmodifiedtime` bigint(20) DEFAULT NULL,
  `snmppollcreatedby` varchar(50) DEFAULT NULL,
  `snmppollmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`snmppollid`),
  KEY `snmppollneid` (`snmppollneid`),
  KEY `snmppollschdledtag` (`snmppollschdledtag`),
  CONSTRAINT `snmppollstatushistory_ibfk_1` FOREIGN KEY (`snmppollneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmppollstatushistory_ibfk_2` FOREIGN KEY (`snmppollschdledtag`) REFERENCES `joboperationdetails` (`jobopdtlrecid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23686306 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `snmpsystemstatsdetails` (
  `snmpssdetlrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `snmpssdetlneid` bigint(20) DEFAULT NULL,
  `snmpssdetlagentid` bigint(20) DEFAULT NULL,
  `snmpssdetlindex` bigint(20) DEFAULT NULL,
  `snmpssdetlerrorname` varchar(255) DEFAULT NULL,
  `snmpssdetlswapin` bigint(20) DEFAULT NULL,
  `snmpssdetlswapout` bigint(20) DEFAULT NULL,
  `snmpssdetliosent` bigint(20) DEFAULT NULL,
  `snmpssdetlioreceive` bigint(20) DEFAULT NULL,
  `snmpssdetlsysinterrupts` bigint(20) DEFAULT NULL,
  `snmpssdetlsyscontext` bigint(20) DEFAULT NULL,
  `snmpssdetlcpuuser` bigint(20) DEFAULT NULL,
  `snmpssdetlcpusystem` bigint(20) DEFAULT NULL,
  `snmpssdetlcpuidle` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawuser` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawnice` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawsystem` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawidle` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawwait` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawkernel` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawinterrupt` bigint(20) DEFAULT NULL,
  `snmpssdetliorawsent` bigint(20) DEFAULT NULL,
  `snmpssdetliorawreceived` bigint(20) DEFAULT NULL,
  `snmpssdetlrawinterrupts` bigint(20) DEFAULT NULL,
  `snmpssdetlrawcontexts` bigint(20) DEFAULT NULL,
  `snmpssdetlcpurawsoftirq` bigint(20) DEFAULT NULL,
  `snmpssdetlrawswapin` bigint(20) DEFAULT NULL,
  `snmpssdetlrawswapout` bigint(20) DEFAULT NULL,
  `snmpssdetlpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`snmpssdetlrecdid`),
  UNIQUE KEY `snmpssdetlneid` (`snmpssdetlneid`,`snmpssdetlagentid`,`snmpssdetlindex`,`snmpssdetlpolledtimestamp`),
  KEY `snmpssdetlagentid` (`snmpssdetlagentid`),
  CONSTRAINT `snmpsystemstatsdetails_ibfk_1` FOREIGN KEY (`snmpssdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `snmpsystemstatsdetails_ibfk_2` FOREIGN KEY (`snmpssdetlagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=540070 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `specificdetails` (
  `specdetneid` bigint(20) NOT NULL,
  `specdetagentid` bigint(20) NOT NULL,
  `specdetsdname` varchar(25) NOT NULL,
  `specdetsdval` varchar(25) DEFAULT NULL,
  `specdetsdcreationtime` bigint(20) DEFAULT '0',
  `specdetsdmodifiedtime` bigint(20) DEFAULT '0',
  `specdetsdcreatedby` varchar(50) DEFAULT NULL,
  `specdetsdmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`specdetneid`,`specdetagentid`,`specdetsdname`),
  KEY `specdetagentid` (`specdetagentid`),
  CONSTRAINT `specificdetails_ibfk_1` FOREIGN KEY (`specdetneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `specificdetails_ibfk_2` FOREIGN KEY (`specdetagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `specificproblems` (
  `specificproblemid` int(11) NOT NULL AUTO_INCREMENT,
  `specificproblemname` varchar(506) DEFAULT NULL,
  `specificproblemdesc` text,
  PRIMARY KEY (`specificproblemid`),
  UNIQUE KEY `specificproblemname` (`specificproblemname`)
) ENGINE=InnoDB AUTO_INCREMENT=38003 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationaddress` (
  `stationadrsrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `stationadrsstationid` bigint(20) DEFAULT NULL,
  `stationadrsfilename` varchar(250) DEFAULT NULL,
  `stationadrsdesc` text,
  `stationadrsadminsts` tinyint(4) DEFAULT NULL,
  `stationadrscreatedtime` bigint(20) DEFAULT '0',
  `stationadrsmodifiedtime` bigint(20) DEFAULT '0',
  `stationadrscreatedby` varchar(50) DEFAULT NULL,
  `stationadrsmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationadrsrecid`),
  KEY `stationadrsstationid_ibkid` (`stationadrsstationid`),
  CONSTRAINT `stationadrsstationid_ibkid` FOREIGN KEY (`stationadrsstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationalarmconfig` (
  `stationalrmcfgid` int(11) NOT NULL,
  `stationalrmcfgstationid` bigint(20) DEFAULT NULL,
  `stationalrmcfgemail` int(11) DEFAULT '0',
  `stationalrmcfgsms` int(11) DEFAULT '0',
  `stationalrmcfgtrap` int(11) DEFAULT '0',
  `stationalrmcfgcreationtime` bigint(20) DEFAULT '0',
  `stationalrmcfgmodifiedtime` bigint(20) DEFAULT '0',
  `stationalrmcfgcreatedby` varchar(50) DEFAULT NULL,
  `stationalrmcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationalrmcfgid`),
  UNIQUE KEY `stationalrmcfgstationid` (`stationalrmcfgstationid`),
  CONSTRAINT `stationalarmconfig_ibfk_1` FOREIGN KEY (`stationalrmcfgstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationalarmemailconfig` (
  `stationalrmemailcfgid` int(11) NOT NULL AUTO_INCREMENT,
  `stationalrmemailcfgalarmid` int(11) DEFAULT NULL,
  `stationalrmemailcfgcritical` int(11) DEFAULT '0',
  `stationalrmemailcfgcriticalemails` text,
  `stationalrmemailcfgmajor` int(11) DEFAULT '0',
  `stationalrmemailcfgmajoremails` text,
  `stationalrmemailcfgminor` int(11) DEFAULT '0',
  `stationalrmemailcfgminoremails` text,
  `stationalrmemailcfgwarning` int(11) DEFAULT '0',
  `stationalrmemailcfgwarningemails` text,
  `stationalrmemailcfgcreationtime` bigint(20) DEFAULT '0',
  `stationalrmemailcfgmodifiedtime` bigint(20) DEFAULT '0',
  `stationalrmemailcfgcreatedby` varchar(50) DEFAULT NULL,
  `stationalrmemailcfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationalrmemailcfgid`),
  UNIQUE KEY `stationalrmemailcfgalarmid` (`stationalrmemailcfgalarmid`),
  CONSTRAINT `stationalarmemailconfig_ibfk_1` FOREIGN KEY (`stationalrmemailcfgalarmid`) REFERENCES `stationalarmconfig` (`stationalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationalarmsmsconfig` (
  `stationalrmsmscfgid` int(11) NOT NULL AUTO_INCREMENT,
  `stationalrmsmscfgalarmid` int(11) DEFAULT NULL,
  `stationalrmsmscfgcritical` int(11) DEFAULT '0',
  `stationalrmsmscfgcriticalnumbers` text,
  `stationalrmsmscfgmajor` int(11) DEFAULT '0',
  `stationalrmsmscfgmajornumbers` text,
  `stationalrmsmscfgminor` int(11) DEFAULT '0',
  `stationalrmsmscfgminornumbers` text,
  `stationalrmsmscfgwarning` int(11) DEFAULT '0',
  `stationalrmsmscfgwarningnumbers` text,
  `stationalrmsmscfgcreationtime` bigint(20) DEFAULT '0',
  `stationalrmsmscfgmodifiedtime` bigint(20) DEFAULT '0',
  `stationalrmsmscfgcreatedby` varchar(50) DEFAULT NULL,
  `stationalrmsmscfgmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationalrmsmscfgid`),
  UNIQUE KEY `stationalrmsmscfgalarmid` (`stationalrmsmscfgalarmid`),
  CONSTRAINT `stationalarmsmsconfig_ibfk_1` FOREIGN KEY (`stationalrmsmscfgalarmid`) REFERENCES `stationalarmconfig` (`stationalrmcfgid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationdetails` (
  `stationid` bigint(20) NOT NULL,
  `stationname` varchar(30) NOT NULL,
  `stationshortname` varchar(20) NOT NULL,
  `stationtype` enum('SIDE ELEVATED','ISLAND','SIDE','ISLAND ELEVATED') DEFAULT NULL,
  `stationaddress1` varchar(100) DEFAULT NULL,
  `stationaddress2` varchar(100) DEFAULT NULL,
  `stationneighbourhood` varchar(50) DEFAULT NULL,
  `stationcity` varchar(50) DEFAULT NULL,
  `stationstate` varchar(50) DEFAULT NULL,
  `stationcountry` varchar(50) DEFAULT NULL,
  `stationpincode` varchar(10) DEFAULT NULL,
  `stationpersonname` varchar(100) DEFAULT NULL,
  `stationmobilenumber` varchar(15) DEFAULT NULL,
  `stationphonenumber` varchar(15) DEFAULT NULL,
  `stationemail` varchar(255) DEFAULT NULL,
  `stationlat` double DEFAULT NULL,
  `stationlong` double DEFAULT NULL,
  `stationdesc` text,
  `stationplatforms` int(11) DEFAULT NULL,
  `stationgroupid` bigint(20) DEFAULT NULL,
  `stationcreationtime` bigint(20) DEFAULT '0',
  `stationmodifiedtime` bigint(20) DEFAULT '0',
  `stationcreatedby` varchar(50) DEFAULT NULL,
  `stationmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationid`),
  UNIQUE KEY `stationname` (`stationname`),
  UNIQUE KEY `stationshortname` (`stationshortname`),
  KEY `stationgroupid` (`stationgroupid`),
  CONSTRAINT `stationdetails_ibfk_1` FOREIGN KEY (`stationgroupid`) REFERENCES `groupdetails` (`groupid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`%`*/ /*!50003 TRIGGER `insertplatformdetailsafterinsertstation` AFTER INSERT ON `stationdetails` FOR EACH ROW BEGIN
	SET @i = 0;
	SET @id = NEW.stationid;
	SET @creationtime = NEW.stationcreationtime;
	SET @createdby = NEW.stationcreatedby;
	SET @stationtype = NEW.stationtype;
	SELECT MAX(platformid) INTO @i FROM platformdetails;
	SET @i = @i + 1;
	INSERT INTO platformdetails(platformid, platformname, platformshortname, platformdirection, platformlrvids, platformstationid, platformcreationtime, platformcreatedby) VALUES(@i, 'Up Platform', 'Up Platform', 'UP', @i, @id, @creationtime, @createdby);
	SET @i = @i + 1;
	INSERT INTO platformdetails(platformid, platformname, platformshortname, platformdirection, platformlrvids, platformstationid, platformcreationtime, platformcreatedby) VALUES(@i, 'Down Platform', 'Down Platform', 'DOWN', @i, @id, @creationtime, @createdby);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`omcsuser`@`localhost`*/ /*!50003 TRIGGER `deletestationdetailsafterdeletepiksandmessage` AFTER DELETE ON `stationdetails` FOR EACH ROW BEGIN
SET @id = OLD.stationid;
SET @replacestationid = CONCAT(",", OLD.stationid, ",");
 IF EXISTS (SELECT * FROM advertisementdetails WHERE FIND_IN_SET(@id, advdetstationid)) THEN
                UPDATE advertisementdetails SET advdetpikid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', advdetstationid, ','), @replacestationid, ',')));
 END IF;
 
 IF EXISTS (SELECT * FROM emergencyrequestmessages WHERE FIND_IN_SET(@id, emrgncyreqmsgstationid)) THEN
                UPDATE emergencyrequestmessages SET emrgncyreqmsgstationid = TRIM(BOTH ',' FROM (SELECT REPLACE(CONCAT(',', emrgncyreqmsgstationid, ','), @replacestationid, ',')));
 END IF;
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationdistancedetails` (
  `standistdetrecid` bigint(20) NOT NULL,
  `standistdetsrcstationid` bigint(20) DEFAULT NULL,
  `standistdetdesstationid` bigint(20) DEFAULT NULL,
  `standistdetdistance` float DEFAULT NULL,
  `standistdetcreationtime` bigint(20) DEFAULT '0',
  `standistdetmodifiedtime` bigint(20) DEFAULT '0',
  `standistdetcreatedby` varchar(50) DEFAULT NULL,
  `standistdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`standistdetrecid`),
  UNIQUE KEY `stationdetailids` (`standistdetsrcstationid`,`standistdetdesstationid`),
  KEY `standistdetdesstationid` (`standistdetdesstationid`),
  CONSTRAINT `stationdistancedetails_ibfk_1` FOREIGN KEY (`standistdetsrcstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `stationdistancedetails_ibfk_2` FOREIGN KEY (`standistdetdesstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationlayoutdetails` (
  `stationlayoutdetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `stationlayoutdetlstationid` bigint(20) DEFAULT NULL,
  `stationlayoutdetlfileurl` varchar(512) DEFAULT NULL,
  `stationlayoutdetllayoutsize` varchar(50) DEFAULT NULL,
  `stationlayoutdetladminstate` int(11) DEFAULT NULL,
  `stationlayoutdetlcreationtime` bigint(20) DEFAULT '0',
  `stationlayoutdetlmodifiedtime` bigint(20) DEFAULT '0',
  `stationlayoutdetlcreatedby` varchar(50) DEFAULT NULL,
  `stationlayoutdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationlayoutdetlrecordid`),
  UNIQUE KEY `stationlayoutdetlfileurl` (`stationlayoutdetlfileurl`),
  KEY `stationlayoutdetlstationid` (`stationlayoutdetlstationid`),
  CONSTRAINT `stationlayoutdetails_ibfk_1` FOREIGN KEY (`stationlayoutdetlstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationorderdetails` (
  `stnordrdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `stnordrdetstationid` bigint(20) DEFAULT NULL,
  `stnordrdetstationupindx` int(4) DEFAULT NULL,
  `stnordrdetstationdownindx` int(4) DEFAULT NULL,
  `stnordrdetcreatedtime` bigint(20) DEFAULT '0',
  `stnordrdetmodifiedtime` bigint(20) DEFAULT '0',
  `stnordrdetcreatedby` varchar(50) DEFAULT NULL,
  `stnordrdetmodifiedby` varchar(50) DEFAULT NULL,
  `stnordrdetstationordid` bigint(10) DEFAULT NULL,
  PRIMARY KEY (`stnordrdetrecid`),
  KEY `stnordrdetstationid_ibfk_1` (`stnordrdetstationid`),
  CONSTRAINT `stnordrdetstationid_ibfk_1` FOREIGN KEY (`stnordrdetstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationparkingcost` (
  `stationprkcstrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `stationprkcststationid` bigint(20) DEFAULT NULL,
  `stationprkcstfilename` varchar(250) DEFAULT NULL,
  `stationprkcstdesc` text,
  `stationprkcstadminsts` tinyint(4) DEFAULT NULL,
  `stationprkcstcreatedtime` bigint(20) DEFAULT '0',
  `stationprkcstmodifiedtime` bigint(20) DEFAULT '0',
  `stationprkcstcreatedby` varchar(50) DEFAULT NULL,
  `stationprkcstmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stationprkcstrecid`),
  KEY `stationprkcststationid_ibkid` (`stationprkcststationid`),
  CONSTRAINT `stationprkcststationid_ibkid` FOREIGN KEY (`stationprkcststationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `stationpdfdetails` (
  `stsnpdfdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `stsnpdfdetname` varchar(250) DEFAULT NULL,
  `stsnpdfdetlangtype` int(11) DEFAULT '1',
  `stsnpdfdetfilename` varchar(250) DEFAULT NULL,
  `stsnpdfdetstationid` bigint(20) DEFAULT NULL,
  `stsnpdfdetdesc` text,
  `stsnpdfdetadminsts` tinyint(4) DEFAULT NULL,
  `stsnpdfdetcreatedtime` bigint(20) DEFAULT '0',
  `stsnpdfdetmodifiedtime` bigint(20) DEFAULT '0',
  `stsnpdfdetcreatedby` varchar(50) DEFAULT NULL,
  `stsnpdfdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`stsnpdfdetrecid`),
  KEY `stsnpdfdetstationid_ibfk_1` (`stsnpdfdetstationid`),
  CONSTRAINT `stsnpdfdetstationid_ibfk_1` FOREIGN KEY (`stsnpdfdetstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `subsystemdetails` (
  `subsystemdetlrecordid` bigint(20) NOT NULL,
  `subsystemdetlneid` bigint(20) DEFAULT NULL,
  `subsystemdetlagentid` bigint(20) DEFAULT NULL,
  `subsystemdetlname` varchar(100) DEFAULT NULL,
  `subsystemdetlidentifier` varchar(500) DEFAULT NULL,
  `subsystemdetladminstate` int(11) DEFAULT NULL,
  `subsystemdetlcreationtime` bigint(20) DEFAULT '0',
  `subsystemdetlmodifiedtime` bigint(20) DEFAULT '0',
  `subsystemdetlcreatedby` varchar(50) DEFAULT NULL,
  `subsystemdetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`subsystemdetlrecordid`),
  UNIQUE KEY `subsystemdetlneid` (`subsystemdetlneid`,`subsystemdetlname`),
  KEY `subsystemdetlname` (`subsystemdetlname`,`subsystemdetlidentifier`,`subsystemdetladminstate`,`subsystemdetlcreationtime`,`subsystemdetlmodifiedtime`),
  CONSTRAINT `subsystemdetails_ibfk_1` FOREIGN KEY (`subsystemdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `subsystemlayoutdetails` (
  `subsystemlayoutdetlrecordid` bigint(20) NOT NULL AUTO_INCREMENT,
  `subsystemlayoutdetlneid` bigint(20) DEFAULT NULL,
  `subsystemlayoutdetlagentid` bigint(20) DEFAULT NULL,
  `subsystemlayoutdetlsubsystemid` bigint(20) DEFAULT NULL,
  `subsystemlayoutdetlposition` varchar(50) DEFAULT NULL,
  `subsystemlayoutdetladminstate` int(11) DEFAULT NULL,
  `subsystemlayoutdetlcreationtime` bigint(20) DEFAULT '0',
  `subsystemlayoutdetlmodifiedtime` bigint(20) DEFAULT '0',
  `subsystemlayoutdetlcreatedby` varchar(32) DEFAULT NULL,
  `subsystemlayoutdetlmodifiedby` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`subsystemlayoutdetlrecordid`),
  KEY `subsystemlayoutdetlneid` (`subsystemlayoutdetlneid`),
  KEY `subsystemlayoutdetlagentid` (`subsystemlayoutdetlagentid`),
  KEY `subsystemlayoutdetlsubsystemid` (`subsystemlayoutdetlsubsystemid`),
  CONSTRAINT `subsystemlayoutdetails_ibfk_1` FOREIGN KEY (`subsystemlayoutdetlneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `subsystemlayoutdetails_ibfk_3` FOREIGN KEY (`subsystemlayoutdetlsubsystemid`) REFERENCES `subsystemdetails` (`subsystemdetlrecordid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `switch_utilization` (
  `ne` bigint(20) DEFAULT NULL,
  `agent` bigint(20) DEFAULT NULL,
  `port` bigint(20) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `inutilization` double DEFAULT NULL,
  `oututilization` double DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL,
  UNIQUE KEY `switch_utilization_index` (`ne`,`agent`,`port`,`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `switch_utilization_tmp` (
  `ne` bigint(20) DEFAULT NULL,
  `agent` bigint(20) DEFAULT NULL,
  `port` bigint(20) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `inutilization` double DEFAULT NULL,
  `oututilization` double DEFAULT NULL,
  `createdTime` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `switchportassociation` (
  `switchportassid` bigint(20) NOT NULL,
  `switchportassneid` bigint(20) DEFAULT NULL,
  `switchportassagentid` bigint(20) DEFAULT NULL,
  `switchportassportnumber` int(11) DEFAULT NULL,
  `switchportassporttype` int(11) DEFAULT NULL,
  `switchportassportcapacity` int(11) DEFAULT NULL,
  `switchportassused` int(11) DEFAULT NULL,
  `switchportassconnectedneid` bigint(20) DEFAULT NULL,
  `switchportassadminstate` int(11) DEFAULT NULL,
  `switchportasscreationtime` bigint(20) DEFAULT '0',
  `switchportassmodifiedtime` bigint(20) DEFAULT '0',
  `switchportasscreatedby` varchar(50) DEFAULT NULL,
  `switchportassmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`switchportassid`),
  KEY `switchportassneid` (`switchportassneid`),
  KEY `switchportassagentid` (`switchportassagentid`),
  KEY `switchportassconnectedneid` (`switchportassconnectedneid`),
  CONSTRAINT `switchportassociation_ibfk_1` FOREIGN KEY (`switchportassneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `switchportassociation_ibfk_2` FOREIGN KEY (`switchportassagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `switchportassociation_ibfk_3` FOREIGN KEY (`switchportassconnectedneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `threaddetails` (
  `threaddetlrecid` int(11) NOT NULL,
  `threaddetlmodulename` varchar(50) DEFAULT NULL,
  `threaddetlminthread` int(11) DEFAULT NULL,
  `threaddetlmaxthread` int(11) DEFAULT NULL,
  `threaddetlttl` int(11) DEFAULT NULL,
  `threaddetlpriority` int(11) DEFAULT '5',
  `threaddetlmisfiretype` int(11) DEFAULT '1',
  `threaddetlcreationtime` bigint(20) DEFAULT '0',
  `threaddetlmodifiedtime` bigint(20) DEFAULT '0',
  `threaddetlcreatedby` varchar(50) DEFAULT NULL,
  `threaddetlmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`threaddetlrecid`),
  UNIQUE KEY `threaddetlmodulename` (`threaddetlmodulename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `trainfaredetails` (
  `trnfardetrecid` bigint(20) NOT NULL,
  `trnfardetsrcstationid` bigint(20) DEFAULT NULL,
  `trnfardetdesstationid` bigint(20) DEFAULT NULL,
  `trnfardetcost` float DEFAULT NULL,
  `trnfardetadultcost` float DEFAULT NULL,
  `trnfardetmecardcost` float DEFAULT NULL,
  `trnfardetsutcost` float DEFAULT NULL,
  `trnfardetchildcost` float DEFAULT NULL,
  `trnfardetseniorcost` float DEFAULT NULL,
  `trnfardetstudentcost` float DEFAULT NULL,
  `trnfardetprioritycost` float DEFAULT NULL,
  `trnfardetcreationtime` bigint(20) DEFAULT '0',
  `trnfardetmodifiedtime` bigint(20) DEFAULT '0',
  `trnfardetcreatedby` varchar(50) DEFAULT NULL,
  `trnfardetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`trnfardetrecid`),
  UNIQUE KEY `platformstationid` (`trnfardetsrcstationid`,`trnfardetdesstationid`),
  KEY `trnfardetdesstationid` (`trnfardetdesstationid`),
  CONSTRAINT `trainfaredetails_ibfk_1` FOREIGN KEY (`trnfardetdesstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `trainfaredetails_ibfk_2` FOREIGN KEY (`trnfardetsrcstationid`) REFERENCES `stationdetails` (`stationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `traininformation` (
  `traininforecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `traininfolrvid` varchar(100) DEFAULT NULL,
  `traininfotopic` varchar(512) DEFAULT NULL,
  `traininfoxml` text,
  `traininfologtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`traininforecdid`),
  KEY `traininfolrvid` (`traininfolrvid`),
  KEY `traininfologtime` (`traininfologtime`),
  CONSTRAINT `traininformation_ibfk_1` FOREIGN KEY (`traininfolrvid`) REFERENCES `platformdetails` (`platformlrvids`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30645748 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `tspspolldetails` (
  `tspspdrecid` int(11) NOT NULL AUTO_INCREMENT,
  `tspspdneid` bigint(20) DEFAULT NULL,
  `tspspdagentid` bigint(20) DEFAULT NULL,
  `tspspdappearancetimestamp` bigint(20) DEFAULT NULL,
  `tspspdgravity` bigint(20) DEFAULT NULL,
  `tspspdtext` varchar(506) DEFAULT NULL,
  `tspspdpolledtimestamp` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`tspspdrecid`),
  UNIQUE KEY `tspspdneid` (`tspspdneid`,`tspspdagentid`,`tspspdpolledtimestamp`,`tspspdtext`,`tspspdappearancetimestamp`),
  KEY `tspspdagentid` (`tspspdagentid`),
  CONSTRAINT `tspspolldetails_ibfk_1` FOREIGN KEY (`tspspdneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tspspolldetails_ibfk_2` FOREIGN KEY (`tspspdagentid`) REFERENCES `agentdetails` (`agentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10737320 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `updateadvtstatistics` (
  `upadvstsrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `upadvstspikid` bigint(20) DEFAULT NULL,
  `upadvstsstarttime` bigint(20) DEFAULT '0',
  `upadvstsendtime` bigint(20) DEFAULT '0',
  `upadvstsflag` tinyint(4) DEFAULT NULL,
  `upadvstscreatedtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`upadvstsrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `updateadvtstatisticsdetails` (
  `upadvstsdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `upadvstsdetstid` bigint(20) DEFAULT NULL,
  `upadvstsdetadvtid` bigint(20) DEFAULT NULL,
  `upadvstsdetplycunt` bigint(20) DEFAULT NULL,
  `upadvstsdetduration` time DEFAULT NULL,
  `upadvstsdetcreatedtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`upadvstsdetrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `updateusagestatistics` (
  `upusgestsrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `upusgestspikid` bigint(20) DEFAULT NULL,
  `upusgestsstarttime` bigint(20) DEFAULT '0',
  `upusgestsendtime` bigint(20) DEFAULT '0',
  `upusgestsflag` tinyint(4) DEFAULT NULL,
  `upusgestsappstarrate` tinyint(4) DEFAULT NULL,
  `upusgestsappreview` text,
  `upusgestscreatedtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`upusgestsrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `updateusagestatisticsdetails` (
  `upusgestsdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `upusgestsdetstid` bigint(20) DEFAULT NULL,
  `upusgestsdetmenuid` bigint(20) DEFAULT NULL,
  `upusgestsdetsubmenuid` bigint(20) DEFAULT NULL,
  `upusgestsdetsubmenurating` bigint(20) DEFAULT NULL,
  `upusgestsdetsubmenureview` text,
  `upusgestsdetcreatedtime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`upusgestsdetrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userackedalarms` (
  `userackedalarmrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `userackedalarmid` bigint(20) DEFAULT NULL,
  `userackedalarmusername` varchar(50) DEFAULT NULL,
  `userackedalarmacktime` bigint(20) DEFAULT '0',
  `userackedalarmannotation` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`userackedalarmrecdid`)
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userackedalarmshistory` (
  `userackedalarmrecdid` bigint(20) NOT NULL AUTO_INCREMENT,
  `userackedalarmid` bigint(20) DEFAULT NULL,
  `userackedalarmusername` varchar(50) DEFAULT NULL,
  `userackedalarmacktime` bigint(20) DEFAULT '0',
  `userackedalarmannotation` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`userackedalarmrecdid`)
) ENGINE=InnoDB AUTO_INCREMENT=174 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userdefaultneprivileges` (
  `userdefneprvuserid` int(11) NOT NULL,
  `userdefneprvprofileid` int(11) NOT NULL,
  `userdefneprvcreationtime` bigint(20) DEFAULT '0',
  `userdefneprvmodifiedtime` bigint(20) DEFAULT '0',
  `userdefneprvcreatedby` varchar(50) DEFAULT NULL,
  `userdefneprvmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`userdefneprvuserid`,`userdefneprvprofileid`),
  KEY `userdefneprvprofileid` (`userdefneprvprofileid`),
  CONSTRAINT `userdefaultneprivileges_ibfk_1` FOREIGN KEY (`userdefneprvuserid`) REFERENCES `userdetails` (`userdetuserid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userdefaultneprivileges_ibfk_2` FOREIGN KEY (`userdefneprvprofileid`) REFERENCES `profiledetails` (`profileid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userdetails` (
  `userdetuserid` int(11) NOT NULL,
  `userdetloginname` varchar(32) DEFAULT NULL,
  `userdetpassword` text,
  `userdetauthmethod` int(11) DEFAULT '1',
  `userdetfirstname` varchar(64) DEFAULT NULL,
  `userdetlastname` varchar(64) DEFAULT NULL,
  `userdetemailid` varchar(254) DEFAULT NULL,
  `userdetphonenumber` varchar(15) DEFAULT NULL,
  `userdetmobilenumber` varchar(15) DEFAULT NULL,
  `userdetnote` varchar(250) DEFAULT NULL,
  `userdetadminstate` int(11) DEFAULT NULL,
  `userdetsystemuser` int(11) DEFAULT NULL,
  `userdetoprtypeid` int(11) DEFAULT NULL,
  `userdetcreationtime` bigint(20) DEFAULT '0',
  `userdetmodifiedtime` bigint(20) DEFAULT '0',
  `userdetcreatedby` varchar(50) DEFAULT NULL,
  `userdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`userdetuserid`),
  KEY `userdetoprtypeid` (`userdetoprtypeid`),
  CONSTRAINT `userdetails_ibfk_1` FOREIGN KEY (`userdetoprtypeid`) REFERENCES `operatortypes` (`oprtypeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userguiprivileges` (
  `userguiprvuserid` int(11) NOT NULL,
  `userguiprvappid` int(11) NOT NULL,
  `userguiprvappreadaccess` int(11) DEFAULT NULL,
  `userguiprvappwriteaccess` int(11) DEFAULT NULL,
  `userguiprvcreationtime` bigint(20) DEFAULT '0',
  `userguiprvmodifiedtime` bigint(20) DEFAULT '0',
  `userguiprvcreatedby` varchar(50) DEFAULT NULL,
  `userguiprvmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`userguiprvuserid`,`userguiprvappid`),
  KEY `userguiprvappid` (`userguiprvappid`),
  CONSTRAINT `userguiprivileges_ibfk_1` FOREIGN KEY (`userguiprvuserid`) REFERENCES `userdetails` (`userdetuserid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userguiprivileges_ibfk_2` FOREIGN KEY (`userguiprvappid`) REFERENCES `guiapplicationdetails` (`guiappid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userneprivileges` (
  `userneprvuserid` int(11) NOT NULL,
  `userneprvneid` bigint(20) NOT NULL,
  `userneprvprofileid` int(11) DEFAULT NULL,
  `userneprvcreationtime` bigint(20) DEFAULT '0',
  `userneprvmodifiedtime` bigint(20) DEFAULT '0',
  `userneprvcreatedby` varchar(50) DEFAULT NULL,
  `userneprvmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`userneprvuserid`,`userneprvneid`),
  KEY `userneprvneid` (`userneprvneid`),
  KEY `userneprvprofileid` (`userneprvprofileid`),
  CONSTRAINT `userneprivileges_ibfk_1` FOREIGN KEY (`userneprvuserid`) REFERENCES `userdetails` (`userdetuserid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userneprivileges_ibfk_2` FOREIGN KEY (`userneprvneid`) REFERENCES `nedetails` (`neid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `userneprivileges_ibfk_3` FOREIGN KEY (`userneprvprofileid`) REFERENCES `profiledetails` (`profileid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `weatherdetails` (
  `weatherdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `weatherdeturl` varchar(250) DEFAULT NULL,
  `weatherdetadminsts` tinyint(4) DEFAULT NULL,
  `weatherdetcreatedtime` bigint(20) DEFAULT '0',
  `weatherdetmodifiedtime` bigint(20) DEFAULT '0',
  `weatherdetcreatedby` varchar(50) DEFAULT NULL,
  `weatherdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`weatherdetrecid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `webappdocdetails` (
  `webappdocdetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `webappdocdetname` varchar(250) DEFAULT NULL,
  `webappdocdetfilename` varchar(250) DEFAULT NULL,
  `webappdocdetdesc` text,
  `webappdocdetadminsts` tinyint(4) DEFAULT NULL,
  `webappdocdetcreatedtime` bigint(20) DEFAULT '0',
  `webappdocdetmodifiedtime` bigint(20) DEFAULT '0',
  `webappdocdetcreatedby` varchar(50) DEFAULT NULL,
  `webappdocdetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`webappdocdetrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `webappgallerydetails` (
  `webappglrydetrecid` bigint(20) NOT NULL AUTO_INCREMENT,
  `webappglrydetname` varchar(250) DEFAULT NULL,
  `webappglrydetfilename` varchar(250) DEFAULT NULL,
  `webappglrydetdesc` text,
  `webappglrydetadminsts` tinyint(4) DEFAULT NULL,
  `webappglrydetcreatedtime` bigint(20) DEFAULT '0',
  `webappglrydetmodifiedtime` bigint(20) DEFAULT '0',
  `webappglrydetcreatedby` varchar(50) DEFAULT NULL,
  `webappglrydetmodifiedby` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`webappglrydetrecid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
