-- Kizrak


local sb = serpent.block -- luacheck: ignore 211


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
	--local setting_type = event.setting_type -- string: The setting type: "runtime-per-user", or "runtime-global".

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

	if previousSpeed == newSpeed then -- luacheck: ignore 542
		-- nothing changed
	else
		local player = game.players[event.player_index]
		log("Game speed change triggered by " .. player.name)
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

	local player_desired_speed = player.mod_settings["player_desired_speed"].value
	local newSpeed = math.min(1,player_desired_speed)

	local msg = "Companionship: Reset Game Speed for: "..player.name .. "    [" .. eventName .. "]"

	if game.tick<=0 then
		game.speed = player_desired_speed
		log(msg)

	elseif newSpeed == player_desired_speed then -- luacheck: ignore 542
		-- nothing changed

	else
		game.print(msg,{r=255,g=255})
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


local function speedCommand(event)
	local player = game.players[event.player_index]
	local speed = tonumber(event.parameter)

	if speed then
		log("New command line speed set by "..player.name .. " to a value of " .. speed)
		player.mod_settings["player_desired_speed"] = {value = speed}
	end
end

commands.add_command(
	"speed",
	"Sets player's desired Companionship game speed. A value of 1.0 is normal|default speed of 60 UPS.",
	speedCommand
)

