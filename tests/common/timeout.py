#!/usr/bin/env python3

import signal
from contextlib import contextmanager

@contextmanager
def timeout(deadline, err_msg):
    # Register a function to raise a TimeoutError on the signal.
    signal.signal(signal.SIGALRM, raise_timeout)
    # Schedule the signal to be sent after ``time``.
    signal.alarm(deadline)

    try:
        yield
    except TimeoutError:
        raise Exception(err_msg)
    finally:
        # Unregister the signal so it won't be triggered
        # if the timeout is not reached.
        signal.signal(signal.SIGALRM, signal.SIG_IGN)


def raise_timeout(signum, frame):
    raise TimeoutError
