`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module leds (
    input			ledrst,		// reset, active high (复位信号,高电平有效)
    input			led_clk,	// clk for led (时钟信号)
    input			ledwrite1,	// led write enable, active high (写信号,高电平有效)
     input			ledwrite2,	// led write enable, active high (写信号,高电平有效)
   input			ledwrite3,
    input	[15:0]	ledwdata,	// the data (from register/memorio)  waiting for to be writen to the leds of the board
   output reg  [7:0]	seg_en,
    output  [7:0]	seg_out0,
     output  [7:0]	seg_out1,
     output  reg  [7:0]	seg_out2
);
    reg[15:0] ledout;
    reg[15:0]	ledout1;
     reg[15:0]	ledout2;
   
    always @ (negedge led_clk,posedge ledrst) begin
        if (ledrst)
        begin
            ledout1 <= 15'h0000;
            ledout2 <= 15'h0000;
            seg_out2<=8'h0000;
            end
		//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		else if ( ledwrite1||ledwrite2||ledwrite3) begin
			   if(ledwrite1)
				ledout1 <= ledwdata;
				else if(ledwrite2)
                ledout2 <= ledwdata;
                else if(ledwrite3)
                 seg_out2 <= ledwdata[7:0];
                else
                begin
                ledout1 <= ledout1;
                ledout2 <= ledout2;
                seg_out2<=seg_out2;
                end
        end 
        else begin
            ledout1 <= ledout1;
        end
    end
    
    
    reg clkout;
    
    reg [31:0] ccnt;
    reg [2:0] scan_cnt;
    
    
    parameter period=5;
   
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
       scan_cnt <=3'b00;
       end
       else begin
       if(scan_cnt==3'd7)
        scan_cnt <=3'b00;
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
      
      reg neg;
      reg [7:0] signen;
      reg [3:0] sign;
      
      always @ (negedge led_clk,posedge ledrst) begin
              if (ledrst)
              begin
                  ledout <= 16'h0000;
                  neg <= 1'b0;
                  end
              else begin
                    if (ledout1[15]) begin
                      ledout <= ~ledout1 + 1;
                      neg <= 1'b1;
                    end
                    else begin
                      ledout <= ledout1;
                      neg <= 1'b0;
                    end
              end 
          end
      
      always @(posedge led_clk,posedge ledrst) begin
                  if(ledrst) begin
                    signen <= 8'b0;
                    sign <= 4'b0;
                  end 
                  else
                  begin
                    if(neg)begin
//                       if(bai != 0) signen <= 8'h08;
//                       else if(shi != 0) signen <= 8'h04;
//                       else if(ge != 0) signen <= 8'h02;
//                       else signen <= 8'h00;
                       sign <= 4'hA;
                    end 
                    else sign <= 4'h0;
                  end
       end
            
            reg [3:0] qiann;
            reg [3:0] baii;
            reg [3:0] shii;
            reg [3:0] gee;
            
            always @(posedge led_clk,posedge ledrst)
            
            begin
            if(ledrst) begin
             qiann<=4'b00; baii<=4'b00; shii<=4'b00; gee<=4'b00;
            
             
                 end
                
            else
            begin
            qiann<=ledout2/1000;
           baii<=(ledout2%1000)/100;
           shii<=(ledout2%100)/10;
            gee<=(ledout2%10);
            
            end
            end
      always@(posedge led_clk,posedge ledrst)
      begin
      
      if(ledrst)
      begin
      fo<=4'b00;
      seg_en<=8'h00;
       
       end
       
       
       else
       begin
      
      
      case(scan_cnt)
      
      3'b000: begin seg_en<=8'h01;fo<=ge; end
      3'b001: begin seg_en<=8'h02;fo<=shi;end   
      3'b010: begin seg_en<=8'h04;fo<=bai; end
      3'b011: begin seg_en<=8'h08;fo<= sign; end    //negative sign
        3'b100: begin seg_en<=8'h10;fo<=gee; end
        3'b101: begin seg_en<=8'h20;fo<=shii;end   
        3'b110: begin seg_en<=8'h40;fo<=baii; end
        3'b111: begin seg_en<=8'h80;fo<=qiann; end
      
      endcase
      end
      end
      qiduan s0(led_clk,ledrst,fo,seg_out0);   
        qiduan s1(led_clk,ledrst,fo,seg_out1);   
      
	
endmodule
