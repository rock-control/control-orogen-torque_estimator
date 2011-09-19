
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

logs = Array.new
logs <<  ARGV[0] + "test_torque.0.log"
logs <<  ARGV[0] + "lowlevel.0.log"
log_replay = Orocos::Log::Replay.open(  logs  ) 

plot_traction = DataPlot.new()
plot_traction.register1D( :w0, {:title => "Rear Left", :lt =>"p pt 2"} )
plot_traction.register1D( :w1, {:title => "Rear Right", :lt =>"p pt 1"} )
plot_traction.register1D( :w2, {:title => "Front Right", :lt =>"p pt 3"} )
plot_traction.register1D( :w3, {:title => "Front Left", :lt =>"p pt 4"} )
plot_traction.setTitle(ARGV[0], "Helvetica,14")
plot_traction.setXLabel("sample (0.001s)", "Helvetica,14")
plot_traction.setYLabel("Traction Force (N)", "Helvetica,14")


plot_normal = DataPlot.new()
plot_normal.register1D( :w0, {:title => "Rear Left", :lt =>"p pt 2"} )
plot_normal.register1D( :w1, {:title => "Rear Right", :lt =>"p pt 1"} )
plot_normal.register1D( :w2, {:title => "Front Right", :lt =>"p pt 3"} )
plot_normal.register1D( :w3, {:title => "Front Left", :lt =>"p pt 4"} )
plot_normal.setTitle(ARGV[0], "Helvetica,14")
plot_traction.setXLabel("sample (0.001s)", "Helvetica,14")
plot_normal.setYLabel("Normal Force (N)", "Helvetica,14")
  

plotTorque = DataPlot.new()
plotTorque.register1D( :w0, {:title => "Rear Left", :lt =>"p pt 2"} )
plotTorque.register1D( :w1, {:title => "Rear Right", :lt =>"p pt 1"} )
plotTorque.register1D( :w2, {:title => "Front Right", :lt =>"p pt 3"} )
plotTorque.register1D( :w3, {:title => "Front Left", :lt =>"p pt 4"} )
plotTorque.setTitle(ARGV[0], "Helvetica,14")
plotTorque.setYLabel("Torque (N/m)", "Helvetica,14")
plotTorque.setXLabel("Sample (0.001s)", "Helvetica,14")
plotTorque.setTitle(ARGV[0], "Helvetica,14")

plot_deflection = DataPlot.new()
plot_deflection.register1D( :w0, {:title => "Rear Left", :lt =>"p pt 2"} )
plot_deflection.register1D( :w1, {:title => "Rear Right", :lt =>"p pt 1"} )
plot_deflection.register1D( :w2, {:title => "Front Right", :lt =>"p pt 3"} )
plot_deflection.register1D( :w3, {:title => "Front Left", :lt =>"p pt 4"} )
plot_deflection.setTitle(ARGV[0], "Helvetica,14")
plot_deflection.setYLabel("Deflection (???)", "Helvetica,14")
plot_deflection.setXLabel("Sample (0.001s)", "Helvetica,14")
plot_deflection.setTitle(ARGV[0], "Helvetica,14")

plot_current = DataPlot.new()
plot_current.register1D( :w0, {:title => "Rear Left", :lt =>"p pt 2"} )
plot_current.register1D( :w1, {:title => "Rear Right", :lt =>"p pt 1"} )
plot_current.register1D( :w2, {:title => "Front Right", :lt =>"p pt 3"} )
plot_current.register1D( :w3, {:title => "Front Left", :lt =>"p pt 4"} )
plot_current.setTitle(ARGV[0], "Helvetica,14")
plot_current.setXLabel("sample (0.001s)", "Helvetica,14")
plot_current.setYLabel("current (mA)", "Helvetica,14")

plot = DataPlot.new()
plot.register1D( :w0, {:title => "Torque (N.m)", :lt =>"p pt 2"} )
plot.register1D( :w1, {:title => "Current (A)", :lt =>"p pt 1"} )
plot.register1D( :w2, {:title => "Deflection (rad*10)", :lt =>"p pt 3"} )

plot_terrain = DataPlot.new()
register2DPlot(plot_terrain, ARGV[0],"Normal Force (N)", "Traction Force (N)") 

plot_key = Array.new
plot_key << :w0
plot_key << :w1
plot_key << :w2
plot_key << :w3
    
log_replay.torque.ground_forces_estimated.connect_to(:type => :buffer,:size => 1000) do |data,_|
	plot_normal.addData(  :w0, data.normalForce[0]) if data
	plot_normal.addData(  :w1, data.normalForce[1]) if data
	plot_normal.addData(  :w2, data.normalForce[2]) if data
	plot_normal.addData(  :w3, data.normalForce[3]) if data
	
  	plot_traction.addData(  :w0, data.tractionForce[0]) if data
	plot_traction.addData(  :w1, data.tractionForce[1]) if data
	plot_traction.addData(  :w2, data.tractionForce[2]) if data
	plot_traction.addData(  :w3, data.tractionForce[3]) if data
	
	for i in 0..3 
	    plot_terrain.addData(  plot_key[i], [data.normalForce[i], data.tractionForce[i]]) if data
	end
end

log_replay.torque.torque_estimated.connect_to(:type => :buffer,:size => 1000) do |data,_|
	plotTorque.addData(  :w0, data.torque[0]) if data
	plotTorque.addData(  :w1, data.torque[1]) if data
	plotTorque.addData(  :w2, data.torque[2]) if data
	plotTorque.addData(  :w3, data.torque[3]) if data
	
	plot_deflection.addData(  :w0, data.deflection[0]) if data
	plot_deflection.addData(  :w1, data.deflection[1]) if data
	plot_deflection.addData(  :w2, data.deflection[2]) if data
	plot_deflection.addData(  :w3, data.deflection[3]) if data
	
	plot.addData(  :w0, data.torque[2]*-1.0) if data
	plot.addData(  :w2, (data.deflection[2]*-10.0)) if data
end

log_replay.hbridge.status_motors.connect_to(:type => :buffer,:size => 1000) do |data,_|
	
	plot.addData(  :w1, (data.states[2].current/1000.0)) if data
	
	
	plot_current.addData(  :w0, data.states[0].current) if data
	plot_current.addData(  :w1, data.states[1].current) if data
	plot_current.addData(  :w2, data.states[2].current) if data
	plot_current.addData(  :w3, data.states[3].current) if data
end

log_replay.align( :use_sample_time )
Vizkit.control log_replay
Vizkit.exec

# plot.show()
plot_terrain.show()
# plot_traction.show()
# plot_normal.show()
# plotTorque.show()
# plot_deflection.show()
# plot_current.show()
