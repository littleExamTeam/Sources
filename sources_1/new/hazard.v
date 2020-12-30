`timescale 1ns / 1ps
module hazard(
    //fetch stage
    output wire StallF,

    //decode stage
    input wire [4:0] RsD, RtD,
    input wire BranchD,

    output wire StallD,
    output wire ForwardAD, ForwardBD,

    //excute stage
    input wire [4:0] RsE, RtE,
    input wire [4:0] WriteRegE,
    input wire [1:0] MemtoRegE,
    input wire RegWriteE,

    output wire FlushE,
    output reg [1:0] ForwardAE, ForwardBE,

    //mem stage
    input wire [4:0] WriteRegM,
    input wire [1:0] MemtoRegM,
    input wire RegWriteM,

    //writeback stage
    input wire [4:0] WriteRegW,
    input wire RegWriteW
);

wire LwStallD, BranchStallD, JumpStallD;

//decode stage forwarding
assign ForwardAD = (RsD != 0 & RsD == WriteRegM & RegWriteM);
assign ForwardBD = (RtD != 0 & RtD == WriteRegM & RegWriteM);

//excute stage forwarding
always @(*) begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;
    if(RsE != 0) begin
        if(RsE == WriteRegM & RegWriteM)begin
            ForwardAE = 2'b10;
        end
        else if(RsE == WriteRegW & RegWriteW)begin
            ForwardAE = 2'b01;
        end
    end
    if(RtE != 0) begin
        if(RtE == WriteRegM & RegWriteM)begin
            ForwardBE = 2'b10;
        end
        else if(RtE == WriteRegW & RegWriteW)begin
            ForwardBE = 2'b01;
        end
    end
end

//stalls
assign LwStallD = MemtoRegE[1:1] & MemtoRegE[0:0] & (RtE == RsD | RtE == RtD);
assign BranchStallD = BranchD & 
        (RegWriteE & (WriteRegE == RsD | WriteRegE == RtD) |
         MemtoRegM[1:1] & MemtoRegM[0:0] & (WriteRegE == RsD | WriteRegE == RtD));

assign StallD = LwStallD | BranchStallD;
assign StallF = StallD;

assign FlushE = StallD;

endmodule