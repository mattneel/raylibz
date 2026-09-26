//! raylib's audio module: the audio device, waves, sounds, music streaming,
//! audio streams and the audio processors and callbacks.
//!
//! Every function follows raylibz's rules: raylib's name with the first letter
//! lowercased, raylib's C types spelled as the mirror type of the same name,
//! text as `[:0]const u8`, buffers as slices, a load that raylib pairs with an
//! `Is*Valid` check as `error{LoadFailed}!T`, and raylib's own one-line comment
//! copied above the wrapper, with the Zig-side differences below it.
//!
//! raylib.h's audio section is 66 functions and every one of them is wrapped,
//! so `not_wrapped` is empty. This file imports only names the root also
//! publishes (`c`, `cast`, `types` and the type names they hold), because the
//! root's re-export test requires every top-level declaration here to exist in
//! `raylibz` too. Private helpers go in a `const internal = struct { ... };`,
//! which that test skips.

const c = @import("raylib");
const cast = @import("cast.zig");
const types = @import("types.zig");

/// Wave, audio wave data.
const Wave = types.Wave;
/// Sound.
const Sound = types.Sound;
/// Music, audio stream, anything longer than ~10 seconds should be streamed.
const Music = types.Music;
/// AudioStream, custom audio stream.
const AudioStream = types.AudioStream;

/// The functions of raylib.h's `audio` section that raylibz does not wrap, and
/// why. One line each.
///
/// Empty: all 66 audio functions are wrapped here.
pub const not_wrapped = [_]cast.NotWrapped{};

// Audio device management functions

/// Initialize audio device and context.
///
/// Sounds, music streams and audio streams play through the device, so open it
/// before loading them and close it (`closeAudioDevice`) when done.
pub fn initAudioDevice() void {
    c.InitAudioDevice();
}

/// Close the audio device and context.
///
/// Unload the sounds, music streams and audio streams that were loaded while it
/// was open first: raylib frees the device here, not their buffers.
pub fn closeAudioDevice() void {
    c.CloseAudioDevice();
}

/// Check if audio device has been initialized successfully.
///
/// False after a failed `initAudioDevice`, when raylib could not open a
/// playback device.
pub fn isAudioDeviceReady() bool {
    return c.IsAudioDeviceReady();
}

/// Set master volume (listener).
pub fn setMasterVolume(volume: f32) void {
    c.SetMasterVolume(volume);
}

/// Get master volume (listener).
pub fn getMasterVolume() f32 {
    return c.GetMasterVolume();
}

// Wave/Sound loading/unloading functions

/// Load wave data from file.
///
/// raylibz checks `IsWaveValid` on the result: a file raylib cannot read or
/// decode is `error.LoadFailed`, not a wave with no samples.
pub fn loadWave(fileName: [:0]const u8) error{LoadFailed}!Wave {
    const wave = c.LoadWave(cast.cstr(fileName));
    if (!c.IsWaveValid(wave)) return error.LoadFailed;
    return cast.as(Wave, wave);
}

/// Load wave from memory buffer, `fileType` refers to extension: i.e. '.wav'.
///
/// `fileData` is the whole file, borrowed for this call only: raylib decodes
/// its own copy of the samples. `fileType` is the extension raylib should
/// decode it as, and raylib's own warning applies: it must be lower-case. A
/// buffer raylib cannot decode is `error.LoadFailed`, not a wave with no
/// samples.
pub fn loadWaveFromMemory(fileType: [:0]const u8, fileData: []const u8) error{LoadFailed}!Wave {
    const wave = c.LoadWaveFromMemory(cast.cstr(fileType), fileData.ptr, cast.asLen(fileData));
    if (!c.IsWaveValid(wave)) return error.LoadFailed;
    return cast.as(Wave, wave);
}

/// Check if wave data is valid (data loaded and parameters).
pub fn isWaveValid(wave: Wave) bool {
    return c.IsWaveValid(cast.as(c.Wave, wave));
}

