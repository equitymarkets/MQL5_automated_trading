//+------------------------------------------------------------------+
//|                                                           EA.mq5 |
//|                                                   laserdesign.io |
//|                                       https://www.laserdesign.io |
//+------------------------------------------------------------------+
#property copyright "laserdesign.io"
#property link      "https://www.laserdesign.io"
#property strict

#include <Trade\Trade.mqh>

CTrade trade;

input group "Trade Settings";

enum randomTimeEntry
  {
   ON = 1,
   OFF = 0
  };

enum stopLosses
  {
   StopsOn = 1,
   StopsOff = 0
  };
  
enum takeProfit
  {
   TakeProfitOn = 1,
   TakeProfitOff = 0
  };
  
enum paperTradeTest
  {
   WeekendPaperTraderOn = 1,
   WeekendPaperTraderOff = 0
  };
  
input int MagicNumber = 12345, StopInPoints = 60, 
TakeProfitInPoints = 60;
input double LotSize = .1;
input int MovingAverage = 21;


input ENUM_MA_METHOD MovingAverageType = MODE_SMA;
input ENUM_TIMEFRAMES Timeframe = 0; 
input randomTimeEntry RandomTimeEntry = 0;
input stopLosses StopLoss = 0;
input takeProfit TakeProfit = 0;
input paperTradeTest PaperTradeTest = 0;

int ma_handle;

void OrderEntry(ENUM_TIMEFRAMES timeframe, bool stop_loss, 
int stop_in_points, bool take_profit, int take_profit_in_points, double lot_size)
  {
   bool entry;
   double stop_price = 0, take_profit_price = 0;
   double ma_array[];
   
   double close_price_1 = (iClose(_Symbol,timeframe,1));
   double close_price_2 = (iClose(_Symbol,timeframe,2));
  
   ArraySetAsSeries(ma_array,true);
   
   double ma_1 = CopyBuffer(ma_handle,0,0,100,ma_array);
   
   static datetime time_to_trade_addition = ((MathRand()/
   3600)*timeframe);
   
   if(close_price_1 > close_price_2 && close_price_1 > ma_array[1] &&
   ma_array[1] > ma_array[2])
     {
      if(stop_loss)
        {
         stop_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (stop_in_points*_Point);
        }
      if(take_profit)
        {
         take_profit_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (take_profit_in_points*_Point);
        }
      
      entry = trade.Buy(lot_size,_Symbol,0,stop_price,take_profit_price,"Buy");
        {
         if(!entry)
           {
            Print("Trade not executed. Reason: ", GetLastError());
           }
         else
           {
            Print("Trade executed."); 
           }
        }
     }
   if(close_price_1 < close_price_2 && close_price_1 < ma_array[1] &&
   ma_array[1] < ma_array[2])
     {
      if(stop_loss)
        {
         stop_price = SymbolInfoDouble(_Symbol, SYMBOL_BID) + (stop_in_points*_Point);
        }
      if(take_profit)
        {
         take_profit_price = SymbolInfoDouble(_Symbol, SYMBOL_BID) - (take_profit_in_points*_Point);
        }

      entry = trade.Sell(lot_size,_Symbol,0,stop_price,take_profit_price,"Sell");
        {
         if(!entry)
           {
            Print("Trade not executed. Reason: ", GetLastError());
           }
         else
           {
            Print("Trade executed.");
           }   
        }
     }
  }

