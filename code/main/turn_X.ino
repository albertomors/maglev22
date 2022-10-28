/*
 * Author: Morselli Alberto
 * Project: maglev22
 * Date: Summer-Autumn 2022
 * 
 * 
 * OLD VERSION
 *
 * set the coils ALWAYS in a dual behaviour (one R and the other A) prioritizing ux value and adding after uz.
 * when uz is high and ux is low this can leads to saturate one of the two pwm values to 0
 *
 * example: ux=5, uz=50 => set X1-R with +5+50 = +55 => (R with pwm = 55)
 *                             X2-A with +5-50 = -45 clamped to 0 because of saturation => (A with pwm = 0)
 *
 * R stands for REPELS, A stands for ATTRACTS. First, based on ux>=0 or <0 we chose if the X1-coil will R-epel or A-ttract,
 * X2-coil will do the opposite. The table down here explain the value based on the sign of ux and on the behaviour(R/A) of the coil.
 * Finally value is constrained between 0 and 255.
 *
 * ux>=0: X1-R = +ux+uz # X2-A = +ux-uz
 * ux<0:  X1-A = -ux-uz # X2-R = -ux+uz
 *
 */

void turn_X_OLD(int ux, int uz) //OLD - debugging version
{
  int value = 0;

  if(ux>=0) // X1-R = +ux+uz # X2-A = +ux-uz
  {
    value = +ux +uz;
    value = constrain(value, 0, 255);
    repel(X1_A,X1_B,ENABLE_X1,value); //X1-R

    Serial.print("ux>0: ");
    Serial.print("X1-R: ");
    Serial.print(value);
    Serial.print(" ");

    value = +ux -uz;
    value = constrain(value, 0, 255);
    attract(X2_A,X2_B,ENABLE_X2,value); //X2-A

    Serial.print("X2-A: ");
    Serial.print(value);
    Serial.print(" ");
  }

  else // (ux<0) X1-A = -ux-uz # X2-R = -ux+uz
  {
    value = -ux -uz;
    value = constrain(value, 0, 255);
    attract(X1_A,X1_B,ENABLE_X1,value); //X1-A

    Serial.print("ux<0: ");
    Serial.print("X1-A: ");
    Serial.print(value);
    Serial.print(" ");

    value = -ux +uz;
    value = constrain(value, 0, 255);
    repel(X2_A,X2_B,ENABLE_X2,value); //X2-R

    Serial.print("X2-R: ");
    Serial.print(value);
    Serial.print(" ");
  }
}

// ---------------------------------------------------------------------------------------------------

void turn_X_OLD_final(int ux, int uz) //OLD - performing version
{
  int value = 0;

  if(ux>=0) // X1-R = +ux+uz # X2-A = +ux-uz
  {
    value = +ux +uz;
    value = constrain(value, 0, 255);
    repel(X1_A,X1_B,ENABLE_X1,value); //X1-R

    value = +ux -uz;
    value = constrain(value, 0, 255);
    attract(X2_A,X2_B,ENABLE_X2,value); //X2-A
  }

  else // (ux<0) X1-A = -ux-uz # X2-R = -ux+uz
  {
    value = -ux -uz;
    value = constrain(value, 0, 255);
    attract(X1_A,X1_B,ENABLE_X1,value); //X1-A

    value = -ux +uz;
    value = constrain(value, 0, 255);
    repel(X2_A,X2_B,ENABLE_X2,value); //X2-R
  }
}

/*
 * NEW VERSION
 *
 * calcs before ux+uz for X1 and -ux+uz for X2 (dual action for x axis but same for z-axis) and regardings to >=0 or <0 sets
 * the x-coils. This means that in some cases both coils can A-ttract or R-epel.
 *
 * example: ux=5, uz=50 => x1_value = 5+50 = 55 (R with pwm = 55)
 *                         x2_value = -5+50 = +45 (R with pwm = 45)
 *
 * value is first calculated for both of the 2 coils and constrained between -255 and +255.
 * If >=0 the coil will REPEL with +value, if <0 the coil will ATTRACT with -value=abs(value)
 * 
 */

void turn_X_NEW(int ux, int uz) //NEW - debugging version
{
  int sumx1 = +ux +uz;
  int sumx2 = -ux +uz;

  sumx1 = constrain(sumx1,-255,+255);
  sumx2 = constrain(sumx2,-255,+255);

  Serial.print("s1: ");
  Serial.print(sumx1);
  Serial.print(" ");
  Serial.print("s2: ");
  Serial.print(sumx2);
  Serial.print(" ");

  if(sumx1>=0)
  { repel(X1_A,X1_B,ENABLE_X1,sumx1); //X1-R
  }
  else
  { sumx1 = abs(sumx1);
    attract(X1_A,X1_B,ENABLE_X1,sumx1); //X1-A
  }

  if(sumx2>=0)
  { repel(X2_A,X2_B,ENABLE_X2,sumx2); //X2-R
  }
  else
  { sumx2=abs(sumx2);
    attract(X2_A,X2_B,ENABLE_X2,sumx2); //X2-A
  }
}

// ---------------------------------------------------------------------------------------------------

void turn_X_NEW_final(int ux, int uz) //NEW - performing version
{
  int sumx1 = +ux +uz;
  int sumx2 = -ux +uz;

  sumx1 = constrain(sumx1,-255,+255);
  sumx2 = constrain(sumx2,-255,+255);

  if(sumx1>=0)
  { repel(X1_A,X1_B,ENABLE_X1,sumx1); //X1-R
  }
  else
  { sumx1 = abs(sumx1);
    attract(X1_A,X1_B,ENABLE_X1,sumx1); //X1-A
  }

  if(sumx2>=0)
  { repel(X2_A,X2_B,ENABLE_X2,sumx2); //X2-R
  }
  else
  { sumx2=abs(sumx2);
    attract(X2_A,X2_B,ENABLE_X2,sumx2); //X2-A
  }
}