/// Load sound from file.
///
/// Needs an open audio device (`initAudioDevice`), because raylib converts the
/// wave to the device's format. raylibz checks `IsSoundValid` on the result, so
/// a file raylib cannot read or decode, or a load without a device, is
/// `error.LoadFailed`.
pub fn loadSound(fileName: [:0]const u8) error{LoadFailed}!Sound {
    const sound = c.LoadSound(cast.cstr(fileName));
    if (!c.IsSoundValid(sound)) return error.LoadFailed;
    return cast.as(Sound, sound);
}

/// Load sound from wave data.
///
/// Needs an open audio device. The wave is not consumed: raylib converts a copy
/// of its samples to the device's format, so the caller still owns the wave and
/// unloads it with `unloadWave` when the sound is done with it. raylibz checks
/// `IsSoundValid` on the result.
pub fn loadSoundFromWave(wave: Wave) error{LoadFailed}!Sound {
    const sound = c.LoadSoundFromWave(cast.as(c.Wave, wave));
    if (!c.IsSoundValid(sound)) return error.LoadFailed;
    return cast.as(Sound, sound);
}

/// Load sound alias, new sound that shares the same sample data as the source sound, does not own the sound data.
///
/// Needs an open audio device. The alias borrows the source's samples, so the
/// source must outlive it; `unloadSoundAlias` releases only the alias. raylibz
/// checks `IsSoundValid` on the result.
pub fn loadSoundAlias(source: Sound) error{LoadFailed}!Sound {
    const alias = c.LoadSoundAlias(cast.as(c.Sound, source));
    if (!c.IsSoundValid(alias)) return error.LoadFailed;
    return cast.as(Sound, alias);
}

/// Check if sound is valid (context and buffers initialized).
pub fn isSoundValid(sound: Sound) bool {
    return c.IsSoundValid(cast.as(c.Sound, sound));
}

/// Update sound buffer with new data (default data format: 32 bit float, stereo).
///
/// `data` holds the new samples as 32-bit floats, the format of every sound
/// raylib loads (`sound.stream.sampleSize` is 32 and `sound.stream.channels` is
/// 2), and `frameCount` is how many frames of it raylib copies: it reads
/// `frameCount * sound.stream.channels` samples from the start of `data`, so
/// `data` must hold at least that many and `frameCount` must not exceed
/// `sound.frameCount`. raylib stops the sound to replace its buffer, so play it
/// again (`playSound`) to hear the new data.
pub fn updateSound(sound: Sound, data: []const f32, frameCount: i32) void {
    c.UpdateSound(cast.as(c.Sound, sound), data.ptr, frameCount);
}

/// Unload wave data.
///
/// Takes ownership of the wave's samples and releases them; it dies at this
/// call.
pub fn unloadWave(wave: Wave) void {
    c.UnloadWave(cast.as(c.Wave, wave));
}

/// Unload sound.
///
/// Takes ownership of the sound's buffer and releases it; it dies at this call.
pub fn unloadSound(sound: Sound) void {
    c.UnloadSound(cast.as(c.Sound, sound));
}

/// Unload sound alias (does not deallocate sample data).
///
/// Takes ownership of the alias's buffer and releases it, never the samples it
/// shares with its source; the alias dies at this call.
pub fn unloadSoundAlias(alias: Sound) void {
    c.UnloadSoundAlias(cast.as(c.Sound, alias));
}

/// Export wave data to file, returns true on success.
///
/// raylib picks the writer by `fileName`: `.wav`, `.qoa` when raylib was built
/// with it, or `.raw` (the samples with no header). An extension raylib cannot
/// write is a false.
pub fn exportWave(wave: Wave, fileName: [:0]const u8) bool {
    return c.ExportWave(cast.as(c.Wave, wave), cast.cstr(fileName));
}

/// Export wave sample data to code (.h), returns true on success.
///
/// The file takes its names from `fileName` without the extension, upper-cased:
/// `<NAME>_FRAME_COUNT`, `_SAMPLE_RATE`, `_SAMPLE_SIZE`, `_CHANNELS` and the
/// samples as `<NAME>_DATA`.
pub fn exportWaveAsCode(wave: Wave, fileName: [:0]const u8) bool {
    return c.ExportWaveAsCode(cast.as(c.Wave, wave), cast.cstr(fileName));
}

