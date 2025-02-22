//+------------------------------------------------------------------+
//| macro                                                            |
//+------------------------------------------------------------------+
#property copyright "BlueX Indicators"
#property link "google.com"
#property version "1.2"
#property indicator_buffers 2
#property indicator_chart_window
#property strict
#define expiration D'2026.01.10 00:00'

// enums
enum checker{positive, negative, neutral};
enum testMode{tester, live};

// user inputs
double  precision = 0.70; // filtro de SnR
int     bigCicles = 120;  // contador para resetar as analises


// global variables
testMode  testM         = live;
double    mbb           = 320;
int       miliseconds   = 20;
int       bigIteration  = 0;
bool      startAnalysis = true;
bool      analysisDone  = true;
double    granulation   = 20000;
double    iteration     = 1;
double    empty         = EMPTY_VALUE;

// colors
color backGround = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
color foreGround = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
color bullColors = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
color bearColors = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
color dojiColors = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);

// arrays
double levelArr[];
double srPrices[];
double callArrow[];
double puttArrow[];

//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  ObjectsDeleteAll(0, -1, OBJ_HLINE);
  ObjectsDeleteAll(0, -1, OBJ_VLINE);
  CustomAlert(startAnalysis, 0);
  ConfigureArray(levelArr, (int)granulation);
  CreateBuffer(0, callArrow, DRAW_ARROW, 0, 2, bullColors, 233);
  CreateBuffer(1, puttArrow, DRAW_ARROW, 0, 2, bearColors, 234);
  EventSetMillisecondTimer(miliseconds);
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| deinit event                                                     |
//+------------------------------------------------------------------+
void deinit(){
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  ObjectsDeleteAll(0, -1, OBJ_HLINE);
  ObjectsDeleteAll(0, -1, OBJ_VLINE);
}

//+------------------------------------------------------------------+
//| per-milisecond event                                             |
//+------------------------------------------------------------------+
void OnTimer(){
  if(testM == live){
  // variables
    double positiveCounter = 0;
    double negativeCounter = 0;
    double max;
    double min;
    double dis;
    
    // get levels -> pass to level array
    GetPriceLevels(levelArr, granulation, max, min, dis, mbb);
    
    int limit = MathMin((int)mbb, Bars);
    
    // main loop
    for(int i = limit; i >= 1; i--){
      if(i >= mbb) continue;
      // test levels
      double level = levelArr[(int)iteration];
      checker check = LevelChecker(level, i);
      positiveCounter = (check == positive) ? positiveCounter + 1:positiveCounter;
      negativeCounter = (check == negative) ? negativeCounter + 1:negativeCounter;
      
      // scanner line
      if(analysisDone){
        drawLevel(level, foreGround, 2, STYLE_SOLID, 321, 123.234, true);
      } else {
        deleteLevel(321, 123.234);
      }
      
      // once per cicle event
      if(i == 1) {
        // level accuracy
        color levelClr = C'208,163,233';
        double counterSum = positiveCounter + negativeCounter;
        double levelAccuracy = (counterSum != 0) ? positiveCounter / counterSum:0;
        
        if(levelAccuracy >= precision + 0.05) levelClr = C'196,142,228';
        if(levelAccuracy >= precision + 0.10) levelClr = C'180,113,221';
        if(levelAccuracy >= precision + 0.15) levelClr = C'138,48,198';
        
        if(levelAccuracy >= precision && analysisDone){
          drawLevel(level, levelClr, 1, STYLE_SOLID, i, levelAccuracy);
          DyConfigureArray(srPrices);
          int index = ArraySize(srPrices) - 1;
          srPrices[index] = level;
        }
        
        // create information tag
        double progress = (iteration / granulation) * 100;
        string loading = "Analise em andamento: " + DoubleToStr(progress, 2) + "%";
        string loaded = "Analise concluida";
        string text = (!analysisDone) ? loaded:loading;
        string iteMessage = "Ciclos até analisar novamente: " + IntegerToString(bigCicles - bigIteration);
        CreateLabel(1, text, 12, 5, 20, "Lexend", foreGround);
        CreateLabel(2, iteMessage, 12, 5, 0, "Lexend", foreGround);
        
        // reset controlls
        bool resetIteration = (iteration >= granulation);
        bool bigReset = (bigIteration >= bigCicles);
        
        // small reset
        if(resetIteration) {
          iteration = 1;
          bigIteration++;
          CustomAlert(analysisDone, 1);
        
        // big reset
        } else if (bigReset || ( (Low[0] < min) || (High[0] > max) )) {
          startAnalysis = true;
          analysisDone = true;
          bigIteration = 0;
          CustomAlert(startAnalysis, 0);
          ObjectsDeleteAll(0, -1, OBJ_HLINE);
          ObjectsDeleteAll(0, -1, OBJ_LABEL);
          ObjectsDeleteAll(0, -1, OBJ_VLINE);
        
        // iteration process
        } else {
          iteration++;
        }
      }
    }
  }
}

