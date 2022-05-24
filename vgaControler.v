`define SHIFT 4'b0000
`define ONE   4'b0001
`define TWO   4'b0010
`define THREE 4'b0011
`define FIVE  4'b0101

`define BUP    4'b0110
`define BDOWN  4'b0111
`define BLEFT  4'b1000
`define BRIGHT 4'b1001
`define SPACE  4'b1010

`define ADD   4'b1011
`define MINUS 4'b1100
`define MUL   4'b1101
`define ENTER 4'b1110
`define WAIT  4'b1111

`define HMAXTILE 4'd9
`define VMAXTILE 4'd5
`define HMINTILE 4'd0
`define VMINTILE 4'd0

`define PLAYERA 2'b00
`define PLAYERB 2'b01

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

wire [3:0] curAh;
wire [3:0] curAv;

wire [3:0] curBh;
wire [3:0] curBv;

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
.curBh(curBh),
.curBv(curBv),
.valid(valid),
.vgaRed(vgaRed),
.vgaGreen(vgaGreen),
.vgaBlue(vgaBlue)
);

vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(h_cnt),.v_cnt(v_cnt));
      
KeyboardDecoder KEYBOARDDECODER(.key_down(key_down),.last_change(last_change),.key_valid(key_valid),.PS2_DATA(PS2_DATA),.PS2_CLK(PS2_CLK),.rst(rst),.clk(clk));

player PLAYERA(
.clk(clk),
.rst(rst),
.user(`PLAYERA),
.up(curKey==`FIVE),
.down(curKey==`TWO),
.left(curKey==`ONE),
.right(curKey==`THREE),
.curh(curAh),
.curv(curAv)
);

player PLAYERB(
.clk(clk),
.rst(rst),
.user(`PLAYERB),
.up(curKey==`BUP),
.down(curKey==`BDOWN),
.left(curKey==`BLEFT),
.right(curKey==`BRIGHT),
.curh(curBh),
.curv(curBv)
);

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
                8'h59:begin
                    nextKey = `SHIFT; 
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
                8'h73:begin
                    nextKey = `FIVE;
                end

                8'h1D:begin
                    nextKey = `BUP;
                end
                8'h1B:begin
                    nextKey = `BDOWN;
                end
                8'h1C:begin
                    nextKey = `BLEFT;
                end
                8'h23:begin
                    nextKey = `BRIGHT;
                end
                8'h29:begin
                    nextKey = `SPACE;
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
          displayNum = curBv;
      end 
      4'b1101:begin
          displayNum = curBh;
      end
      4'b1011:begin
          displayNum = `WAIT;
      end 
      default:begin
          displayNum = curKey;
      end 
    endcase
end
endmodule
