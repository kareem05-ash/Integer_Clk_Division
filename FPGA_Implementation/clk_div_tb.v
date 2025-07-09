`timescale 1ns/1ps
module clk_div_tb();
    parameter div_ratio_wd = 8;
    reg clk_ref;                              //clk signal to be divided
    reg rst_n;                                //asynch active_low reset
    reg clk_en;                               //if(clk_en) clk_out = clk_ref
    reg [div_ratio_wd-1 : 0] div_ratio;       //f_out = f_ref/div_ratio
    wire clk_out;                             //divided clk

    clk_div dut(
                .clk_ref(clk_ref),
                .rst_n(rst_n), 
                .clk_en(clk_en),
                .div_ratio(div_ratio),
                .clk_out(clk_out)
    );

    initial             ////clk_ref generation////
        begin
            clk_ref = 0;
            forever #5 clk_ref = ~clk_ref;
        end

    initial             ////showing waveform////
        begin
            $dumpfile("waveform.vcd");
            $dumpvars(0, clk_div_tb);
        end

    initial                 ////stimulus////
        begin
            rst_n = 0; #10; //activate rst_n
            rst_n = 1; #10; //release rst_n
            
                        //first scenario : even div_ratio 

            clk_en = 1; div_ratio = 2;
            repeat(10) @(negedge clk_ref);

                        //second scenario : odd div_ratio

            clk_en = 1; div_ratio = 3;
            repeat(10) @(negedge clk_ref);

                        //third scenario : grater even div_ratio

            clk_en = 1; div_ratio = 6;
            repeat(20) @(negedge clk_ref);

                        //fourth scenario : greater odd div_ratio

            clk_en = 1; div_ratio = 7;
            repeat(20) @(negedge clk_ref);

            #20; $stop;
        end
endmodule