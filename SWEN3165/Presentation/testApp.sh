#!/bin/bash
DB_DEVICE_ARG=00b99b2b2ed81786 calabash-android run app-debug.apk features/my_first.feature;
node index.js;
