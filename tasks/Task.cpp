/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#define DEG(x) (x*180.0/M_PI)

using namespace torque_estimator;
using namespace hbridge;


Task::Task(std::string const& name, TaskCore::TaskState initial_state)
    : TaskBase(name, initial_state),
    prevDeflection(4, 0),
    prevDeflectionVel(4, 0),
    upperGearPlayLimit(4, 0),
    lowerGearPlayLimit(4, 0)
{
    _A.set(0.0);
    _beta.set(0.0);
    _gamma.set(0.0);
    _n.set(0.0);
    _a.set(1.0);
    _ki.set(0.0);
    _nu.set(0.0);
    _eta.set(0.0);
    _h.set(0.0);

    _velSmoothFactor.set(0.5);
}



/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See Task.hpp for more detailed
// documentation about them.

// bool Task::configureHook()
// {
//     if (! TaskBase::configureHook())
//         return false;
//     return true;
// }
bool Task::startHook()
{
    if (! TaskBase::startHook())
	return false;

    for(int i=0; i<4; i++)
	oHysteresis[i].setParameters(
		_A.get(),
		_beta.get(),
		_gamma.get(),
		_n.get(),
		_a.get(),
		_ki.get(),
		_nu.get(),
		_eta.get(),
		_h.get());

    _status.clear();
    firstRun = true;
    return true;
}

void Task::updateHook()
{
    TorquesEstimated.time	= base::Time::now();

    // This is the hbridge status
    if (_status.readNewest(m_status) != RTT::NewData)
	return;

    if(firstRun)
    {
      for(int i=0; i<4; i++)
      {
        prevIndex 		= m_status.index;
        prevDeflection[i] 	= m_status.states[i].positionExtern - m_status.states[i].position;
        prevDeflectionVel[i]	= 0; 
      }
      firstRun = false;
      return;
    }

    for(int i=0; i<4; i++)
    {
	// deflection = external encoder - internal encoder 
	TorquesEstimated.deflection[i] = m_status.states[i].positionExtern - m_status.states[i].position;

	// deflection velocity without smoothing
	double currDefVel = (TorquesEstimated.deflection[i] - prevDeflection[i]) / ( (m_status.index - prevIndex) * 0.001 );

	// First order smoothing
	TorquesEstimated.deflectionVelocity[i] = 
             _velSmoothFactor.get()*currDefVel + 
	    (1.0 - _velSmoothFactor.get()) * prevDeflectionVel[i];

        std::cout << i << "  " << TorquesEstimated.deflectionVelocity[i]  
                       << "  " << currDefVel
                       << "  " << prevDeflection[i]
                       << "  " << prevDeflectionVel[i];


	// Calculates the stress from the model
	TorquesEstimated.torque[i] = oHysteresis[i].getStress(DEG(TorquesEstimated.deflection[i]), DEG(TorquesEstimated.deflectionVelocity[i]));

        if(TorquesEstimated.torque[0] != TorquesEstimated.torque[0] )
        {
          std::cout << "Torque estimator: NaN computed" << std::endl;
          firstRun = true;
          return;
        }

	prevIndex 		= m_status.index;
	prevDeflection[i] 	= TorquesEstimated.deflection[i];
	prevDeflectionVel[i] 	= TorquesEstimated.deflectionVelocity[i];
    }

    _torque_estimated.write(TorquesEstimated);
//    TaskBase::updateHook();
}
// void Task::errorHook()
// {
//     TaskBase::errorHook();
// }
// void Task::stopHook()
// {
//     TaskBase::stopHook();
// }
// void Task::cleanupHook()
// {
//     TaskBase::cleanupHook();
// }

