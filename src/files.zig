//! raylib's core module, from raylib.h's "File system management functions" on:
//! file and directory access, the file access callbacks, compression and
//! encoding, and automation events.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, and raylib's own one-line comment
//! copied above the wrapper. What is not wrapped is listed in `not_wrapped`.
//!
//! This file imports only names the root also publishes (`c`, `cast`, `types`
//! and the type names they hold), because the root's re-export test requires
//! every top-level declaration here to exist in `raylibz` too. Private helpers
//! go in a `const internal = struct { ... };`, which that test skips.

const c = @import("raylib");
const cast = @import("cast.zig");
const types = @import("types.zig");

const FilePathList = types.FilePathList;
const AutomationEvent = types.AutomationEvent;
const AutomationEventList = types.AutomationEventList;

/// The functions of raylib.h's core module from "File system management functions" on that raylibz does not wrap, and
/// why. One line each.
pub const not_wrapped = [_]cast.NotWrapped{};

// File system management functions.

/// Load file data as byte array (read)
///
/// raylib's `int *dataSize` becomes the slice's length: null where raylib
/// returns `NULL` — no such file, an empty file, or a read error. Release the
/// slice with `unloadFileData`.
pub fn loadFileData(fileName: [:0]const u8) ?[]u8 {
    var dataSize: i32 = 0;
    return cast.asSlice(u8, c.LoadFileData(cast.cstr(fileName), &dataSize), dataSize);
}

/// Unload file data allocated by `loadFileData`
///
/// Takes ownership of the memory `data` points into and releases it; the memory
/// dies at this call.
pub fn unloadFileData(data: []u8) void {
    c.UnloadFileData(data.ptr);
}

/// Save data to file from byte array (write), returns true on success
///
/// raylib's `dataSize` is the slice's length: the slice is exactly what is
/// written.
pub fn saveFileData(fileName: [:0]const u8, data: []const u8) bool {
    return c.SaveFileData(cast.cstr(fileName), data.ptr, cast.asLen(data));
}

/// Export data to code (.h), returns true on success
///
/// raylib names the array and its size macro after `fileName` without its
/// extension, upper-cased, with `.`, `-`, `?`, `!` and `+` turned into `_`, and
/// writes the file through `saveFileText`. It reads `data[dataSize - 1]`
/// unconditionally, so `data` must not be empty.
pub fn exportDataAsCode(data: []const u8, fileName: [:0]const u8) bool {
    return c.ExportDataAsCode(data.ptr, cast.asLen(data), cast.cstr(fileName));
}

/// Load text data from file (read), returns a '\0' terminated string
///
/// Null where raylib returns `NULL` — no such file, or an empty file. Release
/// the slice with `unloadFileText`.
pub fn loadFileText(fileName: [:0]const u8) ?[:0]u8 {
    return cast.optOwnedSpan(c.LoadFileText(cast.cstr(fileName)));
}

/// Unload file text data allocated by `loadFileText`
///
/// Takes ownership of the memory `text` points into and releases it; the memory
/// dies at this call.
pub fn unloadFileText(text: [:0]u8) void {
    c.UnloadFileText(text.ptr);
}

/// Save text data to file (write), string must be '\0' terminated, returns true on success
pub fn saveFileText(fileName: [:0]const u8, text: [:0]const u8) bool {
    return c.SaveFileText(cast.cstr(fileName), cast.cstr(text));
}

// File access custom callbacks
// WARNING: Callbacks setup is intended for advanced users

/// Set custom file binary data loader
///
/// The parameter keeps raylib's own `LoadFileDataCallback`, as raylib declares
/// it: raylibz does not re-type it. Pass null to go back to raylib's own
/// loader.
pub const setLoadFileDataCallback = c.SetLoadFileDataCallback;

/// Set custom file binary data saver
///
/// The parameter keeps raylib's own `SaveFileDataCallback`, as raylib declares
/// it: raylibz does not re-type it. Pass null to go back to raylib's own saver.
pub const setSaveFileDataCallback = c.SetSaveFileDataCallback;

/// Set custom file text data loader
///
/// The parameter keeps raylib's own `LoadFileTextCallback`, as raylib declares
/// it: raylibz does not re-type it. Pass null to go back to raylib's own
/// loader.
pub const setLoadFileTextCallback = c.SetLoadFileTextCallback;

/// Set custom file text data saver
///
/// The parameter keeps raylib's own `SaveFileTextCallback`, as raylib declares
/// it: raylibz does not re-type it. Pass null to go back to raylib's own saver.
pub const setSaveFileTextCallback = c.SetSaveFileTextCallback;

/// Rename file (if exists), returns 0 on success
///
/// raylib calls C's `rename` with the two strings as they are: -1 when
/// `fileName` does not exist, and otherwise the C call's own result. raylib's
/// second parameter carries this function's own name, which Zig forbids a
/// parameter to repeat, so it is `newName` here.
pub fn fileRename(fileName: [:0]const u8, newName: [:0]const u8) i32 {
    return c.FileRename(cast.cstr(fileName), cast.cstr(newName));
}

/// Remove file (if exists), returns 0 on success
///
/// -1 when `fileName` does not exist, and otherwise C's `remove` result.
pub fn fileRemove(fileName: [:0]const u8) i32 {
    return c.FileRemove(cast.cstr(fileName));
}

/// Copy file from one path to another, dstPath created if it doesn't exist, returns 0 on success
///
/// raylib creates `dstPath`'s directory and then returns 0 for it, whether it
/// existed or was created — even when `srcPath` could not be read.
pub fn fileCopy(srcPath: [:0]const u8, dstPath: [:0]const u8) i32 {
    return c.FileCopy(cast.cstr(srcPath), cast.cstr(dstPath));
}

