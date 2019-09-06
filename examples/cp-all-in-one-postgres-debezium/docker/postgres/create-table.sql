CREATE TABLE IF NOT EXISTS user (
	username varchar(45) NOT NULL,  
	password varchar(450) NOT NULL,  
	enabled integer NOT NULL DEFAULT '1',  
	PRIMARY KEY (user_id)  
)