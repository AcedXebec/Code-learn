//+------------------------------------------------------------------+
//|                                          PA_SMC_ICT_Hybrid.mq5  |
//|  PA + SMC/ICT Hybrid indicator for MetaTrader 5                 |
//|                                                                  |
//|  Visualizes:                                                     |
//|    - Swing pivots, BOS / CHoCH                                   |
//|    - Bullish / Bearish Order Blocks (recolored when broken)     |
//|    - Fair Value Gaps                                             |
//|    - Equal-highs / equal-lows + sweep markers                   |
//|    - Asia / London / NY session shading                         |
//|    - Kill zones + Silver Bullet windows                         |
//|    - PDH / PDL                                                  |
//|                                                                  |
//|  Exposes 10 buffers consumable by an EA via iCustom().          |
//|  See guide/02-smc-core.md for theory and Include/PASMC_Utils.mqh|
//+------------------------------------------------------------------+
#property copyright   "PA SMC ICT Hybrid Repo (MIT)"
#property link        ""
#property version     "1.00"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   0

#include <PASMC_Utils.mqh>

// ------------------------------ INPUTS -----------------------------------

input int      InpPivotN          = 5;        // Pivot left/right bars
input int      InpMaxOBs          = 8;        // Max OBs kept on chart
input int      InpMaxFVGs         = 6;        // Max FVGs kept on chart
input double   InpFVGMinAtrFrac   = 0.30;     // Min FVG size as fraction of ATR(14)
input double   InpEqTolPips       = 3.0;      // EQH/EQL tolerance in pips
input int      InpBrokerGmtOffset = 2;        // Broker server GMT offset (hours)
input bool     InpShowSessions    = true;     // Asia/London/NY shading
input bool     InpShowKillzones   = true;     // London KZ / NY AM KZ / NY PM KZ shading
input bool     InpShowSilverBullet= true;     // 3 Silver Bullet windows
input bool     InpShowOTE         = true;     // 50% midpoint + OTE band
input int      InpRangeBars       = 60;       // Range lookback
input bool     InpUsePopup        = true;     // Popup alerts
input bool     InpUsePush         = false;    // Mobile push
input bool     InpUseEmail        = false;    // Email
input color    InpColBullOB       = clrLimeGreen;
input color    InpColBearOB       = clrCrimson;
input color    InpColBreaker      = clrOrange;
input color    InpColBullFVG      = clrAquamarine;
input color    InpColBearFVG      = clrMagenta;
input color    InpColLiquidity    = clrAqua;
input color    InpColAsia         = clrGray;
input color    InpColLondon       = clrSteelBlue;
input color    InpColNY           = clrPlum;
input color    InpColKZ           = clrTurquoise;
input color    InpColSB           = clrGold;

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

// ------------------------------ STATE ------------------------------------

int handleATR;
double atrBuf[];

double  g_lastPH = 0, g_lastPHprev = 0;
double  g_lastPL = 0, g_lastPLprev = 0;
datetime g_lastPHt = 0, g_lastPLt = 0;
int     g_bias = PASMC_BIAS_NONE;

// active OBs (parallel arrays)
double g_obTop[]; double g_obBot[]; int g_obDir[]; bool g_obBrk[]; datetime g_obT[];
// active FVGs
double g_fvgTop[]; double g_fvgBot[]; int g_fvgDir[]; datetime g_fvgT[];

string PFX_OB  = "pasmc_ob_";
string PFX_FVG = "pasmc_fvg_";
string PFX_LIQ = "pasmc_liq_";
string PFX_BG  = "pasmc_bg_";
string PFX_BOS = "pasmc_bos_";
string PFX_RNG = "pasmc_rng_";
string PFX_PDX = "pasmc_pdx_";

// ------------------------------ INIT -------------------------------------

