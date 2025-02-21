//+------------------------------------------------------------------+
//| macro                                                            |
//+------------------------------------------------------------------+
#property copyright "BlueX Indicators"
#property link "google.com"
#property version "1.2"
#property indicator_buffers 2
#property indicator_chart_window
#property strict

// enums
enum checker{positive, negative, neutral};

// user inputs
input double precision = 0.75;
input int bigCicles = 120;
input int mbb = 80;

// global variables
int miliseconds = 50;
int limit = MathMin(mbb, Bars);
double granulation = 500;
double iteration = 1;
int bigIteration = 0;
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
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  ObjectsDeleteAll(0, -1, OBJ_HLINE);
  CustomAlert(startAnalysis, 0);
  ConfigureArray(levelArr, (int)granulation);
  EventSetMillisecondTimer(miliseconds);
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| deinit event                                                     |
//+------------------------------------------------------------------+
void deinit(){
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  ObjectsDeleteAll(0, -1, OBJ_HLINE);
}

//+------------------------------------------------------------------+
//| per-milisecond event                                             |
//+------------------------------------------------------------------+
void OnTimer(){
  // variables
  double positiveCounter = 0;
  double negativeCounter = 0;
  double max = High[ArrayMaximum(High, mbb)];
  double min = Low [ArrayMinimum(Low , mbb)];
  double dis = (max - min) / granulation;
  
  // get levels -> pass to level array
  GetPriceLevels(levelArr, granulation, min, dis);
  
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
      color levelClr = clrGray;
      double counterSum = positiveCounter + negativeCounter;
      double levelAccuracy = (counterSum != 0) ? positiveCounter / counterSum:0;
      
      if(levelAccuracy >= precision + 0.05) levelClr = clrYellow;
      if(levelAccuracy >= precision + 0.10) levelClr = clrOrange;
      if(levelAccuracy >= precision + 0.15) levelClr = clrRed;
      
      if(levelAccuracy >= precision && analysisDone){
        drawLevel(level, levelClr, 1, STYLE_SOLID, i, levelAccuracy);
      }
      
      // reset controlls
      bool resetIteration = (iteration >= granulation);
      bool bigReset = (bigIteration >= bigCicles);
      
      // create information tag
      double progress = (iteration / granulation) * 100;
      string loading = "Analise em andamento: " + DoubleToStr(progress, 2) + "%";
      string loaded = "Analise concluida";
      string legend = "(Vermelho - SR forte | Amarelo - SR moderado | cinza - SR fraco)";
      string text = (!analysisDone) ? loaded:loading;
      string iteMessage = "Ciclos até analisar novamente: " + IntegerToString(bigCicles - bigIteration);
      CreateLabel(1, text, 12, 5, 20, "Lexend", foreGround);
      CreateLabel(2, iteMessage, 12, 5, 0, "Lexend", foreGround);
      Comment(legend);
      
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
        ObjectsDeleteAll(0, -1, OBJ_HLINE);
        ObjectsDeleteAll(0, -1, OBJ_LABEL);
      
      // iteration process
      } else {
        iteration++;
      }
    }
  }
  
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
  string name = IntegerToString(shift) + " --> " + DoubleToStr(rd,2);
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
  double rd = 0.22
){
  string name = DoubleToStr(rd,4) + " || " + IntegerToString(MathRand() * 3);
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