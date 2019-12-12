-- Kizrak

local eventNameMapping = {}
for eventName,eventId in pairs(defines.events) do
	eventNameMapping[eventId] = eventName
end


local function getLowestPlayerDesiredSpeed()
	local lowestPlayerDesiredSpeed = 9001 -- It's Over 9000!

	for i, player in pairs(game.connected_players) do
		local player_desired_speed = player.mod_settings["player_desired_speed"].value
		lowestPlayerDesiredSpeed = math.min(lowestPlayerDesiredSpeed,player_desired_speed)
	end

	return lowestPlayerDesiredSpeed
end


local function getNewGameSpeed(numberConnectedPlayers,min_companions,slow_speed_companion)
	local lowestPlayerDesiredSpeed = getLowestPlayerDesiredSpeed()

	if numberConnectedPlayers < min_companions then
		return math.min(slow_speed_companion,lowestPlayerDesiredSpeed)
	else
		return lowestPlayerDesiredSpeed
	end
end


local function on_runtime_mod_setting_changed(event)
	local setting = event.setting -- string: The setting name that changed.
	local setting_type = event.setting_type -- string: The setting type: "runtime-per-user", or "runtime-global".

	if setting ~= "player_desired_speed" then
		return -- not our setting
	end

	local min_companions = settings.startup['minimum_number_of_companions'].value
	local slow_speed_companion = settings.startup['speed_when_below_minimum_number_of_companions'].value

	local numberConnectedPlayers = #game.connected_players

	local previousSpeed = game.speed
	local newSpeed = getNewGameSpeed(numberConnectedPlayers,min_companions,slow_speed_companion)

	local msg = "Companionship: " .. numberConnectedPlayers .. " / " .. min_companions .. "    Speed: " .. newSpeed
	log(msg)

	if previousSpeed == newSpeed then
		-- nothing changed
	else
		game.print(msg,{r=255,g=255})
	end

	game.speed = newSpeed
end

script.on_event({
	defines.events.on_runtime_mod_setting_changed,
},on_runtime_mod_setting_changed)



local function resetPlayerDesiredSpeed(event)
	local player = game.players[event.player_index]
	local eventName = eventNameMapping[event.name]

	if player==nil then return end

	local previousSpeed = player.mod_settings["player_desired_speed"].value
	local newSpeed = math.min(1,previousSpeed)

	if newSpeed == previousSpeed then
		-- nothing changed
	else
		game.print("Companionship: Reset Game Speed for: "..player.name .. "    [" .. eventName .. "]",{r=255,g=255})
		player.mod_settings["player_desired_speed"] = {value = newSpeed}
	end
end

script.on_event({
	defines.events.on_player_created,
	defines.events.on_player_died,
	defines.events.on_player_joined_game,
	defines.events.on_player_kicked,
	defines.events.on_player_left_game,
	defines.events.on_player_removed,
	defines.events.on_player_respawned,
},resetPlayerDesiredSpeed)

