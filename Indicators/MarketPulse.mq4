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
  void CustomAlert(string dir, string msg, int index, double &buffer[]);
  void SetupLayout();
  void BackgroundIMG();
  
  void CreateLabel(
    int labelID,
    string text,
    int fontSize,
    string font,
    double price,
    datetime time,
    color clr,
    double uniqueFactor = 0.23
  );
#import

#property indicator_buffers 4
#property indicator_chart_window
#property strict
#define DEFAULT_FONT "Lexend"
#define expiration D'2025.03.10 00:00'

#property copyright "BlueX Indicators"
#property link "https://t.me/BlueXInd"
#property description "Indicator gratuito - venda proibida!"


//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
// enuns
enum STATE{PUTT_STATE, CALL_STATE};
enum OPERATION_MODE{TREND/*tendência*/, REVERSION/*reversão*/};

// user variables
input string text111 = "- indicator gratuito -"; // - indicador gratuito -
input int indicatorPeriod = 20;           // período do indicador
input double inputWeightA = 6.32;         // influência da tendência
input double inputWeightB = 2.12;         // influência do volume
input double inputTolerance = 5;          // sensibilidade do limite
input OPERATION_MODE opMode = REVERSION;  // modo de operação

// variables
int mbb = indicatorPeriod;

// arrays
double preCallSig[];
double prePuttSig[];
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
  SetupLayout();
  BackgroundIMG();
  color bullColor = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
  color bearColor = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
  
  CreateBuffer(0, preCallSig, DRAW_ARROW, STYLE_SOLID, 3, bullColor, 158);
  CreateBuffer(1, prePuttSig, DRAW_ARROW, STYLE_SOLID, 3, bearColor, 158);
  
  CreateBuffer(2, callSig, DRAW_ARROW, STYLE_SOLID, 1, bullColor, 217);
  CreateBuffer(3, puttSig, DRAW_ARROW, STYLE_SOLID, 1, bearColor, 218);
  
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
   ObjectsDeleteAll(0, -1, OBJ_BITMAP_LABEL);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  if(expiration <= Time[0]){
    Alert("indicator expired -> telegram: t.me/BlueXInd");
    return(0);
  }
  int limit = ArraySize(Close);
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
  ObjectsDeleteAll(0, -1, OBJ_BITMAP_LABEL);
  
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
    //double atr = iATR(NULL, PERIOD_CURRENT, 14, i);
    //string text = DoubleToStr(MathRound(normIndexValue), 0);
    //double price = Low[i] - atr/3;
    //color textColor = (color)ChartGetInteger(0, CHART_COLOR_GRID);
    //CreateLabel(i, text, 8, DEFAULT_FONT, price, Time[i], textColor, Open[i]);
    //---
  }
  PlotArrows(normilizedDistances);
  BackgroundIMG();
  return(Bars);
}

//+------------------------------------------------------------------+
//| mark arrow text                                                  |
//+------------------------------------------------------------------+
void MarkArrowText(string text, double price, color textColor){
  CreateLabel(34, text, 8, DEFAULT_FONT, price, Time[0], textColor, Open[0]);
}

//+------------------------------------------------------------------+
//| plot arrows                                                      |
//+------------------------------------------------------------------+
void PlotArrows(double &normArrayDist[]){
  STATE currentState = GetState(indicatorPeriod, 1, 0);
  double maxValue = GetMaxValue(normArrayDist);
  string text = DoubleToStr(MathRound(normArrayDist[0]), 0);
  double atr  = iATR(NULL, PERIOD_CURRENT, 14, 0) / 3;
  double hiP  = High[0] + atr;
  double loP  = Low[0]  - atr;
  bool noPreviousSignal = preCallSig[1] == EMPTY_VALUE && prePuttSig[1] == EMPTY_VALUE;
  bool callCondition = false;
  bool puttCondition = false;
  
  if(opMode == REVERSION) {
    callCondition = 
      (normArrayDist[0] >= (maxValue - inputTolerance)) &&
      (currentState == CALL_STATE) &&
      (Close[0] < Open[0]) &&
      noPreviousSignal;

    puttCondition = 
      (normArrayDist[0] >= (maxValue - inputTolerance)) &&
      (currentState == PUTT_STATE) &&
      (Close[0] > Open[0]) &&
      noPreviousSignal;
  } else {
    callCondition = 
      (normArrayDist[0] >= (maxValue - inputTolerance * 4)) &&
      (currentState == PUTT_STATE);
  
    puttCondition = 
      (normArrayDist[0] >= (maxValue - inputTolerance * 4)) &&
      (currentState == CALL_STATE);
  }

  preCallSig[0] = (callCondition) ? (loP):(EMPTY_VALUE);
  prePuttSig[0] = (puttCondition) ? (hiP):(EMPTY_VALUE);
  callSig[0] = (preCallSig[1] != EMPTY_VALUE) ? (loP):(EMPTY_VALUE);
  puttSig[0] = (prePuttSig[1] != EMPTY_VALUE) ? (hiP):(EMPTY_VALUE);
  CustomAlert("call", "entrada prox vela", 0, preCallSig);
  CustomAlert("put", "entrada prox vela", 0, prePuttSig);
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