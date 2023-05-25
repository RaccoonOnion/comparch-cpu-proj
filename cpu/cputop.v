`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 16:26:02
// Design Name: 
// Module Name: cputop
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


module cputop( clock,reset, ioread_data_switch,seg_en,seg_out0);
input clock;
wire clkcpu;
cpuclk cpucl(.clk_out1(clkcpu),.clk_in1(clock));
input reset;
wire [31:0] Instruction; // the instruction fetched from this module to Decoder and Controller
//wire[31:0]  Read_data_1;		// 从译码单元的Read_data_1中来
   //wire[31:0]  Read_data_2;		// 从译码单元的Read_data_2中来
   // wire[31:0]  Sign_extend;		// 从译码单元来的扩展后的立即数
 //  wire[5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
   //wire[5:0]   Exe_opcode;  		// 取指单元来的操作码
  //  wire[1:0]   ALUOp;             // 来自控制单元的运算指令控制编码
   wire[4:0]   Shamt;             // 来自取指单元的instruction[10:6]，指定移位次数
   assign Shamt= Instruction[10:6];
  
   
  //  wire 		 Sftmd;            // 来自控制单元的，表明是移位指令
   // wire        ALUSrc;            // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
  //  wire        I_format;          // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
   // wire        Jr;               // 来自控制单元，表明是JR指令
    wire       Zero;              // 为1表明计算值为0 
    wire[31:0] ALU_Result;        // 计算的数据结果
    wire[31:0] Addr_Result;		// 计算的地址结果        
   // wire[31:0]  PC_plus_4;         // 来自取指单元的PC+4


wire  [31:0] branch_base_addr; // (pc+4) to ALU which is used by branch type instruction
wire [31:0] link_addr; // (pc+4) to Decoder which is used by jal instruction
//from CPU TOP

// from ALU

//wire[31:0] Addr_result; // the calculated address from ALU

//wire Zero; // while Zero is 1, it means the ALUresult is zero
// from Decoder
wire[31:0] Read_data_ra; // the address of instruction used by jr instruction



// from Controller
//wire Branch; // while Branch is 1,it means current instruction is beq
// nBranch; // while nBranch is 1,it means current instruction is bnq
// Jmp; // while Jmp 1, it means current instruction is jump
//wire Jal; // while Jal is 1, it means current instruction is jal
//wire Jr; // while Jr is 1, it means current instruction is j
 wire[31:0] read_data_1;               // 输出的第一操作数
   wire[31:0] read_data_2;               // 输出的第二操作数
  
   //wire[31:0]  Instruction;               // 取指单元来的指令
 // wire[31:0]  mem_data;                   //  从DATA RAM or I/O port取出的数据
   //wire[31:0]  ALU_result;                   // 从执行单元来的运算的结果
  // wire        Jal;                       //  来自控制单元，说明是JAL指令 
   //wire      RegWrite;                  // 来自控制单元
  //wire        MemtoReg;              // 来自控制单元
  //wire       RegDst;             
   wire[31:0] Sign_extend;               // 扩展后的32位立即数
                
  wire[31:0]  opcplus4;                 // 来自取指单元，JAL中用
  assign opcplus4=link_addr;
  
wire [5:0]   Opcode;            // 来自IFetch模块的指令高6bit
 
  assign Opcode=Instruction[31:26];
 
      wire [5:0]   Function_opcode;      // 来自IFetch模块的指令低6bit，用于区分r-类型中的指令
   
      assign  Function_opcode=Instruction[5:0];
    
      wire[15:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
      assign Alu_resultHigh=ALU_Result[31:16];
     wire     Jr;              // 为1表明当前指令是jr，为0表示当前指令不是jr
     wire       RegDST;          // 为1表明目的寄存器是rd，为0时表示目的寄存器是rt
      wire      ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）来自立即数（beq，bne除外），为0时表示第二个操作数来自寄存器
      wire       MemtoReg;     // 为1表明从存储器或I/O读取数据写到寄存器，为0时表示将ALU模块输出数据写到寄存器
      wire      RegWrite;         // 为1表明该指令需要写寄存器，为0时表示不需要写寄存器
      wire       MemWrite;       // 为1表明该指令需要写存储器，为0时表示不需要写储存器
     wire       Branch;        // 为1表明是beq指令，为0时表示不是beq指令
     wire       nBranch;       // 为1表明是bne指令，为0时表示不是bne指令
      wire       Jmp;            // 为1表明是j指令，为0时表示不是j指令
      wire       Jal;            // 为1表明是jal指令，为0时表示不是jal指令
      wire       I_format;      // 为1表明该指令是除beq，bne，lw，sw之外的I-类型指令，其余情况为0
      wire      Sftmd;         // 为1表明是移位指令，为0表明不是移位指令
      wire[1:0]  ALUOp;        // 当指令为R-type或I_format为1时，ALUOp的高比特位为1，否则高比特位为0; 当指令为beq或bne时，ALUOp的低比特位为1，否则低比特位为0
      wire MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
     
     wire MemRead; // 1 indicates that the instruction needs to read from the memory
      
      wire IORead; // 1 indicates I/O read
      wire IOWrite; // 1 indicates I/O write
     
      //wire memWrite;
      // the 'Address' of memory unit which is toberead/writen
        wire[31:0] addr_out; // address to Data-Memory
     wire[31:0] address;
      // data tobe wirten to the memory unit
      assign address=addr_out;
     //wire[31:0] writeData;
      /*data to be read from the memory unit, in the left
      screenshot its name is 'MemData' */
      wire[31:0] readDatamem;
      
      //wire mRead; // read memory, from Controller
      //wire mWrite; // write memory, from Controller
      //wire ioRead; // read IO, from Controller
     // wire ioWrite; // write IO, from Controller
     wire[31:0] addr_in; // from alu_result in ALU
     assign addr_in=ALU_Result;
    
     wire[31:0] m_rdata; // data read from Data-Memory
     assign m_rdata=readDatamem;
      //wire[15:0] io_rdata; // data read from IO,16 bits
     wire [31:0]  r_wdata; // data to Decoder(register file)
     // wire[31:0] r_rdata; // data read from Decoder(register file)
     wire[31:0] write_data; // data to memory or I/O（m_wdata, io_wdata）
      wire LEDCtrl; // LED Chip Select
     wire SwitchCtrl;   
      
        //wire			reset,				// reset, active high 复位信号 (高电平有效)
       //wire            ior;               // from Controller, 1 means read from input device(从控制器来的I/O读)
      // wire             switchctrl;            // means the switch is selected as input device (从memorio经过地址高端线获得的拨码开关模块片选)
      input       [3:0]    ioread_data_switch;   // the data from switch(从外设来的读数据，此处来自拨码开关)
      wire      [15:0]    ioread_data ;        // the data to memorio (将外设来的数据送给memorio)
      
      // wire		ledrst,		// reset, active high (复位信号,高电平有效)
       // wire          led_clk;    // clk for led (时钟信号)
        //wire            ledwrite,    // led write enable, active high (写信号,高电平有效)
       // wire            ledcs;       // 1 means the leds are selected as output (从memorio来的，由低至高位形成的LED片选信号)
      //wire   [1:0]    ledaddr;  // 2'b00 means updata the low 16bits of ledout, 2'b10 means updata the high 8 bits of ledout
         wire   [15:0]    ledwdata;    // the data (from register/memorio)  waiting for to be writen to the leds of the board
         assign ledwdata=write_data[15:0];
        wire  [15:0]    ledout ;       // the data writen to the leds  of the board
        output   [3:0] seg_en;
            output  [7:0]  seg_out0;
           
      
        
   
    
   
    
Ifetc32 ife(Instruction, branch_base_addr, link_addr,  clkcpu, reset, Addr_Result,read_data_1,Branch, nBranch, Jmp, Jal, Jr, Zero);
decode32 deco(read_data_1,read_data_2,Instruction,r_wdata,ALU_Result,Jal,RegWrite,MemtoReg,RegDST,Sign_extend, clkcpu,reset,opcplus4);
control32 cont(Opcode, Function_opcode,Sign_extend[31:16], MemorIOtoReg,MemRead,IORead,IOWrite, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
executs32 exec(clkcpu,read_data_1,read_data_2,Sign_extend,Function_opcode,Opcode,ALUOp,Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,branch_base_addr);
dmemory32 dmem( clkcpu,MemWrite,ALU_Result,read_data_2,readDatamem);
memori mmemori(  MemRead,IORead,readDatamem,ioread_data_switch,  r_wdata);
//ioread  iore(reset,IORead,	ioread_data_switch,	ioread_data);
leds le(reset,clkcpu,IOWrite, read_data_2[15:0],seg_en,seg_out0);

endmodule
