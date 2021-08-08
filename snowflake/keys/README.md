# Credentials management

## Snowflake

### Create your account

To use snowflake need to create a free trial: https://signup.snowflake.com/trial

You can select a Standard Snowflake edition over several clouds. 
After validate email and access to the web console, you can see that exists:

- The host accessed in the URL is your configuration for the snowflake connector
- In left panel, you can see the DEMO_DB database with a PUBLIC schema
- In top-right panel, you can see 
  - Your role (SYSADMIN)
  - Your warehouse (COMPUTE_WH)

### Create your key pair

In [Kafka connector install - Using Key Pair Authentication & Key Rotation], you can 
see more detail about it. 

To simplify the management, we generate a unencrypted private key (and a public key) 
to use with snowflake:

```sh
openssl genrsa -out docker/credentials/snowflake_rsa_key.pem 2048
openssl rsa -in docker/credentials/snowflake_rsa_key.pem -pubout -out docker/credentials/snowflake_rsa_key.pub
```

If you don't have a [OpenSSL tookit] installed in your environment, you can run 
this commands with docker:

```sh
docker run -v $PWD:/work -it nginx openssl genrsa -out /work/docker/credentials/snowflake_rsa_key.pem 2048
docker run -v $PWD:/work -it nginx openssl rsa -in /work/docker/credentials/snowflake_rsa_key.pem -pubout -out /work/docker/credentials/snowflake_rsa_key.pub
sudo chown -R $USER:$USER docker/credentials/*
```

The content of the keys is similar to the content in this repo 
(we upload a valid cert, but it doesn't authenticate with our trial snowflake service)

```sh
cat docker/credentials/snowflake_rsa_key.pem
-----BEGIN RSA PRIVATE KEY-----
MIIE6TAbBgkqhkiG9w0BBQMwDgQILYPyCppzOwECAggABIIEyLiGSpeeGSe3xHP1
wHLjfCYycUPennlX2bd8yX8xOxGSGfvB+99+PmSlex0FmY9ov1J8H1H9Y3lMWXbL
...
-----END RSA PRIVATE KEY-----
```
```sh
cat docker/credentials/snowflake_rsa_key.pub
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy+Fw2qv4Roud3l6tjPH4
zxybHjmZ5rhtCz9jppCV8UTWvEXxa88IGRIHbJ/PwKW/mR8LXdfI7l/9vCMXX4mk
...
-----END PUBLIC KEY-----
```

### Registry key pair in snowflake

Access it to the snowflake web console, and locate on top-right your username.
In the snowflake documentation refers swicth your role to SECURITYADMIN, but 
in our case need to change to ACCOUNTADMIN.

Take your public key (without header and footer) and use it to registry in snowflake 
using the web console over your user:

```sql
alter user dariocazas set rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArJFv7/40nuy8D4FC76wQ
Qkz1FHnEhS8jvXVTrSGzlJoTRrKm3Nx039+PPgz0EkzW/WiUdyPF6G4ZJh5L9+WU
6xEQo9HGFJhA4U4rOOXv9q3SlZEMndpg9qbGd6mp/ym5GZ9lznBVc33oQO2lIWum
j8EmuYn7SLpceY7iCUtCrGgu2gE+OxHcajvQPccdMtNlz+LfXXCe+4By7PGQuBkR
9wO0wkhoYfRdInvATRSpGJK8jtAmxe9UelobyeEFsbFVqsXruOw1LbNF2bq3IAaQ
TvD5OVYcfyQ+nDrE55AngRAfewpur09laqYfqzYvVZjutZc2InD4VuSVouGc8bYg
qwIDAQAB';
```

After do this, you can use the __snowflake_rsa_key.pem__ private key from kafka
connect.

[Kafka connector install - Using Key Pair Authentication & Key Rotation]: https://docs.snowflake.com/en/user-guide/kafka-connector-install.html#using-key-pair-authentication-key-rotation
