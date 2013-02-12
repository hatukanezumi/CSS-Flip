use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'          => 'CSS::Flip',
    'ABSTRACT_FROM' => 'lib/CSS/Flip.pod',
    'VERSION_FROM'  => 'lib/CSS/Flip.pod',
    'PREREQ_PM'     => {'Test::More' => 0,},
    'EXE_FILES'     => [qw(bin/cssflip)],
    'NO_META'       => 1,
    'NO_MYMETA'     => 1,
);

