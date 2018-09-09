use v6;
use if;
use strict;

# Some Linux distros have the header file for arc4random, so we can't just check by the OS alone.
my constant HAS_ARC4RANDOM = '/usr/include/bsd/stdlib.h'.IO.e
    || so $*VM.osname ~~ m:i/[free|open|net|dragonfly|ghost]bsd|darwin|solaris|openindiana/;

use Crypt::Random::Win:if($*DISTRO.is-win);
use Crypt::Random::Nix:if(!$*DISTRO.is-win && !HAS_ARC4RANDOM);
use Crypt::Random::BSD:if(HAS_ARC4RANDOM);

unit module Crypt::Random;

# Shim for function exported by OS-specific module
sub crypt_random_buf(uint32 $len) returns Buf is export {
    _crypt_random_bytes($len);
}

# https://rt.perl.org//Public/Bug/Display.html?id=127813
subset PosUInt32 of Int where 1 .. 2**32 - 1;

# Int from byte array (big endian)
sub crypt_random(PosUInt32 $size = 4) returns Int is export {
    return _crypt_random if HAS_ARC4RANDOM;

    my Int $count = 0;
    ($count +<= 8) += $_ for crypt_random_buf($size).values;
    $count;
}

# Translation of arc4random_uniform() for Perl6 and big Ints
sub crypt_random_uniform(Int $upper_bound, PosUInt32 $size = 4) returns Int is export {
    return _crypt_random_uniform($upper_bound) if HAS_ARC4RANDOM;

    if ($upper_bound < 2) {
        return 0;
    }

    my $min = (2**($size*8) - $upper_bound) % $upper_bound;
    my $r;

    loop (;;) {
        $r = crypt_random($size);
        if ($r >= $min) {
            last;
        }
    }

    $r % $upper_bound;
}
