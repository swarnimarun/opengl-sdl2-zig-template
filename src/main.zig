const std = @import("std");
const gl = @import("zgl");
const lib = @import("sdl2_opengl_zig_lib");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return c.SDL_GL_GetProcAddress(symbolName);
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_TIMER) != 0) {
        @panic("failed to initialize SDL");
    }
    defer c.SDL_Quit();

    _ = c.SDL_GL_SetAttribute(c.SDL_GL_DOUBLEBUFFER, 1);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_DEPTH_SIZE, 24);
    _ = c.SDL_GL_SetAttribute(c.SDL_GL_STENCIL_SIZE, 8);

    const window_flags = c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_ALLOW_HIGHDPI;
    const window = c.SDL_CreateWindow("SDL in Zig", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, 800, 600, window_flags) orelse @panic("failed to create window");
    defer c.SDL_DestroyWindow(window);

    const gl_context = c.SDL_GL_CreateContext(window) orelse @panic("failed to create opengl context");
    defer c.SDL_GL_DeleteContext(gl_context);
    if (c.SDL_GL_MakeCurrent(window, gl_context) != 0) {
        @panic("failed to set gl context sdl2");
    }
    if (c.SDL_GL_SetSwapInterval(1) != 0) {
        @panic("failed to set vsync gl sdl2");
    }

    try gl.loadExtensions(void, getProcAddressWrapper);

    gl.viewport(0, 0, 800, 600);
    var event = std.mem.zeroes(c.SDL_Event);
    main_loop: while (true) {
        while (c.SDL_PollEvent(&event) != 0) {
            if (event.type == c.SDL_QUIT) {
                break :main_loop;
            }
        }
        gl.clearColor(1.0, 0.1, 0.1, 1.0);
        gl.clear(.{ .color = true });
        c.SDL_GL_SwapWindow(window);
    }
}
