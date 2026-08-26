#!/bin/bash

echo "******************************"
echo "*"
echo "* UNICORE startup"
echo "*"
echo "******************************"
echo

INST=`dirname $0`
cd $INST

cd gateway
echo "Starting Gateway ..."
./bin/start.sh
cd ..

cd unicorex
echo "Starting UNICORE/X ..."
  bin/start.sh 
cd ..

echo "Done!"
