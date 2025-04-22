#!/usr/bin python
# -*- coding: utf-8 -*-

import sys
import math
import argparse
import rospy
import rosbag
from sensor_msgs.msg import JointState
from geometry_msgs.msg import Vector3
from geometry_msgs.msg import WrenchStamped


# function to write commanded values to the rosbag 
def save_commanded_bag(frame_id, seq, seconds, nanoseconds, joint_pos, joint_vel, joint_torque):
  ros_commanded = JointState()
  ros_commanded.header.seq = seq
  ros_commanded.header.stamp.secs = int(seconds)
  ros_commanded.header.stamp.nsecs = int(nanoseconds)
  ros_commanded.header.frame_id = frame_id
  ros_commanded_topic = '/jointCommanded'
  ros_commanded.name = ['J1', 'J2', 'J3', 'J4', 'J5', 'J6', 'J7']
  ros_commanded.position = joint_pos
  ros_commanded.velocity = joint_vel
  ros_commanded.effort = joint_torque

  bag.write(ros_commanded_topic, ros_commanded, ros_commanded.header.stamp)

# function to write measured values to the rosbag 
def save_measured_bag(frame_id, seq, seconds, nanoseconds, joint_pos, joint_vel, joint_torque):
  ros_measured = JointState()
  ros_measured.header.seq = seq
  ros_measured.header.stamp.secs = int(seconds)
  ros_measured.header.stamp.nsecs = int(nanoseconds)
  ros_measured.header.frame_id = frame_id
  ros_measured_topic = "/jointMeasured"
  ros_measured.name = ["J1", "J2", "J3", "J4", "J5", "J6", "J7"]
  ros_measured.position = joint_pos
  ros_measured.velocity = joint_vel
  ros_measured.effort = joint_torque
  
  bag.write(ros_measured_topic, ros_measured, ros_measured.header.stamp)

# function to write external values to the rosbag 
def save_external_bag(frame_id, seq, seconds, nanoseconds, joint_torque):
  ros_external = JointState()
  ros_external.header.seq = seq
  ros_external.header.stamp.secs = int(seconds)
  ros_external.header.stamp.nsecs = int(nanoseconds)
  ros_external.header.frame_id = frame_id
  ros_external_topic = "/jointExternal"
  ros_external.name = ["J1", "J2", "J3", "J4", "J5", "J6", "J7"]
  ros_external.position = []
  ros_external.velocity = []
  ros_external.effort = joint_torque
  
  bag.write(ros_external_topic, ros_external, ros_external.header.stamp)

  # function to write F/T sensor to rosbag 
def save_FT_sensor_bag(frame_id, seq, seconds, nanoseconds, wrench):
  ros_FT_sensor = WrenchStamped()
  ros_FT_sensor.header.seq = seq
  ros_FT_sensor.header.stamp.secs = int(seconds)
  ros_FT_sensor.header.stamp.nsecs = int(nanoseconds)
  ros_FT_sensor.header.frame_id = frame_id
  ros_FT_sensor_topic = "/FT_sensor"
  force = Vector3()
  force.x =  wrench[0]
  force.y =  wrench[1]
  force.z =  wrench[2]
  torque = Vector3()
  torque.x =  wrench[3]
  torque.y =  wrench[4]
  torque.z =  wrench[5]
  ros_FT_sensor.wrench.force = force
  ros_FT_sensor.wrench.torque = torque
  
  bag.write(ros_FT_sensor_topic, ros_FT_sensor, ros_FT_sensor.header.stamp)



################## main part ##################

if __name__ == "__main__":
  
  parser = argparse.ArgumentParser(description='Script that takes images imu and gps along with the calibration info to create a rosbag')
  parser.add_argument('--path', help='imu log file')
  parser.add_argument('--commanded', help='imu log file')
  parser.add_argument('--measured', help='imu log file')
  parser.add_argument('--external', help='imu log file')
  parser.add_argument('--FT_sensor', help='imu log file')
  parser.add_argument('--out', help='output bag file')
  args = parser.parse_args()
  bag = rosbag.Bag(args.out, 'w')