// Wave/Sound management functions

/// Play a sound.
pub fn playSound(sound: Sound) void {
    c.PlaySound(cast.as(c.Sound, sound));
}

/// Stop playing a sound.
pub fn stopSound(sound: Sound) void {
    c.StopSound(cast.as(c.Sound, sound));
}

/// Pause a sound.
pub fn pauseSound(sound: Sound) void {
    c.PauseSound(cast.as(c.Sound, sound));
}

/// Resume a paused sound.
pub fn resumeSound(sound: Sound) void {
    c.ResumeSound(cast.as(c.Sound, sound));
}

/// Check if sound is currently playing.
pub fn isSoundPlaying(sound: Sound) bool {
    return c.IsSoundPlaying(cast.as(c.Sound, sound));
}

/// Set volume for a sound (1.0 is max level).
pub fn setSoundVolume(sound: Sound, volume: f32) void {
    c.SetSoundVolume(cast.as(c.Sound, sound), volume);
}

/// Set pitch for a sound (1.0 is base level).
pub fn setSoundPitch(sound: Sound, pitch: f32) void {
    c.SetSoundPitch(cast.as(c.Sound, sound), pitch);
}

/// Set pan for a sound (-1.0 left, 0.0 center, 1.0 right).
pub fn setSoundPan(sound: Sound, pan: f32) void {
    c.SetSoundPan(cast.as(c.Sound, sound), pan);
}

/// Copy a wave to a new wave.
///
/// The copy owns its own samples: release it with `unloadWave`. A failed
/// allocation is a wave with no samples, which `isWaveValid` reports.
pub fn waveCopy(wave: Wave) Wave {
    return cast.as(Wave, c.WaveCopy(cast.as(c.Wave, wave)));
}

/// Crop a wave to defined frames range.
///
/// The range is `[initFrame, finalFrame)`: `finalFrame` itself is not kept.
/// raylib frees the wave's old samples and the wave owns the cropped copy,
/// which the caller still unloads with `unloadWave`; a range raylib rejects
/// (negative, inverted, or past `wave.frameCount`) leaves the wave as it was
/// and logs a warning.
pub fn waveCrop(wave: *Wave, initFrame: i32, finalFrame: i32) void {
    c.WaveCrop(cast.asPtr(c.Wave, wave), initFrame, finalFrame);
}

/// Convert wave data to desired format.
///
/// raylib frees the wave's old samples and the wave owns the converted copy: a
/// new allocation of `frameCount * channels * sampleSize/8` bytes, with the new
/// `sampleRate`, `sampleSize` and `channels`. A conversion raylib cannot do
/// leaves the wave as it was.
pub fn waveFormat(wave: *Wave, sampleRate: i32, sampleSize: i32, channels: i32) void {
    c.WaveFormat(cast.asPtr(c.Wave, wave), sampleRate, sampleSize, channels);
}

/// Load samples data from wave as a 32bit float data array.
///
/// The slice is `wave.frameCount * wave.channels` samples, the wave's samples
/// normalized to -1..1, allocated by raylib: release it with
/// `unloadWaveSamples`. Null when raylib's allocation failed.
pub fn loadWaveSamples(wave: Wave) ?[]f32 {
    const samples = c.LoadWaveSamples(cast.as(c.Wave, wave));
    return cast.asSlice(f32, samples, @intCast(wave.frameCount * wave.channels));
}

/// Unload samples data loaded with LoadWaveSamples().
///
/// Takes ownership of the samples and releases them; they die at this call.
pub fn unloadWaveSamples(samples: []f32) void {
    c.UnloadWaveSamples(samples.ptr);
}

// Music management functions

/// Load music stream from file.
///
/// Needs an open audio device, because a music stream plays through it.
/// raylibz checks `IsMusicValid` on the result: a file raylib cannot read or
/// decode is `error.LoadFailed`.
pub fn loadMusicStream(fileName: [:0]const u8) error{LoadFailed}!Music {
    const music = c.LoadMusicStream(cast.cstr(fileName));
    if (!c.IsMusicValid(music)) return error.LoadFailed;
    return cast.as(Music, music);
}

