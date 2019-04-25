const express = require('express');
const request = require('request');
const exec = require('child_process').exec;
const fs = require('fs');
const config = JSON.parse(fs.readFileSync("./config.json",{encoding: "utf8"}));

const server = require("./index");
var servers = [];
var currentServer = 0;
var startingPort = 3000;

const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

execute("./node boot.js", function(error, stdout, stderr){
    console.log(stdout);
});

for(var x = 0; x < config.numberOfLocalhostServers.length; x++){
    servers.push(
        
    );
}

const handler = (req, res) => {
    // Pipe the vanilla node HTTP request (a readable stream) into `request`
    // to the next server URL. Then, since `res` implements the writable stream
    // interface, you can just `pipe()` into `res`.
    req.pipe(request({ url: servers[currentServer] + req.url })).pipe(res);
    currentServer = (currentServer + 1) % servers.length;
};

server = express().get('*', handler).post('*', handler);
server.listen(config.port);



