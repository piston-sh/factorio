#!/bin/bash
docker push pistonsh/factorio:$TRAVIS_BUILD_NUMBER
docker push pistonsh/factorio:latest
