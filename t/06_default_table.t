#$Id$

=pod

Test  Pod::ToDocBook::TableDefault filter

=cut

use strict;
use warnings;
#use Test::More ('no_plan');
use Test::More tests => 6;
use XML::ExtOn qw( create_pipe );
use XML::SAX::Writer;
use XML::Flow;
use Data::Dumper;
use_ok 'Pod::ToDocBook::Pod2xml';
use_ok 'Pod::ToDocBook::ProcessHeads';
use_ok 'Pod::ToDocBook::DoSequences';
use_ok 'Pod::ToDocBook::TableDefault';
use_ok 'Pod::ToDocBook::ProcessItems';

sub pod2xml {
    my $text = shift;
    my $buf;
    my $w = new XML::SAX::Writer:: Output => \$buf;
    my $px = new Pod::ToDocBook::Pod2xml:: header => 0, doctype => 'chapter';
    my $p = create_pipe(
        $px, qw( 
         Pod::ToDocBook::DoSequences Pod::ToDocBook::ProcessHeads
         Pod::ToDocBook::TableDefault 
        ),
        $w 

    );
    $p->parse($text);
    return $buf;
}

my $xml1 = pod2xml( <<'OUT1' );

=pod

=begin table

table title
left, center, right
column name 1,"testname , meters", name3
123 , 123 , 123
1,2,"2, and 3"

=end table

=cut
OUT1

#diag  $xml1; exit;
# <chapter><pod><table><title>table title</title><tgroup cols='3'><colspec align='left' /><colspec align='center' /><colspec align='right' /><thead><row><entry>column name 1</entry><entry>testname , meters</entry><entry> name3</entry></row></thead><tbody><row><entry>123 </entry><entry> 123 </entry><entry> 123</entry></row><row><entry>1</entry><entry>2</entry><entry>2, and 3</entry></row></tbody></tgroup></table></pod></chapter>

my ( $t1, $c1 );
( new XML::Flow:: \$xml1 )->read({
    entry=>sub { shift; $c1++ },
    row=>sub { $c1++},
    colspec=>sub { $c1++},
});
is $c1, 12+3, 'format codes: count';


