#!/bin/bash
set -o pipefail
shopt -s expand_aliases
set -x
#
# MongoDB Backup Tool for single instance - Vers.: 4.4.1 at 2023.02.15
#



# MongoDB Backup Script
# VER. 0.20
# More Info: http://github.com/micahwedemeyer/automongobackup

# Note, this is a lobotomized port of AutoMySQLBackup
# (http://sourceforge.net/projects/automysqlbackup/) for use with
# MongoDB.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#=====================================================================
#=====================================================================
# Set the following variables to your system needs
# (Detailed instructions below variables)
#
# NOTE: All the following parameters must be replicated inside the
# file /etc/default/automongobackup or /etc/sysconfig/automongobackup
# if you desire override them at script's startup.
#
# However, it's possible to override the script's parameters loading
# them by a configuration file passed by command line with the option
# -c (or --config)
#
#=====================================================================

# Database name to specify a specific database only e.g. myawesomeapp
# Unnecessary if backup all databases
MDBCK_DBNAME=""

# MDBCK_COLLECTIONS name list to include e.g. system.profile users
# MDBCK_DBNAME is required
# Unecessary if backup all MDBCK_COLLECTIONS
MDBCK_COLLECTIONS=""

# MDBCK_COLLECTIONS to exclude e.g. system.profile users
# MDBCK_DBNAME is required
# Unecessary if backup all MDBCK_COLLECTIONS
MDBCK_EXCLUDE_COLLECTIONS=""

# Username to access the mongo server e.g. dbuser
# Unnecessary if authentication is off
MDBCK_DBUSERNAME="admin"

# Password to access the mongo server e.g. password
# Unnecessary if authentication is off
MDBCK_DBPASSWORD="x1v1mdb"

# Database for authentication to the mongo server e.g. admin
# Unnecessary if authentication is off
MDBCK_DBAUTHDB="admin"

# Mongo URI used to connect to a replica set (optional)
# NOTE: The parameter has a higher priority rather than the MDBCK_DBHOST
# i.e. dblab01:27017,dblab02:27017
MDBCK_DBURI="dblab01:27017,dblab01:27018,dblab02:27020"

# Host name (or IP address) of mongo server e.g localhost (mandatory)
MDBCK_DBHOST="dblab01"

# Port that mongo is listening on (mandatory)
MDBCK_DBPORT="27017"

# Try with default dbport 27017
MDBCK_DBPORT_TRY_DEFAULT="yes"

# Backup directory location e.g /backups
MDBCK_BACKUPDIR="/opt/dedalus/mongo/backup"

# Mail setup
# What would you like to be mailed to you?
# - log   : send only log file
# - files : send log file and sql files as attachments (see docs)
# - stdout : will simply output the log to the screen if run manually.
# - quiet : Only send logs if an error occurs to the MAILADDR.
MDBCK_MAILCONTENT="stdout"

# Set the maximum allowed email size in k. (4000 = approx 5MB email [see docs])
export MDBCK_MAXATTSIZE="4000"

# Email Address to send mail to? (user@domain.com)
# MAILADDR=""

# ============================================================================
# === SCHEDULING AND RETENTION OPTIONS ( Read the doc's below for details )===
#=============================================================================

# ---
# <MOMENT>RETENTION_TYPE: The MOMENT could be HOURLY, DAILY, WEEKLY or MONTHLY.
#                         Thanks this variable you can selects the retention type:
#                         0: disabled
#                         1: redundancy
#                         2: time-window
#
#                         You can set it by number index or description (in lower case)
# ---

# Do you want to do hourly backups? How long do you want to keep them?
# How many recent backup do you want?
MDBCK_DOHOURLY="no"
MDBCK_HOURLYRETENTION_TYPE=0
MDBCK_HOURLYRETENTION=24

# Do you want to do daily backups? How long do you want to keep them?
# How many recent backup do you want?
MDBCK_DODAILY="yes"
MDBCK_DAILYRETENTION_TYPE=1
MDBCK_DAILYRETENTION=2

# Which day do you want weekly backups? (1 to 7 where 1 is Monday)
# How many recent backup do you want?
MDBCK_DOWEEKLY="no"
MDBCK_WEEKLYDAY=6
MDBCK_WEEKLYRETENTION_TYPE=0
MDBCK_WEEKLYRETENTION=1

# Do you want monthly backups? How long do you want to keep them?
# How many recent backup do you want?
MDBCK_DOMONTHLY="no"
MDBCK_MONTHLYRETENTION_TYPE=0
MDBCK_MONTHLYRETENTION=4

# ============================================================
# === ADVANCED OPTIONS ( Read the doc's below for details )===
#=============================================================

# Choose Compression type: gzip or bzip2. This action will be run after the mongodump.
# This compression needs more space.
MDBCK_COMP="gzip"

# Choose if the uncompressed folder should be deleted after compression has completed (with MDBCK_COMP var initialized)
MDBCK_CLEANUP="yes"

# Additionally keep a copy of the most recent backup in a seperate directoryi (MDBCK_COMP is mandatory to use this option).
MDBCK_LATEST="yes"

# Make Hardlink not a copy
MDBCK_LATESTLINK="yes"

# gzip Compression during mongodump
MDBCK_MONGOCOMP="yes"

# Use oplog for point-in-time snapshotting.
MDBCK_OPLOG="yes"

# Purge the space of MDBCK_BACKUPDIR if there isn't enough space to proceed with the backup
MDBCK_PURGE_BCKDIR_SPACE="yes"

# Choose the first available secondary node (in the replica set) to dump data.
# If its value is no, the script dump by the dbhost or by dburi.
MDBCK_REPLICAONSLAVE="yes"

# Allow MDBCK_DBUSERNAME without MDBCK_DBAUTHDB
MDBCK_REQUIREMDBCK_DBAUTHDB="yes"

# Maximum files of a single backup used by split - leave empty if no split required
MDBCK_MAXFILESIZE=""

# Command to run before backups (uncomment to use)
#MDBCK_PREBACKUP=""

# Command run after backups (uncomment to use)
#MDBCK_POSTBACKUP=""


#=====================================================================
# Options documentation
# NOTE: the doc may not be updated respect the script version.
#=====================================================================
# Set MDBCK_DBUSERNAME and MDBCK_DBPASSWORD of a user that has at least SELECT permission
# to ALL databases.
#
# Set the MDBCK_DBHOST option to the server you wish to backup, leave the
# default to backup "this server".(to backup multiple servers make
# copies of this file and set the options for that server)
#
# You can change the backup storage location from /backups to anything
# you like by using the MDBCK_BACKUPDIR setting..
#
# The MDBCK_MAILCONTENT and MAILADDR options and pretty self explanatory, use
# these to have the backup log mailed to you at any email address or multiple
# email addresses in a space seperated list.
#
# (If you set mail content to "log" you will require access to the "mail" program
# on your server. If you set this to "files" you will have to have mutt installed
# on your server. If you set it to "stdout" it will log to the screen if run from
# the console or to the cron job owner if run through cron. If you set it to "quiet"
# logs will only be mailed if there are errors reported. )
#
#
# Finally copy automongobackup.sh to anywhere on your server and make sure
# to set executable permission. You can also copy the script to
# /etc/cron.daily to have it execute automatically every night or simply
# place a symlink in /etc/cron.daily to the file if you wish to keep it
# somwhere else.
#
# NOTE: On Debian copy the file with no extention for it to be run
# by cron e.g just name the file "automongobackup"
#
# Thats it..
#
#
# === Advanced options ===
#
# To set the day of the week that you would like the weekly backup to happen
# set the MDBCK_WEEKLYDAY setting, this can be a value from 1 to 7 where 1 is Monday,
# The default is 6 which means that weekly backups are done on a Saturday.
#
# Use MDBCK_PREBACKUP and MDBCK_POSTBACKUP to specify Pre and Post backup commands
# or scripts to perform tasks either before or after the backup process.
#
#
#=====================================================================
# Backup Rotation..
#=====================================================================
#
# Hourly backups are executed if MDBCK_DOHOURLY is set to "yes".
# The number of hours backup copies to keep for each day (i.e. 'Monday', 'Tuesday', etc.) is set with DHOURLYRETENTION.
# DHOURLYRETENTION=0 rotates hourly backups every day (i.e. only the most recent hourly copy is kept). -1 disables rotation.
#
# Daily backups are executed if MDBCK_DODAILY is set to "yes".
# The number of daily backup copies to keep for each day (i.e. 'Monday', 'Tuesday', etc.) is set with MDBCK_DAILYRETENTION.
# MDBCK_DAILYRETENTION=0 rotates daily backups every week (i.e. only the most recent daily copy is kept). -1 disables rotation.
#
# Weekly backups are executed if MDBCK_DOWEEKLY is set to "yes".
# MDBCK_WEEKLYDAY [1-7] sets which day a weekly backup occurs when cron.daily scripts are run.
# Rotate weekly copies after the number of weeks set by MDBCK_WEEKLYRETENTION.
# MDBCK_WEEKLYRETENTION=0 rotates weekly backups every week. -1 disables rotation.
#
# Monthly backups are executed if MDBCK_DOMONTHLY is set to "yes".
# Monthy backups occur on the first day of each month when cron.daily scripts are run.
# Rotate monthly backups after the number of months set by MDBCK_MONTHLYRETENTION.
# MDBCK_MONTHLYRETENTION=0 rotates monthly backups upon each execution. -1 disables rotation.
#
#=====================================================================
# Please Note!!
#=====================================================================
#
# I take no resposibility for any data loss or corruption when using
# this script.
#
# This script will not help in the event of a hard drive crash. You
# should copy your backups offline or to another PC for best protection.
#
# Happy backing up!
#
#=====================================================================
# Restoring
#=====================================================================
# ???
#
#=====================================================================
# Change Log
#=====================================================================
#
# VER 4.4.1 - (2023.02.15) (author: Luca Rabezzana)
#           - Backup directory check improved
#           - Redundancy and Time-window retention checks implemented
#           - Added loading by command line and override by default parameters
#           - Variable names changed. Now them are the prefix MDBCK_.
#             That allows to identify the variable list to match the script's
#             internal parameters with the external configuration file.
#           - Added dimention check: this test verify the space available to
#             proceed with the backup. If it isn't enough, the backup will be
#             skipped.
#
# VER 4.4.0 - (2022.11.03) (author: Luca Rabezzana)
#           - Implemented a check of mongo's backup status.
#             If it has been finished sucessfully than the script will
#             check the retention; otherwise the script will delete the
#             last backup.
#           - Retention's check becomes dynamic (chkObsolete and chkRetention).
#           - Implemented currentUsedSpace function to test the current
#             space quota.
#           - Implemented variable's assignement
#           - Implemented variable's default and check
#           - Source code becomes more slim.
#           - Implemented a new layout.
#           - Renamed select_secondary_member to chkSelectRoleMember to identify
#             the role of each member.
#
#
# VER 4.3.9 - (2022.06.09) (author: Luca Rabezzana)
#           - To improve the deletion of old backups, it will be used
#             the touch command to allow a right date check between the
#             current backup and previous.
#
# VER 4.3.8 - (2022.03.18) (author: Luca Rabezzana)
#           - Modified the LOGFILE and LOGMDB variable values about
#             the BACKUP_TYPE (monthly, weekly, daily, hourly)
#
# VER 4.3.7 - (2022.03.16) (author: Luca Rabezzana)
#           - Moved the backup check to permit the deletion of older
#             backup(s) after the current (if it finished sucessfully).
#             In this case we will have the right retention.
#
# VER 4.3.6 - (2022.03.11) (author: Luca Rabezzana)
#           - Added MDBCK_DBURI variable for connection to entire replica set
#           - Added MDBCK_MONGOCOMP variable to allow the gzip compression
#		          during mongodump instead than after
#		        - Added clean up logs that correspond to the retention
#
# VER 4.3.5 - (2021.12.07) (author: Luca Rabezzana)
#           - Fixed bugs in select_secondary_member() if member's check
#             was run on arbiter node
#           - Deleted set -e on top of script
#           - Added logs directory creation
#
# VER 0.11 - (2016-05-04) (author: Claudio Prato)
#          - Fixed bugs in select_secondary_member() with authdb enabled
#          - Fixed bugs in Compression function by removing the * symbol
#          - Added incremental backup feature
#          - Added option to select the MDBCK_COLLECTIONS to backup
#
# VER 0.10 - (2015-06-22) (author: Markus Graf)
#          - Added option to backup only one specific database
#
# VER 0.9 - (2011-10-28) (author: Joshua Keroes)
#       - Fixed bugs and improved logic in select_secondary_member()
#       - Fixed minor grammar issues and formatting in docs
#
# VER 0.8 - (2011-10-02) (author: Krzysztof Wilczynski)
#       - Added better support for selecting Secondary member in the
#         Replica Sets that can be used to take backups without bothering
#         busy Primary member too much.
#
# VER 0.7 - (2011-09-23) (author: Krzysztof Wilczynski)
#       - Added support for --journal dring taking backup
#         to enable journaling.
#
# VER 0.6 - (2011-09-15) (author: Krzysztof Wilczynski)
#       - Added support for --oplog during taking backup for
#         point-in-time snapshotting.
#       - Added filter for "mongodump" writing "connected to:"
#         on the standard error, which is not desirable.
#
# VER 0.5 - (2011-02-04) (author: Jan Doberstein)
#       - Added replicaset support (don't Backup on Master)
#       - Added Hard Support for 'latest' Copy
#
# VER 0.4 - (2010-10-26)
#       - Cleaned up warning message to make it clear that it can
#         usually be safely ignored
#
# VER 0.3 - (2010-06-11)
#       - Added the MDBCK_DBPORT parameter
#       - Changed USERNAME and PASSWORD to MDBCK_DBUSERNAME and MDBCK_DBPASSWORD
#       - Fixed some bugs with compression
#
# VER 0.2 - (2010-05-27) (author: Gregory Barchard)
#       - Added back the compression option for automatically creating
#         tgz or bz2 archives
#       - Added a cleanup option to optionally remove the database dump
#         after creating the archives
#       - Removed unnecessary path additions
#
# VER 0.1 - (2010-05-11)
#       - Initial Release
#
# VER 0.2 - (2015-09-10)
#       - Added configurable backup rentention options, even for
#         monthly backups.
#
#=====================================================================
#=====================================================================
#=====================================================================
#
# Should not need to be modified from here down!!
#
#=====================================================================
#=====================================================================
#=====================================================================


