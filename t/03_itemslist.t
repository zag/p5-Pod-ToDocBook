#$Id$

=pod

Test  Pod::ToDocBook::ProcessItems filter

=cut

use strict;
use warnings;
#use Test::More ('no_plan');
use Test::More (tests=>12);
use XML::ExtOn qw( create_pipe );
use XML::SAX::Writer;
use XML::Flow;
use Data::Dumper;
use_ok 'Pod::ToDocBook::Pod2xml';
use_ok 'Pod::ToDocBook::ProcessItems';

sub pod2xml {
    my $text = shift;
    my $buf;
    my $w = new XML::SAX::Writer:: Output => \$buf;
    my $px = new Pod::ToDocBook::Pod2xml:: header => 0, doctype => 'chapter';
    my $p = create_pipe(
        $px, qw( Pod::ToDocBook::ProcessItems ),

        #      create_pipe( $px,
        $w
    );
    $p->parse($text);
    return $buf;
}

my $xml1 = pod2xml( <<OUT1 );

=over 

=item test

test

=item test2

test

=cut

OUT1

#diag $xml1;
#exit;
my $f1 = new XML::Flow:: \$xml1;
my ( $t1, $c1 );
$f1->read(
    {
        'variablelist' => sub { shift; $c1++; $t1 = \@_ },
        'varlistentry' => sub { shift; $c1++; return {@_} },
        term => sub { shift; return term => join "", @_ }
    }
);
is $c1, 3, 'variablelist: count';

#diag Dumper $t1;
is_deeply $t1, [ { 'term' => 'test' }, { 'term' => 'test2' } ],
  'variablelist: terms';

my $xml2 = pod2xml( <<OUT1 );

=over 1

text

=item * test

asdasdasd

=item * test2

asdasdasd

=back

=cut

OUT1

my $f2 = new XML::Flow:: \$xml2;
my ( $t2, $c2 );
$f2->read(
    {
        'itemizedlist' => sub { shift; $c2++; $t2 = \@_ },
        'listitem' => sub { shift; $c2++; return {@_} },
        para => sub { shift; return para => join "", @_ }
    }
);
is $c2, 3, 'itemizedlist: count';

is_deeply $t2, [ { 'para' => 'asdasdasd' }, { 'para' => 'asdasdasd' } ],
  'itemizedlist: paras';

my $xml3 = pod2xml( <<OUT1 );

=over 1

text

=item 1 test

asdasdasd

=back

=cut

OUT1

my $f3 = new XML::Flow:: \$xml3;
my ( $t3, $c3 );
$f3->read(
    {
        'orderedlist' => sub {
            my $attr = shift;
            $c3++;
            $c3++ if exists $attr->{numeration};
            $t3 = \@_;
        },
        'listitem' => sub { shift; $c3++; return {@_} },
        para => sub { shift; return para => join "", @_ }
    }
);
is $c3, 3, 'orderedlist: count';

is_deeply $t3, [ { 'para' => 'asdasdasd' } ], 'orderedlist: para';
my $xml4 = pod2xml( <<OUT1 );

=over 1

=item test

text

=item asdasdasd

dfsdfas 

=back

=cut

OUT1

# <chapter><variablelist><varlistentry><term><anchor id=':test' />test</term><listitem><para>text</para></listitem></varlistentry><varlistentry><term><anchor id=':asdasdasd' />asdasdasd</term><listitem><para>dfsdfas</para></listitem></varlistentry></variablelist></chapter>

my $f4 = new XML::Flow:: \$xml4;
my ( $t4, $c4 );
$f4->read(
    {
        'variablelist' => sub { shift; $c4++; $t4 = \@_ },
        'varlistentry' => sub { shift; $c4++; return varlistentry => \@_ },
        'listitem' => sub { shift; $c4++; return {@_} },
        'term' => sub { shift; $c4++; return term => \@_ },
        'anchor' => sub {
            my $attr = shift;
            $c4++;
            $c4++ if exists $attr->{ad};
            return { anchor => \@_ };
        },

        para => sub { shift; return para => join "", @_ }
    }
);
is $c4, 9, 'variablelist: count';
is_deeply $t4,
  [
    'varlistentry',
    [ 'term', [ { 'anchor' => [] }, 'test' ], { 'para' => 'text' } ],
    'varlistentry',
    [ 'term', [ { 'anchor' => [] }, 'asdasdasd' ], { 'para' => 'dfsdfas' } ]
  ],
  'variablelist: struct';

my $xml5 = pod2xml( <<OUT1 );

=over 1

test

  text

=back

=cut

OUT1

# <chapter><blockquote><para>test</para></blockquote><verbatim><![CDATA[  text
# ]]></verbatim></chapter> 
my $f5 = new XML::Flow:: \$xml5;
my ( $t5, $c5 );
$f5->read(
    {
        'blockquote' => sub { shift; $c5++; $t5 = \@_ },
        para => sub { shift; $c5++;return para => join "", @_ }
    }
);
is $c5, 2, 'blockqoute: count';
is_deeply $t5,  [
           'para',
           'test'
         ], 'blockqoute: struct';

