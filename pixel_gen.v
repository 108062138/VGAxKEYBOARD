`define UNIT 10'd64
`define HALFUNIT 10'd32 
`define QUARTERUNIT 10'd16
`define ZERO  4'b0000
`define ONE   4'b0001
`define TWO   4'b0010
`define THREE 4'b0011
`define FOUR  4'b0100
`define FIVE  4'b0101
`define SIX   4'b0110
`define SEVEN 4'b0111
`define EIGHT 4'b1000
`define NINE  4'b1001
`define TEN   4'b1010

`define PATH 12'hfff
`define BLOCK 12'h0
`define WATER 12'h0f0
`define NODIS 4'd15
`define A 12'h39
`define HMAXTILE 4'd9
`define VMAXTILE 4'd5
`define HMINTILE 4'd0
`define VMINTILE 4'd0

module pixel_gen(
input [9:0] h_cnt,
input [9:0] v_cnt,
input [3:0] curAh,
input [3:0] curAv,
input valid,
output reg [3:0] vgaRed,
output reg [3:0] vgaGreen,
output reg [3:0] vgaBlue
);

reg [3:0] hMap;
reg [3:0] vMap;
reg [9:0] centerAh;
reg [9:0] centerAv;
reg [19:0] playCircle;
always @(*) begin
    if(!valid)begin
        hMap = 15;
    end else if(h_cnt<`UNIT*1)begin
        hMap = 0;
    end else if(h_cnt<`UNIT*2)begin
        hMap = 1;
    end else if(h_cnt<`UNIT*3)begin
        hMap = 2;
    end else if(h_cnt<`UNIT*4)begin
        hMap = 3;
    end else if(h_cnt<`UNIT*5)begin
        hMap = 4;
    end else if(h_cnt<`UNIT*6)begin
        hMap = 5;
    end else if(h_cnt<`UNIT*7)begin
        hMap = 6;
    end else if(h_cnt<`UNIT*8)begin
        hMap = 7;
    end else if(h_cnt<`UNIT*9)begin
        hMap = 8;
    end else if(h_cnt<`UNIT*10)begin
        hMap = 9;
    end else begin
        hMap = 15;
    end
end

always @(*) begin
    centerAh = curAh*`UNIT+`HALFUNIT;
    centerAv = curAv*`UNIT+`HALFUNIT;
    playCircle = (centerAh-h_cnt)*(centerAh-h_cnt) + (centerAv-v_cnt)*(centerAv-v_cnt);
end

always @(*) begin
    if(hMap==`NODIS || vMap==`NODIS)begin
        {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
    end else begin
        if(curAh==hMap && curAv==vMap && (playCircle<`QUARTERUNIT*`QUARTERUNIT))begin
            {vgaRed, vgaGreen, vgaBlue} = `A;
        end else begin
            if(hMap%3==0)begin
                {vgaRed, vgaGreen, vgaBlue} = `WATER;
            end else begin
                if(vMap%4==0)begin
                    {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
                end else begin
                    {vgaRed, vgaGreen, vgaBlue} = `PATH;
                end
            end 
        end
    end
end

always @(*) begin
    if(!valid)begin
        vMap = 15;
    end else if(v_cnt<`UNIT*1)begin
        vMap = 0;
    end else if(v_cnt<`UNIT*2)begin
        vMap = 1;
    end else if(v_cnt<`UNIT*3)begin
        vMap = 2;
    end else if(v_cnt<`UNIT*4)begin
        vMap = 3;
    end else if(v_cnt<`UNIT*5)begin
        vMap = 4;
    end else if(v_cnt<`UNIT*6)begin
        vMap = 5;
    end else begin
        vMap = 15;
    end
end
endmodule