/// Load music stream from data.
///
/// `fileType` is the extension raylib should decode `data` as; raylib's own
/// warning applies: it must be lower-case. `data` is the whole file, and raylib
/// keeps reading it for as long as the music plays, so the caller must keep it
/// alive until `unloadMusicStream` (unlike `loadWaveFromMemory`, which decodes
/// its copy up front). Needs an open audio device. raylibz checks `IsMusicValid`
/// on the result.
pub fn loadMusicStreamFromMemory(fileType: [:0]const u8, data: []const u8) error{LoadFailed}!Music {
    const music = c.LoadMusicStreamFromMemory(cast.cstr(fileType), data.ptr, cast.asLen(data));
    if (!c.IsMusicValid(music)) return error.LoadFailed;
    return cast.as(Music, music);
}

/// Check if music stream is valid (context and buffers initialized).
pub fn isMusicValid(music: Music) bool {
    return c.IsMusicValid(cast.as(c.Music, music));
}

/// Unload music stream.
///
/// Takes ownership of the music stream's device buffers and its decoder context
/// and releases both; the music dies at this call. raylib stops it first if it
/// is playing.
pub fn unloadMusicStream(music: Music) void {
    c.UnloadMusicStream(cast.as(c.Music, music));
}

/// Start music playing.
pub fn playMusicStream(music: Music) void {
    c.PlayMusicStream(cast.as(c.Music, music));
}

/// Check if music is playing.
pub fn isMusicStreamPlaying(music: Music) bool {
    return c.IsMusicStreamPlaying(cast.as(c.Music, music));
}

/// Update buffers for music streaming.
///
/// Call it every frame while the music plays: this is what decodes the next
/// frames and hands them to the device.
pub fn updateMusicStream(music: Music) void {
    c.UpdateMusicStream(cast.as(c.Music, music));
}

/// Stop music playing.
pub fn stopMusicStream(music: Music) void {
    c.StopMusicStream(cast.as(c.Music, music));
}

/// Pause music playing.
pub fn pauseMusicStream(music: Music) void {
    c.PauseMusicStream(cast.as(c.Music, music));
}

/// Resume playing paused music.
pub fn resumeMusicStream(music: Music) void {
    c.ResumeMusicStream(cast.as(c.Music, music));
}

/// Seek music to a position (in seconds).
pub fn seekMusicStream(music: Music, position: f32) void {
    c.SeekMusicStream(cast.as(c.Music, music), position);
}

/// Set volume for music (1.0 is max level).
pub fn setMusicVolume(music: Music, volume: f32) void {
    c.SetMusicVolume(cast.as(c.Music, music), volume);
}

/// Set pitch for music (1.0 is base level).
pub fn setMusicPitch(music: Music, pitch: f32) void {
    c.SetMusicPitch(cast.as(c.Music, music), pitch);
}

/// Set pan for music (-1.0 left, 0.0 center, 1.0 right).
pub fn setMusicPan(music: Music, pan: f32) void {
    c.SetMusicPan(cast.as(c.Music, music), pan);
}

/// Get music time length (in seconds).
pub fn getMusicTimeLength(music: Music) f32 {
    return c.GetMusicTimeLength(cast.as(c.Music, music));
}

/// Get current music time played (in seconds).
pub fn getMusicTimePlayed(music: Music) f32 {
    return c.GetMusicTimePlayed(cast.as(c.Music, music));
}

// AudioStream management functions

/// Load audio stream (to stream raw audio pcm data).
///
/// `sampleRate`, `sampleSize` (bits per sample) and `channels` are the stream's
/// own: raylib converts them to the device's 32-bit float stereo as the data
/// plays. `sampleSize` must be 8, 16 or 32; raylib reads any other value as 32.
/// Needs an open audio device. raylibz checks `IsAudioStreamValid` on the
/// result.
pub fn loadAudioStream(sampleRate: u32, sampleSize: u32, channels: u32) error{LoadFailed}!AudioStream {
    const stream = c.LoadAudioStream(sampleRate, sampleSize, channels);
    if (!c.IsAudioStreamValid(stream)) return error.LoadFailed;
    return cast.as(AudioStream, stream);
}