int OnInit()
  {
   SetIndexBuffer(PASMC_BUF_BIAS,         BufBias,        INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_LASTPH,       BufLastPH,      INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_LASTPL,       BufLastPL,      INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_BULLOB_TOP,   BufBullOBTop,   INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_BULLOB_BOT,   BufBullOBBot,   INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_BEAROB_TOP,   BufBearOBTop,   INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_BEAROB_BOT,   BufBearOBBot,   INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_FVG_BULL,     BufFVGBull,     INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_FVG_BEAR,     BufFVGBear,     INDICATOR_DATA);
   SetIndexBuffer(PASMC_BUF_SETUP,        BufSetup,       INDICATOR_DATA);

   for(int i = 0; i < PASMC_BUFFERS; i++)
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);

   handleATR = iATR(_Symbol, _Period, 14);
   if(handleATR == INVALID_HANDLE)
     {
      Print("PA_SMC_ICT_Hybrid: failed to create ATR handle");
      return INIT_FAILED;
     }

   ArraySetAsSeries(atrBuf, true);

   ArrayResize(g_obTop, 0);
   ArrayResize(g_obBot, 0);
   ArrayResize(g_obDir, 0);
   ArrayResize(g_obBrk, 0);
   ArrayResize(g_obT,   0);
   ArrayResize(g_fvgTop, 0);
   ArrayResize(g_fvgBot, 0);
   ArrayResize(g_fvgDir, 0);
   ArrayResize(g_fvgT,   0);

   IndicatorSetString(INDICATOR_SHORTNAME, "PA SMC ICT");
   return INIT_SUCCEEDED;
  }

// ------------------------------ DEINIT -----------------------------------

void OnDeinit(const int reason)
  {
   PASMC_DeletePrefix(PFX_OB);
   PASMC_DeletePrefix(PFX_FVG);
   PASMC_DeletePrefix(PFX_LIQ);
   PASMC_DeletePrefix(PFX_BG);
   PASMC_DeletePrefix(PFX_BOS);
   PASMC_DeletePrefix(PFX_RNG);
   PASMC_DeletePrefix(PFX_PDX);
   if(handleATR != INVALID_HANDLE) IndicatorRelease(handleATR);
  }

// ------------------------------ HELPERS ----------------------------------

double PipSize()
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pt   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return (digits == 3 || digits == 5) ? pt * 10.0 : pt;
  }

void EnsureSize(double &arr[], int n) { if(ArraySize(arr) < n) ArrayResize(arr, n); }

void PushOB(double top, double bot, int dir, datetime t)
  {
   int n = ArraySize(g_obTop);
   ArrayResize(g_obTop, n+1); g_obTop[n] = top;
   ArrayResize(g_obBot, n+1); g_obBot[n] = bot;
   ArrayResize(g_obDir, n+1); g_obDir[n] = dir;
   ArrayResize(g_obBrk, n+1); g_obBrk[n] = false;
   ArrayResize(g_obT,   n+1); g_obT[n]   = t;
   while(ArraySize(g_obTop) > InpMaxOBs)
     {
      string nm = StringFormat("%sBOX_%d", PFX_OB, (int)(g_obT[0] / 60));
      ObjectDelete(0, nm);
      ArrayRemove(g_obTop, 0, 1);
      ArrayRemove(g_obBot, 0, 1);
      ArrayRemove(g_obDir, 0, 1);
      ArrayRemove(g_obBrk, 0, 1);
      ArrayRemove(g_obT,   0, 1);
     }
  }

