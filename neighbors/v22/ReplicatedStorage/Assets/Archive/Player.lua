local v = {}
local bindableEvent = Instance.new("BindableEvent")

-- equivalent calls inferred from this helper; original call sites unknown
local function register_character(player, instance)
	if v[player] == instance then
		return
	end

	v[player] = instance
	bindableEvent:Fire(player, instance)
	instance.Destroying:connect(function()
		if v[player] == instance then
			v[player] = nil
		end
	end)
end

local function register_player(player)
	if player.Character then
		register_character(player, player.Character) -- equivalent call inferred; original call site unknown
	end

	player.CharacterAdded:connect(function(p)
		return register_character(player, p)
	end)
end

game.Players.PlayerAdded:connect(function(p)
	return register_player(p)
end)
game.Players.PlayerRemoving:connect(function(p)
	v[p] = nil
end)
local Player = {}

for _, v2 in game.Players:GetPlayers() do
	task.spawn(register_player, v2)
end

function Player.GetCharacter(_, p)
	return v[p]
end

Player.CharacterAdded = bindableEvent.Event
return Player