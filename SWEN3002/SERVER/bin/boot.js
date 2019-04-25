
new Promise(function(resolve, reject){

});

const fs = require("fs");
const request = require("request");
const os = require('os');
const readline = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout
});
const exec = require('child_process').exec;

const execute = function (command, callback) {
    exec(command, { maxBuffer: 1024 * 250 }, function (error, stdout, stderr) {
        callback(error, stdout, stderr);
    });
};

/** Generates a new HTTPS certificate*/
const generateNewCertificate = function(){
    return new Promise(function(resolve, reject){
        execute(`openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
        -keyout key.pem  -out cert.pem`, function(err, stdout, stderr){
            resolve(true);
        });
    });
}

/** Fetches the servers Current IP address*/
const getServerIp = function(){
    return new Promise(function(resolve, reject){
        if(!config.autoIpDetection){
            resolve(config.serverIp+":"+config.port);
        }
        else{
            request("http://ipecho.net/plain", {timeout: 5000}, function(error, response, body){
                if(body == undefined)
                    reject();
                resolve(body+":"+config.port);
            });
        }
    });
}

if(fs.existsSync("./config.json") == false){
    fs.writeFileSync("./config.json", "ewogICAgInNlcnZlcklwIjogIjxTZXJ2ZXIgSXAgQWRkcmVzcyBIZXJlPiIsCiAgICAiYXV0b0lwRGV0ZWN0aW9uIjogdHJ1ZSwKICAgICJzaG93QWR2ZXJ0aXNtZW50cyI6IHRydWUsCiAgICAiYWRtb2RJZCI6ImNhLWFwcC1wdWItMzk0MDI1NjA5OTk0MjU0NC82MzAwOTc4MTExIiwKICAgICJlbmFibGVIVFRQUyI6IHRydWUsCiAgICAia2V5UGF0aCI6Ii4va2V5LnBlbSIsCiAgICAiY2VydFBhdGgiOiIuL2NlcnQucGVtIiwKICAgICJzYXZlRXh0ZXJuYWxTZXJ2ZXJzIjogdHJ1ZSwKICAgICJzaGEyNTZQYXNzd29yZCI6ICIwMWJhNDcxOWM4MGI2ZmU5MTFiMDkxYTdjMDUxMjRiNjRlZWVjZTk2NGUwOWMwNThlZjhmOTgwNWRhY2E1NDZiIiwKICAgICJtYXhQYXJ0aWNpcGFudHNQZXJHcm91cCI6IDEwMCwKICAgICJwb3J0IjogNjMzMywKICAgICJkYXRhYmFzZUNvbmZpZyI6ewogICAgICAgICJob3N0IjoibG9jYWxob3N0IiwKICAgICAgICAidXNlciI6InJvb3QiLAogICAgICAgICJwYXNzd29yZCI6IiIsCiAgICAgICAgImRhdGFiYXNlIjoiY2lwaGVyY2hhdCIsCiAgICAgICAgInBvcnQiOiAzMzA2CiAgICB9Cn0=", 'base64');
}
const config = JSON.parse(fs.readFileSync("./config.json",{encoding: "utf8"}));

readline.question("Launch in debugging mode? [y/N] ", function(debuggingMode){
    readline.close();
    console.log(`
==========================
BOOTED A CipherChat SERVER
==========================
Selected Port: `+config.port+`
HTTPS: `+config.enableHTTPS+`
Admob ID: `+config.admodId+`
Debug Mode: false

Starting Server..
`);
    
    new Promise(async function(resolve, reject){
        if(config.enableHTTPS){
            const checkForCertificate = async function(){
                return new Promise(async function(resolve, reject){
                    try{
                        if(!fs.existsSync(config.keyPath) || !fs.existsSync(config.certPath))
                            throw new Error();
                        else
                            resolve();
                    }
                    catch(err){
                        if(os.platform() == "linux"){
                            console.log("It appears HTTPS is enabled, however the key/certificate files are missing.");
                            readline.question("Would you like to generate them now? (requires openssl) [Y/n] ", function(response){
                                if(response != "n" && response != "N"){
                                    console.log("\nGenerating 4096 bit Certificate..");
                                    generateNewCertificate().then(function(){
                                        console.log("Done!\n");
                                        resolve();
                                    });
                                }
                                else{
                                    console.log("\n\nExiting..\n");
                                    throw new Error();
                                }
                                readline.close();
                            });
                        }
                        else{
                            throw new Error("Unable to find key/certificate file(s)");
                        }
                    }
                });
            }
            await checkForCertificate();
            console.log("CipherChat SERVER STARTED. Now Listening on port "+config.port);
            console.log("You may check the server at https://127.0.0.1:"+config.port+"/");
            var ip = "<Your Public IP Address>";
            try{
                ip = await getServerIp();
                ip = ip.split(":")[0];
            }
            catch(err){
                //Connection Error
            }
            console.log(`\nThis server may be submitted at:
'https://github.com/CipherChat/CipherChat/issues/new'
with the title 'Public Server Submission' and the comment of: 

{
    "ip": "`+ip+`",
    "port": "`+config.port+`"
}
`);
            console.log("=========================================================")
            console.log("| Remember to forward port "+config.port+" in your router settings |");
            console.log("| for global access this server.                        |")    
            console.log("=========================================================")
            console.log(""); 
            resolve(debuggingMode);       
        }
    }).then(function(debuggingMode){
        if(debuggingMode != "y" && debuggingMode != "y"){
            execute("./npx forever -c ./node start index.js;", function(error, stdout, stderr){
                if(error)
                    console.log(error);
                console.log(stdout);
                process.exit();
            });
        }
        else{
            process.stdin.resume();
        }
    });    
});

