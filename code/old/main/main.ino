#include <KickFiltersRT.h>
#include <SimpleKalmanFilter.h>
 // PARAMETERS - PINS
// Motor driver 1 
#define IN_X_2 9 // RED Input 1 and 2 on the motor driver controls the polarity of coil X1
#define IN_X_1 10 //ORANGE
#define IN_Y_2 11 // YELLOW Input 3 and 4 on the motor driver controls the polarity of coil X2
#define IN_Y_1 12 // GREEN
#define ENABLE_X_A 8 // BROWN Enable coil X1 - pwm signals to control the currents
#define ENABLE_Y_A 14 // BLUE  Enable coil X2

// Motor driver 2
#define IN_Y_4 3 // RED Input 1 and 2 on the motor driver controls the polarity of coil Y1
#define IN_Y_3 4 //ORANGE
#define IN_X_3 5 // YELLOW Input 3 and 4 on the motor driver controls the polarity of coil Y2
#define IN_X_4 6 //GREEN
#define ENABLE_Y_B 2 // BROWN Enable coil Y1 - pwm signals to control the currents
#define ENABLE_X_B 7// BLUE Enable coil Y2

//Sensor pins
#define Sensor_1_x 17 //YELLOW
#define Sensor_1_y 16 //BROWN
#define Sensor_1_z 15 //WHITE
byte Sensor_pins[] = {Sensor_1_x, Sensor_1_y, Sensor_1_z};
float Sensor_readings[3];
// (((((RAW SENSOR VALUE * 5000/ADCresolution) - 2500) * 1/SENSOR_AMP) * Hall mV/G)
// Sensor_AMP = 5, mV/G = 2.0
const float Voltageconstant = 5000.00/10240.00; // ((10/3)/1024) * (5/((10)/3)); Calculates from 3.3 V datalogic to mV in 5 V logic.
const float Voltageoffset = 250; //2500 mV * 1/AMP * mV/G

// Constants
int MAX_OUTPUT_X = 255;
int MIN_OUTPUT_X = -255;
int MAX_OUTPUT_Y = 255;
int MIN_OUTPUT_Y = -255;
int MAX_OUTPUT_Z = 100;
int MIN_OUTPUT_Z = -100;

#define KP_X 2.6
#define KD_X 1.0
#define KI_X 0

#define KP_Y 2.6
#define KD_Y 1.0
#define KI_Y 0

#define KP_Z -1.2
#define KD_Z -0.8
#define KI_Z 0

float setpoint_x = 0; // These values will have to be tuned
float setpoint_y = 0;
float setpoint_z = 0;



// Variables
int previous_sample_time_ms = 0;
float previous_error_x[2] = {0.0,0.0};
float previous_error_y[2] = {0.0,0.0};
float previous_error_z[2] = {0.0,0.0};
float previous_output_x = 0.0;
float previous_output_y = 0.0;
float previous_output_z = 0.0;


SimpleKalmanFilter Kalmanfilter[3] = {SimpleKalmanFilter(5, 5, 1), SimpleKalmanFilter(5, 5, 1), SimpleKalmanFilter(5, 5, 1)}; //Kalman filter, seems to be broken when used in a list, needs to be looked into more.
KickFiltersRT<float> LPfilter[3];


const float fs = 1.0/0.000062;

void Sensor_Read() { //Reads the sensors and gives back the differance in Geuss.
  
  for (int i = 0; i <= 2; i++) {
    Sensor_readings[i] = analogRead(Sensor_pins[i]);
    
    // Filters, only one of them should be enabled at the time
    Sensor_readings[i] = LPfilter[i].lowpass(Sensor_readings[i], 30, fs); //LP
    //Sensor_readings[i] = Kalmanfilter[i].updateEstimate(Sensor_readings[0]); //Kalman
    
    Sensor_readings[i] *= Voltageconstant;
    Sensor_readings[i] -= Voltageoffset;
    }
}




