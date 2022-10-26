/*
 * Author: Morselli Alberto
 * 
 * with the current setup based on the coil connection made [A-B = EXT-INT] and the levmag orientation [NORTH POLE pointing up]
 * a repulsion is made setting the coil with a SOUTH POLE on the top, aka setting A-B = HIGH-LOW. An attraction is instead made
 * setting A-B = LOW-HIGH, creating a NORTH-POLE on the top. Change the repel() and attract() functions depending on the setup used.
 */

//SOUTH-POLE on the TOP
void repel(byte ca, byte cb, byte c_enable, int value){
  digitalWrite(ca, HIGH);
  digitalWrite(cb, LOW);
  analogWrite(c_enable, value);
}

//NORTH-POLE on the TOP
void attract(byte ca, byte cb, byte c_enable, int value){
  repel(cb,ca,c_enable,value);
}
