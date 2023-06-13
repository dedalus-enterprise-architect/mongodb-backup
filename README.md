# MongoDB backup

## Description

This script allows you to dump full or specific databases using the native mongodump command.
Furthermore, at each execution, the obsolete backups are deleted, according to the specifications of the specified retention.
Retention can be specified for TIME-WINDOWS (i.e. time check) or REDUNDANCY (i.e. number of copies).

## Parameters

Listed below are the parameters that must be entered in order for the script to work.

|Parameter|Type|Default value|Comment|
|--|--|--|--|
|MDBCK_BACKUPDIR|string|N/A|Identifies the root directory which will be responsible for the hourly, daily, weekly and monthly backups, as well as the logs|
|MDBCK_DBUSERNAME|string|N/A|Identify the username. It can be omitted only in case authentication is not enabled on the mongo|
|MDBCK_DBPASSWORD|string|N/A|Identify the password associated with the username. It can be omitted only in case authentication is not enabled on the mongo|
|MDBCK_DBAUTHDB|string|N/A|Identifies the database used to certify the credentials used during login. It can be omitted only in case authentication is not enabled on the mongo|
|MDBCK_DBHOST|string|N/A|Identifies the hostname database to connect to for information retrieval and/or data dump. It is usually used to indicate the primary node|
|MDBCK_DBPORT|integer|N/A|Identifies the communication port the mongo is listening on. May be omitted if parameter MDBCK_DBPORT_TRY_DEFAULT="yes". In this case, the communication port will be automatically set to 27017|
|MDBCK_DOHOURLY|string|no|Identifies whether to carry out (yes) or not (no) the hourly backup|
|MDBCK_HOURLYRETENTION_TYPE|mixed|N/A|Identifies whether to enable or disable the retention check. The selection can take place either numerically, by index, or via string. Possible values are: 0 or "disabled", 1 or "redundancy", 2 or "time-window"|
|MDBCK_HOURLYRETENTION| integer|1|Numerically identify the retention threshold. For example, if the retention were of type 1 (redundancy) and MDBCK_HOURLYRETENTION had value 4, it would be understood that the script should keep the 4 most recent copies of the backups present on disk. If instead the retention were of type 2 (time-window) and MDBCK_HOURLYRETENTION had value 6, it should be understood that the script should delete backups older than 6 hours|
|MDBCK_DODAILY|string|no|Identifies whether to carry out (yes) or not (no) the backup on a daily basis|
|MDBCK_DAILYRETENTION_TYPE|mixed|N/A|Identifies whether to enable or disable the retention check. See previous description|
|MDBCK_DAILYRETENTION|integer|1|Numerically identify the retention threshold. See previous description|
|MDBCK_DOWEEKLY|string|no|Identify whether to perform (yes) or not (no) the weekly backup|
|MDBCK_WEEKLYDAY|integer|N/A|Identifies the day of the week on which the backup should take place. The range goes from 1 to 7, where 1 identifies the first day of the week: Monday|
|MDBCK_WEEKLYRETENTION_TYPE|mixed|N/A|Identifies whether to enable or disable the retention check. See previous description|
|MDBCK_WEEKLYRETENTION|integer|1|Numerically identify the retention threshold. See previous description|
|MDBCK_DOMONTHLY|string|no|Identify whether to perform (yes) or not (no) the backup on a monthly basis|
|MDBCK_MONTHLYRETENTION_TYPE|mixed|N/A|Identifies whether to enable or disable the retention check. See previous description|
|MDBCK_MONTHLYRETENTION|integer|1|Numerically identify the retention threshold. See previous description|


**The MDBCK_DOHOURLY, MDBCK_DODAILY, MDBCK_DOWEEKLY, and MDBCK_DOMONTHLY parameters are mutually exclusive.**

This means that the period that is found to be valued first will be the one that will trigger the typology of backups to perform. The priority is (highest to lowest): MDBCK_DOMONTHLY, MDBCK_DOWEEKLY, MDBCK_DODAILY, and MDBCK_DOHOURLY.

Therefore, if you want to make a backup of different types in conjunction with two configurations, you will have to make use of a diversified crontab programming and/or use an external parameter file.
MDBCK_DOMONTHLY also only fires on the first day of each month.

## Optional parameters

Below is the list of optional parameters.

