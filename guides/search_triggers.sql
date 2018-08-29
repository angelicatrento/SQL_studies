select OBJECT_NAME(parent_object_id),* from sys.sql_modules m
inner join sys.objects o
	on m.object_id = o.object_id
where type_desc like '%trigg%'
and m.definition like '%schedule%'