const std = @import("std");

const MemoryInfoError = error{
    CachedMemoryNotFound,
    AvailableMemoryNotFound,
    FileSystemError, // General filesystem errors
    AllocationError,
};

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator.init(.{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const args = try std.process.argsAlloc(arena.allocator());

    // print help usage if only command is supplied or -h is used
    if (args.len < 2 or (args.len == 2 and std.mem.eql(u8, args[1], "-h"))) {
        printUsage(args[0]);
        return; //exit after printing usage
    }

    try executeArgs(args, arena.allocator());
    // using try bubbles up the error to the containing function
}

fn getCachedMemory(allocator: std.mem.Allocator) !u64 {
    const file = try std.fs.openFileAbsolute("/proc/meminfo", .{});
    defer file.close();

    //const reader = file.reader();

    var bufferedReader = std.io.bufferedReader(file.reader());
    const reader = bufferedReader.reader();

    const content = try reader.readAllAlloc(allocator, 16 * 1024);
    defer allocator.free(content);

    //split content into lines and search for cached
    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "Cached:")) {
            //parse the number value
            var iter = std.mem.tokenizeAny(u8, line, " \t:");
            //std.debug.print("line output: {s}\n", .{line});
            _ = iter.next(); // skip cached token
            // get the value in kb
            if (iter.next()) |value| {
                // the value of 10 is the base type
                return try std.fmt.parseInt(u64, value, 10);
            }
        }
    }
    return error.cachedMemoryNotFound;
}
// []const []const u8 is a slice of slices , []const u8 is a string in zig
fn executeArgs(args: []const []const u8, allocator: std.mem.Allocator) !void {
    const systemRam: u64 = try std.process.totalSystemMemory();
    const systemCache: u64 = try getCachedMemory(allocator);
    const ramMb = systemRam / (1024 * 1024);
    const ramKb = systemRam / 1024;

    // Process each argument using a for loop
    // Skip args[0] which is the program name
    for (args[1..]) |arg| {
        if (std.mem.eql(u8, arg, "-total")) {
            std.debug.print("Total system RAM bytes: {}\n", .{systemRam});
        } else if (std.mem.eql(u8, arg, "-kb")) {
            std.debug.print("Total system RAM KB: {}\n", .{ramKb});
        } else if (std.mem.eql(u8, arg, "-mb")) {
            std.debug.print("Total system RAM MB: {}\n", .{ramMb});
        } else if (std.mem.eql(u8, arg, "-cached")) {
            std.debug.print("Total system cache KB: {}\n", .{systemCache});
        } else {
            std.debug.print("Unknown argument: {s}\n", .{arg});
            printUsage(args[0]);
        }
    }
}

fn printUsage(program_name: []const u8) void {
    std.debug.print("Usage {s} [options]\n", .{program_name});
    std.debug.print("Options:\n", .{});
    std.debug.print("  -total - Print total RAM in bytes\n", .{});
    std.debug.print("  -kb    - Print total RAM in kilobytes\n", .{});
    std.debug.print("  -mb    - Print total RAM in megabytes\n", .{});
    std.debug.print("  -cached  - Print total Cached RAM in Kilobytes\n", .{});
    std.debug.print("  -h    - Print these usage options\n", .{});
    std.debug.print("Example: {s} total kb mb\n", .{program_name});
}
