1795574685696983275
  File "/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/edlclient/edl.py", line 412, in run
    base.run()
    ~~~~~~~~^^
  File "/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/edlclient/edl.py", line 291, in run
    self.cdc = usb_class(portconfig=portconfig, loglevel=self.__logger.level, serial_number=self.serial_number)
               ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/edlclient/Library/Connection/usblib.py", line 71, in __init__
    super().__init__(loglevel, portconfig, devclass)
    ~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/opt/pipx/venvs/edlclient/lib/python3.14/site-packages/edlclient/Library/Connection/devicehandler.py", line 44, in __init__
    fh = logging.FileHandler(logfilename, encoding='utf-8')
  File "/usr/lib/python3.14/logging/__init__.py", line 1219, in __init__
    StreamHandler.__init__(self, self._open())
                                 ~~~~~~~~~~^^
  File "/usr/lib/python3.14/logging/__init__.py", line 1248, in _open
    return open_func(self.baseFilename, self.mode,
                     encoding=self.encoding, errors=self.errors)
FileNotFoundError: [Errno 2] No such file or directory: '/home/moon/xt3/logs/log.txt'
