//NTSC_ENC_TINY.v
//  NTSC_ENC_TINY()
// for CHAR_GEN check
// by @mangakoji
// license by BSD
//      without font ROM data
//
//180617u       :1st

module NTSC_ENC_TINY
(
          input             CK_i
        , input tri1        XAR_i 
        , input tri1        CK_EE_i
        , input tri0 [ 7:0] YYs_i
        , input tri0        BURST_i   //1:BURST */
        , input tri0        BLANK_i    //1:BLANK */
        , input tri1        XSYNC_i    //0:SYNC */
        , output[ 9:0]  VIDEOs_o 
) ;
    localparam C_PEDESTAL = 10'h0F0 ;
    localparam C_SYNC_L = 10'h010 ;
    localparam C_COMP_GAIN = 32'h28C ; // 560/220=28/11====>
    reg [9:0] VIDEOs ;
//    wire [31:0] MUL_tmp;
//    assign MUL_tmp = C_COMP_GAIN * YYs_i ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            VIDEOs <= C_PEDESTAL ;
        else if( CK_EE_i )
            if( ~ XSYNC_i )
                VIDEOs <= C_SYNC_L;
            else
                if( BLANK_i)
                    VIDEOs <= C_PEDESTAL ;
                else 
                    VIDEOs <= 
                        ((C_COMP_GAIN * YYs_i)>> 8) 
                        + 
                        C_PEDESTAL
                    ;
    assign VIDEOs_o = VIDEOs ;
endmodule
//NTSC_ENC_TINY
