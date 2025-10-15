using Godot;
using Microsoft.Win32; // <-- Import this for registry access
using System;

public partial class RegistryDemo : Node
{
	public override void _Ready()
	{
		// 1. DEFINE OUR TEST KEY AND VALUE
		// We use HKEY_CURRENT_USER (Registry.CurrentUser) so we don't need admin rights.
		string keyPath = @"Software\ZUEDEV\Godot_WindowsRegistry_Example"; // A safe path for testing
		string valueName = "LastRunTime";
		string valueData = DateTime.Now.ToString();

		try
		{
			// 2. WRITE THE VALUE
			GD.Print($"Attempting to write to registry at: HKEY_CURRENT_USER\\{keyPath}");

			// CreateSubKey will create the path if it doesn't exist AND open it for writing.
			using (RegistryKey key = Registry.CurrentUser.CreateSubKey(keyPath))
			{
				key.SetValue(valueName, valueData);
				GD.Print($"SUCCESS: Wrote value '{valueData}'");
			}

			// 3. READ THE VALUE BACK
			GD.Print("Attempting to read value back...");
			using (RegistryKey key = Registry.CurrentUser.OpenSubKey(keyPath))
			{
				if (key != null)
				{
					// GetValue returns an 'object', so we cast it to a string.
					string readData = key.GetValue(valueName) as string;
					GD.Print($"SUCCESS: Read back: '{readData}'");
				}
				else
				{
					GD.PrintErr("Error: Could not find key to read.");
				}
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr($"REGISTRY ERROR: {ex.Message}");
		}
	}
}
