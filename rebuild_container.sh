#!/bin/bash -e

#docker image rm modelica-builder -f
docker build . -t="modelica-builder"