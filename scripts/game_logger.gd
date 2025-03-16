extends Node
""" Game Logger
Advanced logging system for the pool game with support for log levels, 
timestamped messages, and component identification.
"""

# Logging levels as enum
enum LogLevel {
	DEBUG = 0,
	INFO = 1,
	WARNING = 2,
	ERROR = 3,
	CRITICAL = 4
}

# Logger configuration
@export var min_log_level: LogLevel = LogLevel.INFO  # Minimum level to display
@export var show_timestamp: bool = true  # Include timestamp in logs
@export var log_to_file: bool = false  # Save logs to file
@export var log_file_path: String = "user://game.log"  # Path for log file
@export var max_log_file_size: int = 1024 * 1024  # 1MB default

# Internal variables
var _loggers: Dictionary = {}  # Component-specific loggers
var _log_file: FileAccess = null
var _default_logger: ComponentLogger


func _ready() -> void:
	""" Initialize the logging system.
	"""
	if log_to_file:
		_setup_log_file()
	
	_default_logger = ComponentLogger.new(self, "Game")


func _setup_log_file() -> void:
	""" Set up log file for writing.
	"""
	_log_file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if _log_file:
		var header = "=== Game Log Started: %s ===\n" % Time.get_datetime_string_from_system()
		_log_file.store_string(header)
	else:
		push_error("Failed to open log file: %s" % log_file_path)


func get_logger(component_name: String) -> ComponentLogger:
	""" Get a logger instance for a specific component.
	
	Args:
	    component_name: The name of the component requesting a logger.
	
	Returns:
	    A ComponentLogger instance specific to the requesting component.
	"""
	if not _loggers.has(component_name):
		_loggers[component_name] = ComponentLogger.new(self, component_name)
	
	return _loggers[component_name]


func write_log(level: LogLevel, component: String, message: String, details: Dictionary = {}) -> void:
	""" Write a log message if it meets the minimum level requirement.
	
	Args:
	    level: The log severity level.
	    component: The component that generated the log.
	    message: The log message.
	    details: Optional additional structured data.
	"""
	if level < min_log_level:
		return
	
	var log_message = LogMessage.new(level, component, message, details)
	var formatted_message = _format_log_message(log_message)
	
	# Console output
	match level:
		LogLevel.DEBUG, LogLevel.INFO:
			print(formatted_message)
		LogLevel.WARNING:
			push_warning(formatted_message)
		LogLevel.ERROR, LogLevel.CRITICAL:
			push_error(formatted_message)
	
	# File output if enabled
	if log_to_file and _log_file:
		_log_file.store_string(formatted_message + "\n")


func _format_log_message(log_msg: LogMessage) -> String:
	""" Format a log message for display/storage.
	
	Args:
	    log_msg: The LogMessage object to format.
	
	Returns:
	    A formatted string representation of the log message.
	"""
	var level_str = LogLevel.keys()[log_msg.level]
	var timestamp_str = ""
	
	if show_timestamp:
		timestamp_str = "[%s] " % log_msg.timestamp
		
	var basic_msg = "%s[%s] [%s] %s" % [
		timestamp_str, 
		level_str, 
		log_msg.component, 
		log_msg.message
	]
	
	# Add details if present
	if not log_msg.details.is_empty():
		var details_str = JSON.stringify(log_msg.details)
		basic_msg += " | " + details_str
		
	return basic_msg


# Close file handle when game exits
func _exit_tree() -> void:
	if _log_file:
		_log_file.close()


class LogMessage:
	""" Class representing a structured log message.
	"""
	var level: LogLevel
	var component: String
	var message: String
	var timestamp: String
	var details: Dictionary
	
	func _init(p_level: LogLevel, p_component: String, p_message: String, p_details: Dictionary = {}) -> void:
		level = p_level
		component = p_component
		message = p_message
		timestamp = Time.get_datetime_string_from_system()
		details = p_details


class ComponentLogger:
	""" Class providing component-specific logging interface.
	"""
	var _logger: Node  # Reference to the main logger
	var _component_name: String
	
	func _init(logger_ref: Node, component: String) -> void:
		_logger = logger_ref
		_component_name = component
	
	func debug(message: String, details: Dictionary = {}) -> void:
		_logger.write_log(LogLevel.DEBUG, _component_name, message, details)
	
	func info(message: String, details: Dictionary = {}) -> void:
		_logger.write_log(LogLevel.INFO, _component_name, message, details)
	
	func warning(message: String, details: Dictionary = {}) -> void:
		_logger.write_log(LogLevel.WARNING, _component_name, message, details)
	
	func error(message: String, details: Dictionary = {}) -> void:
		_logger.write_log(LogLevel.ERROR, _component_name, message, details)
	
	func critical(message: String, details: Dictionary = {}) -> void:
		_logger.write_log(LogLevel.CRITICAL, _component_name, message, details)
