#ifndef TORQUE_ESTIMATOR_TYPES_HPP
#define TORQUE_ESTIMATOR_TYPES_HPP

#include <HBridge.hpp>
#include <base/time.h>

namespace torque_estimator
{
    struct WheelTorques {
        base::Time time;
	double deflection[4];
	double deflectionVelocity[4];
        double torque[4];
    };
}

#endif
