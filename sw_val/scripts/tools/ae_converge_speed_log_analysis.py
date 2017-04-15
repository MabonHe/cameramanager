#!/usr/bin/python
import os
import sys
import re
from datetime import datetime, date, time

def parse_hal_log(path):
    y_mean_list=[]
    #08-01 18:45:49.133: [AIQ]: ISP_PARAM_ADAPTOR:RGB stat grid[1] 60x34, y_mean 88
    rule=re.compile("^([0-9,-]{5} [0-9,:,\.]{12}).*y_mean ([0-9]{1,3})")
    with open(path, "r") as f:
        lines = f.readlines()
        for line in lines:
            match = rule.search(line)
            if match:
                timestr = match.group(1)+"000"
                dt=datetime.strptime(timestr, "%m-%d %H:%M:%S.%f")
                y_mean_list.append((dt, (int)(match.group(2))))
    return y_mean_list

def find_converge_point(y_mean_list, win_size, sigma_th):
    mean_y_mean = 0
    mean_y_mean_2 = 0
    acc_y_mean = 0
    acc_y_mean_2 = 0
    i = 0
    for (dt, y_mean) in y_mean_list:
        acc_y_mean = y_mean + acc_y_mean
        acc_y_mean_2 = acc_y_mean_2 + y_mean * y_mean
        if (i >= win_size):
            y_mean_org = y_mean_list[i-win_size][1]
            acc_y_mean_2 = acc_y_mean_2 - y_mean_org*y_mean_org
            acc_y_mean = acc_y_mean - y_mean_org
            mean_y_mean_2 = float(acc_y_mean_2) / win_size
            mean_y_mean = float(acc_y_mean) / win_size
            sigma = mean_y_mean_2 - mean_y_mean * mean_y_mean
            if sigma < sigma_th:
                return i - win_size
        i = i + 1
    return -1
 
 #DISPLAY=:0 cameraDebug=8 gst-launch-1.0 icamerasrc device-name=imx185 wdr-mode=on converge-speed-mode=hal converge-speed=low num-buffers=1500 io-mode=3 ! video/x-raw,format=NV12,width=1920,height=1080 ! vaapipostproc ! vaapisink
def main():
    if len(sys.argv) < 2:
        print "Usage %s hal/aiq" % sys.argv[0]
        exit(-1)
    
    coverage_speed_mode = sys.argv[1]
    
    log_path_low = "/home/root/sw_val/results/converge_speed_{cs_mode}_{c_speed}.log".format(cs_mode=coverage_speed_mode, c_speed="low")
    log_path_mid = "/home/root/sw_val/results/converge_speed_{cs_mode}_{c_speed}.log".format(cs_mode=coverage_speed_mode, c_speed="mid")
    log_path_normal = "/home/root/sw_val/results/converge_speed_{cs_mode}_{c_speed}.log".format(cs_mode=coverage_speed_mode, c_speed="normal")
    
    CMD_LOW="DISPLAY=:0 cameraDebug=8 gst-launch-1.0 icamerasrc device-name=imx185 wdr-mode=on converge-speed-mode={cs_mode} converge-speed={c_speed} num-buffers=1500 io-mode=3 ! video/x-raw,format=NV12,width=1920,height=1080 ! vaapipostproc ! vaapisink > {logpath}".format(cs_mode=coverage_speed_mode, c_speed="low", logpath=log_path_low)
    
    CMD_MID="DISPLAY=:0 cameraDebug=8 gst-launch-1.0 icamerasrc device-name=imx185 wdr-mode=on converge-speed-mode={cs_mode} converge-speed={c_speed} num-buffers=1500 io-mode=3 ! video/x-raw,format=NV12,width=1920,height=1080 ! vaapipostproc ! vaapisink > {logpath}".format(cs_mode=coverage_speed_mode, c_speed="mid", logpath=log_path_mid)
    
    CMD_NORMAL="DISPLAY=:0 cameraDebug=8 gst-launch-1.0 icamerasrc device-name=imx185 wdr-mode=on converge-speed-mode={cs_mode} converge-speed={c_speed} num-buffers=1500 io-mode=3 ! video/x-raw,format=NV12,width=1920,height=1080 ! vaapipostproc ! vaapisink > {logpath}".format(cs_mode=coverage_speed_mode, c_speed="normal", logpath=log_path_normal)
    
    print CMD_LOW
    ret_low = os.system(CMD_LOW)
    print CMD_MID
    ret_mid = os.system(CMD_MID)
    print CMD_NORMAL
    ret_normal = os.system(CMD_NORMAL)
    
    if ret_low !=0 or ret_mid != 0 or ret_normal != 0:
        print "Failed to run GStreamer Pipe: return code error"
        exit(-1)
    
    # Very import paramerters to find the converge point
    win_size = 300
    threshold = 0.4
    
    y_mean_list_low = parse_hal_log(log_path_low)
    index_low = find_converge_point(y_mean_list_low, win_size, threshold)
    if index_low < 0:
        print "Failed to find coverge point for coverge speed low"
        exit(-1)
    timestamp_low = y_mean_list_low[index_low][0] - y_mean_list_low[0][0]
    print "Coverge speed mode: {}, converge speed: low, coverge time: {} days, {} seconds, {} microseconds".format(coverage_speed_mode, timestamp_low.days, timestamp_low.seconds, timestamp_low.microseconds)
    
    y_mean_list_mid = parse_hal_log(log_path_mid)
    index_mid = find_converge_point(y_mean_list_mid, win_size, threshold)
    if index_mid < 0:
        print "Failed to find coverge point for coverge speed mid"
        exit(-1)
    timestamp_mid = y_mean_list_mid[index_mid][0] - y_mean_list_mid[0][0]
    print "Coverge speed mode: {}, converge speed: mid, coverge time: {} days, {} seconds, {} microseconds".format(coverage_speed_mode, timestamp_mid.days, timestamp_mid.seconds, timestamp_mid.microseconds)
    
    y_mean_list_normal = parse_hal_log(log_path_normal)
    index_normal = find_converge_point(y_mean_list_normal, win_size, threshold)
    if index_normal < 0:
        print "Failed to find coverge point for coverge speed normal"
        exit(-1)
    timestamp_normal = y_mean_list_normal[index_normal][0] - y_mean_list_normal[0][0]
    print "Coverge speed mode: {}, converge speed: high, coverge time: {} days, {} seconds, {} microseconds".format(coverage_speed_mode, timestamp_normal.days, timestamp_normal.seconds, timestamp_normal.microseconds)
    
    if timestamp_normal >= timestamp_mid or timestamp_mid >= timestamp_low:
        print "Failed due to converge speed does not work"
        exit(-1)
    print "PASS"
    exit(0)
    
main()