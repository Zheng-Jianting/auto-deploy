drop database if exists autodeploy;
create database autodeploy;
use autodeploy;


drop table if exists user;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `created` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `last_login` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

insert into user values(1, 'root', 'e10adc3949ba59abbe56e057f20f883e', 'www.xxx.png', '374537202@qq.com', '2021-10-01 17:30:00', '2021-10-01 17:30:00', 'ACTIVE');



drop table if exists project;
CREATE TABLE `project` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `project_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into project values(1, 'Log4j', 'Log4j Description', 1);



drop table if exists deploy;
CREATE TABLE `deploy` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `application_name` varchar(255) NOT NULL,
  `server_id` bigint DEFAULT NULL,
  `cluster_id` bigint DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `directory` varchar(255) NOT NULL,
  `created` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `compression_format` varchar(255) NOT NULL,
  `is_execute` tinyint NOT NULL,
  `script_path` varchar(255) DEFAULT NULL,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `deploy_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into deploy values(1, 'Application 1', 1, null, 'SERVER', '/home/autodeploy', '2021-10-01 17:30:00', '.zip', '/home/autodeploy/Application 1/checkResult.txt', 1);



drop table if exists collect;
CREATE TABLE `collect` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deploy_id` bigint NOT NULL,
  `created` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `is_default` tinyint NOT NULL,
  `log_name` varchar(255) DEFAULT NULL,
  `use_case_name` varchar(255) DEFAULT NULL,
  `project_id` bigint NOT NULL,
  `is_build` tinyint,
  PRIMARY KEY (`id`),
  KEY `deploy_id` (`deploy_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `collect_ibfk_1` FOREIGN KEY (`deploy_id`) REFERENCES `deploy` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `collect_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into collect values(1, 'Collect 1', 1, '2021-10-01 17:30:00', 1, 'Collect 1.txt', 'src/main/java/example', 1);



drop table if exists collect_package;
CREATE TABLE `collect_package` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `is_collect` tinyint NOT NULL,
  `project_id` bigint NOT NULL,
  `collect_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  KEY `collect_id` (`collect_id`),
  CONSTRAINT `collect_package_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `collect_package_ibfk_2` FOREIGN KEY (`collect_id`) REFERENCES `collect` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into collect_package values(1, 'org.apache.log4j.config', 1, 1, 1);



drop table if exists server;
CREATE TABLE `server` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `ip` varchar(255) NOT NULL,
  `port` bigint NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `is_default` tinyint NOT NULL,
  `project_id` bigint NOT NULL,
  `created` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `server_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into server values(1, '127.0.0.1', 22, 'root', '123456', 'CONNECTED', 0, 1, '2021-10-05 00:55:00');



drop table if exists collect_tool;
CREATE TABLE `collect_tool` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `directory` varchar(255) NOT NULL,
  `server_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `server_id` (`server_id`),
  CONSTRAINT `collect_tool_ibfk_1` FOREIGN KEY (`server_id`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into collect_tool values(1, 'log_agent.jar', '/home/autodeploy/collect_tool', 1);



drop table if exists cluster;
CREATE TABLE `cluster` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `project_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `cluster_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into cluster values(1, 'Cluster 1', 'Cluster 1 description', '2021-10-01 17:30:00', 1);



drop table if exists cluster_server;
CREATE TABLE `cluster_server` (
  `cluster_id` bigint NOT NULL,
  `server_id` bigint NOT NULL,
  PRIMARY KEY (`cluster_id`,`server_id`),
  KEY `server_id` (`server_id`),
  CONSTRAINT `cluster_server_ibfk_1` FOREIGN KEY (`cluster_id`) REFERENCES `cluster` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `cluster_server_ibfk_2` FOREIGN KEY (`server_id`) REFERENCES `server` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- insert into cluster_server values(1, 1);
