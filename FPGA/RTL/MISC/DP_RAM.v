// DP_RAM.vhd
// DP_RAM()
//
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
    , input tri0 [C_DAT_W-1:0]  WD_i
    , input tri0 [C_ADR_W-1:0]  WA_i
    , input tri0 [C_ADR_W-1:0]  RA_i
    , output[C_DAT_W-1:0]       RD_o 
) ;
    reg [C_DAT_W-1:0]   BIT_CELL    [0 : 2**C_ADR_W-1] ;
    reg [C_ADR_W-1:0]   WA_D ;
    reg [C_DAT_W-1:0]   WD_D ;
    reg                 WE_D ;
    always @(posedge W_CK_i or negedge XARST_i ) 
        if( ~ XARST_i )
        begin
            WA_D <= 'd0 ;
            WD_D <= 'd0 ;
            WE_D <= 1'd0 ;
        end else
        begin 
            WA_D <= WA_i ;
            WD_D <= WD_i ;
            WE_D <= WE_i ;
            if( WE_D )
                BIT_CELL[ WA_D  ] <= WD_D ;
        end

    reg [C_ADR_W-1:0]   RA_D ;
    reg [C_DAT_W-1:0]   RD   ;
    always @(posedge R_CK_i or negedge XARST_i ) 
        if( ~ XARST_i  )
        begin
            RA_D <= 'd0 ;
            RD <= 'd0 ;
        end else
        begin
            RA_D <= RA_i ;
            RD  <= BIT_CELL[ RA_D ] ;
        end
    assign RD_o = RD ;
endmodule
// DP_RAM()
