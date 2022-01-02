# Credentials management

## Snowflake

### Create your account

To use snowflake need to create a free trial: https://signup.snowflake.com

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
cd snowflake/keys
openssl genrsa -out snowflake_rsa_key.pem 2048
openssl pkcs8 -topk8 -inform PEM -in snowflake_rsa_key.pem -out snowflake_rsa_key.p8
openssl rsa -in snowflake_rsa_key.p8 -pubout -out snowflake_rsa_key.pub
```

If you don't have a [OpenSSL toolkit] installed in your environment, you can run 
this commands with docker:

```sh
cd snowflake
docker run -v $PWD:/work -it nginx openssl genrsa -out /work/keys/snowflake_rsa_key.pem 2048
docker run -v $PWD:/work -it nginx openssl pkcs8 -topk8 -inform PEM -in /work/keys/snowflake_rsa_key.pem -out /work/keys/snowflake_rsa_key.p8
docker run -v $PWD:/work -it nginx openssl rsa -in /work/keys/snowflake_rsa_key.pem -pubout -out /work/keys/snowflake_rsa_key.pub
sudo chown -R $USER:$USER keys/*
```

The content of the keys is similar to the content in this repo 
(we upload a valid cert, but it doesn't authenticate with our trial snowflake service)

```sh
cat docker/credentials/snowflake_rsa_key.pem
-----BEGIN ENCRYPTED PRIVATE KEY-----
MIIFLTBXBgkqhkiG9w0BBQ0wSjApBgkqhkiG9w0BBQwwHAQIHl29yM4BvgICAggA
MAwGCCqGSIb3DQIJBQAwHQYJYIZIAWUDBAEqBBCkFIfNB88Urq5VaPCCzze1BIIE
...
-----END ENCRYPTED PRIVATE KEY-----
```
```sh
cat docker/credentials/snowflake_rsa_key.pub
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwBwYbPtbEUXueQ6u3KDw
zlKu4IhAkGdcUBVbdTdUVBLNVsZX+eiKOedN3EnMtDeVzRlaT8JAwHX0LVXkgXtn
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
alter user dariocazas set rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwBwYbPtbEUXueQ6u3KDw
zlKu4IhAkGdcUBVbdTdUVBLNVsZX+eiKOedN3EnMtDeVzRlaT8JAwHX0LVXkgXtn
KzMBp6TpS4j+2kKvbZc5p0KfZHjn42G+C/DXI4ZNQZEBQ/Q4UY6OkTZepFaOX3ev
2icxB6LnnVYI3WHkSnq3vTthhYhTuUOQ4YRudadOtoT4By09hxbsaanVl42FXIZP
AXX1jwawzKe52V1+FB5/UMv+JMUFfczlO+acn/EaZvKbR55Vk/+OVrUP4KIKvdWn
s/n4ASYqxiw9xjrizGCoUyl+b+Ch6A02fTU02HrT9jOOj+dVAeFD2QGOqaze0eCD
dwIDAQAB';
```

After do this, you can use the __snowflake_rsa_key.pem__ private key from kafka
connect.

[Kafka connector install - Using Key Pair Authentication & Key Rotation]: https://docs.snowflake.com/en/user-guide/kafka-connector-install.html#using-key-pair-authentication-key-rotation