/// Check if an audio stream is valid (buffers initialized).
pub fn isAudioStreamValid(stream: AudioStream) bool {
    return c.IsAudioStreamValid(cast.as(c.AudioStream, stream));
}

/// Unload audio stream and free memory.
///
/// Takes ownership of the audio stream's buffers and releases them; the stream
/// dies at this call.
pub fn unloadAudioStream(stream: AudioStream) void {
    c.UnloadAudioStream(cast.as(c.AudioStream, stream));
}

/// Update audio stream buffers with data.
///
/// `data` is the stream's own format: `frameCount` frames of
/// `stream.channels` channels, `stream.sampleSize/8` bytes per sample, so
/// raylib copies `frameCount * stream.channels * stream.sampleSize/8` bytes
/// from the start of `data`, and `data` must hold at least that many. Only one
/// of the stream's two sub-buffers is written, and raylib warns unless
/// `isAudioStreamProcessed` says one is free; any space it does not fill is
/// zeroed.
pub fn updateAudioStream(stream: AudioStream, data: []const u8, frameCount: i32) void {
    c.UpdateAudioStream(cast.as(c.AudioStream, stream), data.ptr, frameCount);
}

/// Check if any audio stream buffers requires refill.
pub fn isAudioStreamProcessed(stream: AudioStream) bool {
    return c.IsAudioStreamProcessed(cast.as(c.AudioStream, stream));
}

/// Play audio stream.
pub fn playAudioStream(stream: AudioStream) void {
    c.PlayAudioStream(cast.as(c.AudioStream, stream));
}

/// Pause audio stream.
pub fn pauseAudioStream(stream: AudioStream) void {
    c.PauseAudioStream(cast.as(c.AudioStream, stream));
}

/// Resume audio stream.
pub fn resumeAudioStream(stream: AudioStream) void {
    c.ResumeAudioStream(cast.as(c.AudioStream, stream));
}

/// Check if audio stream is playing.
pub fn isAudioStreamPlaying(stream: AudioStream) bool {
    return c.IsAudioStreamPlaying(cast.as(c.AudioStream, stream));
}

/// Stop audio stream.
pub fn stopAudioStream(stream: AudioStream) void {
    c.StopAudioStream(cast.as(c.AudioStream, stream));
}

/// Set volume for audio stream (1.0 is max level).
pub fn setAudioStreamVolume(stream: AudioStream, volume: f32) void {
    c.SetAudioStreamVolume(cast.as(c.AudioStream, stream), volume);
}

/// Set pitch for audio stream (1.0 is base level).
pub fn setAudioStreamPitch(stream: AudioStream, pitch: f32) void {
    c.SetAudioStreamPitch(cast.as(c.AudioStream, stream), pitch);
}

/// Set pan for audio stream (-1.0 left, 0.0 center, 1.0 right).
pub fn setAudioStreamPan(stream: AudioStream, pan: f32) void {
    c.SetAudioStreamPan(cast.as(c.AudioStream, stream), pan);
}

/// Default size for new audio streams.
///
/// The size is in frames; 0 restores the default raylib computes from the
/// device, and either way it applies to the streams created after this call.
pub fn setAudioStreamBufferSizeDefault(size: i32) void {
    c.SetAudioStreamBufferSizeDefault(size);
}

/// Audio thread callback to request new data.
///
/// The callback runs on the audio thread and fills `bufferData` with `frames`
/// frames of the device's format: interleaved 32-bit float stereo. It is
/// raylib's own `AudioCallback` type; null removes the callback.
pub fn setAudioStreamCallback(stream: AudioStream, callback: c.AudioCallback) void {
    c.SetAudioStreamCallback(cast.as(c.AudioStream, stream), callback);
}

