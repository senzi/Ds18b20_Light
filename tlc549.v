module tlc549_drive(clk,cs,sdate,clk_ad,reset,dateout);

input          clk,reset,sdate;

output         cs,clk_ad;
output  [7:0]  dateout;

reg            cs,clk_ad_r,clk_r;

reg     [7:0]  dateout, dateout_r;
reg     [7:0]  count;
reg     [2:0]  temp;
reg     [3:0]  cnt;

reg     [2:0]  c_st;
reg            mark;
reg            flag;

parameter [2:0]s0=0,s1=1,s2=2;

always@(posedge clk)
begin 
    if(count<119)
        count<=count+1;
    else begin 
        clk_r<=~clk_r;
        count<=0;
    end
end

always@(posedge clk)
begin 
    clk_ad_r<=~clk_r;
end

assign clk_ad=clk_ad_r;

always@(posedge clk_r or negedge reset)
begin 
    if(!reset)
        c_st<=s0;
    else 
        case(c_st)
            s0:
            begin 
                cs<=1;
                mark<=0;
                if(temp==3)
                begin 
                    temp<=0;
                    c_st<=s1;
                end
                else begin 
                    temp<=temp+1;
                    c_st<=s0;
                end
            end
            s1:
            begin 
                cs<=0;
                mark<=1;
                c_st<=s2;
            end
            s2:
            begin 
                cs<=0;
                mark<=1;
                if(flag==1)
                    c_st<=s0;
                else 
                    c_st<=s2;
            end
            default:c_st<=s0;
        endcase
end

always@(posedge clk_ad_r)
begin
    if(mark==1)
    if(cnt==8)
        begin 
            cnt<=0;
            flag<=1;
        end
   else 
        begin 
            cnt<=cnt+1;
            flag<=0;
        end
end

always@(posedge clk_ad_r)
begin
    if(mark==1)
    if(flag==1)
        dateout<=dateout_r;
    else 
        dateout_r<={dateout_r[6:0],sdate};
end

endmodule
