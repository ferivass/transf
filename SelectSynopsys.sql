SELECT o.name         "Table Name",
       p.subname      "Part",
       min(h.analyzetime)  "Start synopsis Creation Time",
       max(h.analyzetime)  "End synopsis Creation Time"              
FROM   sys.WRI$_OPTSTAT_SYNOPSIS_HEAD$ h,
       sys.OBJ$ o,
       sys.USER$ u,
       sys.COL$ c,
       ( ( SELECT TABPART$.bo#  BO#,
                  TABPART$.obj# OBJ#
           FROM   sys.TABPART$ tabpart$ )
         UNION ALL
         ( SELECT TABCOMPART$.bo#  BO#,
                  TABCOMPART$.obj# OBJ#
           FROM   sys.TABCOMPART$ tabcompart$ ) ) tp,
       sys.OBJ$ p
WHERE  o.name = 'FACT_TRANSACTIONS' AND
       tp.obj# = p.obj# AND
       h.bo# = tp.bo# AND
       h.group# = tp.obj# * 2 AND
       h.bo# = c.obj#(+) AND
       h.intcol# = c.intcol#(+) AND
       o.owner# = u.user# AND
       h.bo# = o.obj#
GROUP BY o.name, p.subname       
ORDER  BY 3,1,2;

==

SELECT o.name, decode(bitand(h.spare2, 8), 8, 'yes', 'no') incremental
FROM   sys.hist_head$ h, sys.obj$ o
WHERE  h.obj# = o.obj#
AND    o.name = 'FACT_TRANSACTIONS'
AND    o.subname is null; 
