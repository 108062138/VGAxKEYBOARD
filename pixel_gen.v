`define UNIT 10'd64
`define HALFUNIT 10'd32 
`define HALFUNIT 10'd32 
`define BUBBLEUNIT 10'd29
`define QUARTERUNIT 10'd16
`define ONE8UNIT 10'd8
`define ONE16UNIT 10'd4
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

`define TOTALHEALTH 4'b0100

/*R G*/
`define PATHCOLOR   12'hfff
`define BLOCKCOLOR  12'h000
`define BOXCOLOR    12'h669
`define WATERCOLOR  12'h008
`define KILLERCOLOR 12'h088
`define HITCOLOR    12'h123
`define ACOLOR      12'h6f3
`define BCOLOR      12'hf55

`define NODIS 4'd15

`define BOX0          5'b00000
`define BOX1          5'b00001
`define BOX2          5'b00010
`define ABOUTTOBOMB   5'b00011
`define EXPLOSION     5'b00100
`define WALKOK        5'b11100
`define BLOCK         5'b11111

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
input wire ACanMove,
input wire BCanMove,
input wire [3:0] numAWin,
input wire [3:0] numBWin,
output reg [3:0] vgaRed,
output reg [3:0] vgaGreen,
output reg [3:0] vgaBlue,
output reg [(HMAXTILE+1)*(VMAXTILE+1):0] walkAble,
output reg hitA,
output reg hitB
);

parameter HMAXTILE  = 9;parameter VMAXTILE  = 5;parameter HMINTILE  = 0;parameter VMINTILE  = 0;

reg [3:0] hMap;
reg [3:0] vMap;

reg [9:0] centerAh;
reg [9:0] centerAv;
reg [19:0] playerACircle;

reg [9:0] centerBh;
reg [9:0] centerBv;
reg [19:0] playerBCircle;

reg [9:0] centerMapV;
reg [9:0] centerMapH;
reg [19:0] mapCircle;

wire [3:0] AHealth;
wire [3:0] BHealth;

assign AHealth = `TOTALHEALTH - numBWin;
assign BHealth = `TOTALHEALTH - numAWin;

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

    centerMapH = hMap*`UNIT+`HALFUNIT;
    centerMapV = vMap*`UNIT+`HALFUNIT;
    mapCircle = (centerMapH-h_cnt)*(centerMapH-h_cnt) + (centerMapV-v_cnt)*(centerMapV-v_cnt);
end

