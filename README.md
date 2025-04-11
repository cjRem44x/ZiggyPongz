# ZiggyPongz

A simple Pong clone written in Zig using the Raylib library. This project serves as an educational resource for learning game development concepts and the Zig programming language.

## Educational Purpose

This project is created for educational purposes only to demonstrate:
- Basic game development concepts
- Zig programming language fundamentals
- Collision detection
- Simple game AI
- Real-time graphics rendering with Raylib
- Game loop implementation
- Structure and organization of a small game project

## Game Features

- Classic Pong gameplay mechanics
- Player vs CPU gameplay
- Score tracking
- Smooth paddle movement
- Ball physics with screen boundary detection
- Simple AI opponent
- Visual styling with custom colors

## Controls

- Up Arrow: Move player paddle up
- Down Arrow: Move player paddle down
- ESC: Exit game

## Technical Details

- Written in Zig programming language
- Uses Raylib for graphics and input handling
- Implements basic collision detection
- Runs at 60 FPS
- Resolution: 1200x800

## Disclaimer

This is a learning project and is not intended for commercial use. All code is written for educational purposes to understand game development concepts and the Zig programming language.8


## Building and Running

### Prerequisites

- [Zig](https://ziglang.org/download/) (0.11.0 or later)
- [Raylib](https://www.raylib.com/) (4.5.0 or later)

### Build Steps

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ZiggyPongz.git
cd ZiggyPongz
```

2. Build the project:
```bash
zig build
```

3. Run the game:
```bash
zig build run
```

### Development

For development with hot reloading:
```bash
zig build run -- -watch
```

### Build Modes

- Release build: `zig build -Doptimize=ReleaseFast`
- Debug build: `zig build -Doptimize=Debug`