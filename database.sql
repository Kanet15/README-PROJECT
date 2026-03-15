-- ส่วนที่ 1: สร้างและเลือกฐานข้อมูล
CREATE DATABASE IF NOT EXISTS `roomkub_prod`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `roomkub_prod`;

-- ส่วนที่ 2: สร้างตารางหลัก
CREATE TABLE IF NOT EXISTS `role` (
  `role_id` INT AUTO_INCREMENT PRIMARY KEY,
  `role_name` VARCHAR(191) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(191) NOT NULL,
  `password_hash` VARCHAR(191) NOT NULL,
  `role_id` INT NOT NULL,
  CONSTRAINT `USER_role_id_fkey`
    FOREIGN KEY (`role_id`) REFERENCES `role`(`role_id`),
  CONSTRAINT `USER_username_key` UNIQUE (`username`),
  INDEX `USER_role_id_fkey` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `room` (
  `room_id` INT AUTO_INCREMENT PRIMARY KEY,
  `room_number` VARCHAR(191) NOT NULL,
  `floor` INT NOT NULL,
  `price` DECIMAL(65,30) NOT NULL,
  `status` ENUM('Vacant','Occupied','Maintenance') NOT NULL,
  `room_type` ENUM('Air','Fan','Standard','Other') NOT NULL DEFAULT 'Standard',
  CONSTRAINT `ROOM_room_number_key` UNIQUE (`room_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `utility_rate` (
  `rate_id` INT AUTO_INCREMENT PRIMARY KEY,
  `water_rate` DECIMAL(65,30) NOT NULL,
  `electric_rate` DECIMAL(65,30) NOT NULL,
  `effective_date` DATETIME(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `billing_cycle` (
  `cycle_id` INT AUTO_INCREMENT PRIMARY KEY,
  `month` VARCHAR(191) NOT NULL,
  `due_date` DATETIME(3) NULL,
  `status` ENUM('Draft','Ready','Generated') NOT NULL DEFAULT 'Draft',
  `generated_count` INT NOT NULL DEFAULT 0,
  `generated_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT `BILLING_CYCLE_month_key` UNIQUE (`month`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `line_group` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `group_name` VARCHAR(191) NOT NULL,
  `group_id` VARCHAR(191) NOT NULL,
  `description` VARCHAR(191) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT `LINE_GROUP_group_id_key` UNIQUE (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `knowledge_base` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category` VARCHAR(191) NOT NULL,
  `topic` VARCHAR(191) NOT NULL,
  `question` TEXT NOT NULL,
  `answer` TEXT NOT NULL,
  `metadata_json` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX `KNOWLEDGE_BASE_category_idx` (`category`),
  INDEX `KNOWLEDGE_BASE_topic_idx` (`topic`),
  FULLTEXT INDEX `KNOWLEDGE_BASE_question_answer_ft_idx` (`question`, `answer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `knowledge_documents` (
  `id` VARCHAR(36) PRIMARY KEY,
  `doc_hash` VARCHAR(64) NOT NULL,
  `owner_id` INT NOT NULL,
  `doc_name` VARCHAR(255) NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'uploaded',
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT `KNOWLEDGE_DOCUMENTS_doc_hash_key` UNIQUE (`doc_hash`),
  INDEX `KNOWLEDGE_DOCUMENTS_owner_status_created_idx` (`owner_id`, `status`, `created_at`),
  INDEX `KNOWLEDGE_DOCUMENTS_status_updated_idx` (`status`, `updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `chatbot_conversation_log` (
  `log_id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_question` TEXT NOT NULL,
  `rewritten_query` TEXT NOT NULL,
  `retrieved_context` JSON NOT NULL,
  `final_answer` TEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX `CHATBOT_LOG_created_at_idx` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `tenant` (
  `tenant_id` INT AUTO_INCREMENT PRIMARY KEY,
  `tenant_code` VARCHAR(191) NULL,
  `user_id` INT NOT NULL,
  `full_name` VARCHAR(191) NOT NULL,
  `citizen_id` VARCHAR(191) NOT NULL,
  `phone` VARCHAR(191) NOT NULL,
  `start_date` DATETIME(3) NOT NULL,
  `room_id` INT NOT NULL,
  `line_id` VARCHAR(191) NULL,
  CONSTRAINT `TENANT_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  CONSTRAINT `TENANT_room_id_fkey` FOREIGN KEY (`room_id`) REFERENCES `room`(`room_id`),
  CONSTRAINT `TENANT_tenant_code_key` UNIQUE (`tenant_code`),
  CONSTRAINT `TENANT_user_id_key` UNIQUE (`user_id`),
  CONSTRAINT `TENANT_citizen_id_key` UNIQUE (`citizen_id`),
  CONSTRAINT `TENANT_phone_key` UNIQUE (`phone`),
  CONSTRAINT `TENANT_room_id_key` UNIQUE (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `audit_log` (
  `audit_log_id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `action` VARCHAR(191) NOT NULL,
  `entity` VARCHAR(191) NOT NULL,
  `entity_id` INT NOT NULL,
  `metadata` JSON NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT `AUDIT_LOG_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  INDEX `AUDIT_LOG_created_at_idx` (`created_at`),
  INDEX `AUDIT_LOG_user_id_idx` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `user_session` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `refresh_token_hash` VARCHAR(191) NOT NULL,
  `expires_at` DATETIME(3) NOT NULL,
  `revoked` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT `USER_SESSION_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  INDEX `USER_SESSION_expires_at_idx` (`expires_at`),
  INDEX `USER_SESSION_user_id_revoked_idx` (`user_id`, `revoked`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `meter` (
  `meter_id` INT AUTO_INCREMENT PRIMARY KEY,
  `room_id` INT NOT NULL,
  `month` VARCHAR(191) NOT NULL,
  `water_meter` DECIMAL(65,30) NOT NULL,
  `electric_meter` DECIMAL(65,30) NOT NULL,
  CONSTRAINT `METER_room_id_fkey` FOREIGN KEY (`room_id`) REFERENCES `room`(`room_id`),
  CONSTRAINT `METER_room_id_month_key` UNIQUE (`room_id`, `month`),
  INDEX `METER_room_id_fkey` (`room_id`),
  INDEX `METER_month_idx` (`month`),
  INDEX `METER_month_room_id_idx` (`month`, `room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bill` (
  `bill_id` INT AUTO_INCREMENT PRIMARY KEY,
  `room_id` INT NOT NULL,
  `tenant_id` INT NOT NULL,
  `month` VARCHAR(191) NOT NULL,
  `total_amount` DECIMAL(65,30) NOT NULL,
  `due_date` DATETIME(3) NOT NULL,
  `status` ENUM('Paid','Unpaid','Pending','Overdue','Cancelled') NOT NULL,
  `rate_id` INT NOT NULL,
  CONSTRAINT `BILL_room_id_fkey` FOREIGN KEY (`room_id`) REFERENCES `room`(`room_id`),
  CONSTRAINT `BILL_tenant_id_fkey` FOREIGN KEY (`tenant_id`) REFERENCES `tenant`(`tenant_id`),
  CONSTRAINT `BILL_rate_id_fkey` FOREIGN KEY (`rate_id`) REFERENCES `utility_rate`(`rate_id`),
  CONSTRAINT `BILL_room_id_month_key` UNIQUE (`room_id`, `month`),
  INDEX `BILL_rate_id_fkey` (`rate_id`),
  INDEX `BILL_room_id_fkey` (`room_id`),
  INDEX `BILL_tenant_id_fkey` (`tenant_id`),
  INDEX `BILL_status_due_date_idx` (`status`, `due_date`),
  INDEX `BILL_tenant_status_due_date_idx` (`tenant_id`, `status`, `due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `payment` (
  `payment_id` INT AUTO_INCREMENT PRIMARY KEY,
  `bill_id` INT NOT NULL,
  `payment_date` DATETIME(3) NOT NULL,
  `amount` DECIMAL(65,30) NOT NULL,
  `status` ENUM('Success','Pending','Failed','Verifying','Verified','Rejected','Expired') NOT NULL,
  `expires_at` DATETIME(3) NOT NULL,
  `expired_at` DATETIME(3) NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `slip_reference` VARCHAR(191) NULL,
  `slip_hash` VARCHAR(191) NULL,
  `slip_url` VARCHAR(191) NULL,
  `verified_at` DATETIME(3) NULL,
  `verification_source` VARCHAR(191) NULL,
  `raw_slip_data` JSON NULL,
  CONSTRAINT `PAYMENT_bill_id_fkey` FOREIGN KEY (`bill_id`) REFERENCES `bill`(`bill_id`),
  CONSTRAINT `PAYMENT_bill_id_key` UNIQUE (`bill_id`),
  CONSTRAINT `PAYMENT_slip_reference_key` UNIQUE (`slip_reference`),
  CONSTRAINT `PAYMENT_slip_hash_key` UNIQUE (`slip_hash`),
  INDEX `idx_payment_slip_reference` (`slip_reference`),
  INDEX `idx_payment_slip_hash` (`slip_hash`),
  INDEX `idx_payment_expires_at` (`expires_at`),
  INDEX `PAYMENT_status_payment_date_idx` (`status`, `payment_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `billing_draft` (
  `draft_id` INT AUTO_INCREMENT PRIMARY KEY,
  `room_id` INT NOT NULL,
  `tenant_id` INT NULL,
  `month` VARCHAR(191) NOT NULL,
  `due_date` DATETIME(3) NULL,
  `service_price` DECIMAL(65,30) NOT NULL DEFAULT 0,
  `fine_price` DECIMAL(65,30) NOT NULL DEFAULT 0,
  `include` BOOLEAN NOT NULL DEFAULT TRUE,
  `confirmed` BOOLEAN NOT NULL DEFAULT FALSE,
  `generated_at` DATETIME(3) NULL,
  `bill_id` INT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  CONSTRAINT `BILLING_DRAFT_room_id_fkey` FOREIGN KEY (`room_id`) REFERENCES `room`(`room_id`),
  CONSTRAINT `BILLING_DRAFT_tenant_id_fkey` FOREIGN KEY (`tenant_id`) REFERENCES `tenant`(`tenant_id`),
  CONSTRAINT `BILLING_DRAFT_bill_id_fkey` FOREIGN KEY (`bill_id`) REFERENCES `bill`(`bill_id`),
  CONSTRAINT `BILLING_DRAFT_room_id_month_key` UNIQUE (`room_id`, `month`),
  INDEX `BILLING_DRAFT_month_generated_at_idx` (`month`, `generated_at`),
  INDEX `BILLING_DRAFT_tenant_id_idx` (`tenant_id`),
  INDEX `BILLING_DRAFT_bill_id_idx` (`bill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `notification` (
  `notification_id` INT AUTO_INCREMENT PRIMARY KEY,
  `tenant_id` INT NOT NULL,
  `message` VARCHAR(191) NOT NULL,
  `sent_date` DATETIME(3) NOT NULL,
  `is_read` BOOLEAN NOT NULL DEFAULT FALSE,
  `read_at` DATETIME(3) NULL,
  CONSTRAINT `NOTIFICATION_tenant_id_fkey` FOREIGN KEY (`tenant_id`) REFERENCES `tenant`(`tenant_id`),
  INDEX `NOTIFICATION_tenant_id_fkey` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `notification_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `message` TEXT NOT NULL,
  `group_id` VARCHAR(191) NOT NULL,
  `group_name` VARCHAR(191) NOT NULL,
  `status` VARCHAR(191) NOT NULL,
  `error_message` TEXT NULL,
  `sent_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX `NOTIFICATION_HISTORY_sent_at_idx` (`sent_at`),
  INDEX `NOTIFICATION_HISTORY_status_sent_at_idx` (`status`, `sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `knowledge_chunks` (
  `chunk_id` VARCHAR(36) PRIMARY KEY,
  `doc_hash` VARCHAR(64) NOT NULL,
  `chunk_no` INT NOT NULL,
  `text` LONGTEXT NOT NULL,
  `embedding` JSON NULL,
  `metadata_json` JSON NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  CONSTRAINT `KNOWLEDGE_CHUNKS_doc_hash_fkey`
    FOREIGN KEY (`doc_hash`) REFERENCES `knowledge_documents`(`doc_hash`),
  CONSTRAINT `KNOWLEDGE_CHUNKS_doc_hash_chunk_no_key` UNIQUE (`doc_hash`, `chunk_no`),
  INDEX `KNOWLEDGE_CHUNKS_doc_hash_idx` (`doc_hash`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ส่วนที่ 3: สร้าง Views รายงาน (10 Views)
DROP VIEW IF EXISTS `vw_monthly_revenue_summary`;
CREATE VIEW `vw_monthly_revenue_summary` AS
SELECT
  b.`month` AS `bill_month`,
  COUNT(*) AS `total_bills`,
  SUM(CAST(b.`total_amount` AS DECIMAL(12, 2))) AS `total_billed_amount`,
  SUM(
    CASE
      WHEN LOWER(COALESCE(b.`status`, '')) = 'paid'
        OR LOWER(COALESCE(p.`status`, '')) IN ('success', 'verified')
      THEN CAST(b.`total_amount` AS DECIMAL(12, 2))
      ELSE 0
    END
  ) AS `total_collected_amount`
FROM `bill` b
LEFT JOIN `payment` p ON p.`bill_id` = b.`bill_id`
GROUP BY b.`month`;

DROP VIEW IF EXISTS `vw_unpaid_summary_by_month`;
CREATE VIEW `vw_unpaid_summary_by_month` AS
SELECT
  b.`month` AS `bill_month`,
  COUNT(*) AS `unpaid_bill_count`,
  SUM(CAST(b.`total_amount` AS DECIMAL(12, 2))) AS `unpaid_total_amount`
FROM `bill` b
WHERE LOWER(COALESCE(b.`status`, '')) IN ('unpaid', 'pending', 'overdue')
GROUP BY b.`month`;

DROP VIEW IF EXISTS `vw_overdue_bills_detail`;
CREATE VIEW `vw_overdue_bills_detail` AS
SELECT
  b.`bill_id`,
  b.`month` AS `bill_month`,
  r.`room_number`,
  t.`full_name` AS `tenant_name`,
  b.`due_date`,
  CAST(b.`total_amount` AS DECIMAL(12, 2)) AS `total_amount`,
  DATEDIFF(CURDATE(), DATE(b.`due_date`)) AS `overdue_days`
FROM `bill` b
JOIN `room` r ON r.`room_id` = b.`room_id`
JOIN `tenant` t ON t.`tenant_id` = b.`tenant_id`
WHERE LOWER(COALESCE(b.`status`, '')) = 'overdue';

DROP VIEW IF EXISTS `vw_payment_success_rate_monthly`;
CREATE VIEW `vw_payment_success_rate_monthly` AS
SELECT
  b.`month` AS `bill_month`,
  COUNT(*) AS `total_bills`,
  SUM(CASE WHEN LOWER(COALESCE(p.`status`, '')) IN ('success', 'verified') THEN 1 ELSE 0 END)
    AS `successful_payments`,
  ROUND(
    (
      SUM(CASE WHEN LOWER(COALESCE(p.`status`, '')) IN ('success', 'verified') THEN 1 ELSE 0 END)
      / NULLIF(COUNT(*), 0)
    ) * 100,
    2
  ) AS `success_rate_percent`
FROM `bill` b
LEFT JOIN `payment` p ON p.`bill_id` = b.`bill_id`
GROUP BY b.`month`;

DROP VIEW IF EXISTS `vw_room_occupancy_status`;
CREATE VIEW `vw_room_occupancy_status` AS
SELECT
  r.`room_id`,
  r.`room_number`,
  r.`floor`,
  r.`room_type`,
  COALESCE(t.`tenant_id`, 0) AS `tenant_id`,
  COALESCE(t.`full_name`, 'ห้องว่าง') AS `tenant_name`,
  CASE WHEN t.`tenant_id` IS NULL THEN 'vacant' ELSE 'occupied' END AS `occupancy_status`
FROM `room` r
LEFT JOIN `tenant` t ON t.`room_id` = r.`room_id`;

DROP VIEW IF EXISTS `vw_room_type_occupancy_summary`;
CREATE VIEW `vw_room_type_occupancy_summary` AS
SELECT
  r.`room_type`,
  COUNT(*) AS `total_rooms`,
  SUM(CASE WHEN t.`tenant_id` IS NOT NULL THEN 1 ELSE 0 END) AS `occupied_rooms`,
  SUM(CASE WHEN t.`tenant_id` IS NULL THEN 1 ELSE 0 END) AS `vacant_rooms`,
  ROUND(
    (
      SUM(CASE WHEN t.`tenant_id` IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)
    ) * 100,
    2
  ) AS `occupancy_rate_percent`
FROM `room` r
LEFT JOIN `tenant` t ON t.`room_id` = r.`room_id`
GROUP BY r.`room_type`;

DROP VIEW IF EXISTS `vw_water_usage_by_room_month`;
CREATE VIEW `vw_water_usage_by_room_month` AS
SELECT
  m.`room_id`,
  r.`room_number`,
  m.`month` AS `bill_month`,
  CAST(m.`water_meter` AS DECIMAL(12, 2)) AS `current_water_meter`,
  CAST(COALESCE(pm.`water_meter`, 0) AS DECIMAL(12, 2)) AS `previous_water_meter`,
  CAST(m.`water_meter` AS DECIMAL(12, 2)) - CAST(COALESCE(pm.`water_meter`, 0) AS DECIMAL(12, 2))
    AS `water_usage_units`
FROM `meter` m
JOIN `room` r ON r.`room_id` = m.`room_id`
LEFT JOIN `meter` pm ON pm.`room_id` = m.`room_id`
  AND pm.`month` = DATE_FORMAT(
    DATE_SUB(STR_TO_DATE(CONCAT(m.`month`, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
    '%Y-%m'
  );

DROP VIEW IF EXISTS `vw_electric_usage_by_room_month`;
CREATE VIEW `vw_electric_usage_by_room_month` AS
SELECT
  m.`room_id`,
  r.`room_number`,
  m.`month` AS `bill_month`,
  CAST(m.`electric_meter` AS DECIMAL(12, 2)) AS `current_electric_meter`,
  CAST(COALESCE(pm.`electric_meter`, 0) AS DECIMAL(12, 2)) AS `previous_electric_meter`,
  CAST(m.`electric_meter` AS DECIMAL(12, 2)) - CAST(COALESCE(pm.`electric_meter`, 0) AS DECIMAL(12, 2))
    AS `electric_usage_units`
FROM `meter` m
JOIN `room` r ON r.`room_id` = m.`room_id`
LEFT JOIN `meter` pm ON pm.`room_id` = m.`room_id`
  AND pm.`month` = DATE_FORMAT(
    DATE_SUB(STR_TO_DATE(CONCAT(m.`month`, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH),
    '%Y-%m'
  );

DROP VIEW IF EXISTS `vw_high_usage_alerts`;
CREATE VIEW `vw_high_usage_alerts` AS
SELECT
  w.`room_id`,
  w.`room_number`,
  w.`bill_month`,
  w.`water_usage_units`,
  e.`electric_usage_units`,
  CASE
    WHEN w.`water_usage_units` > 200 OR e.`electric_usage_units` > 500 THEN 'high'
    ELSE 'normal'
  END AS `usage_level`
FROM `vw_water_usage_by_room_month` w
JOIN `vw_electric_usage_by_room_month` e
  ON e.`room_id` = w.`room_id`
 AND e.`bill_month` = w.`bill_month`
WHERE w.`water_usage_units` > 200 OR e.`electric_usage_units` > 500;

DROP VIEW IF EXISTS `vw_notification_read_summary`;
CREATE VIEW `vw_notification_read_summary` AS
SELECT
  DATE(n.`sent_date`) AS `sent_day`,
  COUNT(*) AS `total_notifications`,
  SUM(CASE WHEN n.`is_read` = TRUE THEN 1 ELSE 0 END) AS `read_notifications`,
  SUM(CASE WHEN n.`is_read` = FALSE THEN 1 ELSE 0 END) AS `unread_notifications`,
  ROUND(
    (
      SUM(CASE WHEN n.`is_read` = TRUE THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0)
    ) * 100,
    2
  ) AS `read_rate_percent`
FROM `notification` n
GROUP BY DATE(n.`sent_date`);
