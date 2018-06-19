#!/usr/bin/env python
# -*- coding: EUC_JP -*-
#$Id $
# 蛸入り
VERSION ="""
#
#       plot.py
#
# 2017-05-31we  : 1st.
"""
__doc__ = """
"""
import sys
# sys.setdefaultencoding( "shift_jis" )
import os
#import add_math
import math
from operator import *
#from std  import *
import datetime
#import time

from PIL import Image
import matplotlib.pyplot as plt
import numpy as np

class Font_mk( object ) :
    def __init__(self , file_name , OFSs=(8*3*2-6,8*3*2-6)) :
        self.OFSs = OFSs[:]
        self.im = Image.open( file_name )
#       im.show()
        self.im_list = np.asarray( self.im )
        plt.imshow( self.im_list )
#        plt.show()

    def px_get(self , loc ) :
        ll =[]
        for yy in xrange( 8 ) :
            line = []
            for xx in xrange( 8 ) :
                px = self.im_list[
                        2*(yy+loc[1]*8)+self.OFSs[1]
                    ][
                        2*(xx+loc[0]*8)+self.OFSs[0]
                    ]
#                print px[0:3]
                if reduce(lambda last,x:last and(x==0), px[0:3],True) :
                    line.append( 0 )
                else :
                    line.append( 255 )
            ll.append( line[:] )
        return ll

    def chk_show(self ,ll) :
        img = np.array(
                ll
            , dtype=np.uint8
        )
        plt.imshow(img , cmap='gray' , vmin=0 , vmax=255,interpolation='none')
        plt.show()


    def mif_prn(self ) :
        HEADER = """\
-- Clearbox generated Memory Initialization File (.mif)
--FONT 8x8
--ichigojam font-v12
-- made by 
--%s :converted

WIDTH=8;
DEPTH=2048;

ADDRESS_RADIX=UNS;
DATA_RADIX=DEC;

CONTENT BEGIN"""% datetime.datetime.now()
        print HEADER 
        for yy in xrange( 16 ) :
            for xx in xrange( 16 ) :
                ll = self.px_get( (xx,yy) ) 
                for v_loc in xrange( 8 ) :
                    adr = (yy*16+xx) *8 + v_loc
                    dat = reduce(
                        lambda last,bit
                        :
                                (last<<1)+bit
                        , map(
                            lambda bit 
                            :
                                (1 if bit!=0 else 0) 
                            , ll[v_loc]
                        )
                    )
                    print "%d\t:\t%d\t;"%(adr,dat)
        FOOTER = """\
END ;"""
        print FOOTER

def main() :
    file_name = "ichigojamfont_v12.png"
    font_mk = Font_mk( file_name)
#    print im_list[10][10]
#    plt.show()
    font_mk.mif_prn()

#    ll = font_mk.px_get( (0x9,0xF) )
#    font_mk.chk_show( ll )



if  __name__  == '__main__' : 
        import sys
        if 2 > len( sys.argv ) :
                pass

        elif '-t' == sys.argv[ 1 ] :
                import doctest
                doctest.testmod()
                sys.exit( 0 )

        elif "-timeit" == sys.argv[ 1 ] :
                setup_f = lambda setup: "\n".join(
                        map(
                                lambda line :
                                        line.split("... ")[ 1 ],
                                setup.splitlines()[1 : ]
                        )
                )
                import timeit
                mode = ["copy" , "fget" , "fput"]
                if "copy" in mode :
                        setup = "import __main__ ;bmp = __main__.Bmp( 'sample.bmp' )"
                        stmt = "bmp2 = bmp.copy()"
                        t = timeit.Timer(stmt , setup)
                        print min( t.repeat(3 ,1) )


        main()
