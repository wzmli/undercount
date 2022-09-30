use strict;
use 5.10.0;

$/ = undef;

open INC, "<", grep(/inc$/, @ARGV) or die;
my $inc = <INC>;

open TEX, "<", grep(/tex$/, @ARGV) or die;
my $tex = <TEX>;

$tex =~ s/\\author[^}]*}/$inc/;

print $tex;
