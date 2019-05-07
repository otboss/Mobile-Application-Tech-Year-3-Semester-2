#!/bin/bash
./geckodriver --port 4444 > /dev/null & \
./node_modules/.bin/wdio wdio.conf.js;
kill $(lsof -t -i:4444);
