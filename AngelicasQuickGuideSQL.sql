--- =================================================================[
/*
					  Angelica's Quick Guide SQL
*/
--- =================================================================]

-- CREATE TABLE
CREATE TABLE [dbo].[TDimension_MetadataTables]
(
     [PK_TableID] [int] IDENTITY(1,1) NOT NULL
	,[TableName] [varchar] (255) NOT NULL
	,[Description] [varchar] (800) NOT NULL
	,[EffectiveDate] [datetime]  NOT NULL
 ,CONSTRAINT [PK_TDimension_MetadataTables] PRIMARY KEY CLUSTERED 
(
	[PK_TableID] ASC
)) ON [PRIMARY]

GO

CREATE TABLE [dbo].[TDimension_Date]
(
	 [PK_dateKey] [int] NOT NULL --PK 
	,[Date] [datetime] NOT NULL -- NK should it be a primary key? kimball's says that it should be a natural key and have a meaningless key as primary key
	,[DateFormatDDMMYYYY] [varchar](100) NOT NULL -- full date attribute
	,[DateFormatMMDDYYYY] [varchar](100) NULL -- full date attribute
	,[DateFormatYYYYMMDD] [varchar](10) NULL
	,[DateFormatYYYYMM] [varchar](10) NULL
	,[YearName] [varchar](100) NULL
	,[YearNumber] [int] NULL
	,[YearDatetime] [datetime] NULL
	,[QuarterName_pt_BR] [varchar](100) NULL
	,[QuarterName_en_US] [varchar](100) NULL
	,[QuarterName_es_MX] [varchar](100) NULL
	,[QuarterNumber] [int] NULL
	,[QuarterDatetime] [datetime] NULL
	,[MonthName_pt_BR] [varchar](50) NULL
	,[MonthName_en_US] [varchar](50) NULL
	,[MonthName_es_MX] [varchar](50) NULL
	,[MonthAbbrev_pt_BR] [varchar](10) NULL
	,[MonthAbbrev_en_US] [varchar](10) NULL
	,[MonthAbbrev_es_MX] [varchar](10) NULL
	,[MonthNumber] [int] NULL -- month in number 
	,[MonthDatetime] [datetime] NULL
	,[WeekInYearNumber] [int] NULL
	,[DayOfYear] [int] NULL
	,[DayOfMonth] [int] NULL
	,[DayOfWeek] [int] NULL
	,[DayOfWeek_pt_BR] [varchar](50) NULL
	,[DayOfWeek_en_US] [varchar](50) NULL
	,[DayOfWeek_es_MX] [varchar](50) NULL
	,[DayOfWeekAbbrev_pt_BR] [varchar](10) NULL
	,[DayOfWeekAbbrev_en_US] [varchar](10) NULL
	,[DayOfWeekAbbrev_es_MX] [varchar](10) NULL
	,[lastDayOfMonth] [bit] NOT NULL
	,[lastDayOfMonthDescr_pt_BR] [varchar] (100) NULL -- 'Último dia do mês'/'Não é fim do mês'
	,[lastDayOfMonthDescr_en_US] [varchar] (100) NULL -- 'Month End'/'Not Month End'
	,[lastDayOfMonthDescr_es_MX] [varchar] (100) NULL -- ''/''
	,[isWeekend] [bit] NOT NULL
	,[isWeekendDescr_pt_BR] [varchar] (50) NULL -- 'Dia útil'/ 'Final de semana'
	,[isWeekendDescr_en_US] [varchar] (50) NULL -- 'Week Day'/ 'Weekend'
	,[isWeekendDescr_es_MX] [varchar] (50) NULL -- ''/ ''
	,[YMD] [varchar] (10) NULL
	,[FK_TableID] [int] NOT NULL
 ,CONSTRAINT [PK_TDimension_Date] PRIMARY KEY CLUSTERED 
(
	[PK_dateKey] ASC
)) ON [PRIMARY]

GO

-- CREATE FOREIGN KEY
ALTER TABLE TDimension_Date 
ADD CONSTRAINT TDimension_Date_FK_TableID FOREIGN KEY ( FK_TableID ) REFERENCES TDimension_MetadataTables(PK_TableID)

-- DROP FOREIGN KEY
ALTER TABLE TDimension_Date DROP CONSTRAINT TDimension_Date_FK_TableID

-- DROP TABLE 
DROP TABLE [TDimension_MetadataTables]

-- RENAME TABLE,COLUMN and CONSTRAINTS
--EXEC sp_rename 'TDimension_DataType', 'TDimension_GenericFieldDataType';
--EXEC sp_RENAME 'TDimension_GenericFieldDataType.PK_FiscalMonth' , 'PK_FiscalDate', 'COLUMN'
--EXEC sp_RENAME 'PK_TDimension_DataType','PK_TDimension_GenericFieldDataType','OBJECT'

