extends Node

class_name EzCfg

enum e_root { 
	res, 
	user
}

# path root where our file will be saved
# 0 = project folder 
# 1 = users folder (persistent data) 
@export var path_root: e_root = 0

const filename = "settings" # filename for our config file

# signal to emit on save/ e.g. updating UI values on config_saved
signal saved
signal loaded


func _ready():
	if !is_file_found(): 
		save_file()
	
func delete_file():
	# checks if a file exists, if so delete it 
	if is_file_found():
		DirAccess.remove_absolute(get_file_path())
		print_debug("Config file deleted!")
		
func save_file(file=get_file()) -> ConfigFile: 
	var config = ConfigFile.new()
	
	if file: 
		config = file
	
	config.save(get_file_path())
	emit_signal("saved")
	return config

func load_file(): 
	if is_file_found(): 
		print("file found")
		emit_signal("loaded")

func get_value(section, key, default=0): 
	# returns the request value from our cfg file
	if is_file_found(): 
		var file = get_file()
		
		# if no value is found save a new value with the given params
		# TODO: may not be desired outcome so make an option to not save 
		if !file.has_section_key(section, key): 
			save_value(section, key, default)
			
		return file.get_value(section, key, default)

func save_value(section, key, value): 
	if is_file_found():  
		var file = get_file()
		file.set_value(section, key, value)
		save_file(file)
	else: 
		var file = ConfigFile.new()
		file.set_value(section, key, value)
		save_file(file)
	
func get_file() -> ConfigFile: 
	var config: ConfigFile = ConfigFile.new()

	config.load(get_file_path())
	return config 
	
func get_path_root() -> String: 
	# returns path root where our file will be saved 
	# 0 = project folder
	# 1 = users folder (persistent data) 
	if path_root == 0: 
		return "res"
		
	return "user"
		
func get_file_path() -> String: 
	var file_extention = ".cfg"
	return get_path_root() + "://" + filename + file_extention

func is_file_found() -> bool:
	var file: ConfigFile = ConfigFile.new()
	var err = file.load(get_file_path())
	
	if err == OK: 
		return true 

	return false