void setup() {
  
  //Serial.begin(115200); //Does nothing on a teensy.
  analogReadResolution(10);
  analogReadAveraging(4);
  analogWriteResolution(8);

  
  analogWriteFrequency(ENABLE_X_A, 32258);
  analogWriteFrequency(ENABLE_X_B, 32258);
  analogWriteFrequency(ENABLE_Y_A, 32258);
  analogWriteFrequency(ENABLE_Y_B, 32258);
  
  // Set pins
  pinMode(IN_X_1, OUTPUT);
  pinMode(IN_X_2, OUTPUT);
  pinMode(IN_X_3, OUTPUT);
  pinMode(IN_X_4, OUTPUT);

  pinMode(IN_Y_1, OUTPUT);
  pinMode(IN_Y_2, OUTPUT);
  pinMode(IN_Y_3, OUTPUT);
  pinMode(IN_Y_4, OUTPUT);

  pinMode(Sensor_1_x, INPUT);
  pinMode(Sensor_1_y, INPUT);
  pinMode(Sensor_1_z, INPUT);

  pinMode(ENABLE_X_A, OUTPUT); // Output for coil x1 disabled for ESP32
  pinMode(ENABLE_X_B, OUTPUT); // Output for coil x2
  
  pinMode(ENABLE_Y_A, OUTPUT); // Output for coil y1
  pinMode(ENABLE_Y_B, OUTPUT); // Output for coil y2
  
  // Initial values
  digitalWrite(IN_X_1, LOW); // Start with coils "off"
  digitalWrite(IN_X_2, LOW);
  digitalWrite(IN_X_3, LOW);
  digitalWrite(IN_X_4, LOW);
  
  digitalWrite(IN_Y_1, LOW);
  digitalWrite(IN_Y_2, LOW);
  digitalWrite(IN_Y_3, LOW);
  digitalWrite(IN_Y_4, LOW);
  

}

void loop() {
  
  // Read inputs
  Sensor_Read();
  
  float input_x = Sensor_readings[0];
  float input_y = Sensor_readings[1];
  float input_z = Sensor_readings[2];
 
   // Compute error signals
  float error_x = input_x - setpoint_x;
  float error_y = input_y - setpoint_y;
  float error_z = input_z - setpoint_z;

  
  //Compute controller gain - Velocity form
  float output_x = 1 * (previous_output_x + KP_X*(error_x-previous_error_x[0]) + KI_X*error_x + KD_X*(error_x - 2*previous_error_x[0] + previous_error_x[1]));
  float output_y = 1 * (previous_output_y + KP_Y*(error_y-previous_error_y[0]) + KI_Y*error_y + KD_Y*(error_y - 2*previous_error_y[0] + previous_error_y[1]));
  float output_z = 1 * (previous_output_z + KP_Z*(error_z-previous_error_z[0]) + KI_Z*error_z + KD_Z*(error_z - 2*previous_error_z[0] + previous_error_z[1]));


  if (output_x > MAX_OUTPUT_X){
    output_x = MAX_OUTPUT_X;
  }else if (output_x < MIN_OUTPUT_X){
    output_x = MIN_OUTPUT_X;
  }

  if (output_y > MAX_OUTPUT_Y){
    output_y = MAX_OUTPUT_Y;
  }else if (output_y < MIN_OUTPUT_Y){
    output_y = MIN_OUTPUT_Y;
  }
  
  if (output_z > MAX_OUTPUT_Z){
    output_z = MAX_OUTPUT_Z;
  }else if (output_z < MIN_OUTPUT_Z){
    output_z = MIN_OUTPUT_Z;
  }


  
  // Update values
  previous_error_x[1] = previous_error_x[0];
  previous_error_x[0] = error_x;
  previous_output_x = output_x;
  previous_error_y[1] = previous_error_y[0];
  previous_error_y[0] = error_y;
  previous_output_y = output_y;
  //
  previous_error_z[1] = previous_error_z[0];
  previous_error_z[0] = error_z;
  previous_output_z = output_z;











  //PRINT: INPUT/OUTPUT
  Serial.print(Sensor_readings[0]);
  Serial.print(" ");
  Serial.print(Sensor_readings[1]); 
  Serial.print(" ");
  Serial.print(Sensor_readings[2]);
  Serial.print(" "); // a space ' ' or  tab '\t' character is printed between the  values.
  Serial.print(round(output_x));
  Serial.print(" "); // a space ' ' or  tab '\t' character is printed between the two values.
  Serial.print(round(output_y));
  Serial.print(" "); // a space ' ' or  tab '\t' character is printed between the two values.
  Serial.println(round(output_z)); // the last value is followed by a carriage return and a newline characters.
  
  
 

  turn_X(round(output_x), round(output_z));  //You can adjust turn_X and turn_Y to choose which output algorithm to use, The old version is bugged, but has better performance.
  turn_Y(round(output_y), round(output_z));

  
  
}
