//+------------------------------------------------------------------+
//|                                              PA_SMC_ICT_EA.mq4  |
//|  MT4 semi-automated EA — reads PA_SMC_ICT_Hybrid.mq4 buffers    |
//|  via iCustom() and trades setups #1 and #4 with risk-% sizing.  |
//+------------------------------------------------------------------+
#property copyright "PA SMC ICT Hybrid Repo (MIT)"
#property version   "1.00"
#property strict

#define PASMC_BUF_SETUP        9
#define PASMC_BUF_BULLOB_TOP   3
#define PASMC_BUF_BULLOB_BOT   4
#define PASMC_BUF_BEAROB_TOP   5
#define PASMC_BUF_BEAROB_BOT   6

#define PASMC_SETUP_NONE       0
#define PASMC_SETUP_S1_LONG    1
#define PASMC_SETUP_S1_SHORT   2
#define PASMC_SETUP_S4_LONG    4
#define PASMC_SETUP_S4_SHORT   5

extern double InpRiskPct          = 0.5;
extern double InpRRTP1            = 1.5;
extern double InpRRTP2            = 3.0;
extern double InpTP1Frac          = 0.5;
extern double InpSlBufferAtrFrac  = 1.0;
extern bool   InpAllowS1          = true;
extern bool   InpAllowS4          = true;
extern bool   InpOnlyKillzones    = true;
extern int    InpBrokerGmtOffset  = 2;
extern int    InpMagic            = 770401;
extern string InpIndicatorName    = "PA_SMC_ICT_Hybrid";
extern int    InpSlippage         = 3;

datetime lastBarTime = 0;

double PipSize()
  {
   int dg = (int)MarketInfo(_Symbol, MODE_DIGITS);
   double pt = MarketInfo(_Symbol, MODE_POINT);
   return (dg == 3 || dg == 5) ? pt * 10.0 : pt;
  }

bool InNySession(datetime dt, int sHHMM, int eHHMM)
  {
   int totalMinBroker = TimeHour(dt)*60 + TimeMinute(dt);
   int ny = totalMinBroker - InpBrokerGmtOffset*60 - 300;
   while(ny < 0) ny += 1440;
   while(ny >= 1440) ny -= 1440;
   int sm = (sHHMM/100)*60 + (sHHMM%100);
   int em = (eHHMM/100)*60 + (eHHMM%100);
   if(sm <= em) return (ny >= sm && ny < em);
   return (ny >= sm || ny < em);
  }

double LotForRisk(double slPoints)
  {
   if(slPoints <= 0) return 0.0;
   double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
   double minLot    = MarketInfo(_Symbol, MODE_MINLOT);
   double lotStep   = MarketInfo(_Symbol, MODE_LOTSTEP);
   double riskCash  = AccountEquity() * (InpRiskPct/100.0);
   double oneLotRisk = slPoints * tickValue;
   if(oneLotRisk <= 0) return 0.0;
   double lots = riskCash / oneLotRisk;
   lots = MathFloor(lots/lotStep) * lotStep;
   return MathMax(minLot, lots);
  }

int CountOpenForMagic()
  {
   int n = 0;
   for(int i = 0; i < OrdersTotal(); i++)
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() == InpMagic && OrderSymbol() == _Symbol) n++;
   return n;
  }

int OnInit()  { return INIT_SUCCEEDED; }
void OnDeinit(const int reason) {}

