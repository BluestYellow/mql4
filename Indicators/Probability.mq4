//+------------------------------------------------------------------+
//| import section                                                   |
//+------------------------------------------------------------------+
#import "utils.ex4"
  void CreateBuffer(
    const int buffer,
    double &array[],
    const int type,
    const int style,
    const int width,
    const color clr,
    const int arrowCode = 10
  );
  
  void StoreValue(double &array[], const int size);
  void StoreValue(int &array[], const int size);
  void CustomAlert(const string dir, const string msg, const int index, double &buffer[]);
  void SetupLayout();
  void BackgroundIMG();
  
  void CreateLabel(
    const int labelID,
    const string text,
    const int fontSize,
    const string font,
    const double price,
    const datetime time,
    const color clr,
    const double uniqueFactor = 0.23
  );
#import 

//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_chart_window
#property strict
#property copyright "BlueX Indicators"
#property link "https://t.me/BlueXInd"
#property description "Indicator gratuito - venda proibida!"
#define DEFAULT_FONT "Lexend"
#define expiration D'2025.03.10 00:00'

// enum
enum CUSTOM_TREND{UP_TREND, DN_TREND};

// user variables
input int mbb = 300;

//+------------------------------------------------------------------+
//| initialize event                                                 |
//+------------------------------------------------------------------+
int init(){
  if(expiration <= Time[0]) {
    Alert("indicator expired -> telegram: t.me/BlueXInd");
    return(0);
  }
  SetupLayout();
  BackgroundIMG();

  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  if(expiration <= Time[0]){
    Alert("indicator expired -> telegram: t.me/BlueXInd");
    return(0);
  }
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
  
  const int limit = ArraySize(Close);
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    double price;
    color clrTag;
    const color clrBull = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
    const color clrBear = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
    const double atr = iATR(NULL, PERIOD_CURRENT, 14, i);
    const CUSTOM_TREND trend = CustomTrend(i);
    if(trend == UP_TREND){
      price = High[i] + atr/2;
      clrTag = clrBull;
    } else {
      price = Low[i] - atr/4;
      clrTag = clrBear;
    }
    
    const string probabilityText = DoubleToStr(MathRound(Probability(i)),0);
    CreateLabel(i, probabilityText, 7, DEFAULT_FONT, price, Time[i], clrTag);
  }
  
  return(Bars);
}

//+------------------------------------------------------------------+
//| delete event                                                     |
//+------------------------------------------------------------------+
void deinit(){
   ObjectsDeleteAll(0, -1, OBJ_TEXT);
   ObjectsDeleteAll(0, -1, OBJ_BITMAP_LABEL);
}

//+------------------------------------------------------------------+
//| custom trend                                                     |
//+------------------------------------------------------------------+
CUSTOM_TREND CustomTrend(const int shift){
  const double currentMA = ma(1, shift);
  const double referenceMA = ma(3, shift);
  CUSTOM_TREND trend;
  
  if(currentMA > referenceMA){
    trend = UP_TREND;
  } else {
    trend = DN_TREND;
  }
  
  return(trend);
}

//+------------------------------------------------------------------+
//| ma                                                                |
//+------------------------------------------------------------------+
double ma(const int period, const int shift){
  const double maValue = (
    iMA(NULL, PERIOD_CURRENT, period, 0, MODE_SMA, PRICE_CLOSE, shift)
  );
  
  return(maValue);
}

//+------------------------------------------------------------------+
//| probability                                                      |
//+------------------------------------------------------------------+
double Probability(const int shift){
  const int weightA = 5;
  const int weightB = 4;
  const int weightC = 3;
  const int weightD = 2;
  const double paramA = rsi(2, PRICE_CLOSE, shift) * weightA;
  const double paramB = rsi(3, PRICE_CLOSE, shift) * weightB;
  const double paramC = rsi(4, PRICE_CLOSE, shift) * weightC;
  const double paramD = rsi(5, PRICE_CLOSE, shift) * weightD;
  const double probabilityValue = (
    (paramA  + paramB  + paramC  + paramD)  /
    (weightA + weightB + weightC + weightD)
  );
  return(probabilityValue);
}

double rsi(const int period, const int price, const int shift){
  double rsiValue = iRSI(NULL, PERIOD_CURRENT, period, price, shift);
  return(rsiValue);
}








