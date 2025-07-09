module clk_div#(parameter div_ratio_wd = 8)
    (
    input clk_ref,                              //clk signal to be divided
    input rst_n,                                //asynch active_low reset
    input clk_en,                               //if(clk_en) clk_out = clk_ref
    input [div_ratio_wd-1 : 0] div_ratio,       //f_out = f_ref/div_ratio
    output clk_out                              //divided clk
    );
    wire zero_flag = (div_ratio == 0);                                    //track zero ratio
    wire one_flag  = (div_ratio == 1);                                    //track one ratio
    wire odd_flag = div_ratio [0];                                        //set if the div_ratio is odd to maintain unequal low and high levels in case of odd div_ratoi
    wire tot_en = (clk_en & !zero_flag & !one_flag);                      //total enable to ensure thet the clk_en is high and the div_ratio isn't zero nor one. 
    wire [div_ratio_wd-2 : 0] div_ratio_shifted = div_ratio >> 1;         //floor the result of (div_ratio/2)
    reg clk_div;
    reg [div_ratio_wd-2 : 0] count;

    assign clk_out = tot_en? clk_div : clk_ref;  //selection line from the divided or reference clk to be the output

    always@(posedge clk_ref or negedge rst_n)
        begin
            if(!rst_n)
                begin
                    count = 0;
                    clk_div = 1;
                end
            else if(tot_en)
                begin
                    if(!odd_flag && count == div_ratio_shifted-1)    //even ratio
                        begin
                            clk_div = ~clk_div;
                            count = 0;
                        end
                    else if(odd_flag)                                //odd ratio
                        begin
                            if(((count == div_ratio_shifted) && !clk_div) || ((count == div_ratio_shifted-1) && clk_div))    
                                begin
                                    clk_div = ~clk_div;
                                    count = 0;
                                end
                            else
                                count = count + 1;
                        end
                    else //if none of the above conditions set, then increment the counter 
                        count = count + 1;
                end  
        end
endmodule