----------------------------------------------------------------------------
-- INICIO: [dbo].[usp_addIdentityColumn]
----------------------------------------------------------------------------
IF OBJECT_ID('usp_createIndex','PROCEDURE') IS NOT NULL
	BEGIN
		DROP PROCEDURE usp_addIdentityColumn
	END
GO

CREATE PROCEDURE usp_addIdentityColumn
(
	  @chTableName VARCHAR(1000) -- Nome da tabela onde o indice sera criado. Ex: 'TActiveMailingOperation'
	, @chColumnName VARCHAR(1000) -- Script de criacao do indice
	, @chOrderByColumns VARCHAR(MAX) = NULL -- string com os campos na ordem do order by para inserção do campo identity
	, @chColumnType VARCHAR(100) = 'INT'
)
/*  
-- --------------------------------------------------------------------------  
-- PROCEDURE UTILIZADA PARA CONTROLE DE CRIACAO DE INDICES			  -------  
-- --------------------------------------------------------------------------  
-- --------------------------------------------------------------------------  
-- Procedimento: [dbo].[usp_addIdentityColumn]   
-- --------------------------------------------------------------------------  
	Data de criação.....................: 14/03/2017
	Autor...............................: Angelica Trento
	Objetivo do procedimento............: adicionar campo identity em tabela já
									existente.
								
	Demanda.............................: 12055  
	Solicitante.........................: Felipe Portuense Lima 
	ID Tarefa...........................: 59784
	Banco de execução do procedimento...: Voscenter
	Banco(s) envolvido(s)...............: Voscenter
	Parametros de saida.................: 
								Tabela com campo identity:
								- se campo identity tem o mesmo nome que campo existente na tabela, 
								  criar tabela com esse campo e re-inserir os dados com base no campo que já existe
								- se campo identity é um campo novo, criar tabela e inserir os dados conforme ordenação  
								  passada no parametro @chOrderByColumns

	*-------------------------------------------------------------------------------------------------------*
	|PARAMETROS			|VALOR DEFAULT |   TIPO   | OBRIGATÓRIO |DESCRIÇÃO									|
	| @chTableName		|	  N/A	   | VARCHAR  |		SIM		| Nome da tabela onde indice sera criado	|
	| @chColumnName		|	  N/A	   | VARCHAR  |		SIM		| nome da coluna a ser criada como identity	|
	*-------------------------------------------------------------------------------------------------------*
   
	Exemplos execução:
		EXEC usp_addIdentityColumn
								  @chTableName = 'TActiveTypePhone'
								, @chColumnName = 'IdTypePhone'
								, @chOrderByColumns = NULL 
								, @chColumnType = 'INT'

	-- ----------------------------------------------------------------------------------------------  
	-- Histórico  
	-- ----------------------------------------------------------------------------------------------   
		Data de alteração.................:   /  /      
		Autor.............................:   
		Tarefa que originou a alteração...:   
		Demanda...........................:   
		Solicitante.......................:   
	    Objetivo da alteração.............:   
	--------------------------------------------------------------------------------------------------   

*/  
AS
	BEGIN 
		
		-- TESTE INICIO

			DECLARE
				  @chTableName VARCHAR(1000) = 'TActiveTypePhone'
				, @chColumnName VARCHAR(1000) = 'IdTypePhone'
				, @chOrderByColumns VARCHAR(MAX) = NULL
				, @chColumnType VARCHAR(100) = 'INT'

		-- TESTE FIM
		SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @chColumnName AND TABLE_NAME = @chTableName
		SELECT * FROM sys.identity_columns where object_id = OBJECT_ID('TReportCDRDac') AND is_identity != 1 AND name = 'IdEvent'
		SELECT * FROM sys.columns where name = 'IdTypePhone' AND object_id = OBJECT_ID('TActiveTypePhone')

		 SELECT * FROM TReportCDRDac

		 DECLARE @tempTableName AS VARCHAR(MAX) = @chTableName + '_IdentityCopy_' + CONVERT(VARCHAR(10),GETDATE(),112)
		 DECLARE @originalTbRowCount AS INT = 0
		 DECLARE @tempTbRowCount AS INT = 0
		 DECLARE @sqlQuery AS NVARCHAR(MAX)
		 DECLARE @getColumns NVARCHAR(MAX)
		 DECLARE @destination_column_list VARCHAR(max)
		 DECLARE @source_column_list VARCHAR(max)

		-- Verifica se o nome da coluna identity a ser criada já existe na tabela 
		IF EXISTS (SELECT * FROM .INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @chTableName )
			BEGIN
				-- coluna existe com nome igual e não é identity
				IF EXISTS( SELECT * FROM SYS.COLUMNS 
						   WHERE NAME = @chColumnName 
								AND object_id = OBJECT_ID(@chTableName)
								AND is_identity = 0
						 )
					BEGIN
						DECLARE @column_type AS VARCHAR(100) 
						SELECT @column_type = DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @chColumnName AND TABLE_NAME = @chTableName

						-- criar tabela com esse campo e re-inserir os dados com base no campo que já existe
						-- criar copia da tabela que já existe
						IF NOT EXISTS(SELECT * FROM .INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tempTableName)
							BEGIN
								EXEC('SELECT * INTO ' + @tempTableName + ' FROM ' + @chTableName)

								-- quantidade de linhas tabela temporária criada
								SET @sqlQuery = 'SELECT @qtt = COUNT(*) FROM ' + @tempTableName
								
								EXEC SP_EXECUTESQL @sqlQuery, N'@qtt INT OUT',@tempTbRowCount OUT
								SET @sqlQuery = ''
								-- quantidade de linhas tabela original
								SET @sqlQuery = 'SELECT @qtt = COUNT(*) FROM ' + @chTableName
								
								EXEC SP_EXECUTESQL @sqlQuery, N'@qtt INT OUT',@originalTbRowCount OUT
								SET @sqlQuery = ''

								IF (@tempTbRowCount = @originalTbRowCount)
									BEGIN
										
										-- delete everything in the original table
										EXEC('DELETE FROM ' + @chTableName)

										EXEC('sp_rename ''' + @chTableName + '.' + @chColumnName + ''', ''' + @chColumnName + '_noIdentity'', ''COLUMN''')

										IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = @chColumnName AND TABLE_NAME = @chTableName)
											BEGIN
												
												EXEC(' ALTER TABLE ' + @chTableName + 
													 ' ADD ' + @chColumnName + ' ' + @column_type + ' IDENTITY(1,1) NOT NULL ')
												
												WAITFOR DELAY '00:00:01';  

												-- temporarily allow updating identity columns
												SET IDENTITY_INSERT TDatabaseConfig ON;
								
												-- copy data into the existing table from the copy of the existing table
												-- modify the select statement to put whatever you want in the identity column
												-- of course you can join to other tables etc to get the int for your id column
												INSERT INTO @chColumnName (
													 DatabaseVersion
													,UpdateScript
													,UpdateDate
													,BDType
													,chRequiredVOSCenterVersion
													,PK_DBVersion
												) 
												SELECT
													 DC.DatabaseVersion
													,DC.UpdateScript
													,DC.UpdateDate
													,DC.BDType
													,DC.chRequiredVOSCenterVersion
													,T.PK_DBVersion_RowNumber
												FROM TDatabaseConfig_temp DC
												INNER JOIN
												(
													SELECT DatabaseVersion, UpdateDate, ROW_NUMBER() OVER (ORDER BY [UpdateDate]) AS PK_DBVersion_RowNumber
													FROM TDatabaseConfig_temp
												 ) T ON T.UpdateDate = DC.UpdateDate AND T.DatabaseVersion = DC.DatabaseVersion

												-- prevent updating identity columns in future
												SET IDENTITY_INSERT TDatabaseConfig OFF

											END

										-- permite inserir dados na coluna identity 
										--SET IDENTITY_INSERT TDatabaseConfig ON;

									END
							END
						

					END
			END


		-- Verifica se o nome da coluna identity a ser criada já existe na tabela 
		EXEC
		('
			IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ''' + @chTableName + ' )
				BEGIN
					IF EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = ''' + @chColumnName + ''' AND TABLE_NAME = ''' + @chTableName + ' )
						BEGIN
							
			IF OBJECT_ID(''' + @chTableName + '_VERICA_INDICES'') IS NOT NULL 
				DROP TABLE ' + @chTableName + '_VERICA_INDICES
			SELECT TOP(0) * INTO ' + @chTableName + '_VERICA_INDICES FROM ' + @chTableName
		)

		DECLARE @chIndexName VARCHAR(100) -- Armazena nome do indice a ser criado
		DECLARE @chNewIndexStructure VARCHAR(MAX) -- Armazena a "estrutura" do indice a ser criado
		DECLARE @chIndexNameSameStructure VARCHAR(MAX) -- Armazena o nome do indice que possui a mesma "estrutura" que o indice a ser criado
		DECLARE @chDate VARCHAR(10) = CONVERT(VARCHAR(10),GETDATE(),112) -- Armazena a data do dia da execucao da procedure
		DECLARE @chCreationScriptReplace VARCHAR(MAX) 

		DECLARE @positionTableName_ON INT, @stringTableName_ON VARCHAR(10) = ' ON '
		DECLARE @positionTableName_Parenthesis INT, @stringTableName_Parenthesis VARCHAR(10) = '('

		SELECT @positionTableName_ON = CHARINDEX(@stringTableName_ON,@chCreationScript);
		SELECT @positionTableName_Parenthesis = CHARINDEX(@stringTableName_Parenthesis,@chCreationScript);

		-- create index 
		IF @positionTableName_ON > 0 
			BEGIN
				-- armazena tamanho da string a ser ignorado no replace: tudo depois do primeiro parenteses em CREATE INDEX [INDEX NAME] ON TABLE_NAME (column1, column2)
				DECLARE @lenAfterIndexTableName INT, @stringAfterIndexTableName VARCHAR(MAX)
				SELECT @stringAfterIndexTableName = SUBSTRING(@chCreationScript,@positionTableName_Parenthesis,LEN(@chCreationScript))
				SELECT @lenAfterIndexTableName = LEN(@stringAfterIndexTableName);
				DECLARE @tableName AS VARCHAR(MAX)
				-- Armazena script de criacao do indice com o nome da tabela "destino" alterado para a "temporaria"
				--SELECT @tableName = SUBSTRING(SUBSTRING(@chCreationScript, 1,@positionTableName_Parenthesis-1),@positionTableName_ON + LEN(RTRIM(LTRIM(@stringTableName_ON)))+2,LEN(@chCreationScript))
				--SELECT @tableName
				
				SELECT @chCreationScriptReplace = SUBSTRING(@chCreationScript, 1, @positionTableName_ON + LEN(RTRIM(LTRIM(@stringTableName_ON))) + 1)
											+ ' ' + @chTableName+'_VERICA_INDICES '
											+ @stringAfterIndexTableName
				
				--SELECT @stringAfterIndexTableName
			END
		--SELECT @chCreationScriptReplace
		-- Cria tabela temporaria para validacao dos indices
		EXEC('
			IF OBJECT_ID(''' + @chTableName + '_VERICA_INDICES'') IS NOT NULL 
				DROP TABLE ' + @chTableName + '_VERICA_INDICES
			SELECT TOP(0) * INTO ' + @chTableName + '_VERICA_INDICES FROM ' + @chTableName
		)
		-- Cria indice na tabela temporaria para gerar string com a "estrutura"
		EXEC(@chCreationScriptReplace)

		-- Armazena o nome do indice a ser criado
		SELECT TOP 1 @chIndexName = name FROM sys.indexes WHERE  object_id = object_id(@chTableName + '_VERICA_INDICES') AND type > 0

		-- Armazena a "estrutura" do indice a ser criado
		SELECT @chNewIndexStructure = dbo.fn_ReturnIndexStructure_Verification(@chTableName + '_VERICA_INDICES',@chIndexName)
		
		-- Verifica se EXISTE indice com o MESMO NOME do indice que deve ser criado
		IF EXISTS(SELECT name from sys.indexes where name = @chIndexName AND OBJECT_ID = OBJECT_ID(@chTableName))
			BEGIN
				-- Verifica se este indice (com o mesmo nome) POSSUI A MESMA ESTRUTURA que o que deve ser criado
				IF @chNewIndexStructure = dbo.fn_ReturnIndexStructure_Verification(@chTableName,@chIndexName)
					BEGIN
						-- Se tiver, nao faz nada, pois o indice ja esta criado como deveria
						RETURN
					END
				ELSE -- Se este INDICE (COM O MESMO NOME) tem a ESTRUTURA DIFERENTE do que deve ser criado
					BEGIN
						-- PROCURA um INDICE na tabela que possua a MESMA ESTRUTURA do que deve ser criado e armazena o nome na variavel se encontrar
						SELECT @chIndexNameSameStructure = dbo.fn_ReturnIndexEqualStructure(@chTableName, @chNewIndexStructure)
						
						-- Se nao encontrou nenhum indice com a mesma estrutura
						IF @chIndexNameSameStructure IS NULL
							BEGIN
								-- Renomeia o indice como NOME IGUAL ao que deve ser criado e que tem ESTRUTURA DIFERENTE para outro nome Ex.: IX_Callid_RENAMED_20161208
								EXEC('sp_rename ''' + @chTableName + '.' + @chIndexName + ''',''' + @chIndexName + '_RENAMED_' + @chDate + ''',''INDEX''')
								-- Cria o indice conforme script passado como parametro
								EXEC(@chCreationScript)
							END
						-- Se encontrou um indice com a MESMA ESTRUTURA que o que deve ser criado mas com NOME DIFERENTE
						ELSE IF	@chIndexNameSameStructure != @chIndexName
							BEGIN
								-- Renomeia o indice com o NOME IGUAL ao que deve ser criado e que tem ESTRUTURA DIFERENTE Ex.: IX_Callid_RENAMED_20161208
								EXEC('sp_rename ''' + @chTableName + '.' + @chIndexName + ''',''' + @chIndexName + '_RENAMED_' + @chDate + ''',''INDEX''')
								-- Renomeia o indice com ESTRUTURA IGUAL e NOME DIFERENTE para o nome utilizado no script passado como parametro
								EXEC('sp_rename ''' + @chTableName + '.' + @chIndexNameSameStructure + ''',''' + @chIndexName + ''',''INDEX''')
							END					
					END
					
			END
		ELSE -- Se NAO EXISTE indice com o MESMO NOME do indice que deve ser criado
			BEGIN
				-- PROCURA um INDICE na tabela que possua a MESMA ESTRUTURA do que deve ser criado e armazena o nome na variavel se encontrar
				SELECT @chIndexNameSameStructure = dbo.fn_ReturnIndexEqualStructure(@chTableName, @chNewIndexStructure)
				
				-- Verifica se EXISTE algum indice com a MESMA ESTRUTURA que a do que deve ser criado
				IF	@chIndexNameSameStructure IS NOT NULL
					BEGIN				
						-- Se existir, renomeia o indice com NOME DIFERENTE e ESTRUTURA IGUAL ao que deve ser criado para o nome utilizado no script passado como parametro
						EXEC('sp_rename ''' + @chTableName + '.' + @chIndexNameSameStructure + ''',''' + @chIndexName + ''',''INDEX''')
					END
				ELSE
					BEGIN
						-- Se nao existir, CRIA o INDICE de acordo como script passado como parametro
						EXEC(@chCreationScript)				
					END
			END

		-- Remove a tabela "temporaria"
		EXEC ('DROP TABLE ' + @chTableName + '_VERICA_INDICES')
	END
GO
----------------------------------------------------------------------------
-- FIM: [dbo].[usp_addIdentityColumn]
----------------------------------------------------------------------------