//+------------------------------------------------------------------+
//|                                          PA_SMC_ICT_Hybrid.mq4  |
//|  PA + SMC/ICT Hybrid indicator for MetaTrader 4                 |
//|  (Feature-reduced port of the MT5 version.)                     |
//|                                                                  |
//|  Visualizes:                                                     |
//|    - Swing pivots (high/low markers)                             |
//|    - BOS / CHoCH lines                                           |
//|    - Bullish / Bearish Order Blocks (recolor when broken)       |
//|    - Fair Value Gaps                                             |
//|    - Equal-highs / equal-lows + sweep markers                    |
//|    - Kill zones background shading (Asia/London/NY)             |
//+------------------------------------------------------------------+
#property copyright   "PA SMC ICT Hybrid Repo (MIT)"
#property link        ""
#property version     "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 10

// ------------------------------ INPUTS -----------------------------------

extern int      InpPivotN          = 5;
extern int      InpMaxOBs          = 8;
extern int      InpMaxFVGs         = 6;
extern double   InpFVGMinAtrFrac   = 0.30;
extern double   InpEqTolPips       = 3.0;
extern int      InpBrokerGmtOffset = 2;
extern bool     InpShowKillzones   = true;
extern bool     InpUsePopup        = true;
extern bool     InpUsePush         = false;
extern bool     InpUseEmail        = false;
extern color    InpColBullOB       = clrLimeGreen;
extern color    InpColBearOB       = clrCrimson;
extern color    InpColBreaker      = clrOrange;
extern color    InpColBullFVG      = clrAquamarine;
extern color    InpColBearFVG      = clrMagenta;
extern color    InpColLiquidity    = clrAqua;
extern color    InpColKZ           = clrTurquoise;

// ------------------------------ BUFFERS ----------------------------------

double BufBias[];
double BufLastPH[];
double BufLastPL[];
double BufBullOBTop[];
double BufBullOBBot[];
double BufBearOBTop[];
double BufBearOBBot[];
double BufFVGBull[];
double BufFVGBear[];
double BufSetup[];

#define PASMC_SETUP_NONE       0
#define PASMC_SETUP_S1_LONG    1
#define PASMC_SETUP_S1_SHORT   2
#define PASMC_SETUP_S4_LONG    4
#define PASMC_SETUP_S4_SHORT   5

// ------------------------------ STATE ------------------------------------

double  g_lastPH = 0, g_lastPHprev = 0;
double  g_lastPL = 0, g_lastPLprev = 0;
datetime g_lastPHt = 0, g_lastPLt = 0;
int     g_bias = 0;

// active OBs (parallel arrays)
double g_obTop[];
double g_obBot[];
int    g_obDir[];
int    g_obBrk[];   // 0/1 for false/true (MQL4 has no bool array push helper here)
datetime g_obT[];

// active FVGs
double g_fvgTop[];
double g_fvgBot[];
int    g_fvgDir[];
datetime g_fvgT[];

string PFX_OB  = "pasmc_ob_";
string PFX_FVG = "pasmc_fvg_";
string PFX_LIQ = "pasmc_liq_";
string PFX_BG  = "pasmc_bg_";
string PFX_BOS = "pasmc_bos_";

// ------------------------------ HELPERS ----------------------------------

double PipSize()
  {
   int dg = (int)MarketInfo(_Symbol, MODE_DIGITS);
   double pt = MarketInfo(_Symbol, MODE_POINT);
   return (dg == 3 || dg == 5) ? pt * 10.0 : pt;
  }

bool IsPivotHighSeries(int idx, int n)
  {
   double v = High[idx];
   for(int k = 1; k <= n; k++)
     {
      if(idx + k >= Bars) return false;
      if(idx - k < 0) return false;
      if(High[idx + k] >= v) return false;
      if(High[idx - k] >= v) return false;
     }
   return true;
  }

bool IsPivotLowSeries(int idx, int n)
  {
   double v = Low[idx];
   for(int k = 1; k <= n; k++)
     {
      if(idx + k >= Bars) return false;
      if(idx - k < 0) return false;
      if(Low[idx + k] <= v) return false;
      if(Low[idx - k] <= v) return false;
     }
   return true;
  }

bool InNySession(datetime dt, int startHHMM, int endHHMM)
  {
   int totalMinBroker = TimeHour(dt) * 60 + TimeMinute(dt);
   int totalMinNy = totalMinBroker - InpBrokerGmtOffset * 60 - 300;
   while(totalMinNy < 0) totalMinNy += 1440;
   while(totalMinNy >= 1440) totalMinNy -= 1440;
   int sm = (startHHMM/100)*60 + (startHHMM%100);
   int em = (endHHMM/100)*60   + (endHHMM%100);
   if(sm <= em) return (totalMinNy >= sm && totalMinNy < em);
   return (totalMinNy >= sm || totalMinNy < em);
  }

