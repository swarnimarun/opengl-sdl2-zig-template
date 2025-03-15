const std = @import("std");
const Renderer = @import("./Renderer.zig");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const AppInfo = struct {
    title: [*c]const u8,
    width: i32,
    height: i32,
};

pub fn App(comptime RendererT: type) type {
    return struct {
        title: [*c]const u8,
        width: i32,
        height: i32,
        window: ?*c.SDL_Window,
        gl_context: c.SDL_GLContext,
        renderer: ?RendererT,

        const Self = @This();
        pub fn new(info: AppInfo) Self {
            return Self{
                .title = info.title,
                .width = info.width,
                .height = info.height,
                .window = null,
                .gl_context = null,
                .renderer = null,
            };
        }

        pub fn init(self: *Self, renderer: RendererT) !void {
            if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_TIMER) != 0) {
                @panic("failed to initialize SDL");
            }
            _ = c.SDL_GL_SetAttribute(c.SDL_GL_DOUBLEBUFFER, 1);
            _ = c.SDL_GL_SetAttribute(c.SDL_GL_DEPTH_SIZE, 24);
            _ = c.SDL_GL_SetAttribute(c.SDL_GL_STENCIL_SIZE, 8);

            self.window = c.SDL_CreateWindow(self.title, 20, 20, self.width, self.height, c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_RESIZABLE | c.SDL_WINDOW_ALLOW_HIGHDPI);

            self.gl_context = c.SDL_GL_CreateContext(self.window);
            if (c.SDL_GL_MakeCurrent(self.window, self.gl_context) != 0) {
                @panic("failed to set gl context sdl2");
            }
            if (c.SDL_GL_SetSwapInterval(1) != 0) {
                @panic("failed to set vsync gl sdl2");
            }

            try renderer.init();
            self.renderer = renderer;
            // self.renderer.init();
        }

        pub fn render(self: *Self) !void {
            if (self.renderer) |renderer| {
                try renderer.prerender();
                var event = std.mem.zeroes(c.SDL_Event);
                main_loop: while (true) {
                    while (c.SDL_PollEvent(&event) != 0) {
                        if (event.type == c.SDL_QUIT) {
                            break :main_loop;
                        }
                    }
                    try renderer.render();
                    c.SDL_GL_SwapWindow(self.window);
                }
            } else {
                @panic("called function with bad renderer setup");
            }
        }

        pub fn destroy(self: *Self) !void {
            if (self.gl_context != null) {
                c.SDL_GL_DeleteContext(self.gl_context);
            }
            if (self.window != null) {
                c.SDL_DestroyWindow(self.window);
            }
            c.SDL_Quit();
        }
    };
}

pub fn GenericRenderer(
    comptime Context: type,
    comptime RenderError: type,
    comptime initFn: fn (context: Context) RenderError!void,
    comptime prerenderFn: fn (context: Context) RenderError!void,
    comptime renderFn: fn (context: Context) RenderError!void,
) type {
    return struct {
        context: Context,
        const Self = @This();
        pub const Error = RenderError;
        pub inline fn prerender(self: Self) Error!void {
            return prerenderFn(self.context);
        }
        pub inline fn init(self: Self) Error!void {
            return initFn(self.context);
        }
        pub inline fn render(self: Self) Error!void {
            return renderFn(self.context);
        }
    };
}
