`timescale 1 ns / 1 ns


module btn_xd(i_clk, i_btn, o_btn);
   parameter [18:0] n = 19'b1111010000100100000;
   input            i_clk;
   input            i_btn;
   output           o_btn;
   reg              o_btn;
   
   reg [18:0]       count;
   
   
   always @(posedge i_clk)
      
      begin
         if (i_btn == 1'b1)
         begin
            if (count == n)
               count <= count;
            else
               count <= count + 1;
            if (count == n - 1)
               o_btn <= 1'b1;
            else
               o_btn <= 1'b0;
         end
         else
            count <= {19{1'b0}};
      end
   
endmodule
