//+------------------------------------------------------------------+
//|                                              PASMC_Utils.mqh    |
//|  Shared helpers for PA + SMC/ICT Hybrid indicator and EA (MT5)  |
//|  See guide/02-smc-core.md and guide/03-ict-essentials.md         |
//+------------------------------------------------------------------+
#ifndef __PASMC_UTILS_MQH__
#define __PASMC_UTILS_MQH__

#define PASMC_VERSION "1.0.0"

// Bias states
enum ENUM_PASMC_BIAS
  {
   PASMC_BIAS_NONE   =  0,
   PASMC_BIAS_BULL   =  1,
   PASMC_BIAS_BEAR   = -1
  };

// Setup IDs (used as iCustom buffer markers and EA filters)
enum ENUM_PASMC_SETUP
  {
   PASMC_SETUP_NONE = 0,
   PASMC_SETUP_S1_LONG  = 1,
   PASMC_SETUP_S1_SHORT = 2,
   PASMC_SETUP_S4_LONG  = 4,
   PASMC_SETUP_S4_SHORT = 5
  };

// Indicator buffer indexes (must match the indicator)
#define PASMC_BUF_BIAS         0
#define PASMC_BUF_LASTPH       1
#define PASMC_BUF_LASTPL       2
#define PASMC_BUF_BULLOB_TOP   3
#define PASMC_BUF_BULLOB_BOT   4
#define PASMC_BUF_BEAROB_TOP   5
#define PASMC_BUF_BEAROB_BOT   6
#define PASMC_BUF_FVG_BULL     7   // 1 if a bullish FVG just printed
#define PASMC_BUF_FVG_BEAR     8
#define PASMC_BUF_SETUP        9   // ENUM_PASMC_SETUP

#define PASMC_BUFFERS         10

// ------------------------------------ TIME / SESSION ----------------------

// Convert HHMM minutes since 00:00 NY to broker server time, applying offset.
// brokerGmtOffset = number of hours by which broker time leads GMT (+2 winter, +3 summer for typical brokers).
// Returns: 1 if `dt` (broker time) falls in [startHHMM, endHHMM] NY; 0 otherwise.
bool PASMC_InNySession(datetime dt, int startHHMM, int endHHMM, int brokerGmtOffset)
  {
   // NY = GMT - 5 (EST) or GMT - 4 (EDT). We approximate with GMT-5 winter, GMT-4 summer.
   // For simplicity assume dynamic DST via TimeGMTOffset() difference from broker time.
   // Practical method: convert broker time to NY by subtracting brokerGmtOffset, adding NY offset.
   MqlDateTime mt;
   TimeToStruct(dt, mt);
   // shift broker -> GMT -> NY (approx EST = -5)
   int totalMinBroker = mt.hour * 60 + mt.min;
   int totalMinNy = totalMinBroker - brokerGmtOffset * 60 - 300; // EST -5h
   while(totalMinNy < 0) totalMinNy += 1440;
   while(totalMinNy >= 1440) totalMinNy -= 1440;

   int startMin = (startHHMM/100)*60 + (startHHMM%100);
   int endMin   = (endHHMM/100)*60   + (endHHMM%100);

   if(startMin <= endMin)
      return (totalMinNy >= startMin && totalMinNy < endMin);
   else
      return (totalMinNy >= startMin || totalMinNy < endMin); // wraps midnight
  }

// ------------------------------------ STRUCTURE / PIVOTS -----------------

// Returns true if the bar at index `i` is a pivot high with `n` bars on each side.
// Series-indexed (0 = current).
bool PASMC_IsPivotHigh(const double &highs[], int i, int n)
  {
   if(i < n || i + n >= ArraySize(highs))
      return false;
   double v = highs[i];
   for(int k = 1; k <= n; k++)
     {
      if(highs[i+k] >= v) return false;
      if(highs[i-k] >= v) return false;
     }
   return true;
  }

