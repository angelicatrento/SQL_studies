IF NOT EXISTS(
		SELECT *  
		FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS  
		WHERE constraint_type = 'PRIMARY KEY'   
		AND table_name = 'TActiveChannelsPerCampaign'
	)
	BEGIN
		ALTER TABLE dbo.TActiveChannelsPerCampaign
		ADD CONSTRAINT PK_TActiveChannelsPerCampaign PRIMARY KEY NONCLUSTERED (PK_channelsPerCampaign);
	END
GO