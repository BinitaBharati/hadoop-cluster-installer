#!/bin/bash

dos2unix stopServices.sh stopServices.sh
chmod +x stopServices.sh
dos2unix startServices.sh startServices.sh
chmod +x startServices.sh
./stopServices.sh
./startServices.sh




