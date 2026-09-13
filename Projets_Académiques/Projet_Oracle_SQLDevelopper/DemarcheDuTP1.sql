/* YASMINE AMRI 6319139 Ce fichier.sql contient ma démarche pour le TP1 */
--connexion vmetudes_pdb@etudes_pdb      il est en tant que etud_admin
-- Vérification des tables de la base de donnés

-- Ouvrir la PDB en tant que vmsysDBA@etudes_pdb
ALTER PLUGGABLE DATABASE etudes_pdb OPEN;

-- Ces requête en tant que connexion vmetudes_pdb@etudes_pdb
 -- on doi être dans ETUDES_PDB
show con_name;

--Vérifier du contenue des tables de la PDB 
SELECT table_name FROM user_tables;

SELECT *
FROM ETUDIANT;

SELECT *
FROM SEMESTRE;

SELECT *
FROM GROUPE;

SELECT *
FROM COURS;

SELECT *
FROM EVALUATION;

--Pour la création des utilisateurs, role je vais la faire dans la connexion vmsysDBA@etudes_pdb

