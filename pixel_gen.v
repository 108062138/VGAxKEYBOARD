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

`define PATHCOLOR  12'hfff
`define BLOCKCOLOR 12'h000
`define BOXCOLOR   12'h669
`define WATERCOLOR 12'h0f0

`define ACOLOR     12'h6f3
`define BCOLOR     12'hf55

`define NODIS 4'd15

`define BOX0 4'b0000
`define BOX1 4'b0001
`define BOX2 4'b0010
`define KILL 4'b0011
`define WALKOK 4'b1110
`define BLOCK  4'b1111

module pixel_gen(
input [9:0] h_cnt,
input [9:0] v_cnt,
input [3:0] curAh,
input [3:0] curAv,
input [3:0] curBh,
input [3:0] curBv,
input valid,
input clk,
input rst,
input wire atkFromA,
input wire atkFromB,
output reg [3:0] vgaRed,
output reg [3:0] vgaGreen,
output reg [3:0] vgaBlue,
output reg [(HMAXTILE+1)*(VMAXTILE+1):0] walkAble
);

parameter HMAXTILE  = 9;
parameter VMAXTILE  = 5;
parameter HMINTILE  = 0;
parameter VMINTILE  = 0;

reg [3:0] hMap;
reg [3:0] vMap;

reg [9:0] centerAh;
reg [9:0] centerAv;
reg [19:0] playerACircle;

reg [9:0] centerBh;
reg [9:0] centerBv;
reg [19:0] playerBCircle;

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
    playerACircle = (centerAh-h_cnt)*(centerAh-h_cnt) + (centerAv-v_cnt)*(centerAv-v_cnt);

    centerBh = curBh*`UNIT+`HALFUNIT;
    centerBv = curBv*`UNIT+`HALFUNIT;
    playerBCircle = (centerBh-h_cnt)*(centerBh-h_cnt) + (centerBv-v_cnt)*(centerBv-v_cnt);
end

always @(*) begin
    if(hMap==`NODIS || vMap==`NODIS)begin
        {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
    end else begin
        if(curAh==hMap && curAv==vMap && (playerACircle<`QUARTERUNIT*`QUARTERUNIT))begin
            {vgaRed, vgaGreen, vgaBlue} = `ACOLOR;
        end else if(curBh==hMap && curBv==vMap && (playerBCircle<`QUARTERUNIT*`QUARTERUNIT))begin 
            {vgaRed, vgaGreen, vgaBlue} = `BCOLOR;
        end else begin
            if(blocks[vMap][hMap])begin
                {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
            end else if(boxes[vMap][hMap]) begin
                {vgaRed, vgaGreen, vgaBlue} = `BOXCOLOR;
            end else if(map[vMap][hMap]==`KILL)begin
                {vgaRed, vgaGreen, vgaBlue} = `WATERCOLOR;
            end else begin
                {vgaRed, vgaGreen, vgaBlue} = `PATHCOLOR;
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

reg [3:0] map [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg [3:0] nextMap [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg blocks [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg boxes [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];

always @(*) begin
    //block definition
    blocks[0][0] = 0;
    blocks[0][1] = 0;
    blocks[0][2] = 0;
    blocks[0][3] = 0;
    blocks[0][4] = 0;
    blocks[0][5] = 0;
    blocks[0][6] = 0;
    blocks[0][7] = 0;
    blocks[0][8] = 0;
    blocks[0][9] = 0;
    blocks[1][0] = 0;
    blocks[1][1] = 1;
    blocks[1][2] = 1;
    blocks[1][3] = 0;
    blocks[1][4] = 0;
    blocks[1][5] = 0;
    blocks[1][6] = 0;
    blocks[1][7] = 0;
    blocks[1][8] = 0;
    blocks[1][9] = 0;
    blocks[2][0] = 0;
    blocks[2][1] = 1;
    blocks[2][2] = 0;
    blocks[2][3] = 0;
    blocks[2][4] = 0;
    blocks[2][5] = 0;
    blocks[2][6] = 0;
    blocks[2][7] = 0;
    blocks[2][8] = 0;
    blocks[2][9] = 0;
    blocks[3][0] = 0;
    blocks[3][1] = 0;
    blocks[3][2] = 0;
    blocks[3][3] = 0;
    blocks[3][4] = 0;
    blocks[3][5] = 0;
    blocks[3][6] = 0;
    blocks[3][7] = 0;
    blocks[3][8] = 1;
    blocks[3][9] = 0;
    blocks[4][0] = 0;
    blocks[4][1] = 0;
    blocks[4][2] = 0;
    blocks[4][3] = 0;
    blocks[4][4] = 0;
    blocks[4][5] = 0;
    blocks[4][6] = 0;
    blocks[4][7] = 1;
    blocks[4][8] = 1;
    blocks[4][9] = 0;
    blocks[5][0] = 0;
    blocks[5][1] = 0;
    blocks[5][2] = 0;
    blocks[5][3] = 0;
    blocks[5][4] = 0;
    blocks[5][5] = 0;
    blocks[5][6] = 0;
    blocks[5][7] = 0;
    blocks[5][8] = 0;
    blocks[5][9] = 0;

    //boxes
    //block definition
    boxes[0][0] = 0;
    boxes[0][1] = 0;
    boxes[0][2] = 0;
    boxes[0][3] = 0;
    boxes[0][4] = 1;
    boxes[0][5] = 0;
    boxes[0][6] = 0;
    boxes[0][7] = 0;
    boxes[0][8] = 0;
    boxes[0][9] = 0;
    boxes[1][0] = 0;
    boxes[1][1] = 0;
    boxes[1][2] = 0;
    boxes[1][3] = 0;
    boxes[1][4] = 1;
    boxes[1][5] = 1;
    boxes[1][6] = 0;
    boxes[1][7] = 1;
    boxes[1][8] = 1;
    boxes[1][9] = 0;
    boxes[2][0] = 0;
    boxes[2][1] = 0;
    boxes[2][2] = 0;
    boxes[2][3] = 0;
    boxes[2][4] = 1;
    boxes[2][5] = 1;
    boxes[2][6] = 0;
    boxes[2][7] = 0;
    boxes[2][8] = 0;
    boxes[2][9] = 0;
    boxes[3][0] = 0;
    boxes[3][1] = 0;
    boxes[3][2] = 0;
    boxes[3][3] = 0;
    boxes[3][4] = 1;
    boxes[3][5] = 1;
    boxes[3][6] = 0;
    boxes[3][7] = 0;
    boxes[3][8] = 0;
    boxes[3][9] = 0;
    boxes[4][0] = 1;
    boxes[4][1] = 1;
    boxes[4][2] = 0;
    boxes[4][3] = 0;
    boxes[4][4] = 1;
    boxes[4][5] = 1;
    boxes[4][6] = 0;
    boxes[4][7] = 0;
    boxes[4][8] = 0;
    boxes[4][9] = 0;
    boxes[5][0] = 0;
    boxes[5][1] = 0;
    boxes[5][2] = 0;
    boxes[5][3] = 0;
    boxes[5][4] = 0;
    boxes[5][5] = 1;
    boxes[5][6] = 0;
    boxes[5][7] = 0;
    boxes[5][8] = 0;
    boxes[5][9] = 0;
end

integer h;
integer v;
always @(posedge clk) begin
    if(rst)begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                if(blocks[v][h])begin
                    map[v][h] <= `BLOCK;
                end else if(boxes[v][h])begin
                    map[v][h] <= `BOX2;
                end else begin
                    map[v][h] <= `WALKOK;
                end
            end
        end
    end else begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                map[v][h] <= nextMap[v][h];
            end
        end
    end
end

always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if(atkFromA)begin
                if(curAh==h&&curAv==v)begin
                    nextMap[v][h] = `KILL;
                end else begin
                    nextMap[v][h] = map[v][h];
                end
            end else if(atkFromB)begin
                if(curBh==h&&curBv==v)begin
                    nextMap[v][h] = `KILL;
                end else begin
                    nextMap[v][h] = map[v][h];
                end
            end else begin
                nextMap[v][h] = map[v][h];
            end
        end
    end
end

always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if(boxes[v][h]||blocks[v][h])begin
                walkAble[(HMAXTILE+1)*v+h] = 0;
            end else begin
                walkAble[(HMAXTILE+1)*v+h] = 1;
            end
        end
    end
end

endmodule
