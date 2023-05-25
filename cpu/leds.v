`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input			ledrst,		// reset, active high (复位信号,高电平有效)
    input			led_clk,	// clk for led (时钟信号)
    input			ledwrite,	// led write enable, active high (写信号,高电平有效)
    
  
    input	[15:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
   output reg  [3:0]	seg_en,
    output  [7:0]	seg_out0
    
);
  
    reg[15:0]	ledout;
   
    always @ (negedge led_clk,posedge ledrst) begin
        if (ledrst)
            ledout <= 15'h0000;
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		else if ( ledwrite) begin
			
				ledout <= ledwdata;
			
			
        end 
        else begin
            ledout <= ledout;
        end
    end
    
    
    reg clkout;
    
    reg [31:0] ccnt;
    reg [1:0] scan_cnt;
    
    
    parameter period=20000;
   
     always@(posedge led_clk,posedge ledrst )
     begin
      if(ledrst) begin
      ccnt<=0;
      clkout<=0;
     
      end
      else begin
      if(ccnt==(period>>1)-1)
      begin
      clkout<=~clkout;
      ccnt<=0;
      end
      else ccnt<=ccnt+1;
      end
      end
      
      always@(posedge clkout,posedge ledrst)
       begin
       
       if(ledrst) begin
       scan_cnt <=2'b00;
       end
       else begin
       if(scan_cnt==2'd3)
        scan_cnt <=2'b00;
        else
        scan_cnt<= scan_cnt +1;
      end
      end
      
      reg [3:0] fo;
      
      reg [3:0] qian;
      reg [3:0] bai;
      reg [3:0] shi;
      reg [3:0] ge;
      
      always @(posedge led_clk,posedge ledrst)
      
      begin
      if(ledrst) begin
       qian<=4'b00; bai<=4'b00; shi<=4'b00; ge<=4'b00;
      
       
           end
          
      else
      begin
      qian<=ledout/1000;
     bai<=(ledout%1000)/100;
     shi<=(ledout%100)/10;
      ge<=(ledout%10);
      
      end
      end
      
      always@(posedge led_clk,posedge ledrst)
      begin
      
      if(ledrst)
      begin
      fo<=4'b00;
      seg_en<=4'h00;
       
       end
       
       
       else
       begin
      
      
      case(scan_cnt)
      
      2'b00: begin seg_en<=4'h01;fo<=ge; end
      2'b01: begin seg_en<=8'h02;fo<=shi;end   
      2'b10: begin seg_en<=8'h04;fo<=bai; end
      2'b11: begin seg_en<=8'h08;fo<=qian; end
      
      
      endcase
      end
      end
      qiduan s0(led_clk,ledrst,fo,seg_out0);   
      
      
	
endmodule
