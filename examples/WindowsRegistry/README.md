# Godot 4 Windows Registry Example

This example provides simple Godot C# and GDScript examples demonstrating how to interact with the Windows Registry. The project shows how to write a value to a registry key and then read it back.

## About the Project

This project was created to provide a straightforward example for Godot developers on how to perform basic Windows Registry operations using C#. This can be useful for saving application settings, user preferences, or other data that needs to persist between sessions in a standard Windows location.

The example uses the `Microsoft.Win32` namespace, which is part of the .NET framework and is readily available in Godot C# projects.

## How to Use

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/zuedev/godot-examples.git
    ```
2.  **Open the project:**
    - Open the Godot Engine (v4.1.1-stable_mono or later).
    - Click "Import" and browse to this directory inside the cloned repository.
    - Select the `project.godot` file in this directory to open the project.
3.  **Run the project:**
    - To run the C# example, open and run the `csharp.tscn` scene.
    - To run the GDScript example, open and run the `gdscript.tscn` scene.
4.  **Check the output:**
    - The Godot output panel will display the results of the registry operations. It will show the attempt to write a value, the success message, and then the attempt to read the value back.

## The Code

The core logic for the examples is contained in the following files:

- **C#:** [`RegistryDemo.cs`](RegistryDemo.cs)
- **GDScript:** [`RegistryDemo.gd`](RegistryDemo.gd)

Both scripts demonstrate the same functionality of writing to and reading from the Windows Registry.

## Important Notes

- **Platform Specific:** This code will only work on Windows. You should add platform checks if you are developing a cross-platform application.
- **Permissions:** Be mindful of where you are writing in the registry. `HKEY_CURRENT_USER` is generally safe. Writing to `HKEY_LOCAL_MACHINE` requires administrator rights.
