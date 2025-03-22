# memcli

A simple command-line utility written in Zig for displaying system memory information.

## Overview

`memcli` is a lightweight cli tool that outputs memory in bytes, Kilobytes, and Megabytes. The Linux version just reads
from /proc/meminfo using the process module in Zig. This project is one of many for me to learn Zig syntax and internals.

## Platforms
Linux only currently but plan to add others

## Installation

### Prerequisites
- Zig compiler (version 0.14.0 used)
### Building from source
```bash
git clone https://github.com/yourusername/memcli.git
cd memcli
zig build -Drelease-safe
```

The compiled binary will be available in the `zig-out/bin` directory.

## Usage

```bash
memcli [OPTIONS]
```

### Options

- `-total`: Display total system memory
- `-kb`: Display memory information in kilobytes
- `-mb`: Display memory information in megabytes

You can combine multiple options. For example:

```bash
memcli -total -mb
```

This will display the total system memory in megabytes.

### Examples

1. Basic usage (default output):
   ```bash
   memcli
   ```

2. Show total memory in bytes:
   ```bash
   memcli -total
   ```

3. Display memory in kilobytes:
   ```bash
   memcli -kb
   ```
4. Display memory in MB:
   ```bash
   memcli -mb
   ```

5. Combined options:
   ```bash
   memcli -total -kb -mb
   ```

## Building

```bash
zig build
```

This will produce the `memcli` executable in the `zig-out/bin` directory.

## License

[MIT](LICENSE)