//+------------------------------------------------------------------+
//| per-tick function                                                |
//+------------------------------------------------------------------+
int start(){
  if(testM == tester){
  // variables
    double positiveCounter = 0;
    double negativeCounter = 0;
    double max;
    double min;
    double dis;
    
    // get levels -> pass to level array
    GetPriceLevels(levelArr, granulation,max, min, dis, mbb);
    
    int limit = MathMin((int)mbb, Bars);
    
    // main loop
    for(int i = limit; i >= 1; i--){
      if(i >= mbb) continue;
      
      // test levels
      double level = levelArr[(int)iteration];
      checker check = LevelChecker(level, i);
      positiveCounter = (check == positive) ? positiveCounter + 1:positiveCounter;
      negativeCounter = (check == negative) ? negativeCounter + 1:negativeCounter;
      
      
      // once per cicle event
      if(i == 1) {
        // level accuracy
        color levelClr = C'208,163,233';
        double counterSum = positiveCounter + negativeCounter;
        double levelAccuracy = (counterSum != 0) ? positiveCounter / counterSum:0;
        
        if(levelAccuracy >= precision + 0.05) levelClr = C'196,142,228';
        if(levelAccuracy >= precision + 0.10) levelClr = C'180,113,221';
        if(levelAccuracy >= precision + 0.15) levelClr = C'138,48,198';
        
        if(levelAccuracy >= precision && analysisDone){
          drawLevel(level, levelClr, 1, STYLE_SOLID, i, levelAccuracy);
          DyConfigureArray(srPrices);
          int index = ArraySize(srPrices) - 1;
          srPrices[index] = level;
        }
        
        // create information tag
        double progress = (iteration / granulation) * 100;
        string loading = "Analise em andamento: " + DoubleToStr(progress, 2) + "%";
        string loaded = "Analise concluida";
        string text = (!analysisDone) ? loaded:loading;
        string iteMessage = "Ciclos até analisar novamente: " + IntegerToString(bigCicles - bigIteration);
        CreateLabel(1, text, 12, 5, 20, "Lexend", foreGround);
        CreateLabel(2, iteMessage, 12, 5, 0, "Lexend", foreGround);
        
        // reset controlls
        bool resetIteration = (iteration >= granulation);
        bool bigReset = (bigIteration >= bigCicles);
        
        // small reset
        if(resetIteration) {
          iteration = 1;
          bigIteration++;
          CustomAlert(analysisDone, 1);
        
        // big reset
        } else if (bigReset || ( (Low[0] < min) || (High[0] > max) )) {
          startAnalysis = true;
          analysisDone = true;
          bigIteration = 0;
          CustomAlert(startAnalysis, 0);
          ObjectsDeleteAll(0, -1, OBJ_HLINE);
          ObjectsDeleteAll(0, -1, OBJ_LABEL);
          ObjectsDeleteAll(0, -1, OBJ_VLINE);
        
        // iteration process
        } else {
          iteration++;
        }
      }
    }
  }
  return(Bars);
}

//+------------------------------------------------------------------+
//| test levels score                                                |
//+------------------------------------------------------------------+
checker LevelChecker(double price, int shift){
  checker check;
  bool plusOne = (
    (
      Open[shift] < price && 
      High[shift] > price && 
      Close[shift] < price
    ) || (
      Open[shift] > price && 
      Low[shift] < price && 
      Close[shift] > price
    )
  );
  
  bool minusOne = (
    (
      Open[shift] < price && 
      High[shift] > price && 
      Close[shift] > price
    ) || (
      Open[shift] > price && 
      Low[shift] < price && 
      Close[shift] < price
    )
  );
  
  ; if      (plusOne)   {check = positive;
  } else if (minusOne)  {check = negative;
  } else                {check = neutral;
  } return              (check);
}

//+------------------------------------------------------------------+
//| delete hline object                                              |
//+------------------------------------------------------------------+
void deleteLevel(int shift,double rd = 0.22){
  string name = DoubleToStr(rd,4);
  ObjectDelete(0, name);
}

//+------------------------------------------------------------------+
//| create hline object                                              |
//+------------------------------------------------------------------+
void drawLevel(
  double price, 
  color clr, 
  int width, 
  int style,
  int shift, 
  double rd = 0.22,
  bool uniqueObj = false
){
  string name = "";
  if(uniqueObj) {
    name = DoubleToStr(rd,4);
  } else {
    name = DoubleToStr(rd,4) + " || " + IntegerToString(MathRand() * 3);
  }
  
  bool object = ObjectCreate(0, name, OBJ_HLINE, 0, 0, 0);
  
  if(object){
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_BACK, true);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_WIDTH, width);
    ObjectSet(name, OBJPROP_STYLE, style);
  } else {
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_WIDTH, width);
    ObjectSet(name, OBJPROP_STYLE, style);
  }
}

