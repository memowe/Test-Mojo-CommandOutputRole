package Test::Mojo::CommandOutputRole;

use Role::Tiny;
use Mojo::Base -strict, -signatures;
use Test::More;
use File::Temp 'tmpnam';
use Test::Exception;

our $VERSION = '0.01';

sub command_output ($t, $command, $args, $test, $test_name = 'Output test') {
subtest $test_name => sub {

    # Capture output into temp file
    my $tmpfn   = tmpnam;
    open my $tmpf, '>', $tmpfn
        or die "Couldn't open temp file '$tmpfn': $!\n";
    select $tmpf;
    $|++; # enable flushing
    lives_ok sub {$t->app->start($command => @$args)},
        "Command didn't die";
    select STDOUT;
    close $tmpfn;

    # Slurp output
    open $tmpf, '<', $tmpfn
        or die "Couldn't open temp file '$tmpfn': $!\n";
    my $output = do {local $/; <$tmpf>}; # Standard idiom
    close $tmpf;

    # Test code: execute tests on output
    return subtest 'Handle command output' => sub {$test->($output)}
        if ref($test) eq 'CODE';

    # Output string regex test
    return like $output => $test, 'Output regex'
        if ref($test) eq 'Regexp';

    # Output string equality test
    return is $output => $test, 'Correct output string';
}}

1;
__END__
