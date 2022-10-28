/* 
 * Author: Morselli Alberto
 * Project: maglev22
 * Date: Summer-Autumn 2022
 *  
 *  
 * OLD VERSION
 *
 * set the coils ALWAYS in a dual behaviour (one R and the other A) prioritizing uy value and adding after uz.
 * when uz is high and uy is low this can leads to saturate one of the two pwm values to 0
 *
 * example: uy=5, uz=50 => set Y1-R with +5+50 = +55 => (R with pwm = 55)
 *                             Y2-A with +5-50 = -45 clamped to 0 because of saturation => (A with pwm = 0)
 *
 * R stands for REPELS, A stands for ATTRACTS. First, based on uy>=0 or <0 we chose if the Y1-coil will R-epel or A-ttract,
 * Y2-coil will do the opposite. The table down here explain the value based on the sign of uy and on the behaviour(R/A) of the coil.
 * Finally value is constrained between 0 and 255.
 *
 * uy>=0: Y1-R = +uy+uz # X2-A = +uy-uz
 * uy<0:  Y1-A = -uy-uz # X2-R = -uy+uz
 *  
 */

void turn_Y_OLD(int uy, int uz) //OLD - debugging version
{
  int value = 0;

  if(uy>=0) // Y1-R = +uy+uz # Y2-A = +uy-uz
  {
    value = +uy +uz;
    value = constrain(value, 0, 255);
    repel(Y1_A,Y1_B,ENABLE_Y1,value); //Y1-R

    Serial.print("uy>0: ");
    Serial.print("Y1-R: ");
    Serial.print(value);
    Serial.print(" ");

    value = +uy -uz;
    value = constrain(value, 0, 255);
    attract(Y2_A,Y2_B,ENABLE_Y2,value); //Y2-A

    Serial.print("Y2-A: ");
    Serial.print(value);
    Serial.print(" ");
  }

  else // (uy<0) Y1-A = -uy-uz # Y2-R = -uy+uz
  {
    value = -uy -uz;
    value = constrain(value, 0, 255);
    attract(Y1_A,Y1_B,ENABLE_Y1,value); //Y1-A

    Serial.print("uy<0: ");
    Serial.print("Y1-A: ");
    Serial.print(value);
    Serial.print(" ");

    value = -uy +uz;
    value = constrain(value, 0, 255);
    repel(Y2_A,Y2_B,ENABLE_Y2,value); //Y2-R

    Serial.print("Y2-R: ");
    Serial.print(value);
    Serial.print(" ");
  }
}

// ---------------------------------------------------------------------------------------------------

void turn_Y_OLD_final(int uy, int uz) //OLD - performing version
{
  int value = 0;

  if(uy>=0) // Y1-R = +uy+uz # Y2-A = +uy-uz
  {
    value = +uy +uz;
    value = constrain(value, 0, 255);
    repel(Y1_A,Y1_B,ENABLE_Y1,value); //Y1-R

    value = +uy -uz;
    value = constrain(value, 0, 255);
    attract(Y2_A,Y2_B,ENABLE_Y2,value); //Y2-A
  }

  else // (uy<0) Y1-A = -uy-uz # Y2-R = -uy+uz
  {
    value = -uy -uz;
    value = constrain(value, 0, 255);
    attract(Y1_A,Y1_B,ENABLE_Y1,value); //Y1-A

    value = -uy +uz;
    value = constrain(value, 0, 255);
    repel(Y2_A,Y2_B,ENABLE_Y2,value); //Y2-R
  }
}

/*
 * NEW VERSION
 *
 * calcs before uy+uz for Y1 and -uy+uz for Y2 (dual action for y-axis but same for z-axis) and regardings to >=0 or <0 sets
 * the coils. This means that in some cases both coils can A-ttract or R-epel.
 *
 * example: uy=5, uz=50 => y1_value = 5+50 = 55 (R with pwm = 55)
 *                         y2_value = -5+50 = +45 (R with pwm = 45)
 *
 * value is first calculated for both of the 2 coils and constrained between -255 and +255.
 * If >=0 the coil will REPEL with +value, if <0 the coil will ATTRACT with -value=abs(value)
 * 
 */

void turn_Y_NEW(int uy, int uz) //NEW - debugging version
{
  int sumy1 = +uy +uz;
  int sumy2 = -uy +uz;

  sumy1 = constrain(sumy1,-255,+255);
  sumy2 = constrain(sumy2,-255,+255);

  Serial.print("s1: ");
  Serial.print(sumy1);
  Serial.print(" ");
  Serial.print("s2: ");
  Serial.print(sumy2);
  Serial.print(" ");

  if(sumy1>=0)
  { repel(Y1_A,Y1_B,ENABLE_Y1,sumy1); //Y1-R
  }
  else
  { sumy1 = abs(sumy1);
    attract(Y1_A,Y1_B,ENABLE_Y1,sumy1); //Y1-A
  }

  if(sumy2>=0)
  { repel(Y2_A,Y2_B,ENABLE_Y2,sumy2); //Y2-R
  }
  else
  { sumy2=abs(sumy2);
    attract(Y2_A,Y2_B,ENABLE_Y2,sumy2); //Y2-A
  }
}

// ---------------------------------------------------------------------------------------------------

void turn_Y_NEW_final(int uy, int uz) //NEW - performing version
{
  int sumy1 = +uy +uz;
  int sumy2 = -uy +uz;

  sumy1 = constrain(sumy1,-255,+255);
  sumy2 = constrain(sumy2,-255,+255);

  if(sumy1>=0)
  { repel(Y1_A,Y1_B,ENABLE_Y1,sumy1); //Y1-R
  }
  else
  { sumy1 = abs(sumy1);
    attract(Y1_A,Y1_B,ENABLE_Y1,sumy1); //Y1-A
  }

  if(sumy2>=0)
  { repel(Y2_A,Y2_B,ENABLE_Y2,sumy2); //Y2-R
  }
  else
  { sumy2=abs(sumy2);
    attract(Y2_A,Y2_B,ENABLE_Y2,sumy2); //Y2-A
  }
}
