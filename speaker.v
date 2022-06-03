`timescale 1ns / 1ps

`define DOSOUND 22'd191571
`define RESOUND 22'd170648
`define MISOUND 22'd151515
`define MUTE    22'd1000
`define TOPVOL 16'd1000_0000_0000_0000
`define MIDVOL 16'd0000_0100_0000_0000
`define BOTVOL 16'd0000_0000_0000_0001
`define ALL1 16'hFFFF

module speaker( 
input wire clk, // clock from crystal 
input wire rst_n, // active low reset 
output wire audio_mclk, // master clock 
output wire audio_lrck, // left-right clock 
output wire audio_sck, // serial clock 
output wire audio_sdin, // serial audio data input 
input wire lBtn,
input wire mBtn,
input wire rBtn,
input wire uBtn,
input wire dBtn,
output reg [15:0] led
); 

// Declare internal nodes 
wire [15:0] audio_in_left, audio_in_right; 
wire [4:0] cntParallelToSerial;
wire debLBtn;
wire debMBtn;
wire debRBtn;
wire debUBtn;
wire debDBtn;
wire opLBtn;
wire opMBtn;
wire opRBtn;
wire opUBtn;
wire opDBtn;
wire clk1hz;
wire [3:0]AN;

reg [21:0] curTone;
reg [21:0] nextTone;
reg [1:0] curDbgTone;
reg [1:0] nextDbgTone;
reg [15:0] curVolumn;
reg [15:0] nextVolumn;
reg [3:0] curDbgVol;
reg [3:0] nextDbgVol;
wire [15:0] curNegVol;

wire [15:0] inputPosVol;
wire [15:0] inputNegVol;

assign inputPosVol = (curTone==`MUTE)? 0 : curVolumn;
assign inputNegVol = (curTone==`MUTE)? 0 : curNegVol;
// Note generation 
buzzerControl Ung( 
.clk(clk), // clock from crystal 
.rst_n(rst_n), // active low reset 
.note_div(curTone/*22'd191571*/), // div for note generation 
.audio_left(audio_in_left), // left sound audio 
.audio_right(audio_in_right), // right sound audio 
.posVol(inputPosVol),
.negVol(inputNegVol)
);

assign curNegVol =  (curVolumn[15:0] ^ `ALL1) + 1;
// Speaker controllor 
speakerControl Usc( 
.clk(clk), // clock from the crystal 
.rst_n(rst_n), // active low reset 
.lChannel(audio_in_left), // left channel audio data input 
.rChannel(audio_in_right), // right channel audio data input 
.mclk(audio_mclk), // master clock 
.lrclk(audio_lrck), // left-right clock 
.sclk(audio_sck), // serial clock 
.sdin(audio_sdin), // serial audio data input 
.curCnt(cntParallelToSerial[4:0])
); 

debounce debL(.button(lBtn),.clk(clk),.res(debLBtn));
onePulse opL(.clk(clk1hz),.pulse(debLBtn),.res(opLBtn));

debounce debM(.button(mBtn),.clk(clk),.res(debMBtn));
onePulse opM(.clk(clk1hz),.pulse(debMBtn),.res(opMBtn));

debounce debR(.button(rBtn),.clk(clk),.res(debRBtn));
onePulse opR(.clk(clk1hz),.pulse(debRBtn),.res(opRBtn));

clkDivider #(.divbit(24)) CLKLDIVIDER(.clk(clk),.divclk(clk1hz),.AN(AN[3:0]));

always @(posedge clk1hz or negedge rst_n) begin
    if(~rst_n)begin
        curVolumn <= `MIDVOL;
        curDbgVol <= 13;
    end else begin
        curVolumn <= nextVolumn;
        curDbgVol <= nextDbgVol;
    end
end

always @(*) begin
    if(opUBtn)begin
        if(curVolumn == `TOPVOL)begin
            nextVolumn = `TOPVOL;
            nextDbgVol = 15;
        end else begin
            nextVolumn = curVolumn << 1;
            nextDbgVol = curDbgVol +1;
        end
    end else begin
        if(opDBtn)begin
            if(curVolumn == `BOTVOL)begin
                nextVolumn = `BOTVOL;
                nextDbgVol = 0;
            end else begin
                nextVolumn = curVolumn >> 1;
                nextDbgVol = curDbgVol -1;
            end
        end else begin
            nextVolumn = curVolumn;
            nextDbgVol = curDbgVol;
        end
    end
end

//always @(posedge clk1hz or negedge rst_n) begin
//    if(~rst_n)begin
//        curTone <= `DOSOUND;
//        curDbgTone <= 0;
//    end else begin
//        curTone <= nextTone;
//        curDbgTone <= nextDbgTone;
//    end
//end
//
//always @(*) begin
//    if(opLBtn)begin
//        nextTone = `DOSOUND;
//        nextDbgTone = 0;
//    end else begin
//       if(opMBtn)begin
//           nextTone = `RESOUND;
//           nextDbgTone = 1;
//       end else begin
//           if(opRBtn)begin
//               nextTone = `MISOUND;
//               nextDbgTone = 2;
//           end else begin
//               nextTone = `MUTE;
//               nextDbgTone = 3;
//           end
//       end
//    end
//end

reg [3:0] cnt;
reg [3:0] ncnt;

always @(posedge clk1hz) begin
    if(rst_n)begin
        cnt <= 0;
        curTone <= 0;
    end else begin
        cnt <= ncnt; 
        curTone <= nextTone;
    end
end

always @(*) begin
    if(opMBtn)begin
        ncnt = 1;
        nextTone = `DOSOUND;
    end else if(opRBtn)begin
        ncnt = 2;
        nextTone = `RESOUND;
    end else begin
        ncnt = 0;
        nextTone = `MUTE;
    end
end

always @(*) begin
    led[15:12] = cnt;

    led[7] = mBtn;
    led[6] = rBtn;
    led[5] = opMBtn;
    led[4] = opRBtn;
    led[3] = dBtn;
    led[1:0] = curDbgTone[1:0];
end

endmodule

module btnClkDiv(
input wire clk,
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
    case (curCounter[18:17])//change this part when deployed to FPGA
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
    curCounter <= nextCounter;
end
assign divclk = curCounter[divbit];
endmodule