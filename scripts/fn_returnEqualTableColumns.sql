
-----------------------------------------------------------------------------
-- INICIO: [dbo].[fn_ReturnIndexEqualStructure]
-----------------------------------------------------------------------------
IF OBJECT_ID ('dbo.fn_returnEqualTableColumns') IS NOT NULL
   DROP FUNCTION dbo.fn_returnEqualTableColumns
GO

CREATE FUNCTION dbo.fn_returnEqualTableColumns
(
   @chSourceTableName 			VARCHAR(1000) 
 , @chDestineTableName 			VARCHAR(1000) 
)
RETURNS VARCHAR(MAX)
	BEGIN
		DECLARE @columns_list VARCHAR(max)			



		RETURN @chIndexName
	END
GO

-- pega lista dinâmica de colunas das tabelas para inserção de dados
DECLARE @destination_column_list VARCHAR(max)
DECLARE @source_column_list VARCHAR(max)
DECLARE @sqlCommand NVARCHAR(MAX)

DECLARE
				  @chTableName VARCHAR(1000) = 'TActiveTypePhone'
				, @chColumnName VARCHAR(1000) = 'IdTypePhone'
				, @chOrderByColumns VARCHAR(MAX) = NULL
				, @chColumnType VARCHAR(100) = 'INT'

SET @sqlCommand =	N'SELECT @destination_column_list = COALESCE(@destination_column_list + '', '', '''') + D.COLUMN_NAME ' +
					'	,@source_column_list = COALESCE(@source_column_list + '', '', '''') + O.COLUMN_NAME ' +
					'FROM INFORMATION_SCHEMA.COLUMNS D ' +
					'INNER JOIN INFORMATION_SCHEMA.COLUMNS O ON O.COLUMN_NAME = D.COLUMN_NAME ' +
					'WHERE D.TABLE_NAME= ''' + @chTableName + ''' AND ' + ' O.TABLE_NAME= ''' + @chTableName + '''' 
			
--SELECT @sqlCommand AS '@sqlCommand'
		
EXECUTE sp_executesql @sqlCommand, N'@destination_column_list NVARCHAR(MAX) OUTPUT,@source_column_list NVARCHAR(MAX) OUTPUT', @destination_column_list = @destination_column_list OUTPUT, @source_column_list=@source_column_list OUTPUT

--SELECT @destination_column_list AS '@destination_column_list'
--SELECT @source_column_list AS '@source_column_list'

DECLARE @nuLastRowVersionImported [BINARY](8)  
	
-- busca qual foi a última linha copiada do voscenter a partir da coluna do tipo timestamp/rowversion
SELECT @nuLastRowVersionImported = nuLastRowVersionImported
FROM TControl_ETLDataImportExecution
WHERE ClientCode = @ClientCode AND chTableName = @chTableName 
			AND @chDataBaseName = chDataBaseName AND @nuTableETLType = FK_ETLTableType AND REPLACE(chImport2TableName,'dbo.','') = @DestinationStagingTable

SET @sqlCommand = ''			 
		