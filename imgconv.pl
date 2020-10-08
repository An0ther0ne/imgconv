# Copyright (c) by An0ther0ne 2019
# Github imgconv project
use Imager;

my $progname = $0;
$progname = $1 if $progname=~m|[/\\]([^/\\]+?)$|g;

sub Usage{
	"Usage: $progname <inimage> <outimage> [-c:l,t[,r[,b]]] [-s:float] [-g:float] [-n:float] \\\n".
	"\t[-w:file] [-a] [-v]\n".
	"    Options applied one by one in order as listed in command line.\n".
	"    inimage  - Input image file name. Supported formats: PNG, BMP, GIF, JPG \n".
	"    outimage - Output image file name. Supported formats: PNG, BMP, GIF, JPEG, TIFF\n".
	"    Options allowed:\n".
	"\t-c:l,t,r,b - Crop image by (l)eft, (t)op, (r)ight and (b)ottom margin (integer) pixels;\n".
	"\t-d:float   - Rotate for <float> degrees;\n".
	"\t-s:float   - Scale for <float> factor;\n".
	"\t-g:float   - Gaussian blur filter of <float> amount;\n".
	"\t-n:float   - Noise of <float> amount;\n".
	"\t-t:float   - Contrast of <float> level;\n".
	"\t-p:integer - Post level;\n".
	"\t-w:file    - Water mark from file;\n".
	"\t-f:chars   - Flip image (v)ertical or (h)orisontal, or 'vh'\n".
	"\t-r:string  - Color transformation, possible values are: gray, noalpha, red, channel0,\n".
	"\t\t     green, channel1, blue, channel2, alpha, rgb, addalpha.\n".
	"\t-x:chars   - Swap any two color channels: 'r','g' or 'b'. Exactly two chars allowed;\n".
	"\t-a         - Autolevels;\n".
	"\t-v         - Verbose;\n".
	"\t-help      - This help. Also display one if required parameter missing.\n";
}

die Usage if @ARGV<2;

my $infile = shift;
my $outfile = shift;
my %options;
my $verbose = 0;

for ($i=@ARGV;$i>0;$i--){
	my $opti = shift;
	if ($opti=~/^-v$/i){
		$verbose = 1;
	} elsif ($opti=~/^-{1,2}help$/i){
		die Usage;
	} elsif ($opti=~/^(-a)$/){
		$options{$i} = $1."\t";
	} elsif ($opti=~/^(-x):([rgb]{1})([rgb]{1})$/){
		$options{$i} = $1."\t".$2.$3 if $2 ne $3;
	} elsif ($opti=~/^(-r):(gray|addalpha|noalpha|alpha|channel0|channel1|channel2|red|green|blue|rgb)$/){
		$options{$i} = $1."\t".$2;
	} elsif ($opti=~/^(-f):([vh]{1,2})$/){
		$options{$i} = $1."\t".$2;
	} elsif ($opti=~m/^(-p):(\d+)$/){					# Integer
		$options{$i} = $1."\t".$2;
	} elsif ($opti=~m/^(-w):\"*(.+?)\"*$/){				# File path
		$options{$i} = $1."\t".$2;
	} elsif ($opti=~m/^(-[dsgnt]):(\d*\.*\d+)$/){		# Float
		$options{$i} = $1."\t".$2;
	} elsif ($opti=~m/^(-c):(\d+\,\d+\,*\d*\,*\d*)$/){	# 2..4 integers: x,y[,z[,k]]
		$options{$i} = $1."\t".$2;
	}
}

my $outformat = $1 if $outfile=~m|\.([^\.]+?)$|g;
die "Output image type \'$outformat\' is not supported\n" unless ($Imager::formats{$outformat});

my $inimage = Imager->new(file=>$infile) 
	or die "Can't open image file:".Imager->errstr."\n";

my $imwidth   = $inimage->getwidth();
my $imgheight = $inimage->getheight();
print "Input image width=$imwidth, height=$imgheight\n" if $verbose;

