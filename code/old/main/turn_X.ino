#include "Arduino.h"
// OUTPUT ALGORITHM: The old version has better permormance, but is bugged due to not constraining the ouput to < 0.
void turn_X(int u_x, int u_z) 
{
/*
  // NEW VERSION
int sumx1 = (u_x + u_z);
int sumx2 = (-u_x + u_z);

//Saturation
if(sumx1>= 255){
  sumx1 = 255;
}
else if(sumx1<=(-255)){
  sumx1 = -255;
}

if(sumx2>= 255){
  sumx2 = 255;
}
else if(sumx2<=(-255)){
  sumx2 = -255;
}
  if(sumx1>=0){
    digitalWrite(IN_X_1, LOW);
    digitalWrite(IN_X_2, HIGH);
    analogWrite(ENABLE_X_A, sumx1);
  }
  else if(sumx1<0){
    sumx1 = abs(sumx1);
    digitalWrite(IN_X_1, HIGH);
    digitalWrite(IN_X_2, LOW);
    analogWrite(ENABLE_X_A, sumx1);
  }

  if(sumx2>=0){
    digitalWrite(IN_X_3, LOW);
    digitalWrite(IN_X_4, HIGH);
    analogWrite(ENABLE_X_B, sumx2);
  }
  else if(sumx2<0){
    sumx2=abs(sumx2);
    digitalWrite(IN_X_3, HIGH);
    digitalWrite(IN_X_4, LOW);
    analogWrite(ENABLE_X_B, sumx2);
  }
  
  */
  // OLD VERSION 
  
  if(u_z>=0) // if z>=0 then u_x + u_z
  {
    if(u_x>=0)
    {
      digitalWrite(IN_X_1, LOW); // Coil x1 +u_x + u_z
      digitalWrite(IN_X_2, HIGH);
      analogWrite(ENABLE_X_A, u_x + u_z);
      digitalWrite(IN_X_3, HIGH); // Coil x2 -u_x + u_z
      digitalWrite(IN_X_4, LOW);
      analogWrite(ENABLE_X_B, u_x - u_z);
    }
    else
    {
      u_x=abs(u_x);
      digitalWrite(IN_X_1, HIGH); // Coil x1 -u_x + u_z
      digitalWrite(IN_X_2, LOW);
      analogWrite(ENABLE_X_A, u_x - u_z);
      digitalWrite(IN_X_3, LOW); // Coil x2 +u_x + u_z
      digitalWrite(IN_X_4, HIGH);
      analogWrite(ENABLE_X_B, u_x + u_z);
    }
  }
  else // if z<0 then u_x - u_z
  {
    u_z = abs(u_z);
  if(u_x>=0)
    {
      digitalWrite(IN_X_1, LOW); // Coil x1 +u_x - u_z
      digitalWrite(IN_X_2, HIGH);
      analogWrite(ENABLE_X_A, u_x - u_z);
      digitalWrite(IN_X_3, HIGH); // Coil x2 -u_x - u_z
      digitalWrite(IN_X_4, LOW);
      analogWrite(ENABLE_X_B, u_x + u_z);
    }
    else
    {
      u_x=abs(u_x);
      digitalWrite(IN_X_1, HIGH); // Coil x1 -u_x - u_z
      digitalWrite(IN_X_2, LOW);
      analogWrite(ENABLE_X_A, u_x + u_z);
      digitalWrite(IN_X_3, LOW); // Coil x2 +u_x - u_z
      digitalWrite(IN_X_4, HIGH);
      analogWrite(ENABLE_X_B, u_x - u_z);
    }
  }
  
}
