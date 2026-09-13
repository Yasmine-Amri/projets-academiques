-- Connecter avec vmsysDBA@etudes_pdb      il est en tant que sys

/* YASMINE AMRI 6319139 Ce fichier.sql contient ma démarche 
pour la création des utilisateurs,profils,rôles*/

-- Donner les privilèges de création de table et de vues
--à l’administrateur de la base de données : etud_admin
GRANT CREATE TABLE,CREATE VIEW TO etud_admin;


-- Ouvrir la PDB 
ALTER PLUGGABLE DATABASE etudes_pdb OPEN;

--*****************************************************--
--***************1)Création des utilisateurs:**********--
--*****************************************************--

-- 1) 2 SYSDBA, le DBA principal et son collègue 
CREATE USER ys_dba_principal IDENTIFIED BY oracle;
CREATE USER ys_dba_adjoint IDENTIFIED BY oracle;

-- 2) 1 gestionnaire principal : ys_gestionnaire
CREATE USER ys_gestionnaire IDENTIFIED BY oracle;

-- 3) 2 utilisateurs du registrariat : ys_reg1, ys_reg2
CREATE USER ys_reg1 IDENTIFIED BY oracle;
CREATE USER ys_reg2 IDENTIFIED BY oracle;

-- 4) 1 utilisateur API : ys_api
CREATE USER ys_api IDENTIFIED BY oracle;

-- 5) 1 enseignant : ys_enseignant
CREATE USER ys_enseignant IDENTIFIED BY oracle;



--**************************************************************--
--********Création des rôle et attribution des privilèges:******--
--**************************************************************--

-- 1) Pour les 2 SYSDBA, le DBA principal et son collègue 
SHOW CON_NAME;
GRANT CONNECT , sysbackup, dba to ys_dba_principal;
GRANT CONNECT , sysbackup, dba to ys_dba_adjoint;
GRANT SYSDBA TO ys_dba_principal;
GRANT SYSDBA TO ys_dba_adjoint;
--sysbakup c'est un rôle qui ce trouve dans oracle et il permet de réaliser des sauvegarde
-- ils auront trois rôles , ils seront comme sys, pourrons se connecter à la base de donnée
-- et avec DBA ils auront une adminitration complète


--*********************************************************--
-- 2) Pour le 1 gestionnaire principal : ys_gestionnaire
CREATE ROLE ys_role_gestionnaire;

-- Privilèges accordés
GRANT CREATE SESSION, CREATE TABLE,
CREATE VIEW, CREATE PROCEDURE,
SELECT ANY TABLE TO ys_role_gestionnaire;
-- Assigner ce rôle à l'utilisateur ys_gestionnaire 
GRANT ys_role_gestionnaire TO ys_gestionnaire;




--*************************************************--
-- 3) Pour les 2 utilisateurs du registrariat : ys_reg1, ys_reg2
CREATE ROLE ys_role_registrariat;
-- Privilèges accordés
GRANT CREATE SESSION, SELECT ANY TABLE,  INSERT ANY TABLE, UPDATE ANY TABLE TO ys_role_registrariat;
-- Assigner ce rôle aux utilisateurs ys_reg1 et ys_reg2 
GRANT ys_role_registrariat TO ys_reg1;
GRANT ys_role_registrariat TO ys_reg2;

--Révocation des privilèges précédents:
REVOKE CREATE SESSION FROM ys_role_registrariat;
REVOKE SELECT ANY TABLE FROM ys_role_registrariat;
REVOKE INSERT ANY TABLE FROM ys_role_registrariat;
REVOKE UPDATE ANY TABLE FROM ys_role_registrariat;

--Création d'une vue pour la table etudiant
CREATE VIEW vue_identite AS
SELECT DA, ENOM, ADRESSE, TELEPHONE, GENRE
FROM ETUD_ADMIN.ETUDIANT;

--Création d'une vue pour la table groupe
CREATE VIEW vue_groupe AS
SELECT *
FROM ETUD_ADMIN.GROUPE;

