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
void StoreValue(double &array[], double value, int size, int index){
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
  array[index] = value;
}

void StoreValue(int &array[], int value, int size, int index){
  ArrayInitialize(array, EMPTY_VALUE);
  ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
  array[index] = value;
}