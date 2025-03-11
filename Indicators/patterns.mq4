//+------------------------------------------------------------------+
//| MACRO & GLOBAL                                                   |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property strict
#property link "https://t.me/BlueXInd"
#property copyright "BlueX Indicators"
#property description "----"
#define indicator_name "BlueLines"

// user variables

// global variables
int G_cicle = 100;
int G_unitis = 10;
int G_mbb = (G_unitis * G_cicle);
int G_miliseconds = 20;
int G_limit = 0;
int G_counter = 0;

// flagd
bool F_limit = true;
bool F_loopPermision = true;
bool F_firstPass = true;
bool F_cicleState = true;
bool F_cBuffer = true;
bool F_pBuffer = true;

// arrays
double A_cicleState[];
double A_cBuffer[];
double A_pBuffer[];

//+------------------------------------------------------------------+
//| EVENT FUNCTIONS                                                  |
//+------------------------------------------------------------------+

//====================================================
// ONCE PER TIME EVENT                              ||
//====================================================
int init()
{
  // event timer settings
  EventSetMillisecondTimer(G_miliseconds);
  
  return(INIT_SUCCEEDED);
}

//=================================================================================
// ONCE EVERY TIME EVENT                                                         ||
//=================================================================================
void OnTimer()
{
  // local variables
  if(F_limit) G_limit = LimitChecker(G_mbb, F_limit);
  if(G_limit == 0) F_limit = true;
  int cicleSize = G_limit;
  int cicleCounter = 0;
  int counter = 0;
  
  // configure arrays and buffers
  ArrayConfigure(A_cicleState, G_cicle, F_cicleState);
  CreateBuffer(0, 0, clrBlack, A_cBuffer, 233, F_cBuffer);
  CreateBuffer(1, 0, clrBlack, A_pBuffer, 234, F_pBuffer);
  
  ObjectsDeleteAll(0, -1, OBJ_VLINE);
  
  // main loop
  for(int i = G_limit; i >= 1; i--)
  {
    // decrement / increment
    cicleSize--;
    counter++;
    
    // out of loop control logic
    if(counter == G_unitis)
    {
      double currentCandle = 0;
      counter = 0;
      cicleCounter++;
      if(F_firstPass) G_counter++;
            
      for(int j = cicleSize; j <= (cicleSize + G_unitis); j++)
      {
        //if(j == 0) continue;
        if(F_firstPass)
        {
          currentCandle = currentCandle + GetCandleState(j);
          if(j == (cicleSize + G_unitis)) A_cicleState[cicleCounter] = currentCandle;
          if(G_counter >= G_limit) F_firstPass = false;
        }
        
        if(!F_firstPass)
        {
          color clr = clrGray;
          if(A_cicleState[cicleCounter] >  00) clr = C'74,95,41';
          if(A_cicleState[cicleCounter] <  00) clr = C'122,24,14';
          if(A_cicleState[cicleCounter] >  20) clr = C'59,125,0';
          if(A_cicleState[cicleCounter] < -20) clr = C'171,6,6';
          CreateVLine(clr, cicleCounter, j);
          
          // place buffers
          bool call = 
          (
            (
              (A_cicleState[cicleCounter] >  20) && 
              (Close[j] < Open[j]) &&
              (Close[j] > Open[j+1]) 
            ) 
            ||
            (
              (A_cicleState[cicleCounter] >  20) && 
              (Close[j] > Open[j]) 
            )

          );
          bool putt = 
          (
            (
              (A_cicleState[cicleCounter] < -20) && 
              (Close[j] > Open[j]) &&
              (Close[j+1] < Open[j+1]) 
            )
            ||
            (
              (A_cicleState[cicleCounter] < -20) && 
              (Close[j] < Open[j]) 
            )
          );
          double atr = iATR(NULL, PERIOD_CURRENT, 14, j) / 3;
          A_cBuffer[j] = (call) ? Low[j] - atr:EMPTY_VALUE;
          A_pBuffer[j] = (putt) ? High[j] + atr:EMPTY_VALUE;
        }
      }
    }
    
    // loop control logic
    if(i == 0)
    {
    } 
  }
}


//====================================================
// ONCE PER TICK EVENT                              ||
//====================================================
int start()
{
  return(Bars);
}

//====================================================
// ONCE PER EXIT EVENT                              ||
//====================================================
void deinit()
{
  // delete timer event
  EventKillTimer();
}

//+------------------------------------------------------------------+
//| CUSTOM FUNCTION                                                  |
//+------------------------------------------------------------------+

//======================================================
// CREATE VLINE                                       ||
//======================================================
void CreateVLine(color clr, int cicle, int shift)
{
  string name = "VLINE: " + IntegerToString(shift);
  int zoom = (int)ChartGetInteger(0, CHART_SCALE);
  int width = 1;
  switch(zoom)
  {
    case(5): width = 32; break;
    case(4): width = 16; break;
    case(3): width = 08; break;
    case(2): width = 04; break;
    case(1): width = 02; break;
    case(0): width = 01; break;
  }
  
  bool object = ObjectCreate(0, name, OBJ_VLINE, 0, 0, 0);
  if(object)
  {
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_BACK, true);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
    ObjectSet(name, OBJPROP_WIDTH, width);
  }
  else
  {
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
    ObjectSet(name, OBJPROP_WIDTH, width);
  }
}


//======================================================
// CHECK CANDLE STATE                                 ||
//======================================================
double GetCandleState(int shift)
{
  double pip = MathAbs(Close[shift] - Open[shift]) / Point();
  if(Close[shift] > Open[shift]) return(pip * 1);
  else if(Close[shift] < Open[shift]) return(pip * (-1));
  else return(0);
}

//======================================================
// CHECK LIMITS AND PREVENT AOR                       ||
//======================================================
int LimitChecker(int value, bool &lock) 
{
  int barsLimit = MathMin(value, IndicatorCounted());
  lock = false;
  Print("Limit set: ", barsLimit);
  return(barsLimit);
}

//===============================================================
// configure array                                             ||
//===============================================================
void ArrayConfigure(double &array[], int size, bool &lock)
{
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayResize(array, size+2);
  lock = false;
}

//==================================================================================
// configure buffers                                                              ||
//==================================================================================
void CreateBuffer(int arrIndex, int width, color clr,double &array[], int code, bool &lock) 
{
  // configure array to buffer
  string name = StringFormat(" %d || %s", arrIndex, indicator_name);
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayInitialize(array, EMPTY_VALUE);
  SetIndexBuffer(arrIndex, array);
  SetIndexStyle(arrIndex, DRAW_ARROW, STYLE_SOLID, width, clr);
  SetIndexEmptyValue(arrIndex, EMPTY_VALUE);
  SetIndexArrow(arrIndex, code);
  SetIndexLabel(arrIndex, name);
  lock = false;
}


