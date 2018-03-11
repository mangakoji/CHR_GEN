//CHR_GEN.vhd<
//CHR_GEN()
// by @mangakoji
// license by BSD
//      without font ROM data
//
//2018-03-11u   :mod new coding rule like BSD style
//              :many debug
//2014-??-??
//2010-01-01?? : 1st.
module CHR_GEN
(
      input             CK_i
    , input tri1        XARST_i
    , input tri1        XHD_i
    , input tri1        XVD_i
    , input tri0 [7:0]  VRAM_WD_i
    , input tri0 [9:0]  VRAM_WA_i
    , input tri0        VRAM_WE_i
    , input tri0 [7:0]  CPU_VRAM_WD_i
    , input tri0 [9:0]  CPU_VRAM_WA_i
    , input tri0        CPU_VRAM_WE_i
    , input tri0        BUS_OSD_CPU_USE
    , input tri0        BUS_OSD_OFF
    , input tri0 [11:0] BUS_H_DLY
    , input tri0 [10:0] BUS_V_DLY
    , input tri0 [2:0]  BUS_H_MAG
    , input tri0 [2:0]  BUS_V_MAG
    , input tri0 [7:0]  BUS_H_SCROLL
    , input tri0 [7:0]  BUS_V_SCROLL
    , input tri0        BUS_FUCHI_MASK
    , output            CHAR_o
    , output            FUCHI_o
) ;
    // get H,V timing
    reg     XHD_D ;
    reg     XVD_D ;
    wire    div_xhd ;
    wire    div_xvd ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
                XHD_D   <= 1'b1 ;
                XVD_D   <= 1'b1 ;
        end else
        begin
                XHD_D <= XHD_i ;
                XVD_D <= XVD_i ;
        end
    assign div_xhd = (~ XHD_i) & XHD_D ;
    assign div_xvd = (~ XVD_i) & XVD_D ;
    

    reg [1:0]   HD_DD   ;
    reg         HP      ;
    reg         VD_DD   ;
    reg         VP      ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
                HD_DD   <= 'd0 ;
                HP      <= 1'b0 ;
                VD_DD   <= 1'b0 ;
                VP      <= 1'b0 ;
        end else
        begin
                HD_DD   <= {HD_DD[0] , div_xhd} ;
                HP      <= HD_DD[1]  ;
                if( HD_DD[1] )
                    VD_DD   <= 1'b0 ;
                else if( div_xvd )
                    VD_DD   <= 1'b1 ;
                VP <= HD_DD[1] &  VD_DD ;
        end

    reg [11:0]  HDLY_CTR    ;
    reg         HST         ;
    reg [ 2:0]  HST_D       ;
    reg [11:0]  VDLY_CTR    ;
    reg         VST         ;
    reg [ 2 :0] VST_D       ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            HDLY_CTR    <= ~ 0 ;
            HST         <= 1'b0 ;
            HST_D       <= 0 ;
            VDLY_CTR    <= ~ 0 ;
            VST         <= 1'b0 ;
            VST_D       <= 0 ;
        end else 
        begin
            if( HP )
                HDLY_CTR <= 0 ;
            else
            begin
                if(~(&HDLY_CTR))
                    HDLY_CTR <= HDLY_CTR + 1 ;
            end 
            HST <= (HDLY_CTR == BUS_H_DLY) ;
            HST_D <= {HST_D[1 : 0] , HST} ;
            if( VP )
                VDLY_CTR <= 0 ;
            else if( HP )
            begin
                if(~ (&VDLY_CTR))
                    VDLY_CTR <= VDLY_CTR + 1 ;
            end
            VST <=
                (VDLY_CTR == BUS_V_DLY) 
                & 
                (HDLY_CTR == BUS_H_DLY)
            ;
            VST_D <= {VST_D[1 : 0] , VST} ;
        end

    reg [ 2 :0] PRESCALER_HCTR  ;
    reg         HCTR_EE         ;
    reg [ 5 :0] HCTR_EE_D       ;
    reg [ 2 :0] PRESCALER_VCTR  ;
    reg         VCTR_EE         ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            PRESCALER_HCTR  <=0   ;
            HCTR_EE         <= 1'b0 ;
            HCTR_EE_D       <=0   ;
            PRESCALER_VCTR  <=0   ;
            VCTR_EE         <= 1'b0 ;
        end else
        begin
            if( HST )
                PRESCALER_HCTR <= 0 ;
            else if(PRESCALER_HCTR==BUS_H_MAG)
                PRESCALER_HCTR <= 0 ;
            else
                PRESCALER_HCTR <= PRESCALER_HCTR + 1 ;
            HCTR_EE <= &(~PRESCALER_HCTR) ;
            HCTR_EE_D <= {HCTR_EE_D[4 : 0] , HCTR_EE} ;
            if( VST )
                PRESCALER_VCTR <= 0 ;
            else if( HST )
            begin
                if(PRESCALER_VCTR == BUS_V_MAG)
                    PRESCALER_VCTR <= 0 ;
                else
                    PRESCALER_VCTR <= PRESCALER_VCTR + 1 ;
            end
            VCTR_EE <= HST_D[ 0 ] & (&(~PRESCALER_VCTR)) ;
        end
    reg [7:0]   HCTR    ;
    reg [7:0]   H_ADR   ;
    reg [7:0]   VCTR    ;
    reg [7:0]   V_ADR   ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            HCTR    <= 0 ;
            H_ADR   <= 0 ;
            VCTR    <= 0 ;
            V_ADR   <= 0 ;
        end else
        begin
            if( HST_D[1] )
                HCTR    <= 0 ;
            else if( HCTR_EE )
                HCTR <= HCTR + 1 ;
            H_ADR   <= HCTR + BUS_H_SCROLL ;
            if( VST_D[1] )
                VCTR    <= 0 ;
            else if( VCTR_EE )
                VCTR <= VCTR + 1 ;
            V_ADR   <= VCTR + BUS_V_SCROLL ;
        end
    wire[2 :0] CHAR_PIX_CTR  = H_ADR[ 2 :0] ;
    wire[4 :0] CHAR_H_CTR    = H_ADR[ 7: 3] ;
    wire[2 :0] CHAR_LINE_CTR = V_ADR[ 2 :0] ;
    wire[4 :0] CHAR_V_CTR    = V_ADR[ 7: 3] ;

    reg         HBLK    ;
    reg         VBLK    ;
    reg [ 4:0]  BLK_AQ  ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            HBLK <= 1'b1 ;
            VBLK <= 1'b1 ;
            BLK_AQ <= ~ 0 ;
        end else
        begin
            if( HST_D[2] )
                HBLK <= 1'b0 ;
            else if( & HCTR )
                HBLK <= 1'b1 ;

            if( VST_D[2] )
                VBLK <= 1'b0 ;
            else if( &{VCTR,HCTR} )
            begin
                VBLK <= 1'b1 ;
            end

            BLK_AQ <= {BLK_AQ[3 : 0] , (HBLK | VBLK)} ;
        end
    wire BLK = BLK_AQ[ 3 ] ;

    //
    reg [7:0]   VRAM_WD ;
    reg [9:0]   VRAM_WA ;
    reg         VRAM_WE ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            VRAM_WD <= 0 ;
            VRAM_WA <= 0 ;
            VRAM_WE <= 1'b0 ;
        end else
        begin
            if( BUS_OSD_CPU_USE )
            begin
                VRAM_WD <= CPU_VRAM_WD_i ;
                VRAM_WA <= CPU_VRAM_WA_i ;
                VRAM_WE <= CPU_VRAM_WE_i ;
            end else
            begin
                VRAM_WD <= VRAM_WD_i ;
                VRAM_WA <= VRAM_WA_i ;
                VRAM_WE <= VRAM_WE_i ;
            end
        end
    wire [5+5-1:0]  VRAM_RA = {CHAR_V_CTR , CHAR_H_CTR} ;
    wire [7:0]  VRAM_RD ;
    DP_RAM 
    #(
          .C_DAT_W  (  8        )
        , .C_ADR_W  ( 10        )
    )
    DP_RAM
    (
          .W_CK_i   ( CK_i      )
        , .R_CK_i   ( CK_i      )
        , .XARST_i  ( XARST_i   )
        , .WE_i     ( VRAM_WE   )
        , .WD_i     ( VRAM_WD   )
        , .WA_i     ( VRAM_WA   )
        , .RA_i     ( VRAM_RA   )
        , .RD_o     ( VRAM_RD   )
    ) ; //DP_RAM ; 

    reg [ 3 :0] SHIFT_REG_LD_AQ ;
    reg [ 2 :0] CHAR_LINE_D     ;
    reg [ 2 :0] CHAR_LINE_DD    ;
    wire        SHIFT_LD_AQ_a   ;
    assign SHIFT_LD_AQ_a = (CHAR_PIX_CTR==0) & HCTR_EE_D[1] ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            SHIFT_REG_LD_AQ <= 0 ;
            CHAR_LINE_D     <= 0 ;
            CHAR_LINE_DD    <= 0 ;
        end else
        begin
            SHIFT_REG_LD_AQ <= 
                { 
                    SHIFT_REG_LD_AQ[ 2 :0]
                    ,
                    SHIFT_REG_LD_AQ_a
                }
            ;
            CHAR_LINE_D <= CHAR_LINE_CTR ;
            CHAR_LINE_DD <= CHAR_LINE_D ;
        end 
    wire [10 :0] CHAR_ADR = {VRAM_RD , CHAR_LINE_DD} ;
    wire [ 7 :0] FONT_DAT   ;
    ichigojamfont_v12
    ichigojamfont_v12
    (
          .clock    ( CK_i      )
        , .address  ( CHAR_ADR  )
        , .q        ( FONT_DAT  )
    ) ;

    wire SHIFT_REG_LD = SHIFT_REG_LD_AQ[ 3 ] ;
    wire SHIFT_REG_SFL = HCTR_EE_D[ 5 ] ;
    wire char_blanked   ;
    wire fuchi_blanked  ;
    reg [ 1 :0] CHAR_AQ     ;
    reg [ 1 :0] BLK_D       ;
    reg [ 7 :0] SHIFT_REG   ;
    assign char_blanked = (~ BLK_D[0]) & SHIFT_REG[ 7 ] ;
    assign fuchi_blanked = 
        (~
            (
                BUS_FUCHI_MASK & BLK_D[1]
            )
        ) & 
        (
            char_blanked 
            |
            ( | CHAR_AQ)
        ) 
    ;

    reg         CHAR    ;
    reg         FUCHI   ;
    always @(posedge CK_i or negedge XARST_i)
        if( ~ XARST_i )
        begin
            SHIFT_REG   <= 0 ;
            BLK_D       <= ~ 0 ;
            CHAR_AQ     <= 0 ;
            CHAR        <= 1'b0 ;
            FUCHI       <= 1'b0 ;
        end else
        begin
            if( BUS_OSD_OFF )
            begin
                SHIFT_REG <= 0 ;
                BLK_D   <= ~ 0 ;
                CHAR_AQ <='d0 ;
                CHAR    <= 1'b0 ;
                FUCHI   <= 1'b0 ;
            end else if( SHIFT_REG_SFL )
            begin
                if( SHIFT_REG_LD )
                    SHIFT_REG <= FONT_DAT ;
                else
                    SHIFT_REG <= {SHIFT_REG[ 6 :0] , 1'b0} ;
                BLK_D <= {BLK_D[0] , BLK} ;
                CHAR_AQ <= {CHAR_AQ[0] , char_blanked} ;
                CHAR <= CHAR_AQ[0] ; //~ [1]
                FUCHI <= fuchi_blanked ;
            end
        end
    assign CHAR_o  = CHAR ;
    assign FUCHI_o = FUCHI ;
endmodule
//CHR_GEN()