/// Move file from one directory to another, dstPath created if it doesn't exist, returns 0 on success
///
/// raylib copies, checks that the two files have the same length, and removes
/// `srcPath`: -1 when `srcPath` does not exist.
pub fn fileMove(srcPath: [:0]const u8, dstPath: [:0]const u8) i32 {
    return c.FileMove(cast.cstr(srcPath), cast.cstr(dstPath));
}

/// Replace text in an existing file, returns 0 on success
///
/// raylib needs its rtext module for this one (on by default); built without
/// it, raylib logs a warning and returns -1.
pub fn fileTextReplace(fileName: [:0]const u8, search: [:0]const u8, replacement: [:0]const u8) i32 {
    return c.FileTextReplace(cast.cstr(fileName), cast.cstr(search), cast.cstr(replacement));
}

/// Find text in existing file, returns -1 if index not found or index otherwise
///
/// raylib loads the file through `loadFileText`, which is null for a file that
/// exists but is empty, and hands that to C's `strstr`: that case is undefined
/// behaviour in raylib.
pub fn fileTextFindIndex(fileName: [:0]const u8, search: [:0]const u8) i32 {
    return c.FileTextFindIndex(cast.cstr(fileName), cast.cstr(search));
}

/// Check if file exists
pub fn fileExists(fileName: [:0]const u8) bool {
    return c.FileExists(cast.cstr(fileName));
}

/// Check if directory path exists
pub fn directoryExists(dirPath: [:0]const u8) bool {
    return c.DirectoryExists(cast.cstr(dirPath));
}

/// Check file extension (recommended include point: .png, .wav)
///
/// `ext` may list several extensions separated by `;`, with or without the
/// leading dot, and the comparison ignores case: `".png;.apng"`, `"png"`.
pub fn isFileExtension(fileName: [:0]const u8, ext: [:0]const u8) bool {
    return c.IsFileExtension(cast.cstr(fileName), cast.cstr(ext));
}

/// Check if file path (file or directory) is hidden by OS
///
/// On POSIX raylib only looks at the last component of the path and answers
/// true for a leading dot; on Windows it reads the file's attributes.
pub fn isFileHidden(filePath: [:0]const u8) bool {
    return c.IsFileHidden(cast.cstr(filePath));
}

/// Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
///
/// 0 when raylib cannot open the file.
pub fn getFileLength(fileName: [:0]const u8) i32 {
    return c.GetFileLength(cast.cstr(fileName));
}

/// Get file modification time (last write time)
///
/// raylib's C `long`, in seconds since the Unix epoch; 32 bits on Windows, where
/// raylib truncates `time_t` to it. 0 when raylib cannot stat the file.
pub fn getFileModTime(fileName: [:0]const u8) c_long {
    return c.GetFileModTime(cast.cstr(fileName));
}

/// Get pointer to extension for a filename string (includes dot: '.png')
///
/// raylib returns a pointer into `fileName`, not a copy, so the slice lasts as
/// long as `fileName` does. Null when the name has no dot, or its first
/// character is the dot.
pub fn getFileExtension(fileName: [:0]const u8) ?[:0]const u8 {
    return cast.optSpan(c.GetFileExtension(cast.cstr(fileName)));
}

/// Get pointer to filename for a path string
///
/// raylib returns a pointer into `filePath` — or `filePath` itself when it holds
/// no separator — not a copy, so the slice lasts as long as `filePath` does.
pub fn getFileName(filePath: [:0]const u8) [:0]const u8 {
    return cast.span(c.GetFileName(cast.cstr(filePath)));
}

/// Get filename string without extension (uses static string)
///
/// raylib's static buffer: valid until the next call to `getFileNameWithoutExt`.
/// It cuts at the last dot of the file name it found in `filePath`.
pub fn getFileNameWithoutExt(filePath: [:0]const u8) [:0]const u8 {
    return cast.span(c.GetFileNameWithoutExt(cast.cstr(filePath)));
}

/// Get full path for a provided fileName with path (uses static string)
///
/// raylib's static buffer: valid until the next call to `getDirectoryPath`. A
/// relative path gets `./` prepended (`sub/file.txt` gives `./sub`), an
/// absolute one keeps its root (`/sub/file.txt` gives `/sub`).
pub fn getDirectoryPath(filePath: [:0]const u8) [:0]const u8 {
    return cast.span(c.GetDirectoryPath(cast.cstr(filePath)));
}

/// Get previous directory path for a provided path (uses static string)
///
/// raylib's static buffer: valid until the next call to `getPrevDirectoryPath`.
pub fn getPrevDirectoryPath(dirPath: [:0]const u8) [:0]const u8 {
    return cast.span(c.GetPrevDirectoryPath(cast.cstr(dirPath)));
}

/// Get current working directory (uses static string)
///
/// raylib's static buffer: valid until the next call to `getWorkingDirectory`.
/// Null where raylib returns `NULL`, which is C's `getcwd` failing — a working
/// directory longer than raylib's buffer, or an unreadable one.
pub fn getWorkingDirectory() ?[:0]const u8 {
    return cast.optSpan(c.GetWorkingDirectory());
}

/// Get the directory of the running application (uses static string)
///
/// raylib's static buffer: valid until the next call to
/// `getApplicationDirectory`. It ends with a path separator.
pub fn getApplicationDirectory() [:0]const u8 {
    return cast.span(c.GetApplicationDirectory());
}

/// Create directories (including full path requested), returns 0 on success
pub fn makeDirectory(dirPath: [:0]const u8) i32 {
    return c.MakeDirectory(cast.cstr(dirPath));
}

/// Change working directory, returns 0 on success
///
/// Moves the whole process: raylib calls C's `chdir`, and every later relative
/// path — raylib's own included — resolves against the new directory.
pub fn changeDirectory(dirPath: [:0]const u8) i32 {
    return c.ChangeDirectory(cast.cstr(dirPath));
}

