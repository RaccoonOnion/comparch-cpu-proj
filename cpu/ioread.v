`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ioread (reset,ior,ioread_data_switch,ioread_data);
 input			reset;				// reset, active high 复位信号 (高电平有效)
	input			ior;				// from Controller, 1 means read from input device(从控制器来的I/O读)
   
    input	[3:0]	ioread_data_switch;	// the data from switch(从外设来的读数据，此处来自拨码开关)
    output	reg [3:0]	ioread_data; 		// the data to memorio (将外设来的数据送给memorio)   
    
    
    always @* begin
        if (reset)
            ioread_data = 4'h0;
        else if (ior) begin
           
                ioread_data = ioread_data_switch;
                end
            else
				ioread_data = ioread_data;
        end

	
endmodule
