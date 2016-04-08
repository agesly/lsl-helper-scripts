/*
 * MULTIPLE AND INDEPENDENT TIMERS
 * Author: Agesly Danzig (Agesly Resident)
 */

float inteval = 0.5;

list timer_identifiers; // identifier of the timer
list timer_times; // when the timer will trigger
list timer_links; // which linked prim asked for the timer
create_timer(integer link, integer identifier, integer seconds)
{
    integer index;
    integer current_time = llGetUnixTime();
    if (seconds <= 0) {
        llMessageLinked(link, identifier, "timer_failed", "invalid duration");
    }
    index = llListFindList(timer_identifiers, [identifier]);
    if (index != -1) {
        // identifier already registered
        llMessageLinked(link, identifier, "timer_failed", "identifier in use");
    }
    timer_identifiers = [identifier] + timer_identifiers;
    timer_times = [current_time + seconds] + timer_times;
    timer_links = [link] + timer_links;
    llSetTimerEvent(inteval);
    llMessageLinked(link, identifier, "timer_success", "timer created");
}

// returns -1 or the time left in seconds
integer get_time_left(integer identifier) {
    integer current_time;
    integer time;
    integer index = llListFindList(timer_identifiers, [identifier]);
    if (index == -1) {
        return -1;
    }
    current_time = llGetUnixTime();
    time = llList2Integer(timer_times, index);
    return time - current_time;
}

default
{
    state_entry()
    {
        llSetTimerEvent(0.0);
    }
    link_message(integer link, integer timer_id, string msg, key time)
    {
        if (msg == "timer_new") {
            create_timer(link, timer_id, (integer) ((string) time));
        } else
        if (msg == "timer_check") {
            llMessageLinked(link, timer_id, "timer_left", (string) get_time_left(timer_id));
        }
    }
    timer()
    {
        integer num_timers = llGetListLength(timer_times);
        integer current_time = llGetUnixTime();
        integer i = num_timers - 1;
        integer identifier;
        integer time;
        integer link;
        integer time_left;
        for (; i >= 0; i -= 1) {
            time = llList2Integer(timer_times, i);
            time_left = time - current_time;
            if (time_left <= 0) {
                identifier = llList2Integer(timer_identifiers, i);
                link = llList2Integer(timer_links, i);
                llMessageLinked(link, identifier, "timer_finished", (string) (- time_left));
                timer_identifiers = llDeleteSubList(timer_identifiers, i, i);
                timer_times = llDeleteSubList(timer_times, i, i);
                timer_links = llDeleteSubList(timer_links, i, i);
            }
        }
        if (num_timers == 0) {
            llSetTimerEvent(0.0);
        }
    }
}