/// Check if provided path points to a file
///
/// raylib's answer is C's `stat` saying the path is a regular file: false for a
/// directory and false for a path that does not exist.
pub fn isPathFile(path: [:0]const u8) bool {
    return c.IsPathFile(cast.cstr(path));
}

/// Check if provided path points to a directory
///
/// raylib's answer is `!isPathFile(path)`, so a path that does not exist counts
/// as a directory too.
pub fn isPathDirectory(path: [:0]const u8) bool {
    return c.IsPathDirectory(cast.cstr(path));
}

/// Check if provided path is an absolute path
///
/// On POSIX raylib looks for a leading `/`; on Windows for a UNC prefix or a
/// drive letter with a separator.
pub fn isPathAbsolute(path: [:0]const u8) bool {
    return c.IsPathAbsolute(cast.cstr(path));
}

/// Check if fileName is valid for the platform/OS
///
/// raylib rejects a name holding `<`, `>`, `:`, `"`, `/`, `\`, `|`, `?`, `*`, a
/// character below 32, or nothing but periods — and answers true for an empty
/// name.
pub fn isFileNameValid(fileName: [:0]const u8) bool {
    return c.IsFileNameValid(cast.cstr(fileName));
}

/// Load directory filepaths, files and directories, no subdirs scan
///
/// raylib allocates the list — each path has `dirPath` prepended — and scans
/// the directory twice, first for the count. An empty list (count 0, paths
/// null) when the directory cannot be opened. Release it with
/// `unloadDirectoryFiles`.
pub fn loadDirectoryFiles(dirPath: [:0]const u8) FilePathList {
    return cast.as(FilePathList, c.LoadDirectoryFiles(cast.cstr(dirPath)));
}

/// Load directory filepaths with extension filtering and subdir scan; some filters available: '*.*','FILES*','DIRS*'
///
/// raylib allocates the list, each path with `basePath` prepended. A null
/// `filter` takes every file and no directory; `"*.*"` takes files and
/// directories alike. Release it with `unloadDirectoryFiles`.
pub fn loadDirectoryFilesEx(basePath: [:0]const u8, filter: ?[:0]const u8, scanSubdirs: bool) FilePathList {
    return cast.as(FilePathList, c.LoadDirectoryFilesEx(cast.cstr(basePath), cast.optCstr(filter), scanSubdirs));
}

/// Unload filepaths
///
/// Takes ownership of the paths `files` holds, and of the array of them, and
/// releases both; they die at this call. raylib's own note: `files.count` is
/// not reset, so the list is stale, not empty, afterwards.
pub fn unloadDirectoryFiles(files: FilePathList) void {
    c.UnloadDirectoryFiles(cast.as(c.FilePathList, files));
}

/// Check if file has been dropped into window
pub const isFileDropped = c.IsFileDropped;

/// Load dropped filepaths
///
/// raylib's own list of the paths dropped into the window this frame — the
/// paths are raylib's, not a copy — empty when no file has been dropped.
/// Release it with `unloadDroppedFiles`.
pub fn loadDroppedFiles() FilePathList {
    return cast.as(FilePathList, c.LoadDroppedFiles());
}

/// Unload dropped filepaths
///
/// Takes ownership of the paths `files` holds, and of the array of them, and
/// releases both; they die at this call. This also clears raylib's dropped-file
/// state, because the paths are raylib's own.
pub fn unloadDroppedFiles(files: FilePathList) void {
    c.UnloadDroppedFiles(cast.as(c.FilePathList, files));
}

/// Get the file count in a directory
pub fn getDirectoryFileCount(dirPath: [:0]const u8) u32 {
    return c.GetDirectoryFileCount(cast.cstr(dirPath));
}

/// Get the file count in a directory with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
///
/// The filter tags are `"*.*"`, `"FILES*"` and `"DIRS*"`, as in
/// `loadDirectoryFilesEx`; a null `filter` counts every file and no directory.
pub fn getDirectoryFileCountEx(basePath: [:0]const u8, filter: ?[:0]const u8, scanSubdirs: bool) u32 {
    return c.GetDirectoryFileCountEx(cast.cstr(basePath), cast.optCstr(filter), scanSubdirs);
}

// Compression/Encoding functionality.

/// Compress data (DEFLATE algorithm), memory must be MemFree()
///
/// raylib allocates the compressed bytes: release them with raylib's
/// `MemFree`. The slice's length is raylib's `compDataSize`; null when raylib
/// returns `NULL` — out of memory, or a library built without its compression
/// API.
pub fn compressData(data: []const u8) ?[]u8 {
    var compDataSize: i32 = 0;
    return cast.asSlice(u8, c.CompressData(data.ptr, cast.asLen(data), &compDataSize), compDataSize);
}

/// Decompress data (DEFLATE algorithm), memory must be MemFree()
///
/// `compData` must be a DEFLATE stream, as `compressData` returns. raylib
/// allocates the decompressed bytes: release them with raylib's `MemFree`. The
/// slice's length is raylib's `dataSize`; null when raylib returns `NULL`.
pub fn decompressData(compData: []const u8) ?[]u8 {
    var dataSize: i32 = 0;
    return cast.asSlice(u8, c.DecompressData(compData.ptr, cast.asLen(compData), &dataSize), dataSize);
}

/// Encode data to Base64 string (includes NULL terminator), memory must be MemFree()
///
/// raylib allocates the NUL-terminated text: release it with raylib's `MemFree`.
/// The slice is the text without the terminator, one byte shorter than raylib's
/// `outputSize`, which counts the terminator. Null when raylib returns `NULL`.
pub fn encodeDataBase64(data: []const u8) ?[:0]u8 {
    var outputSize: i32 = 0;
    return cast.optOwnedSpan(c.EncodeDataBase64(data.ptr, cast.asLen(data), &outputSize));
}

