use strict;
use warnings;
use Test::More;
use Redis::Fast;
use lib 't/tlib';
use Test::SpawnRedisServer;
use Test::SharedFork;
use Socket;

my ($c, $srv) = redis();
END { $c->() if $c }

use Test::LeakTrace;

no_leaks_ok {
    my $r = Redis::Fast->new(server => $srv);
} 'Redis::Fast->new';

no_leaks_ok {
    my $r = Redis::Fast->new(server => $srv);
    my $res;
    $r->set('hogehoge', 'fugafuga');
    $res = $r->get('hogehoge');
    $r->flushdb;
} 'sync get/set';

no_leaks_ok {
    my $r = Redis::Fast->new(server => $srv);
    my $res;
    $r->set('hogehoge', 'fugafuga', sub { });
    $r->get('hogehoge', sub { $res = shift });
    $r->wait_all_responses;
    $r->flushdb;
} 'async get/set';

no_leaks_ok {
    my $r = Redis::Fast->new(server => $srv);
    my $res;
    $r->rpush('hogehoge', 'fugafuga') for (1..3);
    $res = $r->lrange('hogehoge', 0, -1);
} 'sync list operation';

done_testing;