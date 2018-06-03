// $Id: $
// file_name    : NTSC_TG.v
// discript     : frame_construction
//
//180426r  prog :match new coding rule
// 2013-02-23W6 : EE append, and rename names
// 2009-07-29W3 : coding rule correct
// 2009-07-28W2 : WIP
// 2004-05???   : 1st.



//      counter archtecture
//       4fsc
//       v
//       H 0~910-1
//       v
//      --------v_ctr----------
//       V 0~263-1  
//       v cy at half Frame
//       v FI <= 1
//       v 
//       V 0~263-1
//       v cy at full Frame
//       v FI <= 0
//     ---------------------
//       v
//       now 1 frame
//

module  NTSC_TG 
#(
      parameter C_H_START = 10'd126
    , parameter C_V_START = 10'd31 ;

)(     
      input         CK_i 
    , input tri1    XAR_i 
    , input tri1    CK_EE_i //when use 4fsc clock , make fix 1
    , input tri1    XHD_i
    , input tri1    XVD_i
    , output        SYNC_o  //0:sync
    , output        BLANK_o //1:blank
    , output        BURST_o //1:burst
    , output        FI_o
    , output        XHD_Q_o
    , output        XVD_Q_o
) ;
    localparam 
          C_HH_SIZE             = 455
        , C_H_SIZE              = 2 * C_HH_SIZE
        , C_EQU_SIDE_1          = 36
        , C_EQU_SIDE_2          = C_HH_SIZE + C_EQU_SIDE_1
        , C_EQU_CENTER_1        = 388
        , C_EQU_CENTER_2        = C_HH_SIZE + C_EQU_CENTER_1
        , C_HSYNC_PORCH         =  66
    ;
    
    reg XHD_D ;
    reg XVD_D ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i) 
            {XVD_D , XHD_D} <= 2'b11 ;
        else if( CK_EE_i )
            {XVD_D , XHD_D} <= {XVD_i , XHD_i} ;
    wire div_XHD ;
    wire div_XVD ;
    assign div_XHD = ~XHD_i & XHD_D ;
    assign div_XVD = ~XVD_i & XVD_D ;


    wire    Hcy             ;
    reg     [ 9:0]  HCTRs      ;
    assign  Hcy = & ( ((P_H_SIZE - 1) & HCTRs[9 :0]) | ~(P_H_SIZE -1)) ;
    wire            HHcy            ;
    assign  HHcy = (P_HH_SIZE - 1) ==  HCTRs[9 :0] ;
    wire            HSYNC_a ;
    reg             HSYNC   ;

    // h_count 0--P_H_SIZE-1
    wire    [10:0]  HCTRs_inc   ;
    assign  HSYNC_a = 
        ( Hcy ) 
        ?
            1'b0
        : ((P_HSYNC_PORCH-1) == HCTRs[9:0]) 
        ?     
            1'b1
        :
            HSYNC
    ;
    assign HCTRs_inc = HCTRs + 10'd1 ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i) 
        begin
            HCTRs   <= 10'd0 ;
            HSYNC   <= 1'b1 ;
        end else if( CK_EE_i ) 
        begin
            HCTRs <= ( ~ XR || Hcy) ? 9'h000 : HCTRs_inc[9 :0] ;
            HSYNC <=  HSYNC_a ;
        end


    wire            EQU_SYNC_SIDE_a         ;
    reg             EQU_SYNC_SIDE           ;
    wire            EQU_SYNC_CENTER_a       ;
    reg             EQU_SYNC_CENTER         ;
    // 等価パルス＠VSYNC side 3+3H
    assign  EQU_SYNC_SIDE_a = 
        ( Hcy ) 
        ?
            1'b0
        :((C_EQU_SIDE_1-1) == HCTRs) 
        ?
            1'b1
        : ( HHcy ) 
        ?
            1'b0
        :((C_EQU_SIDE_2 - 1) == HCTRs) 
        ?
            1'b1
        :   
            EQU_SYNC_SIDE
    ;
    //      等価パルス＠VSYNC center 3 H
    assign  EQU_SYNC_CENTER_a = 
        ( Hcy ) 
        ?
            1'b0
        :((C_EQU_CENTER_1-1) == HCTRs) 
        ? 
            1'b1
        : ( HHcy )
        ?
            1'b0
        :((C_EQU_CENTER_2-1) == HCTRs) 
        ? 
            1'b1
        :
            EQU_SYNC_CENTER
    ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i) 
        begin
            EQU_SYNC_CENTER <= 1'b1 ;
            EQU_SYNC_SIDE <= 1'b1 ;
        end else if( CK_EE_i ) 
        begin
            EQU_SYNC_SIDE <= EQU_SYNC_SIDE_a ;
            EQU_SYNC_CENTER <= EQU_SYNC_CENTER_a ;
        end

    wire    SYNC_a  ;
    reg     SYNC    ;
    wire    EQU_SYNC_CENTER_now_a ;
    assign  SYNC_a = 
        ( VSYNC_a ) 
        ?
            HSYNC_a
        :( EQU_SYNC_CENTER_now_a) 
        ?    
            EQU_SYNC_CENTER
        :
            EQU_SYNC_SIDE
    ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~XAR_i )
            SYNC <= 1'b1 ;
        else if( CK_EE_i )
            SYNC <= SYNC_a ;
    assign SYNC_o = SYNC ;

    // v_count 0--262,0--261 repeat
    reg     [ 9 :0] VCTRs   ;
    reg             FI      ;
    wire            VCY     ;
    wire            v0cy    ;
    wire            v1cy    ;
    assign v0cy = ~ FI & (262 == VCTRs) ;
    assign v1cy = FI & (261 == VCTRs) ; 
    assign VCY = v0cy | v1cy ;
    wire    [10:0]  inc_v ;
    assign inc_v = VCTRs + 10'd1 ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i ) 
        begin
            VCTRs <=  10'd0 ;
            FI <= 1'd0 ;
        end else if( CK_EE_i ) 
        begin
            VCTRs <= 
                ( ~XR ) 
                ?
                    10'h000
                : (VCY & Hcy) 
                ? 
                    10'h000
                : ( Hcy ) 
                ?
                    inc_v[9 :0]
                :
                    VCTRs
            ;
            FI <= 
                ( ~ XR) 
                ?
                    1'b0
                : (v0cy & Hcy ) 
                ?       
                    1'b1
                : (v1cy & Hcy) 
                ?
                    1'b0
                :
                    FI
            ;
        end
    assign FI_o = FI ;

    wire            VSYNC_a ;
    reg             VSYNC   ;
    assign  VSYNC_a = 
        (VCY &  Hcy  &   FI) 
        ?
            1'b0 
        : ((9-1 == VCTRs) & Hcy  & ~ FI) 
        ?   
            1'b1 
        : (VCY & HHcy & ~ FI) 
        ?
            1'b0 
        : ((9-1 == VCTRs) & HHcy &   FI) 
        ?
            1'b1
        :
            VSYNC
    ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            VSYNC <= 1'b1 ;
        else if( CK_EE_i )
            VSYNC <= VSYNC_a ;

    reg     EQU_SYNC_CENTER_now ;
    assign  EQU_SYNC_CENTER_now_a = 
        ((  2 == VCTRs) & Hcy  & ~ FI) 
        ?
            1'b1 
        :((  5 == VCTRs) & Hcy  & ~ FI) 
        ?
            1'b0 
        :((  2 == VCTRs) & HHcy &   FI) 
        ?
            1'b1 
        :((  5 == VCTRs) & HHcy &   FI) 
        ?
            1'b0
        :
            /EQU_SYNC_CENTER_now
    ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            EQU_SYNC_CENTER_now <= 1'd1 ;
        else if( CK_EE_i )
            EQU_SYNC_CENTER_now <= EQU_SYNC_CENTER_now_a ;

    // 1:BLANK
    reg             BLANK           ;
    reg             H_BLANK         ;
    reg             V_BLANK         ;
    reg             H_START         ;
    reg             V_START         ;
    wire            BLANK_a         ;
    wire            H_BLANK_a       ;
    wire            V_BLANK_a       ;
    localparam C_H_BLANK_START = 894 ;
    localparam C_H_BLANK_END = 125   ;
    assign H_BLANK_a = 
        ((P_H_BLANK_START-1) == HCTRs) 
        ?
            1'd1 
        :( C_H_BLANK_END == HCTRs)   
        ?
            1'd0 
        :
            H_BLANK  
    ;
    assign V_BLANK_a =
        (FI & VCY & Hcy) 
        ?
            1'b1 
        :(~FI & (19 == VCTRs) & Hcy) 
        ?
            1'b0 
        :(~FI & VCY & HHcy) 
        ?
            1'b1 
        :(FI & (19 == VCTRs) & HHcy) 
        ?
            1'b0
        :
            V_BLANK 
    ;
    assign BLANK_a = H_BLANK_a | V_BLANK_a ;
    wire            H_START_a       ;
    assign H_START_a = (P_H_START-1 == HCTRs[9:0]) ;
    always@(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i) 
        begin
            H_BLANK <= 1'b1 ;
            V_BLANK <= 1'b1 ;
            BLANK <= 1'b1 ;
            H_START <= 1'b0 ;
            V_START <= 1'b0 ;
        end else if( CK_EE_i ) 
        begin
            H_BLANK <= H_BLANK_a ;
            V_BLANK <= V_BLANK_a ;
            BLANK <=  BLANK_a ;
            H_START <= H_START_a ;
            V_START <= (P_V_START-1 == VCTRs[9:0]) & H_START_a ;
        end
    assign BLANK_o = BLKANK ;

    reg BURST   ;
    wire BURST_a ;
    localparam C_BURST_START = 73 ;
    localparam C_BURST_END = 115 ;
    assign BURST_a = 
        ~ V_BLANK 
        & (
            (P_BURST_START-1 == HCTRs) 
            ?
                1'b1
            : (P_BURST_END == HCTRs) 
            ?
                1'b0 
            :
                BURST
        )
    ;
    always  @(posedge CK_i or negedge XAR_i)
        if( ~ XAR_i)
            BURST <= 1'b0 ;
        else if( CK_EE_i )
            BURST <= BURST_a ;
    assign BURST_o = BURST ;
endmodule
// NTSC_TG.v
