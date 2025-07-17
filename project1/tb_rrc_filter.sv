`timescale 1ns/10ps

module tb_rrc_filter;

    logic clk, rstn;
    logic signed [6:0] data_in;
    logic signed [6:0] data_out;
    logic signed [6:0] adc_data_in [0:93695];

    initial begin
        clk = 1'b1;
        rstn = 1'b0;
        #55 rstn = 1'b1;
        //#500000 $finish;
    end

    always #5 clk = ~clk;

    integer fd_adc_di;
    integer fd_rrc_do;
    integer i;
    int data;
    logic [23:0] adc_cnt;

    initial begin
        fd_adc_di = $fopen("./ofdm_i_adc_serial_out_fixed_30dB.txt", "r");
        fd_rrc_do = $fopen("./rrc_do2.txt", "w");
        i = 0;
        while (!$feof(fd_adc_di)) begin
            void'($fscanf(fd_adc_di, "%d\n", data));
            adc_data_in[i] = data;
            i = i + 1;
        end
    end

        always_ff @(negedge clk) begin
              $fwrite(fd_rrc_do, "%0d\n", data_out);
          if (adc_cnt >= 93695) begin  // 파일 길이에 맞게 종료
                $fclose(fd_rrc_do);
           $finish;
            end
        end
        
  

    
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn)
            adc_cnt <= 'h0;
        else
            adc_cnt <= adc_cnt + 1'b1;
    end

    logic [6:0] tmp_data_in;
    assign tmp_data_in = adc_data_in[adc_cnt];
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn)
            data_in <= 'h0;
        else
            data_in <= tmp_data_in;
    end

    rrc_filter #(.WIDTH(7)) i_rrc_filter (
        .clk(clk),
        .rstn(rstn),
        .data_in(data_in),
        .data_out(data_out)
    );

endmodule

