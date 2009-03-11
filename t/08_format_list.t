#$Id$

=pod

Test  Pod::ToDocBook::FormatList filter

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
use_ok 'Pod::ToDocBook::FormatList';
use_ok 'Pod::ToDocBook::ProcessItems';

sub pod2xml {
    my $text = shift;
    my $buf;
    my $w = new XML::SAX::Writer:: Output => \$buf;
    my $px = new Pod::ToDocBook::Pod2xml:: header => 0, doctype => 'chapter';
    my $p = create_pipe(
        $px,'Pod::ToDocBook::FormatList','Pod::ToDocBook::ProcessItems',
        $w 
    );
    $p->parse($text);
    return $buf;
}

my $xml1 = pod2xml( <<'OUT1' );

=pod

=begin list

- item 1
- item 2
- item 3

=end list

=cut
OUT1

#diag  $xml1; exit;
# <chapter><pod><itemizedlist><listitem><para>item 1</para></listitem><listitem><para>item 2</para></listitem><listitem><para>item 3</para></listitem></itemizedlist></pod></chapter>
my ( $t1, $c1 );
( new XML::Flow:: \$xml1 )->read({
    listitem=>sub { shift; $c1++ },
    itemizedlist=>sub { $c1++},
});
is $c1, 4, 'format codes: count';


