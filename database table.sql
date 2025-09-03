create database retail_forecasting;
show databases;

SHOW VARIABLES LIKE 'secure_file_priv';

CREATE TABLE train (
  id INT,
  date DATE,
  store_nbr INT,
  family text,
  sales int,
  onpromotion int
);
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;


LOAD DATA local INFILE '/Users/Famille/Desktop/train.csv'
INTO TABLE train
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ANALYZE TABLE train;


