//+------------------------------------------------------------------+
//|                                                crossover_v_1.mq5 |
//|                                                by laserdesign.io |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>

CTrade trade1;
CTrade trade2;

COrderInfo orderInfo;

input double lot = 1.0;
input bool take_profits = false;
input ENUM_TIMEFRAMES low_timeframe = 1;              //Low Timeframe
input ENUM_TIMEFRAMES high_timeframe = 2;             //High Timeframe
input int fast_period = 5;                            //Fast Moving Average
input int slow_period = 13;                           //Slow Moving Average 
input int low_take_profit_points = 5;                 //Take Profit Points, Low Bar
input int high_take_profit_points = 5;                //Take Profit Points, High Bar
input bool low_trader = true;                         //Turn on low timeframe EA
input bool high_trader = true;                        //Turn on high timeframe EA

int fast_ma_handle_low,slow_ma_handle_low,fast_ma_handle_high,slow_ma_handle_high;

int OnInit()
  {
   fast_ma_handle_low = iMA(_Symbol,low_timeframe,fast_period,0,MODE_EMA,PRICE_CLOSE);
   slow_ma_handle_low = iMA(_Symbol,low_timeframe,slow_period,0,MODE_EMA,PRICE_CLOSE);
   fast_ma_handle_high = iMA(_Symbol,high_timeframe,fast_period,0,MODE_EMA,PRICE_CLOSE);
   slow_ma_handle_high = iMA(_Symbol,high_timeframe,slow_period,0,MODE_EMA,PRICE_CLOSE);

   return(INIT_SUCCEEDED);
  }

void OnTick()
  {
   static bool up_trade_low = false;
   static bool down_trade_low = false;
   static bool up_trade_high = false;
   static bool down_trade_high = false;
   
   if(PositionsTotal()==0)
     {
      up_trade_low = false;
      down_trade_low = false;
      up_trade_high = false;
      down_trade_high = false;
     }
     
   if((PositionsTotal()==1 && up_trade_low == true) || (PositionsTotal()==1 && down_trade_low == true))
     {
      up_trade_high = false;
      down_trade_high = false;
     } 
      
   if((PositionsTotal()==1 && up_trade_high == true) || (PositionsTotal()==1 && down_trade_high == true))
     {
      up_trade_low = false;
      down_trade_low = false;
     } 
     
   string note;
   
   ulong magic1 = 10123;
   ulong magic2 = 21624;  
   
   
   double fast_ma_low_array[],slow_ma_low_array[],fast_ma_high_array[],slow_ma_high_array[];
   
   ArraySetAsSeries(fast_ma_low_array,true);
   ArraySetAsSeries(slow_ma_low_array,true);
   ArraySetAsSeries(fast_ma_high_array,true);
   ArraySetAsSeries(slow_ma_high_array,true);
   
   double fast_ma_low = CopyBuffer(fast_ma_handle_low,0,0,100,fast_ma_low_array);
   double slow_ma_low = CopyBuffer(slow_ma_handle_low,0,0,100,slow_ma_low_array);
   double fast_ma_high = CopyBuffer(fast_ma_handle_high,0,0,100,fast_ma_high_array);
   double slow_ma_high = CopyBuffer(slow_ma_handle_high,0,0,100,slow_ma_high_array);
   
//--------EXIT-----------------------------------------------------------------------------------------------------------------------------//    
   //POSITION 1
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong pos_ticket1 = PositionGetTicket(i);
      if(PositionSelectByTicket(pos_ticket1))
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic1)
            {
             if(fast_ma_low_array[1] < slow_ma_low_array[1])
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  bool close1 = trade1.PositionClose(pos_ticket1);
                  if(close1)
                    {
                     up_trade_low = false;
                    }
                 }
              }
            if(fast_ma_low_array[1] > slow_ma_low_array[1])
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  bool close1 = trade1.PositionClose(pos_ticket1);
                  if(close1)
                    {
                     down_trade_low = false;
                    }
                 }
              }
           }
        }
     }
   //POSITION 2
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong pos_ticket2 = PositionGetTicket(i);
      if(PositionSelectByTicket(pos_ticket2))
        {
         if(PositionGetInteger(POSITION_MAGIC) == magic2)
           {
            if(fast_ma_high_array[1] < slow_ma_high_array[1] || fast_ma_low_array[1] < slow_ma_low_array[1])
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  bool close2 = trade2.PositionClose(pos_ticket2);
                  if(close2)
                    {
                     up_trade_high = false;
                    }
                 }
              }
            if(fast_ma_high_array[1] > slow_ma_high_array[1] || fast_ma_low_array[1] > slow_ma_low_array[1])
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  bool close2 = trade2.PositionClose(pos_ticket2);
                  if(close2)
                    {
                     down_trade_high = false;
                    }
                 }
              }
           }
        }
     }

   
   
   
     
