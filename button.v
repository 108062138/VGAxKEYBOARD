`timescale 1ns / 1ps

module debounce(
input wire button,
input wire clk,
output reg res
);

reg [2:0] currentState;
reg [2:0] nextState;

initial begin
    currentState[2:0] = 3'b000;
end

always @(posedge clk) begin
    currentState[2:0] <= nextState[2:0];
end

always @(*) begin
    if(currentState[2:0] == 3'b100)begin
        res = 1;
    end else begin
        res = 0;
    end
end

always @(*) begin
    case (currentState[2:0])
        3'b000: begin
            nextState[2:0] = (button)?3'b001:3'b000;
        end
        3'b001: begin
            nextState[2:0] = (button)?3'b010:3'b000;
        end
        3'b010: begin
            nextState[2:0] = (button)?3'b011:3'b000;
        end
        3'b011: begin
            nextState[2:0] = (button)?3'b100:3'b000;
        end
        default: begin
            //nextState[2:0] = 3'b000;
            nextState[2:0] = (button)?3'b100:3'b000;
        end
    endcase
end
endmodule

module onePulse(
input wire clk,
input wire pulse,
output wire res
);
reg s;
reg sbar;

assign res = sbar & s;

initial begin
    sbar = 1'b1;
    s = 1'b0;
end
always @(*) begin
    s = pulse;
end
always @(posedge clk) begin
    sbar <= !pulse;
end

endmodule

module longer(
input wire clk,
input wire target,
output wire longer
);

reg [1:0] cnt;
reg [1:0] nextCnt;

assign longer = (cnt[1:0]==2'b11)? 1 : 0;

always @(*) begin
    if(target==0)begin
        nextCnt[1:0] = 0;
    end else begin
        nextCnt[1:0] = cnt[1:0] + 1;
    end
end

initial begin
    cnt = 2'b00;
end

always @(posedge clk) begin
    cnt[1:0] <= nextCnt[1:0];
end
endmodule