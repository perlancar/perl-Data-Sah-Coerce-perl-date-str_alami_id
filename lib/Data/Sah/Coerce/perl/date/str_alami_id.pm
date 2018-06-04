package Data::Sah::Coerce::perl::date::str_alami_id;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Data::Dmp;

# TMP
our $time_zone;

sub meta {
    +{
        v => 3,
        enable_by_default => 0,
        might_fail => 1,
        prio => 60, # a bit lower than normal
        precludes => [qr/\Astr_alami(_.+)?\z/, 'str_natural', 'str_flexible'],
    };
}

sub coerce {
    my %args = @_;

    my $dt = $args{data_term};
    my $coerce_to = $args{coerce_to} // 'float(epoch)';

    my $res = {};

    $res->{expr_match} = "!ref($dt)";
    $res->{modules}{"DateTime::Format::Alami::ID"} //= 0;
    $res->{expr_coerce} = join(
        "",
        "do { my \$datetime; eval { \$datetime = DateTime::Format::Alami::ID->new->parse_datetime($dt, {_time_zone => ".dmp($time_zone)."}) }; my \$err = \$@; ",
        ($coerce_to eq 'float(epoch)' ? "if (\$err) { \$err =~ s/ at .+//s; [\$err] } else { [undef, \$datetime->epoch ] } " :
             $coerce_to eq 'Time::Moment' ? "if (\$err) { \$err =~ s/ at .+//s; [\$err] } else { [undef, Time::Moment->from_object(\$datetime) ] } " :
             $coerce_to eq 'DateTime' ? "if (\$err) { \$err =~ s/ at .+//s; [\$err] } else { [undef, \$datetime] } " :
             (die "BUG: Unknown coerce_to '$coerce_to'")),
        "}",
    );

    $res;
}

1;
# ABSTRACT: Coerce date from string parsed by DateTime::Format::Alami::ID

=for Pod::Coverage ^(meta|coerce)$

=head1 DESCRIPTION

The rule is not enabled by default. You can enable it in a schema using e.g.:

 ["date", "x.perl.coerce_rules"=>["str_alami_id"]]
