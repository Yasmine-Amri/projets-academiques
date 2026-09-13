--Connection vmsysDBAtp1@creationDeLaBDenfichable

/* YASMINE AMRI 6319139 Ce fichier.sql contient ma démarche pour
la création de la pdb, l'attribution du quota */

--Moi
--*****************************************************--
--***************1) Création de la PDB:****************--
--*****************************************************--

-- Premièrement, s'assurer que je suis dans le CDB$ROOT
SHOW CON_NAME;
ALTER SESSION SET CONTAINER = CDB$ROOT;

--Deuxièment, créé la PDB avec cette commande:
CREATE PLUGGABLE DATABASE etudes_pdb 
ADMIN USER etud_admin IDENTIFIED BY oracle
FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed/','/opt/oracle/oradata/FREE/etudes_pdb/');

-- Ouvrir la PDB 
ALTER PLUGGABLE DATABASE etudes_pdb OPEN;


--*****************************************************--
--******* 2) Solution pour le problème de quota********--
--*****************************************************--
-- On doi effectuer ces commandes dans la connexion où sys est le user
-- et SYSDBA est le rôle

--Première tentative:
--  a marcher
ALTER SESSION SET CONTAINER = etudes_pdb;
--n'a pas marcher
ALTER USER etud_admin  QUOTA UNLIMITED ON USERS;
-- a marcher
GRANT UNLIMITED TABLESPACE TO etud_admin;




-- Pour résoudre le problème de la requête qui n'a pas marcher:
--Vérifier les tablespaces disponibles:
SELECT tablespace_name FROM dba_tablespaces;
--on verra que la table USERS n'existe pas donc on va la créer
-- ensuite, verifier le bon chemin du fichier.dbf
--Attention il ne faut pas utiliser 
/* /opt/oracle/oradata/FREE/etudes_pdb/system01.dbf
/opt/oracle/oradata/FREE/etudes_pdb/sysaux01.dbf
/opt/oracle/oradata/FREE/etudes_pdb/undotbs01.dbf
*/
SELECT name FROM v$datafile;

--après, créer la tablespace
CREATE TABLESPACE USERS
DATAFILE '/opt/oracle/oradata/FREE/etudes_pdb/users01.dbf'
SIZE 100M AUTOEXTEND ON;

--retester les commande pour le quota
ALTER USER etud_admin  QUOTA UNLIMITED ON USERS;
ALTER SESSION SET CONTAINER = etudes_pdb;
GRANT UNLIMITED TABLESPACE TO etud_admin;


--Création d'une copie de sauvegarde
--S'assurer qu'on est dans le conteneur ETUDES_PDB 

--Donner ces rôles pour la sauvegarde:
GRANT CONNECT, RESOURCE TO etud_admin;

--Création du répertoire logique Oracle
CREATE OR REPLACE DIRECTORY dp_dir AS '/opt/oracle/backup/dpdump';
GRANT READ, WRITE ON DIRECTORY dp_dir TO etud_admin;

-- Vérification
SELECT directory_name, directory_path FROM dba_directories WHERE directory_name = 'DP_DIR';

-- Dans le terminal de la VM:
-- Export complet du schéma etud_admin:
expdp etud_admin/oracle@//localhost:1521/ETUDES_PDB schemas=etud_admin directory=dp_dir dumpfile=etud_admin.dmp logfile=etud_admin.log

-- Import complet du schéma etud_admin :
impdp etud_admin/oracle@//localhost:1521/ETUDES_PDB schemas=etud_admin directory=dp_dir dumpfile=etud_admin.dmp logfile=etud_admin.log




















