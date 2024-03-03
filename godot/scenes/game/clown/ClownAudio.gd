extends AudioStreamPlayer3D

var subs2res
var streams := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var path = "res://assets/voicelines/"
	for res in dir_contents(path):
		streams[res] = load(path + res)

	var file = FileAccess.get_file_as_string("res://settings/clown_audio.json")
	subs2res = JSON.parse_string(file)


func dir_contents(path):
	var audio_files = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".ogg"):
			audio_files.append(file_name)
		file_name = dir.get_next()
	return audio_files

func play_resource(res):
	if streams.has(res):
		self.stream = streams[res]
		self.play(0.0)

func play_subtitle(text):
	var res_name:String = subtitle_to_res(text)
	play_resource(res_name)

func subtitle_to_res(text : String) -> String:
	var res_list = subs2res["subs"]
	for sub in res_list:
		if text.begins_with(sub["sub"]):
			return sub["res"]
	return ""

func play_random_noise(agit_level):
	var res_list = subs2res["random"][str(agit_level)]
	if res_list:
		var res = res_list[randi() % res_list.size()]
		play_resource(res)

