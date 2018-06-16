// DP_RAM.v
//  DP_RAM()
//
//180531r       :mod sig name
//180426r       :mod new coding rule
//2018-03-09f   :mod new coding rule like BSD style
//2012-01-01??  :1st
module DP_RAM
#( 
      parameter C_DAT_W = 8
    , parameter C_ADR_W = 10
)(
      input                     W_CK_i
    , input                     R_CK_i
    , input tri1                XAR_i
    , input tri1                WCK_EE_i
    , input tri0                WE_i
    , input tri0 [C_DAT_W-1:0]  WDs_i
    , input tri0 [C_ADR_W-1:0]  WAs_i
    , input tri1                RCK_EE_i
    , input tri0 [C_ADR_W-1:0]  RAs_i
    , output[C_DAT_W-1:0]       RDs_o 
) ;
    reg [C_DAT_W-1:0]   BIT_CELLs    [0 : 2**C_ADR_W-1] ;
    reg [C_ADR_W-1:0]   WAs_D ;
    reg [C_DAT_W-1:0]   WDs_D ;
    reg                 WE_D ;

    always @(posedge W_CK_i or negedge XAR_i ) 
        if( ~ XAR_i )
        begin
            WAs_D <= 'd0 ;
            WDs_D <= 'd0 ;
            WE_D <= 1'd0 ;
        end else if( WCK_EE_i )
        begin 
            WAs_D <= WAs_i ;
            WDs_D <= WDs_i ;
            WE_D <= WE_i ;
        end
    always @(posedge W_CK_i ) 
        if(WCK_EE_i)
            if( WE_D )
                BIT_CELLs[ WAs_D  ] <= WDs_D ;

    reg [C_ADR_W-1:0]   RAs_AD ;
    reg [C_ADR_W-1:0]   RAs ;
//    reg [C_DAT_W-1:0]   RDs_AD ;
//    reg [C_DAT_W-1:0]   RDs   ;
    always @(posedge R_CK_i or negedge XAR_i ) 
        if( ~ XAR_i  )
        begin
            RAs_AD <= 'd0 ;
            RAs <= 'd0 ;
        end else if( RCK_EE_i )
        begin
            RAs_AD  <= RAs_i ;
            RAs <= RAs_AD  ;
        end
    assign RDs_o = BIT_CELLs[ RAs ]  ;
endmodule
// DP_RAM()


module DP_RAM_BRG
#( 
      parameter C_DAT_W = 8
    , parameter C_ADR_W = 10
)(
      input                     W_CK_i
    , input                     R_CK_i
    , input tri1                XAR_i
    , input tri0                WE_i
    , input tri0 [C_DAT_W-1:0]  WDs_i
    , input tri0 [C_ADR_W-1:0]  WAs_i
    , input tri0 [C_ADR_W-1:0]  RAs_i
    , output[C_DAT_W-1:0]       RDs_o 
) ;

    reg [C_DAT_W-1:0]   WDs ;
    reg [C_ADR_W-1:0]   WAs ;
    reg                 WE  ;
    always@(posedge W_CK_i or negedge XAR_i)
        if( ~ XAR_i)
        begin
            WDs <= 0 ;
            WAs <= 0 ;
            WE  <= 0 ;
        end else
        begin
            WDs <= WDs_i ;
            WAs <= WAs_i ;
            WE  <= WE_i ;
        end
    

    wire [C_DAT_W-1:0]   RDs ;
    DP_RAM
    #( 
          .C_DAT_W  (  8    )
        , .C_ADR_W  ( 10    )
    )DP_RAM
    (
          .W_CK_i   ( W_CK_i)
        , .R_CK_i   ( R_CK_i)
        , .XAR_i    ( XAR_i )
        , .WE_i     ( WE  )
        , .WDs_i    ( WDs )
        , .WAs_i    ( WAs )
        , .RAs_i    ( RAs )
        , .RDs_o    ( RDs ) 
    ) ;  
    reg [C_ADR_W-1:0]   RAs ;
    reg [C_DAT_W-1:0]   Q_RDs ;
    always@(posedge R_CK_i or negedge XAR_i)
        if( ~ XAR_i)
        begin
            RAs <= 0 ;
            Q_RDs <= 0 ;
        end else
        begin
            RAs <= RAs_i;
            Q_RDs <= RDs ;
        end
    assign RDs_o = Q_RDs ;

endmodule 
//DP_RAM_BRG()