--Assigner les vues au rôle
GRANT SELECT ON vue_identite TO ys_role_registrariat;
GRANT SELECT ON vue_groupe TO ys_role_registrariat;

--Autorise l'utilisateur à se connecter pour établir une session
GRANT CREATE SESSION TO ys_role_registrariat;

-- Peut seulement effectuer des mise à jour d'adresse et de téléphone
GRANT UPDATE (ADRESSE, TELEPHONE) ON ETUD_ADMIN.ETUDIANT TO ys_role_registrariat;

--Assigner le rôle aux utilisateurs:
GRANT ys_role_registrariat TO ys_reg1;
GRANT ys_role_registrariat TO ys_reg2;



--******************************************--
-- 4) Pour le 1 utilisateur API : ys_api
CREATE ROLE ys_role_api;

--Création d'une vue pour la table etudiant
--L'api a seulement besoin de connaître le nom, DA et genre de l'élève
CREATE VIEW vue_etudiant AS
SELECT DA, ENOM, GENRE
FROM ETUD_ADMIN.ETUDIANT;

--Création d'une vue pour la table groupe
CREATE VIEW vue_groupe_api AS
SELECT *
FROM ETUD_ADMIN.GROUPE;

--Création d'une vue pour la table cours
CREATE VIEW vue_cours AS
SELECT *
FROM ETUD_ADMIN.COURS;

--Création d'une vue pour la table semestre
CREATE VIEW vue_semestre AS
SELECT *
FROM ETUD_ADMIN.SEMESTRE;

--Création d'une vue pour la table evaluation
CREATE VIEW vue_evaluation AS
SELECT *
FROM ETUD_ADMIN.EVALUATION;

--Autorise l'utilisateur à se connecter pour établir une session
GRANT CREATE SESSION TO ys_role_api;

--Assigner les vues au rôle
GRANT SELECT ON vue_etudiant TO ys_role_api;
GRANT SELECT ON vue_groupe TO ys_role_api;
GRANT SELECT ON vue_cours TO ys_role_api;
GRANT SELECT ON vue_semestre TO ys_role_api;
GRANT SELECT ON vue_evaluation TO ys_role_api;

--Assigner le rôle à l'utilisateurs:
GRANT ys_role_api TO ys_api;



--*******************************************--
-- 5) Pour le 1 enseignant : ys_enseignant
CREATE ROLE ys_role_enseignant;

--Autorise l'utilisateur à se connecter pour établir une session
GRANT CREATE SESSION TO ys_role_enseignant;

--Assigner les vues et privilèges au rôle
GRANT SELECT ON vue_etudiant TO ys_role_enseignant;
GRANT SELECT ON ETUD_ADMIN.EVALUATION TO ys_role_enseignant;

--Assigner le rôle à l'utilisateurs:
GRANT ys_role_enseignant TO ys_enseignant;


--**************************************************************--
--*********************Création des profils:******************--
--**************************************************************--

-- 1) Création d’un profil plus permissif pour l’utilisateur gestionnaire :
/*Nombre de session concurrentes illimité(SESSIONS_PER_USER UNLIMITED), 
durée de connexion d'une session illimité(CONNECT_TIME),durée d'inactivité
d'une session illimité(IDLE_TIME),15 tentatives de connexions(FAILED_LOGIN_ATTEMPTS),
compte vérouillé pendanr 1h si tentatives échouées(PASSWORD_LOCK_TIME), mot de passe
valide pour 180 jours(PASSWORD_LIFE_TIME),délai de 30 jours entre deux utilisations
du même mot de passe(PASSWORD_REUSE_TIME),5 réutilisation du même mot de passe
(PASSWORD_REUSE_MAX),Délai supplémentaire de 15 demande à l'utilisateur pour changer
son mot de passe(une fois le délai défini par PASSWORD_LIFE_TIME atteint)(PASSWORD_GRACE_TIME),
ORA12C_VERIFY_FUNCTION est le nom d'une fonction PL/SQL qui servira à vérifier les mots de passe
saisi(PASSWORD_VERIFY_FUNCTION ).
*/

