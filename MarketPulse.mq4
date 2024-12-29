#import "utils.ex4"
  void CreateBuffer(
    int buffer,
    double &array[],
    int type,
    int style,
    int width,
    color clr,
    int arrowCode = 10
  );
  
  void StoreValue(double &array[], int size);
  void StoreValue(int &array[], int size);
  void CustomAlert(const string &dir);
  
  void CreateLabel(
    int labelID,
    string text,
    int fontSize,
    string font,
    double price,
    datetime time,
    color clr
  );
#import

#property indicator_buffers 2
#property indicator_chart_window
#property strict
#define DEFAULT_FONT "Lexend"

//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
// user variables
input int indicatorPeriod = 20;
input double inputWeightA = 6.32;
input double inputWeightB = 2.12;
input double inputTolerance = 5;
input int mbb = 78;

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
//| delete event                                                     |
//+------------------------------------------------------------------+
void deinit(){
   ObjectsDeleteAll(0, -1, OBJ_TEXT);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  int limit = ArraySize(Close);
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
  
  // loop to data from candles
  for(int a = 0; a <= limit; a++){
    if(a >= mbb) continue;
    double distance = GetDistance(indicatorPeriod, 1, a);
    double volume = (double)Volume[a];
    distanceArray[a] = distance;
    volumeArray[a] = volume;
  }
  
  // get norm value loop
  for(int b = 0; b <= limit; b++){
    if(b >= mbb) continue;
    //--- calculate distance value
    int normBaseValue = 100;
    double currentDistanceValue = distanceArray[b];
    double currentVolumeValue = volumeArray[b];
    double normDistance = NormalizeValue(distanceArray, currentDistanceValue);
    double normVolume = NormalizeValue(volumeArray, currentVolumeValue);
    double normDistancePondered = (normDistance*normBaseValue) * inputWeightA;
    double normVolumePondered = (normVolume*normBaseValue) * inputWeightB;
    normilizedDistances[b] = (
      (normDistancePondered + normVolumePondered) / 
      (inputWeightA + inputWeightB)
    );
    //---
  }
  
  // main loop
  double maxValue = GetMaxValue(normilizedDistances);
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    double normIndexValue = normilizedDistances[i];
    
    //--- plot texts on chart
    double atr = iATR(NULL, PERIOD_CURRENT, 14, i);
    string text = DoubleToStr(MathRound(normIndexValue), 0);
    double price = Low[i] - atr/3;
    CreateLabel(i, text, 8, DEFAULT_FONT, price, Time[i], clrGray);
    //---
    
    //--- plot arrows
    STATE curState = GetState(indicatorPeriod, 1, i);
    bool sigTrigger = normIndexValue >= maxValue - inputTolerance;
    bool call = curState == CALL_STATE;
    bool putt = curState == PUTT_STATE;
    bool bull = Close[i] > Open[i];
    bool bear = Close[i] < Open[i];
    callSig[i] = (sigTrigger && call && bear) ? Low[i]:EMPTY_VALUE;
    puttSig[i] = (sigTrigger && putt && bull) ? High[i]:EMPTY_VALUE;
    //---
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

//+------------------------------------------------------------------+
//| get max value function                                           |
//+------------------------------------------------------------------+
double GetMaxValue(double &scrArray[]){
  double array[];
  ArrayCopy(array, scrArray);
  int size = ArraySize(array);
  if(size > mbb) ArrayResize(array, mbb);
  int maxIndex = ArrayMaximum(array);
  double maxRange = array[maxIndex];
  return(maxRange);
}