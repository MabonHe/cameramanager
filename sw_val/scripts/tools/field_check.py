#!/usr/bin/env python
import os
import sys
import re
def usage():
    print "usage: field_check.py log_file num_frames num_camera"
    print "This script will check the field tag correctness and frame loss.\n num_camera default 1"

def process_lines(key, lines, type):
    if type=="progressive":
        for line in lines:
            try:
                m=re.search("buffer field: (\d*)", line)
                if int(m.group(1)) != 1:
                    result = {"result": 1,"description": "field got should be 1 for progressive! actual={}".format(str(m.group(1)))}
                    return result
            except:
                result = {"result": 1,"description": "field got should be 1 for progressive!"}
                return result
        return {"result": 0,"description": ""}
    if type=="interlaced":
        stack=[]
        for line in lines:
            try:
                m=re.search("buffer field: (\d*)", line)
                if int(m.group(1)) != 2 and int(m.group(1)) != 3:
                    result = {"result": 1,"description": "field got should be 2 or 3 for interlaced! actual={}".format(str(m.group(1)))}
                    return result
                else:
                    stack.append(str(m.group(1)))
            except:
                result = {"result": 1,"description": "field got should be 2 or 3 for interlaced!"}
                return result
        str_stack="".join(stack)
        if "22222" in str_stack or "33333" in str_stack:
           result = {"result": 1,"description": "got more than 5 same field for interlaced! !"}
           return result

        return {"result": 0,"description": ""}
def main():
    if len(sys.argv) < 3:
        usage()
        return 0
    else:
        log=sys.argv[1]
        num_f=int(sys.argv[2])
        if sys.argv[3].isdigit():
            num_cam=int(sys.argv[3])
        else:
            num_cam=1

        log_dict={}
        result_dict={}
        with open(log,"r") as log_f:
            for i in range(1, num_cam+1):
                lines = []
                key_word = "Camera Id: {}".format(i)
                for line in log_f.readlines():
                    if key_word in line:
                       lines.append(line)

                log_dict[i]=lines
        # check log lines
        for (k, v) in log_dict.items():
            if len(v) != num_f:
                result = {"result": 1,
                        "description": "captured log line {0} not equal with {1}".format(str(len(v)), str(num_f))}
            else:
                result = {"result": 0,
                        "description": ""}

            result_dict[k]=result

        # check field
        for (k, v) in log_dict.items():
            if len(v) > 0:
                first_line = v[0]
            else:
                print "Cam field check: result:1, description: no log captured"
                sys.exit(1)

            m=re.search("buffer field: (\d*)", first_line)

            if m:
                field=int(m.group(1))
                #print field
                if field == 1:
                    r = process_lines(k,v,"progressive")
                    result = {"result": r["result"]+result_dict[k]["result"],
                    "description": result_dict[k]["description"] + r["description"]}
                elif field == 2 or field == 3:
                    r = process_lines(k,v, "interlaced")
                    result = {"result": r["result"]+result_dict[k]["result"],
                    "description": result_dict[k]["description"] + r["description"]}
                    #print result
                else:
                    result = {"result": 1+result_dict[k]["result"],
                    "description": result_dict[k]["description"] + "\nField is not in 1, 2, 3!\n"}

            else:
                result = {"result": 1+result_dict[k]["result"],
                    "description": result_dict[k]["description"] + "\nField not get!\n"}

            result_dict[k]=result
            #print result_dict[k]

        # check frame loss
        for (k, v) in log_dict.items():
            m=re.search("buffer sequence: (\d*)", v[num_f-1])
            if m and ((int(m.group(1))-num_f) > 3):
                result = {"result": 1+result_dict[k]["result"],
                    "description": result_dict[k]["description"] + "\nThere is {0} frames lost in capture {1} frames.\n".format((int(m.group(1))-num_f), num_f)}

                result_dict[k]=result


        for (k, v) in result_dict.items():
            if v["result"] != 0:
                print "Cam {0} field check: result:{1}, description:\n{2}".format(k, v["result"], v["description"])
                sys.exit(v["result"])
            print "Cam {0} field check: result:{1}, description:\n{2}".format(k, v["result"], v["description"])
        return 0

main()
