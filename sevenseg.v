`timescale 1ns / 1ps

`define A  0
`define B  1
`define C  2
`define D  3
`define E  4
`define F  5
`define G  6
`define DP 7

module sevenSegment (
input wire [3:0]i,
output wire [3:0]led,
output wire [7:0]ssd,
output wire [3:0]an
);
reg [7:0] SSD;
assign led[3:0] = i[3:0];
assign an[3:0] = 4'b0011; //to check 1/0 trigger
assign ssd = 8'b1111_1111 ^ SSD[7:0];
always @(*) begin
    case (i)
        4'b0000:begin //0
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  0;
            SSD[`DP] = 0;
        end

        4'b0001:begin //1
            SSD[`A] =  0;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  0;
            SSD[`E] =  0;
            SSD[`F] =  0;
            SSD[`G] =  0;
            SSD[`DP] = 0;
        end
        4'b0010:begin //2
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  0;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  0;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b0011:begin //3
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  0;
            SSD[`F] =  0;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b0100:begin //4
            SSD[`A] =  0;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  0;
            SSD[`E] =  0;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b0101:begin //5
            SSD[`A] =  1;
            SSD[`B] =  0;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  0;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b0110:begin //6
            SSD[`A] =  1;
            SSD[`B] =  0;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b0111:begin //7
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  0;
            SSD[`E] =  0;
            SSD[`F] =  0;
            SSD[`G] =  0;
            SSD[`DP] = 0;
        end
        4'b1000:begin //8
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b1001:begin //9
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  0;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b1010:begin //A(10)
            SSD[`A] =  1;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  0;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b1011:begin //B(11)
            SSD[`A] =  0;
            SSD[`B] =  0;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b1100:begin //C(12)
            SSD[`A] =  1;
            SSD[`B] =  0;
            SSD[`C] =  0;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  0;
            SSD[`DP] = 0;
        end
        4'b1101:begin //D(13)
            SSD[`A] =  0;
            SSD[`B] =  1;
            SSD[`C] =  1;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  0;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        4'b1110:begin //E(14)
            SSD[`A] =  1;
            SSD[`B] =  0;
            SSD[`C] =  0;
            SSD[`D] =  1;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
        default:begin //F(15)
            SSD[`A] =  1;
            SSD[`B] =  0;
            SSD[`C] =  0;
            SSD[`D] =  0;
            SSD[`E] =  1;
            SSD[`F] =  1;
            SSD[`G] =  1;
            SSD[`DP] = 0;
        end
    endcase
end

endmodule