// Import Raylib module for drawing and input
const rl = @import("raylib");

const std = @import("std");
const print   =  std.debug.print;

// Define some custom colors using Raylib's Color struct (RGBA format)
const green = rl.Color{ .r = 38, .g = 154, .b = 185, .a = 255 };
const dark_green = rl.Color{ .r = 0, .g = 33, .b = 0, .a = 255 };
const light_green = rl.Color{ .r = 129, .g = 184, .b = 204, .a = 255 };
const yellow = rl.Color{ .r = 243, .g = 91, .b = 213, .a = 255 };
const myblue = rl.Color{ .r = 33, .g = 19, .b = 216, .a = 255 };
const mypurple = rl.Color{ .r = 40, .g = 25, .b = 144, .a = 255 };
const myblack = rl.Color{ .r = 16, .g = 16, .b = 36, .a = 255 };

// Global variables to track player and CPU scores
var player_score: u32 = 0;
var cpu_score: u32 = 0;

// WINDOW PROPERTIES //
//
const GAME_TITLE = "Pong ポン ポンゲーム 弹球游戏"; // Title of the game window
var screen_width: i32 = 1200; // Width of the game window
var screen_height: i32 = 800; // Height of the game window

// Struct representing the ball, with position, velocity, and radius
const Ball = struct {
    x: f32,
    y: f32,
    vx: f32,
    vy: f32,
    rad: f32,
};

// Struct representing a paddle, with position, size, and movement speed
const Paddle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    speed: f32,
};

// Function to draw the ball on screen
fn draw_ball(b: *Ball) void {
    rl.drawCircle(@intFromFloat(b.x), @intFromFloat(b.y), b.rad, yellow);
}

// Function to update the ball's position and detect collisions with screen edges
fn update_ball(b: *Ball) void {
    b.x += b.vx;
    b.y += b.vy;

    // Bounce off top and bottom edges
    if (b.y + b.rad >= @as(f32, @floatFromInt(rl.getScreenHeight())) or b.y - b.rad <= 0) {
        b.vy *= -1;
    }

    // Ball goes past right edge: CPU scores
    if (b.x + b.rad >= @as(f32, @floatFromInt(rl.getScreenWidth()))) {
        cpu_score += 1;
        res_ball(b); // reset ball
    }

    // Ball goes past left edge: Player scores
    if (b.x - b.rad <= 0) {
        player_score += 1;
        res_ball(b); // reset ball
    }
}

// Resets the ball to the center and reverses direction randomly
fn res_ball(b: *Ball) void {
    b.x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2;
    b.y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2;

    const rand = [_]i32{ -1, 1 }; // direction multipliers
    b.vx *= @floatFromInt(rand[@intCast(rl.getRandomValue(0, 1))]);
    b.vy *= @floatFromInt(rand[@intCast(rl.getRandomValue(0, 1))]);
}

// Prevent paddles from moving outside the screen vertically
fn limit_mov(p: *Paddle) void {
    if (p.y <= 0) {
        p.y = 0;
    }
    if (p.y + p.height >= @as(f32, @floatFromInt(rl.getScreenHeight()))) {
        p.y = @as(f32, @floatFromInt(rl.getScreenHeight())) - p.height;
    }
}

// Draws a paddle with rounded edges
fn draw_paddle(p: *Paddle) void {
    rl.drawRectangleRounded(rl.Rectangle{
        .x = p.x,
        .y = p.y,
        .width = p.width,
        .height = p.height,
    }, 0.8, 0, myblue);
}

// Updates player paddle position based on UP and DOWN arrow key inputs
fn update_player_paddle(p: *Paddle) void {
    if (rl.isKeyDown(rl.KeyboardKey.up)) {
        p.y -= p.speed;
    }
    if (rl.isKeyDown(rl.KeyboardKey.down)) {
        p.y += p.speed;
    }

    limit_mov(p);
}