/// Decode Base64 string (expected NULL terminated), memory must be MemFree()
///
/// raylib allocates the decoded bytes: release them with raylib's `MemFree`. The
/// slice's length is raylib's `outputSize`; null when raylib returns `NULL`.
pub fn decodeDataBase64(text: [:0]const u8) ?[]u8 {
    var outputSize: i32 = 0;
    return cast.asSlice(u8, c.DecodeDataBase64(cast.cstr(text), &outputSize), outputSize);
}

/// Compute CRC32 hash code
///
/// The IEEE CRC-32 that zlib, gzip and PNG use, over `data`.
pub fn computeCRC32(data: []const u8) u32 {
    return c.ComputeCRC32(data.ptr, cast.asLen(data));
}

/// Compute MD5 hash code, returns static int[4] (16 bytes)
///
/// raylib's own static `[4]u32`: the four state words of `data`'s MD5, whose
/// digest is those words little-endian, in order. The array is raylib's, and
/// the next call to `computeMD5` writes over it.
pub fn computeMD5(data: []const u8) *const [4]u32 {
    return @ptrCast(c.ComputeMD5(data.ptr, cast.asLen(data)));
}

/// Compute SHA1 hash code, returns static int[5] (20 bytes)
///
/// raylib's own static `[5]u32`: the five state words of `data`'s SHA-1, whose
/// digest is those words big-endian, in order. The array is raylib's, and the
/// next call to `computeSHA1` writes over it.
pub fn computeSHA1(data: []const u8) *const [5]u32 {
    return @ptrCast(c.ComputeSHA1(data.ptr, cast.asLen(data)));
}

/// Compute SHA256 hash code, returns static int[8] (32 bytes)
///
/// raylib's own static `[8]u32`: the eight state words of `data`'s SHA-256,
/// whose digest is those words big-endian, in order. The array is raylib's, and
/// the next call to `computeSHA256` writes over it.
pub fn computeSHA256(data: []const u8) *const [8]u32 {
    return @ptrCast(c.ComputeSHA256(data.ptr, cast.asLen(data)));
}

// Automation events functionality.

/// Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
///
/// raylib allocates the list, ready to record: pass null for an empty one, as
/// raylib's own example does. Release it with `unloadAutomationEventList`.
pub fn loadAutomationEventList(fileName: ?[:0]const u8) AutomationEventList {
    return cast.as(AutomationEventList, c.LoadAutomationEventList(cast.optCstr(fileName)));
}

/// Unload automation events list from file
///
/// Takes ownership of the events `list` holds and releases them; they die at
/// this call.
pub fn unloadAutomationEventList(list: AutomationEventList) void {
    c.UnloadAutomationEventList(cast.as(c.AutomationEventList, list));
}

/// Export automation events list as text file
///
/// raylib writes `list.count` lines, naming each event's type through its own
/// table: `list.events[i].type` indexes it, and an event type outside that table
/// is read out of bounds.
pub fn exportAutomationEventList(list: AutomationEventList, fileName: [:0]const u8) bool {
    return c.ExportAutomationEventList(cast.as(c.AutomationEventList, list), cast.cstr(fileName));
}

/// Set automation event list to record to
///
/// raylib keeps the pointer for `playAutomationEvent` and its frame recorder, so
/// `list` must stay alive, and at the same address, while it is set; pass null to
/// unset it.
pub fn setAutomationEventList(list: ?*AutomationEventList) void {
    const translated: [*c]c.AutomationEventList = if (list) |value| @ptrCast(value) else null;
    c.SetAutomationEventList(translated);
}

/// Set automation event internal base frame to start recording
pub const setAutomationEventBaseFrame = c.SetAutomationEventBaseFrame;

/// Start recording automation events (AutomationEventList must be set)
pub const startAutomationEventRecording = c.StartAutomationEventRecording;

/// Stop recording automation events
pub const stopAutomationEventRecording = c.StopAutomationEventRecording;

/// Play a recorded automation event
///
/// Does nothing while raylib is recording. `event.type` is raylib's own
/// `AutomationEventType` (rcore.c's, not raylib.h's): 1 is a key up, 2 a key
/// down, 3 a key pressed, 4 a key released, 5 and 6 a mouse button up and down,
/// 7 a mouse position, 8 a wheel motion, and on through gamepad, touch, window
/// and action events.
pub fn playAutomationEvent(event: AutomationEvent) void {
    c.PlayAutomationEvent(cast.as(c.AutomationEvent, event));
}

/// Private helpers: the tests' own plumbing, which the root does not re-export.
const internal = struct {
    const std = @import("std");
    const builtin = @import("builtin");

    /// The path of the temporary directory `tmp` made, as raylib wants it: the
    /// same relative path `std.testing.tmpDir` opened, which raylib resolves
    /// against the process's own working directory.
    fn tmpDirPath(gpa: std.mem.Allocator, tmp: *const std.testing.TmpDir) ![:0]u8 {
        return std.mem.joinZ(gpa, "/", &.{ ".zig-cache", "tmp", &tmp.sub_path });
    }

    /// The path of `name` inside `dir`, NUL-terminated as raylib wants it, joined with the
    /// separator raylib's directory scans use: `\` on Windows, `/` elsewhere.
    fn pathZ(gpa: std.mem.Allocator, dir: []const u8, name: []const u8) ![:0]u8 {
        return std.mem.joinZ(gpa, std.fs.path.sep_str, &.{ dir, name });
    }

    /// Whether the scanned `list` holds `path` among its entries.
    fn holds(list: FilePathList, path: []const u8) bool {
        for (list.paths.?[0..list.count]) |entry| {
            if (std.mem.eql(u8, std.mem.span(entry), path)) return true;
        }
        return false;
    }
};

