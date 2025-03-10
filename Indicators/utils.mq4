//+------------------------------------------------------------------+
//| MQL4 library                                                     |
//+------------------------------------------------------------------+
#property library
#resource "\\Images\\background.bmp"
#define expiration D'2025.03.10 00:00'

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
  if(expiration <= Time[0]){
    Print("indicator expired -> telegram: t.me/BlueXInd");
  } else {
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
}

//+------------------------------------------------------------------+
//| store indicator value                                            |
//+------------------------------------------------------------------+
void StoreValue(double &array[], const int size){
  if(expiration <= Time[0]){
    Print("indicator expired -> telegram: t.me/BlueXInd");
  } else {
    ArrayInitialize(array, EMPTY_VALUE);
    ArraySetAsSeries(array, true);
    ArrayResize(array, size+1);
    Print("everything okay - array created!");
  }
}

void StoreValue(int &array[], const int size){
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
}

//+------------------------------------------------------------------+
//| create text label                                                |
//+------------------------------------------------------------------+
void CreateLabel(
  const int labelID,
  const string text,
  const int fontSize,
  const string font,
  const double price,
  const datetime time,
  const color clr,
  const double uniqueFactor = 0.23
) {
  const string name = StringFormat("(%d)(%d)label", labelID, uniqueFactor);
  const bool object = ObjectCreate(0, name, OBJ_TEXT, 0, 0, 0);
  if(object) {
    ObjectSetText(name, text, fontSize, font, clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_TIME1, time);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_HIDDEN, true);
  }
}

//+------------------------------------------------------------------+
//| create label                                                     |
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
  }
}

//+------------------------------------------------------------------+
//| custom alert                                                     |
//+------------------------------------------------------------------+
static datetime alertdt;
void CustomAlert(
  const string dir, 
  const string msg, 
  const int index, 
  double &buffer[]
){
  string stringPeriod;
  const string symbol = Symbol();
  const int period = Period();
  switch(period){
    case(PERIOD_M1): stringPeriod = "M1"; break;
    case(PERIOD_M5): stringPeriod = "M5"; break;
    case(PERIOD_M15): stringPeriod = "M15"; break;
    case(PERIOD_M30): stringPeriod = "M30"; break;
    case(PERIOD_H1): stringPeriod = "H1"; break;
    default: stringPeriod = "unknown"; break;
  }

  const string displayMsg = StringFormat(
    "(o_o)<(%s <--> |%s| for |%s| in |%s|)",
    msg,
    symbol,
    dir,
    stringPeriod
  );
  
  if(
    index         == 0 
    && buffer[0]  != EMPTY_VALUE
    && alertdt    != Time[0]
  ){
    Alert(displayMsg);
    alertdt = Time[0];
  }
}

//+------------------------------------------------------------------+
//| simples custom alert                                             |
//+------------------------------------------------------------------+
void CustomAlert(
  const string dir, 
  const string msg, 
  const int index
){
  string stringPeriod;
  const string symbol = Symbol();
  const int period = Period();
  switch(period){
    case(PERIOD_M1): stringPeriod = "M1"; break;
    case(PERIOD_M5): stringPeriod = "M5"; break;
    case(PERIOD_M15): stringPeriod = "M15"; break;
    case(PERIOD_M30): stringPeriod = "M30"; break;
    case(PERIOD_H1): stringPeriod = "H1"; break;
    default: stringPeriod = "unknown"; break;
  }

  const string displayMsg = StringFormat(
    "(o_o)<(%s: |%s| --- |%s| --- |%s|)",
    msg,
    symbol,
    dir,
    stringPeriod
  );
  
  if(
    index         == 0 
    && alertdt    != Time[0]
  ){
    Alert(displayMsg);
    alertdt = Time[0];
  }
}

//+------------------------------------------------------------------+
//| setup layout                                                     |
//+------------------------------------------------------------------+
void SetupLayout(){
  const color background = C'27,31,41';
  const color foregraund = C'120,124,134';
  const color grid = C'59,64,79';
  const color bullColor = C'0,154,45';
  const color bearColor = C'193,67,49';
  const color dojiColor = C'59,64,79';
  ChartSetInteger(0, CHART_COLOR_BACKGROUND, background);
  ChartSetInteger(0, CHART_COLOR_FOREGROUND, foregraund);
  ChartSetInteger(0, CHART_COLOR_GRID, grid);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, bullColor);
  ChartSetInteger(0, CHART_COLOR_CHART_UP, bullColor);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, bearColor);
  ChartSetInteger(0, CHART_COLOR_CHART_DOWN, bearColor);
  ChartSetInteger(0, CHART_COLOR_CHART_LINE, dojiColor);
}

//+------------------------------------------------------------------+
//| background image                                                 |
//+------------------------------------------------------------------+
void BackgroundIMG(){
  if(expiration <= Time[0]){
    Print("indicator expired -> telegram: t.me/BlueXInd");
  } else {
    const string name = "bkg";
    const string path = "::images\\background.bmp";
    const bool object = ObjectCreate(0, name, OBJ_BITMAP_LABEL, 0, 0, 0);
    if(object){
      ObjectSetString(0, name, OBJPROP_BMPFILE, path);
      ObjectSet(name, OBJPROP_BACK, true);
    }
  }
}