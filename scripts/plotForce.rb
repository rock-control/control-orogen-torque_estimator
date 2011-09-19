
#!/usr/bin/env ruby
#

require 'orocos/log'
require 'vizkit'
require 'plotData.rb' 

def register2DPlot ( plot, title, x_axis, y_axis ) 
  
#     plot.register2D( :w0, {:title => "Rear Left", :lt =>"p pointsize 1 pt 2"} )
#     plot.register2D( :w1, {:title => "Rear Right", :lt =>"p pointsize 1 pt 1"} )
#     plot.register2D( :w2, {:title => "Front Right", :lt =>"p pointsize 1 pt 3"} )
#     plot.register2D( :w3, {:title => "Front Left", :lt =>"p pointsize 1 pt 4"} )
      plot.register2D( :w0, {:title => "Rear Left", :lt =>"l  lt 2"} )
    plot.register2D( :w1, {:title => "Rear Right", :lt =>"l  lt 1"} )
    plot.register2D( :w2, {:title => "Front Right", :lt =>"l  lt 3"} )
    plot.register2D( :w3, {:title => "Front Left", :lt =>"l  lt 4"} )
    plot.setTitle(title, "Helvetica,14")
    plot.setXLabel(x_axis, "Helvetica,14")
    plot.setYLabel(y_axis, "Helvetica,14")
    
end 


wheel_idx = 0


logs = Array.new
logs <<  ARGV[0] + "test_torque.0.log"
logs <<  ARGV[0] + "lowlevel.0.log"
log_replay = Orocos::Log::Replay.open(  logs  ) 

plot_traction = DataPlot.new()
register2DPlot( plot_traction,ARGV[0], "time", "Traction Force (N)")


plot_normal = DataPlot.new()
register2DPlot( plot_normal,ARGV[0], "time", "Normal Force (N)")


plotTorque = DataPlot.new()
register2DPlot( plotTorque,ARGV[0], "time", "Torque (N/m)")



plot_deflection = DataPlot.new()
register2DPlot( plot_deflection,ARGV[0], "time", "Deflection (rad)")


plot_current = DataPlot.new()
register2DPlot( plot_current,ARGV[0], "time", "current (mA)")


plot = DataPlot.new()
plot.register1D( :torque, {:title => "Torque (N.m)", :lt =>"p pt 2"} )
plot.register1D( :current, {:title => "Current (A)", :lt =>"p pt 1"} )
plot.register1D( :deflection, {:title => "Deflection (rad*10)", :lt =>"p pt 3"} )
 plot.setTitle("wheel "+wheel_idx.to_s+" " +ARGV[0] , "Helvetica,14")
plot_terrain = DataPlot.new()
register2DPlot(plot_terrain, ARGV[0],"Normal Force (N)", "Traction Force (N)") 

plot_key = Array.new
plot_key << :w0
plot_key << :w1
plot_key << :w2
plot_key << :w3

init_time = 0 


log_replay.torque.ground_forces_estimated.connect_to(:type => :buffer,:size => 1000) do |data,_|
	if init_time == 0 
	    init_time = data.time.to_f 
	end
	for i in 0..3 
	    plot_terrain.addData(  plot_key[i], [data.normalForce[i], data.tractionForce[i]]) if data
	    plot_traction.addData(  plot_key[i], [data.time.to_f - init_time, data.tractionForce[i]]) if data
	    plot_normal.addData(  plot_key[i], [data.time.to_f - init_time, data.normalForce[i]]) if data
	end
end

log_replay.torque.torque_estimated.connect_to(:type => :buffer,:size => 1000) do |data,_|
    	if init_time == 0 
	    init_time = data.time.to_f 
	end
	for i in 0..3 
	    plot_deflection.addData(  plot_key[i], [data.time.to_f - init_time, data.deflection[i]]) if data
	    plotTorque.addData(  plot_key[i], [data.time.to_f - init_time, data.torque[i]]) if data
	end

	plot.addData(  :torque, [data.time.to_f - init_time,data.torque[wheel_idx]*-1.0]) if data
	plot.addData(  :deflection, [data.time.to_f - init_time,(data.deflection[wheel_idx]*-10.0)]) if data
end

log_replay.hbridge.status_motors.connect_to(:type => :buffer,:size => 1000) do |data,_|
    	if init_time == 0 
	    init_time = data.time.to_f 
	end
	
	plot.addData(  :current, [data.time.to_f - init_time,(data.states[wheel_idx].current/1000.0)]) if data
	
	for i in 0..3 
	    plot_current.addData(  plot_key[i], [data.time.to_f - init_time, data.states[i].current]) if data
	end
end

log_replay.align( :use_sample_time )
Vizkit.control log_replay
Vizkit.exec

plot.show()
#plot_terrain.show()
# plot_traction.show()
# plot_normal.show()
# plotTorque.show()
# plot_deflection.show()
 plot_current.show()
