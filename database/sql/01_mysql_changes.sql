-- Insert six users in three sentences
INSERT INTO users(name, email, password) 
SELECT 'Lara', concat('lara', LEFT(UUID(), 4), '@email.com'), LEFT(UUID(), 25)
;
INSERT INTO users(name, email, password) 
SELECT 'Jackson', concat('jackson', LEFT(UUID(), 4), '@email.com'), LEFT(UUID(), 25)
;
INSERT INTO users(name, email, password) 
SELECT name, concat(lower(name), LEFT(UUID(), 4), '@email.com'), LEFT(UUID(), 25)
FROM (
    SELECT 'Hana' AS name
    UNION SELECT 'Morgan'
    UNION SELECT 'Willie'
    UNION SELECT 'Bruce'
) t;
-- Update last two user passwords
UPDATE users SET password=LEFT(UUID(), 10) ORDER BY id DESC LIMIT 2
;
-- Update first user password
UPDATE users SET password=LEFT(UUID(), 5) ORDER BY id LIMIT 1
;
-- Delete last user
DELETE FROM users ORDER BY id DESC LIMIT 1
;
-- Show actual state
SELECT * FROM users ORDER BY id
;