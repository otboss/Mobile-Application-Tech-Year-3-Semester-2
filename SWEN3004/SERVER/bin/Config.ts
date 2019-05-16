/** */
export class Config{
    public serverIp:string = "<YOUR_PUBLIC_IP ADDRESS_HERE>";
    public autoIpDetection:boolean = true;
    public keyPath:string = "./key.pem";
    public certPath:string = "./cert.pem";
    public sha256Password:string = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
    public maxParticipantsPerGroup:number = 100;
    public port:number = 6333;
    public instanceServerStartingPort:number = 3000;
    public numberOfLocalhostServers:number = 3;
    public remoteServerUrls:object = [

    ];
    public databaseConfig = new DatabaseConfig();
    constructor(){

    }
}

class DatabaseConfig{
    public host:string = "localhost";
    public user:string = "root";
    public password:string = "";
    public database:string = "cipherchat";
    public port:number = 3306;  
    constructor(){

    }
}