void DrawBox(string name, datetime t1, double p1, datetime t2, double p2, color clr)
  {
   if(ObjectFind(name) < 0)
      ObjectCreate(name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSet(name, OBJPROP_TIME1,  t1);
   ObjectSet(name, OBJPROP_PRICE1, p1);
   ObjectSet(name, OBJPROP_TIME2,  t2);
   ObjectSet(name, OBJPROP_PRICE2, p2);
   ObjectSet(name, OBJPROP_COLOR,  clr);
   ObjectSet(name, OBJPROP_BACK,   true);
   ObjectSet(name, OBJPROP_SELECTABLE, false);
  }

void DrawTrend(string name, datetime t1, double p1, datetime t2, double p2, color clr, int width, int style)
  {
   if(ObjectFind(name) < 0)
      ObjectCreate(name, OBJ_TREND, 0, t1, p1, t2, p2);
   ObjectSet(name, OBJPROP_TIME1, t1);
   ObjectSet(name, OBJPROP_PRICE1, p1);
   ObjectSet(name, OBJPROP_TIME2, t2);
   ObjectSet(name, OBJPROP_PRICE2, p2);
   ObjectSet(name, OBJPROP_COLOR, clr);
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_STYLE, style);
   ObjectSet(name, OBJPROP_RAY,   false);
   ObjectSet(name, OBJPROP_SELECTABLE, false);
  }

void DrawText(string name, datetime t, double p, string txt, color clr, int sz)
  {
   if(ObjectFind(name) < 0)
      ObjectCreate(name, OBJ_TEXT, 0, t, p);
   ObjectSet(name, OBJPROP_TIME1, t);
   ObjectSet(name, OBJPROP_PRICE1, p);
   ObjectSetText(name, txt, sz, "Arial", clr);
   ObjectSet(name, OBJPROP_SELECTABLE, false);
  }

void DeletePrefix(string p)
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string n = ObjectName(i);
      if(StringFind(n, p) == 0) ObjectDelete(n);
     }
  }

void PushOB(double t, double b, int dir, datetime tm)
  {
   int n = ArraySize(g_obTop);
   ArrayResize(g_obTop, n+1); g_obTop[n] = t;
   ArrayResize(g_obBot, n+1); g_obBot[n] = b;
   ArrayResize(g_obDir, n+1); g_obDir[n] = dir;
   ArrayResize(g_obBrk, n+1); g_obBrk[n] = 0;
   ArrayResize(g_obT,   n+1); g_obT[n]   = tm;
   while(ArraySize(g_obTop) > InpMaxOBs)
     {
      string nm = StringConcatenate(PFX_OB, "BOX_", (int)g_obT[0]);
      ObjectDelete(nm);
      ArrayShift(g_obTop); ArrayShift(g_obBot);
      ArrayShiftI(g_obDir);  ArrayShiftI(g_obBrk);
      ArrayShiftDt(g_obT);
     }
  }

void PushFVG(double t, double b, int dir, datetime tm)
  {
   int n = ArraySize(g_fvgTop);
   ArrayResize(g_fvgTop, n+1); g_fvgTop[n] = t;
   ArrayResize(g_fvgBot, n+1); g_fvgBot[n] = b;
   ArrayResize(g_fvgDir, n+1); g_fvgDir[n] = dir;
   ArrayResize(g_fvgT,   n+1); g_fvgT[n]   = tm;
   while(ArraySize(g_fvgTop) > InpMaxFVGs)
     {
      string nm = StringConcatenate(PFX_FVG, "BOX_", (int)g_fvgT[0]);
      ObjectDelete(nm);
      ArrayShift(g_fvgTop); ArrayShift(g_fvgBot);
      ArrayShiftI(g_fvgDir); ArrayShiftDt(g_fvgT);
     }
  }

// MQL4 array shift helpers (no native shift)
void ArrayShift(double &a[])    { for(int i = 0; i < ArraySize(a) - 1; i++) a[i] = a[i+1]; ArrayResize(a, ArraySize(a) - 1); }
void ArrayShiftI(int    &a[])   { for(int i = 0; i < ArraySize(a) - 1; i++) a[i] = a[i+1]; ArrayResize(a, ArraySize(a) - 1); }
void ArrayShiftDt(datetime &a[]){ for(int i = 0; i < ArraySize(a) - 1; i++) a[i] = a[i+1]; ArrayResize(a, ArraySize(a) - 1); }

// ------------------------------ INIT -------------------------------------

