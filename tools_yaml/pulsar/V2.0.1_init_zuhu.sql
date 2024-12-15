CREATE TABLE IF not EXISTS `sys_tenant` (
  `id` bigint NOT NULL,
  `tenant_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '租户名称',
  `tenant_code` bigint DEFAULT NULL COMMENT '租户编码',
  `is_enable` bit(1) DEFAULT NULL COMMENT '是否启用 0 否 1 是',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `is_del` bit(1) DEFAULT NULL COMMENT '删除标识 0 未删除 1 已删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='租户信息表';


INSERT INTO `sys_tenant`(`id`, `tenant_name`, `tenant_code`, `is_enable`, `create_time`, `is_del`) VALUES (1, '数益工联', 1130021, b'1', '2022-01-11 11:30:28', b'0');
update sys_user set tenement_id='1130021';
update sys_resource set tenement_id='1130021';
update sys_role set tenement_id='1130021';
update sys_m_user_role set  tenement_id = '1130021' ;
update sys_m_role_resource set  tenement_id = '1130021' ;



-- 舒路杰报表新增资源
ALTER TABLE `sys_resource` ADD COLUMN `is_report` bit(1) NOT NULL DEFAULT false AFTER `id`;
ALTER TABLE `sys_resource` ADD COLUMN `report_url` varchar(255) NULL COMMENT '报表前端请求路径' AFTER `is_report`;