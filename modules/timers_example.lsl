integer timer_time = 5;
default
{
    touch_start(integer total_number)
    {
        llMessageLinked(LINK_THIS, 10, "timer_new", "my_timer_1");
        llMessageLinked(LINK_THIS, 5, "timer_new", "my_timer_2");
        llMessageLinked(LINK_THIS, 15, "timer_new", "my_timer_3");

        llMessageLinked(LINK_THIS, 0, "timer_check", "my_timer_1");
        llMessageLinked(LINK_THIS, 0, "timer_check", "my_timer_2");
        llMessageLinked(LINK_THIS, 0, "timer_check", "my_timer_3");
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (msg == "timer_success") {
            llSay(0, (string) ["timer '", id, "' was created successfully."]);
        } else
        if (msg == "timer_failed") {
            llSay(0, (string) ["timer '", id, "' was not created because: ", num]);
        } else
        if (msg == "timer_left") {
            llSay(0, (string) ["timer '", id, "' should fire in: ", num, " seconds"]);
        } else
        if (msg == "timer_finished") {
            llSay(0, (string) ["timer '", id, "' fired! (DONE) It was late by ", num, " seconds."]);
        }
    }
}
