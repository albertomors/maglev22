/*
 * Author: Morselli Alberto
 * 
 * 
 * This file contains the settings used for the implementation:
 *   -TEENSY4.0 pin connections [editable here]
 *   -Code constants
 *   -PID parameters
 *
 * TEENSY4.0 pins from 2 to 7 are dedicated to MOTOR DRIVER 1 / SX and controls X1/Y1 coils
 *                from 8 to 12+14 are dedicated to MOTOR DRIVER 2 / DX and controls X2/Y2 coils
 *                from 15 to 19 are dedicated to the SENSORS X,Y,Z (based on 3 or 5 sensor implementation)
 *                20 is dedicated to read Vref supplied by INA128
 */

// pin connections ---------------------------------------------------------------

// motor driver 1 - SX - controls X1-coil and Y1-coil
#define X1_A 3
#define X1_B 4
#define Y1_A 5
#define Y1_B 6

#define ENABLE_X1 2
#define ENABLE_Y1 7

// motor driver 2 - DX - controls X2-coil and Y2-coil
#define X2_A 9
#define X2_B 10
#define Y2_A 11
#define Y2_B 12

#define ENABLE_X2 8
#define ENABLE_Y2 14

// hall effect sensors
#define SENSOR_x1 15
#define SENSOR_x2 16
#define SENSOR_y1 17
#define SENSOR_y2 18
#define SENSOR_z 19
const uint8_t SENSOR_ARRAY[5] = {SENSOR_x1, SENSOR_x2, SENSOR_y1, SENSOR_y2, SENSOR_z};

#define VREF_PIN 20

// others sensors constants ------------------------------------------------------------

const double n2v = 3.3/256;
const double v2n = 1.0/n2v;
const double i2o = 3.96; // ad623 gain set TODO
const double o2i = 1.0/i2o;
const double vref = 1.584;

const double sens = 2; // the value is in [mV/gauss], sens1;
const double sens_1 = 1000.0/sens; // now the value is in [gauss/V]  

// output limitations if set ------------------------------------------------------------

const double X_SCALEFACTOR = 1;
const double Y_SCALEFACTOR = 1;
const double Z_SCALEFACTOR = .4; // prioritize x & y control

// pid parameters -----------------------------------------------------------------------

#define KP_X 1
#define KD_X 0.01
#define KI_X 0

#define KP_Y KP_X
#define KD_Y KD_X
#define KI_Y 0

#define KP_Z KP_X
#define KD_Z KD_X
#define KI_Z 0
