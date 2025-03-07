//+------------------------------------------------------------------+
//| macro                                                            |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 12

// copyright and identification
#property copyright "BlueX Indicators"
#property link "https://t.me/BlueXInd"
#property version "1.08"
#property description "Esse indicador mostra suportes e resistencias analisados"
#property description "de maneira continua."

// enums
enum accTest{positive, negative, neutral};

// constants and variables
#define indicator_name "SnR Lines"
#define expiration D'2025.06.12 00:00'
#define font "Lexend"
int numberOfLevels = 1000;
int mbb = 300;
int bigCicleSize = 120;
int miliseconds = 10;
int limit = MathMin(mbb, Bars);
int interval = 0;
int index = 1;
int bigIndex = bigCicleSize;
bool firstCicle = true;
bool validZoneFlag = true;
double max;
double min;
double distance;
double targetAccuracy = 0.62;

// arrays
double levelsArray[];
double volume[];
double volumeMA[];
double hi[], lo[], op[], cl[];
double opBull[], clBull[];
double opBear[], clBear[];
double opBullVol[], clBullVol[];
double opBearVol[], clBearVol[];

//+------------------------------------------------------------------+
//| init event                                                       |
//+------------------------------------------------------------------+
int init(){
  
  // clear objects
  ClearObjects();

  // time lock
  if(Time[0] >= expiration) return(INIT_SUCCEEDED);

  // initialization global values
  interval = GetCandlesInterval();
  max = High[ArrayMaximum(High, interval)];
  min = Low[ArrayMinimum(Low, interval)]; 
  distance = (max - min);

  // configure arrays
  ArrayConfigure(levelsArray, numberOfLevels);
  ArrayConfigure(volume, (int)(interval * 2.5));
  ArrayConfigure(volumeMA, interval);

  // time set event
  EventSetMillisecondTimer(miliseconds);

  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| pert time event                                                  |
//+------------------------------------------------------------------+
void OnTimer(){
  
  // local variables
  int width = GetCandleWidth();
  double levelPoints = 0.0;
  double levelTotalPoints = 0.0;
  bool validZone = (
    Close[1] > (min - (distance * 0.05)) && 
    Close[1] < (max + (distance * 0.05))
  ) ? true:false;
  
  // configure candles
  color doji = C'152,173,178';
  color neutralBull = C'122,136,148';
  color neutralBear = C'74,82,90';
  color bullColor = C'57,194,115';
  color bearColor = C'226,41,8';
  
  // doji candles
  CreateBuffer(00, 1, doji, hi);
  CreateBuffer(01, 1, doji, lo);
  CreateBuffer(02, width, doji, op);
  CreateBuffer(03, width, doji, cl);
  // bull-bear neutral candles
  CreateBuffer(04, width, neutralBull, opBull);
  CreateBuffer(05, width, neutralBull, clBull);
  CreateBuffer(06, width, neutralBear, opBear);
  CreateBuffer(07, width, neutralBear, clBear);
  // bull-bear great volume candles
  CreateBuffer(08, width, bullColor, opBullVol);
  CreateBuffer(09, width, bullColor, clBullVol);
  CreateBuffer(10, width, bearColor, opBearVol);
  CreateBuffer(11, width, bearColor, clBearVol);
  
  // master logical controler - zone
  if(validZone) {
    
    // plot main lines
    CreateLines("hline", clrRed   , 3, max + (distance * 0.05), 0, true, "hline max");
    CreateLines("hline", clrGreen , 3, min - (distance * 0.05), 0, true, "hline min");
    
    for(int j = 0; j <= numberOfLevels; j++){
    
      double particalLevel = (max - min) / numberOfLevels;
      double level = min + (particalLevel * j);
      levelsArray[j] = level;
      
    }
    
    for(int k = limit; k >= 1; k--){
      if(k >= interval*2.5) continue;
      volume[k] = (double)Volume[k] * iATR(NULL, PERIOD_CURRENT, 14, k);
    }
    
    // main loop
    for(int i = limit; i >= 1; i--){
      
      // bars limit
      if(i >= interval) continue;
      
      // calculates indicators data
      volumeMA[i] = iMAOnArray(volume, 0, 50, 0, MODE_EMA, i);

      // doji candles
      hi[i] = High[i];
      lo[i] = Low[i];
      op[i] = (Open[i] == Close[i]) ? Open[i]:EMPTY_VALUE;
      cl[i] = (Open[i] == Close[i]) ? Close[i]:EMPTY_VALUE;
      // neutral candles
      opBull[i] = (Open[i] < Close[i]) ? Open[i]:EMPTY_VALUE;
      clBull[i] = (Open[i] < Close[i]) ? Close[i]:EMPTY_VALUE;
      opBear[i] = (Open[i] > Close[i]) ? Open[i]:EMPTY_VALUE;
      clBear[i] = (Open[i] > Close[i]) ? Close[i]:EMPTY_VALUE;
      // volume candles bull
      opBullVol[i] = (
        volumeMA[i] > volume[i] && 
        Open[i] < Close[i]
      ) ? Open[i]:EMPTY_VALUE;
      clBullVol[i] = (
        volumeMA[i] > volume[i] &&
        Open[i] < Close[i]
      ) ? Close[i]:EMPTY_VALUE;
      // volume candles bear
      opBearVol[i] = (
        volumeMA[i] > volume[i] && 
        Open[i] > Close[i]
      ) ? Open[i]:EMPTY_VALUE;
      clBearVol[i] = (
        volumeMA[i] > volume[i] &&
        Open[i] > Close[i]
      ) ? Close[i]:EMPTY_VALUE;
      
      // get level values
      double lineLevel = levelsArray[index];
      
      // get level accuracy
      accTest levelAccuracy = GetLevelAccuracy(lineLevel, i);
      bool increment = (levelAccuracy == positive);
      bool decrement = (levelAccuracy == negative);      
      if(increment) levelPoints++;
      if(decrement) levelPoints--;
      if(increment || decrement) levelTotalPoints++;
      
      // once per cicle
      if(i == 1) {
        
        // scan line
        ; if(firstCicle) { CreateLines("hline", clrWhite   , 1, lineLevel, 0, true, "hline scan");
        } else           { ObjectDelete(0, "hline scan");
        }
        
        // big reset if break max min zone
        if(!validZoneFlag) {
        
          CustomAlert("Reanalizando: par("+ Symbol() +")!");
          Alert(index);
          ClearObjects();
          validZoneFlag = true;
          firstCicle = true;
          bigIndex = bigCicleSize;
          
        }
        
        // plot lines per level accuracy
        double accuracy = (levelTotalPoints != 0) ? (levelPoints / levelTotalPoints):0;
        if(accuracy >= targetAccuracy && firstCicle) {
        
          color lineColor = C'55,55,55';
          if(accuracy >= targetAccuracy + 0.05) lineColor = C'93,93,93';
          if(accuracy >= targetAccuracy + 0.10) lineColor = C'109,109,109';
          if(accuracy >= targetAccuracy + 0.15) lineColor = C'101,132,151';
          CreateLines("hline", lineColor, 1, lineLevel, 0);
        
        }
        
        // update index once per cicle
        bool smallReset = (index >= numberOfLevels);
        if(smallReset) {
        
          index = 1;
          bigIndex--;
          firstCicle = false;
          
        } else {
        
          index++;
          
        }
        
        // update big cicles
        if(bigIndex <= 0) {
        
          bigIndex = bigCicleSize;
          firstCicle = true;
          validZoneFlag = false;
        }
        
      }
      
    }
    
  } else {
  
    max = max + (distance * 0.33);
    min = min - (distance * 0.33);
    validZoneFlag = false;
    index = 1;
          
  }
  
} int start(){return(Bars);}

//+------------------------------------------------------------------+
//| candle width                                                     |
//+------------------------------------------------------------------+
int GetCandleWidth() {
  
  int width = 0;
  int zoom = (int)ChartGetInteger(0, CHART_SCALE);
  switch(zoom) {
  
    case(5): width = 13; break;
    case(4): width = 6; break;
    case(3): width = 3; break;
    case(2): width = 2; break;
    case(1): width = 1; break;
    case(0): width = 1; break;
  
  }
  
  return(width);
  
}

//+------------------------------------------------------------------+
//| create buffers                                                   |
//+------------------------------------------------------------------+
void CreateBuffer(int arrIndex, int width, color clr,double &array[]) {
  
  // configure array to buffer
  string name = StringFormat(" %d || %s", arrIndex, indicator_name);
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayInitialize(array, EMPTY_VALUE);
  SetIndexBuffer(arrIndex, array);
  SetIndexStyle(arrIndex, DRAW_HISTOGRAM, STYLE_SOLID, width, clr);
  SetIndexEmptyValue(arrIndex, EMPTY_VALUE);
  SetIndexLabel(arrIndex, name);

}

//+------------------------------------------------------------------+
//| get level accuracy                                               |
//+------------------------------------------------------------------+
accTest GetLevelAccuracy(double line, int shift) {
  
  bool respect = (
    (
    
      // bull condition
      Close[shift] > line &&
      Open[shift] > line &&
      Low[shift] < line
    
    ) || (
      
      // bear condition  
      Close[shift] < line &&
      Open[shift] < line &&
      High[shift] > line
      
    )
  );
  
  bool disrespect = (
    (
    
      // bull condition
      Close[shift] < line &&
      Open[shift] > line
    
    ) || (
      
      // bear condition  
      Close[shift] > line &&
      Open[shift] < line
      
    )
  );
  
  accTest levelState = neutral;
  if(respect) levelState = positive;
  if(disrespect) levelState = negative;
  return(levelState);
  
}

//+------------------------------------------------------------------+
//| configure array                                                  |
//+------------------------------------------------------------------+
void ArrayConfigure(double &array[], int size) {
  if(!ArrayGetAsSeries(array)) ArraySetAsSeries(array, true);
  ArrayResize(array, size+1);
}

//+------------------------------------------------------------------+
//| create lines                                                     |
//+------------------------------------------------------------------+
void CreateLines(
  string objType,
  color objColor,
  int width,
  double price1 = 0,
  datetime time1 = 0,
  bool uniqueObj = false,
  string objName = "obj"
) {

  int type = (objType == "hline") ? OBJ_HLINE:OBJ_VLINE;
  string name = (uniqueObj) ? objName:DoubleToStr((MathRand() / Close[0]),_Digits);
  if(type == OBJ_HLINE){
    
    bool object = ObjectCreate(0, name, type, 0, 0, 0);
    if(object) {
    
      ObjectSet(name, OBJPROP_PRICE1, price1);
      ObjectSet(name, OBJPROP_COLOR, objColor);
      ObjectSet(name, OBJPROP_WIDTH, width);
      ObjectSet(name, OBJPROP_SELECTABLE, false);
      ObjectSet(name, OBJPROP_HIDDEN, true);
      ObjectSet(name, OBJPROP_BACK, true);
      
    } else {
      
      ObjectSet(name, OBJPROP_PRICE1, price1);
      ObjectSet(name, OBJPROP_COLOR, objColor);
      ObjectSet(name, OBJPROP_WIDTH, width);
      
    }
    
  } else {
   
    bool object = ObjectCreate(0, name, type, 0, 0, 0);
    if(object) {
    
      ObjectSet(name, OBJPROP_TIME1, time1);
      ObjectSet(name, OBJPROP_COLOR, objColor);
      ObjectSet(name, OBJPROP_WIDTH, width);
      ObjectSet(name, OBJPROP_SELECTABLE, false);
      ObjectSet(name, OBJPROP_HIDDEN, true);
      ObjectSet(name, OBJPROP_BACK, true);
      
    } else {
      
      ObjectSet(name, OBJPROP_TIME1, time1);
      ObjectSet(name, OBJPROP_COLOR, objColor);
      ObjectSet(name, OBJPROP_WIDTH, width);
      
    }
    
  }
  
}

//+------------------------------------------------------------------+
//| custom alert                                                     |
//+------------------------------------------------------------------+
static datetime dtCA; 
void CustomAlert(string msg){

  if(dtCA != Time[0]) {
    Alert(msg);
    dtCA = Time[0];
  }
  
}

//+------------------------------------------------------------------+
//| get candles interval function                                    |
//+------------------------------------------------------------------+
int GetCandlesInterval(){
  
  int localInterval = 0;
  int period = Period();
  
  switch(period){
    case(001): localInterval = ((60 / period) * 002); break;
    case(005): localInterval = ((60 / period) * 008); break;
    case(015): localInterval = ((60 / period) * 024); break;
    case(030): localInterval = ((60 / period) * 042); break;
    case(060): localInterval = ((60 / period) * 068); break;
    case(240): localInterval = ((60 / period) * 120); break;
  }

  return(localInterval);
}

//+------------------------------------------------------------------+
//| clear objects on the chart                                       |
//+------------------------------------------------------------------+
void ClearObjects(){
  ObjectsDeleteAll(0, -1, OBJ_VLINE);
  ObjectsDeleteAll(0, -1, OBJ_HLINE);
  ObjectsDeleteAll(0, -1, OBJ_LABEL);
  ObjectsDeleteAll(0, -1, OBJ_TEXT);
}






