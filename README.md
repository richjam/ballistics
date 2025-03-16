# ballistics
Pool based roguelite

# Steps to set up the GameLogger as an Autoload in your Godot project:

1. Save the game_logger.gd script to your project (res://game_logger.gd)

2. In the Godot editor, go to Project → Project Settings

3. Navigate to the "Globals" > "Autoload" tab

4. Click the "Add" button at the top right

5. Browse to and select the game_logger.gd script

6. Set the Node Name to "GameLogger"

7. Make sure "Enable" is checked

8. Click "Add" to confirm

This will make the GameLogger available globally at "/root/GameLogger" in your entire project.

# Usage example for other scripts:

```gdscript
extends Node2D

@onready var logger = $"/root/GameLogger"

func _ready():
    logger.setup("MyComponent")
    logger.log("Component initialized")
    
func _process(delta):
    logger.log("Detailed processing data", "debug")
    
func handle_error():
    logger.log("Critical error occurred!", "error")
```

## Setting min log level and saving logs to file:

```gdscript
# In your main scene or game controller:
func _ready() -> void:
	# Configure the logger
	var game_logger = $"/root/GameLogger"
	
	# Set minimum log level based on build configuration
	if OS.is_debug_build():
		game_logger.min_log_level = game_logger.LogLevel.DEBUG
	else:
		game_logger.min_log_level = game_logger.LogLevel.WARNING
	
	# Enable file logging for non-debug builds
	if not OS.is_debug_build():
		game_logger.log_to_file = true
		game_logger.log_file_path = "user://game_logs/game_%s.log" % OS.get_unix_time()
```