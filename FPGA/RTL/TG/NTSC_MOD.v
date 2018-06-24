// $Id: $
// file_name    : NTSC_ENC.v
// descript     : for 4fsc 
//
// 9bit output ! take care!!
//
//180624u       :mod 8bit 
//180426r       :mod for new coding rule
// 2013-02-23W6 : rename NTSC_ENC from color_enc
//                 append EE , and change more 
// 2009-07-27W1 : coding rure update
// 2004-05      : 1st.
module NTSC_MOD
(
      input             CK_i     
    , input tri1        XAR_i 
    , input tri1        CK_EE_i 
    , input tri1        XR_i     
    , input tri0 [ 7:0] YYs_i    
    , input tri0 [ 7:0] UUs_i    //2's  */
    , input tri0 [ 7:0] VVs_i    //2's  */
    , input tri0        BURST_i   //1:BURST */
    , input tri0        BLANK_i    //1:BLANK */
    , input tri1        XSYNC_i    //0:SYNC */
    , output [10:0] VIDEOs_aa_o 
    , output [ 8:0] VIDEOs_a_o 
    , output[ 8:0]  VIDEOs_o 
) ;
    // main part
    //      UU,VV is 2's s2
//    reg     [ 2 :0]   YYs_D , UUs_D, VVs_D ;
//    always@(posedge CK_i or negedge XAR_i) 
//        if( ~ XAR_i)
//        begin
//            YYs_D <= 8'd0 ;
//            UUs_D <= 8'd0 ;
//            VVs_D <= 8'd0 ;
//        end else if( CK_EE_i)
//        begin
//            YYs_D <= YYs_i;
//            UUs_D <= UUs_i ;
//            VVs_D <= VVs_i ;
//        end 

    wire    [ 7 :0]  UUs_y    ;
    assign  UUs_y = ( BURST_i) ? -8'd44 :(8'h80==UUs_i) ? 8'h81 : UUs_i ;
    wire    [ 7 :0]  VVs_y   ;
    assign  VVs_y = ( BURST_i) ?  8'd0  :(8'h80==VVs_i) ? 8'h81 : VVs_i ;
    wire    [ 7 :0]  chroma_s   ;
    function [7:0] f_chroma_s ;
        input [1:0] PHs ;
        input [7:0] UUs ;
        input [7:0] VVs ;
    begin
        if(BLANK_i & ~BURST_i)
            f_chroma_s = 8'h00 ;
        else
            case( PHs )
                2'b00 :
                    f_chroma_s = UUs ;
                2'b01 :
                    f_chroma_s = -VVs ;
                2'b10 :
                    f_chroma_s = -UUs   ;
                2'b11 :
                    f_chroma_s =  VVs ;
                default :
                    f_chroma_s = 8'h00 ;
            endcase
    end endfunction
    assign chroma_s = f_chroma_s( PHs , UUs_y , VVs_y) ;
    wire    [8 :0]  YYs_y      ;
    assign YYs_y =
        ( ~ XSYNC_i ) 
        ?
            9'h019
        : (BLANK_i | BURST_i ) 
        ?
            9'h080
        :
            YYs_i[ 7 :0] + 9'h080
    ;

    wire [10 :0]    VIDEOs_aa    ;
    assign VIDEOs_aa =  {2'b00, YYs_y} + $signed( chroma_s ) ;
    assign VIDEOs_aa_o = VIDEOs_aa ;
    wire [ 8 :0]    VIDEOs_a ;
    assign VIDEOs_a =
        (VIDEOs_aa[ 10 ] &  ~VIDEOs_aa[ 9 ]) 
        ?   
            9'h000
        : ( ~ VIDEOs_aa[ 10 ] & VIDEOs_aa[9] ) 
        ?
            9'h1FF
        :
            VIDEOs_aa[ 8 :0]
    ;
    assign VIDEOs_a_o = VIDEOs_a ;

    reg     [ 8:0]  VIDEOs   ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
            VIDEOs <= 9'h080 ;
        else if( CK_EE_i )
            VIDEOs <= ( ~ XR_i) ? 9'h080 : VIDEOs_a ;
    assign VIDEOs_o = VIDEOs ;

    // timing part
    reg     [ 1:0]  PHs      ;  // 4fsc auto run , dont extra reset.
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            PHs <= 2'b0 ;
        else if( CK_EE_i )
            PHs[1:0] <= 
                ( ~ XR_i) 
                ? 
                    2'd0 
                : {2{1'b1}} & (PHs + 2'd1) 
            ;
endmodule
// NTSC_MOD.v
