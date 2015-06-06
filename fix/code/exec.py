import json
import sys
import os
import base64

arg = sys.argv
arg.pop(0)
for json_input in arg:
    try:
        print "file : "+json_input
        with open(json_input) as json_file:
            json_data = json.load(json_file)

        # pretty printing of json-formatted string
        #print json.dumps(json_data, sort_keys=True, indent = 4)

        rep = "cd ../trash; "
        os.system("rm -rf ../trash/.logdb")
        os.system("rm -rf ../trash/*")

        if ( "batch" in json_data):
            batch64 = json_data["batch"]
            batch = base64.standard_b64decode(batch64)
            print "batch :"
            print batch
            print " "
            sys.stdout.flush()
            f = open('../trash/batch', 'w')
            f.write(batch)
            f.close()

        for cmd in json_data["commands"]:
            prg = "../fix/code/" + cmd["program"]
            for arg in cmd["args"]:
                prg = prg + " " +  arg
            print prg
            sys.stdout.flush()

            res = os.system(rep + prg)
            if(res != 0):
                print 'res : %i' % res
            
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
