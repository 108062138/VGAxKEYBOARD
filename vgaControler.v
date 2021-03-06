`define ZERO  4'b0000
`define SHIFT 4'b0000
`define ONE   4'b0001
`define TWO   4'b0010
`define THREE 4'b0011
`define FOUR  4'b0100
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



`define PLAYERA 2'b00
`define PLAYERB 2'b01

module top(
input clk,
input rst,
input wire uBtn,
input wire dBtn,
inout PS2_DATA,
inout PS2_CLK,
output [3:0] vgaRed,
output [3:0] vgaGreen,
output [3:0] vgaBlue,
output hsync,
output vsync,
output reg [15:0] led,
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
wire [3:0] curKey;
wire [3:0] nextKey;

wire [3:0] curAh;
wire [3:0] curAv;
wire [3:0] aNumOfBumbs;
wire [3:0] curBh;
wire [3:0] curBv;
wire [3:0] bNumOfBumbs;

wire ABomb,BBomb;
wire hitA,hitB;
wire ACanMove,BCanMove,AWin,BWin;
reg [3:0] displayNum;
wire [3:0] dummyLed;
wire [3:0] dummyAN;
wire clk1hz;
reg [2:0] curState;
reg [2:0] nextState;

reg [3:0] showLed;
reg [3:0] nextShowLed;

wire debDBtn,debUBtn;
wire opDBtn,opUBtn;
parameter HMAXTILE = 9;
parameter VMAXTILE = 5;
parameter HMINTILE = 0;
parameter VMINTILE = 0;

wire [(HMAXTILE+1)*(VMAXTILE+1):0] walkAble;

clkDivider #(.divbit(23)) CLKLDIVIDER(.clk(clk),.divclk(clk1hz),.AN(AN[3:0]));


sevenSegment SEVENSEGEMENT(.i(displayNum),.led(dummyLed),.ssd(SSD),.an(dummyAN));

debounce DEBUP(.button(uBtn),.clk(clk),.res(debUBtn));

onePulse OPUP(.clk(clk1hz),.pulse(debUBtn),.res(opUBtn));

debounce DEBDOWN(.button(udtn),.clk(clk),.res(debDBtn));

onePulse OPDOWN(.clk(clk1hz),.pulse(debDBtn),.res(opDBtn));

reg [3:0] numAWin;
reg [3:0] numBWin;
reg [3:0] nextNumAWin;
reg [3:0] nextNumBWin;
always @(posedge clk) begin
    if(rst)begin
        numAWin <= `ZERO;
        numBWin <= `ZERO;
    end else begin
        numAWin <= nextNumAWin;
        numBWin <= nextNumBWin;
    end
end
always @(*) begin
    if(AWin==1)begin
        if(numAWin==`FOUR)begin
            nextNumAWin = `FOUR;
        end else begin
            nextNumAWin = numAWin + 1;
        end
    end else begin
        nextNumAWin = numAWin;
    end

    if(BWin==1)begin
        if(numBWin==`FOUR)begin
            nextNumBWin = `FOUR;
        end else begin
            nextNumBWin = numBWin + 1;
        end
    end else begin
        nextNumBWin = numBWin;
    end
end

always @(*) begin
    if(AWin||BWin)begin
        if(AWin)begin
            led[15:8] = 8'hff;
            led[7:0] = 8'h0;
            
        end else begin
            led[15:8] = 8'h0;
            led[7:0] = 8'hff;
        end
    end else begin
        //led[15:14] = fkled[1:0];
        //led[13] = fkled[7];
        //led[12] = fkled[6];
        //led[11] = fkled[5];
        //led[10] = fkled[4];

        case (showLed)
            `ZERO:   led[9:0] = walkAble[ 9: 0];
            `ONE:    led[9:0] = walkAble[19:10];
            `TWO:    led[9:0] = walkAble[29:20];
            `THREE:  led[9:0] = walkAble[39:30];
            `FOUR:   led[9:0] = walkAble[49:40];
            default: led[9:0] = walkAble[59:50];
        endcase
    end
end

always @(posedge clk1hz) begin
    if(rst)begin
        showLed <= `ZERO;
    end else begin
        showLed <= nextShowLed;
    end
end
always @(*) begin
    if(opUBtn)begin
        if(showLed>`ZERO)begin
            nextShowLed = showLed - 1;
        end else begin
            nextShowLed = `FIVE;
        end
    end else if(opDBtn)begin
        if(showLed<=`FOUR)begin
            nextShowLed = showLed + 1;
        end else begin
            nextShowLed = `ZERO;
        end
    end else begin
        nextShowLed = showLed;
    end
end

clock_divisor clk_wiz_0_inst(.clk(clk),.clk1(clk_25MHz));

pixel_gen pixel_gen_inst(
.h_cnt(h_cnt),
.v_cnt(v_cnt),
.curAh(curAh),
.curAv(curAv),
.curBh(curBh),
.curBv(curBv),
.valid(valid),
.clk(clk),
.rst(rst||AWin||BWin),
.atkFromA(ACanMove&&curKey==`SHIFT),
.atkFromB(BCanMove&&curKey==`SPACE),
.ACanMove(ACanMove),
.BCanMove(BCanMove),
.numAWin(numAWin),
.numBWin(numBWin),
.vgaRed(vgaRed),
.vgaGreen(vgaGreen),
.vgaBlue(vgaBlue),
.walkAble(walkAble),
.hitA(hitA),
.hitB(hitB)
);

hitBoxControler (
.clk(clk),
.rst(rst||AWin||BWin),
.hitA(hitA),
.hitB(hitB),
.curAv(curAv),
.curAh(curAh),
.curBv(curBv),
.curBh(curBh),
.ACanMove(ACanMove),
.BCanMove(BCanMove),
.AWin(AWin),
.BWin(BWin)
);

vga_controller   vga_inst(.pclk(clk_25MHz),.reset(rst),.hsync(hsync),.vsync(vsync),.valid(valid),.h_cnt(h_cnt),.v_cnt(v_cnt));

myKeyBoard MYKEYBOARD__(.clk(clk),.rst(rst),.PS2_DATA(PS2_DATA),.PS2_CLK(PS2_CLK),.key_down(key_down),.last_change(last_change),.curKey(curKey),.nextKey(nextKey));

player PLAYERA(
.clk(clk),
.rst(rst||AWin||BWin),
.user(`PLAYERA),
.up(    ACanMove&&curKey==`FIVE),
.down(  ACanMove&&curKey==`TWO),
.left(  ACanMove&&curKey==`ONE),
.right( ACanMove&&curKey==`THREE),
.attack(ACanMove&&curKey==`SHIFT),
.walkAble(walkAble),
.curh(curAh),
.curv(curAv),
.placeBomb(ABomb),
.numBomb(aNumOfBumbs)
);

player PLAYERB(
.clk(clk),
.rst(rst||AWin||BWin),
.user(`PLAYERB),
.up(    BCanMove&&curKey==`BUP),
.down(  BCanMove&&curKey==`BDOWN),
.left(  BCanMove&&curKey==`BLEFT),
.right( BCanMove&&curKey==`BRIGHT),
.attack(BCanMove&&curKey==`SPACE),
.walkAble(walkAble),
.curh(curBh),
.curv(curBv),
.placeBomb(BBomb),
.numBomb(bNumOfBumbs)
);

always @(*) begin
    case (AN[3:0])
      4'b1110:begin
          displayNum = numAWin;
      end 
      4'b1101:begin
          displayNum = 4'b1010;
      end
      4'b1011:begin
          displayNum = numBWin;
      end 
      default:begin
          displayNum = 4'b1011;
      end 
    endcase
end

endmodule
