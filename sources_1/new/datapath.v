`timescale 1ns / 1ps
module datapath(
    input wire clk, rst,

    //-----fetch stage-------------------------------
    output wire[31:0] PCF,
    input  wire[31:0] InstF,
    //-----------------------------------------------

    //-----decode stage------------------------------
    output wire [5:0] Op,
    output wire [5:0] Funct,
    //--signals--
    input  wire       RegWriteD,
    input  wire [1:0] MemtoRegD,
    input  wire       MemWriteD,
    input  wire [7:0] ALUControlD,
    input  wire       ALUSrcAD,
    input  wire [1:0] ALUSrcBD,
    input  wire       RegDstD,
    input  wire       JumpD,
    input  wire       BranchD,
    input  wire       HIWriteD,
    input  wire       LOWriteD, 
    //-----------------------------------------------

    //-----mem stage---------------------------------
    output wire        MemWriteM,
    output wire [31:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input  wire [31:0] ReadDataM
    //-----------------------------------------------
);
wire [31:0] PC;

//-----fetch stage-----------------------------------
wire [31:0] PCPlus4F;
wire StallF;
//---------------------------------------------------


//-----decode stage----------------------------------
wire [31:0] InstD;
//--signal--
wire [1:0]  PCSrcD;
//--addr--
wire [31:0] PCPlus4D, PCBranchD, PCJumpD;
wire [27:0] ExJumpAddr;
//--imm--
wire [31:0] SignImmD, ExSignImmD, ZeroImmD, SaD;
//--data--
wire [31:0] HIIn,HIDataD;
wire [31:0] LOIn,LODataD;
wire [31:0] DataAD, DataBD;
//--regs info--
wire [4:0]  RsD, RtD, RdD;
//--hazard handle--
wire [31:0] CmpA, CmpB;
wire [31:0] EqualD;
wire [1:0]  ForwardAD, ForwardBD;
wire        StallD, FlushD;
//-------------------------------------------------------


//-----excute stage--------------------------------------
//--signals--
wire       RegWriteE;
wire [1:0] MemtoRegE;
wire       MemWriteE;
wire [7:0] ALUControlE;
wire       ALUSrcAE;
wire [1:0] ALUSrcBE;
wire       RegDstE;
wire       HIWriteE;
wire       LOWriteE;
//--imm--
wire [31:0] SignImmE, ZeroImmE, SaE;
//--data--
wire [31:0] DataAE, DataBE;
wire [31:0] HIDataE, NewHIDataE;
wire [31:0] LODataE, NewLODataE;
//--regs info--
wire  [4:0] RsE, RtE, RdE;
wire  [4:0] WriteRegE;
//--alu src--
wire [31:0] SrcAE, SrcBE, ALUOutE;
wire [31:0] RegValue;
wire [31:0] WriteDataE;
//--hazard handle--
wire [1:0] ForwardAE, ForwardBE;
wire [1:0] ForwardHIE, ForwardLOE;
wire FlushE;
//----------------------------------------------------------


//-----mem stage--------------------------------------------
//--signals--
wire       RegWriteM;
wire [1:0] MemtoRegM;
wire       HIWriteM;
wire       LOWriteM;
//--data--
wire [31:0] HIDataM;
wire [31:0] LODataM;
//--regs info--
wire [4:0]  WriteRegM; 
//----------------------------------------------------------


//-----writeback stage--------------------------------------
//--signals
wire       RegWriteW;
wire [1:0] MemtoRegW;
wire       HIWriteW;
wire       LOWriteW;
//--data--
wire [31:0] ReadDataW;
wire [31:0] HIDataW;
wire [31:0] LODataW;
wire [31:0] ALUOutW;
wire [31:0] ResultW;
//--regs info--
wire  [4:0] WriteRegW;
//----------------------------------------------------------


//-----next pc----------------------------------------------
mux3 #(32) pcmux(PCPlus4F, PCBranchD, PCJumpD, PCSrcD, PC);
//----------------------------------------------------------


//-----fetch stage------------------------------------------
pc #(32) pcreg(clk, rst, ~StallF, PC, PCF);
adder pcadder(PCF, 32'b100, PCPlus4F);
//----------------------------------------------------------


//-----decode stage-----------------------------------------
flopenrc #(32)D1(clk, rst, ~StallD, FlushD, InstF, InstD);
flopenrc #(32)D2(clk, rst, ~StallD, FlushD, PCPlus4F, PCPlus4D);

assign Op    = InstD[31:26];
assign RsD   = InstD[25:21];
assign RtD   = InstD[20:16];
assign RdD   = InstD[15:11];
assign Funct = InstD[5:0];

assign SaD = {27'b0, InstD[10:6]};

assign PCSrcD[0:0] = BranchD & EqualD;
assign PCSrcD[1:1] = JumpD;

//--regs--
regfile rf(clk, RegWriteW, RsD, RtD, WriteRegW, ResultW, DataAD, DataBD);
hiloreg hilo(clk, rst, HIWriteW, LOWriteW, HIIn, LOIn, HIDataD, LODataD);
//--hilo write--
mux2 #(32)HIsel(HIDataW, ResultW ,HIWriteW, HIIn);
mux2 #(32)LOsel(LODataW, ResultW ,LOWriteW, LOIn);
//--barnch hazrad handle--
mux2 #(32)DAmux(DataAD, ALUOutM, ForwardAD, CmpA);
mux2 #(32)DBmux(DataBD, ALUOutM, ForwardBD, CmpB);
eqcmp cmp(CmpA, CmpB, EqualD);

assign FlushD = PCSrcD[0:0] | PCSrcD[1:1];
//--ext imm--
signext se(InstD[15:0], SignImmD);
zeroext ze(InstD[15:0], ZeroImmD);
//--sl--
sl2 #(32)sl2imm(SignImmD, ExSignImmD);
sl2 #(26)sl2jumpaddr(InstD[25:0], ExJumpAddr);
//--branch addr--
adder branchadder(PCPlus4D, ExSignImmD, PCBranchD);
//--jump addr--
assign PCJumpD = {InstD[31:28], ExJumpAddr};
//-------------------------------------------------------------


//-----excute stage---------------------------------------------
floprc   #(18)E1(clk, rst, FlushE,
    {RegWriteD,MemtoRegD,MemWriteD,ALUControlD,ALUSrcAD,ALUSrcBD,RegDstD,HIWriteD,LOWriteD},
    {RegWriteE,MemtoRegE,MemWriteE,ALUControlE,ALUSrcAE,ALUSrcBE,RegDstE,HIWriteE,LOWriteE});
floprc  #(32)E2(clk, rst, FlushE, DataAD, DataAE);
floprc  #(32)E3(clk, rst, FlushE, DataBD, DataBE);
floprc   #(5)E4(clk, rst, FlushE, RsD, RsE);
floprc   #(5)E5(clk, rst, FlushE, RtD, RtE);
floprc   #(5)E6(clk, rst, FlushE, RdD, RdE);
floprc  #(32)E7(clk, rst, FlushE, SignImmD, SignImmE);
floprc  #(32)E8(clk, rst, FlushE, ZeroImmD, ZeroImmE);
floprc  #(32)E9(clk, rst, FlushE, SaD, SaE);
floprc #(32)E10(clk, rst, FlushE, HIDataD, HIDataE);
floprc #(32)E11(clk, rst, FlushE, LODataD, LODataE);
//--alu forwarding--
mux2  #(5) regmux(RtE, RdE, RegDstE, WriteRegE);
mux3 #(32) forwardamux(DataAE, ResultW, ALUOutM, ForwardAE, RegValue);
mux3 #(32) forwardbmux(DataBE, ResultW, ALUOutM, ForwardBE, WriteDataE);
//--alu src--
mux2 #(32) alusrcamux(RegValue, SaE, ALUSrcAE,SrcAE);
mux3 #(32) alusrcbmux(WriteDataE, SignImmE, ZeroImmE, ALUSrcBE, SrcBE);
//--hilo forwarding--
mux3 #(32) forwardHImux(HIDataE, ALUOutM, ResultW, ForwardHIE, NewHIDataE);
mux3 #(32) forwardLOmux(LODataE, ALUOutM, ResultW, ForwardLOE, NewLODataE);

alu alu(ALUControlE, SrcAE, SrcBE, ALUOutE);
//-----------------------------------------------------------


//-----mem stage---------------------------------------------
flopr  #(6)M1(clk, rst,
    {RegWriteE,MemtoRegE,MemWriteE,HIWriteE,LOWriteE},
    {RegWriteM,MemtoRegM,MemWriteM,HIWriteM,LOWriteM});
flopr #(32)M2(clk, rst, ALUOutE, ALUOutM);
flopr #(32)M3(clk, rst, WriteDataE, WriteDataM);
flopr  #(5)M4(clk, rst, WriteRegE, WriteRegM);
flopr #(32)M5(clk, rst, NewHIDataE, HIDataM);
flopr #(32)M6(clk, rst, NewLODataE, LODataM);
//------------------------------------------------------------


//-----writeback stage----------------------------------------
flopr  #(5)W1(clk, rst,
    {RegWriteM,MemtoRegM,HIWriteM,LOWriteM},
    {RegWriteW,MemtoRegW,HIWriteW,LOWriteW});
flopr #(32)W2(clk, rst, ReadDataM, ReadDataW);
flopr #(32)W3(clk, rst, ALUOutM, ALUOutW);
flopr  #(5)W4(clk, rst, WriteRegM, WriteRegW);
flopr #(32)W5(clk, rst, HIDataM, HIDataW);
flopr #(32)W6(clk, rst, LODataM, LODataW);

mux4 #(32)resultmux(ALUOutW, LODataW, HIDataW, ReadDataW, MemtoRegW, ResultW);
//------------------------------------------------------------


//hazard
hazard h(
    //fetch stage
    StallF,
    //decode stage
    RsD, RtD,
    BranchD,

    StallD,
    ForwardAD, ForwardBD,
    //excute stage
    RsE, RtE,
    WriteRegE,
    MemtoRegE,
    RegWriteE,

    FlushE,
    ForwardAE, ForwardBE,
    ForwardHIE, ForwardLOE,
    //mem stage
    WriteRegM,
    MemtoRegM,
    RegWriteM,
    HIWriteM, LOWriteM,
    //writeback stage
    WriteRegW,
    RegWriteW
);

endmodule