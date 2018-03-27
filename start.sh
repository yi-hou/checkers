#!/bin/bash

export PORT=5400

cd ~/www/memory
./bin/memory stop || true
./bin/memory start
