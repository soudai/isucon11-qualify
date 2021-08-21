DROP TABLE IF EXISTS `isu_association_config`;
DROP TABLE IF EXISTS `isu_condition`;
DROP TABLE IF EXISTS `isu`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `latest_isu_condition_id`;
DROP TRIGGER IF EXISTS `tr1`;

CREATE TABLE `isu` (
  `id` bigint AUTO_INCREMENT,
  `jia_isu_uuid` CHAR(36) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `image` LONGBLOB,
  `character` VARCHAR(255),
  `jia_user_id` VARCHAR(255) NOT NULL,
  `created_at` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
   PRIMARY KEY(`id`),
  INDEX idx_character (`character`),
  INDEX idx_jiauserid (jia_user_id)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

CREATE TABLE `isu_condition` (
  `id` bigint AUTO_INCREMENT,
  `jia_isu_uuid` CHAR(36) NOT NULL,
  `timestamp` DATETIME NOT NULL,
  `is_sitting` TINYINT(1) NOT NULL,
  `condition` VARCHAR(255) NOT NULL,
  `message` VARCHAR(255) NOT NULL,
  `created_at` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6),
  `is_dirty` tinyint AS (CASE WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(`condition`, ',', 1), ',', -1), '=', -1) = 'true' THEN 1 ELSE 0 END),
  `is_overweight` tinyint AS (CASE WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(`condition`, ',', 2), ',', -1), '=', -1) = 'true' THEN 1 ELSE 0 END),
  `is_broken` tinyint AS (CASE WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(`condition`, ',', 3), ',', -1), '=', -1) = 'true' THEN 1 ELSE 0 END),
  `score` tinyint AS (CASE is_dirty + is_overweight + is_broken WHEN 3 THEN 1 WHEN 0 THEN 3 ELSE 2 END),
  PRIMARY KEY(`id`),
  INDEX idx_jiaisuuuid_timestamp (`jia_isu_uuid`, `timestamp`),
  INDEX idx_jiaisuuuid (`jia_isu_uuid`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

CREATE TABLE `user` (
  `jia_user_id` VARCHAR(255) PRIMARY KEY,
  `created_at` DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

CREATE TABLE `isu_association_config` (
  `name` VARCHAR(255) PRIMARY KEY,
  `url` VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

CREATE TABLE latest_isu_condition_id (
  id bigint,
  jia_isu_uuid CHAR(36),
  PRIMARY KEY(jia_isu_uuid)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

CREATE TRIGGER tr1 AFTER INSERT ON isu_condition FOR EACH ROW
  REPLACE INTO latest_isu_condition_id (id, jia_isu_uuid) VALUES (NEW.id, NEW.jia_isu_uuid);

CREATE OR REPLACE VIEW `latest_isu_condition` AS (
select `isu_condition`.`id` AS `id`,`isu_condition`.`jia_isu_uuid` AS `jia_isu_uuid`,`isu_condition`.`timestamp` AS `timestamp`,`isu_condition`.`is_sitting` AS `is_sitting`,`isu_condition`.`condition` AS `condition`,`isu_condition`.`message` AS `message`,`isu_condition`.`created_at` AS `created_at`
from (`isu_condition` join `latest_isu_condition_id` on(`isu_condition`.`id` = `latest_isu_condition_id`.`id`))
);

