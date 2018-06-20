alter session set tracefile_identifier='10046_2';
alter session set max_dump_file_size = unlimited;
alter session set timed_statistics = TRUE;
alter session set statistics_level=all;
ALTER SESSION SET EVENTS '10046 trace name context forever, level 12';
-- Execute the queries or operations to be traced here --;
select sysdate from dual; -- this is just to close the above cursor
ALTER SESSION SET EVENTS '10046 trace name context off';
