select
    t.name table_name,
    s.name schema_name,
    sum(p.rows) total_rows
from
    sys.tables t
    join sys.schemas s on (t.schema_id = s.schema_id)
    join sys.partitions p on (t.object_id = p.object_id)
where p.index_id in (0,1)
group by t.name,s.name
having sum(p.rows) > 0;