// DP_RAM.vhd
// DP_RAM()
//
//180426r       :mod new coding rule
//2018-03-09f   :mod new coding rule like BSD style
//2012-01-01??  :1st
module DP_RAM
#( 
      parameter C_DAT_W = 72
    , parameter C_ADR_W = 10
)(
      input                     W_CK_i
    , input                     R_CK_i
    , input tri1                XARST_i
    , input tri0                WE_i
    , input tri0 [C_DAT_W-1:0]  WDs_i
    , input tri0 [C_ADR_W-1:0]  WAs_i
    , input tri0 [C_ADR_W-1:0]  RAs_i
    , output[C_DAT_W-1:0]       RDs_o 
) ;
    reg [C_DAT_W-1:0]   BIT_CELLs    [0 : 2**C_ADR_W-1] ;
    reg [C_ADR_W-1:0]   WAs_D ;
    reg [C_DAT_W-1:0]   WDs_D ;
    reg                 WE_D ;
    always @(posedge W_CK_i or negedge XARST_i ) 
        if( ~ XARST_i )
        begin
            WAs_D <= 'd0 ;
            WDs_D <= 'd0 ;
            WE_D <= 1'd0 ;
        end else
        begin 
            WAs_D <= WAs_i ;
            WDs_D <= WDs_i ;
            WE_D <= WE_i ;
            if( WE_D )
                BIT_CELLs[ WAs_D  ] <= WDs_D ;
        end

    reg [C_ADR_W-1:0]   RAs_D ;
    reg [C_DAT_W-1:0]   RDs   ;
    always @(posedge R_CK_i or negedge XARST_i ) 
        if( ~ XARST_i  )
        begin
            RAs_D <= 'd0 ;
            RDs <= 'd0 ;
        end else
        begin
            RAs_D <= RA_i ;
            RDs  <= BIT_CELLs[ RAs_D ] ;
        end
    assign RDs_o = RDs ;
endmodule
// DP_RAM()
