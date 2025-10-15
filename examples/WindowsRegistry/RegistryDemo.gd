extends Node

# This script adapts the C# RegistryDemo logic into pure GDScript.
# It uses OS.execute to call the Windows 'reg.exe' command-line tool.

func _ready():
	# 1. DEFINE OUR TEST KEY AND VALUE
	var key_path = "HKCU\\Software\\ZUEDEV\\Godot_WindowsRegistry_Example"
	var value_name = "LastRunTime"
	
	var value_data = Time.get_datetime_string_from_system()

	# 2. WRITE THE VALUE
	print("Attempting to write to registry at: ", key_path)
	print("Write value name: ", value_name, ", data: ", value_data)
	var write_success = set_registry_value(key_path, value_name, value_data)
	
	if write_success:
		print("SUCCESS: Wrote value '", value_data, "'")
	else:
		printerr("WRITE FAILED. (Are you on Windows?)")
		return

	# 3. READ THE VALUE BACK
	print("Attempting to read value back...")
	var read_data = get_registry_value(key_path, value_name)
	
	if read_data != null:
		print("SUCCESS: Read back: '", read_data, "'")
		
		if read_data == value_data:
			print("VERIFICATION: Data matches.")
		else:
			printerr("VERIFICATION FAILED: Data does not match. Written: '", value_data, "', Read: '", read_data, "'")
	else:
		printerr("READ FAILED: Could not find key or value.")


# --- HELPER FUNCTIONS ---

func set_registry_value(path: String, value_name: String, data: String, value_type: String = "REG_SZ") -> bool:
	if OS.get_name() != "Windows":
		printerr("Not running on Windows. Aborting registry write.")
		return false

	var command := "reg"
	var args := ["add", path, "/v", value_name, "/t", value_type, "/d", data, "/f"]
	
	print("Executing command: ", command, " ", args)
	var output := []
	var exit_code := OS.execute(command, args, output, true)
	print("Command output: ", output)
	print("Exit code: ", exit_code)
	
	return exit_code == 0


func get_registry_value(path: String, value_name: String) -> Variant:
	if OS.get_name() != "Windows":
		printerr("Not running on Windows. Aborting registry read.")
		return null

	var command := "reg"
	var args := ["query", path, "/v", value_name]
	var output := []
	
	print("Executing command: ", command, " ", args)
	OS.execute(command, args, output, true)
	print("Command output: ", output)
	
	for line in output:
		var text_line := (line as String).replace("\r", "").replace("\n", "").replace(path.replace("HKCU", "HKEY_CURRENT_USER").replace("\\\\", "\\"), "").strip_edges()
		print("Parsing line: '", text_line, "'")
		
		if text_line.begins_with(value_name):
			var parts = text_line.split("    ") 
			var data_parts_clean = []
			
			for p in parts:
				if not p.is_empty():
					data_parts_clean.append(p.strip_edges())

			print("Split parts: ", data_parts_clean)
			if data_parts_clean.size() >= 3:
				var final_data = " ".join(data_parts_clean.slice(2, data_parts_clean.size()))
				print("Extracted registry value: '", final_data, "'")
				return final_data

	print("Could not find registry value for name: ", value_name)
	return null
