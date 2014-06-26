`timescale 1ns / 1ps
module ds18b20_drive(
  input         clk,                  // 50MHzʱ��
  input         rst,                  // ��λ
  inout         one_wire,             // One-Wire����
  output [15:0] temperature          // ����¶�ֵ 
);

//++++++++++++++++++++++++++++++++++++++
// ��Ƶ��50MHz->1MHz ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [5:0] cnt;                         // ������

always @ (posedge clk or posedge rst)
  if (rst)
    cnt <= 0;
  else
    if (cnt == 49)
      cnt <= 0;
    else
      cnt <= cnt + 1'b1;

reg clk_1us;                            // 1MHz ʱ��

always @ (posedge clk or posedge rst)
  if (rst)
    clk_1us <= 0;
  else
    if (cnt <= 24)                      // 24 = 50/2 - 1
      clk_1us <= 0;
    else
      clk_1us <= 1;      

//--------------------------------------
// ��Ƶ��50MHz->1MHz ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// ��ʱģ�� ��ʼ
//++++++++++++++++++++++++++++++++++++++
reg [19:0] cnt_1us;                      // 1us��ʱ������
reg cnt_1us_clear;                       // ��1us��ʱ������

always @ (posedge clk_1us)
  if (cnt_1us_clear)
    cnt_1us <= 0;
  else
    cnt_1us <= cnt_1us + 1'b1;
//--------------------------------------
// ��ʱģ�� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// DS18B20״̬�� ��ʼ
//++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++++++++
// ������
parameter S00     = 5'h00;
parameter S0      = 5'h01;
parameter S1      = 5'h03;
parameter S2      = 5'h02;
parameter S3      = 5'h06;
parameter S4      = 5'h07;
parameter S5      = 5'h05;
parameter S6      = 5'h04;
parameter S7      = 5'h0C;
parameter WRITE0  = 5'h0D;
parameter WRITE1  = 5'h0F;
parameter WRITE00 = 5'h0E;
parameter WRITE01 = 5'h0A;
parameter READ0   = 5'h0B;
parameter READ1   = 5'h09;
parameter READ2   = 5'h08;
parameter READ3   = 5'h18;

reg [4:0] state;                       // ״̬�Ĵ���
//-------------------------------------

reg one_wire_buf;                      // One-Wire���� ����Ĵ���

reg [15:0] temperature_buf;            // �ɼ������¶�ֵ��������δ����
reg [5:0] step;                        // ��״̬�Ĵ��� 0~50
reg [3:0] bit_valid;                   // ��Чλ  
  
always @(posedge clk_1us, posedge rst)
begin
  if (rst)
  begin
    one_wire_buf <= 1'bZ;
    step         <= 0;
    state        <= S00;
  end
  else
  begin
    case (state)
      S00 : begin              
              temperature_buf <= 16'h001F;
              state           <= S0;
            end
      S0 :  begin                       // ��ʼ��
              cnt_1us_clear <= 1;
              one_wire_buf  <= 0;              
              state         <= S1;
            end
      S1 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 500)         // ��ʱ500us
              begin
                cnt_1us_clear <= 1;
                one_wire_buf  <= 1'bZ;  // �ͷ�����
                state         <= S2;
              end 
            end
      S2 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 100)         // �ȴ�100us
              begin
                cnt_1us_clear <= 1;
                state         <= S3;
              end 
            end
      S3 :  if (~one_wire)              // ��18b20��������,��ʼ���ɹ�
              state <= S4;
            else if (one_wire)          // ����,��ʼ�����ɹ�,����S0
              state <= S0;
      S4 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 400)         // ����ʱ400us
              begin
                cnt_1us_clear <= 1;
                state         <= S5;
              end 
            end        
      S5 :  begin                       // д����
              if      (step == 0)       // 0xCC
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 1)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 2)
              begin                
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01; 
              end
              else if (step == 3)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 4)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 5)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 6)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 7)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              
              else if (step == 8)       // 0x44
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 9)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 10)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 11)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 12)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 13)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 14)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
                 
              end
              else if (step == 15)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              
              // ��һ��д��,750ms��,����S0
              else if (step == 16)
              begin
                one_wire_buf <= 1'bZ;
                step         <= step + 1'b1;
                state        <= S6;                
              end
              
              // �ٴ�����0xCC��0xBE
              else if (step == 17)      // 0xCC
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 18)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 19)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 20)
              begin
                step  <= step + 1'b1;
                state <= WRITE01;
                one_wire_buf <= 0;
              end
              else if (step == 21)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 22)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 23)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 24)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;               
              end
              
              else if (step == 25)      // 0xBE
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 26)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 27)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 28)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;                
              end
              else if (step == 29)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 30)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              else if (step == 31)
              begin
                step  <= step + 1'b1;
                state <= WRITE0;
              end
              else if (step == 32)
              begin
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= WRITE01;
              end
              
              // �ڶ���д��,����S7,ֱ�ӿ�ʼ������
              else if (step == 33)
              begin
                step  <= step + 1'b1;
                state <= S7;
              end 
            end
      S6 :  begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 750000 | one_wire)     // ��ʱ750ms!!!!
              begin
                cnt_1us_clear <= 1;
                state         <= S0;    // ����S0,�ٴγ�ʼ��
              end 
            end
            
      S7 :  begin                       // ������
              if      (step == 34)
              begin
                bit_valid    <= 0;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 35)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 36)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 37)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;               
              end
              else if (step == 38)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 39)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;               
              end
              else if (step == 40)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 41)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 42)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 43)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;
              end
              else if (step == 44)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 45)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 46)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 47)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 48)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 49)
              begin
                bit_valid    <= bit_valid + 1'b1;
                one_wire_buf <= 0;
                step         <= step + 1'b1;
                state        <= READ0;                
              end
              else if (step == 50)
              begin
                step  <= 0;
                state <= S0;
              end 
            end            
            
            
      //++++++++++++++++++++++++++++++++
      // д״̬��
      //++++++++++++++++++++++++++++++++
      WRITE0 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 0;       // ���0             
              if (cnt_1us == 80)        // ��ʱ80us
              begin
                cnt_1us_clear <= 1;
                one_wire_buf  <= 1'bZ;  // �ͷ����ߣ��Զ�����                
                state         <= WRITE00;
              end 
            end
      WRITE00 :                         // ��״̬
              state <= S5;
      WRITE01 :                         // ��״̬
              state <= WRITE1;
      WRITE1 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 1'bZ;    // ���1   �ͷ����ߣ��Զ�����
              if (cnt_1us == 80)        // ��ʱ80us
              begin
                cnt_1us_clear <= 1;
                state         <= S5;
              end 
            end
      //--------------------------------
      // д״̬��
      //--------------------------------
      
      
      //++++++++++++++++++++++++++++++++
      // ��״̬��
      //++++++++++++++++++++++++++++++++
      READ0 : state <= READ1;           // ����ʱ״̬
      READ1 :
            begin
              cnt_1us_clear <= 0;
              one_wire_buf  <= 1'bZ;    // �ͷ�����
              if (cnt_1us == 10)        // ����ʱ10us
              begin
                cnt_1us_clear <= 1;
                state         <= READ2;
              end 
            end
      READ2 :                           // ��ȡ����
            begin
              temperature_buf[bit_valid] <= one_wire;
              state                      <= READ3;
            end
      READ3 :
            begin
              cnt_1us_clear <= 0;
              if (cnt_1us == 55)        // ����ʱ55us
              begin
                cnt_1us_clear <= 1;
                state         <= S7;
              end 
            end
      //--------------------------------
      // ��״̬��
      //--------------------------------
      
      
      default : state <= S00;
    endcase 
  end 
end 

assign one_wire = one_wire_buf;         // ע��˫��ڵ�ʹ��
//--------------------------------------
// DS18B20״̬�� ����
//--------------------------------------


//++++++++++++++++++++++++++++++++++++++
// �Բɼ������¶Ƚ��д��� ��ʼ תBCD��
//++++++++++++++++++++++++++++++++++++++
reg [15:4] reg_temperature;
assign temperature[3 : 0] = (temperature_buf[3:0] * 10) >> 4;
assign temperature[15: 4] =  reg_temperature[15:4] ;  

  wire[2:0] c_in;
  wire[2:0] c_out;
  reg [3:0] dec_sreg0;
  reg [3:0] dec_sreg1;
  reg [3:0] dec_sreg2;
  wire[3:0] next_sreg0,next_sreg1,next_sreg2;
  
  reg [3:0] bit_cnt;
  reg [7:0] bin_sreg;
  
wire load=~|bit_cnt;//������������ݣ�׼��ת��
wire convert_ready= (bit_cnt==4'h9);//ת���ɹ�
wire convert_end= (bit_cnt==4'ha);//��ϣ����¿�ʼ
/********************************************************/
always @ (posedge clk)
begin
  if(convert_end) bit_cnt<=4'h0;
  else bit_cnt<=bit_cnt+4'h1; 
end
/*******************************************************/ 
always @ (posedge clk)
begin
  if(load) bin_sreg<=temperature_buf[11:4];
  else bin_sreg <={bin_sreg[6:0],1'b0};
end

assign c_in[0] =bin_sreg[7];
assign c_in[1] =(dec_sreg0>=5);
assign c_in[2] =(dec_sreg1>=5);

assign c_out[0]=c_in[1];
assign c_out[1]=c_in[2];
assign c_out[2]=(dec_sreg2>=5);

//ȷ����λ���
assign next_sreg0=c_out[0]? ({dec_sreg0[2:0],c_in[0]}+4'h6):({dec_sreg0[2:0],c_in[0]});
assign next_sreg1=c_out[1]? ({dec_sreg1[2:0],c_in[1]}+4'h6):({dec_sreg1[2:0],c_in[1]});
assign next_sreg2=c_out[2]? ({dec_sreg2[2:0],c_in[2]}+4'h6):({dec_sreg2[2:0],c_in[2]});


//װ������
/********************************************************************/
always @ (posedge clk)
begin
  if(load) 
    begin 
      dec_sreg0<=4'h0;
      dec_sreg1<=4'h0;
      dec_sreg2<=4'h0;
    end     
  else  
    begin
      dec_sreg0<=next_sreg0;
      dec_sreg1<=next_sreg1;
      dec_sreg2<=next_sreg2;
    end
end

//���
/*******************************************************************/

always @ (posedge clk)
begin
  if(convert_ready) 
    begin 
      reg_temperature[7:4]<=dec_sreg0;
      reg_temperature[11:8]<=dec_sreg1;
      reg_temperature[15:12]<=dec_sreg2;
    end     
end
//--------------------------------------
// �Բɼ������¶Ƚ��д��� ����
//--------------------------------------  

endmodule