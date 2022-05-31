`define FIRE  1'b1
`define CEASE 1'b0
`define MAXBOMB 4'd10
`define PLAYERA 2'b00
`define PLAYERB 2'b01
`define BSTARTV 4'b0000
`define BSTARTH 4'b0000
`define ASTARTV 4'b0101
`define ASTARTH 4'b1001

module player(
input wire clk,
input wire rst,
input wire [1:0] user,
input wire up,
input wire down,
input wire left,
input wire right,
input wire attack,
input wire [(HMAXTILE+1)*(VMAXTILE+1):0] walkAble,
output reg [3:0] curh,
output reg [3:0] curv,
output wire placeBomb,
output reg [3:0] numBomb
);

assign placeBomb = (nextNumBomb-1==numBomb)?1:0;

reg [3:0] nexth;
reg [3:0] nextv;
reg nextPlaceBomb;
parameter TOTALBOMB = 5;
parameter HMAXTILE = 9;
parameter VMAXTILE = 5;
parameter HMINTILE = 0;
parameter VMINTILE = 0;

parameter cntHead = 24;
reg [cntHead:0] walkCD;
always @(posedge clk) begin
    if(rst)begin
        walkCD <= 0;
    end else begin
        if(curh!=nexth || curv!=nextv)begin
            walkCD <= 0;
        end else begin
            if(walkCD=={(cntHead+1){1'b1}})begin//cd time for pressing the button
                walkCD <= walkCD;
            end else begin
                walkCD <= walkCD + 1; 
            end
        end
    end
end

reg [cntHead:0] bombPlaceInterval;
always @(posedge clk) begin
    if(rst)begin
        bombPlaceInterval <= 0;
    end else begin
        if(nextNumBomb+1==numBomb)begin
            bombPlaceInterval <= 0;
        end else begin
            if(bombPlaceInterval=={(cntHead+1){1'b1}})begin//cd time for pressing the button
                bombPlaceInterval <= bombPlaceInterval;
            end else begin
                bombPlaceInterval <= bombPlaceInterval + 1; 
            end
        end
    end
end
parameter bombHead = 25;
reg [bombHead:0] bombCD;
reg [3:0] nextNumBomb;
always @(posedge clk) begin
    if(rst)begin
        bombCD <= 0;
    end else begin
        if(numBomb==`MAXBOMB)begin
            bombCD <= 0;
        end else begin
            bombCD <= bombCD + 1;
        end
    end
end
//handle num of bomb
always @(posedge clk) begin
    if(rst)begin
        numBomb <= `MAXBOMB;
    end else begin
        numBomb <= nextNumBomb;
    end
end

always @(*) begin
    if(bombPlaceInterval>{(cntHead-2){1'b1}})begin
        if(attack)begin
            if(numBomb>0)begin
                nextNumBomb = numBomb - 1;
            end else begin
                nextNumBomb = numBomb;
            end
        end else begin
            if(bombCD=={(bombHead+1){1'b1}})begin
                if(numBomb<`MAXBOMB)begin
                    nextNumBomb = numBomb + 1;
                end else begin
                    nextNumBomb = numBomb;
                end
            end else begin
                nextNumBomb = numBomb;
            end
        end
    end else begin
        if(bombCD=={(bombHead+1){1'b1}})begin
            if(numBomb<`MAXBOMB)begin
                nextNumBomb = numBomb + 1;
            end else begin
                nextNumBomb = numBomb;
            end
        end else begin
            nextNumBomb = numBomb;
        end
    end
end


always @(posedge clk) begin
    if(rst)begin
        if(user==`PLAYERA)begin
            curh <= `ASTARTH;
        end else begin
            curh <= `BSTARTH;
        end
    end else begin
        curh <= nexth;
    end
end

always @(*) begin
    if(walkCD[cntHead])begin
        if(left)begin
            if(curh<=HMINTILE)begin
                nexth = HMINTILE;
            end else begin
                if( walkAble[(HMAXTILE+1)*curv+curh-1] )begin
                    nexth = curh - 1;
                end else begin
                    nexth = curh;
                end
            end
        end else if(right)begin
            if(curh<HMAXTILE)begin
                if( walkAble[(HMAXTILE+1)*curv+curh+1] )begin
                    nexth = curh+1;
                end else begin
                    nexth = curh;
                end
            end else begin
                nexth = HMAXTILE;
            end
        end else begin
            nexth = curh;
        end
    end else begin
        nexth = curh;
    end
end

always @(posedge clk) begin
    if(rst)begin
        if(user==`PLAYERA)begin
            curv <= `ASTARTV;
        end else begin
            curv <= `BSTARTV;
        end
    end else begin
        curv <= nextv;
    end
end

always @(*) begin
    if(walkCD[cntHead])begin
        if(down)begin
            if(curv<VMAXTILE)begin
                if( walkAble[(HMAXTILE+1)*(curv+1)+curh] )begin
                    nextv = curv+1;
                end else begin
                    nextv = curv;
                end
            end else begin
                nextv = VMAXTILE;
            end
        end else if(up)begin
            if(curv<=VMINTILE)begin
                nextv = VMINTILE;
            end else begin
                if( walkAble[(HMAXTILE+1)*(curv-1)+curh] )begin
                    nextv = curv-1;
                end else begin
                    nextv = curv;
                end
            end
        end else begin
            nextv = curv;
        end
    end else begin
        nextv = curv;
    end
end

endmodule