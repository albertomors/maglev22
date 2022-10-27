/*
 * Author: Morselli Alberto
 * Project: Maglev PID controller
 * Date: Summer-Autumn 2022
 *
 *
 * -SENSOR_x1 face X1-coil and gives his back to X2-coil
 *         x2 face X2-coil               back to X1-coil
 * -SENSOR_y1 face Y1-coil and gives his back to Y2-coil
 *         y2 face Y2-coil               back to Y1-coil
 * -SENSOR_z face the top
 * 
 * Ff a magnet SOUTH pole approaches the sensor (inflow in the magnet) the sensor drive the v_outage higher.
 * This 5-sensor configuration leads to positive deviation on x1 and y1 sensors when the magnet moves towards X1 and Y1 coils,
 * and negative when he moves away. x2 and y2 sensors have the opposite behaviour. z sensor leads to positive devs when the magnet
 * goes down and positive when it goes up.
 *
 * With the connection made on the board OUT1-2-3-4 are connected respectively to X1A-B-Y1A-B. Same pattern for motor driver 2.
 * Wires A and B are connected respectively to EXTernal and INTernal heads of the wire's coil.
 * Setting A-B to HIGH-LOW leads to SOUTH pole on his top and NORTH pole on his bottom, R-epelling the levmag that has SOUTH pole on his bottom.
 *         A-B to LOW-HIGH          NORTH pole on his top and SOUTH pole on his bottom, A-ttracting
 *
 * MOTOR-DRIVER 1 pilots X1- and Y1-coils
 * MOTOR-DRIVER 2 pilots X2- and Y2-coils
 *
 * TEENSY4.0 pins from 2 to 7 are dedicated to MOTOR DRIVER 1 / SX and controls X1/Y1 coils
 *                from 8 to 12+14 are dedicated to MOTOR DRIVER 2 / DX and controls X2/Y2 coils
 *                from 15 to 19 are dedicated to the SENSORS X,Y,Z (based on 3 or 5 sensor implementation)
 *                20 is dedicated to read Vref supplied by INA128
 *
 * there are two strategies to set coils behaviour:
 *    the OLD: set the coils ALWAYS in a dual behaviour (one R and the other A) prioritizing ux/uy value and adding after uz.
 *            when uz is high and ux/uy is low this can leads to saturate one of the two pwm vals to 0
 *
 *            example: ux=5, uz=50 => set X1-R with +5+50 = +55 => (R with pwm = 55)
 *                                        X2-A with +5-50 = -45 clamped to 0 because of saturation => (A with pwm = 0)
 *
 *    the NEW: calcs before ux+uz for X1 and -ux+uz for X2 (dual action for x/y-axis but same for z-axis) and regardings to >=0 or <0 sets
 *            the coils. This means that in some cases both coils can A-ttract or R-epel.
 *
 *            example: ux=5, uz=50 => x1_val = 5+50 = 55 (R with pwm = 55)
 *                                    x2_val = -5+50 = +45 (R with pwm = 45)
 */

#include <SimpleKalmanFilter.h>
#include "defines.h"

void setup()
{
  analogReadResolution(8);
  analogReadAveraging(2);
  analogWriteResolution(8);

  //Code running freq is approx 10 kHz
  analogWriteFrequency(ENABLE_X1, 32000);
  analogWriteFrequency(ENABLE_X2, 32000);
  analogWriteFrequency(ENABLE_Y1, 32000);
  analogWriteFrequency(ENABLE_Y2, 32000);
  
  // set pins
  for(int i=2; i<=12; i++){ pinMode(i,OUTPUT); }
  pinMode(14,OUTPUT);
  for(int i=15; i<=20; i++){ pinMode(i,INPUT); }
  
  // start with coils "off"
  digitalWrite(X1_A, LOW);
  digitalWrite(X1_B, LOW);
  digitalWrite(X2_A, LOW);
  digitalWrite(X2_B, LOW);
  
  digitalWrite(Y1_A, LOW);
  digitalWrite(Y1_B, LOW);
  digitalWrite(Y2_B, LOW);
  digitalWrite(Y2_A, LOW);
}

// --------------------------------------------------------------

double ex[3] = {0.0,0.0,0.0}; // e_k, e_(k-1), e_(k-2)
double ey[3] = {0.0,0.0,0.0};
double ez[3] = {0.0,0.0,0.0};

double ux[2] = {0.0,0.0}; // u_k, u_(k-1)
double uy[2] = {0.0,0.0};
double uz[2] = {0.0,0.0};

uint16_t readings[5];
double v_out[5], dv_out[5], filt[5], u[3], g[3];

double dwx2,dwy1,wx1,wx2,wy1,wy2;

// to estimate e[i], aka measurement uncertainty, read and and use n>> values printed on the serial monitor 
// to calc std deviation [corrected, the one with n-1] = s
// then to get the 99.7% coverage interval multiply s by 3 to get 3*s
double e[6] = {.005,.005,.005,.005,.005,.002};
SimpleKalmanFilter kf[6] = {SimpleKalmanFilter(e[0],e[0],0.01), \
                            SimpleKalmanFilter(e[1],e[1],0.01), \
                            SimpleKalmanFilter(e[2],e[2],0.01), \
                            SimpleKalmanFilter(e[3],e[3],0.01), \
                            SimpleKalmanFilter(e[4],e[4],0.01), \
                                                                \
                            SimpleKalmanFilter(e[5],e[5],0.01)}; //last one is for vref