always @(*) begin
    if(hMap==`NODIS || vMap==`NODIS)begin
        if(v_cnt>430&&v_cnt<450)begin
            if(h_cnt<320)begin
                if(h_cnt<`UNIT*BHealth)begin
                    {vgaRed, vgaGreen, vgaBlue} = `BCOLOR;
                end else begin
                    {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
                end
            end else begin
                if(h_cnt>640-`UNIT*AHealth)begin
                    {vgaRed, vgaGreen, vgaBlue} = `ACOLOR;
                end else begin
                    {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
                end
            end
        end else begin
            {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
        end
    end else begin
        if(curAh==hMap && curAv==vMap && (playerACircle<`QUARTERUNIT*`QUARTERUNIT))begin
            {vgaRed, vgaGreen, vgaBlue} = `ACOLOR;
        end else if(curAh==hMap && curAv==vMap && (playerACircle<`HALFUNIT*`HALFUNIT)&&(playerACircle>`BUBBLEUNIT*`BUBBLEUNIT)&&!ACanMove)begin
            {vgaRed, vgaGreen, vgaBlue} = `HITCOLOR;
        end else if(curBh==hMap && curBv==vMap && (playerBCircle<`QUARTERUNIT*`QUARTERUNIT))begin 
            {vgaRed, vgaGreen, vgaBlue} = `BCOLOR;
        end else if(curBh==hMap && curBv==vMap && (playerBCircle<`HALFUNIT*`HALFUNIT)&&(playerBCircle>`BUBBLEUNIT*`BUBBLEUNIT)&&!BCanMove)begin
            {vgaRed, vgaGreen, vgaBlue} = `HITCOLOR;
        end else begin
            if(blocks[vMap][hMap])begin
                {vgaRed, vgaGreen, vgaBlue} = `BLOCK;
            end else if(boxes[vMap][hMap]&&(explodedBoxes[vMap][hMap]==0)) begin
                {vgaRed, vgaGreen, vgaBlue} = `BOXCOLOR;
            end else if(map[vMap][hMap]==`ABOUTTOBOMB)begin
                if(countDown[vMap][hMap]<{(countDownHead-1){1'b1}})begin
                    if(mapCircle<`ONE16UNIT*`ONE16UNIT)begin
                        {vgaRed, vgaGreen, vgaBlue} = `WATERCOLOR;
                    end else begin
                        {vgaRed, vgaGreen, vgaBlue} = `PATHCOLOR;
                    end
                end else if(countDown[vMap][hMap]<{(countDownHead){1'b1}})begin
                    if(mapCircle<`ONE8UNIT*`ONE8UNIT)begin
                        {vgaRed, vgaGreen, vgaBlue} = `WATERCOLOR;
                    end else begin
                        {vgaRed, vgaGreen, vgaBlue} = `PATHCOLOR;
                    end
                end else if(countDown[vMap][hMap]<{(countDownHead){1'b1}}+{(countDownHead-1){1'b1}})begin
                    if(mapCircle<`QUARTERUNIT*`QUARTERUNIT)begin
                        {vgaRed, vgaGreen, vgaBlue} = `WATERCOLOR;
                    end else begin
                        {vgaRed, vgaGreen, vgaBlue} = `PATHCOLOR;
                    end
                end else begin
                    if(mapCircle<`HALFUNIT*`HALFUNIT)begin
                        {vgaRed, vgaGreen, vgaBlue} = `WATERCOLOR;
                    end else begin
                        {vgaRed, vgaGreen, vgaBlue} = `PATHCOLOR;
                    end
                end
            end else if(map[vMap][hMap]==`EXPLOSION || explosionArea[vMap][hMap])begin
                {vgaRed, vgaGreen, vgaBlue} = `KILLERCOLOR;
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


reg [4:0] map [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg [4:0] nextMap [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
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
reg explosionArea [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg explodedBoxes [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg nextExplodedBoxes [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];

always @(posedge clk) begin
    if(rst)begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                explodedBoxes[v][h] = 0;
            end
        end
    end else begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                explodedBoxes[v][h] <= nextExplodedBoxes[v][h];
            end
        end
    end
end
always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            nextExplodedBoxes[v][h] = boxes[v][h]&(explodedBoxes[v][h] | explosionArea[v][h]); 
        end
    end
end

always @(*) begin
    //NORMAL CASE
    for(v=VMINTILE+1;v<VMAXTILE;v=v+1)begin
        for(h=HMINTILE+1;h<HMAXTILE;h=h+1)begin
            if         (explosionDown[v    ][h - 1]>0) begin explosionArea [v][h] = 1;
            end else if(explosionDown[v    ][h + 1]>0) begin explosionArea [v][h] = 1;
            end else if(explosionDown[v - 1][h    ]>0) begin explosionArea [v][h] = 1;
            end else if(explosionDown[v + 1][h    ]>0) begin explosionArea [v][h] = 1;
            end else if(explosionDown[v    ][h    ]>0) begin explosionArea [v][h] = 1;
            end else                                   begin explosionArea [v][h] = 0;
            end
        end
    end
    //UP STICK
    for(h=HMINTILE+1;h<HMAXTILE;h=h+1)begin
        if         (explosionDown[VMINTILE    ][h - 1]>0) begin explosionArea [VMINTILE][h] = 1;
        end else if(explosionDown[VMINTILE    ][h + 1]>0) begin explosionArea [VMINTILE][h] = 1;
        end else if(explosionDown[VMINTILE + 1][h    ]>0) begin explosionArea [VMINTILE][h] = 1;
        end else if(explosionDown[VMINTILE    ][h    ]>0) begin explosionArea [VMINTILE][h] = 1;
        end else                                          begin explosionArea [VMINTILE][h] = 0;
        end
    end
    //DOWN STICK
    for(h=HMINTILE+1;h<HMAXTILE;h=h+1)begin
        if         (explosionDown[VMAXTILE    ][h - 1]>0) begin explosionArea [VMAXTILE][h] = 1;
        end else if(explosionDown[VMAXTILE    ][h + 1]>0) begin explosionArea [VMAXTILE][h] = 1;
        end else if(explosionDown[VMAXTILE - 1][h    ]>0) begin explosionArea [VMAXTILE][h] = 1;
        end else if(explosionDown[VMAXTILE    ][h    ]>0) begin explosionArea [VMAXTILE][h] = 1;
        end else                                          begin explosionArea [VMAXTILE][h] = 0;
        end
    end
    //LEFT STICK
    for(v=VMINTILE+1;v<VMAXTILE;v=v+1)begin
        if         (explosionDown[v    ][HMINTILE + 1]>0) begin explosionArea [v][HMINTILE] = 1;
        end else if(explosionDown[v + 1][HMINTILE    ]>0) begin explosionArea [v][HMINTILE] = 1;
        end else if(explosionDown[v - 1][HMINTILE    ]>0) begin explosionArea [v][HMINTILE] = 1;
        end else if(explosionDown[v    ][HMINTILE    ]>0) begin explosionArea [v][HMINTILE] = 1;
        end else                                          begin explosionArea [v][HMINTILE] = 0; 
        end
    end
    //RIGHT STICK
    for(v=VMINTILE+1;v<VMAXTILE;v=v+1)begin
        if         (explosionDown[v    ][HMAXTILE - 1]>0) begin explosionArea [v][HMAXTILE] = 1;
        end else if(explosionDown[v + 1][HMAXTILE    ]>0) begin explosionArea [v][HMAXTILE] = 1;
        end else if(explosionDown[v - 1][HMAXTILE    ]>0) begin explosionArea [v][HMAXTILE] = 1;
        end else if(explosionDown[v    ][HMAXTILE    ]>0) begin explosionArea [v][HMAXTILE] = 1;
        end else                                          begin explosionArea [v][HMAXTILE] = 0; 
        end
    end
    //UP LEFT
    if         (explosionDown[VMINTILE    ][HMINTILE + 1]>0) begin explosionArea [VMINTILE][HMINTILE] = 1;
    end else if(explosionDown[VMINTILE + 1][HMINTILE    ]>0) begin explosionArea [VMINTILE][HMINTILE] = 1;
    end else if(explosionDown[VMINTILE    ][HMINTILE    ]>0) begin explosionArea [VMINTILE][HMINTILE] = 1;
    end else                                                 begin explosionArea [VMINTILE][HMINTILE] = 0; 
    end
    //UP RIGHT
    if         (explosionDown[VMINTILE    ][HMAXTILE - 1]>0) begin explosionArea [VMINTILE][HMAXTILE] = 1;
    end else if(explosionDown[VMINTILE + 1][HMAXTILE    ]>0) begin explosionArea [VMINTILE][HMAXTILE] = 1;
    end else if(explosionDown[VMINTILE    ][HMAXTILE    ]>0) begin explosionArea [VMINTILE][HMAXTILE] = 1;
    end else                                                 begin explosionArea [VMINTILE][HMAXTILE] = 0; 
    end
    //DOWN LEFT
    if         (explosionDown[VMAXTILE    ][HMINTILE + 1]>0) begin explosionArea [VMAXTILE][HMINTILE] = 1;
    end else if(explosionDown[VMAXTILE - 1][HMINTILE    ]>0) begin explosionArea [VMAXTILE][HMINTILE] = 1;
    end else if(explosionDown[VMAXTILE    ][HMINTILE    ]>0) begin explosionArea [VMAXTILE][HMINTILE] = 1;
    end else                                                 begin explosionArea [VMAXTILE][HMINTILE] = 0; 
    end
    //DOWN RIGHT
    if         (explosionDown[VMAXTILE    ][HMAXTILE - 1]>0) begin explosionArea [VMAXTILE][HMAXTILE] = 1;
    end else if(explosionDown[VMAXTILE - 1][HMAXTILE    ]>0) begin explosionArea [VMAXTILE][HMAXTILE] = 1;
    end else if(explosionDown[VMAXTILE    ][HMAXTILE    ]>0) begin explosionArea [VMAXTILE][HMAXTILE] = 1;
    end else                                                 begin explosionArea [VMAXTILE][HMAXTILE] = 0; 
    end
end
always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if(countDown[v][h]>0&&countDown[v][h]<{(countDownHead+1){1'b1}})begin
                nextMap[v][h] = `ABOUTTOBOMB;
            end else if(explosionDown[v][h]=={(explosionHead+1){1'b1}})begin
                nextMap[v][h] = `WALKOK;
            end else if(countDown[v][h]=={(countDownHead+1){1'b1}})begin
                nextMap[v][h] = `EXPLOSION;
            end else begin
                nextMap[v][h] = map[v][h];
            end
        end
    end
end

parameter countDownHead=26;
reg [countDownHead:0] countDown [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg [countDownHead:0] nextCountDown [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
always @(posedge clk) begin
    if(rst)begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                countDown[v][h] <= 0;
            end
        end
    end else begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                countDown[v][h] <= nextCountDown[v][h];
            end
        end
    end
end

always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if(curAv==v&&curAh==h&&atkFromA)begin
                nextCountDown[v][h] = 1;
            end else if(curBv==v&&curBh==h&&atkFromB)begin
                nextCountDown[v][h] = 1;
            end else begin
                if(countDown[v][h]>0)begin
                    nextCountDown[v][h] = countDown[v][h]+1;
                end else begin
                    nextCountDown[v][h] = 0;
                end
            end
        end
    end
end

//
parameter explosionHead=23;
reg [explosionHead:0] explosionDown [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
reg [explosionHead:0] nextExplosionDown [VMAXTILE:VMINTILE][HMAXTILE:HMINTILE];
always @(posedge clk) begin
    if(rst)begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                explosionDown[v][h] <= 0;
            end
        end
    end else begin
        for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
            for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
                explosionDown[v][h] <= nextExplosionDown[v][h];
            end
        end
    end
end

always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if(countDown[v][h]=={(countDownHead+1){1'b1}})begin
                nextExplosionDown[v][h] = 1;
            end else begin
                if(explosionDown[v][h]>0)begin
                    nextExplosionDown[v][h] = explosionDown[v][h] + 1;
                end else begin
                    nextExplosionDown[v][h] = 0;
                end
            end
        end
    end
end
//

always @(*) begin
    for(v=VMINTILE;v<=VMAXTILE;v=v+1)begin
        for(h=HMINTILE;h<=HMAXTILE;h=h+1)begin
            if((explodedBoxes[v][h]!=boxes[v][h])||blocks[v][h])begin
                walkAble[(HMAXTILE+1)*v+h] = 0;
            end else begin
                walkAble[(HMAXTILE+1)*v+h] = 1;
            end
        end
    end
end

always @(*) begin
    if(explosionArea[curAv][curAh])begin
        hitA = 1;
    end else begin
        hitA = 0;
    end
    if(explosionArea[curBv][curBh])begin
        hitB = 1;
    end else begin
        hitB = 0;
    end
end

endmodule