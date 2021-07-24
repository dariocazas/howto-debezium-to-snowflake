-- Set public key in snowflake to your user account to enable access via kafka connect

-- Snowflake doc refers to SECURITYADMIN, but for me didn't work (I need use ACCOUNTADMIN)
-- https://docs.snowflake.com/en/user-guide/kafka-connector-install.html#using-key-pair-authentication-key-rotation
use role accountadmin;

alter user dariocazas set rsa_public_key='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArJFv7/40nuy8D4FC76wQ
Qkz1FHnEhS8jvXVTrSGzlJoTRrKm3Nx039+PPgz0EkzW/WiUdyPF6G4ZJh5L9+WU
6xEQo9HGFJhA4U4rOOXv9q3SlZEMndpg9qbGd6mp/ym5GZ9lznBVc33oQO2lIWum
j8EmuYn7SLpceY7iCUtCrGgu2gE+OxHcajvQPccdMtNlz+LfXXCe+4By7PGQuBkR
9wO0wkhoYfRdInvATRSpGJK8jtAmxe9UelobyeEFsbFVqsXruOw1LbNF2bq3IAaQ
TvD5OVYcfyQ+nDrE55AngRAfewpur09laqYfqzYvVZjutZc2InD4VuSVouGc8bYg
qwIDAQAB';

