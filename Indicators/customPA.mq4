// desfazer logica e implementar logica de
// ta subundo, comprar no rompimento do topo
// ta descendo, vender no rompimento do fundo


//+------------------------------------------------------------------+
//| MACRO                                                            |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_chart_window
#property strict
#property copyright "BlueX Indicators"
#property link "https://t.me/BlueXInd"
#property version "1.0"
#define expiration D'2025.06.01'
#define indicator_name "CPA"

// enum
enum candle{bull, bear, doji};

// user data
input int mbb = 300;
input bool showArrows = true;

// global variables
int milisecond = 100;
int startLegIndex = 0;
int innerLegIndex = 0;
bool bullLegFlag = true;
bool bearLegFlag = true;
bool isStart = false;
double startLegPrice = 0;
bool lock = false;

// arrays
double candleTypeArr[];
double upArrow[];
double dnArrow[];

//+------------------------------------------------------------------+
//| EVENTS                                                           |
//+------------------------------------------------------------------+
int init() {

  // clean objects
  ObjectsDeleteAll(0, -1, OBJ_TREND);

  // timer config
  EventSetMillisecondTimer(milisecond);
  
  return(INIT_SUCCEEDED);

}

int start() {

  return(Bars);

}

void deinit() {

  ObjectsDeleteAll(0, -1, OBJ_TREND);
  
}


void OnTimer() {

  // local variables
  if(Time[0] > expiration) lock = true;
  int limit = LimitChecker(mbb);
  color bullColor = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
  color bearColor = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
  
  // array & buffers config
  ArrayConfigure(candleTypeArr, limit);
  CreateBuffer(0, 1, bullColor, upArrow, 233);
  CreateBuffer(1, 1, bearColor, dnArrow, 234);
  
  // main loop
  for(int i = limit; i >= 0; i--) {
    if(lock) continue;
    // loop variables
    candle candleType = GetCandleType(i);
    candleTypeArr[i] = candleType;
    
    // bull and bear candles type
    bool isBull0 = (candleTypeArr[i+0] == bull);
    bool isBear0 = (candleTypeArr[i+0] == bear);
    bool isBull1 = (candleTypeArr[i+1] == bull);
    bool isBear1 = (candleTypeArr[i+1] == bear);
    
    // trigger settings
    bool bullTrigger = (isBull0 && isBull1);
    bool bearTrigger = (isBear0 && isBear1);
    
    // starting leg
    if(bullTrigger && bullLegFlag) {
      startLegIndex = i+1;
      startLegPrice = Low[i+1];
      bullLegFlag = false;
      bearLegFlag = true;
    } else if (bearTrigger && bearLegFlag) {
      startLegIndex = i+1;
      startLegPrice = High[i+1];
      bearLegFlag = false;
      bullLegFlag = true;
    }
    
    // plot reverion value
    double atr = iATR(NULL, PERIOD_CURRENT, 14, i) / 3;
    double sar = iSAR(NULL, PERIOD_CURRENT, 0.08, 0.8, i);
    double lo = Low[i] - atr;
    double hi = High[i] + atr;
    bool closeUnder = (Close[i] < startLegPrice);
    bool closeAbove = (Close[i] > startLegPrice);
    bool openUnder = (Open[i] < startLegPrice);
    bool openAbove = (Open[i] > startLegPrice);
    bool crossUp = (openUnder && closeAbove);
    bool crossDn = (openAbove && closeUnder);
    bool noSignal = ((upArrow[i+1] == EMPTY_VALUE) && (dnArrow[i+1] == EMPTY_VALUE));
    bool isRising = (Close[i] > sar);
    bool isFallng = (Close[i] < sar);
    bool distance = MathAbs(Close[i] - startLegPrice) > atr;
    if(showArrows) upArrow[i] = (!bullLegFlag && crossUp && noSignal && isRising) ? lo:EMPTY_VALUE;
    if(showArrows) dnArrow[i] = (!bearLegFlag && crossDn && noSignal && isFallng) ? hi:EMPTY_VALUE;
    
    // bull inner leg process
    if(!bullLegFlag && isBear0) {
      innerLegIndex = i;
      
      // draw line
      if(innerLegIndex < startLegIndex) {
        CreateTrendlines(
          clrWhite, 
          1, 
          startLegPrice, 
          startLegIndex, 
          startLegPrice,
          innerLegIndex,
          true,
          IntegerToString(i)
        );
      }
      startLegPrice = High[i];
      startLegIndex = i;
      
    // bear inner leg process  
    } else if (!bearLegFlag && isBull0) {
      innerLegIndex = i;
      
      // drawLine
      if(innerLegIndex < startLegIndex) {
        CreateTrendlines(
          clrWhite, 
          1, 
          startLegPrice, 
          startLegIndex, 
          startLegPrice,
          innerLegIndex,
          true,
          IntegerToString(i)
        );
      }
    
      startLegPrice = Low[i];
      startLegIndex = i;
    }
  }
}

//+------------------------------------------------------------------+
//| CUSTOM FUNCTION                                                  |
//+------------------------------------------------------------------+
candle GetCandleType(int shift){
  
  candle type = doji;
  bool isBull = (Close[shift] > Open[shift]);
  bool isBear = (Close[shift] < Open[shift]);
  if(isBull) type = bull;
  if(isBear) type = bear;
  return(type);

}


int LimitChecker(int value) {
  int barsLimit = MathMin(value, IndicatorCounted());
  return(barsLimit - 1);
}


void ArrayConfigure(double &array[], int size) {
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayResize(array, size+2);
}


void CreateBuffer(int arrIndex, int width, color clr,double &array[], int code) {
  // configure array to buffer
  string name = StringFormat(" %d || %s", arrIndex, indicator_name);
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayInitialize(array, EMPTY_VALUE);
  SetIndexBuffer(arrIndex, array);
  SetIndexStyle(arrIndex, DRAW_ARROW, STYLE_SOLID, width, clr);
  SetIndexEmptyValue(arrIndex, EMPTY_VALUE);
  SetIndexArrow(arrIndex, code);
  SetIndexLabel(arrIndex, name);
}


void CreateTrendlines(
  color objColor,
  int width,
  double price1,
  int time1,
  double price2,
  int time2,
  bool uniqueObj = false,
  string objName = "obj"
) {
  double randObjName = (MathRand() / Close[0]);
  string name = (uniqueObj) ? objName:DoubleToStr(randObjName, _Digits);
    
  bool object = ObjectCreate(0, name, OBJ_TREND, 0, 0, 0);
  if(object) {
    ObjectSet(name, OBJPROP_PRICE1, price1);
    ObjectSet(name, OBJPROP_PRICE2, price2);
    ObjectSet(name, OBJPROP_TIME1, Time[time1]);
    ObjectSet(name, OBJPROP_TIME2, Time[time2]);
    ObjectSet(name, OBJPROP_COLOR, objColor);
    ObjectSet(name, OBJPROP_WIDTH, width);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_HIDDEN, true);
    ObjectSet(name, OBJPROP_BACK, false);
    ObjectSet(name, OBJPROP_RAY, false);
  } else {
    ObjectSet(name, OBJPROP_PRICE1, price1);
    ObjectSet(name, OBJPROP_PRICE2, price2);
    ObjectSet(name, OBJPROP_TIME1, Time[time1]);
    ObjectSet(name, OBJPROP_TIME2, Time[time2]);
    ObjectSet(name, OBJPROP_COLOR, objColor);
    ObjectSet(name, OBJPROP_WIDTH, width);
  }
}