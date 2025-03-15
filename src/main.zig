const std = @import("std");
const lib = @import("sdl2_opengl_zig_lib");
const ogl = @import("glrenderer.zig");

pub fn main() !void {
    var app = lib.App(ogl.GlRenderer).new(.{
        .title = "Hello World!",
        .width = 800,
        .height = 600,
    });
    var context = ogl.RenderContext{ .value = 10 };
    const renderer = ogl.GlRenderer{ .context = &context };
    try app.init(renderer);
    defer app.destroy() catch @panic("failed to cleanup the application");
    try app.render();
    // var event = std.mem.zeroes(c.SDL_Event);
    // main_loop: while (true) {
    //     while (c.SDL_PollEvent(&event) != 0) {
    //         if (event.type == c.SDL_QUIT) {
    //             break :main_loop;
    //         }
    //     }
    //     c.SDL_GL_SwapWindow(window);
    // }
}
