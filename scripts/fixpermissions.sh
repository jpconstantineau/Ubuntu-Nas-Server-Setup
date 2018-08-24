#!/bin/bash

  mount -a

  chown nobody.nogroup -R /Data
  chmod 777 -R /Data

  chown nobody.nogroup -R /Monitor
  chmod 777 -R /Monitor
  
  service smbd restart