IF OBJECT_ID ('dbo.Table1', 'U') IS NOT NULL
    DROP TABLE dbo.Table1;
GO
IF OBJECT_ID ('dbo.Table2', 'U') IS NOT NULL
    DROP TABLE dbo.Table2;
GO
CREATE TABLE dbo.Table1 
    (ColA int NOT NULL, ColB decimal(10,3) NOT NULL);
GO
CREATE TABLE dbo.Table2 
    (ColA int PRIMARY KEY NOT NULL, ColB decimal(10,3) NOT NULL);
GO
INSERT INTO dbo.Table1 VALUES(1, 10.0), (1, 20.0);
INSERT INTO dbo.Table2 VALUES(1, 0.0);
GO
-- UPDATE -----------------------------------------------------
UPDATE dbo.Table2 
SET dbo.Table2.ColB = dbo.Table2.ColB + dbo.Table1.ColB
FROM dbo.Table2 
    INNER JOIN dbo.Table1 
    ON (dbo.Table2.ColA = dbo.Table1.ColA);
GO
---------------------------------------------------------------
SELECT ColA, ColB 
FROM dbo.Table2;

------------- CURSOR ------------------------------------------
IF OBJECT_ID ('dbo.Table1', 'U') IS NOT NULL
    DROP TABLE dbo.Table1;
GO
IF OBJECT_ID ('dbo.Table2', 'U') IS NOT NULL
    DROP TABLE dbo.Table2;
GO
CREATE TABLE dbo.Table1
    (c1 int PRIMARY KEY NOT NULL, c2 int NOT NULL);
GO
CREATE TABLE dbo.Table2
    (d1 int PRIMARY KEY NOT NULL, d2 int NOT NULL);
GO
INSERT INTO dbo.Table1 VALUES (1, 10);
INSERT INTO dbo.Table2 VALUES (1, 20), (2, 30);
GO
DECLARE abc CURSOR LOCAL FOR
    SELECT c1, c2 
    FROM dbo.Table1;
OPEN abc;
FETCH abc;
UPDATE dbo.Table1 
SET c2 = c2 + d2 
FROM dbo.Table2 
WHERE CURRENT OF abc;
GO
SELECT c1, c2 FROM dbo.Table1;
GO

-- https://msdn.microsoft.com/en-us//library/ms177523.aspx
----------------------------------------------------------------
--ALTER COLUMN DATATYPE
--ALTER TABLE dbo.YourTable
--ALTER COLUMN YourColumnName BIT

-- ALTER TABLE [TDimension_QueueType] DROP COLUMN [FK_TableID]
-- ALTER TABLE [TDimension_QueueType] ADD [QueueTypeDescr_en_US]  [varchar](100) NULL
-- ALTER TABLE [TDimension_QueueType] ADD [QueueTypeDescr_es_MX]  [varchar](100) NULL
-- ALTER TABLE [TDimension_QueueType] ADD [FK_TableID] [int] NOT NULL
-- EXEC sp_RENAME 'TDimension_QueueType.QueueTypeDescr' , 'QueueTypeDescr_pt_BR', 'COLUMN'
--ALTER TABLE TDimension_QueueType ALTER COLUMN [QueueTypeDescr_pt_BR] [varchar](100) NULL1

-- ALTER TABLE table_name DROP COLUMN column_name;
----------------------------------------------------------------
--Find Stored Procedure Related to Table in Database 
----------------------------------------------------------------
SELECT DISTINCT [Table Name] = o.Name, [Found In] = sp.Name, sp.type_desc
FROM sys.objects O INNER JOIN sys.sql_expression_dependencies  sd on o.object_id = sd.referenced_id
                inner join sys.objects sp on sd.referencing_id = sp.object_id
                    and sp.type in ('P', 'FN')
  where o.name = 'TGenericFieldData'
  order by sp.Name

  ----Option 1
SELECT DISTINCT so.name
FROM syscomments sc
INNER JOIN sysobjects so ON sc.id=so.id
WHERE sc.TEXT LIKE '%TGenericFieldData%'
----Option 2
SELECT DISTINCT o.name, o.xtype
FROM syscomments c
INNER JOIN sysobjects o ON c.id=o.id
WHERE c.TEXT LIKE '%FKIdFinishVoiceCallReason%'

  SELECT t.name AS table_name,
SCHEMA_NAME(schema_id) AS schema_name,
c.name AS column_name
FROM sys.tables AS t
INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
WHERE c.name LIKE '%FKIdFinishVoiceCallReason%'
ORDER BY schema_name, table_name;
--FKIdFinishVoiceCallReason

