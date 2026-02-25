# Ajout d'users

# user admin pour l'administration BD --> grant all
CREATE USER 'db_admin'@'localhost' IDENTIFIED BY 'AdminFort!';
GRANT ALL PRIVILEGES ON *.* TO 'db_admin'@'localhost' WITH GRANT OPTION; 

# user app pour l'application (backend ou API) --> grant SELECT / INSERT / UPDATE / delete
CREATE USER 'plumid_app'@'%' IDENTIFIED BY 'AppUser123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON plumid.* TO 'plumid_app'@'%'; 

# user pour l'ajout de données (membres du groupe) --> gra,t SELECT / INSERT / UPDATE / DELETE (certaines tables)
CREATE USER 'plumid_editor'@'%' IDENTIFIED BY 'Editor123!';
GRANT SELECT, INSERT, UPDATE, DELETE 
ON plumid.species TO 'plumid_editor'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE 
ON plumid.pictures TO 'plumid_editor'@'%';

GRANT SELECT, INSERT, UPDATE, DELETE 
ON plumid.feathers TO 'plumid_editor'@'%';

# user en lecture seul --> grant select
CREATE USER 'plumid_viewer'@'%' IDENTIFIED BY 'Viewer123!';
GRANT SELECT ON plumid.* TO 'plumid_viewer'@'%';

# user IA avec full accès aux tables nécessaires aux modèles --> grant SELECT / INSERT / UPDATE / delete (certaines tables)
CREATE USER 'plumid_ia'@'%' IDENTIFIED BY 'IAuser123!';

GRANT SELECT ON plumid.pictures TO 'plumid_ia'@'%';
GRANT SELECT ON plumid.species TO 'plumid_ia'@'%';

SELECT User, Host FROM mysql.user;

SHOW GRANTS FOR 'plumid_user'@'%';