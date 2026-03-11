#ifndef HOST_SWD_STATUS_H
#define HOST_SWD_STATUS_H

enum
{
    SWD_STATUS_OK = 0,
    SWD_STATUS_GENERIC = -1,
    SWD_STATUS_TRANSPORT = -2,
    SWD_STATUS_ACK_WAIT = -3,
    SWD_STATUS_ACK_FAULT = -4,
    SWD_STATUS_ACK_PROTOCOL = -5,
    SWD_STATUS_UNSUPPORTED = -6,
    SWD_STATUS_VERIFY = -7,
    SWD_STATUS_TARGET = -8,
    SWD_STATUS_IO = -9,
    SWD_STATUS_ARGUMENT = -10
};

const char *swd_status_string(int status);

#endif
