CREATE DATABASE cipherchat;
USE cipherchat;

CREATE TABLE groups(
    gid INT(11) NOT NULL AUTO_INCREMENT,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name VARCHAR(50),
    joinKey VARCHAR(100) NOT NULL,
    UNIQUE(joinKey),
    PRIMARY KEY(gid)
);

CREATE TABLE participants(
    pid INT(11) NOT NULL AUTO_INCREMENT,
    gid INT(11) NOT NULL,
    username VARCHAR(255) NOT NULL,
    publicKey VARCHAR(100) NOT NULL,
    participantKey VARCHAR(100) NOT NULL,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE(gid, username),
    UNIQUE(participantKey),
    PRIMARY KEY(pid),
    FOREIGN KEY(gid) REFERENCES groups(gid)
);

CREATE TABLE messages(
    mid INT(11) NOT NULL AUTO_INCREMENT,
    pid INT(11) NOT NULL,
    message TEXT NOT NULL,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(mid),
    FOREIGN KEY(pid) REFERENCES participants(pid)
);