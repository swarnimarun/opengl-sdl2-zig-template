const std = @import("std");

context: *const anyopaque,
initFn: *const fn (context: *const anyopaque) anyerror!void,
preRenderFn: *const fn (context: *const anyopaque) anyerror!void,
renderFn: *const fn (context: *const anyopaque) anyerror!void,

const Self = @This();
pub const Error = anyerror;

pub fn init(self: Self) anyerror!void {
    return self.initFn(self.context);
}
pub fn prerender(self: Self) anyerror!void {
    return self.preRenderFn(self.context);
}
pub fn render(self: Self) anyerror!void {
    return self.renderFn(self.context);
}