//------ENTRY-----------------------------------------------------------------------------------------------------------------------------------//       
   //POSITION 1
   if(low_trader)
     {
      if(fast_ma_low_array[1] > slow_ma_low_array[1] && fast_ma_low_array[2] < slow_ma_low_array[2])
        {
         note = "Bullish ma cross on low bar!";
         SendNotification(note);
         if(!up_trade_low)
           {
            double take_profit_trade = 0;
            trade1.SetExpertMagicNumber(magic1);
            if(take_profits)
              {
               take_profit_trade = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (low_take_profit_points); //*_Point*100);
              }
            bool buy_trade_low = trade1.Buy(lot,_Symbol,0,0,take_profit_trade,"Buy");
            if(buy_trade_low)
              {
               up_trade_low = true;
              }
           }
        }
        
      if(fast_ma_low_array[1] < slow_ma_low_array[1] && fast_ma_low_array[2] > slow_ma_low_array[2])
        {
         note = "Bearish ma cross on low bar!";
         SendNotification(note);
         if(!down_trade_low)
           {
            double take_profit_trade = 0;
            trade1.SetExpertMagicNumber(magic1);
            if(take_profits)
              {
               take_profit_trade = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (low_take_profit_points); //*_Point*100);
              }
            bool sell_trade_low = trade1.Sell(lot,_Symbol,0,0,take_profit_trade,"Sell");
            if(sell_trade_low)
              {
               down_trade_low = true;
              }
           }
        }
     }
   
   //POSITION 2
   if(high_trader)
     {
      if(fast_ma_high_array[1] > slow_ma_high_array[1] && fast_ma_high_array[2] < slow_ma_high_array[2] && fast_ma_low_array[1] > slow_ma_low_array[1])
        {
         note = "Bullish ma cross on high bar!";
         SendNotification(note);
         if(!up_trade_high)
           {
            double take_profit_trade = 0;
            trade2.SetExpertMagicNumber(magic2);
            if(take_profits)
              {
               take_profit_trade = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (high_take_profit_points); //*_Point*100);
              }
            bool buy_trade_high = trade2.Buy(lot,_Symbol,0,0,take_profit_trade,"Buy");
            if(buy_trade_high)
              {
               up_trade_high = true;
              }
           }
        }
   
      if(fast_ma_high_array[1] < slow_ma_high_array[1] && fast_ma_high_array[2] > slow_ma_high_array[2] && fast_ma_low_array[1] < slow_ma_low_array[1])
        {
         note = "Bearish fast ma cross on low bar!";
         SendNotification(note);
         if(!down_trade_high)
           {
            double take_profit_trade = 0;
            trade2.SetExpertMagicNumber(magic2);
            if(take_profits)
              {
               take_profit_trade = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (high_take_profit_points); //*_Point*100);
              }
            bool sell_trade_high = trade2.Sell(lot,_Symbol,0,0,take_profit_trade,"Sell");
            if(sell_trade_high)
              {
               down_trade_high = true;
              }
           }
        }
     }
  }