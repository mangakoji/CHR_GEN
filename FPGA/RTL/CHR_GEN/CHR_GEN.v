//CHR_GEN.vhd<
//CHR_GEN()
// by @mangakoji
// license by BSD
//      without font ROM data
//
//180617s       :syntax check passed 
//180426f       :mod for new coding rule
//2018-03-12m   :mod net naming rule xxxs
//2018-03-11u   :mod new coding rule like BSD style
//              :many debug
//2014-??-??
//2010-01-01?? : 1st.
module CHR_GEN
(
      input             CK_i
    , input tri1        XAR_i
    , input tri1        CK_EE_i
    , input tri1        XHD_i
    , input tri1        XVD_i
    , input tri0 [7:0]  VRAM_WDs_i
    , input tri0 [9:0]  VRAM_WAs_i
    , input tri0        VRAM_WE_i
    , input tri0 [7:0]  CPU_VRAM_WDs_i
    , input tri0 [9:0]  CPU_VRAM_WAs_i
    , input tri0        CPU_VRAM_WE_i
    , input tri0        BUS_OSD_CPU_USE
    , input tri0        BUS_OSD_OFF
    , input tri0 [11:0] BUS_H_DLYs
    , input tri0 [10:0] BUS_V_DLYs
    , input tri0 [2:0]  BUS_H_MAGs
    , input tri0 [2:0]  BUS_V_MAGs
    , input tri0 [7:0]  BUS_H_SCROLLs
    , input tri0 [7:0]  BUS_V_SCROLLs
    , input tri0        BUS_FUCHI_MASK
    , output            CHAR_o
    , output            FUCHI_o
) ;
    // get H,V timing
    reg     XHD_D ;
    reg     XVD_D ;
    wire    div_xhd ;
    wire    div_xvd ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            XHD_D   <= 1'b1 ;
            XVD_D   <= 1'b1 ;
        end else if( CK_EE_i )
        begin
            XHD_D <= XHD_i ;
            XVD_D <= XVD_i ;
        end
    assign div_xhd = (~ XHD_i) & XHD_D ;
    assign div_xvd = (~ XVD_i) & XVD_D ;
    

    reg [1:0]   HD_Ds   ;
    reg         HP      ;
    reg         VD_D    ;
    reg         VP      ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
                HD_Ds   <= 'd0 ;
                HP      <= 1'b0 ;
                VD_D    <= 1'b0 ;
                VP      <= 1'b0 ;
        end else if( CK_EE_i )
        begin
                HD_Ds   <= {HD_Ds[0] , div_xhd} ;
                HP      <= HD_Ds[1]  ;
                if( HD_Ds[1] )
                    VD_D   <= 1'b0 ;
                else if( div_xvd )
                    VD_D   <= 1'b1 ;
                VP <= HD_Ds[1] &  VD_D ;
        end

    reg [11:0]  HDLY_CTRs    ;
    reg         HST          ;
    reg [ 2:0]  HST_Ds       ;
    reg [11:0]  VDLY_CTRs    ;
    reg         VST          ;
    reg [ 2 :0] VST_Ds       ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            HDLY_CTRs   <= ~ 0 ;
            HST         <= 1'b0 ;
            HST_Ds      <= 0 ;
            VDLY_CTRs   <= ~ 0 ;
            VST         <= 1'b0 ;
            VST_Ds      <= 0 ;
        end else if( CK_EE_i )
        begin
            if( HP )
                HDLY_CTRs <= 0 ;
            else
            begin
                if(~(&HDLY_CTRs))
                    HDLY_CTRs <= HDLY_CTRs + 1 ;
            end 
            HST <= (HDLY_CTRs == BUS_H_DLYs) ;
            HST_Ds <= {HST_Ds[1 : 0] , HST} ;
            if( VP )
                VDLY_CTRs <= 0 ;
            else if( HP )
            begin
                if(~ (&VDLY_CTRs))
                    VDLY_CTRs <= VDLY_CTRs + 1 ;
            end
            VST <=
                (VDLY_CTRs == BUS_V_DLYs) 
                & 
                (HDLY_CTRs == BUS_H_DLYs)
            ;
            VST_Ds <= {VST_Ds[1 : 0] , VST} ;
        end

    reg [ 2 :0] PRESCALER_HCTRs  ;
    reg         HCTRs_EE         ;
    reg [ 5 :0] HCTRs_EE_Ds       ;
    reg [ 2 :0] PRESCALER_VCTRs  ;
    reg         VCTRs_EE         ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            PRESCALER_HCTRs  <=0   ;
            HCTRs_EE         <= 1'b0 ;
            HCTRs_EE_Ds       <=0   ;
            PRESCALER_VCTRs  <=0   ;
            VCTRs_EE         <= 1'b0 ;
        end else if( CK_EE_i )
        begin
            if( HST )
                PRESCALER_HCTRs <= 0 ;
            else if(PRESCALER_HCTRs==BUS_H_MAGs)
                PRESCALER_HCTRs <= 0 ;
            else
                PRESCALER_HCTRs <= PRESCALER_HCTRs + 1 ;
            HCTRs_EE <= &(~PRESCALER_HCTRs) ;
            HCTRs_EE_Ds <= {HCTRs_EE_Ds[4 : 0] , HCTRs_EE} ;
            if( VST )
                PRESCALER_VCTRs <= 0 ;
            else if( HST )
            begin
                if(PRESCALER_VCTRs == BUS_V_MAGs)
                    PRESCALER_VCTRs <= 0 ;
                else
                    PRESCALER_VCTRs <= PRESCALER_VCTRs + 1 ;
            end
            VCTRs_EE <= HST_Ds[ 0 ] & (&(~PRESCALER_VCTRs)) ;
        end

    reg [7:0]   HCTRs    ;
    reg [7:0]   H_ADRs   ;
    reg [7:0]   VCTRs    ;
    reg [7:0]   V_ADRs   ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            HCTRs    <= 0 ;
            H_ADRs   <= 0 ;
            VCTRs    <= 0 ;
            V_ADRs   <= 0 ;
        end else if( CK_EE_i )
        begin
            if( HST_Ds[1] )
                HCTRs    <= 0 ;
            else if( HCTRs_EE )
                HCTRs <= HCTRs + 1 ;
            H_ADRs   <= HCTRs + BUS_H_SCROLLs ;
            if( VST_Ds[1] )
                VCTRs    <= 0 ;
            else if( VCTRs_EE )
                VCTRs <= VCTRs + 1 ;
            V_ADRs   <= VCTRs + BUS_V_SCROLLs ;
        end
    wire[2 :0] CHAR_PIX_CTRs  = H_ADRs[ 2 :0] ;
    wire[4 :0] CHAR_H_CTRs    = H_ADRs[ 7: 3] ;
    wire[2 :0] CHAR_LINE_CTRs = V_ADRs[ 2 :0] ;
    wire[4 :0] CHAR_V_CTRs    = V_ADRs[ 7: 3] ;

    reg         HBLK    ;
    reg         VBLK    ;
    reg [ 4:0]  BLK_ADs  ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            HBLK <= 1'b1 ;
            VBLK <= 1'b1 ;
            BLK_ADs <= ~ 0 ;
        end else if( CK_EE_i )
        begin
            if( HST_Ds[2] )
                HBLK <= 1'b0 ;
            else if( & HCTRs )
                HBLK <= 1'b1 ;

            if( VST_Ds[2] )
                VBLK <= 1'b0 ;
            else if( &{VCTRs,HCTRs} )
            begin
                VBLK <= 1'b1 ;
            end

            BLK_ADs <= {BLK_ADs[3 : 0] , (HBLK | VBLK)} ;
        end
    wire BLK = BLK_ADs[ 3 ] ;

    //
    reg [7:0]   VRAM_WDs ;
    reg [9:0]   VRAM_WAs ;
    reg         VRAM_WE ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            VRAM_WDs <= 0 ;
            VRAM_WAs <= 0 ;
            VRAM_WE <= 1'b0 ;
        end else if( CK_EE_i )
        begin
            if( BUS_OSD_CPU_USE )
            begin
                VRAM_WDs <= CPU_VRAM_WDs_i ;
                VRAM_WAs <= CPU_VRAM_WAs_i ;
                VRAM_WE  <= CPU_VRAM_WE_i ;
            end else
            begin
                VRAM_WDs <= VRAM_WDs_i ;
                VRAM_WAs <= VRAM_WAs_i ;
                VRAM_WE  <= VRAM_WE_i ;
            end
        end
    wire [5+5-1:0]  VRAM_RAs = {CHAR_V_CTRs , CHAR_H_CTRs} ;
    wire [7:0]  VRAM_RDs ;
    DP_RAM 
    #(
          .C_DAT_W  (  8        )
        , .C_ADR_W  ( 10        )
    )
    DP_RAM
    (
          .W_CK_i   ( CK_i      )
        , .R_CK_i   ( CK_i      )
//        , .XAR_i    ( XAR_i   )
        , .WCK_EE_i ( CK_EE_i   )
        , .WE_i     ( VRAM_WE   )
        , .WDs_i    ( VRAM_WDs  )
        , .RCK_EE_i ( CK_EE_i   )
        , .WAs_i    ( VRAM_WAs  )
        , .RAs_i    ( VRAM_RAs   )
        , .RDs_o    ( VRAM_RDs   )
    ) ; //DP_RAM ; 

    reg [ 3 :0] SHIFT_REG_LD_AQs ;
    reg [ 2 :0] CHAR_LINEs_D     ;
    reg [ 2 :0] CHAR_LINEs_DD    ;
    wire        SHIFT_REG_LD_AQ_a   ;
    assign SHIFT_REG_LD_AQ_a = (CHAR_PIX_CTRs==0) & HCTRs_EE_Ds[1] ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            SHIFT_REG_LD_AQs <= 0 ;
            CHAR_LINEs_D     <= 0 ;
            CHAR_LINEs_DD    <= 0 ;
        end else if( CK_EE_i )
        begin
            SHIFT_REG_LD_AQs <= 
                { 
                    SHIFT_REG_LD_AQs[ 2 :0]
                    ,
                    SHIFT_REG_LD_AQ_a
                }
            ;
            CHAR_LINEs_D <= CHAR_LINE_CTRs ;
            CHAR_LINEs_DD <= CHAR_LINEs_D ;
        end 
    wire [10 :0] CHAR_ADRs = {VRAM_RDs , CHAR_LINEs_DD} ;
    wire [ 7 :0] FONT_DATs   ;
    ichigojamfont_v12
    ichigojamfont_v12
    (
          .clock    ( CK_i      )
        , .CK_EE_i  ( CK_EE_i   )
        , .address  ( CHAR_ADRs  )
        , .q        ( FONT_DATs  )
    ) ;
    wire SHIFT_REGs_LD = SHIFT_REG_LD_AQs[ 3 ] ;
    wire SHIFT_REGs_SFL = HCTRs_EE_Ds[ 5 ] ;
    wire char_blanked   ;
    wire fuchi_blanked  ;
    reg [ 1 :0] CHAR_ADs     ;
    reg [ 1 :0] BLK_Ds       ;
    reg [ 7 :0] SHIFT_REGs   ;
    assign char_blanked = (~ BLK_Ds[0]) & SHIFT_REGs[ 7 ] ;
    assign fuchi_blanked = 
        (~
            (
                BUS_FUCHI_MASK & BLK_Ds[1]
            )
        ) & 
        (
            char_blanked 
            |
            ( | CHAR_ADs)
        ) 
    ;

    reg         CHAR    ;
    reg         FUCHI   ;
    always @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i )
        begin
            SHIFT_REGs  <= 0 ;
            BLK_Ds      <= ~ 0 ;
            CHAR_ADs    <= 0 ;
            CHAR        <= 1'b0 ;
            FUCHI       <= 1'b0 ;
        end else if( CK_EE_i )
        begin
            if( BUS_OSD_OFF )
            begin
                SHIFT_REGs  <= 0 ;
                BLK_Ds      <= ~ 0 ;
                CHAR_ADs    <='d0 ;
                CHAR        <= 1'b0 ;
                FUCHI       <= 1'b0 ;
            end else if( SHIFT_REGs_SFL )
            begin
                if( SHIFT_REGs_LD )
                    SHIFT_REGs <= FONT_DATs ;
                else
                    SHIFT_REGs <= {SHIFT_REGs[ 6 :0] , 1'b0} ;
                BLK_Ds <= {BLK_Ds[0] , BLK} ;
                CHAR_ADs <= {CHAR_ADs[0] , char_blanked} ;
                CHAR <= CHAR_ADs[0] ; //~ [1]
                FUCHI <= fuchi_blanked ;
            end
        end
    assign CHAR_o  = CHAR ;
    assign FUCHI_o = FUCHI ;
endmodule
//CHR_GEN()