my $outimage = $inimage->copy();
foreach $i (reverse sort keys %options){
	my ($key,$val) = split(/\t/,$options{$i});
	if ($key eq '-s'){
		$outimage = $outimage->scale(scalefactor=>$val) 
			or die "Can't scale image by \'".$val."\' factor: ".Imager->errstr."\n";
		print "Scaled by: ".(($val-1)*100)."%\n" if $verbose;
	}elsif ($key eq '-d'){
		$outimage = $outimage->rotate(degrees=>$val);
		print "Rotated by: ".$val." degrees.\n" if $verbose;
	}elsif ($key eq '-c'){
		my ($left,$top,$right,$bottom) = split(/\,/,$val);
		$right  = $imwidth - $right;
		$bottom = $imgheight - $bottom;
		print "Crop by: LEFT=$left, TOP=$top, RIGHT=$right, BOTTOM=$bottom\n" if $verbose;
		$outimage = $outimage->crop(left=>$left, right=>$right, top=>$top, bottom=>$bottom);
	}elsif ($key eq '-g'){
		$outimage->filter(type=>"gaussian", stddev=>$val);
		print "Gaussian blur by: ".$val."\n" if $verbose;
	}elsif ($key eq '-n'){
		$outimage->filter(type=>"noise", amount=>$val, subtype=>1);
		print "Noise by: ".$val."\n" if $verbose;		
	}elsif ($key eq '-p'){
		$outimage->filter(type=>"postlevels", levels=>$val);
		print "Post level by: ".$val."\n" if $verbose;				
	}elsif ($key eq '-w'){
		my $watermark = Imager->new(file=>$val) 
			or die "Can't open water mark file: $!\n";
		$outimage->filter(type=>"watermark", tx=>0, ty=>0, wmark=>$watermark, pixdiff=>15);
		print "Water marked by: \"".$val."\"\n" if $verbose;
	}elsif ($key eq '-f'){
		if ($verbose){
			print "Flip image " ;
			print "vertical" if $val=~/v/;
			print " and " if length($val)>1;
			print "horisontal" if $val=~/h/;
			print "\n";
		}
		$outimage->flip(dir=>$val);
	}elsif ($key eq '-r'){
		if ($verbose){
			if ($val=~/red|blue|green|channel0|channel1|channel2|alpha/){
				print "Extract $val channel from image.";
			}else{
				print "Transform image colors to $val.";
			}
		}
		$outimage = $outimage->convert(preset=>$val);
	}elsif ($key eq '-x'){
		my $matrix;
		$outimage = $outimage->convert(preset=>'rgb');
		print "Convert to RGB and swap " if $verbose;
		if     ($val=~/rg|gr/){
			$matrix = [[0,1,0],[1,0,0],[0,0,1]];
			print "red and greeen " if $verbose;
		}elsif ($val=~/gb|bg/){
			$matrix = [[1,0,0],[0,0,1],[0,1,0]];
			print "greeen and blue " if $verbose;
		}elsif ($val=~/rb|br/){
			$matrix = [[0,0,1],[0,1,0],[1,0,0]];
			print "red and blue " if $verbose;
		}
		print "channels." if $verbose;
		$outimage = $outimage->convert(matrix=>$matrix);
	}elsif ($key eq '-t'){
		$outimage->filter(type=>"contrast", intensity=>$val);
		print "Contrast by: ".(100*($val-1))."%\n" if $verbose;
	}elsif ($key eq '-a'){
		print "Autolevels\n" if $verbose;
		$outimage->filter(type=>"autolevels");
	}
}

$outimage->write(file=>$outfile) 
	or die "Can't create image file: ".Imager->errstr."\n";
 
exit;

__END__

=head1 NAME

B<imgconv.pl> - simple command-line image-convertation tool.

=head1 SYNOPSIS:

  imgconv.pl inimage outimage [-c:l,t[,r[,b]]] [-d:float] [-s:float] \
    [-g:float] [-n:float] [-t:float] [-p:integer] [-w:file] [-f:chars] \
    [-r:string] [-x:chars] [-a] [-v] [[-]-help]

Options applied one by one in order as listed in command line. One kind of option may be applied for many times.
For example:

  imgconv.pl perl.png out15.jpeg -d:15 -d:10 -f:h -v

Result of this operations (output with verbose flag):

  Rotated by: 15 degrees.
  Rotated by: 10 degrees.
  Flip image horisontal

=head1 DESCRIPTION:

B<imgconv.pl> is a simple command line tool to convert image for various purpose, e.g. batch-processing of crop, resise, flip, blur, contrast, post levels, add noise, swap color channels or extract anyone, convert to another format and so on. Written with B<Perl> and uses builtin B<Imager> extension.

=head2 INPUT PARAMS:

=over

=item B<inimage>

Input image file name. Supported formats: PNG, BMP, GIF, JPG, TIFF

=item B<outimage>

Output image file name. Supported formats: PNG, BMP, GIF, JPEG, TIFF

=back

=head2 OPTIONS:

=over

=item B<-c:l,t,r,b>

Crop image by (B<l>)eft, (B<t>)op, (B<r>)ight and (B<b>)ottom margin (integer) pixels;

=item B<-d:float>

Rotate for <float> degrees;

=item B<-s:float>

Scale for <float> factor;

=item B<-g:float>

Gaussian blur filter of <float> amount;

=item B<-n:float>

Noise of <float> amount;

=item B<-t:float>

Contrast of <float> level;

=item B<-p:integer>

Post level;

=item B<-w:file>

Water mark from file;

=item B<-f:chars>

Flip image (B<v>)ertical or (B<h>)orisontal, or 'B<vh>' or 'B<hv>';

=item B<-r:string>

Color transformation, possible values are: B<gray, noalpha, red, channel0, green, channel1, blue, channel2, alpha, rgb, addalpha>;

=item B<-x:chars>

Swap any two color channels: 'B<r>','B<g>' or 'B<b>'. Exactly two chars allowed;

=item B<-a>

Autolevels;

=item B<-v>

Verbose;

=item B<-help>

Display help screen of usage. Also display one if required parameter missing.

=back

=head1 AUTHOR

An0ther0ne

=head1 SEE ALSO

L<Imager|https://metacpan.org/pod/Imager>, L<Perl|http://www.perl.org/>, 

L<http://imager.perl.org/>

=head1 LICENSE

GNU General Public License v3.0

=cut
