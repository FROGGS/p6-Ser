use v6;
use Test;

my @to-delete;

%*ENV<SER_PM_TEST_FILE> = tempfile();

is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[42]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[42 42]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[42 42 42]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[42 42 42 42]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $a.push: 42; $f.spurt: serialize($a)', '[42 42 42 42 42]';
is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a;              $f.spurt: serialize($a)', '[42 42 42 42 42 42]';
#~ is-run 'my $a = $f.e ?? deserialize($f.slurp) !! []; say $a; $f.spurt: serialize($a)',                                      '[42 42 42]';

sub is-run($code, $out, $desc = "Test: $out") {
    for run($*EXECUTABLE, '-Ilib', '-MSer', '-e', 'my $f = %*ENV<SER_PM_TEST_FILE>.IO; ' ~ $code, :out) -> $proc {
        subtest {
            my $lines = $proc.out.lines.join('');
            my $ps    = $proc.out.close;
            ok $ps,                'subprocess succeeded';
            is $lines,       $out, 'got correct output';
        }, $desc
    }
}

sub tempfile {
    my $file = $*SPEC.catfile($*TMPDIR, 'Ser.pm-test-file');
    $file    = $file ~ 1000.rand.Int while $file.IO.e;
    if $file.IO.e {
        print "1..0 # Skip: Cannot create temporary file\n";
        exit 0
    }
    @to-delete.push: $file;
    $file
}

END {
    try .IO.unlink for @to-delete
}
