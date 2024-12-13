#property indicator_buffers 1
#property indicator_chart_window
#property strict
#import "utils.ex4"

  // create buffer ============= ||
  void CreateBuffer(
    int buffer,
    double &array[],
    int type,
    int style,
    int width,
    color clr,
    int arrowCode
  );
  // create buffer ============= ||
  
  // store value =========================================== ||
  void StoreValue(double &array[], double value, int index);
  void StoreValue(int &array[], int value, int index);
  // store value =========================================== ||
  
#import


int start(){
  return(Bars);
}