// Simple AI: Moves CPU paddle to follow the ball vertically
fn update_cpu_paddle(p: *Paddle, b: *Ball) void {
    if (p.y + p.height / 2 > b.y) {
        p.y -= p.speed;
    }
    if (p.y + p.height / 2 <= b.y) {
        p.y += p.speed;
    }

    limit_mov(p);
}

// Entry point of the program
pub fn main() !void {
    // paddle dimensions
    const p_width = 25;
    const p_height = 120;

    // Initialize ball and paddles
    var ball = Ball{
        .x = i32tof32(@divTrunc(screen_width, 2)),
        .y = i32tof32(@divTrunc(screen_height, 2)),
        .vx = 7,
        .vy = 7,
        .rad = 20,
    };

    var player = Paddle{
        .x = i32tof32(screen_width - p_width - 10),
        .y = i32tof32( @divTrunc(screen_height, 2) - @divTrunc(p_height, 2) ),
        .width = p_width,
        .height = p_height,
        .speed = 12,
    };

    var cpu = Paddle{
        .x = 10,
        .y = i32tof32( @divTrunc(screen_height, 2) - @divTrunc(p_height, 2) ),
        .width = p_width,
        .height = p_height,
        .speed = 6,
    };

    // Initialize the game window
    rl.initWindow(screen_width, screen_height, GAME_TITLE);
    rl.setTargetFPS(60); // Run at 60 frames per second

    compute_window_size(screen_width, screen_height); // Adjust window size if needed
    rl.setWindowSize(screen_width, screen_height); // Set the window size

    // Main game loop
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing(); // Ensures drawing ends properly

        // --- Game logic updates ---
        update_ball(&ball);
        update_player_paddle(&player);
        update_cpu_paddle(&cpu, &ball);

        // --- Collision detection with paddles ---
        const player_rect = rl.Rectangle{
            .x = player.x,
            .y = player.y,
            .width = player.width,
            .height = player.height,
        };
        const cpu_rect = rl.Rectangle{
            .x = cpu.x,
            .y = cpu.y,
            .width = cpu.width,
            .height = cpu.height,
        };

        // If ball hits player's paddle, reverse x-velocity
        if (rl.checkCollisionCircleRec(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.rad, player_rect)) {
            ball.vx *= -1;
        }

        // If ball hits CPU's paddle, reverse x-velocity
        if (rl.checkCollisionCircleRec(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.rad, cpu_rect)) {
            ball.vx *= -1;
        }

        // --- Drawing section ---
        rl.clearBackground(myblack); // Clear screen

        // Center decorations
        const center_x = @divTrunc(screen_width, 2);
        const center_y = @divTrunc(screen_height, 2);
        
        rl.drawRectangle(center_x, 0, screen_width - center_x, screen_height, myblack);
        rl.drawCircle(center_x, center_y, 150, mypurple);
        rl.drawLine(center_x, 0, center_x, screen_height, mypurple);
        
        // Draw game objects
        draw_ball(&ball);
        draw_paddle(&player);
        draw_paddle(&cpu);

        // Draw scores
        rl.drawText(rl.textFormat("%i", .{cpu_score}), @divTrunc(screen_width, 4) - 20, 20, 80, myblue);
        rl.drawText(rl.textFormat("%i", .{player_score}), 3 * @divTrunc(screen_width, 4) - 20, 20, 80, myblue);
    }

    // Clean up and close the window
    rl.closeWindow();
}

// HELPER FUNCTIONS //
//
// Covnersions
fn i32tof32(i: i32) f32 {
    return @as(f32, @floatFromInt(i));
}
//
fn f32toi32(i: f32) i32 {
    return @as(i32, @intFromFloat(i));
}

// Dynamically adjust window size if monitor is larger than 1920x1080
pub fn compute_window_size(w: i32, h: i32) void {
    if (w > 1920 and h > 1080) {
        const r_w = i32tof32(w) / 1920.0;
        const r_h = i32tof32(h) / 1080.0;
        print("{d}\n", .{r_w}); // Log scaling ratio
        screen_width = f32toi32(i32tof32(screen_width) * r_w);
        screen_height = f32toi32(i32tof32(screen_height) * r_h);
    }
}