test "files: data and text round trips in a temporary directory" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const gpa = std.testing.allocator;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const dir = try internal.tmpDirPath(gpa, &tmp);
    defer gpa.free(dir);

    const data_path = try internal.pathZ(gpa, dir, "sample.bin");
    defer gpa.free(data_path);

    // Binary data: written, stat'ed, read back, released.
    const payload = [_]u8{ 0, 1, 2, 0xfe, 0xff, 42 };
    try std.testing.expect(saveFileData(data_path, &payload));
    try std.testing.expect(fileExists(data_path));
    try std.testing.expectEqual(@as(i32, payload.len), getFileLength(data_path));
    try std.testing.expect(getFileModTime(data_path) > 0);
    {
        const loaded = loadFileData(data_path) orelse return error.ExpectedData;
        defer unloadFileData(loaded);
        try std.testing.expectEqualSlices(u8, &payload, loaded);
    }

    // Text: written, read back NUL-terminated.
    const text_path = try internal.pathZ(gpa, dir, "note.txt");
    defer gpa.free(text_path);
    try std.testing.expect(saveFileText(text_path, "hello\nworld\n"));
    {
        const text = loadFileText(text_path) orelse return error.ExpectedText;
        defer unloadFileText(text);
        try std.testing.expectEqualStrings("hello\nworld\n", text);
    }

    // An empty file and a file that is not there both read back as null.
    const empty_path = try internal.pathZ(gpa, dir, "empty.bin");
    defer gpa.free(empty_path);
    try std.testing.expect(saveFileText(empty_path, ""));
    try std.testing.expectEqual(@as(i32, 0), getFileLength(empty_path));
    try std.testing.expect(loadFileData(empty_path) == null);
    try std.testing.expect(loadFileText(empty_path) == null);

    const missing_path = try internal.pathZ(gpa, dir, "missing.bin");
    defer gpa.free(missing_path);
    try std.testing.expect(!fileExists(missing_path));
    try std.testing.expect(loadFileData(missing_path) == null);
    try std.testing.expect(loadFileText(missing_path) == null);
    try std.testing.expectEqual(@as(i32, 0), getFileLength(missing_path));
    try std.testing.expectEqual(@as(c_long, 0), getFileModTime(missing_path));

    // ExportDataAsCode writes a header C can include, named after the file.
    const code_path = try internal.pathZ(gpa, dir, "data.h");
    defer gpa.free(code_path);
    try std.testing.expect(exportDataAsCode(&payload, code_path));
    {
        const code = loadFileText(code_path) orelse return error.ExpectedText;
        defer unloadFileText(code);
        try std.testing.expect(std.mem.find(u8, code, "#define DATA_DATA_SIZE     6") != null);
        try std.testing.expect(std.mem.find(u8, code, "static unsigned char DATA_DATA[DATA_DATA_SIZE] = {") != null);
        try std.testing.expect(std.mem.find(u8, code, "0x2a };") != null);
    }

    // The path helpers: the text points into the argument, or into raylib's own
    // static buffer, which the next call hands back again.
    try std.testing.expectEqualStrings(".bin", getFileExtension(data_path).?);
    try std.testing.expect(getFileExtension("noextension") == null);
    try std.testing.expect(getFileExtension(".hidden") == null);

    try std.testing.expect(isFileExtension(data_path, ".bin"));
    try std.testing.expect(isFileExtension(data_path, "bin"));
    try std.testing.expect(isFileExtension(data_path, ".BIN"));
    try std.testing.expect(isFileExtension(data_path, ".png;.bin"));
    try std.testing.expect(!isFileExtension(data_path, ".png"));

    try std.testing.expectEqualStrings("sample.bin", getFileName(data_path));
    try std.testing.expectEqualStrings("sample.bin", getFileName("sample.bin"));
    try std.testing.expectEqualStrings("sample", getFileNameWithoutExt(data_path));
    try std.testing.expectEqualStrings("sample", getFileNameWithoutExt("sample.bin"));
    try std.testing.expectEqualStrings("other", getFileNameWithoutExt("sub/other.txt"));
    try std.testing.expectEqual(
        getFileNameWithoutExt(data_path).ptr,
        getFileNameWithoutExt("sample.bin").ptr,
    );

    // raylib keeps "./" on the front of a relative path it computes.
    const dotted_dir = try std.mem.concat(gpa, u8, &.{ "./", dir });
    defer gpa.free(dotted_dir);
    try std.testing.expectEqualStrings(dotted_dir, getDirectoryPath(data_path));
    try std.testing.expectEqualStrings("./", getDirectoryPath("file.txt"));
    try std.testing.expectEqualStrings(std.fs.path.dirname(dir).?, getPrevDirectoryPath(data_path));

    const working_directory = getWorkingDirectory() orelse return error.ExpectedDirectory;
    try std.testing.expect(isPathAbsolute(working_directory));
    try std.testing.expect(!isPathAbsolute("relative/path.txt"));
    try std.testing.expect(isFileHidden(".hidden") or internal.builtin.os.tag == .windows);
    try std.testing.expect(!isFileHidden("visible"));

    // The application's directory always ends with a path separator.
    const separator = if (internal.builtin.os.tag == .windows) "\\" else "/";
    try std.testing.expect(std.mem.endsWith(u8, getApplicationDirectory(), separator));

    try std.testing.expect(isPathFile(data_path));
    try std.testing.expect(!isPathFile(dir));
    try std.testing.expect(isPathDirectory(dir));
    try std.testing.expect(!isPathDirectory(data_path));
    // raylib answers `!isPathFile`, so a path that is not there counts as a
    // directory.
    try std.testing.expect(isPathDirectory(missing_path));

    try std.testing.expect(isFileNameValid("sample.bin"));
    try std.testing.expect(!isFileNameValid("sa/mple.bin"));
    try std.testing.expect(!isFileNameValid("..."));

    // Copy, rename, move and remove, on real files.
    const copy_path = try internal.pathZ(gpa, dir, "copy.bin");
    defer gpa.free(copy_path);
    try std.testing.expectEqual(@as(i32, 0), fileCopy(data_path, copy_path));
    {
        const copied = loadFileData(copy_path) orelse return error.ExpectedData;
        defer unloadFileData(copied);
        try std.testing.expectEqualSlices(u8, &payload, copied);
    }

    const renamed_path = try internal.pathZ(gpa, dir, "renamed.bin");
    defer gpa.free(renamed_path);
    try std.testing.expectEqual(@as(i32, 0), fileRename(copy_path, renamed_path));
    try std.testing.expect(!fileExists(copy_path));
    try std.testing.expect(fileExists(renamed_path));
    try std.testing.expectEqual(@as(i32, -1), fileRename(copy_path, renamed_path));

    const moved_dir = try internal.pathZ(gpa, dir, "moved");
    defer gpa.free(moved_dir);
    const moved_path = try internal.pathZ(gpa, moved_dir, "renamed.bin");
    defer gpa.free(moved_path);
    try std.testing.expectEqual(@as(i32, 0), fileMove(renamed_path, moved_path));
    try std.testing.expect(!fileExists(renamed_path));
    try std.testing.expect(fileExists(moved_path));
    try std.testing.expect(directoryExists(moved_dir));

    try std.testing.expectEqual(@as(i32, 0), fileRemove(moved_path));
    try std.testing.expect(!fileExists(moved_path));
    try std.testing.expectEqual(@as(i32, -1), fileRemove(moved_path));

    // File text search and replacement, through raylib's rtext module.
    const notes_path = try internal.pathZ(gpa, dir, "notes.txt");
    defer gpa.free(notes_path);
    try std.testing.expect(saveFileText(notes_path, "one two three"));
    try std.testing.expectEqual(@as(i32, 4), fileTextFindIndex(notes_path, "two"));
    try std.testing.expectEqual(@as(i32, -1), fileTextFindIndex(notes_path, "four"));
    try std.testing.expectEqual(@as(i32, 0), fileTextReplace(notes_path, "two", "2"));
    {
        const replaced = loadFileText(notes_path) orelse return error.ExpectedText;
        defer unloadFileText(replaced);
        try std.testing.expectEqualStrings("one 2 three", replaced);
    }
}

