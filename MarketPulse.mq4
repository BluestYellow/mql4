#import "utils.ex4"
  // create buffer ============= ||//
  void CreateBuffer(
    int buffer,
    double &array[],
    int type,
    int style,
    int width,
    color clr,
    int arrowCode = 10
  );
  // create buffer ============= ||
  
  // store value ===================================================== ||
  void StoreValue(double &array[], int size);
  void StoreValue(int &array[], int size);
  // store value ===================================================== ||
  
  // create label ==================================================== ||
  void CreateLabel(
    int labelID,
    string text,
    int fontSize,
    string font,
    double price,
    datetime time,
    color clr
  );
  // create label ==================================================== ||
#import

#property indicator_buffers 2
#property indicator_chart_window
#property strict
#define DEFAULT_FONT "Lexend"

//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
// user variables
input int indicatorPeriod = 200;
input double inputWeightA = 6.32;
input double inputWeightB = 2.12;
input double inputTolerance = 93;
input int mbb = 1000;

// enuns
enum STATE{PUTT_STATE, CALL_STATE};

// arrays
double callSig[];
double puttSig[];

// temp buffer
double distanceArray[];
double volumeArray[];
double normilizedDistances[];

//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){

  CreateBuffer(0, callSig, DRAW_ARROW, STYLE_SOLID, 1, clrBlueViolet, 233);
  CreateBuffer(1, puttSig, DRAW_ARROW, STYLE_SOLID, 1, clrBlueViolet, 234);
  
  StoreValue(distanceArray, mbb);
  StoreValue(volumeArray, mbb);
  StoreValue(normilizedDistances, mbb);
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  int limit = ArraySize(Close);
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
  // loop to data from candles
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    double distance = GetDistance(indicatorPeriod, 1, i);
    double volume = (double)Volume[i];
    distanceArray[i] = distance;
    volumeArray[i] = volume;
  }
  
  // main loop
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    
    double dist = distanceArray[i];
    double normlizedDistance = NormalizeValue(distanceArray, dist);
    
    double vol = volumeArray[i];
    double normlizedVolume = NormalizeValue(volumeArray, vol);
    
    double weightA = inputWeightA;
    double paramA = (normlizedDistance*100) * weightA;
    
    double weightB = inputWeightB;
    double paramB = (normlizedVolume*100) * weightB;
    
    double wzkValue = (paramA + paramB) / (weightA + weightB);
    
    string distText = DoubleToStr(MathRound(wzkValue), 0);
    double atr = iATR(NULL, PERIOD_CURRENT, 14, i);
    double price = Low[i] - atr/3;
    
    CreateLabel(i, distText, 8, DEFAULT_FONT, price, Time[i], clrGray);
    
    STATE curState = GetState(indicatorPeriod, 1, i); // current state
    
    bool sigTrigger = wzkValue >= inputTolerance;
    
    bool call = curState == CALL_STATE;
    bool putt = curState == PUTT_STATE;
    bool bull = Close[i] > Open[i];
    bool bear = Close[i] < Open[i];
    
    callSig[i] = (sigTrigger && call && bear) ? Low[i]:EMPTY_VALUE;
    puttSig[i] = (sigTrigger && putt && bull) ? High[i]:EMPTY_VALUE;
  }
  
  
  return(Bars);
}

//+------------------------------------------------------------------+
//| indicators data                                                  |
//+------------------------------------------------------------------+
double MovingAverage(int period, int type, int shift){
  double ma = iMA(NULL, PERIOD_CURRENT, period, 0, type, PRICE_CLOSE, shift);
  return(ma);
}

//+------------------------------------------------------------------+
//| get distance function                                            |
//+------------------------------------------------------------------+
double GetDistance(int refPeriod, int dynPeriod, int shift){
  double referenceMA = MovingAverage(refPeriod, MODE_SMA, shift);
  double dynamicMA = MovingAverage(dynPeriod, MODE_SMA, shift);
  double distance = MathAbs(dynamicMA - referenceMA);
  return(distance);
}

//+------------------------------------------------------------------+
//| get state function                                            |
//+------------------------------------------------------------------+
STATE GetState(int refPeriod, int dynPeriod, int shift){
  double referenceMA = MovingAverage(refPeriod, MODE_SMA, shift);
  double dynamicMA = MovingAverage(dynPeriod, MODE_SMA, shift);
  
  STATE position = (dynamicMA > referenceMA) ? PUTT_STATE:CALL_STATE;
  return(position);
}

//+------------------------------------------------------------------+
//| normalization function                                           |
//+------------------------------------------------------------------+
double NormalizeValue(double &scrArray[], double value){
  double array[];
  ArrayCopy(array, scrArray);
  int size = ArraySize(array);
 
  if(size > mbb) ArrayResize(array, mbb);
 
  int maxIndex = ArrayMaximum(array);
  int minIndex = ArrayMinimum(array);
  double maxRange = array[maxIndex];
  double minRange = array[minIndex];
  double normValue = (value - minRange) / (maxRange - minRange);
  
  return(normValue);
}
