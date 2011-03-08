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

 
    coupling_properties = torque_estimator.coupling_properties
    coupling_properties.parameters[0].A			= 1.201051
    coupling_properties.parameters[0].beta			= 0.185264
    coupling_properties.parameters[0].gamma			= 0.006926
    coupling_properties.parameters[0].n			= 3.270138 
    coupling_properties.parameters[0].alpha			= 0.468416 
    coupling_properties.parameters[0].ki			= 0.792530
    coupling_properties.parameters[0].gearPlay              = 6.311779
    coupling_properties.parameters[0].deflectionOffset      = 1.334364
    coupling_properties.parameters[0].dampingConst          = 0.000615
    coupling_properties.parameters[0].velocitySmoothFactor  = 0.01

    coupling_properties.parameters[1].A			= 1.882775
    coupling_properties.parameters[1].beta			= 0.563455
    coupling_properties.parameters[1].gamma			= 0.563455
    coupling_properties.parameters[1].n			= 1.010499
    coupling_properties.parameters[1].alpha			= 0.527440
    coupling_properties.parameters[1].ki			= 0.918977
    coupling_properties.parameters[1].gearPlay              = 5.075883
    coupling_properties.parameters[1].deflectionOffset      = 0.301310
    coupling_properties.parameters[1].dampingConst          = 0.021321
    coupling_properties.parameters[1].velocitySmoothFactor  = 0.01

    coupling_properties.parameters[2].A			= 2.355107
    coupling_properties.parameters[2].beta			= 0.232774
    coupling_properties.parameters[2].gamma			= 0.022843
    coupling_properties.parameters[2].n			= 3.238402
    coupling_properties.parameters[2].alpha			= 0.571053
    coupling_properties.parameters[2].ki			= 0.797152
    coupling_properties.parameters[2].gearPlay              = 4.736712
    coupling_properties.parameters[2].deflectionOffset      = 0.097188
    coupling_properties.parameters[2].dampingConst          = 0.029172
    coupling_properties.parameters[2].velocitySmoothFactor  = 0.01

    coupling_properties.parameters[3].A			= 2.325323
    coupling_properties.parameters[3].beta			= 0.133005
    coupling_properties.parameters[3].gamma			=-0.060698
    coupling_properties.parameters[3].n			= 3.321318
    coupling_properties.parameters[3].alpha			= 0.593363
    coupling_properties.parameters[3].ki			= 0.638724
    coupling_properties.parameters[3].gearPlay              = 9.215597
    coupling_properties.parameters[3].deflectionOffset      = 0.555960
    coupling_properties.parameters[3].dampingConst          = 0.011260
    coupling_properties.parameters[3].velocitySmoothFactor  = 0.01

    torque_estimator.coupling_properties = coupling_properties

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

