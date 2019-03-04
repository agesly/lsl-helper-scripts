/*--------------------------------------------------------------------------------*\
    MULTIPLE AND INDEPENDENT TIMERS MODULE

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
------------------------------------------------------------------------------------
    Special thanks to: Caraway Ohmai
\*--------------------------------------------------------------------------------*/


list timer_queue;

delete_timer(key identifier) {
    integer index = llListFindList(timer_queue, [identifier]);

    if (~index) {
        timer_queue = llDeleteSubList(timer_queue, index - 1, index + 1);
        if (index == 1) {
            if (llGetListLength(timer_queue)) {
                integer time_left = llList2Integer(timer_queue, 0) - llGetUnixTime();

                // Check if should have been triggered already
                if (time_left > 0) llSetTimerEvent(time_left);
                else llSetTimerEvent(0.01);
            } else {
                llSetTimerEvent(0.0);
            }
        }
    }
}

create_timer(integer link, key identifier, integer duration) {
    if (~llListFindList(timer_queue, [identifier])) {
        delete_timer(identifier); // delete if exists
    }

    if (duration <= 0) {
        return; // ignore if zero timer
    }

    integer timer_time = llGetUnixTime() + duration;
    integer other_time = timer_time;
    if (llGetListLength(timer_queue)) {
        other_time = llList2Integer(timer_queue, 0);
    }

    timer_queue = [timer_time, identifier, link] + timer_queue;

    if (other_time < timer_time) {
        // there are other timers that should fire first
        timer_queue = llListSort(timer_queue, 3, TRUE);
    } else {
        // no, this will be the next timer to fire
        llSetTimerEvent(duration);
    }

    llMessageLinked(link, duration, "timer_success", identifier);
}

// returns -1 or the time left in seconds
integer get_time_left(key identifier) {
    integer time_left;
    integer index = llListFindList(timer_queue, [identifier]);
    if (~index) {
        time_left = llList2Integer(timer_queue, index - 1) - llGetUnixTime();
        return time_left;
    } 
    return -1;
}

default
{
    state_entry() {
        llSetTimerEvent(0.0);
    }

    link_message(integer link, integer duration, string msg, key timer_id) {
        if (msg == "timer_new") {
            create_timer(link, timer_id, duration);
        } else
        if (msg == "timer_del") {
            delete_timer(timer_id);
        } else 
        if (msg == "timer_check") {
            llMessageLinked(link, get_time_left(timer_id), "timer_left", timer_id);
        }
    }

    timer() {
        integer num_timers = llGetListLength(timer_queue) / 3;
        integer current_time = llGetUnixTime();

        integer time_left = llList2Integer(timer_queue, 0) - current_time;
        key identifier;
        integer link;

        do {
            identifier = llList2Key(timer_queue, 1);
            link = llList2Integer(timer_queue, 2);

            llMessageLinked(link, -time_left, "timer_finished", identifier);
            timer_queue = llDeleteSubList(timer_queue, 0, 2);
            num_timers -= 1;

            if (num_timers > 0) {
                time_left = llList2Integer(timer_queue, 0) - current_time;
            }
        } while (time_left <= 0 && num_timers > 0);

        if (num_timers > 0) {
            llSetTimerEvent(time_left);
        } else {
            llSetTimerEvent(0.0);
        }
    }
}