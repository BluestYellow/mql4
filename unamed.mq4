#import "utils.ex4"

  // create buffer ============= ||
  void CreateBuffer(
    int buffer,
    double &array[],
    int type,
    int style,
    int width,
    color clr,
    int arrowCode = 10
  );
  // create buffer ============= ||
  
  // store value =========================================== ||
  void StoreValue(double &array[], double value, int size, int index);
  void StoreValue(int &array[], int value, int size, int index);
  // store value =========================================== ||
  
#import

#property indicator_buffers 1
#property indicator_chart_window
#property strict

//+------------------------------------------------------------------+
//| global statement                                                 |
//+------------------------------------------------------------------+
// variables
int mbb = 100;



//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| per-tick event                                                   |
//+------------------------------------------------------------------+
int start(){
  int limit = ArraySize(Close);
  
  // main loop
  for(int i = 0; i <= limit; i++){
    if(i >= mbb) continue;
    

  }
  
  return(Bars);
}