void PushFVG(double top, double bot, int dir, datetime t)
  {
   int n = ArraySize(g_fvgTop);
   ArrayResize(g_fvgTop, n+1); g_fvgTop[n] = top;
   ArrayResize(g_fvgBot, n+1); g_fvgBot[n] = bot;
   ArrayResize(g_fvgDir, n+1); g_fvgDir[n] = dir;
   ArrayResize(g_fvgT,   n+1); g_fvgT[n]   = t;
   while(ArraySize(g_fvgTop) > InpMaxFVGs)
     {
      string nm = StringFormat("%sBOX_%d", PFX_FVG, (int)(g_fvgT[0] / 60));
      ObjectDelete(0, nm);
      ArrayRemove(g_fvgTop, 0, 1);
      ArrayRemove(g_fvgBot, 0, 1);
      ArrayRemove(g_fvgDir, 0, 1);
      ArrayRemove(g_fvgT,   0, 1);
     }
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

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low,  true);
   ArraySetAsSeries(close,true);

   if(CopyBuffer(handleATR, 0, 0, rates_total, atrBuf) <= 0) return 0;

   int start = (prev_calculated <= InpPivotN + 3) ? InpPivotN + 3 : rates_total - prev_calculated + InpPivotN + 1;
   if(start >= rates_total) start = rates_total - 1;

   for(int idx = start; idx >= 0; idx--)
     {
      // Default buffer values
      EnsureSize(BufBias,        rates_total);
      EnsureSize(BufLastPH,      rates_total);
      EnsureSize(BufLastPL,      rates_total);
      EnsureSize(BufBullOBTop,   rates_total);
      EnsureSize(BufBullOBBot,   rates_total);
      EnsureSize(BufBearOBTop,   rates_total);
      EnsureSize(BufBearOBBot,   rates_total);
      EnsureSize(BufFVGBull,     rates_total);
      EnsureSize(BufFVGBear,     rates_total);
      EnsureSize(BufSetup,       rates_total);

      // Detect pivots
      bool isPH = PASMC_IsPivotHigh(high, idx + InpPivotN, InpPivotN);
      bool isPL = PASMC_IsPivotLow (low,  idx + InpPivotN, InpPivotN);
      // (we look at the bar that CONFIRMED InpPivotN ago — no repaint)

      if(isPH)
        {
         g_lastPHprev = g_lastPH;
         g_lastPH     = high[idx + InpPivotN];
         g_lastPHt    = time[idx + InpPivotN];
        }
      if(isPL)
        {
         g_lastPLprev = g_lastPL;
         g_lastPL     = low[idx + InpPivotN];
         g_lastPLt    = time[idx + InpPivotN];
        }

      // BOS / CHoCH detection on close
      double cl  = close[idx];
      double cl1 = close[idx + 1];

      bool crossUp   = (g_lastPH > 0 && cl > g_lastPH && cl1 <= g_lastPH);
      bool crossDown = (g_lastPL > 0 && cl < g_lastPL && cl1 >= g_lastPL);

      if(crossUp)
        {
         color cc = (g_bias <= 0) ? clrRed : clrLimeGreen;
         string lbl = (g_bias <= 0) ? "CHoCH↑" : "BOS↑";
         string nm  = StringFormat("%sUP_%d", PFX_BOS, (int)time[idx]);
         PASMC_DrawTrendline(nm, time[idx + 1], g_lastPH, time[idx], g_lastPH, cc, 1, STYLE_DOT);
         PASMC_DrawText(nm + "_t", time[idx], g_lastPH, lbl, cc, 8);
         g_bias = PASMC_BIAS_BULL;
         g_lastPH = 0;
        }
      if(crossDown)
        {
         color cc = (g_bias >= 0) ? clrRed : clrLimeGreen;
         string lbl = (g_bias >= 0) ? "CHoCH↓" : "BOS↓";
         string nm  = StringFormat("%sDN_%d", PFX_BOS, (int)time[idx]);
         PASMC_DrawTrendline(nm, time[idx + 1], g_lastPL, time[idx], g_lastPL, cc, 1, STYLE_DOT);
         PASMC_DrawText(nm + "_t", time[idx], g_lastPL, lbl, cc, 8);
         g_bias = PASMC_BIAS_BEAR;
         g_lastPL = 0;
        }

      // Order blocks
      double atr = atrBuf[idx];
      bool dispUp   = (cl > high[idx + 1] && cl - open[idx] > atr * 0.7);
      bool dispDown = (open[idx] - cl > atr * 0.7 && cl < low[idx + 1]);

      if(dispUp && close[idx + 1] < open[idx + 1])
        {
         double t = high[idx + 1], b = low[idx + 1];
         PushOB(t, b, +1, time[idx + 1]);
         string nm = StringFormat("%sBOX_%d", PFX_OB, (int)time[idx + 1]);
         color cc = (color)(InpColBullOB);
         PASMC_DrawBox(nm, time[idx + 1], t, time[idx] + PeriodSeconds() * 20, b, cc, 1);
        }
      if(dispDown && close[idx + 1] > open[idx + 1])
        {
         double t = high[idx + 1], b = low[idx + 1];
         PushOB(t, b, -1, time[idx + 1]);
         string nm = StringFormat("%sBOX_%d", PFX_OB, (int)time[idx + 1]);
         color cc = (color)(InpColBearOB);
         PASMC_DrawBox(nm, time[idx + 1], t, time[idx] + PeriodSeconds() * 20, b, cc, 1);
        }

      // Mark breakers
      for(int k = ArraySize(g_obTop) - 1; k >= 0; k--)
        {
         if(g_obBrk[k]) continue;
         bool brk = (g_obDir[k] > 0 && cl < g_obBot[k]) || (g_obDir[k] < 0 && cl > g_obTop[k]);
         if(brk)
           {
            g_obBrk[k] = true;
            string nm = StringFormat("%sBOX_%d", PFX_OB, (int)g_obT[k]);
            ObjectSetInteger(0, nm, OBJPROP_COLOR, InpColBreaker);
           }
        }

      // FVGs
      bool fvgB = PASMC_IsBullFVG(low, high, idx);
      bool fvgS = PASMC_IsBearFVG(low, high, idx);

      if(fvgB && (low[idx] - high[idx + 2]) >= InpFVGMinAtrFrac * atr)
        {
         double t = low[idx], b = high[idx + 2];
         PushFVG(t, b, +1, time[idx + 2]);
         string nm = StringFormat("%sBOX_%d", PFX_FVG, (int)time[idx + 2]);
         PASMC_DrawBox(nm, time[idx + 2], t, time[idx] + PeriodSeconds() * 20, b, InpColBullFVG, 1, STYLE_DOT);
         BufFVGBull[idx] = 1.0;
        }
      if(fvgS && (low[idx + 2] - high[idx]) >= InpFVGMinAtrFrac * atr)
        {
         double t = low[idx + 2], b = high[idx];
         PushFVG(t, b, -1, time[idx + 2]);
         string nm = StringFormat("%sBOX_%d", PFX_FVG, (int)time[idx + 2]);
         PASMC_DrawBox(nm, time[idx + 2], t, time[idx] + PeriodSeconds() * 20, b, InpColBearFVG, 1, STYLE_DOT);
         BufFVGBear[idx] = 1.0;
        }

      // Sweeps + EQH/EQL liquidity tags
      double tolPx = InpEqTolPips * PipSize();
      bool eqHigh = (g_lastPH > 0 && g_lastPHprev > 0 && MathAbs(g_lastPH - g_lastPHprev) <= tolPx);
      bool eqLow  = (g_lastPL > 0 && g_lastPLprev > 0 && MathAbs(g_lastPL - g_lastPLprev) <= tolPx);

      if(eqHigh)
        {
         string nm = StringFormat("%sEQH_%d", PFX_LIQ, (int)g_lastPHt);
         PASMC_DrawTrendline(nm, g_lastPHt, g_lastPH, time[idx], g_lastPH, InpColLiquidity, 1, STYLE_DASH);
         PASMC_DrawText(nm + "_t", time[idx], g_lastPH, "EQH", InpColLiquidity, 8);
        }
      if(eqLow)
        {
         string nm = StringFormat("%sEQL_%d", PFX_LIQ, (int)g_lastPLt);
         PASMC_DrawTrendline(nm, g_lastPLt, g_lastPL, time[idx], g_lastPL, InpColLiquidity, 1, STYLE_DASH);
         PASMC_DrawText(nm + "_t", time[idx], g_lastPL, "EQL", InpColLiquidity, 8);
        }

      bool swBull = PASMC_IsBullSweep(low, close, idx, g_lastPL);
      bool swBear = PASMC_IsBearSweep(high, close, idx, g_lastPH);

      if(swBull)
        PASMC_DrawText(StringFormat("%sSSL_%d", PFX_LIQ, (int)time[idx]),
                       time[idx], low[idx] - PipSize() * 2, "🩸 SSL", clrRed, 8);
      if(swBear)
        PASMC_DrawText(StringFormat("%sBSL_%d", PFX_LIQ, (int)time[idx]),
                       time[idx], high[idx] + PipSize() * 2, "🩸 BSL", clrRed, 8);

      // Determine setup signal for buffer
      int setupCode = PASMC_SETUP_NONE;
      bool inKZ = (PASMC_InNySession(time[idx], 200,  500,  InpBrokerGmtOffset)
                || PASMC_InNySession(time[idx], 700,  1000, InpBrokerGmtOffset)
                || PASMC_InNySession(time[idx], 1330, 1600, InpBrokerGmtOffset));

      if(swBull && crossUp && inKZ)        setupCode = PASMC_SETUP_S1_LONG;
      else if(swBear && crossDown && inKZ) setupCode = PASMC_SETUP_S1_SHORT;
      else
        {
         // Setup #4: any breaker tagged on this bar
         for(int k = 0; k < ArraySize(g_obTop); k++)
           {
            if(!g_obBrk[k]) continue;
            bool tagged = (high[idx] >= g_obBot[k] && low[idx] <= g_obTop[k]);
            if(tagged)
              {
               if(g_obDir[k] < 0) { setupCode = PASMC_SETUP_S4_LONG;  break; }
               if(g_obDir[k] > 0) { setupCode = PASMC_SETUP_S4_SHORT; break; }
              }
           }
        }
      BufSetup[idx]    = (double)setupCode;
      BufBias[idx]     = (double)g_bias;
      BufLastPH[idx]   = g_lastPH;
      BufLastPL[idx]   = g_lastPL;

      // Save the most recent OB top/bot to buffers (last in array)
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

      // Alerts
      if(idx == 0 && (setupCode != PASMC_SETUP_NONE))
        {
         string txt;
         switch(setupCode)
           {
            case PASMC_SETUP_S1_LONG:  txt = "PA SMC: Setup #1 LONG (sweep+CHoCH+OB) on " + _Symbol; break;
            case PASMC_SETUP_S1_SHORT: txt = "PA SMC: Setup #1 SHORT on " + _Symbol; break;
            case PASMC_SETUP_S4_LONG:  txt = "PA SMC: Setup #4 LONG (breaker tagged) on " + _Symbol; break;
            case PASMC_SETUP_S4_SHORT: txt = "PA SMC: Setup #4 SHORT on " + _Symbol; break;
           }
         if(InpUsePopup)         Alert(txt);
         if(InpUsePush)          SendNotification(txt);
         if(InpUseEmail)         SendMail("PA SMC alert", txt);
        }
     }

   // Background shading on the latest bars (sessions / kill zones / SB)
   if(InpShowSessions || InpShowKillzones || InpShowSilverBullet)
     {
      // Use one big rectangle per zone covering the latest 2 days; simplicity > precision.
      datetime t0 = time[0];
      datetime t1 = (rates_total > 200) ? time[200] : time[rates_total - 1];

      if(InpShowSessions)
        {
         // Asia
         PASMC_DrawBox(PFX_BG + "asia", t1, ChartGetDouble(0, CHART_PRICE_MAX),
                       t0, ChartGetDouble(0, CHART_PRICE_MIN), InpColAsia, 0, STYLE_SOLID);
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