|Parameter|Type|Default value|Comment|
|--|--|--|--|
|MDBCK_DBURI|string|N/A|Identifies the mongo connection uri, especially in the replica configuration. Ex. MDBCK_DBURI="dblab01:27017,dblab01:27018,dblab02:27020". This parameter, among other things, is used to retrieve the information from mongo, despite having the MDBCK_DBHOST set|
|MDBCK_DBNAME|string|all|Identifies the name of the database to dump. If left blank, it will be interpreted as "all",so all databases in the mongo will be dumped|
|MDBCK_COLLECTIONS|string|all| Identifies the name of the collection to be dumped. If left blank, it will be interpreted as "all", so all collections present in the database specified in the MDBCK_DBNAME parameter will be dumped|
|MDBCK_EXCLUDE_COLLECTIONS|string|N/A|Identifies the list of collections that should be excluded from dumping a specific database, indicated in the MDBCK_DBNAME parameter|
|MDBCK_DBPORT_TRY_DEFAULT|string|no|If set to "yes" it will attribute the default port 27017 to the MDBCK_DBPORT parameter. This parameter should be used to overcome communication problems that might occur during the execution of the script, perhaps due to incorrectly assigned ports or MDBCK_DBPORT not valued|
|MDBCK_MAILCONTENT|string|N/A|Identifies where output redirection should occur. It is currently work in progress|
|MDBCK_MAXATTSIZE|integer|N/A|Identifies the maximum size of the log to be attached to the notification email. It is currently work in progress|

## Advanced parameters

Below are the parameters that identify the advanced features of the script:

|Parameter|Type|Default value|Comment|
|--|--|--|--|
|MDBCK_COMP|string|N/A| Identifies the type of compressor that will be used at the end of the dump process, in order to reduce its occupation space on disk. Possible values are gzip and bzip2|
|MDBCK_CLEANUP|string|no|Identifies whether to delete the directory where the dump resides from disk. It will be deleted only if the parameter MDBCK_COMP is filled in and if the archive was created correctly|
|MDBCK_LATEST|string|no|Identifies whether to create a copy of the last created backup in a dedicated folder. Requires parameter MDBCK_COMP|
|MDBCK_LATESTLINK|string|no|Identifies whether to create a hard link instead of a copy of the last created backup|
|MDBCK_MONGOCOMP|string|yes|Identifies whether compression will be used during the mongodump. Not to be confused with the creation of a valued archive via parameter MDBCK_COMP|
|MDBCK_OPLOG|string|no|Indicates whether the mongodump should contemplate oplogs during the full backup phase|
|MDBCK_PURGE_BCKDIR_SPACE|string|no|Identifies the forced cleanup action (deleting the oldest backup) to free up space to accommodate a new backup|
|MDBCK_REPLICAONSLAVE|string|yes|Indicates that the mongodump will draw from a replica node instead of the primary node|
|MDBCK_REQUIREMDBCK_DBAUTHDB|string|no|Indicates that authentication must occur by checking the --authenticationDatabase option. Requires MDBCK_DBAUTHDB to be set|
|MDBCK_MAXFILESIZE|integer|N/A|Identifies the maximum size that the dump must have and if this is exceeded, a split will be performed|
|MDBCK_PREBACKUP|string|N/A|Identifies a command/script that must be executed before the backup is performed|
|MDBCK_POSTBACKUP|string|N/A|Identifies a command/script that needs to be executed after the backup is performed|

## Configuring Retention

The script, is able to verify the number of backups present on disk or, alternatively, the outdated state of the dumps.

There must be 2 fundamental conditions for which the script would proceed with the retention test:

1. The dump has been performed (MDBCK_DO<PERIOD>="yes") and is consistent;
2. Retention is enabled (parameter MDBCK_<PERIODO>RETENTION_TYPE is valued other than 0 or "disabled").

if these conditions are met, the backups to be deleted will be identified (if any).

The parameters that must be used for retention management are:

- MDBCK_<PERIOD>RETENTION_TYPE
- MDBCK_<PERIOD>RETENTION

where PERIOD could be HOURLY, DAILY, WEEKLY, MONTHLY and therefore refer to hourly, daily, weekly or monthly backups.

The RETENTION_TYPE can assume, as mentioned above, three values (with indication of index or string type):

