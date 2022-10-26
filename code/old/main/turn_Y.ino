#include "Arduino.h"
// OUTPUT ALGORITHM: The old version has better permormance, but is bugged due to not constraining the ouput to < 0.
void turn_Y(int u_y, int u_z) // implement this one into turn x and turn y 
{
  /*
  // NEW VERSION

int sumy1 = (u_y + u_z);
int sumy2 = (-u_y + u_z);

//Saturation
if(sumy1>= 255){
  sumy1 = 255;
}
else if(sumy1<=(-255)){
  sumy1 = -255;
}

if(sumy2>= 255){
  sumy2 = 255;
}
else if(sumy2<=(-255)){
  sumy2 = -255;
}

  if(sumy1>=0){
    digitalWrite(IN_Y_1, LOW);
    digitalWrite(IN_Y_2, HIGH);
    analogWrite(ENABLE_Y_A, sumy1);
  }
  else if(sumy1<0){
    sumy1 = abs(sumy1);
    digitalWrite(IN_Y_1, HIGH);
    digitalWrite(IN_Y_2, LOW);
    analogWrite(ENABLE_Y_A, sumy1);
  }

  if(sumy2>=0){
    digitalWrite(IN_Y_3, LOW);
    digitalWrite(IN_Y_4, HIGH);
    analogWrite(ENABLE_Y_B, sumy2);
  }
  else if(sumy2<0){
    sumy2=abs(sumy2);
    digitalWrite(IN_Y_3, HIGH);
    digitalWrite(IN_Y_4, LOW);
    analogWrite(ENABLE_Y_B, sumy2);
  }
  */
  // OLD VERSION 
  
  if(u_z>=0) // if z>=0 then u_x + u_z
  {
    if(u_y>=0)
    {
      digitalWrite(IN_Y_1, LOW); // Coil y1 +u_y + u_z
      digitalWrite(IN_Y_2, HIGH);
      analogWrite(ENABLE_Y_A, u_y + u_z);
      digitalWrite(IN_Y_3, HIGH); // Coil y2 -u_y + u_z
      digitalWrite(IN_Y_4, LOW);
      analogWrite(ENABLE_Y_B, u_y - u_z);
    }
    else
    {
      u_y=abs(u_y);
      digitalWrite(IN_Y_1, HIGH); // Coil y1 -u_y + u_z
      digitalWrite(IN_Y_2, LOW);
      analogWrite(ENABLE_Y_A, u_y - u_z);
      digitalWrite(IN_Y_3, LOW); // Coil y2 +u_y - u_z
      digitalWrite(IN_Y_4, HIGH);
      analogWrite(ENABLE_Y_B, u_y + u_z);
      
    }
  }
  else // if z<0 then u_y - u_z
  {
    u_z = abs(u_z);
    if(u_y>=0)
    {
      digitalWrite(IN_Y_1, LOW); // Coil y1 +u_y - u_z
      digitalWrite(IN_Y_2, HIGH);
      analogWrite(ENABLE_Y_A, u_y - u_z);
      digitalWrite(IN_Y_3, HIGH); // Coil y2 -u_y - u_z
      digitalWrite(IN_Y_4, LOW);
      analogWrite(ENABLE_Y_B, u_y + u_z);
    }
    else
    {
      u_y=abs(u_y);
      digitalWrite(IN_Y_1, HIGH); // Coil y1 -u_y - u_z
      digitalWrite(IN_Y_2, LOW);
      analogWrite(ENABLE_Y_A, u_y + u_z);
      digitalWrite(IN_Y_3, LOW); // Coil y2 +u_y - u_z
      digitalWrite(IN_Y_4, HIGH);
      analogWrite(ENABLE_Y_B, u_y - u_z);
    }  
  }
}