test "files: directory scans, dropped files and the working directory" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const gpa = std.testing.allocator;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const dir = try internal.tmpDirPath(gpa, &tmp);
    defer gpa.free(dir);

    const a_path = try internal.pathZ(gpa, dir, "a.txt");
    defer gpa.free(a_path);
    const b_path = try internal.pathZ(gpa, dir, "b.bin");
    defer gpa.free(b_path);
    const hidden_path = try internal.pathZ(gpa, dir, ".hidden");
    defer gpa.free(hidden_path);
    const sub_path = try internal.pathZ(gpa, dir, "sub");
    defer gpa.free(sub_path);
    const inner_path = try internal.pathZ(gpa, sub_path, "inner.bin");
    defer gpa.free(inner_path);

    try std.testing.expect(!directoryExists(sub_path));
    try std.testing.expectEqual(@as(i32, 0), makeDirectory(sub_path));
    try std.testing.expect(directoryExists(sub_path));
    try std.testing.expectEqual(@as(i32, 0), makeDirectory(sub_path));
    try std.testing.expect(saveFileData(a_path, "a"));
    try std.testing.expect(saveFileData(b_path, "b"));
    try std.testing.expect(saveFileData(hidden_path, "h"));
    try std.testing.expect(saveFileData(inner_path, "i"));

    // The counts: files and directories, files only, one extension, directories
    // only, and a recursive scan.
    try std.testing.expectEqual(@as(u32, 4), getDirectoryFileCount(dir));
    try std.testing.expectEqual(@as(u32, 3), getDirectoryFileCountEx(dir, null, false));
    try std.testing.expectEqual(@as(u32, 1), getDirectoryFileCountEx(dir, ".bin", false));
    try std.testing.expectEqual(@as(u32, 1), getDirectoryFileCountEx(dir, "DIRS*", false));
    try std.testing.expectEqual(@as(u32, 4), getDirectoryFileCountEx(dir, null, true));
    try std.testing.expectEqual(@as(u32, 5), getDirectoryFileCountEx(dir, "*.*", true));

    // LoadDirectoryFiles lists them all, with the base path prepended; the
    // extension scan reaches into the subdirectory.
    {
        const top = loadDirectoryFiles(dir);
        defer unloadDirectoryFiles(top);
        try std.testing.expectEqual(@as(u32, 4), top.count);
        try std.testing.expect(internal.holds(top, a_path));
        try std.testing.expect(internal.holds(top, b_path));
        try std.testing.expect(internal.holds(top, hidden_path));
        try std.testing.expect(internal.holds(top, sub_path));
        try std.testing.expect(!internal.holds(top, inner_path));
    }
    {
        const files_only = loadDirectoryFilesEx(dir, null, false);
        defer unloadDirectoryFiles(files_only);
        try std.testing.expectEqual(@as(u32, 3), files_only.count);
        try std.testing.expect(!internal.holds(files_only, sub_path));
    }
    {
        const nested = loadDirectoryFilesEx(dir, ".bin", true);
        defer unloadDirectoryFiles(nested);
        try std.testing.expectEqual(@as(u32, 2), nested.count);
        try std.testing.expect(internal.holds(nested, b_path));
        try std.testing.expect(internal.holds(nested, inner_path));
    }
    {
        // A directory that is not there scans to nothing at all.
        const nowhere = try internal.pathZ(gpa, dir, "nowhere");
        defer gpa.free(nowhere);
        const none = loadDirectoryFiles(nowhere);
        defer unloadDirectoryFiles(none);
        try std.testing.expectEqual(@as(u32, 0), none.count);
        try std.testing.expect(none.paths == null);
    }

    // Dropped files: raylib's own list, empty without a window.
    try std.testing.expect(!isFileDropped());
    {
        const dropped = loadDroppedFiles();
        defer unloadDroppedFiles(dropped);
        try std.testing.expectEqual(@as(u32, 0), dropped.count);
        try std.testing.expect(dropped.paths == null);
    }

    // ChangeDirectory moves the whole process, and getWorkingDirectory follows
    // it; the copy of the old path outlives the static buffer it came from.
    const original = getWorkingDirectory() orelse return error.ExpectedDirectory;
    const original_copy = try gpa.dupeSentinel(u8, original, 0);
    defer gpa.free(original_copy);
    defer _ = changeDirectory(original_copy);
    try std.testing.expectEqual(@as(i32, 0), changeDirectory(dir));
    try std.testing.expect(std.mem.endsWith(u8, getWorkingDirectory().?, &tmp.sub_path));
    try std.testing.expectEqual(@as(i32, -1), changeDirectory("no-such-directory"));
}

