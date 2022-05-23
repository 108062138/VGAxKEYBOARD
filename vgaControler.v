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

`define ADD   4'b1011
`define MINUS 4'b1100
`define MUL   4'b1101
`define ENTER 4'b1110
`define WAIT  4'b1111

`define HMAXTILE 4'd9
`define VMAXTILE 4'd5
`define HMINTILE 4'd0
`define VMINTILE 4'd0

module top(
input clk,
input rst,
inout PS2_DATA,
inout PS2_CLK,
output [3:0] vgaRed,
output [3:0] vgaGreen,
output [3:0] vgaBlue,
output hsync,
output vsync,
output wire [15:0] led,
output wire [3:0] AN,
output wire [7:0] SSD
);


wire clk_25MHz;
wire valid;
wire [9:0] h_cnt; //640
wire [9:0] v_cnt;  //480
wire [511:0] key_down;
wire [8:0] last_change;
wire key_valid;
reg [3:0] curKey;
reg [3:0] nextKey;

reg [3:0] curAh;
reg [3:0] nextAh;
reg [3:0] curAv;
reg [3:0] nextAv;

reg [3:0] curBh;
reg [3:0] nextBh;
reg [3:0] curBv;
reg [3:0] nextBv;

reg [3:0] displayNum;
wire [3:0] dummyLed;
wire [3:0] dummyAN;
wire clk1hz;

reg [2:0] curState;
reg [2:0] nextState;

assign led[3:0] = curKey[3:0];
assign led[15:7] = last_change[8:0];
assign led[5] = key_valid;
assign led[3:0] = curKey[3:0];

clkDivider #(.divbit(24)) CLKLDIVIDER(.clk(clk),.divclk(clk1hz),.AN(AN[3:0]));

sevenSegment SEVENSEGEMENT(.i(displayNum),.led(dummyLed),.ssd(SSD),.an(dummyAN));

clock_divisor clk_wiz_0_inst(.clk(clk),.clk1(clk_25MHz));

pixel_gen pixel_gen_inst(
.h_cnt(h_cnt),
.v_cnt(v_cnt),
.curAh(curAh),
.curAv(curAv),
.valid(valid),
.vgaRed(vgaRed),
.vgaGreen(vgaGreen),
.vgaBlue(vgaBlue)
);

vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(h_cnt),.v_cnt(v_cnt));
      
KeyboardDecoder KEYBOARDDECODER(.key_down(key_down),.last_change(last_change),.key_valid(key_valid),.PS2_DATA(PS2_DATA),.PS2_CLK(PS2_CLK),.rst(rst),.clk(clk));
parameter cntHead = 25;
reg [cntHead:0] cntATime;
reg [cntHead:0] cntBTime;
always @(posedge clk) begin
    if(rst)begin
        cntATime <= 0;
        cntBTime <= 0;
    end else begin
        if(curAh!=nextAh || curAv!=nextAv)begin
            cntATime <= 0;
        end else begin
            if(cntATime=={(cntHead+1){1'b1}})begin//cd time for pressing the button
                cntATime <= cntATime;
            end else begin
                cntATime <= cntATime + 1; 
            end
        end

        if(curBh!=nextBh || curBv!=nextBv)begin
            cntBTime <= 0;
        end else begin
            if(cntBTime=={(cntHead+1){1'b1}})begin//cd time for pressing the button
                cntBTime <= cntBTime;
            end else begin
                cntBTime <= cntBTime + 1; 
            end
        end
    end
end

always @(posedge clk) begin
    if(rst)begin
        curAh <= `HMINTILE;
    end else begin
        curAh <= nextAh;
    end
end

always @(*) begin
    if(cntATime[cntHead])begin
        if(curKey==`ONE)begin
            if(curAh<=`HMINTILE)begin
                nextAh = `HMINTILE;
            end else begin
                nextAh = curAh -1;
            end
        end else if(curKey==`THREE)begin
            if(curAh<`HMAXTILE)begin
                nextAh = curAh + 1;
            end else begin
                nextAh = `HMAXTILE;
            end
        end else begin
            nextAh = curAh;
        end
    end else begin
        nextAh = curAh;
    end
end

always @(posedge clk) begin
    if(rst)begin
        curAv <= `VMINTILE;
    end else begin
        curAv <= nextAv;
    end
end

always @(*) begin
    if(cntATime[cntHead])begin
        if(curKey==`FIVE)begin
            if(curAv<`VMAXTILE)begin
                nextAv = curAv + 1;
            end else begin
                nextAv = `VMAXTILE;
            end
        end else if(curKey==`TWO)begin
            if(curAv<=`VMINTILE)begin
                nextAv = `VMINTILE;
            end else begin
                nextAv = curAv - 1;
            end
        end else begin
            nextAv = curAv;
        end
    end else begin
        nextAv = curAv;
    end
end

always @(posedge clk) begin
    if(rst)begin
        curKey <= `WAIT;//F for default
    end else begin
        if(key_valid)begin//event detect!
            curKey <= nextKey;
        end else begin
            curKey <= curKey;
        end 
    end
end

always @(*) begin
    if(key_valid)begin
        if(!key_down[last_change[7:0]])begin
            //has been press for a while
            nextKey = `WAIT;
        end else begin
            //hadn't been press 
            case (last_change[7:0])
                8'h70:begin
                    nextKey = `ZERO; 
                end
                8'h69:begin
                    nextKey = `ONE;
                end 
                8'h72:begin
                    nextKey = `TWO;
                end
                8'h7A:begin
                    nextKey = `THREE;
                end
                8'h6B:begin
                    nextKey = `FOUR;
                end
                8'h73:begin
                    nextKey = `FIVE;
                end
                8'h74:begin
                    nextKey = `SIX;
                end
                8'h6C:begin
                    nextKey = `SEVEN;
                end
                8'h75:begin
                    nextKey = `EIGHT;
                end
                8'h7D:begin
                    nextKey = `NINE;
                end
                8'h5A:begin
                    if(last_change[8]==0)begin
                        nextKey = `ENTER;
                    end else begin
                        nextKey = `WAIT;
                    end
                end
                8'h79:begin
                    nextKey = `ADD;
                end
                8'h7B:begin
                    nextKey = `MINUS;
                end
                8'h7C:begin
                    nextKey = `MUL;
                end
                default: begin
                    nextKey = `WAIT;
                end
            endcase
        end 
    end else begin
        nextKey = `WAIT;
    end
end
always @(*) begin
    case (AN[3:0])
      4'b1110:begin
          displayNum = curKey;
      end 
      4'b1101:begin
          displayNum = 4'b1111;
      end
      4'b1011:begin
          displayNum = curAv;
      end 
      default:begin
          displayNum = curAh;
      end 
    endcase
end
endmodule
