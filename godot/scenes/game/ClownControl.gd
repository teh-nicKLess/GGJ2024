extends CanvasLayer

signal action_triggered(action:String)

@onready var subtitles: Label = $MarginContainer/Subtitles
@onready var debug: Label = $MarginContainer/Debug
@onready var clown_audio: AudioStreamPlayer3D = $"../ClownAudio"

const BOX_HIT_COOLDOWN := 0.1 # cooldown factor per second
const AGITATION_FACTOR := 0.1 # higher means clows is agitated quicker


var ctrl
var agitation_level := 0 # can be 0,1,2
var solved_blocks_count := 0 # can be 0,1,2
var box_hit_count := 0.0 # counts the hits of blocks to the box while trying to fit them
var expected_solving_time := 0 # in seconds
var level_timer := 0.0
var is_timing_out := false
var expected_solved_count := 0.0
var debug_action := ""
var debug_action_timeout := 0.0
var trigger_queue := []
var trigger_after_text := ""
var text_queue := []
var game_level := 0

func _ready() -> void:
    var file = FileAccess.get_file_as_string("res://settings/clown_ctrl.json")
    ctrl = JSON.parse_string(file)

func _process(delta: float) -> void:

    # update internals
    level_timer += delta
    is_timing_out = level_timer >= expected_solving_time
    expected_solved_count = level_timer / (expected_solving_time / 3)
    if box_hit_count > 0:
        box_hit_count -= (BOX_HIT_COOLDOWN * delta)
    agitation_level = round(box_hit_count * AGITATION_FACTOR)
    if agitation_level > 2:
        agitation_level = 2

    # update debug-panel
    debug.text = "lt=" + str(int(level_timer)) + \
                 "\nagit=" + str(agitation_level) + \
                 "\nsolved=" + str(solved_blocks_count) + \
                 "\nest=" + str(expected_solving_time) + \
                 "\naction=" + debug_action
    if debug_action and level_timer >= debug_action_timeout:
        debug_action = ""

    # handle trigger-queue
    if trigger_queue:
        var new_queue = []
        for event in trigger_queue:
            if event[0] <= level_timer:
                trigger(event[1])
            else:
                new_queue.append(event)
        trigger_queue = new_queue

    # handle text-queue
    if text_queue:
        if text_queue[0][0] == "text":
            play_and_show(text_queue[0][1])
            text_queue.remove_at(0)
        elif text_queue[0][0] == "ts":
            if text_queue[0][1] <= level_timer:
                text_queue.remove_at(0)
        elif text_queue[0][0] == "trigger":
            call_trigger(text_queue[0][1])
            text_queue.remove_at(0)

func reset_level(level: int, expected_solving_time: int):
    self.agitation_level = 0
    self.solved_blocks_count = 0
    self.expected_solving_time = expected_solving_time
    self.level_timer = 0
    self.game_level = level

func trigger_at(time: float, action: String):
    trigger_queue.append([time, action])

func trigger(action: String) -> void:
    # display event in debug for 1 sec
    debug_action = action
    debug_action_timeout = level_timer + 1.0

    # handle special actions
    if action == "box_hit":
        box_hit_count += 1
    elif action == "one_solved":
        solved_blocks_count += 1
    elif action == ""

    # find text
    var matching_rules = []
    for rule in ctrl:
        if rule_matches(rule, action):
            matching_rules.append(rule)

    if matching_rules:
        var rule = matching_rules[randi() % matching_rules.size()]
        enqueue_text(rule["text"], rule["action"])

func rule_matches(rule, action:String) -> bool:

    if rule["trigger"] != action:
        return false

    var condition = rule["cond"]
    if condition.has("ag0") and agitation_level != 0: return false
    if condition.has("ag1") and agitation_level != 1: return false
    if condition.has("ag2") and agitation_level != 2: return false
    if condition.has("l0") and agitation_level != 0: return false
    if condition.has("l1") and game_level != 1: return false
    if condition.has("l2") and game_level != 2: return false
    if condition.has("l3") and game_level != 3: return false
    if condition.has("l4") and game_level != 4: return false
    if condition.has("t0") and is_timing_out: return false
    if condition.has("t1") and (not is_timing_out): return false
    if condition.has("s0") and solved_blocks_count != 0: return false
    if condition.has("s1") and solved_blocks_count != 1: return false
    if condition.has("s2") and solved_blocks_count != 2: return false
    if condition.has("s3") and solved_blocks_count != 3: return false
    if condition.has("s1+") and solved_blocks_count == 0: return false
    if condition.has("s2+") and solved_blocks_count <= 1: return false
    if condition.has("e0") and expected_solved_count != 0: return false
    if condition.has("e1") and expected_solved_count != 1: return false
    if condition.has("e2") and expected_solved_count != 2: return false
    if condition.has("e3") and expected_solved_count != 3: return false

    return true


func enqueue_text(text: String, action: String):
    var parts = text.split("|")
    for part in parts:
        if part.is_valid_float():
            text_queue.append(["ts", part.to_float() + level_timer])
        else:
            text_queue.append(["text", part])
    if action:
        text_queue.append(["trigger", action])

func play_and_show(text: String):
    subtitles.text = text

func call_trigger(action):
    trigger(action)
    emit_signal("action_triggered", action)