test "files: compression and base64 round trips" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const payload = "hello hello hello hello hello hello hello";
    {
        const compressed = compressData(payload) orelse return error.CompressionFailed;
        defer c.MemFree(@ptrCast(compressed.ptr));
        try std.testing.expect(compressed.len > 0);

        const restored = decompressData(compressed) orelse return error.DecompressionFailed;
        defer c.MemFree(@ptrCast(restored.ptr));
        try std.testing.expectEqualStrings(payload, restored);
    }

    // Base64 both ways, against raylib's own text, then a round trip.
    {
        const encoded = encodeDataBase64("hello") orelse return error.EncodeFailed;
        defer c.MemFree(@ptrCast(encoded.ptr));
        try std.testing.expectEqualStrings("aGVsbG8=", encoded);

        const decoded = decodeDataBase64("aGVsbG8=") orelse return error.DecodeFailed;
        defer c.MemFree(@ptrCast(decoded.ptr));
        try std.testing.expectEqualStrings("hello", decoded);
    }
    {
        // Empty data encodes to the empty string: raylib's output size counts
        // the terminator, one more than the slice's length.
        const encoded = encodeDataBase64("") orelse return error.EncodeFailed;
        defer c.MemFree(@ptrCast(encoded.ptr));
        try std.testing.expectEqual(@as(usize, 0), encoded.len);
    }
    {
        const text = "The quick brown fox jumps over the lazy dog.";
        const encoded = encodeDataBase64(text) orelse return error.EncodeFailed;
        defer c.MemFree(@ptrCast(encoded.ptr));
        try std.testing.expectEqual(@as(usize, 4 * ((text.len + 2) / 3)), encoded.len);

        const decoded = decodeDataBase64(encoded) orelse return error.DecodeFailed;
        defer c.MemFree(@ptrCast(decoded.ptr));
        try std.testing.expectEqualStrings(text, decoded);
    }
}

test "files: the hashes are the standard digests" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const hello = "hello";

    try std.testing.expectEqual(@as(u32, 0x3610a686), computeCRC32(hello));

    // The digests of "hello", as raylib's state words: MD5's words are its
    // digest little-endian, SHA-1's and SHA-256's big-endian.
    try std.testing.expectEqualSlices(
        u32,
        &.{ 0x2a40415d, 0x762a4bbc, 0x919d71b9, 0x92c51710 },
        computeMD5(hello),
    );
    try std.testing.expectEqualSlices(
        u32,
        &.{ 0xaaf4c61d, 0xdcc5e8a2, 0xdabede0f, 0x3b482cd9, 0xaea9434d },
        computeSHA1(hello),
    );
    try std.testing.expectEqualSlices(
        u32,
        &.{
            0x2cf24dba, 0x5fb0a30e, 0x26e83b2a, 0xc5b9e29e,
            0x1b161e5c, 0x1fa7425e, 0x73043362, 0x938b9824,
        },
        computeSHA256(hello),
    );

    // A longer, multi-block input, against std's own implementations of the
    // three digests, which also pins the byte order the words carry.
    var long: [1000]u8 = undefined;
    for (&long, 0..) |*byte, index| byte.* = @truncate(index *% 7 +% 3);

    const md5_words = computeMD5(&long).*;
    const md5_digest = std.crypto.hash.Md5.hashResult(&long);
    var md5_bytes: [16]u8 = undefined;
    for (md5_words, 0..) |word, index| {
        md5_bytes[index * 4 + 0] = @truncate(word);
        md5_bytes[index * 4 + 1] = @truncate(word >> 8);
        md5_bytes[index * 4 + 2] = @truncate(word >> 16);
        md5_bytes[index * 4 + 3] = @truncate(word >> 24);
    }
    try std.testing.expectEqualSlices(u8, &md5_digest, &md5_bytes);

    const sha1_words = computeSHA1(&long).*;
    var sha1_digest: [std.crypto.hash.Sha1.digest_length]u8 = undefined;
    std.crypto.hash.Sha1.hash(&long, &sha1_digest, .{});
    var sha1_bytes: [20]u8 = undefined;
    for (sha1_words, 0..) |word, index| {
        sha1_bytes[index * 4 + 0] = @truncate(word >> 24);
        sha1_bytes[index * 4 + 1] = @truncate(word >> 16);
        sha1_bytes[index * 4 + 2] = @truncate(word >> 8);
        sha1_bytes[index * 4 + 3] = @truncate(word);
    }
    try std.testing.expectEqualSlices(u8, &sha1_digest, &sha1_bytes);

    const sha256_words = computeSHA256(&long).*;
    var sha256_digest: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(&long, &sha256_digest, .{});
    var sha256_bytes: [32]u8 = undefined;
    for (sha256_words, 0..) |word, index| {
        sha256_bytes[index * 4 + 0] = @truncate(word >> 24);
        sha256_bytes[index * 4 + 1] = @truncate(word >> 16);
        sha256_bytes[index * 4 + 2] = @truncate(word >> 8);
        sha256_bytes[index * 4 + 3] = @truncate(word);
    }
    try std.testing.expectEqualSlices(u8, &sha256_digest, &sha256_bytes);

    // raylib's digest arrays are static: the next call hands back the same one.
    try std.testing.expectEqual(computeMD5(hello), computeMD5(&long));
}

