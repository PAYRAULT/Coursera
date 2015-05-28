#!/usr/bin/env python

import json
import os
import sys

for file in os.listdir("."):

    if file.endswith(".json"):
        f = open(file, 'r')
        try:
            j = json.loads(f.read())
            print "valid: %s" % file
        except: 
            print "malformed: %s" % file
            raise
        finally:
            f.close
            