void OnTick()
  {
   datetime t0 = iTime(_Symbol, 0, 0);
   if(t0 == lastBarTime) return;
   lastBarTime = t0;

   double setupVal = iCustom(_Symbol, 0, InpIndicatorName, PASMC_BUF_SETUP, 1);
   if(setupVal == EMPTY_VALUE) return;
   int setup = (int)setupVal;
   if(setup == PASMC_SETUP_NONE) return;

   if(InpOnlyKillzones)
     {
      datetime tBar = iTime(_Symbol, 0, 1);
      bool inKZ = InNySession(tBar, 200, 500)
               || InNySession(tBar, 700, 1000)
               || InNySession(tBar, 1330, 1600);
      if(!inKZ) return;
     }

   if(CountOpenForMagic() > 0) return;

   double atr = iATR(_Symbol, 0, 14, 1);
   double slBuffer = atr * InpSlBufferAtrFrac;
   double pt = MarketInfo(_Symbol, MODE_POINT);

   double bullOBBot = iCustom(_Symbol, 0, InpIndicatorName, PASMC_BUF_BULLOB_BOT, 1);
   double bullOBTop = iCustom(_Symbol, 0, InpIndicatorName, PASMC_BUF_BULLOB_TOP, 1);
   double bearOBTop = iCustom(_Symbol, 0, InpIndicatorName, PASMC_BUF_BEAROB_TOP, 1);
   double bearOBBot = iCustom(_Symbol, 0, InpIndicatorName, PASMC_BUF_BEAROB_BOT, 1);

   double ask = MarketInfo(_Symbol, MODE_ASK);
   double bid = MarketInfo(_Symbol, MODE_BID);

   bool isLong  = (setup == PASMC_SETUP_S1_LONG)  || (setup == PASMC_SETUP_S4_LONG);
   bool isShort = (setup == PASMC_SETUP_S1_SHORT) || (setup == PASMC_SETUP_S4_SHORT);

   if((!InpAllowS1) && (setup == PASMC_SETUP_S1_LONG || setup == PASMC_SETUP_S1_SHORT)) return;
   if((!InpAllowS4) && (setup == PASMC_SETUP_S4_LONG || setup == PASMC_SETUP_S4_SHORT)) return;

   if(isLong)
     {
      double obBot = (setup == PASMC_SETUP_S1_LONG) ? bullOBBot : bearOBBot;
      if(obBot == 0 || obBot == EMPTY_VALUE) return;
      double sl = obBot - slBuffer;
      if(sl >= ask) return;
      double risk = ask - sl;
      double tp1 = ask + risk * InpRRTP1;
      double tp2 = ask + risk * InpRRTP2;
      double slPoints = risk / pt;
      double lots = LotForRisk(slPoints);
      double lots1 = NormalizeDouble(lots * InpTP1Frac, 2);
      double lots2 = NormalizeDouble(lots - lots1, 2);
      double minLot = MarketInfo(_Symbol, MODE_MINLOT);
      if(lots1 >= minLot)
         OrderSend(_Symbol, OP_BUY, lots1, ask, InpSlippage, sl, tp1, "PASMC L tp1", InpMagic, 0, clrLime);
      if(lots2 >= minLot)
         OrderSend(_Symbol, OP_BUY, lots2, ask, InpSlippage, sl, tp2, "PASMC L tp2", InpMagic, 0, clrLime);
     }
   if(isShort)
     {
      double obTop = (setup == PASMC_SETUP_S1_SHORT) ? bearOBTop : bullOBTop;
      if(obTop == 0 || obTop == EMPTY_VALUE) return;
      double sl = obTop + slBuffer;
      if(sl <= bid) return;
      double risk = sl - bid;
      double tp1 = bid - risk * InpRRTP1;
      double tp2 = bid - risk * InpRRTP2;
      double slPoints = risk / pt;
      double lots = LotForRisk(slPoints);
      double lots1 = NormalizeDouble(lots * InpTP1Frac, 2);
      double lots2 = NormalizeDouble(lots - lots1, 2);
      double minLot = MarketInfo(_Symbol, MODE_MINLOT);
      if(lots1 >= minLot)
         OrderSend(_Symbol, OP_SELL, lots1, bid, InpSlippage, sl, tp1, "PASMC S tp1", InpMagic, 0, clrRed);
      if(lots2 >= minLot)
         OrderSend(_Symbol, OP_SELL, lots2, bid, InpSlippage, sl, tp2, "PASMC S tp2", InpMagic, 0, clrRed);
     }
  }
//+------------------------------------------------------------------+
