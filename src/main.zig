const std = @import("std");
const display = @import("display.zig");
const shapes = @import("shapes.zig");

const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

var run = false;
var offset_x: i32 = 0;

fn process_input() void {
    var event: c.SDL_Event = undefined;
    _ = c.SDL_PollEvent(&event);

    switch (event.type) {
        c.SDL_QUIT => {
            run = false;
        },

        else => {},
    }
}

fn update() void {
    display.clear_buffer(0xff444444);
    offset_x += 5;
    display.draw_rect(.{ .width = 30, .height = 30 }, .{.x = 50 + offset_x, .y = 50}, 0xffffffff);
}

pub fn main() !void {
    run = display.initialize();

    while (run) {
        process_input();
        update();
        display.render();
    }

    display.teardown();
    c.SDL_Quit();
}
