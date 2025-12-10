# Jeu de TU (tests unitaires)
# Requêtes pour l'user : db_admin
CREATE TABLE plumid.test_admin (id INT);
DROP TABLE plumid.test_admin;

ALTER TABLE plumid.species ADD COLUMN test_col INT;
ALTER TABLE plumid.species DROP COLUMN test_col;

CREATE USER 'test_user'@'%' IDENTIFIED BY 'testmdp';
GRANT SELECT ON plumid.* TO 'test_user'@'%';
DROP USER 'test_user'@'%';

# Requêtes pour l'user : plumid_app
# Test 1 — SELECT (DOIT RÉUSSIR)
SELECT * FROM plumid.species LIMIT 1;

# Test 2 — SELECT (DOIT RÉUSSIR)
INSERT INTO plumid.species (sex, region, environment, information, species_name) VALUES ('M', 'Occitanie', 'env', 'toto', 'moi');

# Test 3 — SELECT (DOIT RÉUSSIR)
UPDATE plumid.species SET species_name='Anass' WHERE environment='env';

# Test 4 — SELECT (DOIT RÉUSSIR)
DELETE FROM plumid.species WHERE environment='env';

# Test 5 — DROP TABLE (DOIT ÉCHOUER)
CREATE TABLE plumid.forbidden_test (id INT);

# Test 6 — DROP TABLE (DOIT ÉCHOUER)
DROP TABLE plumid.species;

# Requêtes pour l'user : plumid_editor
# Test 1 — INSERT picture
INSERT INTO plumid.pictures (url, latitude, longitude, date_collected, feathers_idfeathers) VALUES ('on/est/là/hein', '48°51\'12.28"N', '2°20\'55.68"E', '2025-12-10', 1);

# Test 2 — SELECT species
SELECT * FROM plumid.species LIMIT 1;

# Test 3 — DROP TABLE (DOIT ÉCHOUER)
DROP TABLE plumid.pictures;

# Requêtes pour l'user : plumid_viewer
# Test 1 — SELECT (OK)
SELECT * FROM plumid.species LIMIT 1;

# Test 2 — INSERT (interdit)
INSERT INTO plumid.species (sex, region, environment, information, species_name) VALUES ('F', 'test_user_viewer', 'env', 'toto', 'moi');

# Test 3 — UPDATE (interdit)
UPDATE plumid.species SET species_name='toto' WHERE region='test_user_viewer';

# Test 4 — DELETE (interdit)
DELETE FROM plumid.species WHERE region='test_user_viewer';

# Requêtes pour l'user : plumid_ia
# Test 1 — SELECT images (OK)
SELECT * FROM plumid.pictures LIMIT 1;

# Test 2 — SELECT species (OK)
SELECT * FROM plumid.species LIMIT 1;

# Test 3 — INSERT image (interdit)
INSERT INTO plumid.pictures (url, latitude, longitude, date_collected, feathers_idfeathers) VALUES ('on/est/là/hein_test_ia', '48°51\'12.28"N', '2°20\'55.68"E', '2025-12-10', 1);

# Test 4 — ALTER TABLE (interdit)
ALTER TABLE plumid.species ADD test_col INT;