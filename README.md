# NAME
    imgconv.pl - simple command-line image-convertation tool.

# SYNOPSIS:
      imgconv.pl inimage outimage [-c:l,t[,r[,b]]] [-d:float] [-s:float] \
        [-g:float] [-n:float] [-t:float] [-p:integer] [-w:file] [-f:chars] \
        [-r:string] [-x:chars] [-a] [-v] [[-]-help]

    Options applied one by one in order as listed in command line. One kind
    of option may be applied for many times. For example:

      "imgconv.pl perl.png out15.jpeg -d:15 -d:10 -f:h -v""

    Result of this operations (output with verbose flag):

      "Rotated by: 15 degrees.
      Rotated by: 10 degrees.
      Flip image horisontal"

# DESCRIPTION:
    imgconv.pl is a simple command line tool to convert image for various
    purpose, e.g. batch-processing of crop, resise, flip, blur, contrast,
    post levels, add noise, swap color channels or extract anyone, convert
    to another format and so on. Written with Perl and uses builtin Imager
    extension.

## INPUT PARAMS:
    inimage
        Input image file name. Supported formats: PNG, BMP, GIF, JPG, TIFF

    outimage
        Output image file name. Supported formats: PNG, BMP, GIF, JPEG, TIFF

## OPTIONS:
    __-c:l,t,r,b__
        Crop image by (l)eft, (t)op, (r)ight and (b)ottom margin (integer)
        pixels;

    __-d:float__
        Rotate for <float> degrees;

    __-s:float__
        Scale for <float> factor;

    __-g:float__
        Gaussian blur filter of <float> amount;

    __-n:float__
        Noise of <float> amount;

    __-t:float__
        Contrast of <float> level;

    __-p:integer__
        Post level;

    __-w:file__
        Water mark from file;

    __-f:chars__
        Flip image (v)ertical or (h)orisontal, or 'vh' or 'hv';

    __-r:string__
        Color transformation, possible values are: gray, noalpha, red,
        channel0, green, channel1, blue, channel2, alpha, rgb, addalpha;

    __-x:chars__
        Swap any two color channels: 'r','g' or 'b'. Exactly two chars
        allowed;

    __-a__  Autolevels;

    __-v__  Verbose;

    __-help__
        Display help screen of usage. Also display one if required parameter
        missing.

# AUTHOR
    An0ther0ne

# SEE ALSO
* [Imager](https://metacpan.org/pod/Imager)
* [Perl](http://www.perl.org/)
* http://imager.perl.org/

# LICENSE
    GNU General Public License v3.0