//+------------------------------------------------------------------+
//| create vline object                                              |
//+------------------------------------------------------------------+
void drawLevel(
  color clr, 
  int width, 
  int style,
  int shift, 
  double rd = 0.22,
  bool uniqueObj = false
){
  string name = "";
  
  if(uniqueObj) {
    name = DoubleToStr(rd,4);
  } else {
    name = DoubleToStr(rd,4) + " || " + IntegerToString(MathRand() * 3);
  }
  
  bool object = ObjectCreate(0, name, OBJ_VLINE, 0, 0, 0);
  
  if(object){
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_BACK, true);
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
    ObjectSet(name, OBJPROP_WIDTH, width);
    ObjectSet(name, OBJPROP_STYLE, style);
  } else {
    ObjectSet(name, OBJPROP_COLOR, clr);
    ObjectSet(name, OBJPROP_TIME1, Time[shift]);
    ObjectSet(name, OBJPROP_WIDTH, width);
    ObjectSet(name, OBJPROP_STYLE, style);
  }
}

//+------------------------------------------------------------------+
//| create label object                                              |
//+------------------------------------------------------------------+
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
) {
  const string name = StringFormat("(%d)(%d)label", labelID, uniqueFactor);
  const bool object = ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
  if(object) {
    ObjectSetText(name, text, fontSize, font, clr);
    ObjectSet(name, OBJPROP_XDISTANCE, xDist);
    ObjectSet(name, OBJPROP_YDISTANCE, yDist);
    ObjectSet(name, OBJPROP_CORNER, corner);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_HIDDEN, true);
  } else {
    ObjectSetText(name, text, fontSize, font, clr);
    ObjectSet(name, OBJPROP_XDISTANCE, xDist);
    ObjectSet(name, OBJPROP_YDISTANCE, yDist);
    ObjectSet(name, OBJPROP_CORNER, corner);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_HIDDEN, true);
  } 
}

//+------------------------------------------------------------------+
//| get levels                                                       |
//+------------------------------------------------------------------+
int MaxDIndex = 1;
int minDindex = 1;
void GetPriceLevels(
  double &array[], 
  double numLevels, 
  double &max,
  double &min,
  double &dis,
  double &candles
){
  double high = iHigh(NULL, PERIOD_D1, MaxDIndex);
  double low = iLow(NULL, PERIOD_D1, minDindex);
  bool newHigh = High[0] >= high;
  bool newLow = Low[0] <= low;
  double totalMinutes = 1440 / Period();
  MaxDIndex = (newHigh) ? MaxDIndex+1:MaxDIndex;
  minDindex = (newLow) ? minDindex+1:minDindex;
  max = high + ((high - low) * 0.25);
  min = low - ((high - low) * 0.25);
  dis = (max - min) / granulation;
  int qtt = MathMin(MaxDIndex, minDindex);
  
  if(!newHigh && !newLow){
    candles = (qtt * totalMinutes) * 2;
    for(int i = 0; i <= numLevels; i++){
      array[i] = min + (dis * i);
    }
    drawLevel(max, clrRed, 3, STYLE_SOLID, 321, 123.23, true);
    drawLevel(min, clrRed, 3, STYLE_SOLID, 321, 123.24, true);
    drawLevel(clrRed, 3, STYLE_SOLID, (int)candles, 123.42, true);
  }
}

//+------------------------------------------------------------------+
//| configure array                                                  |
//+------------------------------------------------------------------+
void ConfigureArray(double &array[], int size){
  ArrayInitialize(array, empty);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
}


//+------------------------------------------------------------------+
//| dynamic configure array                                          |
//+------------------------------------------------------------------+
void DyConfigureArray(double &array[]){
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayResize(array, ArraySize(array) + 1);
}


//+------------------------------------------------------------------+
//| custom alert                                                     |
//+------------------------------------------------------------------+
void CustomAlert(bool &trigger, int selector){
  string starting = "Analisando o par (" + Symbol() + ") Aguarde...";
  string ready = "Par (" + Symbol() + ") Analisado!";
  string message = (selector == 0) ? starting:ready;
  if(trigger) {
    Alert(message);
    trigger = false;
  }
}

//+------------------------------------------------------------------+
//| CreateBuffer                                                     |
//+------------------------------------------------------------------+
void CreateBuffer(
  const int buffer,
  double &array[],
  const int type,
  const int style,
  const int width,
  const color clr,
  const int arrowCode = 10
){
  const string name = StringFormat("(%d)buffer", buffer);
  if(type == DRAW_ARROW) SetIndexArrow(buffer, arrowCode);
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  SetIndexBuffer(buffer, array);
  SetIndexLabel(buffer, name);
  SetIndexEmptyValue(buffer, EMPTY_VALUE);
  SetIndexStyle(buffer, type, style, width, clr);
  Print("everything okay - " + name + " Created!");
}
