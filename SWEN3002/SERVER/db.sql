CREATE DATABASE cipherchat;
USE cipherchat;

CREATE TABLE groups(
    gid INT(11) NOT NULL AUTO_INCREMENT,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    joinKey VARCHAR(100) NOT NULL,
    UNIQUE(joinKey),
    PRIMARY KEY(gid)
);

CREATE TABLE participants(
    pid INT(11) NOT NULL AUTO_INCREMENT,
    gid INT(11) NOT NULL,
    username VARCHAR(255) NOT NULL,
    publicKeyXCoord VARCHAR(100) NOT NULL,
    publicKeyX2Coord VARCHAR(100) NOT NULL,
    publicKeyYCoord VARCHAR(100) NOT NULL,
    leftChat INT(1) NOT NULL DEFAULT 0,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE(gid, username),
    PRIMARY KEY(pid),
    FOREIGN KEY(gid) REFERENCES groups(gid)
);

CREATE TABLE messages(
    mid INT(11) NOT NULL AUTO_INCREMENT,
    pid INT(11) NOT NULL,
    message TEXT NOT NULL,
    hashedMessage VARCHAR(100) NOT NULL,
    r TEXT,
    s TEXT,
    signature TEXT,
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(mid),
    FOREIGN KEY(pid) REFERENCES participants(pid)
);

/*
CREATE TABLE recipients(
    rid INT(11) NOT NULL AUTO_INCREMENT,
    mid INT(11) NOT NULL,
    pid INT(11) NOT NULL,
    PRIMARY KEY(rid),
    FOREIGN KEY(mid) REFERENCES messages(mid),
    FOREIGN KEY(pid) REFERENCES participants(pid)
);*/