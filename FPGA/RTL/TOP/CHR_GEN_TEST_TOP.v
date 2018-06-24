//CHR_GEN.vhd<
//CHR_GEN()
// by @mangakoji
// license on BSD
//      without font ROM data
//
//180623s       :append XVD_o,XVD_o
//180617s       :syntax check passed 
//180426f       :mod for new coding rule
//2018-03-12m   :mod net naming rule xxxs
//2018-03-11u   :mod new coding rule like BSD style
//              :many debug
//2014-??-??
//2010-01-01?? : 1st.
module CHR_GEN_TEST_TOP
(
      input             NFSC_CK_i
    , input             DAC_CK_i
    , input tri1        XSYS_R_i
    , input tri1        VRAM_WE_i
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
    , input tri1        BUS_OSD_ON
    , input tri0        BUS_RGB
    , output        VIDEO_o
    //
    , output        XHD_o
    , output        XVD_o
    , output        XSYNC_o
    , output        BLANK_o
    , output        BURST_o
    , output        CHAR_o
    , output        FUCHI_o
    , output[ 7:0] YYs_o
    , output[ 9:0] VIDEOs_o
//    , output[ 9:0] VIDEOs_DD_o 
) ;
    reg         FSC4_CK_EE ;
    reg [ 2 :0] FSC4_PRESCALE_CTRs  ;
    wire FSC4_PRESCALE_CTRs_cy ;
    assign FSC4_PRESCALE_CTRs_cy = (FSC4_PRESCALE_CTRs == 3) ;
    always@(posedge NFSC_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
        begin
            FSC4_CK_EE <= 1 ;
            FSC4_PRESCALE_CTRs <= 7 ;
        end else
        begin
            FSC4_CK_EE <= FSC4_PRESCALE_CTRs_cy ;
            if( FSC4_CK_EE )
                FSC4_PRESCALE_CTRs <= 0 ;
            else
                FSC4_PRESCALE_CTRs <= FSC4_PRESCALE_CTRs + 1 ;
        end
    wire XSYNC ;
    wire BLANK ;
    wire BURST ;
    wire[ 9:0]  HCTRs ;
    wire[ 9:0]  VCTRs ;
    NTSC_TG 
    NTSC_TG 
    (
          .CK_i         ( NFSC_CK_i    )
        , .XAR_i        ( XSYS_R_i      )
        , .CK_EE_i      ( FSC4_CK_EE    )
        , .XSYNC_o      ( XSYNC      )//0:sync
        , .BLANK_o      ( BLANK      )//1:blank
        , .BURST_o      ( BURST      )//1:burst
        , .HCTRs_o      ( HCTRs )
        , .VCTRs_o      ( VCTRs )
    ) ;
    assign XSYNC_o      = XSYNC      ; //0:sync
    assign BLANK_o      = BLANK      ; //1:blank
    assign BURST_o      = BURST      ; //1:burst


    reg XHD ;
    reg XVD ;
    always@(posedge NFSC_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
        begin
            XHD <= 1 ;
            XVD <= 1 ;
        end else if( FSC4_CK_EE )
        begin
            XHD <= ~ (HCTRs == (910-1)) ;
            XVD <= ~ (VCTRs  == 0) ;
        end
    assign XHD_o = XHD ;
    assign XVD_o = XVD ;

    reg [7:0] VRAM_WDs ;
    reg [9:0] VRAM_WAs ;
    reg        VRAM_WE ;
    always@(posedge NFSC_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i)
        begin
            VRAM_WDs <= 0 ;
            VRAM_WAs <= 0 ;
            VRAM_WE <= 0 ;
        end else if( FSC4_CK_EE )
        begin 
            VRAM_WDs <= VRAM_WDs + 1 ;
            VRAM_WAs <= VRAM_WAs + 1 ;
            VRAM_WE <= 1 ;
        end            


    wire    CHAR ;
    wire    FUCHI ;
    CHR_GEN
    CHR_GEN
    (
          .CK_i             ( NFSC_CK_i    )
        , .XAR_i            ( XSYS_R_i      )
        , .CK_EE_i          ( FSC4_CK_EE    )
        , .XHD_i            ( XHD           )
        , .XVD_i            ( XVD           )
        , .VRAM_WDs_i       ( VRAM_WDs      )
        , .VRAM_WAs_i       ( VRAM_WAs      )
        , .VRAM_WE_i        ( VRAM_WE_i     )
        , .CPU_VRAM_WDs_i   ( CPU_VRAM_WDs_i    )
        , .CPU_VRAM_WAs_i   ( CPU_VRAM_WAs_i    )
        , .CPU_VRAM_WE_i    ( CPU_VRAM_WE_i     )
        , .BUS_OSD_CPU_USE  ( BUS_OSD_CPU_USE   )
        , .BUS_OSD_OFF      ( BUS_OSD_OFF    )
        , .BUS_H_DLYs       ( BUS_H_DLYs     )
        , .BUS_V_DLYs       ( BUS_V_DLYs     )
        , .BUS_H_MAGs       ( BUS_H_MAGs     )
        , .BUS_V_MAGs       ( BUS_V_MAGs     )
        , .BUS_H_SCROLLs    ( BUS_H_SCROLLs  )
        , .BUS_V_SCROLLs    ( BUS_V_SCROLLs  )
        , .BUS_FUCHI_MASK   ( BUS_FUCHI_MASK )
        , .CHAR_o           ( CHAR          )
        , .FUCHI_o          ( FUCHI         )
    ) ;
    assign CHAR_o = CHAR ;
    assign FUCHI_o = FUCHI ;

    wire [ 7 :0] YYs_NTSC ;
    wire [ 7 :0] UUs_NTSC ;
    wire [ 7 :0] VVs_NTSC ;
    NTSC_RGB2YUV
    NTSC_RGB2YUV
    (
          . CK_i    ( NFSC_CK_i     )
        , .XAR_i    ( XSYS_R_i      )
        , .CK_EE_i  ( FSC4_CK_EE    )
        , .DATs_R_i ( BUS_YY        )
        , .DATs_G_i ( BUS_UU        )
        , .DATs_B_i ( BUS_VV        )
        , .YYs_o    ( YYs_NTSC      )
        , .UUs_o    ( UUs_NTSC      )
        , .VVs_o    ( VVs_NTSC      )
        
    ) ;
    
    reg [7:0] YYs ;
    reg [7:0] UUs ;
    reg [7:0] VVs ;
    always@(posedge NFSC_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
        begin
            YYs <= 0 ;
            UUs <= 0 ;
            VVs <= 0 ;
        end else if( FSC4_CK_EE )
            if( BUS_OSD_ON & (CHAR  | FUCHI))
                if( CHAR )
                begin
                    YYs <= 8'd220 ;
                    UUs <= 0 ;
                    VVs <= 0 ;
                end else if( FUCHI )
                begin
                    YYs <= 8'h00 ;
                    UUs <= 0 ;
                    VVs <= 0 ;
                end
            else if( BUS_RGB )
            begin
                YYs <= YYs_NTSC ;
                UUs <= UUs_NTSC ;
                VVs <= VVs_NTSC ;
            end else
            begin
                YYs <= BUS_YY ;
                UUs <= BUS_UU ;
                VVs <= BUS_VV ;
            end
    assign YYs_o = YYs ;
    wire [8:0] VIDEOs ;
    
    NTSC_MOD
    NTSC_MOD
    (
          . CK_i    ( NFSC_CK_i    )
        , .XAR_i    ( XSYS_R_i      )
        , .CK_EE_i  ( FSC4_CK_EE    )
        , .YYs_i    ( YYs           )
        , .UUs_i    ( UUs           )
        , .VVs_i    ( VVs           )
        , .BLANK_i  ( BLANK         ) //1:BLANK */
        , .XSYNC_i  ( XSYNC         ) //0:SYNC */
        , .VIDEOs_o ( VIDEOs        )
    ) ;
    assign VIDEOs_o = VIDEOs ;
    // 
    reg [8:0] VIDEOs_Ds [0:7] ;
    reg [8:0] VIDEOs_DD ;
    always@(posedge NFSC_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i)
        begin
            VIDEOs_Ds[0] <= 0 ;
            VIDEOs_Ds[1] <= 0 ;
            VIDEOs_Ds[2] <= 0 ;
            VIDEOs_Ds[3] <= 0 ;
            VIDEOs_Ds[4] <= 0 ;
            VIDEOs_Ds[5] <= 0 ;
            VIDEOs_Ds[6] <= 0 ;
            VIDEOs_Ds[7] <= 0 ;
            VIDEOs_DD  <= 0 ;
        end else
        begin
            VIDEOs_Ds[0] <= VIDEOs ;
            VIDEOs_Ds[1] <= VIDEOs_Ds[0] ;
            VIDEOs_Ds[2] <= VIDEOs_Ds[1] ;
            VIDEOs_Ds[3] <= VIDEOs_Ds[2] ;
            VIDEOs_Ds[4] <= VIDEOs_Ds[3] ;
            VIDEOs_Ds[5] <= VIDEOs_Ds[4] ;
            VIDEOs_Ds[6] <= VIDEOs_Ds[5] ;
            VIDEOs_Ds[7] <= VIDEOs_Ds[6] ;
            VIDEOs_DD <= 
                (
                      VIDEOs_Ds[0] 
                    + VIDEOs_Ds[1]
                    + VIDEOs_Ds[2]
                    + VIDEOs_Ds[3]
                    + VIDEOs_Ds[4]
                    + VIDEOs_Ds[5]
                    + VIDEOs_Ds[6]
                    + VIDEOs_Ds[7]
                )>>3 
            ;
        end
    assign VIDEOs_DD_o = VIDEOs_DD ;
    DELTA_SIGMA_1BIT_DAC 
    #(
        .C_DAT_W    ( 9 )
    )(
          .CK       ( DAC_CK_i    )
        , .XARST_i  ( XSYS_R_i      )
        , .DAT_i    ( VIDEOs     )
        , .QQ_o     ( VIDEO_o       )
    ) ;
    
    
endmodule
//CHR_GEN_TEST_TOP()

