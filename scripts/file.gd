class_name File

var file : FileAccess

enum FileOpts {READ, WRITE, WRITE_READ, READ_WRITE}

func _init():
	file = null

func open(path : String, fo : FileOpts) -> void:
	var opts
	match fo:
		FileOpts.READ:
			opts = FileAccess.READ
		FileOpts.WRITE:
			opts = FileAccess.WRITE
		FileOpts.WRITE_READ:
			opts = FileAccess.WRITE_READ
		FileOpts.READ_WRITE:
			opts = FileAccess.READ_WRITE
	file = FileAccess.open(path, opts)

func get_as_text() -> String:
	return file.get_as_text()

func store_string(string : String) -> void:
	file.store_string(string)

func close() -> void:
	file = null
