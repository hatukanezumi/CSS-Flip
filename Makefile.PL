use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'      => 'CSS::Flip',
    'ABSTRACT'  => 'Flip direction of Cascading Style Sheet (CSS)',
    'VERSION'   => '0.02',
    'AUTHOR'    => ['Hatuka*nezumi - IKEDA Soji <hatuka@nezumi.nu>'],
    'LICENSE'   => 'perl',
    'PREREQ_PM' => {'Test::More' => '0.45',},
    'EXE_FILES' => [qw(bin/cssflip)],
);

