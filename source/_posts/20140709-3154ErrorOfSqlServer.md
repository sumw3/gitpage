title: 'SQL SERVER 2005恢复数据错误（3154）'
date: 2014-07-09 20:18:31
tags:
  - sql server 2005
  - 备份还原
categories:
  - Problems
---

###问题

在**SqlServer2005**的**Management studio**里使用`bak`文件还原数据库的时候总是会发生下面的错误。

![SQL Server restore error](http://images.cnblogs.com/cnblogs_com/adandelion/BACKERROR.GIF)

>Restore failed for Server 'ADANDELI'. (Microsoft.SqlServer.Smo)
An exception occurred while executing a Transact-SQL statement or batch.  (Microsoft.SqlServer.ConnectionInfo
The backup set holds a backup of a database other than the existing 'AAA' database.
RESTORE DATABASE is terminating abnormally. (Microsoft SQL Server，错误: 3154)

<!--more-->

###解决方法：

####Step 1

查询备份文件中的逻辑文件名称

```sql
USE master
RESTORE FILELISTONLY
   FROM DISK = 'C:\back.Bak'
Go
```

####Step 2

利用bak恢复数据库，强制还原`(REPLACE)`。
`STATS = 10`每完成10%显示一条记录。
`DBTest`和`DBTest_log`是上面`C:\back.Bak`里的逻辑文件

```sql
USE master
RESTORE DATABASE DB_Test
   FROM DISK = 'C:\back.Bak'
   WITH MOVE 'DBTest' TO 'C:\Program Files\Microsoft SQL Server2005\Data\DB.mdf',
   MOVE 'DBTest_log' TO 'C:\Program Files\Microsoft SQL Server2005\Data\DB_log.ldf',
STATS = 10, REPLACE
GO
```

到此数据库恢复完毕，在数据库列表中应该会出现名为`DB_Test`的数据库。

>代码中相关参数请参考实际自行修改
