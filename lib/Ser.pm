unit module Ser;
use nqp;

sub serialize($obj is copy) is export {
    my Mu $sh := nqp::list_s();
    my $name   = 'Ser_' ~ nqp::time_n();
    my Mu $sc := nqp::createsc(nqp::unbox_s($name));
    nqp::setobjsc($obj, $sc);
    nqp::scsetobj($sc, 0, $obj);
    my $serialized = nqp::serialize($sc, $sh);
    my Mu $iter := nqp::iterator($sh);
    while ($iter) {
        my $s := nqp::shift($iter);
    }
    nqp::scdisclaim($sc);
    nqp::shift_s($sh);
    $name ~ "\n" ~ nqp::p6box_s(nqp::join("\n", $sh)) ~ "\n" ~ $serialized
}

sub deserialize($b64) is export {
    my Mu $sh        := nqp::list_s();
    my @lines          = $b64.split("\n");
    my str $name       = nqp::unbox_s(@lines.shift);
    my str $serialized = nqp::unbox_s(@lines.pop);
    nqp::push_s($sh, nqp::null_s());
    nqp::push_s($sh, nqp::unbox_s($_)) for @lines;

    my Mu $sc := nqp::createsc(nqp::unbox_s($name));
    my $conflicts := nqp::list();
    nqp::deserialize($serialized, $sc, $sh, nqp::list(), $conflicts);
    my Mu $obj := nqp::scgetobj($sc, 0);
    #~ my $cnt = nqp::scobjcount($sc);
    #~ nqp::scgetobj($sc, $_) for 1..^$cnt;
    nqp::scdisclaim($sc);
    $obj
}
