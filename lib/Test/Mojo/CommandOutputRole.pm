package Test::Mojo::CommandOutputRole;

use Role::Tiny;
use Mojo::Base -strict, -signatures;
use Test::More;
use Capture::Tiny 'capture';

our $VERSION = '0.01';

sub command_output ($t, $command, $args, $test, $test_name = 'Output test') {
subtest $test_name => sub {

    # Capture successful command output
    my ($output, $error) = capture {$t->app->start($command => @$args)};
    is $error => '', 'No error thrown by command';

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
