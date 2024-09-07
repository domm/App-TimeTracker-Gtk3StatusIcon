package App::TimeTracker::Gtk3StatusIcon;

# ABSTRACT: Show TimeTracker status as a GTK3 StatusIcon in the system tray
# VERSION

use 5.010;
use strict;
use warnings;

use Gtk3;
use AnyEvent;
use App::TimeTracker::Proto 3.100;
use App::TimeTracker::Data::Task;
use File::Share qw(dist_file);
use Clipboard;

sub init {
    my ($class, $run) = @_;
    my $storage_location = App::TimeTracker::Proto->new->home;

    my $lazy = dist_file( 'App-TimeTracker-Gtk3StatusIcon', 'lazy.png' );
    my $busy = dist_file( 'App-TimeTracker-Gtk3StatusIcon', 'busy.png' );

    Gtk3->init;
    my $icon   = Gtk3::StatusIcon->new_from_file($lazy);

    my $menu = Gtk3::Menu->new();
    my $item = Gtk3::MenuItem->new('...');
    $item->signal_connect( activate => sub {
        Clipboard->copy($item->get_label) unless $item->get_label eq 'nothing';
    } );
    $menu->append($item);

    my $quit = Gtk3::ImageMenuItem->new_from_stock('gtk-quit');
    $quit->signal_connect( activate => sub { Gtk3->main_quit } );
    $menu->append($quit);

    $menu->show_all();

    $icon->signal_connect( 'button-press-event' => sub { $menu->popup_at_pointer(  ) } );

    my $current;
    my $t = AnyEvent->timer(
        after    => 0,
        interval => 5,
        cb       => sub {
            my $task = App::TimeTracker::Data::Task->current($storage_location);
            if ($task) {
                $icon->set_from_file($busy);
                $current = $task->project;
                $current .= ' '.$task->id if $task->id;
                $current .= ': '.$task->description if $task->description;
                $item->set_label($current);
            }
            else {
                $icon->set_from_file($lazy);
                $current = 'nothing';
                $item->set_label($current);
            }
        } );

    Gtk3->main if $run;
}

1;

__END__

=head1 DESCRIPTION

Backend for L<tracker_gtk3statusicon.pl>

=method init

Initialize the GTK3 app.


