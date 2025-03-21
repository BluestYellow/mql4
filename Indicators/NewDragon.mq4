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
#define DEFAULT_FONT "Lexend"
#define expiration D'2025.03.10 00:00'
#property copyright "BlueX Indicators"
#property link "https://t.me/BlueXInd"
#property description "Indicator gratuito - venda proibida!"


// enuns
enum DRAGON_MODE{UP_MODE, DN_MODE};
enum DRAGON_SENSE{WEAKER/*fraca*/, NORMAL/*normal*/, STRONG/*forte*/};

// user variables
input DRAGON_SENSE sensebility = NORMAL; // sensibilidade a tendência
input int mbb = 300; // velas analisadas

// arrays
double upDragonLine[];
double dnDragonLine[];

//+------------------------------------------------------------------+
//| initialize event                                                 |
//+------------------------------------------------------------------+
int init(){
  if(expiration <= Time[0]) {
    Alert("indicator expired -> telegram: t.me/BlueXInd");
    return(0);
  }
  const color bullColor = (color) ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
  const color bearColor = (color) ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
  SetupLayout();
  BackgroundIMG();
  CreateBuffer(0, upDragonLine, DRAW_ARROW, STYLE_SOLID, 3, bullColor, 158);
  CreateBuffer(1, dnDragonLine, DRAW_ARROW, STYLE_SOLID, 3, bearColor, 158);
  
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
  
  const int limit = ArraySize(Close);
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    const DRAGON_MODE trend = GetCustomTrend(sensebility, i);
    const double dragon = CustomMovingAverage(trend, sensebility, i);
    upDragonLine[i] = (trend == UP_MODE) ? (dragon):(EMPTY_VALUE);
    dnDragonLine[i] = (trend == DN_MODE) ? (dragon):(EMPTY_VALUE);
  }
  
  return(Bars);
}

//+------------------------------------------------------------------+
//| get custom trend                                                 |
//+------------------------------------------------------------------+
DRAGON_MODE GetCustomTrend(const DRAGON_SENSE sense, const int shift){
  int period;
  DRAGON_MODE trend;
 
  switch(sense) {
    case WEAKER: period = 50; break; 
    case NORMAL: period = 30; break;
    case STRONG: period = 20; break;
    default: period = 1; break;
  } 
  
  const double referenceMA = iMA(NULL, PERIOD_CURRENT, period, 0, MODE_LWMA, PRICE_WEIGHTED, shift);
  const double currentMA = iMA(NULL, PERIOD_CURRENT, 1, 0, MODE_LWMA, PRICE_WEIGHTED, shift);
  
  if(currentMA > referenceMA){
    trend = UP_MODE;
  } else {
    trend = DN_MODE;
  }
  
  return(trend);
}

//+------------------------------------------------------------------+
//| create custom moving average                                     |
//+------------------------------------------------------------------+
double CustomMovingAverage(const DRAGON_MODE mode, const DRAGON_SENSE sense, const int shift){
  int period;
  double pointMA;
  
  switch(sense) {
    case WEAKER: period = 50; break; 
    case NORMAL: period = 30; break;
    case STRONG: period = 20; break;
    default: period = 1; break;
  }
  
  const double hiMA = iMA(NULL, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_HIGH, shift);
  const double loMA = iMA(NULL, PERIOD_CURRENT, period, 0, MODE_EMA, PRICE_LOW, shift);
  
  if(mode == UP_MODE){
    pointMA = hiMA;
  } else {
    pointMA = loMA;
  }
  
  return(pointMA);
}