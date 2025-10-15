# Slot Machine Example

A basic slot machine mechanic demonstration for Godot 4.

## Features

- Three spinning reels with multiple symbols
- Spin button to start the slot machine
- Randomized symbol selection for each reel
- Win detection when all three reels match
- Visual feedback with colors and labels
- Reset functionality

## How to Use

1. Open the project in Godot 4.4 or later
2. Run the `slot_machine.tscn` scene
3. Click the "SPIN" button to spin the reels
4. Watch as the reels stop one by one
5. The result will display whether you won or lost

## Implementation

The slot machine uses:
- **SlotMachine.gd**: Main controller script that manages the game logic
- **Reel.gd**: Individual reel script that handles spinning animation and symbol display
- Simple UI with Labels and Buttons for a clean presentation

Each reel spins for a random duration before stopping on a random symbol, creating a realistic slot machine feel.
