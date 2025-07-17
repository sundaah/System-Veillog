`timescale 1ns/1ps

module rrc_filter #(
    parameter WIDTH = 7
)(
    input clk,
    input rstn,
    input [WIDTH-1:0] data_in,  // <1.8>
    output logic signed [WIDTH-1:0] data_out
);

    // Shift register for samples
    logic signed [WIDTH-1:0] shift_din [32:0];
    integer i;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 33; i = i+1)
                shift_din[i] <= 0;
        end else begin
            for (i = 32; i > 0; i = i -1)
                shift_din[i] <= shift_din[i-1];
            shift_din[0] <= data_in;
        end
    end

    // Tap multiplication
    logic signed [WIDTH+9-1:0] mul [32:0];
    always @(*) begin
   mul[ 0] = shift_din[ 0]*0;
   mul[ 1] = shift_din[ 1]*(-1);
   mul[ 2] = shift_din[ 2]*1;
   mul[ 3] = shift_din[ 3]*0;
   mul[ 4] = shift_din[ 4]*(-1);
   mul[ 5] = shift_din[ 5]*2;
   mul[ 6] = shift_din[ 6]*0;
   mul[ 7] = shift_din[ 7]*(-2);
   mul[ 8] = shift_din[ 8]*2;
   mul[ 9] = shift_din[ 9]*0;
   mul[10] = shift_din[10]*(-6);
   mul[11] = shift_din[11]*8;
   mul[12] = shift_din[12]*10;
   mul[13] = shift_din[13]*(-28);
   mul[14] = shift_din[14]*(-14);
   mul[15] = shift_din[15]*111;
   mul[16] = shift_din[16]*196;
   mul[17] = shift_din[17]*111;
   mul[18] = shift_din[18]*(-14);
   mul[19] = shift_din[19]*(-28);
   mul[20] = shift_din[20]*10;
   mul[21] = shift_din[21]*8;
   mul[22] = shift_din[22]*(-6);
   mul[23] = shift_din[23]*0;
   mul[24] = shift_din[24]*2;
   mul[25] = shift_din[25]*(-2);
   mul[26] = shift_din[26]*0;
   mul[27] = shift_din[27]*2;
   mul[28] = shift_din[28]*(-1);
   mul[29] = shift_din[29]*0;
   mul[30] = shift_din[30]*1;
   mul[31] = shift_din[31]*(-1);
   mul[32] = shift_din[32]*0;
    end



    // Summation
    logic signed [WIDTH+16-1:0] filter_sum;
    always @(*) begin
        filter_sum = 0;
        for (i = 0; i < 33; i = i+1)
            filter_sum = filter_sum + mul[i];
    end

    // Truncation and saturation
    logic signed [WIDTH+8-1:0] trunc_filter_sum;
    assign trunc_filter_sum = filter_sum[WIDTH+16-1:8];

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn)
            data_out <= 'h0;
        else if (trunc_filter_sum > 63)
            data_out <= 63;
        else if (trunc_filter_sum < -64)
            data_out <= -64;
        else
            data_out <= trunc_filter_sum[WIDTH-1:0];
    end

endmodule
