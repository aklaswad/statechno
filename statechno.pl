#!/usr/bin/env perl
use common::sense;
use Net::OpenSoundControl;
use Text::LTSV;
use AnyEvent;
use AnyEvent::Handle;
use Net::OpenSoundControl::Client;

my $p = Text::LTSV->new;
my $cv = AnyEvent->condvar;
my ($stats, $last) = ({},{ gain => 0 });
my $bpm = 128;
my $interval = (60 * 1000) / ($bpm * 4); # ms of 1/16 note length
my $hdl; $hdl = new AnyEvent::Handle
    fh => \*STDIN,
    on_read => sub {
        my $hdl = shift;
        my $line = $hdl->rbuf;
        my $log = $p->parse_line($line) or next;
        $stats->{substr( $log->{status}, 0, 1 )}++;
        $hdl->{rbuf} = '';
    };

my $osc = Net::OpenSoundControl::Client->new(
      Host => "127.0.0.1", Port => 19999)
      or die "Could not start client: $@\n";

my $w = AnyEvent->timer( after => 0, interval => $interval / 1000,  cb => sub {
    my $success = $stats->{2} || 0;
    my $total = 0;
    $total += $_ for values %$stats;
    my $e4 = $stats->{4} || 0;
    my $e5 = $stats->{5} || 0;
    $stats->{gain} = $last->{gain} * 0.95 + $success * 0.1;
    $osc->send([ '/hb',
        'f' => $interval,
        'i' => $stats->{2} || 0,
        'i' => $stats->{4} || 0,
        'i' => $stats->{5} || 0,
        'f' => $stats->{gain},
    ]);
    $last = $stats;
    $stats = {};

});


$cv->recv;