/// Attach audio stream processor to stream, receives frames x 2 samples as 'float' (stereo).
///
/// The processor runs on the audio thread over each block of the stream's
/// output, in place, as interleaved 32-bit float stereo.
pub fn attachAudioStreamProcessor(stream: AudioStream, processor: c.AudioCallback) void {
    c.AttachAudioStreamProcessor(cast.as(c.AudioStream, stream), processor);
}

/// Detach audio stream processor from stream.
///
/// raylib detaches the processor with this exact function pointer, so pass the
/// one that was attached.
pub fn detachAudioStreamProcessor(stream: AudioStream, processor: c.AudioCallback) void {
    c.DetachAudioStreamProcessor(cast.as(c.AudioStream, stream), processor);
}

/// Attach audio stream processor to the entire audio pipeline, receives frames x 2 samples as 'float' (stereo).
///
/// The processor runs on the audio thread over each block of the mixed output,
/// in place, as interleaved 32-bit float stereo.
pub fn attachAudioMixedProcessor(processor: c.AudioCallback) void {
    c.AttachAudioMixedProcessor(processor);
}

/// Detach audio stream processor from the entire audio pipeline.
///
/// raylib detaches the processor with this exact function pointer, so pass the
/// one that was attached.
pub fn detachAudioMixedProcessor(processor: c.AudioCallback) void {
    c.DetachAudioMixedProcessor(processor);
}

/// Private helpers: the tests' WAV builder and path builders, and `std`.
///
/// The root's re-export test skips `internal` by name, so nothing here has to
/// exist in `raylibz`.
const internal = struct {
    const std = @import("std");
    const testing = std.testing;

    /// Fills `out` with a 16-bit PCM WAV file holding `samples` interleaved
    /// over `channels`, and returns the part of `out` the file occupies.
    fn wavBytes(out: []u8, sampleRate: u32, channels: u16, samples: []const i16) []u8 {
        const dataSize: u32 = @intCast(samples.len * 2);
        @memcpy(out[0..4], "RIFF");
        std.mem.writeInt(u32, out[4..8], 36 + dataSize, .little);
        @memcpy(out[8..12], "WAVE");
        @memcpy(out[12..16], "fmt ");
        std.mem.writeInt(u32, out[16..20], 16, .little); // fmt chunk size
        std.mem.writeInt(u16, out[20..22], 1, .little); // WAVE_FORMAT_PCM
        std.mem.writeInt(u16, out[22..24], channels, .little);
        std.mem.writeInt(u32, out[24..28], sampleRate, .little);
        std.mem.writeInt(u32, out[28..32], sampleRate * channels * 2, .little); // byte rate
        std.mem.writeInt(u16, out[32..34], channels * 2, .little); // block align
        std.mem.writeInt(u16, out[34..36], 16, .little); // bits per sample
        @memcpy(out[36..40], "data");
        std.mem.writeInt(u32, out[40..44], dataSize, .little);
        for (samples, 0..) |sample, i| {
            std.mem.writeInt(i16, out[44 + i * 2 ..][0..2], sample, .little);
        }
        return out[0 .. 44 + dataSize];
    }

    /// The path of `name` inside the test's temporary directory, as raylib's
    /// `fopen` wants it: NUL-terminated, relative to the cwd the test runs in,
    /// which is where `testing.tmpDir` made the directory.
    fn tmpPath(out: []u8, tmp: *testing.TmpDir, name: []const u8) [:0]u8 {
        return std.fmt.bufPrintSentinel(out, ".zig-cache/tmp/{s}/{s}", .{ tmp.sub_path, name }, 0) catch
            @panic("test path does not fit");
    }
};

test "loadWaveFromMemory decodes a 16-bit PCM WAV built in memory" {
    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 0, 16384, -16384, 32767 };
    const wav = internal.wavBytes(&bytes, 8000, 1, &samples);

    const wave = try loadWaveFromMemory(".wav", wav);
    defer unloadWave(wave);

    try internal.testing.expectEqual(@as(u32, 4), wave.frameCount);
    try internal.testing.expectEqual(@as(u32, 8000), wave.sampleRate);
    try internal.testing.expectEqual(@as(u32, 16), wave.sampleSize);
    try internal.testing.expectEqual(@as(u32, 1), wave.channels);
    try internal.testing.expect(isWaveValid(wave));

    // The wave holds raylib's own copy of the samples, not a window into the
    // caller's buffer: overwriting the file bytes leaves it intact.
    @memset(wav, 0);
    const floats = loadWaveSamples(wave) orelse return error.OutOfMemory;
    defer unloadWaveSamples(floats);
    try internal.testing.expectEqualSlices(f32, &.{ 0, 0.5, -0.5, 32767.0 / 32768.0 }, floats);
}

