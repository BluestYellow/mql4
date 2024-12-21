#import "utils.ex4"
  // create buffer ============= ||
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
#import

#property indicator_buffers 1
#property indicator_separate_window
#property strict

//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
// variables
const int mbb = 100;

// arrays
double lineTest[];
double distanceArray[];
double volumeArray[];

//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){
  CreateBuffer(0, lineTest, DRAW_LINE, STYLE_SOLID, 3, clrBlueViolet);
  StoreValue(distanceArray, mbb);
  StoreValue(volumeArray, mbb);
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  int limit = ArraySize(Close);
  
  // loop to data from candles
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    double distance = GetDistance(200, 1, i);
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
    
    double weightA = 6.32;
    double paramA = (normlizedDistance*100) * weightA;
    
    double weightB = 2.12;
    double paramB = (normlizedVolume*100) * weightB;
    
    double wzkValue = (paramA + paramB) / (weightA + weightB);
    
    lineTest[i] = wzkValue;
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