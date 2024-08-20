请按照如下步骤收集信息：
1．在sqd-gdp-eas-prd-th-03_ro上运行step 1~3
2．开启压测
3．压测完成后执行step 4




--- Transact-SQL code for Event File target on Azure SQL Database.
 
 
------  Step 1.  Create key, and  ------------
------  Create credential (your Azure Storage container must already exist).
 
IF NOT EXISTS
    (SELECT * FROM sys.symmetric_keys
        WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '0C34C960-6621-4682-A123-C7EA08E3FC46' -- Or any newid().
END
GO
 
IF EXISTS
    (SELECT * FROM sys.database_scoped_credentials
        WHERE name = 'https://mssqldebug.blob.core.windows.net/cssdebug')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL
        [https://mssqldebug.blob.core.windows.net/cssdebug] ;
END
GO
 
CREATE 
    DATABASE SCOPED
    CREDENTIAL
        -- use '.blob.',   and not '.queue.' or '.table.' etc.
       [https://mssqldebug.blob.core.windows.net/cssdebug]
    WITH
        IDENTITY = 'SHARED ACCESS SIGNATURE',  -- "SAS" token.
        SECRET = 'sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2024-11-09T11:13:30Z&st=2024-08-12T03:13:30Z&spr=https&sig=ApeE1pw4WJs%2FatA5FVheOFXFbl9LoMk7L7axqox%2BRoY%3D'
    ;
GO
 
------  Step 2.  Create (define) an event session.  --------
------  The event session has an event with an action,
------  and a has a target.
 
 
ALTER
    EVENT SESSION
        ADS_Standard_Azure
    ON DATABASE
 
ADD EVENT sqlserver.attention(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.begin_tran_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.commit_tran_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.execution_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.login(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logout(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rollback_tran_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.num_response_rows,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_id,sqlserver.sql_text,sqlserver.tsql_stack)),

   

         
       ADD TARGET
        package0.event_file
            (
           -- Also, tweak the .xel file name at end, if you like.
            SET filename =
                'https://mssqldebug.blob.core.windows.net/cssdebug/xevent_perf.xel'
            )
    WITH
        (MAX_MEMORY = 100 MB,
        MAX_DISPATCH_LATENCY = 3 SECONDS)
    ;
GO
 
 
--Instructions to start the event session: 
------  Step 3.  Start the event session.  ----------------
------  Issue the SQL Update statements that will be traced.
------  Then stop the session.
 
------  Note: If the target fails to attach,
------  the session must be stopped and restarted.
 
ALTER
    EVENT SESSION
        ADS_Standard_Azure
    ON DATABASE
    STATE = START;
GO
 


------------------------------------------分割线，压测结束执行第四步结束session---------------------------------------------------------------------


--Instructions to stop the event session: 
------  Step 4.  Stop the event session.  ----------------
 
ALTER
    EVENT SESSION
       ADS_Standard_Azure
    ON DATABASE
    STATE = STOP;
GO
