#! /usr/bin/env ruby

require 'orocos'
require 'orocos/log'
require 'vizkit'


include Orocos

if ARGV.size < 1 then 
    puts "usage: process_logs.rb ru"
    exit
end


BASE_DIR = File.expand_path('..', File.dirname(__FILE__))
ENV['PKG_CONFIG_PATH'] = "#{BASE_DIR}/build:#{ENV['PKG_CONFIG_PATH']}"
Orocos.initialize

Orocos::Process.spawn('test_torque') do |p|
    # log all the output ports
    Orocos.log_all_ports 

    # get the invidual tasks
    torque_estimator = p.task 'torque'

 
    # connect the tasks to the logs
    log_replay = Orocos::Log::Replay.open( ARGV[0]+"lowlevel.0.log" ) 

    #log_replay.xsens.orientation_samples.connect_to( inertial_navigation.orientation_samples, :type => :buffer, :size => 10 )
    log_replay.hbridge.status_motors.connect_to( torque_estimator.status, :type => :buffer, :size => 10 )
    
    torque_estimator.configure
    torque_estimator.start
    
    
  

#     # open the log replay widget
     Vizkit.control log_replay
     Vizkit.exec
    
end

