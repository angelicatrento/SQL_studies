EXEC sp_resetstatus 'VosCenter_History'

ALTER DATABASE VosCenter_History SET EMERGENCY DBCC checkdb('VosCenter_History')

ALTER DATABASE VosCenter_History SET SINGLE_USER WITH ROLLBACK IMMEDIATE

DBCC CheckDB('VosCenter_History',REPAIR_ALLOW_DATA_LOSS)

ALTER DATABASE VosCenter_History SET MULTI_USER

EXEC sp_resetstatus 'VosCenter_History'