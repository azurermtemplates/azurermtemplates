#!/bin/bash

cd /usr/local
touch privateIP.txt

echo $(($1+1)) >> privateIP.txt
