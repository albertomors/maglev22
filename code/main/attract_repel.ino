/*
 * Author: Morselli Alberto
 * Project: maglev22
 * Date: Summer-Autumn 2022
 * 
 * with the current setup based on the coil connection made [A-B = EXT-INT] and the levmag orientation [NORTH POLE pointing up]
 * a repulsion is made setting the coil with a SOUTH POLE on the top, aka setting A-B = HIGH-LOW. An attraction is instead made
 * setting A-B = LOW-HIGH, creating a NORTH-POLE on the top. Change the repel() and attract() functions depending on the setup used.
 */

//NORTH-POLE on the TOP
void attract(byte c_a, byte c_b, byte c_enable, int value){
  digitalWrite(c_a, LOW);
  digitalWrite(c_b, HIGH);
  analogWrite(c_enable, value);
}

//SOUTH-POLE on the TOP
void repel(byte c_a, byte c_b, byte c_enable, int value){
  attract(c_b, c_a, c_enable, value);
}
