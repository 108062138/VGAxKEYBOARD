`timescale 1ns / 1ps
/*useage: when taking an instance, the grammer is shown as follow*/
//clkDivider #(.divbit(6)) CLKLDIVIDER(
//.clk(CLK),
//.divclk(DIVCLK),
//.AN(AN[3:0])
//);
//noted that the parameter divbit should be #(.divbit(?))
module clkDivider(
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