bool PASMC_IsPivotLow(const double &lows[], int i, int n)
  {
   if(i < n || i + n >= ArraySize(lows))
      return false;
   double v = lows[i];
   for(int k = 1; k <= n; k++)
     {
      if(lows[i+k] <= v) return false;
      if(lows[i-k] <= v) return false;
     }
   return true;
  }

// ------------------------------------ FVG DETECTION ----------------------
// 3-candle FVG: bullish if low[i] > high[i+2]; bearish if high[i] < low[i+2].
// (`i` is 0-based series index — i is the "candle 3" of the pattern.)
bool PASMC_IsBullFVG(const double &lows[], const double &highs[], int i)
  {
   if(i + 2 >= ArraySize(lows)) return false;
   return lows[i] > highs[i+2];
  }
bool PASMC_IsBearFVG(const double &lows[], const double &highs[], int i)
  {
   if(i + 2 >= ArraySize(lows)) return false;
   return highs[i] < lows[i+2];
  }

// ------------------------------------ SWEEPS -----------------------------
// Bullish sweep at bar i: low[i] < ref_low AND close[i] > ref_low.
bool PASMC_IsBullSweep(const double &lows[], const double &closes[], int i, double refLow)
  {
   if(refLow == 0.0) return false;
   return (lows[i] < refLow && closes[i] > refLow);
  }
bool PASMC_IsBearSweep(const double &highs[], const double &closes[], int i, double refHigh)
  {
   if(refHigh == 0.0) return false;
   return (highs[i] > refHigh && closes[i] < refHigh);
  }

// ------------------------------------ DRAWING HELPERS --------------------

void PASMC_DrawBox(const string name, datetime t1, double p1, datetime t2, double p2,
                   color clr, int border, ENUM_LINE_STYLE style = STYLE_SOLID)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_TIME,   0, t1);
   ObjectSetDouble (0, name, OBJPROP_PRICE,  0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME,   1, t2);
   ObjectSetDouble (0, name, OBJPROP_PRICE,  1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR,        clr);
   ObjectSetInteger(0, name, OBJPROP_FILL,         true);
   ObjectSetInteger(0, name, OBJPROP_BACK,         true);
   ObjectSetInteger(0, name, OBJPROP_WIDTH,        border);
   ObjectSetInteger(0, name, OBJPROP_STYLE,        style);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN,       true);
  }

void PASMC_DrawTrendline(const string name, datetime t1, double p1, datetime t2, double p2,
                         color clr, int width, ENUM_LINE_STYLE style)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t1);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, name, OBJPROP_TIME,  1, t2);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PASMC_DrawText(const string name, datetime t, double p, const string txt, color clr, int size = 8)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, t, p);
   ObjectSetInteger(0, name, OBJPROP_TIME,  0, t);
   ObjectSetDouble (0, name, OBJPROP_PRICE, 0, p);
   ObjectSetString (0, name, OBJPROP_TEXT,  txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  }

void PASMC_DeletePrefix(const string prefix)
  {
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
     {
      string n = ObjectName(0, i);
      if(StringFind(n, prefix) == 0)
         ObjectDelete(0, n);
     }
  }

// ------------------------------------ RISK SIZING ------------------------

// Returns lot size for given risk-percent, SL distance in points, and pip value.
double PASMC_LotForRisk(double accountEquity, double riskPct,
                        double slPoints, double tickValue, double minLot, double lotStep)
  {
   if(slPoints <= 0 || tickValue <= 0) return 0.0;
   double riskCash = accountEquity * (riskPct / 100.0);
   double oneLotRisk = slPoints * tickValue;
   if(oneLotRisk <= 0) return 0.0;
   double lots = riskCash / oneLotRisk;
   // round down to step
   lots = MathFloor(lots / lotStep) * lotStep;
   return MathMax(minLot, lots);
  }

#endif // __PASMC_UTILS_MQH__
