`define MOVABLE 4'b0000
`define GETHIT  4'b0001
`define FINISH  4'b0010

module hitBoxControler(
input wire clk,
input wire rst,
input wire hitA,
input wire hitB,
input wire [3:0] curAv,
input wire [3:0] curAh,
input wire [3:0] curBv,
input wire [3:0] curBh,
output wire ACanMove,
output wire BCanMove,
output wire AWin,
output wire BWin
);

parameter freezeHead=27;
reg [freezeHead:0] freezeA;
reg [freezeHead:0] freezeB;
reg [freezeHead:0] nextFreezeA;
reg [freezeHead:0] nextFreezeB;
wire samePosition;
assign samePosition = ((curAv==curBv)&&(curAh==curBh))?1:0;

assign ACanMove = (freezeA>0)?0:1;
assign BCanMove = (freezeB>0)?0:1;
assign AWin = (samePosition&&!BCanMove&&ACanMove)?1:0;
assign BWin = (samePosition&&!ACanMove&&BCanMove)?1:0;

always @(posedge clk) begin
    if(rst)begin
        freezeA <=0;
        freezeB <=0;
    end else begin
        freezeA <= nextFreezeA;
        freezeB <= nextFreezeB;
    end
end

always @(*) begin
    if(hitA)begin
        nextFreezeA = 1;
    end else if(freezeA>0)begin
        nextFreezeA = freezeA + 1;
    end else begin
        nextFreezeA = freezeA;
    end

    if(hitB)begin
        nextFreezeB = 1;
    end else if(freezeB>0)begin
        nextFreezeB = freezeB + 1;
    end else begin
        nextFreezeB = freezeB;
    end
end

endmodule