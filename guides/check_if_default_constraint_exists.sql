--------------------------------------------------------
-- VERIFICA SE CONSTRAINT DEFAULT EXISTE OU NAO E SE O VALOR DEFAULT EH O MESMO, SE NAO ALTERA CONSTRAINT
--------------------------------------------------------
IF NOT EXISTS( 
		SELECT  default_constraints.name/*,**/
		FROM sys.default_constraints
		INNER JOIN sys.all_columns ON all_columns.default_object_id = default_constraints.object_id
		WHERE all_columns.name = 'WeekDayMask' -- column name
			AND all_columns.OBJECT_ID = OBJECT_ID('TFileCopy_Schedule') -- table name
			AND default_constraints.definition = '((0))' -- default value
	)
	BEGIN
		ALTER TABLE [dbo].[TFileCopy_Schedule] ADD  CONSTRAINT [DF_TFileCopy_Schedule_WeekDayMask]  DEFAULT ((0)) FOR [WeekDayMask]
	END
GO

SELECT * FROM BDIMport_1_01_00_00.INFORMATION_SCHEMA.COLUMNS c
		INNER JOIN sys.default_constraints dc ON dc.parent_object_id = OBJECT_ID(c.TABLE_NAME)
		AND c.TABLE_NAME = 'TActiveMailingImportCustomSample'
		AND c.TABLE_CATALOG = 'BDIMport_1_01_00_00'
		AND c.COLUMN_NAME = 'datCreation'
		AND c.COLUMN_DEFAULT = '(GETDATE())'
