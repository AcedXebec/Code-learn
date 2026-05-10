//+------------------------------------------------------------------+
//|                                              PA_SMC_ICT_EA.mq5  |
//|  Semi-automated EA — reads PA_SMC_ICT_Hybrid indicator buffers  |
//|  via iCustom() and trades setups #1 and #4 with risk-% sizing.  |
//|                                                                  |
//|  IMPORTANT: this is a stub for educational use. Test on demo for|
//|  at least one month before going live.                          |
//+------------------------------------------------------------------+
#property copyright "PA SMC ICT Hybrid Repo (MIT)"
#property version   "1.00"
#property strict

#include <PASMC_Utils.mqh>
#include <Trade\Trade.mqh>

input double InpRiskPct          = 0.5;     // Risk per trade (%)
input double InpRRTP1            = 1.5;     // TP1 R-multiple
input double InpRRTP2            = 3.0;     // TP2 R-multiple
input double InpTP1Frac          = 0.5;     // Fraction off at TP1
input double InpSlBufferAtrFrac  = 1.0;     // SL buffer (× ATR14)
input bool   InpAllowS1          = true;    // Allow setup #1
input bool   InpAllowS4          = true;    // Allow setup #4
input bool   InpOnlyKillzones    = true;    // Trade only inside kill zones
input int    InpBrokerGmtOffset  = 2;       // Broker server GMT offset (h)
input ulong  InpMagic            = 770401;
input string InpIndicatorName    = "PA_SMC_ICT_Hybrid";

CTrade trade;
int    hPasmc = INVALID_HANDLE;
int    hAtr   = INVALID_HANDLE;
double atrBuf[];
double bufSetup[], bufBullOBTop[], bufBullOBBot[], bufBearOBTop[], bufBearOBBot[];

datetime lastBarTime = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(InpMagic);
   trade.SetMarginMode();
   trade.SetTypeFilling(ORDER_FILLING_IOC);

   hPasmc = iCustom(_Symbol, _Period, InpIndicatorName);
   if(hPasmc == INVALID_HANDLE)
     {
      Print("EA: failed to load indicator ", InpIndicatorName);
      return INIT_FAILED;
     }
   hAtr = iATR(_Symbol, _Period, 14);
   if(hAtr == INVALID_HANDLE) return INIT_FAILED;

   ArraySetAsSeries(atrBuf,        true);
   ArraySetAsSeries(bufSetup,      true);
   ArraySetAsSeries(bufBullOBTop,  true);
   ArraySetAsSeries(bufBullOBBot,  true);
   ArraySetAsSeries(bufBearOBTop,  true);
   ArraySetAsSeries(bufBearOBBot,  true);
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(hPasmc != INVALID_HANDLE) IndicatorRelease(hPasmc);
   if(hAtr   != INVALID_HANDLE) IndicatorRelease(hAtr);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   datetime t0 = iTime(_Symbol, _Period, 0);
   if(t0 == lastBarTime) return; // bar-close trader
   lastBarTime = t0;

   if(CopyBuffer(hAtr, 0, 0, 5, atrBuf) <= 0) return;

   if(CopyBuffer(hPasmc, PASMC_BUF_SETUP,      0, 5, bufSetup)      <= 0) return;
   if(CopyBuffer(hPasmc, PASMC_BUF_BULLOB_TOP, 0, 5, bufBullOBTop)  <= 0) return;
   if(CopyBuffer(hPasmc, PASMC_BUF_BULLOB_BOT, 0, 5, bufBullOBBot)  <= 0) return;
   if(CopyBuffer(hPasmc, PASMC_BUF_BEAROB_TOP, 0, 5, bufBearOBTop)  <= 0) return;
   if(CopyBuffer(hPasmc, PASMC_BUF_BEAROB_BOT, 0, 5, bufBearOBBot)  <= 0) return;

   // bar 1 = previous closed bar — read setup signal there
   int setupCode = (int)bufSetup[1];
   if(setupCode == PASMC_SETUP_NONE) return;

   if(InpOnlyKillzones)
     {
      datetime tBar = iTime(_Symbol, _Period, 1);
      bool inKZ = PASMC_InNySession(tBar, 200,  500,  InpBrokerGmtOffset)
               || PASMC_InNySession(tBar, 700,  1000, InpBrokerGmtOffset)
               || PASMC_InNySession(tBar, 1330, 1600, InpBrokerGmtOffset);
      if(!inKZ) return;
     }

   if(PositionsTotalForMagic() > 0) return; // one trade at a time

   double atr = atrBuf[1];
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pt  = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   double slBuffer = atr * InpSlBufferAtrFrac;

   if((setupCode == PASMC_SETUP_S1_LONG || setupCode == PASMC_SETUP_S4_LONG) && InpAllowS1 && setupCode == PASMC_SETUP_S1_LONG ||
       setupCode == PASMC_SETUP_S4_LONG && InpAllowS4)
     {
      double obBot = (setupCode == PASMC_SETUP_S1_LONG) ? bufBullOBBot[1] : bufBearOBBot[1];
      double sl = obBot - slBuffer;
      if(sl >= ask) return;
      double risk = ask - sl;
      double tp1 = ask + risk * InpRRTP1;
      double tp2 = ask + risk * InpRRTP2;
      double slPoints = risk / pt;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

      double lots = PASMC_LotForRisk(AccountInfoDouble(ACCOUNT_EQUITY),
                                     InpRiskPct, slPoints, tickValue, minLot, lotStep);
      if(lots <= 0) return;
      // Split into 2 orders — TP1 chunk and TP2 chunk
      double lots1 = NormalizeDouble(lots * InpTP1Frac, 2);
      double lots2 = NormalizeDouble(lots - lots1,        2);
      if(lots1 >= minLot) trade.Buy(lots1, _Symbol, ask, sl, tp1, "PASMC L tp1");
      if(lots2 >= minLot) trade.Buy(lots2, _Symbol, ask, sl, tp2, "PASMC L tp2");
     }
   if((setupCode == PASMC_SETUP_S1_SHORT || setupCode == PASMC_SETUP_S4_SHORT) && InpAllowS1 && setupCode == PASMC_SETUP_S1_SHORT ||
       setupCode == PASMC_SETUP_S4_SHORT && InpAllowS4)
     {
      double obTop = (setupCode == PASMC_SETUP_S1_SHORT) ? bufBearOBTop[1] : bufBullOBTop[1];
      double sl = obTop + slBuffer;
      if(sl <= bid) return;
      double risk = sl - bid;
      double tp1 = bid - risk * InpRRTP1;
      double tp2 = bid - risk * InpRRTP2;
      double slPoints = risk / pt;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

      double lots = PASMC_LotForRisk(AccountInfoDouble(ACCOUNT_EQUITY),
                                     InpRiskPct, slPoints, tickValue, minLot, lotStep);
      if(lots <= 0) return;
      double lots1 = NormalizeDouble(lots * InpTP1Frac, 2);
      double lots2 = NormalizeDouble(lots - lots1,        2);
      if(lots1 >= minLot) trade.Sell(lots1, _Symbol, bid, sl, tp1, "PASMC S tp1");
      if(lots2 >= minLot) trade.Sell(lots2, _Symbol, bid, sl, tp2, "PASMC S tp2");
     }
  }

//+------------------------------------------------------------------+
int PositionsTotalForMagic()
  {
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol)
         n++;
     }
   return n;
  }
//+------------------------------------------------------------------+
