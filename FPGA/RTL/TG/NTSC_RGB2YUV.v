// $Id: $
// file_name    : NTSC_RGB2YUV.v
// descript     : for 4fsc 
//
//180629f :fix RGB ratio to Y
//180624u: 1st.
module NTSC_RGB2YUV
(
      input             CK_i     
    , input tri1        XAR_i 
    , input tri1        CK_EE_i 
    , input tri0 [ 7 :0] DATs_R_i
    , input tri0 [ 7 :0] DATs_G_i
    , input tri0 [ 7 :0] DATs_B_i
    , output [ 7:0] YYs_o
    , output [ 7:0] UUs_o
    , output [ 7:0] VVs_o
) ;

    // Y = (77R+ 150G + 29B)/256
    localparam C_K_R = 8'h4D ;
    localparam C_K_G = 8'h96 ;
    localparam C_K_B = 8'h1D ;

    wire [15:0] yy_s ;
    assign yy_s = 
          C_K_R * DATs_R_i 
        + C_K_G * DATs_G_i
        + C_K_B * DATs_B_i
    ;
    reg [ 7 :0]     YYs_AQ ;
    always@(posedge CK_i or negedge XAR_i) 
        if( ~ XAR_i)
            YYs_AQ <= 8'd0 ;
        else if( CK_EE_i )
            YYs_AQ <= (0+yy_s) >> 8 ;

    // C_K_U = 256/2.03 =126
    // C_K_V = 256/1.14 = 224
    localparam C_K_U = 8'h7E ;
    localparam C_K_V = 8'hE0 ;
    wire signed [16:0] uu_s ;
    wire signed [16:0] vv_s ;
    assign uu_s = (0+DATs_B_i - (0+YYs_AQ)) * C_K_U ;
    assign vv_s = (0+DATs_R_i - (0+YYs_AQ)) * C_K_V ;

    reg     [ 8:0]  VIDEOs   ;
    wire    [9:0]  VIDEOs_a ;

    //      UU,VV is 2's s2
    reg [ 7 :0]     YYs ;
    reg [ 7 :0]     UUs ;
    reg [ 7 :0]     VVs ;
    always@(posedge CK_i or negedge XAR_i) 
        if( ~ XAR_i)
        begin
            YYs <= 8'd0 ;
            UUs <= 8'd0 ;
            VVs <= 8'd0 ;
        end else if( CK_EE_i)
        begin
            YYs <= YYs_AQ ;
            UUs <= (0+uu_s)>>> 8 ;
            VVs <= (0+vv_s)>>> 8 ;
        end 
    assign YYs_o = YYs ;
    assign UUs_o = UUs ;
    assign VVs_o = VVs ;
endmodule
// NTSC_RGB2YUV.v
