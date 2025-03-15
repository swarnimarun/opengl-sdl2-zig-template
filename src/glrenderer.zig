const lib = @import("sdl2_opengl_zig_lib");
const gl = @import("zgl");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

fn getProcAddressWrapper(comptime _: type, symbolName: [:0]const u8) ?*const anyopaque {
    return c.SDL_GL_GetProcAddress(symbolName);
}

pub const RenderError = error{ InitFail, RenderFail, PrerenderFail };

pub const GlRenderer = lib.GenericRenderer(
    *RenderContext,
    RenderError,
    initGl,
    preRenderGl,
    renderGl,
);

pub const RenderContext = struct { value: usize };

pub fn initGl(_: *RenderContext) RenderError!void {
    gl.loadExtensions(void, getProcAddressWrapper) catch return RenderError.InitFail;
}
pub fn preRenderGl(_: *RenderContext) RenderError!void {
    gl.viewport(0, 0, 800, 600);
    // try gl.loadExtensions(void, getProcAddressWrapper);
}
pub fn renderGl(_: *RenderContext) RenderError!void {
    // try gl.loadExtensions(void, getProcAddressWrapper);
    gl.clearColor(1.0, 0.1, 0.1, 1.0);
    gl.clear(.{ .color = true });
}
