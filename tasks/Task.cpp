/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "Task.hpp"
#define DEG(x) (x*180.0/M_PI)

using namespace torque_estimator;
using namespace hbridge;


Task::Task(std::string const& name, TaskCore::TaskState initial_state)
    : TaskBase(name, initial_state)
{
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

    std::vector<double> p;
    for(int i=0; i<4; i++)
    {
        _coupling_properties.get().parameters[i].toVector(p);
	oHysteresis[i].setParameters(&p[0]);
        oHysteresis[i].printParameters();
    }

    _status.clear();
    return true;
}

void Task::updateHook()
{
    TorquesEstimated.time	= base::Time::now();

    // This is the hbridge status
    if (_status.readNewest(m_status) != RTT::NewData)
	return;

    for(int i=0; i<4; i++)
    {
	// deflection = external encoder - internal encoder 
	TorquesEstimated.deflection[i] =   m_status.states[i].positionExtern 
                                         - m_status.states[i].position;

	// Calculates the stress from the model
	if(!oHysteresis[i].getStress(
            m_status.index * 0.001,
            DEG(TorquesEstimated.deflection[i]), 
            TorquesEstimated.deflectionVelocity[i],
            TorquesEstimated.torque[i]))
        {
            return;
        }
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