# ---
# Vars & Const
# ---
RETENTION_TYPE_LIST=("disabled" "redundancy" "time-window") # disabled has index 0 ; redundancy has index 1 ; time-window has index 2
START_DATE_BCK=`date +%Y%m%d`


# ---
# Functions
# ---


chkMongoConnection() {
  mongo --quiet $1 --eval 'db' >/dev/null 2>&1  # checks if the node is available
  return $?
}



chkObsolete() {
  echo -e "`CURRENT_DATE` - I: Retention check... \c"

  if [ "${RETENTION_TYPE}" != "${RETENTION_TYPE_LIST[0]}" ]; then # Check the right retention config
      if [ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[1]}" ];  then # redundancy
          # ---
          # Delete backup copies
          # ---
          _backup_list=($(ls -tr ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}))
          _cnt_backup_list=${#_backup_list[@]}
          if [ ${_cnt_backup_list} -gt ${RETENTION} ]; then
              echo -e "$((${_cnt_backup_list}-${RETENTION})) obsolete copies found."
              _backup_list=(${_backup_list[@]:0:$((${_cnt_backup_list}-${RETENTION}))})
              echo -e "`CURRENT_DATE` - I: Deleting obsolete backup(s) and log(s)..."
              set -o pipefail
              for _file2delete in $(echo ${_backup_list[@]});
              do
                  rm -fRv ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}/${_file2delete} 2>&1
                  [ $? -ne 0 ] && echo -e "\n`CURRENT_DATE` - E: OS: An error occurred removing \"${_file2delete}\". "
                  rm -fRv ${MDBCK_BACKUPDIR}/log/${_file2delete/\.tgz/\.log} 2>&1
                  [ $? -ne 0 ] && echo -e "\n`CURRENT_DATE` - E: OS: An error occurred removing \"${_file2delete/\.tgz/\.log}\". "
              done
              set +o pipefail
          # ---
          else
              echo -e "no piece(s) found."
          fi
          unset _backup_list
          unset _cnt_backup_list
      elif [ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ]; then  # time-window
          # ---
          # Translate to minutes
          # ---
          if [ "${KIND_BCK_POLICY}" = "hourly" ]; then
              _suffixRetention="hours"
          elif [ "${KIND_BCK_POLICY}" = "daily" ]; then
              _suffixRetention="days"
          elif [ "${KIND_BCK_POLICY}" = "weekly" ]; then
              _suffixRetention="weeks"
          elif [ "${KIND_BCK_POLICY}" = "monthly" ]; then
              _suffixRetention="months"
          fi
          _date2chk=`date -d "${START_DATE_BCK} -${RETENTION} ${_suffixRetention}" +"%Y%m%d %H:%M:%S"` # Date explained in seconds
          _date2chk=$((`date -d "${_date2chk}" +%s` - `date -d "${START_DATE_BCK}" +%s`))
          _date2chk=$((${_date2chk}/60))
          # ---

          _cnt_backup_list=$(find ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,} -mindepth 1 -daystart ! -mmin ${_date2chk} | wc -l)
          if [ ${_cnt_backup_list} -gt 0 ]; then
              echo -e "${_cnt_backup_list} obsolete backup found."
              echo -e "`CURRENT_DATE` - I: Deleting old backup(s) and log(s)..."
              find ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,} -mindepth 1 -daystart ! -mmin ${_date2chk} | xargs rm -fRv
              find ${MDBCK_BACKUPDIR}/log -mindepth 1 -daystart ! -mmin ${_date2chk} | xargs rm -fv
          else
              echo -e "no obsolete backup found."
          fi
          unset _cnt_backup_list
          unset _date2chk
      fi
  else
      echo -e " is ${RETENTION_TYPE}."
  fi

<<'COMMENT'
  NUM_OLD_FILES=$(find ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY} -mindepth 1 -maxdepth 1 -not -newermt \
                  "${RETENTION} `[ ${KIND_BCK_POLICY} == "daily" ] && (KIND_BCK_POLICY="day" ; echo ${KIND_BCK_POLICY}) \
                  || echo ${KIND_BCK_POLICY/%ly/}` ago" | wc -l)

  if [ ${NUM_OLD_FILES} -gt 0 ]; then
      echo "Found."
      echo -e "`CURRENT_DATE` - I: Deleting "${NUM_OLD_FILES}" backup file(s) older than "$RETENTION" \c"
      echo -e "`[ ${KIND_BCK_POLICY} == "daily" ] && (KIND_BCK_POLICY="day" ; echo ${KIND_BCK_POLICY}) || echo ${KIND_BCK_POLICY/%ly/}` ago:\n"
      find ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY} -mindepth 1 -maxdepth 1 -not -newermt \
        "${RETENTION} `[ ${KIND_BCK_POLICY} == "daily" ] && (KIND_BCK_POLICY="day" ; echo ${KIND_BCK_POLICY}) \
        || echo ${KIND_BCK_POLICY/%ly/}` ago" -print -exec rm -fR {} \;
      find ${MDBCK_BACKUPDIR}/log -mindepth 1 -maxdepth 1 -type f -iname "*.log" -not -newermt \
        "${RETENTION} `[ ${KIND_BCK_POLICY} == "daily" ] && (KIND_BCK_POLICY="day" ; echo ${KIND_BCK_POLICY}) \
        || echo ${KIND_BCK_POLICY/%ly/}` ago" -exec rm -f {} \;
      echo
  else
      echo "No obsolete backup found."
  fi
COMMENT
} # chkObsolete



