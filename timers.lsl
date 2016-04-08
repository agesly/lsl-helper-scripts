list timer_identifiers; // identifier of the timer
list timer_times; // when the timer will trigger
list timer_links; // which linked prim asked for the timer

integer create_timer(integer link, integer identifier, integer seconds)
{
    integer current_time = llGetUnixTime();
    integer index = llListFindList(timer_identifiers, [identifier]);
    if (index != -1) {
        // identifier already registered
        return FALSE;
    }
    timer_identifiers += identifier;
    timer_times += seconds + current_time;
    timer_links += link;
}

// returns -1 or the time left in seconds
integer get_time_left(integer identifier) {
    integer current_time;
    integer index = llListFindList(timer_identifiers, [identifier]);
    if (index == -1)
    current_time = llGetUnixTime();
    llList2Integer(timer_times, integer index)
}

default
{
    state_entry()
    {
        llSetTimerEvent(0.0);
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
        llOwnerSay((string) ["sender: ", sender_num, "\nmessage: ", msg, "\nnum:", num]);
    }
    timer()
    {
        integer num_timers = llGetListLength(timer_times);
        integer current_time = llGetUnixTime();
        integer i = 0;
        integer identifier;
        integer time;
        integer link;
        for (; i < num_timers; ++i) {
            time = llList2Integer(timer_times, i);
            if (time <= current_time) {
                identifier = llList2Integer(timer_identifiers, i);
                link = llList2Integer(timer_links, i);
                llDeleteSubList(timer_identifiers, i, i);
                llDeleteSubList(timer_times, i, i);
                llMessageLinked(link, identifier, "timer_end", "");
            }
        }
    }
}