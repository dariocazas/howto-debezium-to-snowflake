-- Insert six products in two sentences
INSERT INTO product(name, description)
SELECT name, concat('Description for ', name)
    FROM (
        VALUES ('Harley Davidson Ultimate Chopper'),
            ('1996 Moto Guzzi 1100i')
    ) t (name)
;
INSERT INTO product(name, description)
SELECT name, concat('Description for ', name)
    FROM (
        VALUES ('1985 Toyota Supra'),
            ('1957 Ford Thunderbird'),
            ('1938 Cadillac V-16 Presidential Limousine'),
            ('1982 Lamborghini Diablo')
    ) t (name)
;
-- Update last two descriptions
UPDATE product 
    SET description=concat('(Update ', NOW(), ') - Desc. for ', name)
    WHERE id in (
        SELECT id FROM product ORDER BY id DESC LIMIT 2
    )
;
-- Update first description
UPDATE product 
    SET description=concat('(Up. ', NOW(), ') - Desc. for ', name)
    WHERE id in (
        SELECT min(id) FROM product
    )
;
-- Delete last product
DELETE FROM product 
    WHERE id in (
        SELECT id FROM product ORDER BY id DESC LIMIT 1
    )
;
-- Show actual state
SELECT * FROM product ORDER BY id
;