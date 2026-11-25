1795570881599626301
usage: uefi-firmware-parser [-h] [-b] [--superbrute] [--depex] [-q]
                            [--color {always,never,auto}] [-p] [-o OUTPUT]
                            [-O] [-c] [-e] [-g GENERATE] [-j] [--test]
                            [--verbose]
                            file [file ...]

Parse, and optionally output, details and data on UEFI-related firmware.

positional arguments:
  file                  The file(s) to work on

options:
  -h, --help            show this help message and exit
  -b, --brute           The input is a blob and may contain FV headers.
  --superbrute          The input is a blob and may contain any sort of
                        firmware object
  --depex               The input is a DEPEX blob
  -q, --quiet           Do not show info.
  --color {always,never,auto}
                        Control the use of ANSI colors in the output. (auto is
=== LinuxLoader/ABL-moduler:
7:    Section 1: type 0x12, size 0x250cc (151756 bytes) (Terse executable (TE) section)
58:                Name: VerifiedBootDxe
79:                PUSH EFI_VARIABLE_WRITE_ARCH_PROTOCOL_GUID (6441f818-6362-4e44-b570-7dba31dd2453)
104:                Name: EmuVariableRuntimeDxe
462:                PUSH EFI_VARIABLE_WRITE_ARCH_PROTOCOL_GUID (6441f818-6362-4e44-b570-7dba31dd2453)
463:                PUSH EFI_VARIABLE_ARCH_PROTOCOL_GUID (1e5668e2-8481-11d4-bcf1-0080c73c8881)