int OnInit()
  {
   IndicatorBuffers(10);
   IndicatorShortName("PA SMC ICT (MT4)");

   SetIndexBuffer(0, BufBias);
   SetIndexBuffer(1, BufLastPH);
   SetIndexBuffer(2, BufLastPL);
   SetIndexBuffer(3, BufBullOBTop);
   SetIndexBuffer(4, BufBullOBBot);
   SetIndexBuffer(5, BufBearOBTop);
   SetIndexBuffer(6, BufBearOBBot);
   SetIndexBuffer(7, BufFVGBull);
   SetIndexBuffer(8, BufFVGBear);
   SetIndexBuffer(9, BufSetup);

   for(int i = 0; i < 10; i++)
     {
      SetIndexStyle(i, DRAW_NONE);
      SetIndexEmptyValue(i, 0.0);
     }
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   DeletePrefix(PFX_OB);
   DeletePrefix(PFX_FVG);
   DeletePrefix(PFX_LIQ);
   DeletePrefix(PFX_BG);
   DeletePrefix(PFX_BOS);
  }

// ------------------------------ MAIN -------------------------------------

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total < 50) return 0;

   int counted = prev_calculated;
   if(counted < 0) counted = 0;

   int firstBar = MathMax(rates_total - counted - 1, InpPivotN + 3);
   for(int idx = firstBar; idx >= 0; idx--)
     {
      double atr = iATR(_Symbol, 0, 14, idx);

      // Pivots (use the bar `InpPivotN` ago, fully confirmed)
      int piv = idx + InpPivotN;
      if(piv < Bars - InpPivotN)
        {
         if(IsPivotHighSeries(piv, InpPivotN))
           {
            g_lastPHprev = g_lastPH;
            g_lastPH     = High[piv];
            g_lastPHt    = Time[piv];
           }
         if(IsPivotLowSeries(piv, InpPivotN))
           {
            g_lastPLprev = g_lastPL;
            g_lastPL     = Low[piv];
            g_lastPLt    = Time[piv];
           }
        }

      double cl  = Close[idx];
      double cl1 = Close[idx + 1];

      bool crossUp   = (g_lastPH > 0 && cl > g_lastPH && cl1 <= g_lastPH);
      bool crossDown = (g_lastPL > 0 && cl < g_lastPL && cl1 >= g_lastPL);

      if(crossUp)
        {
         color cc = (g_bias <= 0) ? clrRed : clrLimeGreen;
         string lbl = (g_bias <= 0) ? "CHoCH/up" : "BOS/up";
         string nm  = StringConcatenate(PFX_BOS, "UP_", (int)Time[idx]);
         DrawTrend(nm, Time[idx + 1], g_lastPH, Time[idx], g_lastPH, cc, 1, STYLE_DOT);
         DrawText(nm + "_t", Time[idx], g_lastPH, lbl, cc, 8);
         g_bias = 1;
         g_lastPH = 0;
        }
      if(crossDown)
        {
         color cc = (g_bias >= 0) ? clrRed : clrLimeGreen;
         string lbl = (g_bias >= 0) ? "CHoCH/dn" : "BOS/dn";
         string nm  = StringConcatenate(PFX_BOS, "DN_", (int)Time[idx]);
         DrawTrend(nm, Time[idx + 1], g_lastPL, Time[idx], g_lastPL, cc, 1, STYLE_DOT);
         DrawText(nm + "_t", Time[idx], g_lastPL, lbl, cc, 8);
         g_bias = -1;
         g_lastPL = 0;
        }

      // Order blocks
      bool dispUp   = (cl > High[idx + 1] && cl - Open[idx] > atr * 0.7);
      bool dispDown = (Open[idx] - cl > atr * 0.7 && cl < Low[idx + 1]);

      if(dispUp && Close[idx + 1] < Open[idx + 1])
        {
         double t = High[idx + 1], b = Low[idx + 1];
         PushOB(t, b, +1, Time[idx + 1]);
         string nm = StringConcatenate(PFX_OB, "BOX_", (int)Time[idx + 1]);
         DrawBox(nm, Time[idx + 1], t, Time[idx] + PeriodSeconds() * 20, b, InpColBullOB);
        }
      if(dispDown && Close[idx + 1] > Open[idx + 1])
        {
         double t = High[idx + 1], b = Low[idx + 1];
         PushOB(t, b, -1, Time[idx + 1]);
         string nm = StringConcatenate(PFX_OB, "BOX_", (int)Time[idx + 1]);
         DrawBox(nm, Time[idx + 1], t, Time[idx] + PeriodSeconds() * 20, b, InpColBearOB);
        }

      // Breaker conversion
      for(int k = ArraySize(g_obTop) - 1; k >= 0; k--)
        {
         if(g_obBrk[k] != 0) continue;
         bool brk = (g_obDir[k] > 0 && cl < g_obBot[k]) || (g_obDir[k] < 0 && cl > g_obTop[k]);
         if(brk)
           {
            g_obBrk[k] = 1;
            string nm = StringConcatenate(PFX_OB, "BOX_", (int)g_obT[k]);
            ObjectSet(nm, OBJPROP_COLOR, InpColBreaker);
           }
        }

      // FVGs
      bool fvgB = (Low[idx] > High[idx + 2]);
      bool fvgS = (High[idx] < Low[idx + 2]);

      if(fvgB && (Low[idx] - High[idx + 2]) >= InpFVGMinAtrFrac * atr)
        {
         double t = Low[idx], b = High[idx + 2];
         PushFVG(t, b, +1, Time[idx + 2]);
         string nm = StringConcatenate(PFX_FVG, "BOX_", (int)Time[idx + 2]);
         DrawBox(nm, Time[idx + 2], t, Time[idx] + PeriodSeconds() * 20, b, InpColBullFVG);
         BufFVGBull[idx] = 1.0;
        }
      if(fvgS && (Low[idx + 2] - High[idx]) >= InpFVGMinAtrFrac * atr)
        {
         double t = Low[idx + 2], b = High[idx];
         PushFVG(t, b, -1, Time[idx + 2]);
         string nm = StringConcatenate(PFX_FVG, "BOX_", (int)Time[idx + 2]);
         DrawBox(nm, Time[idx + 2], t, Time[idx] + PeriodSeconds() * 20, b, InpColBearFVG);
         BufFVGBear[idx] = 1.0;
        }

      // Sweep markers
      double tolPx = InpEqTolPips * PipSize();
      bool eqHigh = (g_lastPH > 0 && g_lastPHprev > 0 && MathAbs(g_lastPH - g_lastPHprev) <= tolPx);
      bool eqLow  = (g_lastPL > 0 && g_lastPLprev > 0 && MathAbs(g_lastPL - g_lastPLprev) <= tolPx);

      if(eqHigh)
         DrawTrend(StringConcatenate(PFX_LIQ, "EQH_", (int)g_lastPHt),
                   g_lastPHt, g_lastPH, Time[idx], g_lastPH, InpColLiquidity, 1, STYLE_DASH);
      if(eqLow)
         DrawTrend(StringConcatenate(PFX_LIQ, "EQL_", (int)g_lastPLt),
                   g_lastPLt, g_lastPL, Time[idx], g_lastPL, InpColLiquidity, 1, STYLE_DASH);

      bool swBull = (g_lastPL > 0 && Low[idx] < g_lastPL && Close[idx] > g_lastPL);
      bool swBear = (g_lastPH > 0 && High[idx] > g_lastPH && Close[idx] < g_lastPH);

      if(swBull)
         DrawText(StringConcatenate(PFX_LIQ, "SSL_", (int)Time[idx]),
                  Time[idx], Low[idx] - PipSize() * 2, "SSL", clrRed, 8);
      if(swBear)
         DrawText(StringConcatenate(PFX_LIQ, "BSL_", (int)Time[idx]),
                  Time[idx], High[idx] + PipSize() * 2, "BSL", clrRed, 8);

      // Setup buffer
      int setupCode = PASMC_SETUP_NONE;
      bool inKZ = InNySession(Time[idx], 200, 500)
               || InNySession(Time[idx], 700, 1000)
               || InNySession(Time[idx], 1330, 1600);
      if(swBull && crossUp && inKZ)        setupCode = PASMC_SETUP_S1_LONG;
      else if(swBear && crossDown && inKZ) setupCode = PASMC_SETUP_S1_SHORT;
      else
        {
         for(int k = 0; k < ArraySize(g_obTop); k++)
           {
            if(g_obBrk[k] == 0) continue;
            bool tagged = (High[idx] >= g_obBot[k] && Low[idx] <= g_obTop[k]);
            if(tagged)
              {
               if(g_obDir[k] < 0) { setupCode = PASMC_SETUP_S4_LONG;  break; }
               if(g_obDir[k] > 0) { setupCode = PASMC_SETUP_S4_SHORT; break; }
              }
           }
        }

      BufBias[idx]   = g_bias;
      BufLastPH[idx] = g_lastPH;
      BufLastPL[idx] = g_lastPL;
      BufSetup[idx]  = setupCode;

      if(ArraySize(g_obTop) > 0)
        {
         int last = ArraySize(g_obTop) - 1;
         if(g_obDir[last] > 0)
           {
            BufBullOBTop[idx] = g_obTop[last];
            BufBullOBBot[idx] = g_obBot[last];
           }
         else
           {
            BufBearOBTop[idx] = g_obTop[last];
            BufBearOBBot[idx] = g_obBot[last];
           }
        }

      // Alerts only on the latest bar
      if(idx == 0 && setupCode != PASMC_SETUP_NONE)
        {
         string txt = "PA SMC: setup " + IntegerToString(setupCode) + " on " + _Symbol;
         if(InpUsePopup) Alert(txt);
         if(InpUsePush)  SendNotification(txt);
         if(InpUseEmail) SendMail("PA SMC alert", txt);
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