0 = "disabled" --> i.e. no retention verification action or cancellations will be performed;
1 = "redundancy" --> i.e. a retention check will be performed on the number of backups present on disk;
2 = "time-window" --> i.e. a retention check will be carried out regarding the obsolescence of the backups on disk.

Based on the latter, the script will act by maintaining the most recent N backup copies (in the case of retention = 1) or by deleting the oldest backups of N periods (hours, days, weeks or months) (in the case
of retention = 2). The number N will be set with the MDBCK_<PERIOD>RETENTION parameter.
  
## Command line syntax

The script gives the option of accepting parameters as input, listed below:

This command allows to execute the mongodump with retention management.

```text

Usage: mdb_backup.sh <option>

where option should be:

     --conf | -c : used to load an extetnal configuration file.
     --help | -? : this help.
     --test | -t : used to test the parameter assigned (dry-run).

```

- --conf or -c option allows you to read a configuration file for which you will have an override of the parameters which, on the contrary, are set within the script itself.
- --help rather than -? lists the syntax.
- --test or -t option allows only the check of the parameters without the dump and related accompanying actions being performed. This option is very useful for catching parameter errors, without having to run into error messages or, even more so, inconsistent backups that you would notice later.
  
## Examples

A. Calling up syntax help:

```text
$> mdb_backup.sh --help

************************************************** **
* AutoMongoBackup - ver. 4.4.1 (at 2023.02.16)
************************************************** **

This command allows to execute the mongodump with retention management.

Usage: mdb_backup.sh <option>

where option should be:

--conf | -c : used to load an extetnal configuration file.
--help | -? : this help.
--test | -t : used to test the parameter assigned (dry-run).
```

B. Testing the configuration of a daily backup, via URI binding, with 2-copy redundancy retention:

```text
MDBCK_BACKUPDIR="/opt/backup/mongo"
MDBCK_DBUSERNAME="admin"
MDBCK_DBPASSWORD="password"
MDBCK_DBAUTHDB="admin"
MDBCK_DBHOST="dblab01.domain.loc"
MDBCK_DBPORT=""
MDBCK_DODAILY="yes"
MDBCK_DAILYRETENTION_TYPE="redundancy"
MDBCK_DAILYRETENTION=2
MDBCK_DBURI="dblab01:27017,dblab01:27018,dblab02:27020"
MDBCK_DBPORT_TRY_DEFAULT="yes"
MDBCK_COMP="gzip"
MDBCK_CLEANUP="yes"
MDBCK_LATEST="yes"
MDBCK_LATESTLINK="yes"
MDBCK_MONGOCOMP="yes"
MDBCK_OPLOG="yes"
MDBCK_PURGE_BCKDIR_SPACE="yes"
MDBCK_REPLICAONSLAVE="yes"
MDBCK_REQUIREMDBCK_DBAUTHDB="yes"

$> /opt/backup/mongo/scripts/mdb_backup.sh --test
Loading parameters...done.
=================================================== ====================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
=================================================== ====================
Starting procedure at 2023.05.15 18:27:03

I: Checking parameters...
I: The path "/backup/mongo/backup" will be a regular directory. It could be better to use a dedicated mount point for the MDBCK_BACKUPDIR parameter.
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used ratherthen MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a redundancy retention of 2 copies.
I: All is ok.

Procedure completed at 2023.05.15 18:27:04
======================================================================
```

C. Backup execution with configuration from step B:

