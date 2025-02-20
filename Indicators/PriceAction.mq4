//+------------------------------------------------------------------+
//| macro                                                            |
//+------------------------------------------------------------------+
#property copyright "BlueX Indicators"
#property link "google.com"
#property version "1.2"
#property indicator_buffers 2
#property indicator_chart_window
#property strict

// global variables
int mbb = 75;
int limit = MathMin(mbb, Bars);
double granulation = 10000;
double iteration = 1;
int bigIteration = 0;
int bigCicles = 6;
double empty = EMPTY_VALUE;
bool startAnalysis = true;
bool analysisDone = true;

// colors
color backGround = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
color foreGround = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
color bullColors = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
color bearColors = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
color dojiColors = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);

// arrays
double levelArr[];
//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){
  CustomAlert(startAnalysis, 0);
  ConfigureArray(levelArr, (int)granulation);
  EventSetMillisecondTimer(50);
  return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| per-milisecond event                                             |
//+------------------------------------------------------------------+
void OnTimer(){
  // variables
  double max = High[ArrayMaximum(High, mbb)];
  double min = Low [ArrayMinimum(Low , mbb)];
  double dis = (max - min) / granulation;
  
  // get levels -> pass to level array
  GetPriceLevels(levelArr, granulation, min, dis);
  
  // main loop
  for(int i = limit; i >= 1; i--){
    if(i >= mbb) continue;
   
    // once per cicle event
    if(i == 1) {
      // reset controlls
      bool resetIteration = (iteration >= granulation);
      bool bigReset = (bigIteration >= bigCicles);
      
      // create information tag
      double progress = (iteration / granulation) * 100;
      string loading = "Analise " + DoubleToStr(progress, 2) + "% concluida...";
      string loaded = "Analise concluida!";
      string text = (!analysisDone) ? loaded:loading;
      CreateLabel(1, text, 12, 5, 20, "Lexend", foreGround);
      CreateLabel(2, IntegerToString(bigIteration), 12, 5, 0, "Lexend", foreGround);
      
      // small reset
      if(resetIteration) {
        iteration = 1;
        bigIteration++;
        CustomAlert(analysisDone, 1);
      
      // big reset
      } else if (bigReset) {
        startAnalysis = true;
        analysisDone = true;
        bigIteration = 0;
        CustomAlert(startAnalysis, 0);
      
      // iteration process
      } else {
        iteration++;
      }
    }
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
void GetPriceLevels(
  double &array[], 
  double numLevels, 
  double min,
  double dis
){
  for(int i = 0; i <= numLevels; i++) array[i] = min + (dis * i);
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
//| per-tick function                                                |
//+------------------------------------------------------------------+
int start(){
  return(Bars);
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