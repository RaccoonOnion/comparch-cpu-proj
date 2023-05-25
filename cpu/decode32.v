`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 18:02:43
// Design Name: 
// Module Name: Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output  [31:0] read_data_1;               // ����ĵ�һ������
    output  [31:0] read_data_2;               // ����ĵڶ�������
    
    input[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
    input[31:0]  mem_data;   				//  ��DATA RAM or I/O portȡ��������
    input[31:0]  ALU_result;   				// ��ִ�е�Ԫ��������Ľ��
    input        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
    input        RegWrite;                  // ���Կ��Ƶ�Ԫ
    input        MemtoReg;              // ���Կ��Ƶ�Ԫ
    input        RegDst;             
    output[31:0] Sign_extend;               // ��չ���32λ������
    input		 clock,reset;                // ʱ�Ӻ͸�λ
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
    
    reg [31:0] Reg[0:31];  
    wire [4:0] rs ;
    wire [4:0] rt ;
    wire [4:0] rd ;
    assign rs=Instruction[25:21];
    assign rt=Instruction[20:16];
    assign rd=Instruction[15:11];
    
//    initial begin
//        for (i = 0; i < 32; i = i+ 1) Reg[i] <= 0;  
//    end
    
    always @(posedge clock,posedge reset) begin
     Reg[0] <= 32'b0;
    
        if(reset) begin
           
         Reg[0]<= 32'h0; 
        Reg[1]<= 32'h0; 
        Reg[2]<= 32'h0; 
        Reg[3]<= 32'h0; 
        Reg[4]<= 32'h0; 
        Reg[5]<= 32'h0; 
        Reg[6]<= 32'h0; 
        Reg[7]<= 32'h0; 
        Reg[8]<= 32'h0; 
        Reg[9]<= 32'h0; 
        Reg[10]<= 32'h0; 
        Reg[11]<= 32'h0; 
        Reg[12]<= 32'h0; 
        Reg[13]<= 32'h0; 
        Reg[14]<= 32'h0; 
        Reg[15]<= 32'h0; 
        Reg[16]<= 32'h0; 
        Reg[17]<= 32'h0; 
        Reg[18]<= 32'h0; 
        Reg[19]<= 32'h0; 
        Reg[20]<= 32'h0; 
        Reg[21]<= 32'h0; 
        Reg[22]<= 32'h0; 
        Reg[23]<= 32'h0; 
        Reg[24]<= 32'h0; 
        Reg[25]<= 32'h0; 
        Reg[26]<= 32'h0; 
        Reg[27]<= 32'h0; 
        Reg[28]<= 32'h0; 
        Reg[29]<= 32'h0; 
        Reg[30]<= 32'h0; 
        Reg[31]<= 32'h0; 
        end
        else if(RegWrite) begin 
          if(Jal)   begin
                      Reg[31] <= opcplus4;
                      
                  end
           else if(MemtoReg) begin
              case(RegDst) 
                1'b0: Reg[rt] <= mem_data;  
                1'b1: Reg[rd] <= mem_data; 
              endcase       
            end
            else begin
                 case(RegDst) 
                    1'b0:  Reg[rt] <= ALU_result;  
                    1'b1:  Reg[rd] <= ALU_result; 
                endcase      
            end
         
           
        end
    end
    
    
     
      assign read_data_1 = Reg[rs];
       assign read_data_2 = Reg[rt];
        
    
   
   
    
    assign Sign_extend =  {(Instruction[31:26]!=6'hb&Instruction[31:26]!=6'hc&Instruction[31:26]!=6'hd&Instruction[31:26]!=6'he) ? (Instruction[15] ? 16'hffff : 16'h0000) : 16'h0000,  Instruction[15:0]};
endmodule
