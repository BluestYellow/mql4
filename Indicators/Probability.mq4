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
  void CustomAlert(const string dir, const string msg, const int index);
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
  void CreateLabel(
    const int labelID,
    const string text,
    const int fontSize,
    const int xDist,
    const int yDist,
    const string font,
    const color clr,
    const int corner = CORNER_RIGHT_LOWER,
    const double uniqueFactor = 0.22
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
enum PROBABILITY_MODE{FAST, DEFAULT, SLOW};

// user variables
input int mbb = 300;
input int precision = 2;
input double priceAlertHi = 99.5;
input double priceAlertLo = 0.5;
input PROBABILITY_MODE probMode = DEFAULT;

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
  EventSetTimer(1);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| per-time event                                                   |
//+------------------------------------------------------------------+
static int timer;
void OnTimer(){
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  color textColor = C'255,255,255';
  if(timer <= 62){
    timer++;
    Print(timer);
    switch(timer){
      // Branco -> Azul Aqua (30 etapas)
      case(00): textColor = C'255,255,255'; break; // Branco puro
      case(01): textColor = C'248,255,255'; break;
      case(02): textColor = C'240,255,255'; break;
      case(03): textColor = C'232,255,255'; break;
      case(04): textColor = C'224,255,255'; break;
      case(05): textColor = C'216,255,255'; break;
      case(06): textColor = C'208,255,255'; break;
      case(07): textColor = C'200,255,255'; break;
      case(08): textColor = C'192,255,255'; break;
      case(09): textColor = C'184,255,255'; break;
      case(10): textColor = C'176,255,255'; break;
      case(11): textColor = C'168,255,255'; break;
      case(12): textColor = C'160,255,255'; break;
      case(13): textColor = C'152,255,255'; break;
      case(14): textColor = C'144,255,255'; break;
      case(15): textColor = C'136,255,255'; break;
      case(16): textColor = C'128,255,255'; break;
      case(17): textColor = C'120,255,255'; break;
      case(18): textColor = C'112,255,255'; break;
      case(19): textColor = C'104,255,255'; break;
      case(20): textColor = C'96,255,255'; break;
      case(21): textColor = C'88,255,255'; break;
      case(22): textColor = C'80,255,255'; break;
      case(23): textColor = C'72,255,255'; break;
      case(24): textColor = C'64,255,255'; break;
      case(25): textColor = C'56,255,255'; break;
      case(26): textColor = C'48,255,255'; break;
      case(27): textColor = C'40,255,255'; break;
      case(28): textColor = C'32,255,255'; break;
      case(29): textColor = C'24,255,255'; break;
      case(30): textColor = C'16,255,255'; break;
      case(31): textColor = C'8,255,255'; break;
      case(32): textColor = C'0,255,255'; break;    // Azul Aqua puro
    
      // Azul Aqua -> Branco (30 etapas)
      case(33): textColor = C'8,255,255'; break;
      case(34): textColor = C'16,255,255'; break;
      case(35): textColor = C'24,255,255'; break;
      case(36): textColor = C'32,255,255'; break;
      case(37): textColor = C'40,255,255'; break;
      case(38): textColor = C'48,255,255'; break;
      case(39): textColor = C'56,255,255'; break;
      case(40): textColor = C'64,255,255'; break;
      case(41): textColor = C'72,255,255'; break;
      case(42): textColor = C'80,255,255'; break;
      case(43): textColor = C'88,255,255'; break;
      case(44): textColor = C'96,255,255'; break;
      case(45): textColor = C'104,255,255'; break;
      case(46): textColor = C'112,255,255'; break;
      case(47): textColor = C'120,255,255'; break;
      case(48): textColor = C'128,255,255'; break;
      case(49): textColor = C'136,255,255'; break;
      case(50): textColor = C'144,255,255'; break;
      case(51): textColor = C'152,255,255'; break;
      case(52): textColor = C'160,255,255'; break;
      case(53): textColor = C'168,255,255'; break;
      case(54): textColor = C'176,255,255'; break;
      case(55): textColor = C'184,255,255'; break;
      case(56): textColor = C'192,255,255'; break;
      case(57): textColor = C'200,255,255'; break;
      case(58): textColor = C'208,255,255'; break;
      case(59): textColor = C'216,255,255'; break;
      case(60): textColor = C'224,255,255'; break;
      case(61): textColor = C'232,255,255'; break;
      case(62): textColor = C'240,255,255'; break;
      case(63): textColor = C'255,255,255'; break; // Branco puro
    
      default: textColor = C'255,255,255'; break;   // Branco puro como padrão
    }


  } else {
    timer = 0;
  }
  ChartSetInteger(0, CHART_COLOR_FOREGROUND, textColor);
  string text = "mais indicadores => https://t.me/BlueXInd";
  CreateLabel(21, text, 9, 5, 5, DEFAULT_FONT, textColor);
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
    const double probabilityValue = Probability(i, probMode, trend);
    if(trend == UP_TREND){
      price = High[i] + atr/2;
      clrTag = clrBull;
    } else {
      price = Low[i] - atr/4;
      clrTag = clrBear;
    }
    int fontSize = 12;
    if(precision >= 2) {fontSize = 8;}
    else if (precision >= 4) {fontSize = 7;}
    
    const string probabilityText = DoubleToStr(probabilityValue ,precision);
    CreateLabel(i, probabilityText, fontSize, DEFAULT_FONT, price, Time[i], clrTag);
    
    if(probabilityValue >= priceAlertHi) {
      CustomAlert("mercado descendo", "ATENÇÃO", i);
    } else if( probabilityValue <= priceAlertLo) {
      CustomAlert("mercado subindo", "ATENÇÃO", i);
    }
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
  
  if(currentMA > referenceMA){ trend = UP_TREND;} 
  else {trend = DN_TREND;}
  
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
double Probability(const int shift, PROBABILITY_MODE mode, CUSTOM_TREND priceTrend){
  int periodA;
  int periodB;
  int periodC;
  int periodD;
  int priceMode;
  
  switch(priceTrend){
    default:        priceMode = PRICE_CLOSE;  break;
    case(UP_TREND): priceMode = PRICE_HIGH;   break;
    case(DN_TREND): priceMode = PRICE_LOW;    break;
  }
  
  switch(mode){
    default:        periodA = 2; periodB = 3; periodC = 4;  periodD = 5;  break;
    case(FAST):     periodA = 1; periodB = 2; periodC = 3;  periodD = 4;  break;
    case(DEFAULT):  periodA = 2; periodB = 3; periodC = 4;  periodD = 5;  break;
    case(SLOW):     periodA = 4; periodB = 7; periodC = 12; periodD = 14; break;
  }
  
  const int weightA = 6;
  const int weightB = 5;
  const int weightC = 4;
  const int weightD = 3;
  const int weightA1 = 4;
  const int weightB2 = 3;
  const int weightC3 = 2;
  const int weightD4 = 1;
  
  // RSI CLUSTER
  const double paramA = rsi(periodA, priceMode, shift) * weightA;
  const double paramB = rsi(periodB, priceMode, shift) * weightB;
  const double paramC = rsi(periodC, priceMode, shift) * weightC;
  const double paramD = rsi(periodD, priceMode, shift) * weightD;
  
  // MFI CLUSTER
  const double paramA1 = mfi(periodA, shift) * weightA1;
  const double paramB2 = mfi(periodB, shift) * weightB2;
  const double paramC3 = mfi(periodC, shift) * weightC3;
  const double paramD4 = mfi(periodD, shift) * weightD4;
  
  const double probabilityValue = (
    (paramA  + paramB  + paramC  + paramD + paramA1 + paramB2 + paramC3 + paramD4)  /
    (weightA + weightB + weightC + weightD + weightA1 + weightB2 + weightC3 + weightD4)
  );
  return(probabilityValue);
}

double rsi(const int period, const int price, const int shift){
  double rsiValue = iRSI(NULL, PERIOD_CURRENT, period, price, shift);
  return(rsiValue);
}

double mfi(const int period, const int shift){
  double mfiValue = iMFI(NULL, PERIOD_CURRENT, period, shift);
  return(mfiValue);
}