test "loadWaveFromMemory is error.LoadFailed for what raylib cannot decode" {
    var bytes: [128]u8 = undefined;
    const wav = internal.wavBytes(&bytes, 8000, 1, &.{ 0, 1 });

    try internal.testing.expectError(error.LoadFailed, loadWaveFromMemory(".wav", "not a wave at all"));
    // Same bytes, an extension raylib has no decoder for.
    try internal.testing.expectError(error.LoadFailed, loadWaveFromMemory(".ogg", wav));
}

test "loadWave reads a wave file from disk" {
    var tmp = internal.testing.tmpDir(.{});
    defer tmp.cleanup();

    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 100, -100, 200, -200, 300, -300 };
    const wav = internal.wavBytes(&bytes, 11025, 1, &samples);
    try tmp.dir.writeFile(internal.testing.io, .{ .sub_path = "wave.wav", .data = wav });

    var path_buf: [160]u8 = undefined;
    const wave = try loadWave(internal.tmpPath(&path_buf, &tmp, "wave.wav"));
    defer unloadWave(wave);

    try internal.testing.expectEqual(@as(u32, 6), wave.frameCount);
    try internal.testing.expectEqual(@as(u32, 11025), wave.sampleRate);
    try internal.testing.expectEqual(@as(u32, 16), wave.sampleSize);
    try internal.testing.expect(isWaveValid(wave));

    try internal.testing.expectError(error.LoadFailed, loadWave(".zig-cache/tmp/raylibz-no-such-wave.wav"));
}

test "waveCopy copies a wave and waveCrop crops the frames it keeps" {
    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 0, 1000, 2000, 3000, 4000, 5000, 6000, 7000 };
    const wave = try loadWaveFromMemory(".wav", internal.wavBytes(&bytes, 8000, 1, &samples));
    defer unloadWave(wave);

    var copy = waveCopy(wave);
    defer unloadWave(copy);

    try internal.testing.expectEqual(wave.frameCount, copy.frameCount);
    try internal.testing.expectEqual(wave.sampleRate, copy.sampleRate);
    try internal.testing.expect(isWaveValid(copy));

    const original = loadWaveSamples(wave) orelse return error.OutOfMemory;
    defer unloadWaveSamples(original);
    const copied = loadWaveSamples(copy) orelse return error.OutOfMemory;
    defer unloadWaveSamples(copied);
    try internal.testing.expectEqualSlices(f32, original, copied);

    // waveCrop keeps [2, 5): frames 2, 3 and 4, and nothing else.
    waveCrop(&copy, 2, 5);
    try internal.testing.expectEqual(@as(u32, 3), copy.frameCount);

    const cropped = loadWaveSamples(copy) orelse return error.OutOfMemory;
    defer unloadWaveSamples(cropped);
    try internal.testing.expectEqualSlices(f32, original[2..5], cropped);

    // A range raylib rejects leaves the wave alone.
    waveCrop(&copy, 5, 2);
    try internal.testing.expectEqual(@as(u32, 3), copy.frameCount);
}

