`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ioread (reset,ior,ioread_data_switch,ioread_data);
 input			reset;				// reset, active high ��λ�ź� (�ߵ�ƽ��Ч)
	input			ior;				// from Controller, 1 means read from input device(�ӿ���������I/O��)
   
    input	[3:0]	ioread_data_switch;	// the data from switch(���������Ķ����ݣ��˴����Բ��뿪��)
    output	reg [3:0]	ioread_data; 		// the data to memorio (���������������͸�memorio)   
    
    
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
