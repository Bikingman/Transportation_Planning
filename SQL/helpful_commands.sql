

-- get list of column names 
SELECT *
  FROM information_schema.columns
 WHERE table_schema = 'your_schema'
   AND table_name   = 'your_table'
     ;