test "waveFormat converts the wave's rate, sample size and channels in place" {
    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 8192, -8192, 4096, -4096 };
    var wave = try loadWaveFromMemory(".wav", internal.wavBytes(&bytes, 8000, 1, &samples));
    defer unloadWave(wave);

    // Mono 16-bit to stereo 32-bit at the same rate: the frames stay, the
    // samples double, one per channel.
    waveFormat(&wave, 8000, 32, 2);

    try internal.testing.expectEqual(@as(u32, 4), wave.frameCount);
    try internal.testing.expectEqual(@as(u32, 8000), wave.sampleRate);
    try internal.testing.expectEqual(@as(u32, 32), wave.sampleSize);
    try internal.testing.expectEqual(@as(u32, 2), wave.channels);

    const converted = loadWaveSamples(wave) orelse return error.OutOfMemory;
    defer unloadWaveSamples(converted);
    try internal.testing.expectEqual(@as(usize, 8), converted.len); // frameCount * channels
    // The mono frames, normalized and duplicated across the two channels:
    // 8192/32768 = 0.25, -8192/32768 = -0.25, 4096/32768 = 0.125, ...
    try internal.testing.expectEqualSlices(
        f32,
        &.{ 0.25, 0.25, -0.25, -0.25, 0.125, 0.125, -0.125, -0.125 },
        converted,
    );
}

test "loadWaveSamples returns the wave's samples normalized to floats" {
    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 0, 16384, -16384, 32767 };
    const wave = try loadWaveFromMemory(".wav", internal.wavBytes(&bytes, 8000, 1, &samples));
    defer unloadWave(wave);

    const floats = loadWaveSamples(wave) orelse return error.OutOfMemory;
    defer unloadWaveSamples(floats);

    try internal.testing.expectEqual(@as(usize, wave.frameCount * wave.channels), floats.len);
    try internal.testing.expectEqualSlices(f32, &.{ 0, 0.5, -0.5, 32767.0 / 32768.0 }, floats);
}

test "exportWave writes a wave file raylib loads back" {
    var tmp = internal.testing.tmpDir(.{});
    defer tmp.cleanup();

    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 1, -2, 3, -4, 5, -6 };
    const wave = try loadWaveFromMemory(".wav", internal.wavBytes(&bytes, 16000, 1, &samples));
    defer unloadWave(wave);

    var path_buf: [160]u8 = undefined;
    const path = internal.tmpPath(&path_buf, &tmp, "exported.wav");
    try internal.testing.expect(exportWave(wave, path));

    const reloaded = try loadWave(path);
    defer unloadWave(reloaded);

    try internal.testing.expectEqual(wave.frameCount, reloaded.frameCount);
    try internal.testing.expectEqual(wave.sampleRate, reloaded.sampleRate);
    try internal.testing.expectEqual(wave.sampleSize, reloaded.sampleSize);
    try internal.testing.expectEqual(wave.channels, reloaded.channels);

    const before = loadWaveSamples(wave) orelse return error.OutOfMemory;
    defer unloadWaveSamples(before);
    const after = loadWaveSamples(reloaded) orelse return error.OutOfMemory;
    defer unloadWaveSamples(after);
    try internal.testing.expectEqualSlices(f32, before, after);
}

test "exportWaveAsCode writes the wave's parameters and samples as C" {
    var tmp = internal.testing.tmpDir(.{});
    defer tmp.cleanup();

    var bytes: [128]u8 = undefined;
    const samples = [_]i16{ 0, 1, -1, 2 };
    const wave = try loadWaveFromMemory(".wav", internal.wavBytes(&bytes, 22050, 1, &samples));
    defer unloadWave(wave);

    var path_buf: [160]u8 = undefined;
    try internal.testing.expect(exportWaveAsCode(wave, internal.tmpPath(&path_buf, &tmp, "wave_code.h")));

    const text = try tmp.dir.readFileAlloc(
        internal.testing.io,
        "wave_code.h",
        internal.testing.allocator,
        .limited(64 * 1024),
    );
    defer internal.testing.allocator.free(text);

    // The file names everything after the file, without the extension and
    // upper-cased, and sizes the sample array by frames * channels * size/8.
    try internal.testing.expect(internal.std.mem.indexOf(u8, text, "WAVE_CODE_FRAME_COUNT") != null);
    try internal.testing.expect(internal.std.mem.indexOf(u8, text, "WAVE_CODE_SAMPLE_RATE") != null);
    try internal.testing.expect(internal.std.mem.indexOf(u8, text, "WAVE_CODE_DATA[8]") != null);
}