CREATE PROFILE ys_profil_gestionnaire LIMIT
SESSIONS_PER_USER UNLIMITED
CONNECT_TIME UNLIMITED
IDLE_TIME UNLIMITED
FAILED_LOGIN_ATTEMPTS 15
PASSWORD_LOCK_TIME 1/24
PASSWORD_LIFE_TIME 180
PASSWORD_REUSE_TIME 30
PASSWORD_REUSE_MAX 5
PASSWORD_GRACE_TIME 15
PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION;

-- Attribuer le profil à son utilisateur:
ALTER USER ys_gestionnaire PROFILE ys_profil_gestionnaire;



-- 2)Création d’un profil plus restrictif mais fonctionnel pour les utilisateurs du registrariat :
/* Maximum de 2 session concurrentes (SESSIONS_PER_USER UNLIMITED), durée de connexion d'une
session de 60 min (CONNECT_TIME),15 min d'inactivité d'une session (IDLE_TIME),10 tentatives 
de connexions(FAILED_LOGIN_ATTEMPTS),compte vérouillé pendanr 1h si tentatives échouées(PASSWORD_LOCK_TIME),
mot de passe valide pour 90 jours(PASSWORD_LIFE_TIME),délai de 60 jours entre deux utilisations
du même mot de passe(PASSWORD_REUSE_TIME),3 réutilisation du même mot de passe
(PASSWORD_REUSE_MAX),Délai supplémentaire de 10 demande à l'utilisateur pour changer
son mot de passe(une fois le délai défini par PASSWORD_LIFE_TIME atteint)(PASSWORD_GRACE_TIME),
ORA12C_VERIFY_FUNCTION est le nom d'une fonction PL/SQL qui servira à vérifier les mots de passe
saisi(PASSWORD_VERIFY_FUNCTION ).
*/

CREATE PROFILE ys_profil_registrariat LIMIT
SESSIONS_PER_USER 2
CONNECT_TIME 60
IDLE_TIME 15
FAILED_LOGIN_ATTEMPTS 10
PASSWORD_LOCK_TIME 1/24
PASSWORD_LIFE_TIME 90
PASSWORD_REUSE_TIME 60
PASSWORD_REUSE_MAX 3
PASSWORD_GRACE_TIME 10
PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION; 

-- Attribuer le profil à son utilisateur:
ALTER USER ys_reg1 PROFILE ys_profil_registrariat;
ALTER USER ys_reg2 PROFILE ys_profil_registrariat;



-- 3) Création d’un profil semi-permissif avec un accès technique, mais contrôlé
-- pour l'API:
CREATE PROFILE ys_profil_api LIMIT
SESSIONS_PER_USER 5
CONNECT_TIME 120
IDLE_TIME 30
FAILED_LOGIN_ATTEMPTS 5
PASSWORD_LOCK_TIME 1/24
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 30
PASSWORD_REUSE_MAX 5
PASSWORD_GRACE_TIME 10
PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION; 

-- Attribuer le profil à son utilisateur:
ALTER USER ys_api PROFILE ys_profil_api;

-- 4) Création d’un profil pour l'enseignant ce sera le plus restrictif , car 
--c’est seulement pour un accès pédagogique, donc sécurisé et limité:
CREATE PROFILE ys_profil_enseignant LIMIT
SESSIONS_PER_USER 1
CONNECT_TIME 45
IDLE_TIME 10
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 1/24
PASSWORD_LIFE_TIME 60
PASSWORD_REUSE_TIME 60
PASSWORD_REUSE_MAX 2
PASSWORD_GRACE_TIME 5
PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION; 

-- Attribuer le profil à son utilisateur:
ALTER USER ys_enseignant PROFILE ys_profil_enseignant;























