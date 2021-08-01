CREATE TABLE product (
    id serial PRIMARY KEY,
    name VARCHAR(100), 
    description VARCHAR(255),
    created_on TIMESTAMP NOT NULL DEFAULT NOW()
);
