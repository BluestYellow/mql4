//+------------------------------------------------------------------+
//| MQL4 library                                                     |
//+------------------------------------------------------------------+
#property library

//+------------------------------------------------------------------+
//| CreateBuffer                                                     |
//+------------------------------------------------------------------+
void CreateBuffer(
  int buffer,
  double &array[],
  int type,
  int style,
  int width,
  color clr,
  int arrowCode = 10
){
  string name = StringFormat("(%d)buffer", buffer);
  if(type == DRAW_ARROW) SetIndexArrow(buffer, arrowCode);
  
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  SetIndexBuffer(buffer, array);
  SetIndexLabel(buffer, name);
  SetIndexEmptyValue(buffer, EMPTY_VALUE);
  SetIndexStyle(buffer, type, style, width, clr);
}

//+------------------------------------------------------------------+
//| store indicator value                                            |
//+------------------------------------------------------------------+
void StoreValue(double &array[], int size){
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
}

void StoreValue(int &array[], int size){
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
}

//+------------------------------------------------------------------+
//| create text label                                                |
//+------------------------------------------------------------------+
void CreateLabel(
  int labelID,
  string text,
  int fontSize,
  string font,
  double price,
  datetime time,
  color clr,
  double uniqueFactor = 0.23
) {
  string name = StringFormat("(%d)(%d)label", labelID, uniqueFactor);
  bool object = ObjectCreate(0, name, OBJ_TEXT, 0, 0, 0);

  if(object) {
    ObjectSetText(name, text, fontSize, font, clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_TIME1, time);
    ObjectSet(name, OBJPROP_SELECTABLE, false);
    ObjectSet(name, OBJPROP_HIDDEN, true);
  }
}

//+------------------------------------------------------------------+
//| custom alert                                                     |
//+------------------------------------------------------------------+
void CustomAlert(const string &dir){
  string symbol = Symbol();
  string stringPeriod;
  int period = Period();
  
  switch(period){
    case(PERIOD_M1): stringPeriod = "M1"; break;
    case(PERIOD_M5): stringPeriod = "M5"; break;
    case(PERIOD_M15): stringPeriod = "M15"; break;
    case(PERIOD_M30): stringPeriod = "M30"; break;
    case(PERIOD_H1): stringPeriod = "H1"; break;
    default: stringPeriod = "unknown"; break;
  }

  string displayMsg = StringFormat(
    "(o_o)<(signal at |%s| for |%s| in |%s|)",
    symbol,
    dir,
    stringPeriod
  );
  
  Alert(displayMsg);
}

//+------------------------------------------------------------------+
//| setup layout                                                     |
//+------------------------------------------------------------------+
void SetupLayout(){
  color background = C'36,42,58';
  color foregraund = C'120,124,134';
  color grid = C'59,64,79';
  color bullColor = C'0,154,45';
  color bearColor = C'193,67,49';
  color dojiColor = C'59,64,79';
  
  ChartSetInteger(0, CHART_COLOR_BACKGROUND, background);
  ChartSetInteger(0, CHART_COLOR_FOREGROUND, foregraund);
  ChartSetInteger(0, CHART_COLOR_GRID, grid);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, bullColor);
  ChartSetInteger(0, CHART_COLOR_CHART_UP, bullColor);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, bearColor);
  ChartSetInteger(0, CHART_COLOR_CHART_DOWN, bearColor);
  ChartSetInteger(0, CHART_COLOR_CHART_LINE, dojiColor);
}