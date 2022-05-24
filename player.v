`define HMAXTILE 4'd9
`define VMAXTILE 4'd5
`define HMINTILE 4'd0
`define VMINTILE 4'd0

module player(
input wire clk,
input wire rst,
input wire [1:0] user,
input wire up,
input wire down,
input wire left,
input wire right,
output reg [3:0] curh,
output reg [3:0] curv
);
reg [3:0] nexth;
reg [3:0] nextv;

parameter cntHead = 24;
reg [cntHead:0] cntTime;
always @(posedge clk) begin
    if(rst)begin
        cntTime <= 0;
    end else begin
        if(curh!=nexth || curv!=nextv)begin
            cntTime <= 0;
        end else begin
            if(cntTime=={(cntHead+1){1'b1}})begin//cd time for pressing the button
                cntTime <= cntTime;
            end else begin
                cntTime <= cntTime + 1; 
            end
        end
    end
end

always @(posedge clk) begin
    if(rst)begin
        curh <= `HMINTILE;
    end else begin
        curh <= nexth;
    end
end

always @(*) begin
    if(cntTime[cntHead])begin
        if(left)begin
            if(curh<=`HMINTILE)begin
                nexth = `HMINTILE;
            end else begin
                nexth = curh -1;
            end
        end else if(right)begin
            if(curh<`HMAXTILE)begin
                nexth = curh + 1;
            end else begin
                nexth = `HMAXTILE;
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
        curv <= `VMINTILE;
    end else begin
        curv <= nextv;
    end
end

always @(*) begin
    if(cntTime[cntHead])begin
        if(down)begin
            if(curv<`VMAXTILE)begin
                nextv = curv + 1;
            end else begin
                nextv = `VMAXTILE;
            end
        end else if(up)begin
            if(curv<=`VMINTILE)begin
                nextv = `VMINTILE;
            end else begin
                nextv = curv - 1;
            end
        end else begin
            nextv = curv;
        end
    end else begin
        nextv = curv;
    end
end

endmodule