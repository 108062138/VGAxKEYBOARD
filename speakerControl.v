`timescale 1ns / 1ps
`timescale 1ns / 1ps
`define L15 5'b00001
`define L14 5'b00010
`define L13 5'b00011
`define L12 5'b00100
`define L11 5'b00101
`define L10 5'b00110
`define L09 5'b00111
`define L08 5'b01000
`define L07 5'b01001
`define L06 5'b01010
`define L05 5'b01011
`define L04 5'b01100
`define L03 5'b01101
`define L02 5'b01110
`define L01 5'b01111
`define L00 5'b10000
`define R15 5'b10001
`define R14 5'b10010
`define R13 5'b10011
`define R12 5'b10100
`define R11 5'b10101
`define R10 5'b10110
`define R09 5'b10111
`define R08 5'b11000
`define R07 5'b11001
`define R06 5'b11010
`define R05 5'b11011
`define R04 5'b11100
`define R03 5'b11101
`define R02 5'b11110
`define R01 5'b11111
`define R00 5'b00000
module speakerControl(
input wire clk,
input wire rst_n,
input wire [15:0] lChannel,
input wire [15:0] rChannel,
output wire mclk,
output wire lrclk,
output wire sclk,
output reg sdin,
output reg [4:0] curCnt
);

wire [3:0] anmclk;
wire [3:0] anlrclk;
wire [3:0] ansclk;
soundDivider #(.divbit(2-1)) MCLK(
.clk(clk),
.rst_n(rst_n),
.divclk(mclk),
.AN(anmclk[3:0])
);

soundDivider #(.divbit(4-1)) SCLK(
.clk(clk),
.rst_n(rst_n),
.divclk(sclk),
.AN(ansclk[3:0])
);

reg [4:0] nextCnt;

assign lrclk = curCnt[4];

always @(*) begin
    case (curCnt[4:0])
        `L15:begin
            sdin = lChannel[15];
        end
        `L14:begin
            sdin = lChannel[14];
        end
        `L13:begin
            sdin = lChannel[13];
        end
        `L12:begin
            sdin = lChannel[12];
        end
        `L11:begin
            sdin = lChannel[11];
        end
        `L10:begin
            sdin = lChannel[10];
        end
        `L09:begin
            sdin = lChannel[9];
        end
        `L08:begin
            sdin = lChannel[8];
        end
        `L07:begin
            sdin = lChannel[7];
        end
        `L06:begin
            sdin = lChannel[6];
        end
        `L05:begin
            sdin = lChannel[5];
        end
        `L04:begin
            sdin = lChannel[4];
        end
        `L03:begin
            sdin = lChannel[3];
        end
        `L02:begin
            sdin = lChannel[2];
        end
        `L01:begin
            sdin = lChannel[1];
        end
        `L00:begin
            sdin = lChannel[0];
        end
        `R15:begin
            sdin = rChannel[15];
        end
        `R14:begin
            sdin = rChannel[14];
        end
        `R13:begin
            sdin = rChannel[13];
        end
        `R12:begin
            sdin = rChannel[12];
        end
        `R11:begin
            sdin = rChannel[11];
        end
        `R10:begin
            sdin = rChannel[10];
        end
        `R09:begin
            sdin = rChannel[9];
        end
        `R08:begin
            sdin = rChannel[8];
        end
        `R07:begin
            sdin = rChannel[7];
        end
        `R06:begin
            sdin = rChannel[6];
        end
        `R05:begin
            sdin = rChannel[5];
        end
        `R04:begin
            sdin = rChannel[4];
        end
        `R03:begin
            sdin = rChannel[3];
        end
        `R02:begin
            sdin = rChannel[2];
        end
        `R01:begin
            sdin = rChannel[1];
        end
        default: begin
            sdin = rChannel[0];
        end
    endcase
end

always @(*) begin
    nextCnt = curCnt + 1;
end

initial begin
    curCnt = 0;
end

always @(negedge sclk) begin
    curCnt <= nextCnt;
end

endmodule

module soundDivider(
input wire clk,
input wire rst_n,
output reg [3:0] AN,
output wire divclk
);
parameter divbit = 25;

reg [divbit:0] curCounter;
reg [divbit:0] nextCounter;
initial begin
    curCounter = 0;
end
always @(*) begin
    nextCounter = curCounter +1;
end
always @(*) begin
    case (curCounter[divbit:divbit-1])//change this part when deployed to FPGA
        2'b00:begin
            AN = 4'b1110;
        end 
        2'b01:begin
            AN = 4'b1101;
        end
        2'b10:begin
            AN = 4'b1011;
        end
        default: begin
            AN = 4'b0111;
        end
    endcase
end
always @(posedge clk) begin
    if(rst_n)begin
        curCounter <= 0;
    end else begin
        curCounter <= nextCounter;
    end
end
assign divclk = curCounter[divbit];
endmodule