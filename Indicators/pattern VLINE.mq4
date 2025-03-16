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
input int U_candlePerCicles = 20;
input int U_numberOfCicles = 100;



// global variables
int G_arrID = 0;
int G_limit = 0;
int G_cicleCounter = 0;
int G_miliseconds = 20;
int G_mbb = (U_candlePerCicles * U_numberOfCicles);
color G_bullClr = clrBlack;
color G_bearClr = clrBlack;
color G_foreground = clrBlack;


// flagd
bool F_limit = true;
bool F_firstLoop = true;
bool F_candleState = true;
bool F_nuclearCandleState = true;
bool F_startOn = false;
bool F_call = true;
bool F_putt = true;

// arrays
double A_candleState[];
double A_nuclearCandleState[];
double B_call[];
double B_putt[];

//+------------------------------------------------------------------+
//| EVENT FUNCTIONS                                                  |
//+------------------------------------------------------------------+

//====================================================
// ONCE PER TIME EVENT                              ||
//====================================================
int init()
{
  // clean objects
  ObjectsDeleteAll(0, -1, OBJ_VLINE);
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
  
  // get chart colors
  G_bullClr = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
  G_bearClr = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
  G_foreground = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
  ChartSetInteger(0, CHART_COLOR_CHART_LINE, G_foreground);
  
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
  if(F_limit) G_limit = LimitChecker(G_mbb, F_limit) + 1;
  if(G_limit <= 1) F_limit = true;
  
  
  // configure arrays and buffers 
  ArrayConfigure(G_arrID, A_candleState, U_numberOfCicles, F_candleState, F_limit);
  ArrayConfigure(G_arrID, A_nuclearCandleState, G_limit, F_nuclearCandleState, F_limit);
  CreateBuffer(0, 1, G_foreground, 233, B_call, F_call);
  CreateBuffer(1, 1, G_foreground, 234, B_putt, F_putt);
  
  int inner_cicleCounter = 0;
  
  // main loop
  for(int i = G_limit; i >= 1; i--)
  { 
    if(G_cicleCounter == U_numberOfCicles) G_cicleCounter = 0;

    // selector mechanism
    int cicleDiv = (G_limit - (G_cicleCounter * U_candlePerCicles));
    
    if(i == cicleDiv)
    {
      //CreateText(i, (double)i, Black, (High[i] + atr), 1.11);
      int limit = i - (U_candlePerCicles) + 1;
      double candleState = 0;
      
      for(int j = i; j >= limit; j--) 
      {
        candleState = candleState + GetCandleState(j);
        color clr = clrWhite;
        
        int nuclearCandleState = -1;
        if(A_candleState[G_cicleCounter] > 0) 
        {
          clr = G_bullClr;
          nuclearCandleState = 0;
        }
        if(A_candleState[G_cicleCounter] < 0)
        {
          clr = G_bearClr;
          nuclearCandleState = 1;
        }
        
        CreateVLine(clr, j, 0.2);
        A_nuclearCandleState[j] = (double)nuclearCandleState;
      }
      A_candleState[G_cicleCounter] = candleState;
      
      // end of conditional block
      G_cicleCounter++;
    }
  }
  F_startOn = true;
}

//====================================================
// ONCE PER TICK EVENT                              ||
//====================================================
int start()
{ 
  if(F_startOn)
  {
    for(int i = G_limit; i >= 1; i--)
    {
      double candleState = A_nuclearCandleState[i];
      double atr = iATR(NULL, PERIOD_CURRENT, 14, i)/3;
      
      if(candleState == 0)
      {
        bool entry = 
        (
          Close[i+2] < Open[i+2] &&
          Close[i+1] < Open[i+1] &&
          Close[i+0] < Open[i+0] 
        );
        
        B_call[i] = (entry) ? Low[i] - atr:EMPTY_VALUE;
      }
      
      if(candleState == 1)
      {
        bool entry = 
        (
          Close[i+2] > Open[i+2] &&
          Close[i+1] > Open[i+1] &&
          Close[i+0] > Open[i+0] 
        );
        
        B_putt[i] = (entry) ? High[i] + atr:EMPTY_VALUE;
      }
      
    }
  }
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
// CREATE TEXT                                        ||
//======================================================
void CreateText(int shift, double db, color clr, double price, double value)
{
  string name = "TEXT: " + IntegerToString(shift) + DoubleToStr(value, 3);
  bool object = ObjectCreate(0, name, OBJ_TEXT, 0, 0, 0);
  string text = DoubleToStr(db, 0);
  
  if(object)
  {
    ObjectSetText(name, text, 11, "Lexend", clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
  }
  else
  {
    ObjectSetText(name, text, 11, "Lexend", clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
  }
}

//======================================================
// CREATE VLINE                                       ||
//======================================================
void CreateVLine(color clr, int shift, double value)
{
  string name = "VLINE: " + IntegerToString(shift) + " | " + DoubleToStr(value,3);
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
// GET CANDLE STATE                                   ||
//======================================================
double GetCandleState(int shift)
{
  double pip = MathAbs(Open[shift] - Close[shift]) / Point();
  double volume = (double)Volume[shift];
  double atr = iATR(NULL, PERIOD_CURRENT, 14, shift);
  double var0 = ((pip * volume) / atr);
  if      (Close[shift] > Open[shift]) return(var0 *  1);
  else if (Close[shift] < Open[shift]) return(var0 * -1);
  else                                 return(var0 *  0);
}

//======================================================
// CHECK LIMITS AND PREVENT AOR                       ||
//======================================================
int LimitChecker(int value, bool &lock) 
{
  int barsLimit = MathMin(value, IndicatorCounted());
  lock = false;
  Print("Limit set: ", barsLimit);
  return(barsLimit - 1);
}

//===============================================================
// configure array                                             ||
//===============================================================
void ArrayConfigure(int &id, double &array[], int size, bool &lock, bool limitFlag=false)
{
  if(!limitFlag && lock)
  {
    id++;
    if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
    ArrayResize(array, size+2);
    string msg = StringFormat("Array %d Configured!", id);
    Print(msg);
    lock = false;
  }
}

//==================================================================================
// configure buffers                                                              ||
//==================================================================================
void CreateBuffer(int arrIndex, int width, color clr, int code, double &array[], bool &lock) 
{
  // configure array to buffer
  if(lock)
  {
    string name = StringFormat(" %d || %s", arrIndex, indicator_name);
    if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
    ArrayInitialize(array, EMPTY_VALUE);
    SetIndexBuffer(arrIndex, array);
    SetIndexStyle(arrIndex, DRAW_ARROW, STYLE_SOLID, width, clr);
    SetIndexEmptyValue(arrIndex, EMPTY_VALUE);
    SetIndexLabel(arrIndex, name);
    SetIndexArrow(arrIndex, code);
    Print("Buffer " + name + " Configured!");
  }
  lock = false;
}