/*
  C1_A,C1_B,C2_A,C2_B are the 4 terminals of the 2 coils C1 and C2
  ENABLE_C1 and -2 are the pwm inputs for C1 and -2 coils
  uc is respectively ux or uy
*/

/*  
  OLD VERSION

  set the coils ALWAYS in a dual behaviour (one R and the other A) prioritizing uc value and adding after uz.
  when uz is high and uc is low this can leads to saturate one of the two pwm vals to 0

  example: uc=5, uz=50 => set C1-R with +5+50 = +55 => (R with pwm = 55)
                              C2-A with +5-50 = -45 clamped to 0 because of saturation => (A with pwm = 0)

  R stands for REPELS, A stands for ATTRACTS. First, based on uc>=0 or <0 we chose if the C1-coil will R-epel or A-ttract,
  C2-coil will do the opposite. The table down here explain the val based on the sign of uc and on the behaviour(R/A) of the coil.
  Finally value is constrained between 0 and 255.

  uc>=0: C1-R = +uc+uz # C2-A = +uc-uz
  uc<0:  C1-A = -uc-uz # C2-R = -uc+uz
*/

void turn_C_OLD(byte C1_A, byte C1_B, byte ENABLE_C1, byte C2_A, byte C2_B, byte ENABLE_C2, int uc, int uz)
{
  int val = 0;

  if(uc>=0) // C1-R = +uc+uz # C2-A = +uc-uz
  {
    digitalWrite(C1_A, LOW); // C1-R
    digitalWrite(C1_B, HIGH);
    val = +uc +uz;
    val = constrain(val, 0, 255); //bindings
    analogWrite(ENABLE_C1, val);

    digitalWrite(C2_A, HIGH); // C2-A
    digitalWrite(C2_B, LOW);
    val = +uc -uz;
    val = constrain(val, 0, 255);
    analogWrite(ENABLE_C2, val);
  }

  else // (uc<0) C1-A = -uc-uz # C2-R = -uc+uz
  {
    digitalWrite(C1_A, HIGH); // C1-A
    digitalWrite(C1_B, LOW);
    val = -uc -uz;
    val = constrain(val, 0, 255);
    analogWrite(ENABLE_C1, val);

    digitalWrite(C2_A, LOW); // C2-R
    digitalWrite(C2_B, HIGH);
    val = -uc +uz;
    val = constrain(val, 0, 255);
    analogWrite(ENABLE_C2, val);
  }
}

/*
  NEW VERSION

  calcs before uc+uz for C1 and -uc+uz for C2 (dual action for c-axis but same for z-axis) and regardings to >=0 or <0 sets
  the coils. This means that in some cases both coils can A-ttract or R-epel.

  example: uc=5, uz=50 => c1_val = 5+50 = 55 (R with pwm = 55)
                          c2_val = -5+50 = +45 (R with pwm = 45)

  val is first calculated for both of the 2 coils and constrained between -255 and +255.
  If >=0 the coil will REPEL with +val, if <0 the coil will ATTRACT with -val=abs(val)
*/

void turn_C_NEW(byte C1_A, byte C1_B, byte ENABLE_C1, byte C2_A, byte C2_B, byte ENABLE_C2, int uc, int uz)
{
  int sumc1 = +uc +uz;
  int sumc2 = -uc +uz;

  sumc1 = constrain(sumc1,-255,+255);
  sumc2 = constrain(sumc2,-255,+255);

  if(sumc1>=0)
  {
    //repels
    digitalWrite(C1_A, LOW);  //LH = repels
    digitalWrite(C1_B, HIGH);
  }
  else
  {
    //attracts
    digitalWrite(C1_A, HIGH); //HL = attracts
    digitalWrite(C1_B, LOW);
    sumc1 = abs(sumc1);       //pwm output is always a positive value
  }
  analogWrite(ENABLE_C1, sumc1);

  if(sumc2>=0)
  {
    //attracts
    digitalWrite(C2_A, LOW);  //LH = repels
    digitalWrite(C2_B, HIGH);
  }
  else
  {
    digitalWrite(C2_A, HIGH); //HL = attracts
    digitalWrite(C2_B, LOW);
    sumc2=abs(sumc2);
  }
  analogWrite(ENABLE_C2, sumc2);
}