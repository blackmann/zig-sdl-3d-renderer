const std = @import("std");
const shapes = @import("shapes.zig");
const vectors = @import("vectors.zig");

const c = @cImport(@cInclude("SDL2/SDL.h"));

const width = 800;
const height = 600;
const fps = 1000 / 30;

var window: *c.SDL_Window = undefined;
var renderer: *c.SDL_Renderer = undefined;
var texture: *c.SDL_Texture = undefined;

var color_buffer: [height * width]u32 = undefined;

var time_elapsed: u32 = 0;

pub fn initialize() bool {
    if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
        return false;
    }

    window = c.SDL_CreateWindow("Great app", c.SDL_WINDOWPOS_CENTERED, c.SDL_WINDOWPOS_CENTERED, width, height, c.SDL_WINDOW_RESIZABLE) orelse {
        std.debug.print("Error creating window…", .{});
        return false;
    };

    renderer = c.SDL_CreateRenderer(window, -1, 0) orelse {
        std.debug.print("Error creating renderer", .{});
        return false;
    };

    texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ARGB8888, c.SDL_TEXTUREACCESS_STREAMING, width, height) orelse {
        std.debug.print("Error creating texture", .{});
        return false;
    };

    return true;
}

fn draw_pixel(x: usize, y: usize, color: u32) void {
    color_buffer[y * width + x] = color;
}

pub fn clear_buffer(background: u32) void {
    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            draw_pixel(x, y, background);
        }
    }
}

pub fn draw_rect(rect: shapes.Rect, pos: vectors.Vec2, color: u32) void {
    var y: usize = if (pos.y < 0) 0 else @intCast(usize, pos.y);

    const y_limit: usize = y + rect.height;
    while (y < y_limit and y < height) : (y += 1) {
        var x: usize = if (pos.x < 0) 0 else @intCast(usize, pos.x);
        const x_limit: usize = x + rect.width;
        while (x < x_limit and x < width) : (x += 1) {
            draw_pixel(x, y, color);
        }
    }
}

pub fn render() void {
    const current_time = c.SDL_GetTicks();
    if (current_time < time_elapsed + fps) {
      c.SDL_Delay(time_elapsed + fps - current_time);
    }

    time_elapsed = c.SDL_GetTicks();

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_UpdateTexture(texture, null, @ptrCast(*const anyopaque, &color_buffer), comptime @sizeOf(u32) * width);
    _ = c.SDL_RenderCopy(renderer, texture, null, null);

    c.SDL_RenderPresent(renderer);
}

pub fn teardown() void {
    c.SDL_DestroyWindow(window);
    c.SDL_DestroyRenderer(renderer);
    c.SDL_DestroyTexture(texture);
}
