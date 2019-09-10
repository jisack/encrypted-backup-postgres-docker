#!/bin/bash
# #######################
# Postgresql database backup script.
# - this runs out of the postgres user's crontab
# - this runs once per day
# - this takes a database name as the first argument
# - this compresses the dump with bzip2 compression
# - this encrypts the dump with aes 256 and  
#  
# To extract:
# You need the private key associated with the
# public key defined by the backup_public_key variable.
#
#   openssl smime -decrypt -in my_database.sql.sql.bz2.enc -binary -inform DEM -inkey private.pem | bzcat >  my_database.sql.sql
#
# #######################
# Database Name
database_name="$1"
backup_public_key="/secrets/backup_key.pem.pub"
# Location to place backups.
backup_dir="/pg_backup/"
# Numbers of days you want to keep copies of your databases
number_of_days=30
if [ -z ${database_name} ]
then
 echo "Please specify a database name as the first argument"
 exit 1
fi
# String to append to the name of the backup files
backup_date=`date +%Y-%m-%d-%H-%M-%S`
echo "Dumping ${database_name} to ${backup_dir}${database_name}\_${backup_date}.sql.bz2.enc"
pg_dump dbname=${database_name} --username=${POSTGRES_USER} --no-password|bzip2|openssl smime -encrypt \
 -aes256 -binary -outform DEM \
 -out ${backup_dir}${database_name}\_${backup_date}.sql.bz2.enc \
 "${backup_public_key}"
find ${backup_dir} -type f -prune -mtime \
    +${number_of_days} -exec rm -f {} \;