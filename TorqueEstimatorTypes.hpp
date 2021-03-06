#ifndef TORQUE_ESTIMATOR_TYPES_HPP
#define TORQUE_ESTIMATOR_TYPES_HPP

#include <base/time.h>
#include <vector>

namespace torque_estimator
{
  struct WheelTorques {
    base::Time time;
    unsigned int index;
    std::vector<double> deflection;             // ExternalEncoder - InternalEncoder
    std::vector<double> deflectionVelocity;
    std::vector<double> torque;

    void resize(int size)
    {
	deflection.resize(size);
	deflectionVelocity.resize(size);
	torque.resize(size);
    }
  };

  struct HysteresisParameters {
    //Bouc Wen hysteresis parameters
    double A;
    double beta;
    double gamma;
    double n;
    double alpha;
    double ki;

    // Additional parameter 
    double gearPlay;           
    double deflectionOffset;
    double dampingConst;

    double velocitySmoothFactor;

    HysteresisParameters():
      A(0),
      beta(0),
      gamma(0),
      n(1),
      alpha(0),
      ki(0),
      gearPlay(0),
      deflectionOffset(0),
      dampingConst(0),
      velocitySmoothFactor(1)
    { }

    void setValues(std::vector<double> _p)
    {
      A       = _p[0];
      beta    = _p[1];
      gamma   = _p[2];
      n       = _p[3];
      alpha   = _p[4];
      ki      = _p[5];

      gearPlay          = _p[6];
      deflectionOffset  = _p[7];
      dampingConst      = _p[8];

      velocitySmoothFactor = _p[9] ;
    }

    void toVector(std::vector<double>& p)
    {
      p.resize(10); 

      p[0]  =  A;
      p[1]  =  beta;
      p[2]  =  gamma;
      p[3]  =  n;
      p[4]  =  alpha;
      p[5]  =  ki;
               
      p[6]  =  gearPlay;
      p[7]  =  deflectionOffset;
      p[8]  =  dampingConst;

      p[9]  =  velocitySmoothFactor;
    }
  };

  struct CouplingParameterSet {
    std::vector<HysteresisParameters> parameters;

    CouplingParameterSet(int size = 4)
    {
      parameters.resize(size);
    }
  };

  struct GroundForces {
      base::Time time;

      /* Forces parallel to the ground */
      std::vector<double> tractionForce;
      /* Forces perpendicular to the ground */
      std::vector<double> normalForce;

      GroundForces()
	  : tractionForce(4, 0),
	  normalForce(4, 0)
      {}
  };
}
#endif