################## commanded part ##################

  if args.commanded:
    joint_pos = [0 for i in range(7)] 
    joint_vel = [0 for i in range(7)] 
    joint_torque = [0 for i in range(7)] 
    fr_pos = open(args.path + "/jnt_cmd_position.log","r") #information obtained from sensor
    fr_vel = open(args.path + "/jnt_cmd_speed.log","r") 
    fr_torque = open(args.path + "/jnt_cmd_torque.log","r") #information obtained from sensor
    seq = 0
    commanded_frame_id = "commanded_state"
    #total_size = os.path.getsize(args.imu)
    for line_pos, line_vel, line_torque in zip(fr_pos, fr_vel, fr_torque):
      splitted_line_pos = line_pos.split("   ")
      splitted_line_vel = line_vel.split("   ")
      splitted_line_torque = line_torque.split("   ")
      seconds,nanoseconds = splitted_line_pos[0].split(".")
      nanoseconds = nanoseconds + "000"
      for i in range(7):
        joint_pos[i] = (float(splitted_line_pos[i+1]))
        joint_vel[i] = (float(splitted_line_vel[i+1]))
        joint_torque[i] =(float(splitted_line_torque[i+1]))
      save_commanded_bag(commanded_frame_id, seq, seconds, nanoseconds, joint_pos, joint_vel, joint_torque)
      seq = seq + 1     # increment seq number
    print ("commanded done")

  if args.measured:
    joint_pos = [0 for i in range(7)] 
    joint_vel = [0 for i in range(7)] 
    joint_torque = [0 for i in range(7)] 
    fr_pos = open(args.path + "/jnt_position.log","r") 
    fr_vel = open(args.path + "/jnt_speed.log","r") 
    fr_torque = open(args.path + "/jnt_torque.log","r") #information obtained from sensor
    seq = 0
    commanded_frame_id = "measured_state"
    for line_pos, line_vel, line_torque in zip(fr_pos,fr_vel, fr_torque):
      splitted_line_pos = line_pos.split("   ")
      splitted_line_vel = line_vel.split("   ")
      splitted_line_torque = line_torque.split("   ")
      seconds,nanoseconds = splitted_line_pos[0].split(".")
      nanoseconds = nanoseconds + "000"
      for i in range(7):
        joint_pos[i] = (float(splitted_line_pos[i+1]))
        joint_vel[i] = (float(splitted_line_vel[i+1]))
        joint_torque[i] =(float(splitted_line_torque[i+1]))
      save_measured_bag(commanded_frame_id, seq, seconds, nanoseconds, joint_pos, joint_vel, joint_torque)
      seq = seq + 1     # increment seq number
    print ("measured done")

  if args.external:
    joint_torque = [0 for i in range(7)] 
    fr_torque = open(args.path + "/jnt_ext_torque.log","r") #information obtained from sensor
    seq = 0
    external_frame_id = "external_state"
    for line_torque in fr_torque:
      splitted_line_torque = line_torque.split("   ")
      seconds,nanoseconds = splitted_line_torque[0].split(".")
      nanoseconds = nanoseconds + "000"
      for i in range(7):
        joint_torque[i] =(float(splitted_line_torque[i+1]))
      save_external_bag(external_frame_id, seq, seconds, nanoseconds, joint_torque)
      seq = seq + 1     # increment seq number
    print ("external done")

  if args.FT_sensor:
    FT_sensor = [0 for i in range(6)] 
    fr_sensor = open(args.path + "/ft_sensor.log","r") #information obtained from sensor
    seq = 0
    sensor_frame_id = "FT_sensor"
    for line_sensor in fr_sensor:
      splitted_line_sensor = line_sensor.split("   ")
      seconds,nanoseconds = splitted_line_sensor[0].split(".")
      nanoseconds = nanoseconds + "000"
      for i in range(6):
        FT_sensor[i] =(float(splitted_line_sensor[i+1]))
      #print(FT_sensor[0:3])
      save_FT_sensor_bag(sensor_frame_id, seq, seconds, nanoseconds, FT_sensor)
      seq = seq + 1     # increment seq number
    print ("sensor done")
  
  bag.close()
