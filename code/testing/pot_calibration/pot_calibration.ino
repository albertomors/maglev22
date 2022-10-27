/*
 * Author: Morselli Alberto
 * Project: maglev22
 * 
 * This tool allows you to set all the potentiometer in the board in the correct way. Use it with the levmag wood stand that make it stays centered on [x,y,z] = [0,0,z_eq]
 * where z_eq is approx 2.5+0.4+1.8=4.7 mm from the permanent magnets top surface, and 2.9 mm from the top soft mat layer. With this setup, set all the potentiometer so that
 * dv_out is as close as possible to zero.
 *
 * You can after read ux,uy,uz from the 5 sensors, and their gauss corresponding value and also read vref supplied by the INA128 to the AD623s.
 * Set it as close as possible to 1.584 that is the mid-way point from low saturation value [0] and top saturation value [3.168], that lowered by the zeners stadium goes to [2.94].
 * Max and min values red and stored in dv_out are, in fact, 0 and 2.94.
 * 
 */
#include <SimpleKalmanFilter.h>

uint16_t readings[5], filt[5];
double v_out[5], dv_out[5], dv_in[5], u[3], g[3];

double vref, vref1, n2v, v2n;
double sens, sens_1, o2i, i2o;

// to estimate e[i], AKA measurement uncertainty, read data from the potentiometers, print readings[]
// and use n>> values printed on the serial monitor to calc std deviation [corrected, the one with n-1] = s
// then to get the 99.7% coverage interval multiply s by 3 to get 3*s = {2.92 3.06  2.96  2.98  3.65}

uint8_t e[5] = {8,8,8,8,8};
SimpleKalmanFilter kf[6] = {SimpleKalmanFilter(e[0],e[0],0.01), \
                            SimpleKalmanFilter(e[1],e[1],0.01), \
                            SimpleKalmanFilter(e[2],e[2],0.01), \
                            SimpleKalmanFilter(e[3],e[3],0.01), \
                            SimpleKalmanFilter(e[4],e[4],0.01), \
                                                                \
                            SimpleKalmanFilter(0.02, 0.02, 0.01)}; //last one is for vref

void setup() {
  n2v = 3.3/1024;
  v2n = 1.0/n2v;
  i2o = 3.96; %TODO
  o2i = 1.0/i2o;
  
  sens = 2; // the value is in [mV/gauss]
  sens_1 = 1000.0/sens; // now the value is in [gauss/V] --- = (2/27 + 1.8)/1000
  
  analogReadResolution(10); // [0 : 1024]
  analogReadAveraging(4); // read 4 times and get the average value
}

void print_all(uint16_t arr[], int len){
  for(int i=0; i<len; i++){
    Serial.print(arr[i]);
    Serial.print(" ");
  }
  Serial.println();
}
void print_all(double arr[], int len){
  for(int i=0; i<len; i++){
    Serial.print(arr[i],5);
    Serial.print(" ");
  }
  Serial.println();
}

void loop() {
  vref = analogRead(20) * n2v;
  vref1 = kf[5].updateEstimate(vref); // should be as close as possible to 1.584
  
  for(int i=0; i<5; i++){
    int k = i+15;
    readings[i] = analogRead(k);
    filt[i] = kf[i].updateEstimate(readings[i]); //read and filter adc data [0-1024]

    v_out[i] = filt[i] * n2v; //map from [0 : 1024] to [0 : 3.3V] ...
    dv_out[i] = v_out[i] - vref; // ... and subtract Vref to have a [-vref : vref] value
    dv_in[i] = dv_out[i] * o2i;
  }

  // compute x,y,z values with the chosen positive direction towards x1,y1,bottom
  // SO: ux/uy >= 0 says the levmag is towards x1,y1
  //     uz >= 0 says the levmag is lower than z_eq, towards the bottom
  u[0] = (dv_in[0] - dv_in[1]) * 0.5;
  u[1] = (dv_in[2] - dv_in[3]) * 0.5;
  u[2] = dv_in[4];

  // get gauss values red in the 3 axis
  for(int i=0; i<3; i++){
    g[i] = u[i] * sens_1;
  }

  // print what you want to see on the screen (pass array and array length)
  Serial.print(vref1,3);
  Serial.print(" ### ");
  print_all(dv_in, sizeof(dv_in)/sizeof(dv_in[0]));
}
