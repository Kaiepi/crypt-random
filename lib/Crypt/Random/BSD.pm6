use v6.c;
use NativeCall;

sub arc4random(--> uint32) is native {*}
sub arc4random_buf(Buf, size_t) is native {*}
sub arc4random_uniform(uint32 --> uint32) is native {*}

sub _crypt_random_bytes(uint32 $bytes --> Buf) is export {
    my Buf $buf .= allocate: $bytes;
    arc4random_buf($buf, $bytes);
    $buf
}

sub _crypt_random(--> Int) is export {
    arc4random
}

sub _crypt_random_uniform(Int $upper-bound --> Int) is export {
    arc4random_uniform($upper-bound)
}