--------------------------------------------------------
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'MyProc')
--   exec('CREATE PROCEDURE [dbo].[MyProc] AS BEGIN SET NOCOUNT ON; END')
--GO

--ALTER PROCEDURE [dbo].[MyProc] 
--AS

---------------------------------
-- ALTERAR O NOME DE UMA BASE quando esta é multi_user ---
use master
ALTER DATABASE BOSEVIKRAM SET SINGLE_USER WITH ROLLBACK IMMEDIATE    
ALTER DATABASE BOSEVIKRAM MODIFY NAME = [BOSEVIKRAM_Deleted]
ALTER DATABASE BOSEVIKRAM_Deleted SET MULTI_USER
---------------------------------

-- How to return the date part only from a SQL Server datetime datatype
--On SQL Server 2008 and higher, you should convert to date:
--SELECT CONVERT(date, getdate())
--On older versions, you can do the following:

--SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, @your_date))
--for example

--SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))
--gives me

--2008-09-22 00:00:00.000
--Pros:

--No varchar<->datetime conversions required
--No need to think about locale

-- +1 Looks like this one is 35% faster than the double convert() method commonly used (which I also have used for years). Nice one.

-- checa se há primary key
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + CONSTRAINT_NAME), 'IsPrimaryKey') = 1
AND TABLE_NAME = 'TWebChatDialog' AND TABLE_SCHEMA = 'dbo'


IF NOT EXISTS(SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_NAME), 'IsPrimaryKey') = 1 AND TABLE_NAME = 'TWebChatDialog' AND COLUMN_NAME = 'rowid')
BEGIN
	SELECT 1
END
ELSE
BEGIN
	SELECT 2
END

SELECT object_definition(default_object_id) AS definition
FROM   sys.columns
WHERE  name      ='SessionId'
AND    object_id = object_id('dbo.TWebChatDialog')
SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'TWebChatDialog'
  AND COLUMN_NAME = 'FKGroupId'
-----------------------------
-- TESTE inserção de identity em tabela
-- que já tem dados --------
-----------------------------
CREATE TABLE TESTE
(
	nome VARCHAR(100), 
	equipe VARCHAR(100),
	numero INT

)


INSERT INTO TESTE(nome,equipe,numero) VALUES('a','equipe1',1)
INSERT INTO TESTE(nome,equipe,numero) VALUES('b','equipe1',1)
INSERT INTO TESTE(nome,equipe,numero) VALUES('c','equipe1',1)
INSERT INTO TESTE(nome,equipe,numero) VALUES('a','equipe2',2)
INSERT INTO TESTE(nome,equipe,numero) VALUES('b','equipe2',2)
INSERT INTO TESTE(nome,equipe,numero) VALUES('c','equipe2',2)
INSERT INTO TESTE(nome,equipe,numero) VALUES('m','equipe3',3)
INSERT INTO TESTE(nome,equipe,numero) VALUES('n','equipe3',3)
INSERT INTO TESTE(nome,equipe,numero) VALUES('o','equipe3',3)
INSERT INTO TESTE(nome,equipe,numero) VALUES('p','equipe3',3)
--SELECT * FROM TESTE
--DROP TABLE TESTE

ALTER TABLE TESTE ADD [rowid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL

INSERT INTO TESTE(nome,equipe,numero) VALUES('p','equipe3',3)

DROP TABLE TESTE


--------------------
-- testar busca string --
--------------------
CREATE TABLE #TEMP
(
	teste VARCHAR(100)
)

INSERT INTO #TEMP(
teste
)
VALUES(
	'bla.txt'
)

INSERT INTO #TEMP(
teste
)
VALUES(
	'bla.gz'
)

INSERT INTO #TEMP(
teste
)
VALUES(
	'gztest.xlxs'
)

SELECT UPPER(teste) ,teste FROM   #TEMP
WHERE UPPER(teste) NOT LIKE '%TXT%'    
OR UPPER(teste) LIKE '%GZ'    
OR teste IS NULL    


SELECT UPPER(teste) ,teste FROM   #TEMP
WHERE UPPER(teste) NOT LIKE '%TXT%'
OR teste IS NULL

-----------------------------------
-- data que uma tabela foi criada 
-----------------------------------
select so.name, so.crdate 
from 
    sysobjects so  where name = 'TVoxReportConsolidated_GroupAttendance_DEBUG'

select so.name, so.crdate,* 
from 
    sysobjects so  where name = 'spVoxReport_Incremental_TVoxReportConsolidated_GroupAttendance_Call'

select so.name, so.crdate 
from 
    sysobjects so  where name = 'TVoxReportConsolidated_GroupAttendance'

