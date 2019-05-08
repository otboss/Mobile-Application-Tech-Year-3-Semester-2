const fs = require("fs");
/** Json containing ascii of characters (test domains)*/
const testCases = {
    "specialCharacters": [32, 47],
    "specialCharacters2": [58, 64],
    "specialCharacters3": [91, 96],
    "specialCharacters4": [123, 126],
    "upperCaseCharacters": [65, 90],
    "lowerCaseCharacters": [97, 122]
};
const allKeyboardCharacters = [32, 126]; //Only use with powerful computer or multiple threads
const minLength = 1;
const maxLength = 10;
/** The connected device's adb ID here*/
const adbDeviceId = "00b99b2b2ed81786"; 

const substrings = function(str1, minLength, maxLength) {
    return new Promise(function(resolve, reject){
        var array1 = [];
        for (var x = 0, y = 1; x < str1.length; x++ , y++) {
            array1[x] = str1.substring(x, y);
        }
        var combi = [];
        var temp = "";
        var slent = Math.pow(2, array1.length);
        for (var i = 0; i < slent; i++) {
            temp = "";
            for (var j = 0; j < array1.length; j++) {
                if ((i & Math.pow(2, j))) {
                    temp += array1[j];
                }
                if(temp.length > maxLength)
                    break; 
            }
            if (temp !== "" && temp.length >= minLength && temp.length <= maxLength) {
                combi.push(temp);
            }
        }
        resolve(combi);
    });
}

const runTest = function (adbDeviceId) {
    return new Promise(function (resolve, reject) {
        var command = "calabash-android run app-debug.apk ./features/form_field_test.feature";
        if (adbDeviceId != null) {
            command = 'DB_DEVICE_ARG=' + adbDeviceId + ' calabash-android run app-debug.apk ./features/form_field_test.feature';
        }
        const childProcess = require("child_process").exec(command, function (error, stdout, stderror) {
            if (error)
                console.log('[ERROR]: ' + error);
            console.log("\n\ndone!\n");
            resolve(true);
        });
        childProcess.stdout.on('data', function (data) {
            console.log(data);
        });
    });
}

const formsTester = function (username, password) {
    username = addslashes(username);
    password = addslashes(password);
    return `
    Feature: Form Vulnurability Test

    Scenario: As a new user I should be able to create a new account
      When I see "Sign Up"
      Then I press "Sign Up"
      When I see "Username"
      Then I enter text "`+ username + `" into field with id "username"
      Then I enter text "`+ password + `" into field with id "password"
      * I go back
      Then I enter text "`+ password + `" into field with id "confirmpassword"
      * I go back
      * I wait for 2 seconds
      * I press "submit"  
      * I wait for 5 seconds
      * I should see "Restaurants List"     
      * I go back
      When I see "Username"
      Then I go back
      When I see "Login"
      Then I press "Login"
      When I see "Username"
      Then I enter text "`+ username + `" into field with id "lusername"
      * I go back
      Then I enter text "`+ password + `" into field with id "lpassword"
      * I go back
      * I press "Login Now" 
      * I wait for 5 seconds
      * I should see "Restaurants List"    
    `;
}

const calabashTest = async function () {
    const ranges = Object.keys(testCases);
    for(var x = 0; x < ranges.length; x++){
        try{
            var characters = "";
            const upper = testCases[ranges[x]][0];
            const lower = testCases[ranges[x]][1];
            for(var y = upper; y <= lower; y++){
                characters += String.fromCharCode(y);
            }
            console.log("\n\nNOW TESTING CHARACTER SET: "+characters+"\n");
            const combinations = await substrings(characters, minLength, maxLength);
            console.log("Number of Combinations: "+combinations.length);
            for(var y = 0; y < combinations.length; y++){
                console.log("\nTesting: "+combinations[y]);
                console.log("Length: "+combinations[y].length+"\n");
                fs.writeFileSync("./features/form_field_test.feature", formsTester(combinations[y], combinations[y]));
                await runTest(adbDeviceId);
            }
        }
        catch(err){
            console.log(err);
        }        
    } 
}

const addslashes = function (string) {
    string = String(string);
    return string.replace(/\\/g, '\\\\').
        replace(/\u0008/g, '\\b').
        replace(/\t/g, '\\t').
        replace(/\n/g, '\\n').
        replace(/\f/g, '\\f').
        replace(/\r/g, '\\r').
        replace(/'/g, '\\\'').
        replace(/"/g, '\\"');
}

const generateRandomString = function (stringLength) {
    if (parseInt(stringLength).toString() == "NaN" || parseInt(stringLength) <= 0)
        throw new Error("invalid string length provided");
    const addslashes = function (string) {
        string = String(string);
        return string.replace(/\\/g, '\\\\').
            replace(/\u0008/g, '\\b').
            replace(/\t/g, '\\t').
            replace(/\n/g, '\\n').
            replace(/\f/g, '\\f').
            replace(/\r/g, '\\r').
            replace(/'/g, '\\\'').
            replace(/"/g, '\\"');
    }        
    var string = "";
    const getRandomIntInclusive = function (min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    for (var x = 0; x < stringLength; x++) {
        string += (String.fromCharCode(getRandomIntInclusive(32, 126)));
    }
    return addslashes(string);
}

calabashTest();