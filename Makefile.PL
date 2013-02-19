package MY;
use ExtUtils::MakeMaker;

# For EU::MM < 6.58
sub postamble {
    my $self = shift;
    my $make_json = $self->cd(
	q{$(DISTVNAME)},
	q{$(FULLPERL) -MCPAN::Meta -MCPAN::Meta::Converter -e 'CPAN::Meta->new(CPAN::Meta::Converter->new(CPAN::Meta->load_file("META.yml"))->convert(version=>"2"))->save("META.json")'}
    );
    return "preop :\n\t$make_json\n\n";
}

WriteMakefile(
    'NAME'      => 'CSS::Flip',
    'ABSTRACT'  => 'Flip direction of Cascading Style Sheet (CSS)',
    'VERSION'   => '0.03',
    'AUTHOR'    => ['Hatuka*nezumi - IKEDA Soji <hatuka@nezumi.nu>'],
    'LICENSE'   => 'perl',
    'CONFIGURE_REQUIRES' => {
	'ExtUtils::MakeMaker' => '6.46',
    },
    'PREREQ_PM' => {
	'Test::More'          => '0.45',
    },
    'EXE_FILES'  => [qw(bin/cssflip)],
    'META_MERGE' => {
	'resources' => {
	    'license'    => 'http://dev.perl.org/licenses/',
	    'repository' => 'http://repos.nezumi.nu/repos/CSS-Flip/',
	},
    },
    'dist' => {
	'PREOP' => '$(MAKE) preop',
    },
);

