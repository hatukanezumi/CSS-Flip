package MY;
use ExtUtils::MakeMaker;

# For EU::MM < 6.58
sub postamble {
    my $self = shift;

    return "preop :\n\n"
	unless $self->can('cd');    # Earlier EU::MM don't have it.

    my $make_json = $self->cd(q{$(DISTVNAME)},
	q{$(FULLPERL) -MCPAN::Meta -MCPAN::Meta::Converter -e 'CPAN::Meta->new(CPAN::Meta::Converter->new(CPAN::Meta->load_file("META.yml"))->convert(version=>"2"))->save("META.json")'}
    );
    return "preop :\n\t$make_json\n\n";
}

WriteMakefile(
    'NAME'               => 'CSS::Flip',
    'ABSTRACT'           => 'Flip direction of Cascading Style Sheet (CSS)',
    'VERSION'            => '0.04_03',
    'AUTHOR'             => 'Hatuka*nezumi - IKEDA Soji <hatuka@nezumi.nu>',
    'LICENSE'            => 'perl',
    'MIN_PERL_VERSION'   => 5.005,
    'CONFIGURE_REQUIRES' => {'ExtUtils::MakeMaker' => '6.26',},
    'PREREQ_PM'          => {'Test::More' => '0.45', 'Pod::Usage' => 0,},
    'EXE_FILES'          => [qw(bin/cssflip)],
    'META_MERGE'         => {
	'no_index'  => {'directory' => ['lib/CSS/Yamaantaka'],},
	'resources' => {
	    'license'    => 'http://dev.perl.org/licenses/',
	    'repository' => 'https://github.com/hatukanezumi/CSS-Flip',
	},
    },
    'dist' => {'PREOP' => '$(MAKE) preop',},
);

