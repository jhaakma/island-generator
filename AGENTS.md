# Island Generator


## Summary
Uses Godot 4.4.1

Main TSCN scene: Scenes/main.tscn

Island generator: IslandGeneration/island_generator.gd

## Code Style

- Godot best practices:
    - Use signals, "call down, signal up"
    - Favour composition through Nodes
    - Apply Single Responsibility Principle at all times
    - Consider refactoring code if it will make for cleaner code when achieving a goal

## Testing

When creating new nodes, run the editor (Godot_v4.4.1-stable_linux.x86_64) once before running tests in order to generate the UID files.

To run all tests:

    ./tests/run_all_tests.sh

To run individual tests:

    ./Godot_v4.4.1-stable_linux.x86_64 --headless --path . -s res://tests/<test_name>.gd

