from ansible.plugins.callback import CallbackBase

try:
    from __main__ import display
except ImportError:
    display = None


class CallbackModule(CallbackBase):

    def __init__(self, *args, **kwargs):

        if display is not None:
            display.columns = 80

