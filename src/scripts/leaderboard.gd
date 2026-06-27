extends Control

var entry_scene = preload("res://scenes/leaderboard_label.tscn")

@export var leaderboard_internal_name: String

@onready var entries_container: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/Entries
@onready var username: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Username
@onready var password: LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Password

@onready var info_label: Label = $MarginContainer/VBoxContainer/InfoLabel
@onready var submit: Button = $MarginContainer/VBoxContainer/HBoxContainer/Submit
@onready var accept_dialog: AcceptDialog = $AcceptDialog

func format_time(total_seconds: float) -> String:
	var minutes: int = int(total_seconds) / 60
	var seconds: int = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]

func _process(delta: float) -> void:
	if Globals.best_time == -1:
		submit.disabled = true
		username.editable = false
		password.editable = false
		username.text = ""
		submit.text = "[COMPLETE A\nRUN TO JOIN]"
	else:
		submit.disabled = false
		username.editable = true
		password.editable = true
		if username.text == "" and Globals.username:
			username.text = Globals.username
		if password.text == "" and Globals.password:
			password.text = Globals.password
		submit.text = "Submit!\nBest time: " + format_time(Globals.best_time)

func _ready() -> void:
	await _load_entries()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry.position, entry.player_alias.identifier, entry.score)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	for entry in Talo.leaderboards.get_cached_entries(leaderboard_internal_name):
		_create_entry(entry)
	info_label.hide()

func _load_entries() -> void:
	info_label.show()
	var page = 0
	var done = false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)
		var entries: Array[TaloLeaderboardEntry] = res.entries
		var count: int = res.count
		var is_last_page: bool = res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()

func _on_submit_pressed() -> void:
	info_label.show()
	var user = await auth_or_create(username.text, password.text)
	if user == "":
		return
	await Talo.players.identify("username", user)
	var score := Globals.best_time
	if score == -1:
		info_label.hide()
		submit.disabled = true
		username.editable = false
		password.editable = false
		return
	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score)

	_build_entries()

func _on_close_pressed() -> void:
	hide()

func auth_or_create(username_input: String, password_input: String) -> String:
	if not username_input or not password_input:
		return ""

	var register_res = await Talo.player_auth.register(username_input, password_input)
	if register_res == OK:
		print("Account successfully created! Player logged in automatically.")
		Globals.username = username_input
		Globals.password = password_input
		return username_input
	
	var last_error = Talo.player_auth.last_error
	
	if last_error and last_error.get_code() == TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
		var login_res = await Talo.player_auth.login(username_input, password_input)
	
		if login_res == OK:
			print("Login successful! Existing account found.")
			Globals.username = username_input
			Globals.password = password_input
			return username_input

		var login_error = Talo.player_auth.last_error
		if login_error and login_error.get_code() == TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
			accept_dialog.dialog_text = "Incorrect username/password"
			accept_dialog.popup()
			accept_dialog.position = DisplayServer.window_get_size()/2
		else:
			var msg = "Failed to create account:\n" + (login_error.get_message() if login_error else "Unknown error")
			
			accept_dialog.dialog_text = msg
			accept_dialog.popup()
			accept_dialog.position = DisplayServer.window_get_size()/2
	elif last_error and last_error.get_code() == TaloAuthError.ErrorCode.IDENTIFIER_PROFANITY:
		accept_dialog.dialog_text = "Registration rejected:\nUsername contains inappropriate language."
		accept_dialog.popup()
		accept_dialog.position = DisplayServer.window_get_size()/2
	else:
		var err_msg = last_error.get_message() if last_error else "Unknown error"
		accept_dialog.dialog_text = "Registration failed:\n" + err_msg
		accept_dialog.popup()
		accept_dialog.position = DisplayServer.window_get_size()/2
	return ""


func _on_leader_button_pressed() -> void:
	show()
