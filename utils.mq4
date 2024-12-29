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
  color clr
) {
  string name = StringFormat("(%d)label", labelID);
  bool object = ObjectCreate(0, name, OBJ_TEXT, 0, 0, 0);

  if(object) {
    ObjectSetText(name, text, fontSize, font, clr);
    ObjectSet(name, OBJPROP_PRICE1, price);
    ObjectSet(name, OBJPROP_TIME1, time);
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