`timescale 1ns / 1ps
module buzzerControl( 
input wire clk, // clock from crystal 
input wire rst_n, // active low reset 
input [21:0] note_div, // div for note generation 
output [15:0] audio_left, // left sound audio 
output [15:0] audio_right, // right sound audio 
input wire [15:0] posVol,
input wire [15:0] negVol
); 
// Declare internal signals 
reg [21:0] clk_cnt_next, clk_cnt; 
reg b_clk, b_clk_next;

// Note frequency generation 
always @(posedge clk or negedge rst_n)begin
    if (~rst_n) begin 
        clk_cnt <= 22'd0; 
        b_clk <= 1'b0; 
    end else begin 
        clk_cnt <= clk_cnt_next; 
        b_clk <= b_clk_next; 
    end     
end

always @(*) begin
    if (clk_cnt == note_div) begin 
        clk_cnt_next = 22'd0; 
        b_clk_next = ~b_clk; 
    end else begin 
        clk_cnt_next = clk_cnt + 1'b1; 
        b_clk_next = b_clk; 
    end 
end
 
// Assign the amplitude of the note 
assign audio_left = (b_clk == 1'b0) ? negVol[15:0] : posVol[15:0]; 
assign audio_right = (b_clk == 1'b0) ? negVol[15:0] : posVol[15:0]; 
endmodule
