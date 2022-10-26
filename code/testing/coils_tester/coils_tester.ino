/* Author: Morselli Alberto
 *  
 * use it to try coils separately.
 * With the connection made on the board OUT1-2-3-4 are connected respectively to X1A-B-Y1A-B. Same pattern for motor driver 2.
 * Wires A and B are connected respectively to EXTernal and INTernal heads of the wire's coil.
 * Setting A-B to HIGH-LOW leads to SOUTH pole on his top and NORTH pole on his bottom, R-epelling the levmag that has SOUTH pole on his bottom.
 *         A-B to LOW-HIGH          NORTH pole on his top and SOUTH pole on his bottom, A-ttracting
 */
  
#include "defines.h"

void setup() {
  for(int i=2; i<=12; i++){ pinMode(i,OUTPUT); }
  pinMode(14,OUTPUT);
  
  analogReadResolution(10);
  analogWriteResolution(8);
  analogWriteFrequency(ENABLE_X1,32000); //max value for L298 is 40kHz
  analogWriteFrequency(ENABLE_X2,32000);
  analogWriteFrequency(ENABLE_Y1,32000);
  analogWriteFrequency(ENABLE_Y2,32000);
}

void attract(byte c_a, byte c_b, byte c_enable, int value){
  digitalWrite(c_a, LOW);
  digitalWrite(c_b, HIGH);
  analogWrite(c_enable, value);
}

void repel(byte c_a, byte c_b, byte c_enable, int value){
  attract(c_b, c_a, c_enable, value);
}

void turnoff(byte c_a, byte c_b, byte c_enable = 0, int value = 0){
  digitalWrite(c_a, LOW);
  digitalWrite(c_b, LOW);
}

void loop() {
}