bool OrderExit(ENUM_TIMEFRAMES timeframe, int moving_average, 
ENUM_MA_METHOD moving_average_type,int magic_number)
     {
      bool exit;
      double ma_array[];
   
      ArraySetAsSeries(ma_array,true);
   
      double ma_1 = CopyBuffer(ma_handle,0,0,100,ma_array);
      
      for(int i = PositionsTotal()-1; i>=0; i--)
        {
         if(PositionGetTicket(i))
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               if(_Symbol==PositionGetSymbol(i))
                 {
                  if(PositionGetInteger(POSITION_MAGIC) == magic_number)
                    {
                     if(iClose(_Symbol,0,1) < ma_array[1])
                       {
                        exit = trade.PositionClose(PositionGetTicket(i));
                          {
                           if(!exit)
                             {
                              Print("Trade not executed. Reason: ", 
                              GetLastError());
                             }
                           else
                             {
                              if(PositionGetDouble(POSITION_PROFIT) > 0)
                                {
                                 return true;
                                }
                              Print("Trade executed.");
                             }
                          }
                       }
                    }
                 }
              }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               if(_Symbol==PositionGetSymbol(i))
                 {
                  if(PositionGetInteger(POSITION_MAGIC) == magic_number)
                    {
                     if(iClose(_Symbol,0,1) > ma_array[1])
                       {
                        exit = trade.PositionClose(PositionGetTicket(i));
                          {
                           if(!exit)
                             {
                              Print("Trade not executed. Reason: ",GetLastError());
                             }
                           else
                             {
                              if(PositionGetDouble(POSITION_PROFIT) > 0)
                                {
                                 return true;
                                }
                              Print("Trade executed.");
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
      return false;
     }

bool PaperTradeTester(ENUM_TIMEFRAMES timeframe,
int moving_average,int moving_average_type)
  {  
  
   double ma_array[];
   
   ArraySetAsSeries(ma_array,true);
   
   double ma_1 = CopyBuffer(ma_handle,0,0,100,ma_array);

   double close_price_1 = (iClose(_Symbol,timeframe,1));
   double close_price_2 = (iClose(_Symbol,timeframe,2));

   static bool paper_buy = false;
   static bool paper_sell = false;
   static double paper_buy_price, paper_sell_price;
     
   if(paper_buy == false) 
     {
      if(close_price_1 > close_price_2 && ma_array[1] >= ma_array[2] && close_price_1 >= ma_array[1]) 
        {
         paper_buy = true;
         paper_buy_price = close_price_1;
        }
     }
   if(paper_buy == true) 
     {
      if(close_price_1 < ma_array[1])
        {
         paper_buy = false;
         if(close_price_1 > paper_buy_price)
           {
            return true;
           }
        }
     }
   
   if(paper_sell == false) 
     {
      if(close_price_1 < close_price_2 && ma_array[1] <= ma_array[2] && close_price_1 <= ma_array[1]) 
        {
         paper_sell = true;
         if(paper_sell == true) 
           {
            paper_sell_price = close_price_1;
           }
        }
     }
     
   if(paper_sell == true) 
     {
      if(close_price_1 > ma_array[1])
        {
         paper_sell = false;
         if(close_price_1 < paper_sell_price)
           {
            return true;
           }
        }
     }
   return false;
  }
       
void OnInit()
  {
   Alert( ma_handle);
   Comment(ma_handle);
   Print(ma_handle);
   PrintFormat("the value is %d", ma_handle);
   
   Sleep(30000);
   
   trade.SetExpertMagicNumber(MagicNumber);
   ma_handle = iMA(_Symbol,Timeframe,MovingAverage,0,MovingAverageType,PRICE_CLOSE);
  }
   
void OnTick()
  {
   int timeframe = PeriodSeconds(Timeframe)/60;
   
   static bool trade_allowed = false;
   static datetime time_to_trade_addition = ((MathRand()/3600)*timeframe);
   
   if(iTime(Symbol(),Timeframe,0) - iTime(Symbol(),Timeframe,1) > 25200) 
     {
      trade_allowed = false;
     }
     
   if(PaperTradeTest==1)
     {
      if(trade_allowed == false)
        {
         bool paper_test = PaperTradeTester(Timeframe,MovingAverage,MovingAverageType);
         if(paper_test==true)
           {
            trade_allowed=true;
           }
        }
     }
   
   if(PositionsTotal()==0)
     {
      if(PaperTradeTest==0 || trade_allowed)
        {
         if(RandomTimeEntry==0 || TimeCurrent() > (iTime(_Symbol,Timeframe,0) + time_to_trade_addition))
           {
            OrderEntry(Timeframe, StopLoss, StopInPoints, TakeProfit, TakeProfitInPoints, LotSize);
           }
        }
     }
   else
     {
      bool profitable_exit = OrderExit(Timeframe,MovingAverage,MovingAverageType,MagicNumber);
      if(profitable_exit) 
        { 
         trade_allowed=true;
         time_to_trade_addition = ((MathRand()/3600)*timeframe);
        }
     }
  }
//+------------------------------------------------------------------+