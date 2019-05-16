"use strict";
exports.__esModule = true;
/** */
var Config = /** @class */ (function () {
    function Config() {
        this.serverIp = "<YOUR_PUBLIC_IP ADDRESS_HERE>";
        this.autoIpDetection = true;
        this.keyPath = "./key.pem";
        this.certPath = "./cert.pem";
        this.sha256Password = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        this.maxParticipantsPerGroup = 100;
        this.port = 6333;
        this.instanceServerStartingPort = 3000;
        this.numberOfLocalhostServers = 3;
        this.remoteServerUrls = [];
        this.databaseConfig = new DatabaseConfig();
    }
    return Config;
}());
exports.Config = Config;
var DatabaseConfig = /** @class */ (function () {
    function DatabaseConfig() {
        this.host = "localhost";
        this.user = "root";
        this.password = "";
        this.database = "cipherchat";
        this.port = 3306;
    }
    return DatabaseConfig;
}());
