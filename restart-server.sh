#!/bin/bash

echo "Killing all node processes..."
pkill -9 node
sleep 2

echo "Starting server..."
cd /workspaces/purescript
node server.js
