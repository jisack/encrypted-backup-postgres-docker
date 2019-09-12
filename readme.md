# Manual setup backup Postgresql

## Step 1 Setup key
```sh
openssl req -x509 -nodes -days 1000000 -newkey rsa:4096 \
-keyout backup_key.pem \
-out backup_key.pem.pub
```

Result will get 2 file 
  	* backup_key.pem (private key for dencrypt)
  	* backup_key.pem.pub  (public key for encrypt)

## Step 2 manual command to execute dump and encrypt
```sh
pg_dump --dbname=${dbname} --username=${username} --no-password | bzip2 | openssl smime -encrypt -aes256 -binary \
-outform DEM -out my_database.sql.bz2.ssl backup_key.pem.pub
```

Result will get backup with encrypted file
	* my_database.sql.bz2.ssl

## Step 3 Automate script to execute dump and encrypt file

[Encrypt Script](./backup_encrypt.sh)

execute via crontab or any background process interval with this command

```sh
sh /backup_encrypt.sh ${my-database-name}
```

Result will output 
	* my-database-name_2019-09-10-03-06-58.sql.bz2.enc

## Step 4 Decrypt a encrypted file
```sh
# Decrypt to a file using private key
openssl smime -decrypt -in ${encrypt_file}.sql.bz2.ssl -binary \
-inform DEM -inkey backup_key.pem -out ${decrypt_file}.sql.bz2

# Decrypt to stdout using private key
openssl smime -decrypt -in ${encrypt_file}.sql.bz2.ssl -binary \
-inform DEM -inkey backup_key.pem -out ${decrypt_file}.sql.bz2
```

Reference 
[Encrypted Postgres Backups | Imaginary Landscape](https://www.imagescape.com/blog/2015/12/18/encrypted-postgres-backups/)