test "files: the file access callbacks replace raylib's loaders and savers" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const custom = struct {
        /// What the custom loaders answer with.
        var data: []const u8 = "data from the callback";
        var text: [:0]const u8 = "text from the callback";
        /// What the custom saver was handed.
        var saved: [64]u8 = undefined;
        var saved_len: usize = 0;

        fn loadData(fileName: [*c]const u8, dataSize: [*c]c_int) callconv(.c) [*c]u8 {
            _ = fileName;
            const buffer = c.MemAlloc(@intCast(data.len)) orelse return null;
            const bytes: [*]u8 = @ptrCast(buffer);
            @memcpy(bytes[0..data.len], data);
            dataSize.* = @intCast(data.len);
            return bytes;
        }

        fn loadText(fileName: [*c]const u8) callconv(.c) [*c]u8 {
            _ = fileName;
            const buffer = c.MemAlloc(@intCast(text.len + 1)) orelse return null;
            const bytes: [*]u8 = @ptrCast(buffer);
            @memcpy(bytes[0..text.len], text);
            bytes[text.len] = 0;
            return bytes;
        }

        fn saveText(fileName: [*c]const u8, fileText: [*c]const u8) callconv(.c) bool {
            _ = fileName;
            const written: [:0]const u8 = @import("std").mem.span(fileText);
            @memcpy(saved[0..written.len], written);
            saved_len = written.len;
            return true;
        }
    };

    setLoadFileDataCallback(custom.loadData);
    defer setLoadFileDataCallback(null);
    {
        const loaded = loadFileData("ignored.bin") orelse return error.ExpectedData;
        defer unloadFileData(loaded);
        try std.testing.expectEqualStrings(custom.data, loaded);
    }

    setLoadFileTextCallback(custom.loadText);
    defer setLoadFileTextCallback(null);
    {
        const loaded = loadFileText("ignored.txt") orelse return error.ExpectedText;
        defer unloadFileText(loaded);
        try std.testing.expectEqualStrings(custom.text, loaded);
    }

    setSaveFileTextCallback(custom.saveText);
    defer setSaveFileTextCallback(null);
    try std.testing.expect(saveFileText("ignored.txt", "written through the callback"));
    try std.testing.expectEqualStrings("written through the callback", custom.saved[0..custom.saved_len]);
}

test "files: automation event lists load, export and play" {
    const std = @import("std");

    // raylib logs straight to stdout, which the test runner's own protocol
    // owns: keep it quiet, and put raylib's default level back at the end.
    c.SetTraceLogLevel(c.LOG_NONE);
    defer c.SetTraceLogLevel(c.LOG_INFO);

    const gpa = std.testing.allocator;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const dir = try internal.tmpDirPath(gpa, &tmp);
    defer gpa.free(dir);
    const list_path = try internal.pathZ(gpa, dir, "events.txt");
    defer gpa.free(list_path);

    // An empty list, the way raylib's own example asks for one.
    var list = loadAutomationEventList(null);
    defer unloadAutomationEventList(list);
    try std.testing.expect(list.events != null);
    try std.testing.expect(list.capacity > 0);
    try std.testing.expectEqual(@as(u32, 0), list.count);

    // Two events, exported as raylib's text format and read back: 1 is a key
    // up and 2 a key down, both for key 65, raylib's KEY_A.
    list.events.?[0] = .{ .frame = 7, .type = 1, .params = .{ 65, 0, 0, 0 } };
    list.events.?[1] = .{ .frame = 9, .type = 2, .params = .{ 65, 0, 0, 0 } };
    list.count = 2;
    try std.testing.expect(exportAutomationEventList(list, list_path));
    {
        const exported = loadFileText(list_path) orelse return error.ExpectedText;
        defer unloadFileText(exported);
        try std.testing.expect(std.mem.find(u8, exported, "c 2") != null);
        try std.testing.expect(std.mem.find(u8, exported, "e 7 1 65 0 0 0") != null);
        try std.testing.expect(std.mem.find(u8, exported, "INPUT_KEY_UP") != null);
    }

    const reloaded = loadAutomationEventList(list_path);
    defer unloadAutomationEventList(reloaded);
    try std.testing.expectEqual(@as(u32, 2), reloaded.count);
    try std.testing.expectEqual(@as(u32, 7), reloaded.events.?[0].frame);
    try std.testing.expectEqual(@as(u32, 2), reloaded.events.?[1].type);
    try std.testing.expectEqual(@as(i32, 65), reloaded.events.?[1].params[0]);

    // Set as the list to record to, and then played: with recording stopped, a
    // key event reaches raylib's own input state.
    setAutomationEventList(&list);
    defer setAutomationEventList(null);
    startAutomationEventRecording();
    stopAutomationEventRecording();
    playAutomationEvent(.{ .frame = 0, .type = 2, .params = .{ 65, 0, 0, 0 } });
    try std.testing.expect(c.IsKeyDown(65));
    playAutomationEvent(.{ .frame = 0, .type = 1, .params = .{ 65, 0, 0, 0 } });
    try std.testing.expect(!c.IsKeyDown(65));
    // The key down also queued KEY_A as pressed, and a key up does not dequeue it
    // (rcore.c's PlayAutomationEvent). raylib's input state is every test's, so
    // take back what this test put there.
    try std.testing.expectEqual(@as(c_int, 65), c.GetKeyPressed());
    try std.testing.expectEqual(@as(c_int, 0), c.GetKeyPressed());
}
