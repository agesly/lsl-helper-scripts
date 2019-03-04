/*

MULTIPLE AND INDEPENDENT TIMERS

Copyright (C) 2019  Agesly Danzig

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

list timer_identifiers = []; // identifier of the timer
list timer_times = []; // when the timer will trigger
list timer_links = []; // which linked prim asked for the timer

integer ERR_TIMER_LENGTH = 1;

create_timer(integer link, key identifier, integer duration)
{
    integer index;

    index = llListFindList(timer_identifiers, [identifier]);

    if (~index) {
        // identifier already registered
        timer_identifiers = llDeleteSubList(timer_identifiers, 0, 0);
        timer_times = llDeleteSubList(timer_times, 0, 0);
        timer_links = llDeleteSubList(timer_links, 0, 0);

        if (index == 0) {
            if (llGetListLength(timer_times)) {
                integer time_left = llList2Integer(timer_times, 0) - llGetUnixTime();
                if (time_left > 0) {
                    llSetTimerEvent(llList2Integer(timer_times, 0) - llGetUnixTime());
                } else {
                    llSetTimerEvent(0.01);
                }
            } else {
                llSetTimerEvent(0.0);
            }
        }
        if (duration <= 0) { return; }
    }

    if (duration <= 0) {
        llMessageLinked(link, ERR_TIMER_LENGTH, "timer_failed", identifier);
        return;
    }

    integer timer_time = llGetUnixTime() + duration;
    integer list_length = llGetListLength(timer_times);
    integer other_time = timer_time;
    
    index = 0;
    if (list_length) {
        while (other_time <= timer_time && index < list_length) {
            other_time = llList2Integer(timer_times, index);
            if (other_time <= timer_time) index += 1;
        }
    }
    
    timer_identifiers = llListInsertList(timer_identifiers, [identifier], index);
    timer_times = llListInsertList(timer_times, [timer_time], index);
    timer_links = llListInsertList(timer_links, [link], index);

    if (index == 0) {
        llSetTimerEvent(duration);
    }

    llMessageLinked(link, duration, "timer_success", identifier);
}

// returns -1 or the time left in seconds
integer get_time_left(key identifier) {
    integer time_left;
    integer index = llListFindList(timer_identifiers, [identifier]);
    if (~index) {
        time_left = llList2Integer(timer_times, index) - llGetUnixTime();
        return time_left;
    } 
    return -1;
}

default
{
    state_entry()
    {
        llSetTimerEvent(0.0);
    }
    link_message(integer link, integer duration, string msg, key timer_id)
    {
        if (msg == "timer_new") {
            create_timer(link, timer_id, duration);
        } else
        if (msg == "timer_check") {
            llMessageLinked(link, get_time_left(timer_id), "timer_left", timer_id);
        }
    }
    timer()
    {
        integer num_timers = llGetListLength(timer_times);
        integer current_time = llGetUnixTime();
        key identifier;
        integer link;
        integer time_left = llList2Integer(timer_times, 0) - current_time;

        do {
            identifier = llList2Key(timer_identifiers, 0);
            link = llList2Integer(timer_links, 0);
            llMessageLinked(link, time_left, "timer_finished", identifier);

            timer_identifiers = llDeleteSubList(timer_identifiers, 0, 0);
            timer_times = llDeleteSubList(timer_times, 0, 0);
            timer_links = llDeleteSubList(timer_links, 0, 0);
            num_timers -= 1;

            if (num_timers > 0) time_left = llList2Integer(timer_times, 0) - current_time;
        } while (time_left <= 0 && num_timers > 0);

        if (num_timers > 0) {
            llSetTimerEvent(time_left);
        } else {
            llSetTimerEvent(0.0);
        }
    }
}