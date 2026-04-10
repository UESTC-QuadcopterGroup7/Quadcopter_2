#include "swd_status.h"

const char *swd_status_string(int status)
{
    switch (status) {
    case SWD_STATUS_OK:
        return "ok";
    case SWD_STATUS_GENERIC:
        return "generic error";
    case SWD_STATUS_TRANSPORT:
        return "transport error";
    case SWD_STATUS_ACK_WAIT:
        return "target returned WAIT";
    case SWD_STATUS_ACK_FAULT:
        return "target returned FAULT";
    case SWD_STATUS_ACK_PROTOCOL:
        return "protocol error";
    case SWD_STATUS_UNSUPPORTED:
        return "backend not implemented";
    case SWD_STATUS_VERIFY:
        return "verification failed";
    case SWD_STATUS_TARGET:
        return "target reported an error";
    case SWD_STATUS_IO:
        return "file I/O error";
    case SWD_STATUS_ARGUMENT:
        return "invalid argument";
    default:
        return "unknown error";
    }
}