chkParameters() {

# Check if all variables are set.
chk_RC=0 # 0=OK 1=WARNING 2=ERROR
dburi_cnt_err=0 # Count of occurred error for dburi
dburi_msg_info="false"
echo -e "I: Checking parameters..." | tee -a "${LOG_TMP}"


# Check if mongodump command exists
which mongodump > /dev/null 2>&1 || {
[ ${chk_RC} -lt 2 ] && chk_RC=2
echo -e "E: Not found: Mongodump command unreachable. Verify the mongo's packages are installed and their binaries were declared into the PATH environment variable." | tee -a "${LOG_TMP}"
}

# Check if backup dir is right
if [ "${MDBCK_BACKUPDIR}" ]; then
    _continue_check="true"

    for DIR_MATCH_CRITERIA in $(echo ${DISCARDED_PATH[@]});
    do
        if [[ "${MDBCK_BACKUPDIR}" =~ ${DIR_MATCH_CRITERIA} ]]; then
            echo -e "E: Bad value: the MDBCK_BACKUPDIR parameter allows a path that is different by the O.S.'s. (equal to or parent by) as:"
            #echo -e "  \"., ..$(echo ${DISCARDED_PATH[*]} | sed -e 's/[\\.*+^{}$()0]//g' -e 's/\ /, /g' -e 's/\/$//')\""
            echo -e "  \"., .., $(echo ${DISCARDED_PATH[*]} | sed -e 's/[\\.*+^{}$()0]//g' | sed -e 's/\ \/$//g' | sed -e 's/^\ //' -e 's/\ /,\ /g')\""
            echo -e "   except for: \"$(echo ${ALLOWED_PATH_LIST[@]} | sed -e 's/\ /, /g')\"."
            _continue_check="false"
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            break
        fi
    done

    if [ "${_continue_check}" = "true" ]; then
        _path_is_valid="false"
        _BACKUPDIR_IS_MOUNT_POINT="false"
        for DIR_MATCH_CRITERIA in $(echo ${ALLOWED_PATH[@]});
        do
            if [[ "${MDBCK_BACKUPDIR}" =~ ${DIR_MATCH_CRITERIA} ]]; then
                _path_is_valid="true"
                _BACKUPDIR=${MDBCK_BACKUPDIR}
                while true ;
                do
                    if [ -n "${_BACKUPDIR}" ]; then
                        df -h | awk '{print $6}' | grep -Fx ${_BACKUPDIR} >/dev/null 2>&1
                        if [ $? -eq 0 ]; then
                            echo -e "I: The path \"${MDBCK_BACKUPDIR}\" is or has a dedicated (parent) mount point."
                            _BACKUPDIR_IS_MOUNT_POINT="true"
                            break
                        else
                            _BACKUPDIR=$(echo ${_BACKUPDIR%/*})
                        fi
                    else
                        echo -e "I: The path \"${MDBCK_BACKUPDIR}\" will be a regular directory. It could be better to use a dedicated mount point for the MDBCK_BACKUPDIR parameter."
                        break
                    fi
                done
                break
            fi
        done

        if [ "${_path_is_valid}" = "false" ]; then
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            echo -e "E: Bad value: the path \"${MDBCK_BACKUPDIR}\" doesn't satisfy the match criteria \"${DIR_MATCH_CRITERIA}\". The MDBCK_BACKUPDIR parameter is mandatory."
        fi
    fi
else
    [ ${chk_RC} -lt 2 ] && chk_RC=2
    echo -e "E: Value not assigned: the MDBCK_BACKUPDIR parameter is mandatory." | tee -a "${LOG_TMP}"
fi


if [ -z "${MDBCK_DBUSERNAME}" ] || [ -z "${MDBCK_DBPASSWORD}" ]; then
    ##shellout "E: Username and password are mandatory. Please, checks the settings." "${LOG_TMP}"
    [ ${chk_RC} -lt 2 ] && chk_RC=2
    echo -e "E: Value not assigned: the MDBCK_DBUSERNAME and MDBCK_DBPASSWORD parameters are mandatory." | tee -a "${LOG_TMP}"
    dburi_msg_info="true"
fi


if [ "${MDBCK_REQUIREMDBCK_DBAUTHDB}" == "yes" ] && [ -z "${MDBCK_DBAUTHDB}" ]; then
    ##shellout "E: With the authentication enabled, it's mandatory to specify an authentication database. Please, checks the settings." "${LOG_TMP}"
    [ ${chk_RC} -lt 2 ] && chk_RC=2
    echo -e "E: Value not assigned: the MDBCK_DBAUTHDB parameter is mandatory if the authentication is enabled (MDBCK_REQUIREMDBCK_DBAUTHDB)." | tee -a "${LOG_TMP}"
    dburi_msg_info="true"
fi


# Do we need to use a username/password on MDBCK_DBURI?
# Note: MDBCK_DBURI has a higher priority rather than MDBCK_DBHOST and MDBCK_DBPORT!
if [ -n "${MDBCK_DBURI}" ]; then
    [ "${dburi_msg_info}" = "true" ] && echo -e "I: The MDBCK_DBURI's parameter check could shows a wrong result." | tee -a "${LOG_TMP}"
    rc=0
    cnt=0
    DBURI_CNT_MEMBERS=0
    for x in $(echo ${MDBCK_DBURI} | xargs -d, -n 1); do
        cnt=$((cnt + 1))
        if [[ ! "${x}" =~ ^([^[:punct:]\ àèéìòùç£°§¶][-_.]?)+[^[:punct:]\ àèéìòùç£°§¶]{2,}:[[:digit:]]{4,5}$ ]]; then
            rc=1
            dburi_cnt_err=$((dburi_cnt_err + 1))
            [ ${msg} ] && msg="${msg}, ${cnt}" || msg="${cnt}"
        else
            _dbhost=$(echo ${x%%:*})
            _dbport=$(echo ${x##*:})

            if [[ ! "${_dbhost}" =~ ^([^[:punct:]\ àèéìòùç£°§¶][-_.]?)+([[:alnum:]]{2,})$ ]]; then
                echo -e "E: Bad format: MDBCK_DBURI section #${cnt}: \"${_dbhost}\". The database hostname allowed is a string as: localhost, hostname or \"<FQDN>\"." | tee -a "${LOG_TMP}"
                rc=1
                dburi_cnt_err=$((dburi_cnt_err + 1))
                [ -n "${msg}" ] && msg="${msg}, ${cnt}" || msg="${cnt}"
            else
                if [[ ${_dbport} =~ ^[1-9]{1}[0-9]{3,4}$ ]]; then
                    if [ ${_dbport} -lt 1025 -o ${_dbport} -gt 49151 ]; then
                        echo -e "E: Bad value: MDBCK_DBURI section #${cnt}: \"${_dbport}\" is a reserved port. The database port allowed in an integer between 1024 and 49151." | tee -a "${LOG_TMP}"
                        rc=1
                        dburi_cnt_err=$((dburi_cnt_err + 1))
                        [ ${msg} ] && msg="${msg}, ${cnt}" || msg="${cnt}"
                    else
                        chkTcpConnection "${_dbhost}" "${_dbport}"
                        if [ $? -eq 1 ]; then
                            [ ${chk_RC} -lt 1 ] && chk_RC=1
                            echo -e "W: MDBCK_DBURI: no TCP connection to \"${x}\". Maybe it is unreachable, doesn't exist or hasn't an assigned DNS entry." | tee -a "${LOG_TMP}"
                        else
                            chkMongoConnection "--host ${_dbhost}:${_dbport}"
                            if [ $? -eq 0 ]; then
                                chkSelectRoleMember "${_dbhost}" "${_dbport}"
                                if [ $? -eq 0 ]; then
                                    [ ${chk_RC} -lt 1 ] && chk_RC=1
                                    echo -e "W: MDBCK_DBURI: the node \"${x}\" is an arbiter." | tee -a "${LOG_TMP}"
                                else
                                    [ -n "${msg}" ] && msg="${msg}, ${cnt}"
                                    [ -z "${DBURI_LIST_MEMBERS}" ] && DBURI_LIST_MEMBERS="${_dbhost}:${_dbport}" || DBURI_LIST_MEMBERS="${DBURI_LIST_MEMBERS} ${_dbhost}:${_dbport}"
                                    DBURI_CNT_MEMBERS=$((DBURI_CNT_MEMBERS + 1))
                                fi
                            else
                                echo -e "E: MDBCK_DBURI: no connection to \"${x}\". Maybe it is not a mongo member." | tee -a "${LOG_TMP}"
                                rc=1
                                dburi_cnt_err=$((dburi_cnt_err + 1))
                                [ -n "${msg}" ] && msg="${msg}, ${cnt}" || msg="${cnt}"
                            fi
                        fi
                    fi
                else
                    ##shellout "E: The database port must be a number between 4 and 5 digits. Please, checks the settings." "${LOG_TMP}"
                    echo -e "E: Bad format: MDBCK_DBURI section #${cnt}: \"${_dbport}\". The database port allowed is an integer between 1024 and 49151." | tee -a "${LOG_TMP}"
                    rc=1
                    dburi_cnt_err=$((dburi_cnt_err + 1))
                    [ ${msg} ] && msg="${msg}, ${cnt}" || msg="${cnt}"
                fi
            fi
        fi
    done

    if [ ${rc} -eq 0 ]; then
        if [ ${DBURI_CNT_MEMBERS} -gt 0 ]; then
            if [ -n "${DBURI_LIST_MEMBERS}" ]; then
                DBURI_LIST_MEMBERS=$(echo "${DBURI_LIST_MEMBERS}" | tr ' ' ',')
                MDBCK_DBURI="${DBURI_LIST_MEMBERS}"
            fi
            if [ -n "${MDBCK_DBUSERNAME}" ]; then
                MDBCK_DBURI="mongodb://${MDBCK_DBUSERNAME}:${MDBCK_DBPASSWORD}@${MDBCK_DBURI}"
                if [ "${MDBCK_REQUIREMDBCK_DBAUTHDB}" == "yes" ]; then
                    MDBCK_DBURI="${MDBCK_DBURI}/?authSource=${MDBCK_DBAUTHDB}"
                fi
            fi
            echo -e "I: MDBCK_DBURI is valorized (with "${DBURI_CNT_MEMBERS}" of ${cnt} member(s))$([ -n ${DBURI_LIST_MEMBERS} ] && echo ": \"${DBURI_LIST_MEMBERS}\""). It will be used rather then MDBCK_DBHOST (for highest priority)." | tee -a "${LOG_TMP}"
        else
          echo -e "W: MDBCK_DBURI: No members of \"${MDBCK_DBURI}\" are available. It will try to proceed with the MDBCK_DBHOST parameter if it's valorized." | tee -a "${LOG_TMP}"
          MDBCK_DBURI="" # forzed to null to test a connection with MDBCK_DBHOST if it is valorized.
        fi
    else
        [ ${chk_RC} -lt 2 ] && chk_RC=2
        if [ ${dburi_cnt_err} -eq ${cnt} ]; then
            echo -e "E: Bad format: the full MDBCK_DBURI is wrong. The MDBCK_DBURI parameter allows the syntax \"<MDBCK_DBHOST>:<MDBCK_DBPORT>[,]\" to repeat <1..n>." | tee -a "${LOG_TMP}"
        else
            echo -e "E: Bad format/value: for the MDBCK_DBURI's section(s) #${msg}. The MDBCK_DBURI parameter allows the syntax \"<MDBCK_DBHOST>:<MDBCK_DBPORT>[,]\" to repeat <1..n>." | tee -a "${LOG_TMP}"
        fi
    fi
fi


if [ -z "${MDBCK_DBURI}" ]; then
    if [ -z "${MDBCK_DBHOST}" -a -z "${MDBCK_DBPORT}" ]; then
        [ ${chk_RC} -lt 2 ] && chk_RC=2
        echo -e "E: Value not assigned: the MDBCK_DBHOST, MDBCK_DBPORT and MDBCK_DBURI parameters are empty." | tee -a "${LOG_TMP}"
        echo -e "I: The MDBCK_DBHOST and MDBCK_DBURI parameters are mandatory and mutually exclusive."  | tee -a "${LOG_TMP}"
        echo -e "I: To the MDBCK_DBPORT parameter will be assigned the port 27017 if the MDBCK_DBPORT_TRY_DEFAULT parameter is set to \"yes\"."  | tee -a "${LOG_TMP}"
        dburi_cnt_err=$((dburi_cnt_err + 1))
    elif [ -z "${MDBCK_DBHOST}" ]; then
        [ ${chk_RC} -lt 2 ] && chk_RC=2
        dburi_cnt_err=$((dburi_cnt_err + 1))
        echo -e "E: Value not assigned: the MDBCK_DBHOST parameter is mandatory." | tee -a "${LOG_TMP}"
    elif [ -n "${MDBCK_DBHOST}" ]; then
          if [[ ! "${MDBCK_DBHOST}" =~ ^([^[:punct:]\ àèéìòùç£°§¶][-_.]?)+([[:alnum:]]{2,})$ ]]; then
              ##shellout "E: The database host has a wrong value. The right syntax is localhost or \"<FQDN>\" i.e. dbhost.y.x.z." "${LOG_TMP}"
              [ ${chk_RC} -lt 2 ] && chk_RC=2
              dburi_cnt_err=$((dburi_cnt_err + 1))
              echo -e "E: Bad format: the MDBCK_DBHOST parameter allows a string as: localhost, hostname or \"<FQDN>\"." | tee -a "${LOG_TMP}"
          else
              if [ -z "${MDBCK_DBPORT}" ]; then
                  if [ "${MDBCK_DBPORT_TRY_DEFAULT}" = "yes" ]; then
                      MDBCK_DBPORT=${MDBCK_DBPORT:-"27017"}
                      [ ${chk_RC} -lt 1 ] && chk_RC=1
                      echo -e "W: Value not assigned: the MDBCK_DBPORT parameter is empty, but the MDBCK_DBPORT_TRY_DEFAULT parameter is enabled. An attempt will be made with the default value \"${MDBCK_DBPORT}\"." | tee -a "${LOG_TMP}"
                  else
                      [ ${chk_RC} -lt 2 ] && chk_RC=2
                      dburi_cnt_err=$((dburi_cnt_err + 1))
                      echo -e "E: Value not assigned: the MDBCK_DBPORT parameter is mandatory." | tee -a "${LOG_TMP}"
                  fi
              fi

              if [ -n "${MDBCK_DBPORT}" ]; then
                  if [[ ${MDBCK_DBPORT} =~ ^[1-9]{1}[0-9]{3,4}$ ]]; then
                      if [ ${MDBCK_DBPORT} -lt 1025 -o ${MDBCK_DBPORT} -gt 49151 ]; then
                          [ ${chk_RC} -lt 2 ] && chk_RC=2
                          dburi_cnt_err=$((dburi_cnt_err + 1))
                          echo -e "E: Bad value: \"${MDBCK_DBPORT}\" is a reserved port. The MDBCK_DBPORT parameter allows the range: 1024 to 49151." | tee -a "${LOG_TMP}"
                      else
                          chkTcpConnection "${MDBCK_DBHOST}" "${MDBCK_DBPORT}"
                          if [ $? -eq 1 ]; then
                              [ ${chk_RC} -lt 1 ] && chk_RC=1
                              echo -e "W: No TCP connection to \"${MDBCK_DBHOST}:${MDBCK_DBPORT}\". Maybe it is unreachable, doesn't exist or hasn't an assigned DNS entry." | tee -a "${LOG_TMP}"
                          else
                              chkMongoConnection "--host ${MDBCK_DBHOST}:${MDBCK_DBPORT}"
                              if [ $? -eq 0 ]; then
                                  chkSelectRoleMember "${MDBCK_DBHOST}" "${MDBCK_DBPORT}"
                                  if [ $? -eq 0 ]; then
                                      [ ${chk_RC} -lt 2 ] && chk_RC=2
                                      dburi_cnt_err=$((dburi_cnt_err + 1))
                                      echo -e "E: The \"${MDBCK_DBHOST}:${MDBCK_DBPORT}\" is an arbiter. The MDBCK_DBHOST parameter could be a primary or secondary node only." | tee -a "${LOG_TMP}"
                                  fi
                              else
                                  echo -e "E: No connection to \"${MDBCK_DBHOST}:${MDBCK_DBPORT}\". Maybe it is not a mongo member." | tee -a "${LOG_TMP}"
                                  [ ${chk_RC} -lt 2 ] && chk_RC=2
                                  dburi_cnt_err=$((dburi_cnt_err + 1))
                              fi
                          fi
                      fi
                  else
                      ##shellout "E: The database port must be a number between 4 and 5 digits. Please, checks the settings." "${LOG_TMP}"
                      [ ${chk_RC} -lt 2 ] && chk_RC=2
                      dburi_cnt_err=$((dburi_cnt_err + 1))
                      echo -e "E: Bad format. The MDBCK_DBPORT parameter allows an integer between 1024 and 49151." | tee -a "${LOG_TMP}"
                  fi
              fi
          fi

    fi
fi


# Do we use gzip compression during mongodump
if [ "${MDBCK_MONGOCOMP}" = "yes" ]; then
    OPT="${OPT} --gzip"
fi


# Do we need to backup only a specific database?
if [ -n "${MDBCK_DBNAME}" ]; then
    cnt=0
    for x in ${MDBCK_DBNAME}; do
        cnt=$((cnt + 1))
    done
    if [ ${cnt} -gt 1 ]; then
        ##shellout "E: It's possible to select: only one or all database (MDBCK_DBNAME left empty). No more one of them. Please, checks the settings." "${LOG_TMP}"
        [ ${chk_RC} -lt 2 ] && chk_RC=2
        echo -e "E: Too many values: the MDBCK_DBNAME parameter allows a single alphanumeric value: empty (aka all databases) or a database name (max 64 characters). No more." | tee -a "${LOG_TMP}"
        MDBCK_DBNAME="!0" # Forced to identifiy the error within the next checks (collection, excludeCollection and optlog)
    else
        if [[ "${MDBCK_DBNAME}" =~ ^[^\0\/\\\.\"\$[:space:]]{1,64}$ ]]; then
            OPT="$OPT -d ${MDBCK_DBNAME}"
        else
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            echo -e "E: Bad value/format: the MDBCK_DBNAME parameter allows a single alphanumeric value: empty (aka all databases) or a database name (max 64 characters)." | tee -a "${LOG_TMP}"
            MDBCK_DBNAME="-" # Forced to identifiy the error within the next checks (collection, excludeCollection and optlog)
        fi

    fi
fi


# Do we need to backup only a specific MDBCK_COLLECTIONS?
if [ -n "${MDBCK_COLLECTIONS}" ] && [ -n "${MDBCK_EXCLUDE_COLLECTIONS}" ]; then
    ##shellout "E: It's not allowed to use the options --collection and --excludeCollection at the same time. Please, checks the settings." "${LOG_TMP}"
    [ ${chk_RC} -lt 2 ] && chk_RC=2
    echo -e "E: Too many values: MDBCK_COLLECTIONS and MDBCK_EXCLUDE_COLLECTIONS parameters not allowed at the same time." | tee -a "${LOG_TMP}"
else
    if [ -n "${MDBCK_COLLECTIONS}" ]; then
        cnt=0
        for x in ${MDBCK_COLLECTIONS}; do
            cnt=$((cnt + 1))
        done
        if [ ${cnt} -gt 1 ]; then
            ##shellout "E: It's possible to dump all MDBCK_COLLECTIONS or only one at the same time. No more. Please, checks the settings." "${LOG_TMP}"
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            echo -e "E: Too many values: the MDBCK_COLLECTIONS parameter allows a signle value: empty (aka all MDBCK_COLLECTIONS) or a collection name. No more." | tee -a "${LOG_TMP}"
        else
            if [ -n "${MDBCK_DBNAME}" ]; then
                if [ "${MDBCK_DBNAME}" != "!0" -a "${MDBCK_DBNAME}" != "-" ]; then
                    OPT="${OPT} --collection $x"
                else
                    [ ${chk_RC} -lt 2 ] && chk_RC=2
                    echo -e "E: Too many values or bad value/format: it's mandatory to specify a single alphanumeric value in the MDBCK_DBNAME parameter if you want to use --collection mongodump's option (MDBCK_COLLECTIONS)." | tee -a "${LOG_TMP}"
                fi
            else
                ##shellout "E: It's not possible dump a collection without a specified database. Please, checks the settings." "${LOG_TMP}"
                [ ${chk_RC} -lt 2 ] && chk_RC=2
                echo -e "E: Value not assigned: the MDBCK_DBNAME parameter is mandatory if you want to use --collection mongodump's option (MDBCK_COLLECTIONS)." | tee -a "${LOG_TMP}"
            fi
        fi
    fi


    # Do we need to exclude MDBCK_COLLECTIONS?
    if [ -n "${MDBCK_EXCLUDE_COLLECTIONS}" ]; then
        if [ -n "$MDBCK_DBNAME" ]; then
            if [ "${MDBCK_DBNAME}" != "!0" -a "${MDBCK_DBNAME}" != "-" ]; then
                for x in $MDBCK_EXCLUDE_COLLECTIONS; do
                    OPT="$OPT --excludeCollection $x"
                done
            else
                [ ${chk_RC} -lt 2 ] && chk_RC=2
                echo -e "E: Too many values or bad value/format: it's mandatory to specify a single alphanumeric value in the MDBCK_DBNAME parameter if you want to use --excludeCollection mongodump's option (MDBCK_EXCLUDE_COLLECTIONS)." | tee -a "${LOG_TMP}"
            fi
        else
            ##shellout "E: It's not possible exclude one or more MDBCK_COLLECTIONS without a specified database. Please, checks the settings." "${LOG_TMP}"
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            echo -e "E: Value not assigned: the MDBCK_DBNAME parameter is mandatory if you want to use --excludeCollection mongodump's option (MDBCK_EXCLUDE_COLLECTIONS)." | tee -a "${LOG_TMP}"
        fi
    fi
fi

# Do we use oplog for point-in-time snapshotting?
if [ "${MDBCK_OPLOG}" = "yes" ]; then
    if [ -z "$MDBCK_DBNAME" ]; then
        OPT="${OPT} --oplog"
    else
        [ ${chk_RC} -lt 1 ] && chk_RC=1
        echo -e "W: Bad value: the MDBCK_DBNAME must be empty if you want to use --oplog mongodump's option. It's used during a full backup only. Then the oplogs will be skipped." | tee -a "${LOG_TMP}"
    fi
fi


if [ -n "${MDBCK_MAXFILESIZE}" ]; then
    if [[ ! ${MDBCK_MAXFILESIZE} =~ ^[1-9]{1}[0-9]{3,} ]]; then
        [ ${chk_RC} -lt 1 ] && chk_RC=1
        echo -e "W: Bad format: the MDBCK_MAXFILESIZE parameter allows an intger between 1024 and 1073741824 (1MB and 1GB). No split will be run." | tee -a "${LOG_TMP}"
        MAXFILESISE=""
    else
        if [ ${MDBCK_MAXFILESIZE} -lt 1024 -o ${MDBCK_MAXFILESIZE} -gt 1073741824 ]; then  # Between 1MB to 1GB
            ${chk_RC} -lt 1 ] && chk_RC=1
            echo -e "W: Bad value: The MAXFILESISE parameter allows an integer between 1024 and 1073741824 (1MB and 1GB). No split will be run." | tee -a "${LOG_TMP}"
            MDBCK_MAXFILESIZE=""
        fi
    fi
fi


# Try to select an available secondary for the backup or fallback to primary.
if [ "x${MDBCK_REPLICAONSLAVE}" == "xyes" ]; then
    if [ ${dburi_cnt_err} -gt 0 ]; then
        echo -e "I: The MDBCK_REPLICAONSLAVE parameter is enabled, but depends by the MDBCK_DBHOST, MDBCK_DBPORT and MDBCK_DBURI parameters." | tee -a "${LOG_TMP}"
    elif [ "${dburi_msg_info}" = "true" ]; then
        echo -e "I: The MDBCK_REPLICAONSLAVE parameter is enabled, but depends by the MDBCK_DBUSERNAME, MDBCK_DBPASSWORD and MDBCK_DBAUTHDB parameters." | tee -a "${LOG_TMP}"
    else # Check error counter about MDBCK_DBHOST and MDBCK_DBPORT as single values or within the MDBCK_DBURI.
        # Return value via indirect-reference hack ...
        chkSelectRoleMember secondary
        if [ $? -ne 0 ]; then
            [ ${chk_RC} -lt 2 ] && chk_RC=2
            echo -e "E: Connection failure to mongo member(s). Secondary node not retrieved for data dump (MDBCK_REPLICAONSLAVE). " | tee -a "${LOG_TMP}"
        else
            if [ -n "${secondary}" ]; then
                MDBCK_DBHOST=${secondary%%:*}
                MDBCK_DBPORT=${secondary##*:}
                echo -e "I: The MDBCK_REPLICAONSLAVE parameter is enabled. Secondary node identified: \"${MDBCK_DBHOST}:${MDBCK_DBPORT}\"." | tee -a "${LOG_TMP}"
            else
                [ ${chk_RC} -lt 1 ] && chk_RC=1
                if [ -n "${MDBCK_DBURI}" ]; then
                    # Retrieve the MDBCK_DBHOST and MDBCK_DBPORT using MDBCK_DBURI, however the LOGFILE will left empty.
                    chkSelectRoleMember ismaster
                    if [ -n "${ismaster}" ]; then
                        MDBCK_DBHOST=${ismaster%%:*}
                        MDBCK_DBPORT=${ismaster##*:}
                        REPLICATION_WARNING="primary node ${MDBCK_DBHOST}:${MDBCK_DBPORT}"
                    fi
                elif [ -n "${MDBCK_DBHOST}" ]; then
                    REPLICATION_WARNING="MDBCK_DBHOST ${MDBCK_DBHOST}:${MDBCK_DBPORT}"
                fi
                echo -e "W: The MDBCK_REPLICAONSLAVE parameter is enabled, but no suitable secondary node found. Falling back to ${REPLICATION_WARNING}." | tee -a "${LOG_TMP}"
            fi
        fi
    fi
else
    if [ ${dburi_cnt_err} -eq 0 -a "${dburi_msg_info}" = "false" ]; then
        if [ -n "${MDBCK_DBURI}" ]; then
            # Retrieve the MDBCK_DBHOST and MDBCK_DBPORT using MDBCK_DBURI, however the LOGFILE will left empty.
            chkSelectRoleMember ismaster
            if [ -n "${ismaster}" ]; then
                MDBCK_DBHOST=${ismaster%%:*}
                MDBCK_DBPORT=${ismaster##*:}
            fi
        fi
    fi
fi


# Do we use a filter for hourly point-in-time snapshotting?
if [ "${MDBCK_DOHOURLY}" == "yes" ]; then

    # getting PITR START timestamp
    # shellcheck disable=SC2012
    [ "${MDBCK_COMP}" = "gzip" ] && HOURLYQUERY=$(ls -t $MDBCK_BACKUPDIR/hourly | head -n 1 | cut -d '.' -f3)

    # setting the start timestamp to NOW for the first execution
    if [ -z "${HOURLYQUERY}" ]; then
        QUERY=""
    else
        # limit the documents included in the output of mongodump
        # shellcheck disable=SC2016
        QUERY='{ "ts" : { $gt :  Timestamp('${HOURLYQUERY}', 1) } }'
    fi
fi


# Check for correct sed usage
if [ "$(uname -s)" = 'Darwin' ] || [ "$(uname -s)" = 'FreeBSD' ]; then
    SED="sed -i ''"
else
    SED="sed -i"
fi


# Check Retention - Retrieve which backup policy is running
if [[ ${DOM} = "01" ]] && [[ "${MDBCK_DOMONTHLY}" = "yes" ]]; then
    # Delete old monthly backups while respecting the set rentention policy.
    KIND_BCK_POLICY="monthly"
elif [[ "${DNOW}" = "$MDBCK_WEEKLYDAY" ]] && [[ "${MDBCK_DOWEEKLY}" = "yes" ]] ; then
    # Delete old weekly backups while respecting the set rentention policy.
    KIND_BCK_POLICY="weekly"
elif [[ "${MDBCK_DODAILY}" = "yes" ]] ; then
    # Delete old daily backups while respecting the set rentention policy.
    KIND_BCK_POLICY="daily"
elif [[ "${MDBCK_DOHOURLY}" = "yes" ]] ; then
    # Delete old hourly backups while respecting the set rentention policy.
    KIND_BCK_POLICY="hourly"
fi


if [ -n "${KIND_BCK_POLICY}" ]; then
    RETENTION_TYPE="$(eval echo \${MDBCK_${KIND_BCK_POLICY^^}RETENTION_TYPE})"
    _retention_type_is_valid="true"
    if [[ ${RETENTION_TYPE} =~ ^[[:digit:]]+$ ]]; then
        if [ ${RETENTION_TYPE} -ge 0 -a ${RETENTION_TYPE} -lt ${#RETENTION_TYPE_LIST[@]} ]; then
            RETENTION_TYPE="${RETENTION_TYPE_LIST[${RETENTION_TYPE}]}"
        else
           _retention_type_is_valid="false"
        fi
    else
        for IDX in ${!RETENTION_TYPE_LIST[@]} ;
        do
            _retention_type_is_valid="true"
            if [ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[${IDX}]}" ]; then
                RETENTION_TYPE="${RETENTION_TYPE_LIST[${IDX}]}"
                break
            else
                _retention_type_is_valid="false"
            fi
        done
    fi

    if [ "${_retention_type_is_valid}" = "false" ]; then
        [ ${chk_RC} -lt 1 ] && chk_RC=1
        echo -e "W: Bad value: wrong retention type specified for the ${KIND_BCK_POLICY} backup policy. Obsolete backup(s) will not be deleted." | tee -a "${LOG_TMP}"
        RETENTION_TYPE="${RETENTION_TYPE_LIST[0]}"
        echo -e "I: The retention will be forced to ${RETENTION_TYPE}." | tee -a "${LOG_TMP}"
    else
        if [ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[0]}" ]; then
            echo -e "I: The retention is ${RETENTION_TYPE_LIST[0]}. Obsolete backup(s) will not be deleted." | tee -a "${LOG_TMP}"
        else
            eval RETENTION="\${MDBCK_${KIND_BCK_POLICY^^}RETENTION}"
            if [ ${RETENTION} -eq 0 ]; then
                echo -e "W: The retention is ${RETENTION} (aka ${RETENTION_TYPE_LIST[0]}) for the ${KIND_BCK_POLICY} backup policy. Obsolete backup(s) will not be deleted." | tee -a "${LOG_TMP}"
                RETENTION_TYPE="${RETENTION_TYPE_LIST[0]}"
                [ ${chk_RC} -lt 1 ] && chk_RC=1
            elif [ ${RETENTION} -lt 0 ]; then
                echo -e "W: Bad value: the retention allows positive integer only. Obsolete backup(s) will not be deleted for the ${KIND_BCK_POLICY} backup policy." | tee -a "${LOG_TMP}"
                RETENTION_TYPE="${RETENTION_TYPE_LIST[0]}"
                [ ${chk_RC} -lt 1 ] && chk_RC=1
                echo -e "I: The retention will be forced to ${RETENTION_TYPE}." | tee -a "${LOG_TMP}"
            else
                if [[ ! ${RETENTION} =~ ^[1-9]{1}[0-9]{0,2} ]]; then
                    echo -e "W: Bad format: the $(eval \${MDBCK_${KIND_BCK_POLICY^^}RETENTION}) parameter allows an integer. It will be forced to ${RETENTION_TYPE_LIST[0]}. Obsolete backup(s) will not be deleted." | tee -a "${LOG_TMP}"
                    RETENTION_TYPE="${RETENTION_TYPE_LIST[0]}"
                    [ ${chk_RC} -lt 1 ] && chk_RC=1
                else
                    if [ "${KIND_BCK_POLICY}" = "hourly" ]; then
                        if [ ${RETENTION} -gt 672 ]; then
                            echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "hrs" || echo "copies"). It's suggested to use the monthly backup policy." | tee -a "${LOG_TMP}"
                        elif [ ${RETENTION} -gt 168 ]; then
                            echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "hrs" || echo "copies"). It's suggested to use the weekly backup policy." | tee -a "${LOG_TMP}"
                        elif [ ${RETENTION} -gt 24 ]; then
                            echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "hrs" || echo "copies"). It's suggested to use the daily backup policy." | tee -a "${LOG_TMP}"
                        else
                            echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "hrs" || echo "copies")." | tee -a "${LOG_TMP}"
                        fi
                    elif [ "${KIND_BCK_POLICY}" = "daily" ]; then
                          if [ ${RETENTION} -gt 30 ]; then
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "days" || echo "copies"). It's suggested to use the monthly backup policy." | tee -a "${LOG_TMP}"
                          elif [ ${RETENTION} -gt 7 ]; then
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "days" || echo "copies"). It's suggested to use the weekly backup policy." | tee -a "${LOG_TMP}"
                          else
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "days" || echo "copies")." | tee -a "${LOG_TMP}"
                          fi
                    elif [ "${KIND_BCK_POLICY}" = "weekly" ]; then
                          if [ ${RETENTION} -gt 4 ]; then
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "weeks" || echo "copies"). It's suggested to use the monthly backup policy." | tee -a "${LOG_TMP}"
                          else
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "weeks" || echo "copies")." | tee -a "${LOG_TMP}"
                          fi
                    elif [ "${KIND_BCK_POLICY}" = "monthly" ]; then
                          if [ ${RETENTION} -gt 12 ]; then
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "months" || echo "copies"). It's suggested to review the monthly backup policy." | tee -a "${LOG_TMP}"
                          else
                              echo -e "I: The ${KIND_BCK_POLICY} backup has a ${RETENTION_TYPE} retention of ${RETENTION} $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "months" || echo "copies")." | tee -a "${LOG_TMP}"
                          fi
                    fi
                fi
            fi
        fi
    fi
else
    [ ${chk_RC} -lt 2 ] && chk_RC=2
    echo -e "E: Value not assigned: the MDBCK_DOHOURLY, MDBCK_DODAILY, MDBCK_DOWEEKLY, MDBCK_DOMONTHLY (only at the 1st of month) parameters are mandatory. No backup will be run." | tee -a "${LOG_TMP}"
fi


if [ "$1" = "yes" ]; then        # onlyTest = yes => dry-run of the script
    if [ "${chk_RC}" -eq 0 ]; then
        echo -e "I: All is ok." | tee -a "${LOG_TMP}"
    else
        echo -e "I: One or more warning(s)/error(s) found. The warning will be ignored during the execution, but checks the ${SCRIPT_NAME}'s settings anyway." | tee -a "${LOG_TMP}"
    fi
    echo -e "\nProcedure completed at `CURRENT_DATE`"                                   | tee -a "${LOG_TMP}"
    echo -e "======================================================================\n"  | tee -a "${LOG_TMP}"
    exit 0
elif [ "$1" = "no" ]; then       # onlyTest = no => complete run of the script
    if [ ${chk_RC} -eq 0 ]; then
        echo -e "I: All is ok." | tee -a "${LOG_TMP}"
    elif [ ${chk_RC} -eq 1 ]; then
        echo -e "I: One or more warning(s) found. It will be used the alternative parameters.\n" | tee -a "${LOG_TMP}"
    else
        echo -e "I: One or more parameters could be wrong/unassigned or some errors occurred. Please, checks the ${SCRIPT_NAME}'s settings." | tee -a "${LOG_TMP}"
        echo -e "\nProcedure completed at `CURRENT_DATE`"                                   | tee -a "${LOG_TMP}"
        echo -e "======================================================================\n"  | tee -a "${LOG_TMP}"
        exit 1
    fi

    mkdir -p ${MDBCK_BACKUPDIR}/{hourly,daily,weekly,monthly,latest,log}  # Executed if chk_RC is 0 or 1
    if [ $? -eq 0 ]; then
        chmod 750 ${MDBCK_BACKUPDIR}/{hourly,daily,weekly,monthly,latest,log} >/dev/null 2>&1
        chown -R mongod:mongod ${MDBCK_BACKUPDIR} >/dev/null 2>&1
    else
        echo -e "E: OS: an error occurred during the MDBCK_BACKUPDIR's subdirectory creation." | tee -a "${LOG_TMP}"
        echo -e "\nProcedure completed at `CURRENT_DATE`"                                   | tee -a "${LOG_TMP}"
        echo -e "======================================================================\n"  | tee -a "${LOG_TMP}"
        exit 1
    fi
fi

} # chkParameters



chkSelectRoleMember() {

# This function allows to check or select the role of a member.
# If you pass a single parameter (one of these: "ismaster" or "secondary"),
# the function will find the respective role of mongo member(s).
# However, if you pass two parameters (dbhost and dbport), the function will checks
# if this node is an arbiter.


    # We will use indirect-reference hack to return variable from this function.
    if [ $# -eq 1 ]; then
        local __role_member=$1

        # ver. 4.3.5
        if [ -n "${MDBCK_DBURI}" ]; then
            CMD="--host ${MDBCK_DBURI}"
        else
            CMD="--host ${MDBCK_DBHOST}:${MDBCK_DBPORT}"
            if [ -n "${MDBCK_DBUSERNAME}" ]; then
                OPTSEC="$OPTSEC --username=${MDBCK_DBUSERNAME} --password=${MDBCK_DBPASSWORD}"
                if [ "${MDBCK_REQUIREMDBCK_DBAUTHDB}" = "yes" ]; then
                    OPTSEC="${OPTSEC} --authenticationDatabase=${MDBCK_DBAUTHDB}"
                fi
                CMD="${CMD} ${OPTSEC}"
            fi
        fi

        chkMongoConnection "${CMD}"
        __rc=$?
        [ ${__rc} -ne 0 ] && return ${__rc}

        members=( $(mongo --quiet ${CMD} --eval 'rs.conf().members.forEach(function(x){ print(x.host + "_" + x.arbiterOnly) })') )
        # Check each replset member to see if it's a primary or secondary and return it.
        if [ ${#members[@]} -gt 0 ]; then
            for member in "${members[@]}"; do
                echo ${member} | grep -q "true" # Check if the node is not an arbiter
                if [ $? -eq 0 ]; then
                    continue
                else
                    _member=$(echo ${member} | awk '{print $1}' FS="_")

                    role_member=$(mongo --quiet --host ${_member} --eval "rs.isMaster().${__role_member}" $OPTSEC )

                    if [ "${__role_member}" = "ismaster" ]; then
                        case "${role_member}" in
                            'true') primary="${_member}"
                                    eval $__role_member="'${primary}'"
                                    break
                                    ;;
                                 *) continue
                                    ;;
                        esac
                    elif [ "${__role_member}" = "secondary" ]; then
                        case "${role_member}" in
                            'true') secondary="${_member}"
                                    eval $__role_member="'${secondary}'"
                                    break
                                    ;;
                                 *) continue
                                    ;;
                        esac
                    fi
                fi
            done
        fi
    elif [ $# -eq 2 ]; then
      ###  chkMongoConnection ${1} ${2} ; __rc=$?
      ###  [ ${__rc} -ne 0 ] && return ${__rc}
        result=$(mongo --quiet --host $1:$2 --eval "rs.isMaster().arbiterOnly")
        [ "${result}" = "true" ] && return 0 || return 1
    else
        return 2
    fi

    # Return list of with all replica set members
    # shellcheck disable=SC2086

} # chkSelectRoleMember



chkTcpConnection() {
  if [ -n $1 -a -n $2 ]; then
      (echo > /dev/tcp/$1/$2) >/dev/null 2>&1 && return 0 || return 1
  else
      return 2
  fi
}



chOwnPerm() {
# Setting owner and permission to new backup

## ---
## v.4.3.9
## ---
  echo -e "`CURRENT_DATE` - I: Setting the right owner and permissions to \"$1\"... \c"
##  touch -t "${Y}${m}${d}${H}${M}.00" "$1" # to avoid retention issues, it will be changed the modify date to the dump file.
##  if [ $? -eq 0 ]; then
  if [ -f $1 ]; then
      chmod 640 "$1" >/dev/null 2>&1
  elif [ -d $1 ]; then
      chmod 750 "$1" >/dev/null 2>&1
  fi
  [ $? -eq 0 ] && _rc=0 || _rc=1

  chown -R mongod:mongod "$1" >/dev/null 2>&1
  [ $? -ne 0 ] && _rc=1

  [ ${_rc} -eq 0 ] && echo "Done." || echo -e "\n`CURRENT_DATE` - W: OS: operation failed."

} # chOwnPerm



# Compression function plus latest copy
compression() {
    dir=$(dirname "$1")
    file=$(basename "$1")
    if [ -n "${MDBCK_COMP}" ]; then
        if [ "${MDBCK_COMP}" = "gzip" ]; then
            SUFFIX="${SUFFIX}tgz"
        elif [ "${MDBCK_COMP}" = "bzip2" ]; then
            SUFFIX="${SUFFIX}tar.bz2"
        else
            echo "`CURRENT_DATE` - W: Bad value: the MDBCK_COMP parameter allows strings as: gzip or bzip2. The dump destination will not be compressed."
            return 99
        fi
        echo -e "`CURRENT_DATE` - I: Tar and ${MDBCK_COMP} of \"$file$SUFFIX\"... \c"
        cd "$dir"
        if [ $? -ne 0 ]; then
            echo -e "\n`CURRENT_DATE` - W: OS: change dir to \"${dir}\" failed. The compression will not be run."
            return 99
        fi
        tar -cf - "$file" | ${MDBCK_COMP} --stdout | write_file "${file}${SUFFIX}"

        if [ $? -eq 0 ]; then
            echo "Done."
            chOwnPerm ${file}${SUFFIX}
            chOwnPerm $1

            if [ "${MDBCK_LATEST}" = "yes" ]; then
                if [ "${MDBCK_LATESTLINK}" = "yes" ]; then
      	   	       COPY="ln"
      	        else
      	           COPY="cp -p"
      	        fi

                if [ -d "${MDBCK_BACKUPDIR}"/latest ]; then
                    rm -rf "${MDBCK_BACKUPDIR}"/latest/* > /dev/null 2>&1
                    ${COPY} "$1$SUFFIX" "$MDBCK_BACKUPDIR/latest/"
                else
                    echo -e "`CURRENT_DATE` - W: OS: the \"${MDBCK_BACKUPDIR}/latest\" not exists or it is not a directory. MDBCK_LATEST not created."
                fi
      	    fi

          	if [ "${MDBCK_CLEANUP}" = "yes" ]; then
          	    echo -e "`CURRENT_DATE` - I: Cleaning the dump destination... \c"
                if [ -d $1 ]; then
                    rm -rf "$1" > /dev/null 2>&1
                    if [ $? -ne 0 ]; then
                        echo -e "\n`CURRENT_DATE` - W: OS: an issue occurred during the cleaning."
                        return 99
                    else
                        echo "Done."
                    fi
                else
                    echo -e "\n`CURRENT_DATE` - W: OS: the path \"$1\" not exists or it is not a directory. Cleaning not run."
                    return 99
                fi
          	fi

            cd - >/dev/null
            if [ $? -ne 0 ]; then
                echo -e "`CURRENT_DATE` - W: OS: change dir to \"${dir}\" failed."
                return 99
            fi
        else
            echo "`CURRENT_DATE` - W: OS: compression failed."
            return 99
        fi
    else
        echo "`CURRENT_DATE` - W: Value not assigned: the MDBCK_COMP parameter allows strings as: gzip or bzip2. The dump destination will not be compressed."
        return 99
    fi

    return 0
} # compression



currentUsedSpace() {
du -sh $1
}



# Database dump function
dbdump () {

    CMD="--host=${MDBCK_DBHOST}:${MDBCK_DBPORT} --out=$1"

    # shellcheck disable=SC2086
		if [ -n "${MDBCK_DBURI}" -a -z "${secondary}" ]; then
		    CMD="--uri \"${MDBCK_DBURI}\" --out=$1"
		else
		    if [ -n "${MDBCK_DBUSERNAME}" ]; then
				    OPT="${OPT} --username=${MDBCK_DBUSERNAME} --password=${MDBCK_DBPASSWORD}"
			      if [ "${MDBCK_REQUIREMDBCK_DBAUTHDB}" = "yes" ]; then
					      OPT="${OPT} --authenticationDatabase=${MDBCK_DBAUTHDB}"
				    fi
			  fi
		fi

    [ -n "${QUERY}" ] && CMD="${CMD} -q ${QUERY}"

    CMD="${CMD} ${OPT}"

    mongodump ${CMD} ; MDUMPSTATUS=$?

    if [ -e "$1" ]; then
        if [ "$MDUMPSTATUS" -ne 0 ]; then
            echo "`CURRENT_DATE` - E: OS: an issue occurred during the mongodump. Please, look the mongodump log file."
        fi
    else
        echo "`CURRENT_DATE` - W: OS: the dump destination doesn't exist. Please, look the mongodump log file."
        MDUMPSTATUS=1
    fi

    return ${MDUMPSTATUS}
} # dbdump


forcePurgeBckDest() {

  if [ "${MDBCK_PURGE_BCKDIR_SPACE}" = "yes" ]; then
      echo -e "`CURRENT_DATE` - I: Checking disk space... \c"
      if [ "${RETENTION_TYPE}" != "${RETENTION_TYPE_LIST[0]}" ]; then # Check the right retention config
          # ---
          # Delete 1 oldest backup copy
          # ---
          if [ "${_BACKUPDIR_IS_MOUNT_POINT}" = "true" ]; then
              echo "Primo passo"
              _sizeBackupDir=$( (df ${_BACKUPDIR} --block-size=K | column -t | awk '{print $4}' | tail -1) 2> /dev/null)
          else
              echo "Secondo passo"
              _sizeBackupDir=$( (df / --block-size=K | tail -1 | awk '{print $4}') 2> /dev/null)
          fi
          _sizeBackupDir=${_sizeBackupDir%%K*}

          _backup_list_timeOrder=($(ls -tr --block-size=K ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}))
          _backup_list_sizeOrder=($(ls -Sr --block-size=K ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}))
          _cnt_backup_list=${#_backup_list_timeOrder[@]}
          if [ ${_cnt_backup_list} -gt 0 ]; then
              _file2delete=(${_backup_list_timeOrder[@]:0:1})
              _file2delete=${_file2delete%%K*}

              _file2chkSize=(${_backup_list_sizeOrder[-1]})
              _file2chkSize=${_file2chkSize%%K*}

              _sizeFile=$(du -BK ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}/${_file2chkSize} | cut -f 1)
              _sizeFile=${_sizeFile%%K*}

              if [ ! ${_sizeFile} -lt ${_sizeBackupDir} ]; then
                  echo -e "It's not enough. The oldest backup \"${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}/${_file2delete}\" will be deleted... \c"
                  set -o pipefail
                  rm -fR ${MDBCK_BACKUPDIR}/${KIND_BCK_POLICY,,}/${_file2delete} 2>&1
                  [ $? -ne 0 ] && echo -e "\n`CURRENT_DATE` - E: OS: An error occurred removing \"${_file2delete}\". " || _rc=0
                  rm -fR ${MDBCK_BACKUPDIR}/log/${_file2delete/\.tgz/\.log} 2>&1
                  [ $? -ne 0 ] && echo -e "\n`CURRENT_DATE` - E: OS: An error occurred removing \"${_file2delete/\.tgz/\.log}\". " || _rc=0
                  set +o pipefail
                  [ ${_rc} -eq 0 ] && echo -e "Done."
              else
                  echo -e "It's ok."
              fi
          # ---
          else
              echo -e "\n`CURRENT_DATE` - I: There aren't backup pieces to compare with the current destination size (${_sizeBackupDir} bytes)."
          fi
      else
          echo -e "\n`CURRENT_DATE` - I: The retention is ${RETENTION_TYPE}. So the backup will already be overwritten."
      fi
  fi
}


help() {
    echo -e "\n****************************************************"
    echo -e "* ${SCRIPT_NAME} - ver. ${VER} (at ${VER_DATE})"
    echo -e "****************************************************"
    echo -e "\nThis command allows to execute the mongodump with retention management."
    echo -e "\nUsage: $(basename $0) <option>"
    echo -e "\nwhere option should be:\n"
    echo -e "    --conf | -c : used to load an extetnal configuration file."
    echo -e "    --help | -? : this help."
    echo -e "    --test | -t : used to test the parameter assigned (dry-run).\n"
}



loadVars() {
# ---
# Vars
# ---
echo -e "Loading parameters... \c"
PARAMS="Internal."

[ `echo $PATH | grep -Fc "/bin"` -eq 0 ] && PATH=/bin:$PATH
[ `echo $PATH | grep -Fc "/usr/bin"` -eq 0 ] && PATH=/usr/bin:$PATH
[ `echo $PATH | grep -Fc "/usr/local/bin"` -eq 0 ] && PATH=/usr/local/bin:$PATH
alias CURRENT_DATE='date +"%Y.%m.%d %H:%M:%S"'
DATE=$(date +%Y%m%d-%Hh%Mm)                       # Datestamp e.g 2002-09-21
HOD=$(date +%s)                                   # Current timestamp for PITR backup
DOW=$(date +%A)                                   # Day of the week e.g. Monday
DNOW=$(date +%u)                                  # Day number of the week 1 to 7 where 1 represents Monday
DOM=$(date +%d)                                   # Date of the Month e.g. 27
M=$(date +%B)                                     # Month e.g January
W=$(date +%V)                                     # Week Number e.g 37
VER="4.4.1"                                           # Version Number
VER_DATE="2023.02.16"
OPT=""                                            # OPT string for use with mongodump
OPTSEC=""                                         # OPT string for use with mongodump in chkSelectRoleMember function
QUERY=""                                          # QUERY string for use with mongodump
HOURLYQUERY=""                                    # HOURLYQUERY string for use with mongodump
SCRIPT_NAME="AutoMongoBackup"
LOG_TMP="/tmp/${SCRIPT_NAME}.log.tmp"
ALLOWED_PATH=("^(\/home).+[^\/]$" "^(\/mnt).+[^\/]$" "^(\/opt).+[^\/]$" "^(\/).*[^\/.]$")
DISCARDED_PATH=("\.+" "^(\/bin).*" "^(\/boot).*" "^(\/dev).*" "^(\/etc).*" "^(\/home)(.{0})$" "^(\/mnt)(.{0})$" "^(\/opt)(.{0})$" "^(\/proc).*" "^(\/root).*" "^(\/run).*" "^(\/sbin).*" "^(\/srv).*" "^(\/sys).*" "^(\/tmp).*" "^(\/usr).*" "^(\/var).*" "^(\/).{0}$")
ALLOWED_PATH_LIST=("/" "/home" "/media" "/mnt" "/opt")

# Default assignement
# ---
MDBCK_DBPORT_TRY_DEFAULT="${MDBCK_DBPORT_TRY_DEFAULT:-"no"}"
# ---
MDBCK_DODAILY="${MDBCK_DODAILY:-"no"}"
MDBCK_DOHOURLY="${MDBCK_DOHOURLY:-"no"}"
MDBCK_DOMONTHLY="${MDBCK_DOMONTHLY:-"no"}"
MDBCK_DOWEEKLY="${MDBCK_DOWEEKLY:-"no"}"
# ---
KIND_BCK_POLICY=""
MDBCK_DAILYRETENTION="${MDBCK_DAILYRETENTION:-1}"
MDBCK_HOURLYRETENTION="${MDBCK_HOURLYRETENTION:-1}"
MDBCK_MONTHLYRETENTION="${MDBCK_MONTHLYRETENTION:-1}"
MDBCK_WEEKLYRETENTION="${MDBCK_WEEKLYRETENTION:-1}"
# ---
MDBCK_CLEANUP="${MDBCK_CLEANUP:-"no"}"
MDBCK_LATEST="${MDBCK_LATEST:-"no"}"
MDBCK_LATESTLINK="${MDBCK_LATESTLINK:-"no"}"
SUFFIX="${SUFFIX:-"."}"
# ---
MDBCK_MONGOCOMP="${MDBCK_MONGOCOMP:-"yes"}"
MDBCK_OPLOG="${MDBCK_OPLOG:-"no"}"
MDBCK_PURGE_BCKDIR_SPACE="${MDBCK_PURGE_BCKDIR_SPACE:-"no"}"
MDBCK_REPLICAONSLAVE="${MDBCK_REPLICAONSLAVE:-"yes"}"
MDBCK_REQUIREMDBCK_DBAUTHDB="${MDBCK_REQUIREMDBCK_DBAUTHDB:-"no"}"
# ---

echo -e "done."

} # loadVars


loadOverridingVars() {
# External config - override default values set above

for x in default sysconfig;
do
    if [ -f "/etc/$x/automongobackup" ]; then
       # shellcheck source=/dev/null
       echo -e "Overriding script's parameters by /etc/$x/automongobackup." | tee -a "${LOG_TMP}"
       source /etc/$x/automongobackup
       PARAMS="Automongobackup configuration file(s)."
    fi
done

}


shellout () {
# This function is used to print to the screen a message and exit with return code 1.
# If the second parameter will be passed, the function will print on the screen and
# to a file.
# If the third parameter will be passed, exit.

if [ -n "$1" ]; then
    if [ -n "$2" ]; then
        echo -e "${1}" | tee -a "${2}"
    else
        echo "$1"
    fi
    exit 1
else
    exit 0
fi
} # shellout


if [ -n "${MDBCK_MAXFILESIZE}" ]; then
    write_file() {
        split --bytes "$MDBCK_MAXFILESIZE" --numeric-suffixes - "${1}-"
    }
else
    write_file() {
        cat > "$1"
    }
fi



#
# Main
#


# ---
# Args in. Must be declared outside a function to work!
# ---
ArgsCount=$#           # Checks how many arguments are passed to the script.
# ---
#interactvie="no"       # Used to specify if the log report will be shown at the end of the procedure
                       # or during it.
onlyTest="no"          # Used to identify the dry-run or complete execution of the script.
# ---

set -x
loadVars
loadOverridingVars


while [ $# -gt 0 ]
do
    ArgIn=$1
    ArgIn=${ArgIn:+`echo ${ArgIn,,}`}

    case ${ArgIn} in
# ---
# TOBE
# ---
#        --interact | -i)  interactive="yes"
#                          break
#                          ;;
# ---
        --conf | -c)  if [ -f $2 ]; then
                          PARAMS="Configuration file by cli ($2)."
                          echo ${!MDBCK_*} | xargs -n 1 -r > /tmp/mdbck_ip.list
                          echo -e "Loading configuration file by cli.\n\n"
                          . $2
                          echo -e "Override of $(cat $2 | grep -i MDBCK_ | wc -l)/$(cat /tmp/mdbck_ip.list | wc -l) parameters."
                          [ -f /tmp/mdbck_ip.list ] && rm /tmp/mdbck_ip.list
                      else
                          echo -e "Configuration file \"$2\" doesn't exist. It will proceed with the script's internal parameters.\n\n"
                      fi
                      shift
                      ;;
        --test | -t)  onlyTest="yes"
                      ;;
    --help | -? | *)  help
                      shellout
                      ;;
    esac
    shift
done



echo "======================================================================" | tee "${LOG_TMP}"
echo "* ${SCRIPT_NAME} v.${VER} (at ${VER_DATE})"                             | tee -a "${LOG_TMP}"
echo "======================================================================" | tee -a "${LOG_TMP}"
echo "Starting procedure at `CURRENT_DATE`"                                   | tee -a "${LOG_TMP}"
echo                                                                          | tee -a "${LOG_TMP}"

chkParameters ${onlyTest}

# ---
# Change log: 4.3.7 - 4.3.8
# ---

# Monthly Full Backup of all Databases
BACKUP_TYPE="${KIND_BCK_POLICY^}"
if [ -n "$BACKUP_TYPE" ]; then
    if [[ "${MDBCK_DOMONTHLY}" = "yes" ]]; then
        if [[ $DOM = "01" ]]; then
            FILE="${MDBCK_BACKUPDIR}/${BACKUP_TYPE}/${MDBCK_DBHOST}-${DATE}.${M}"
            BACKUP_TYPE="${BACKUP_TYPE,,} (Retention: $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "delete backup older than ${MDBCK_MONTHLYRETENTION} month(s)" || echo "keep the newest ${MDBCK_MONTHLYRETENTION} backup copies")."
            LOGFILE="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-${DATE}.${M}.log"          	# Logfile Name
            LOGMDB="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-${DATE}.${M}.mdb.log"   	# Logfile Name
        else
            echo -e "W: Monthly backup is enabled. But it will be run only at the 1st day of the month. Today is the \c" | tee -a "${LOG_TMP}"
            if [ ${DOM} -gt 3 ]; then
                echo "${M}, ${DOM}th."
            elif [ ${DOM} -eq 3 ]; then
                echo "${M}, ${DOM}rd."
            else
                echo "${M}, ${DOM}nd."
            fi
        fi

    # Weekly Backup
    elif [[ "${DNOW}" = "${MDBCK_WEEKLYDAY}" ]] && [[ "${MDBCK_DOWEEKLY}" = "yes" ]] ; then
        FILE="$MDBCK_BACKUPDIR/${BACKUP_TYPE,,}/${MDBCK_DBHOST}-week.${W}.${DATE}"
        BACKUP_TYPE="${BACKUP_TYPE} (Retention: $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "delete backup older than ${MDBCK_WEEKLYRETENTION} week(s)" || echo "keep the newest ${MDBCK_WEEKLYRETENTION} backup copies"))"
        LOGFILE="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-week.${W}.${DATE}.log"         	# Logfile Name
        LOGMDB="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-week.${W}.${DATE}.mdb.log"   		# Logfile Name

    # Daily Backup
    elif [[ "${MDBCK_DODAILY}" = "yes" ]] ; then
        FILE="$MDBCK_BACKUPDIR/${BACKUP_TYPE,,}/${MDBCK_DBHOST}-${DATE}.${DOW}"
        BACKUP_TYPE="${BACKUP_TYPE} (Retention: $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "delete backup older than ${MDBCK_DAILYRETENTION} day(s)" || echo "keep the newest ${MDBCK_DAILYRETENTION} backup copies"))"
        LOGFILE="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-${DATE}.${DOW}.log"            # Logfile Name
        LOGMDB="${MDBCK_BACKUPDIR}/log/$MDBCK_DBHOST-${DATE}.${DOW}.mdb.log"           # Logfile Name

    # Hourly Backup
    elif [[ "${MDBCK_DOHOURLY}" = "yes" ]] ; then
        FILE="$MDBCK_BACKUPDIR/${BACKUP_TYPE,,}/${MDBCK_DBHOST}-${DATE}.${DOW}.${HOD}"
        BACKUP_TYPE="${BACKUP_TYPE} (Retention: $([ "${RETENTION_TYPE}" = "${RETENTION_TYPE_LIST[2]}" ] && echo "delete backup older than ${MDBCK_HOURLYRETENTION} hour(s)" || echo "keep the newest ${MDBCK_DAILYRETENTION} backup copies"))"
        LOGFILE="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-${DATE}.${DOW}.${HOD}.log"                # Logfile Name
        LOGMDB="${MDBCK_BACKUPDIR}/log/${MDBCK_DBHOST}-${DATE}.${DOW}.${HOD}.mdb.log"             # Logfile Name
        # convert timestamp to date: echo $TIMESTAMP | gawk '{print strftime("%c", $0)}'

    fi
fi
# ---
echo -e "I: ${SCRIPT_NAME} will execute a mongodump (it could take a while). A complete log report will be shown at the end of the procedure.\n"

# IO redirection for logging.
touch "${LOGFILE}"
exec 6>&1           # Link file descriptor #6 with stdout.
                    # Saves stdout.
exec > "${LOGFILE}"   # stdout replaced with file $LOGFILE.

touch "${LOGMDB}"
exec 7>&2           # Link file descriptor #7 with mongodb messages.
                    # Saves stderr.
exec 2> "${LOGMDB}"   # stderr replaced with file $LOGMDB.


# When a desire is to receive log via e-mail then we close stdout and stderr.
[ "x$MDBCK_MAILCONTENT" == "xlog" ] && exec 6>&- 7>&-


# Hostname for LOG information
if [ "${MDBCK_DBHOST}" = "localhost" ] || [ "${MDBCK_DBHOST}" = "127.0.0.1" ]; then
    HOST=$(hostname)
    if [ "${SOCKET}" ]; then
        OPT="${OPT} --socket=${SOCKET}"
    fi
else
    HOST="${MDBCK_DBHOST}"
fi


echo "======================================================================"
echo
echo "Report"
echo "---"
printf "%-45s@" "Parameters" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo "${PARAMS}"
echo "---"
printf "%-45s@" "Connecting_to" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
if [ -n "${MDBCK_DBURI}" ] && [ ${dburi_cnt_err} -eq 0 ]; then
      echo -e "${MDBCK_DBURI}" | sed -e 's|\(//.*:\).*@|\1\********@|g'
else
      echo -e "${MDBCK_DBHOST}:${MDBCK_DBPORT}"
fi
if [ -z "${MDBCK_DBNAME}" ]; then
    printf "%-45s@%s\n" "Backup_type" "Full" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
else
    printf "%-45s@" "Backup_type" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo -e "${MDBCK_DBNAME}\c"
    [ -n "${MDBCK_COLLECTIONS}" ] && echo -e ".${MDBCK_COLLECTIONS}\c"
    [ -n "${MDBCK_EXCLUDE_COLLECTIONS}" ] && echo " (except: ${MDBCK_EXCLUDE_COLLECTIONS})" || echo ""
fi
printf "%-45s@" "Backup_frequency_&_retention" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo "${BACKUP_TYPE}"
printf "%-45s@" "Including_oplogs" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
if [ "${MDBCK_OPLOG}" = "yes" ] && [ -z "${MDBCK_DBNAME}" ]; then
    echo "Yes"
else
    echo "No"
fi
printf "%-45s@%s\n" "Purge_of_backup_destination" "${MDBCK_PURGE_BCKDIR_SPACE^}" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
[ -n "${MDBCK_REPLICAONSLAVE}" ] && printf "%-45s@%s\n" "Try_to_connect_to_secondary_node_directly" "${MDBCK_REPLICAONSLAVE^}" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
[ -n "${MDBCK_MONGOCOMP}" ] && printf "%-45s@%s\n" "Mongodump_compression" "${MDBCK_MONGOCOMP^}" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
printf "%-45s@" "AutoMongoBackup_compression" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; [ -n "${MDBCK_COMP}" ] && echo "Tar and ${MDBCK_COMP}" || echo "Not set"
printf "%-45s@%s\n" "Link_to_latest_backup" "${MDBCK_LATEST^}" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
[ "${MDBCK_LATEST}" == "yes" ] && {
printf "%-45s@" "Hardlink_or_copy_to_latest" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
[ "${MDBCK_LATESTLINK}" == "yes" ] && echo "Hard link" || echo "Copy"
}
printf "%-45s@%s\n" "Clean_up_dump_destination" "${MDBCK_CLEANUP^}" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
echo "---"
printf "%-45s@" "Backup_home_path" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo "${MDBCK_BACKUPDIR}"
printf "%-45s@" "Mongodump_destination" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g'
if [ -n "${MDBCK_COMP}" ]; then
    if [ "${MDBCK_COMP}" = "gzip" ]; then
        echo "${FILE}.tgz"
    elif [ "${MDBCK_COMP}" = "bzip2" ]; then
        echo "${FILE}.tar.bz2"
    fi
else
    echo "${FILE}"
fi
printf "%-45s@" "Logging_AutoMongoBackup_info_to" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo "${LOGFILE}"
printf "%-45s@" "Logging_mongodump_to" | sed -e 's/ /\./g' -e 's/@/\.: /' -e 's/\_/ /g' ; echo "${LOGMDB}"
echo "---"
echo


# Run command before we begin
if [ "$MDBCK_PREBACKUP" ]; then
    echo ======================================================================
    echo "Prebackup command output."
    echo
    eval "$MDBCK_PREBACKUP"
    echo
    echo ======================================================================
    echo
fi

echo
echo "Backup of Mongo databases `[ "${HOST}" != "${MDBCK_DBHOST}" ] && echo " - running by ${HOST}" `"
echo ======================================================================
echo "Backup started - $(date)"
echo ======================================================================


# ---
# Change log: v.4.3.8
# ---
# Deleted mongobackup type
# ---

forcePurgeBckDest

dbdump "${FILE}" ; STATUS=$?
## ---
## v.4.3.9
## ---
Y=$(date +'%Y')
m=$(date +'%m')
d=$(date +'%d')
H=$(date +'%H')
M=$(date +'%M' -d '-2 mins')
if [ ${STATUS} -eq 0 ]; then # returned by dbdump
    if [ -n "${MDBCK_COMP}" ]; then
        compression "${FILE}" ; STATUS=$?
    else
        chOwnPerm "${FILE}"
    fi

    if [ ${STATUS} -eq 0 ]; then # returned by compression. if compression did not run, STATUS will be equal to the dbdump returned value.
        chkObsolete
    else
        echo "`CURRENT_DATE` - W: The retention clean up has not been executed."
        if [ -e "${FILE}${SUFFIX}" ]; then
            echo -e "`CURRENT_DATE` - I: The compressed file ${FILE}[${SUFFIX}] will be deleted to avoid to allocate space... \c"
            rm -f "${FILE}${SUFFIX}" > /dev/null 2>&1
            [ $? -eq 0 ] && echo "Done." || echo -e "\n`CURRENT_DATE` - W: OS: no compressed file found. Could it has been deleted by mistake?"
        fi
    fi
else
    echo "`CURRENT_DATE` - W: The retention clean up has not been executed."
    if [ -e "${FILE}" ]; then
        echo -e "`CURRENT_DATE` - I: The dump destination will be deleted to avoid to allocate space... \c"
        rm -fR "${FILE}" > /dev/null 2>&1
        [ $? -eq 0 ] && echo "Done." || echo -e "\n`CURRENT_DATE` - W: OS: no dump destination found. Could it has been deleted by mistake?"
    fi
fi


echo ======================================================================
echo "Backup finished `[ ${STATUS} -eq 0 ] && echo "successfully" || echo "with error/warning"` - $(date)"
echo ======================================================================
echo
echo -e "* Backup space usage *\n"
printf "%-5s - %s\n" "Size" "Path"
currentUsedSpace ${MDBCK_BACKUPDIR}/*
echo ======================================================================


# Run command when we're done
if [ "${MDBCK_POSTBACKUP}" ]; then
    echo
    echo ======================================================================
    echo "Postbackup command output."
    echo
    eval "${MDBCK_POSTBACKUP}"
    echo
    echo ======================================================================
fi


echo
cat "${LOGFILE}" >> "${LOG_TMP}"
mv "${LOG_TMP}" "${LOGFILE}"
chOwnPerm "${LOGFILE}"
chOwnPerm "${LOGMDB}"

# Clean up IO redirection if we plan not to deliver log via e-mail.
[ ! "x$MDBCK_MAILCONTENT" == "xlog" ] && exec 1>&6 2>&7 6>&- 7>&-

if [ -s "${LOGFILE}" ]; then
    cat "${LOGFILE}"
fi

###
# Mail send to check. Temporary excluded
###
###if [ -s "$LOGMDB" ]; then
###    eval "$SED" "/^connected/d" "$LOGMDB"
###fi
###
###if [ "$MDBCK_MAILCONTENT" = "log" ]; then
###    mail -s "Mongo Backup Log for $HOST - $DATE" "$MAILADDR" < "$LOGFILE"
###
###    if [ -s "$LOGMDB" ]; then
###        cat "$LOGMDB"
###        mail -s "ERRORS REPORTED: Mongo Backup error Log for $HOST - $DATE" "$MAILADDR" < "$LOGMDB"
###    fi
###else
###    if [ -s "$LOGMDB" ] && [ ${MDUMPSTATUS} -ne 0 ]; then
###        cat "$LOGFILE"
###        echo
###        echo "###### WARNING ######"
###        echo "STDERR written to during mongodump execution."
###        echo "The backup probably succeeded, as mongodump sometimes writes to STDERR, but you may wish to scan the error log below:"
###	      echo
###	      echo
###        cat "$LOGMDB"
###    else
###        cat "$LOGFILE"
###    fi
###fi

# TODO: Would be nice to know if there were any *actual* errors in the $LOGMDB
#$STATUS=0
#if [ -s "$LOGMDB" ]; then
#    STATUS=1
#fi

# v4.3.5
# Clean up Logfile
#rm -f "$LOGFILE" "$LOGMDB"
set +x
exit ${STATUS}
