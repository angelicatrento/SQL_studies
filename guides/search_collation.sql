SELECT
dtb.name AS [Name],
dtb.database_id AS [ID],
CAST(case when dtb.name in ('master','model','msdb','tempdb') then 1 else dtb.is_distributor end AS bit) AS [IsSystemObject],
dtb.collation_name AS [Collation],
dtb.name AS [DatabaseName2]
FROM
master.sys.databases AS dtb
ORDER BY
[Name] ASC