unsigned long t1,t2,t3;
double fs = 0;

// --------------------------------------------------------

void loop()
{
  t1 = micros();
  
  for(int i=0; i<5; i++){
    readings[i] = analogRead(SENSOR_ARRAY[i]);

    v_out[i] = readings[i]*n2v; //map from [0 : 1024] to [0 : 3.3V] ...
    dv_out[i] = v_out[i] - vref; // ... and subtract Vref to have a [-vref : vref] value
    dv_in[i] = dv_out[i]*o2i; //divide by G
    
    filt[i] = kf[i].updateEstimate(dv_in[i]); //filter datas

    Serial.print(dv_in[i],4);
    Serial.print(" ");
  }

  t2 = micros()-t1;

  /* This is the couples of COILS and sensors placement. If the maglev is so much off-center                  
   * towards X1 the right sensor to priotize is y1 instead of y2, more sensible. Same thing
   * if the maglev is towards Y2 the most sensitive and accurate sensor is x1 instead of x2.
   * If it's almost on the center the weights don't differ too much.
   *                   
   *                     x-axis
   *                       ^
   *                       |
   *     
   *                     X1-y1
   * 
   * y-axis  <-- Y1-x2     o     Y2-x1
   * 
   *                     X2-y2
   *                     
   *                     
   */

  dwx2 = (dv_in[2] - dv_in[3]) * 0.5 / 0.4; // use y to estimate the X-weights [how much priority give to x2 than to x1]
  wx2 = 0.5 + dwx2 * 0.5;
  wx1 = 1 - wx2;
  
  dwy1 = (dv_in[0] - dv_in[1]) * 0.5 / 0.4; // instead use x to estimate the Y-weights [how much priority give to y1 than to y2]
  wy1 = 0.5 + dwy1 * 0.5;
  wy2 = 1 - wy1;

//  Serial.print("#W> ");
//  Serial.print(wx1);
//  Serial.print(" ");
//  Serial.print(wx2);
//  Serial.print(" ");
//  Serial.print(wy1);
//  Serial.print(" ");
//  Serial.println(wy2);

  // here you can override values to test the difference
//  wx1 = 0.5; wx2 = 0.5; wy1 = 0.5; wy2 = 0.5;

  // compute x,y,z values with the chosen positive direction towards x1,y1,bottom
  // SO: positive ux/uy contributes says the levmag is towards x1,y1 or flipped on x1,y1.
  //     [if is towards x1 but flipped on x2 the total ux may be <=>0 !!! #TODO]
  //     uz >= 0 says the levmag is lower than z_eq, towards the bottom
   
  u[0] = dv_in[0]*wx1 - dv_in[1]*wx2;
  u[1] = dv_in[2]*wy1 - dv_in[3]*wy2;
  u[2] = dv_in[4];

  // get gauss value
  for(int i=0; i<3; i++){
    g[i] = u[i] * sens1;
  }

  //correct signs of the errors
  ex[0] = u[0]; //towards x1 => positive val => x1 repel (>=0)
  ey[0] = u[1]; //towards y1 => positive val => y1 repel (>=0)
  ez[0] = 0; //towards z => positive val => to lift all coils must attract (<0) => sign change

  Serial.print("#e> ");
  Serial.print(ex[0]);
  Serial.print(" ");
  Serial.print(ey[0]);
  Serial.print(" ");
  Serial.print(ez[0]);
  Serial.print(" ");

  // compute controller gain - Velocity form
  ux[0] = ux[1] + KP_X*(ex[0]-ex[1]) + KI_X*ex[0] + KD_X*(ex[0] - 2*ex[1] + ex[2]);
  uy[0] = uy[1] + KP_Y*(ey[0]-ey[1]) + KI_Y*ey[0] + KD_Y*(ey[0] - 2*ey[1] + ey[2]);
  uz[0] = uz[1] + KP_Z*(ez[0]-ez[1]) + KI_Z*ez[0] + KD_Z*(ez[0] - 2*ez[1] + ez[2]);

  Serial.print("#pid> ");
  Serial.print(ux[0]);
  Serial.print(" ");
  Serial.print(uy[0]);
  Serial.print(" ");
  Serial.print(uz[0]);
  Serial.print(" ");
  
  // update values
  ex[2] = ex[1]; ex[1] = ex[0];
  ey[2] = ey[1]; ey[1] = ey[0];
  ez[2] = ez[1]; ez[1] = ez[0];

  ux[1] = ux[0];
  uy[1] = uy[0];
  uz[1] = uz[0];

  // give priorities to the controller [values between 0 and 1]
  ux[0] = round(ux[0] * X_SCALEFACTOR);
  uy[0] = round(uy[0] * Y_SCALEFACTOR);
  uz[0] = round(uz[0] * Z_SCALEFACTOR);

  turn_X_NEW(ux[0], uz[0]);
  turn_Y_NEW(uy[0], uz[0]);

  Serial.println();
  Serial.print(fs);
  Serial.print(" Hz # ");

  t3 = micros() - t1;
  fs = 1000000.0/t3;
}
