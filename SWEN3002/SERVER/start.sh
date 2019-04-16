#!/bin/bash
read -p 'Launch in debugging mode? [y/N] ' choice;
if [ "$choice" == "y" -o "$choice" == "Y" ];
then
    cd "./bin";
    ./node index.js; 
else
    cd "./bin";
    ./node boot.js;
    ./npx forever -c ./node start index.js;    
fi
