/* CREATE TABLE chatUser(
   id SERIAL PRIMARY KEY NOT NULL,
   serverID VARCHAR,
   login    VARCHAR NOT NULL,
   password VARCHAR NOT NULL
); */

CREATE TABLE chatMessanges(
	id SERIAL PRIMARY KEY NOT NULL,
	sender   INT NOT NULL,
	receiver INT NOT NULL,
	date TEXT,
	text TEXT
);

/*
CREATE TABLE chatContacts(
	id SERIAL PRIMARY KEY NOT NULL,
	name     VARCHAR NOT NULL,
	serverID VARCHAR NOT NULL
);*/
