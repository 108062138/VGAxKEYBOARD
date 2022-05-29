`timescale 1ns / 1ps

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

module myKeyBoard(
input wire clk,
input wire rst,
inout PS2_DATA,
inout PS2_CLK,
output wire [511:0] key_down,
output wire [8:0] last_change,
output reg [3:0] curKey,
output reg [3:0] nextKey
);
KeyboardDecoder KEYBOARDDECODER(
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(key_valid),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst),
    .clk(clk));
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

endmodule
