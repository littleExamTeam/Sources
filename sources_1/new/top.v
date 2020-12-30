`timescale 1ns / 1ps
module top(
    input wire clk,rst,
	output wire[31:0] WriteData, DataAddr,
	output wire MemWrite,
	output wire [31:0] pc_out,
	output wire [31:0] inst_out
    );
    
wire[31:0] PC, Inst, ReadData;

mips mips(clk, rst, 
    PC, Inst,
    MemWrite,
    DataAddr,
    WriteData,
    ReadData);

inst_mem inst_mem(~clk, PC, Inst);
data_mem data_mem(
    .clka(~clk),
    .ena(1'b1),
    .wea(MemWrite),
    .addra(DataAddr),
    .dina(WriteData),
    .douta(ReadData));

assign pc_out = PC;
assign inst_out = Inst;

endmodule
