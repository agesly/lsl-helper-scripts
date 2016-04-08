integer timer_id;
integer timer_time = 5;
default
{
    touch_start(integer total_number)
    {
        timer_id = (integer) llFrand(0xfffffe);
        llMessageLinked(LINK_THIS, timer_id, "timer_new", (string) timer_time);
        llMessageLinked(LINK_THIS, timer_id, "timer_check", "");
    }
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if (msg == "timer_success") {
            llSay(0, (string) ["timer '", num, "' was created successfully."]);
        } else
        if (msg == "timer_failed") {
            llSay(0, (string) ["timer '", num, "' was not created because: ", id]);
        } else
        if (msg == "timer_left") {
            llSay(0, (string) ["timer '", num, "' should fire in: ", id, " seconds"]);
        } else
        if (msg == "timer_finished") {
            llSay(0, (string) ["timer '", num, "' fired! (DONE) It was late by ", id, " seconds."]);
        }
    }
}