```text
$> /opt/backup/mongo/scripts/mdb_backup.sh

Loading parameters... done.
======================================================================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
======================================================================
Starting procedure at 2023.05.15 18:28:51
I: Checking parameters...
I: The path "/backup/mongo/backup" will be a regular directory. It could be better to use a dedicated mount point for theMDBCK_BACKUPDIR parameter.
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used ratherthen MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a redundancy retention of 2 copies.
I: All is ok.
I: AutoMongoBackup will execute a mongodump (it could take a while). A complete log report will be shown at the end of theprocedure.
======================================================================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
======================================================================
Starting procedure at 2023.05.15 18:28:51
I: Checking parameters...
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used ratherthen MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a redundancy retention of 2 copies.
I: All is ok.
======================================================================
Report
---
Parameters....................................: Internal.
---
Connecting to.................................: mongodb://admin:********@dblab01:27017,dblab01:27018,dblab02:27020/authSource=admin
Backup type...................................: Full
Backup frequency & retention..................: Daily (Retention: keep the newest 2 backup copies)
Including oplogs..............................: Yes
Purge of backup destination...................: Yes
Try to connect to secondary node directly.....: Yes
Mongodump compression.........................: Yes
AutoMongoBackup compression...................: Tar and gzip
Link to latest backup.........................: Yes
Hardlink or copy to latest....................: Hard link
Clean up dump destination.....................: Yes
---
Backup home path..............................: /backup/mongo/backup
Mongodump destination.........................: /backup/mongo/backup/daily/dblab01-20230515-18h28m.monday.tgz
Logging AutoMongoBackup info to...............: /backup/mongo/backup/log/dblab01-20230515-18h28m.monday.log
Logging mongodump to..........................: /backup/mongo/backup/log/dblab01-20230515-18h28m.monday.mdb.log
---
Backup of Mongo databases 
======================================================================
Backup started - lun 15 mag 2023, 18.28.52, CEST
======================================================================
2023.05.15 18:28:52 - I: Checking disk space... It's ok.
2023.05.15 18:29:47 - I: Tar and gzip of "dblab01-20230515-18h28m.monday.tgz"... Done.
2023.05.15 18:29:53 - I: Setting the right owner and permissions to "dblab01-20230515-18h28m.monday.tgz"... Done.
2023.05.15 18:29:53 - I: Setting the right owner and permissions to "/backup/mongo/backup/daily/dblab01-20230515-18h28mmonday"... Done.
2023.05.15 18:29:53 - I: Cleaning the dump destination... Done.
2023.05.15 18:29:55 - I: Retention check... 1 obsolete copies found.
2023.05.15 18:29:55 - I: Deleting obsolete backup(s) and log(s)...
"/backup/mongo/backup/daily/bck_current.tgz" deleted
======================================================================
Backup finished successfully - lun 15 mag 2023, 18.29.55, CEST
======================================================================
* Backup space usage *
Size  - Path
278M	/backup/mongo/backup/daily
======================================================================
```

D. Configuration testing for daily and weekly backup, connecting to a URI, with time-window retention set to 2 for both the backup modes:

```text
MDBCK_BACKUPDIR="/opt/backup/mongo"
MDBCK_DBUSERNAME="admin"
MDBCK_DBPASSWORD="password"
MDBCK_DBAUTHDB="admin"
MDBCK_DBHOST="dblab01.domain.loc"
MDBCK_DBPORT=""
MDBCK_DODAILY="yes"
MDBCK_DAILYRETENTION_TYPE=2
MDBCK_DAILYRETENTION=2
MDBCK_DOWEEKLY="yes"
MDBCK_WEEKLYDAY=1
MDBCK_WEEKLYRETENTION_TYPE="time-window"
MDBCK_WEEKLYRETENTION=2
MDBCK_DBURI="dblab01:27017,dblab01:27018,dblab02:27020"
MDBCK_DBPORT_TRY_DEFAULT="yes"
MDBCK_COMP="gzip"
MDBCK_CLEANUP="yes"
MDBCK_LATEST="yes"
MDBCK_LATESTLINK="yes"
MDBCK_MONGOCOMP="yes"
MDBCK_OPLOG="yes"
MDBCK_PURGE_BCKDIR_SPACE="yes"
MDBCK_REPLICAONSLAVE="yes"
MDBCK_REQUIREMDBCK_DBAUTHDB="yes"
```

If the script is run on the same day set in MDBCK_WEEKLYDAY=1 parameter, i.e. Monday, there would be a weekly backup:

```text
$> /opt/backup/mongo/scripts/mdb_backup.sh --test
Loading parameters...done.
=================================================== ====================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
=================================================== ====================
Starting procedure at 2023.05.15 18:46:44

I: Checking parameters...
I: The path "/backup/mongo/backup" will be a regular directory. It could be better to use a dedicated mount point for the MDBCK_BACKUPDIR parameter.
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used rather then MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The weekly backup has a time-window retention of 2 weeks.
I: All is ok.
```

If instead MDBCK_WEEKLYDAY were 6 (Saturday), you would have a daily backup:

```text
$> /opt/backup/mongo/scripts/mdb_backup.sh --test
Loading parameters...done.
=================================================== ====================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
=================================================== ====================
Starting procedure at 2023.05.15 18:47:24

I: Checking parameters...
I: The path "/backup/mongo/backup" will be a regular directory. It could be better to use a dedicated mount point for the MDBCK_BACKUPDIR parameter.
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used rather then MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a time-window retention of 2 days.
I: All is ok.

Procedure completed at 2023.05.15 18:47:25
=================================================== ====================
```

E. Performing a daily backup with time-window retention:

```text
$> /opt/backup/mongo/scripts/mdb_backup.sh
Loading parameters...done.
=================================================== ====================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
=================================================== ====================
Starting procedure at 2023.05.15 18:50:58
    
I: Checking parameters...
I: The path "/backup/mongo/backup" will be a regular directory. It could be better to use a dedicated mount point for the MDBCK_BACKUPDIR parameter.
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used rather then MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a time-window retention of 2 days.
I: All is ok.
I: AutoMongoBackup will execute a mongodump (it could take a while). A complete log report will be shown at the end of the procedure.
    
=================================================== ====================
* AutoMongoBackup v.4.4.1 (at 2023.02.16)
=================================================== ====================
Starting procedure at 2023.05.15 18:50:58
    
I: Checking parameters...
I: MDBCK_DBURI is valorized (with 3 of 3 member(s)): "dblab01:27017,dblab01:27018,dblab02:27020". It will be used rather then MDBCK_DBHOST (for highest priority).
I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: "dblab01:27017".
I: The daily backup has a time-window retention of 2 days.
I: All is ok.
=================================================== ====================
    
Reports
---
Parameters..................................: Internal.
---
Connecting to.................................: mongodb://admin:******** @dblab01:27017,dblab01:27018,dblab02:27020/?authSource=admin
Backup type.............................................: Full
Backup frequency & retention..................: Daily (Retention: delete backup older than 2 day(s))
Including oplogs..............................: Yes
Purge of backup destination...................: Yes
Try to connect to secondary node directly.....: Yes
Mongodump compression.........................: Yes
AutoMongoBackup compression...................: Tar and gzip
Link to latest backup.........................: Yes
Hardlink or copy to latest....................: Hard link
Clean up dump destination.....................: Yes
---
Backup home path..............................: /backup/mongo/backup
Mongodump destination.........................: /backup/mongo/backup/daily/dblab01-20230515-18h50m.monday.tgz
Logging AutoMongoBackup info to...............: /backup/mongo/backup/log/dblab01-20230515-18h50m.monday.log
Logging mongodump to..........................: /backup/mongo/backup/log/dblab01-20230515-18h50m.monday.mdb.log
---


Backup of Mongo databases 
======================================================================
Backup started - lun 15 mag 2023, 18.50.59, CEST
======================================================================
2023.05.15 18:50:59 - I: Checking disk space... It's ok.
2023.05.15 18:51:46 - I: Tar and gzip of "dblab01-20230515-18h50m.monday.tgz"... Done.
2023.05.15 18:51:52 - I: Setting the right owner and permissions to "dblab01-20230515-18h50m.monday.tgz"... Done.
2023.05.15 18:51:52 - I: Setting the right owner and permissions to "/backup/mongo/backup/daily/dblab01-20230515-18h50mmonday"... Done.
2023.05.15 18:51:52 - I: Cleaning the dump destination... Done.
2023.05.15 18:51:53 - I: Retention check... 1 obsolete backup found.
2023.05.15 18:51:53 - I: Deleting old backup(s) and log(s)...
"/backup/mongo/backup/daily/dblab01-20230313-17h44m.monday.tgz" deleted
"/backup/mongo/backup/log/dblab01-20230313-16h58m.monday.mdb.log" deleted
"/backup/mongo/backup/log/dblab01-20230313-17h36m.monday.mdb.log" deleted
"/backup/mongo/backup/log/dblab01-20230313-17h44m.monday.log" deleted
"/backup/mongo/backup/log/dblab01-20230313-17h44m.monday.mdb.log" deleted
======================================================================
Backup finished successfully - lun 15 mag 2023, 18.51.53, CEST
======================================================================

* Backup space usage *

Size  - Path
264M	/backup/mongo/backup/daily
=====================================================================
```