---------------------------------
-- checa tipo de dados de uma coluna ---
----------------------------------------
SELECT DATA_TYPE, *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = 'TCtiSimCard_Config' AND 
     COLUMN_NAME = 'dtChangeHour'

DECLARE @tn SYSNAME;

SELECT @tn = TYPE_NAME(system_type_id) 
FROM sys.columns 
WHERE name = 'dtChangeHour' 
AND [object_id] = OBJECT_ID('dbo.TCtiSimCard_Config');

IF @tn = N'time'
    SELECT 'time'

IF @tn = N'datetime'
    SELECT 'datetime'
-- ----------------------------------------------------------------------------------
-- INICIO - [TCtiSimCard_Config] - ALTER COLUMN [dtChangeHour]
-- ----------------------------------------------------------------------------------
-- DROP CONSTRAINT
IF EXISTS( SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TCtiSimCard_Config' )
	BEGIN
		IF EXISTS(SELECT * FROM SYS.COLUMNS WHERE name = 'dtChangeHour' AND [object_id] = OBJECT_ID('TCtiSimCard_Config'))
			BEGIN
				DECLARE @columnType SYSNAME;
	
				SELECT @columnType = TYPE_NAME(system_type_id) 
				FROM SYS.COLUMNS 
				WHERE name = 'dtChangeHour' 
					AND [object_id] = OBJECT_ID('dbo.TCtiSimCard_Config');

				IF @columnType = N'time'
					BEGIN
						ALTER TABLE TCtiSimCard_Config
						ALTER COLUMN dtChangeHour DATETIME NULL
					END
				--SELECT DATA_TYPE, * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TCtiSimCard_Config' AND COLUMN_NAME = 'dtChangeHour'
			END
		
	END
GO
-- ----------------------------------------------------------------------------------
-- FIM - [TCtiSimCard_Config] - ALTER COLUMN [dtChangeHour]
-- ----------------------------------------------------------------------------------


-----------------
-- INICIO
-- teste de tabela com foreign key
-- NOCHECK VS CHECK
-----------------
-- drop table t1
-- drop table t2
create table t1(i int not null, fk int not null)
create table t2(i int not null)
-- create primary key on t2
alter table t2
add constraint pk_1 primary key (i)
-- create foriegn key on t1
alter table t1
add constraint fk_1 foreign key (fk)
    references t2 (i)
--insert some records
insert t2 values(100)
insert t2 values(200)
insert t2 values(300)
insert t2 values(400)
insert t2 values(500)
insert t1 values(1,100)
insert t1 values(2,100)
insert t1 values(3,500)
insert t1 values(4,500)
----------------------------
-- 1. enabled and trusted
select name,is_disabled,is_not_trusted from sys.foreign_keys
GO
select name,is_disabled,is_not_trusted ,* from sys.foreign_keys where name = 'fk_1' and parent_object_id = OBJECT_ID('t1') --WHERE object_id = OBJECT_ID('dbo.t1')

SELECT * FROM t1
SELECT * FROM t2
select * from sys.foreign_keys  WHERE object_id = OBJECT_ID('t1')
-- 2. disable the constraint
alter table t1 NOCHECK CONSTRAINT fk_1
select name,is_disabled,is_not_trusted from sys.foreign_keys
GO
select name,is_disabled,is_not_trusted ,* from sys.foreign_keys where name = 'fk_1' and parent_object_id = OBJECT_ID('t1') --WHERE object_id = OBJECT_ID('dbo.t1')

-- 3. re-enable constraint, data isnt checked, so not trusted.
-- this means the optimizer will still have to check the column
alter table  t1 CHECK CONSTRAINT fk_1 
select name,is_disabled,is_not_trusted from sys.foreign_keys
GO
select name,is_disabled,is_not_trusted ,* from sys.foreign_keys where name = 'fk_1' and parent_object_id = OBJECT_ID('t1') --WHERE object_id = OBJECT_ID('dbo.t1')

--4. drop the foreign key constraint & re-add 
-- it making sure its checked
-- constraint is then enabled and trusted
alter table t1  DROP CONSTRAINT fk_1
alter table t1 WITH CHECK 
add constraint fk_1 foreign key (fk)
    references t2 (i)
select name,is_disabled,is_not_trusted from sys.foreign_keys
GO


--5. drop the foreign key constraint & add but dont check
-- constraint is then enabled, but not trusted
alter table t1  DROP CONSTRAINT fk_1
alter table t1 WITH NOCHECK 
add constraint fk_1 foreign key (fk)
    references t2 (i)
select name,is_disabled,is_not_trusted from sys.foreign_keys
GO
-----------------
-- FIM
-- teste de tabela com foreign key
-- NOCHECK VS CHECK
-----------------