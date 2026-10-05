local RunService = game:GetService("RunService")
game:GetService("ReplicatedStorage")
local isStudio = RunService:IsStudio()
local v = game.GameId == 4777817887
local DebugFlags = {
	LobbyParry = false,
	AutoParry = false,
	GodMode = false,
	ForceTrainingMode = false
}

for k, _ in DebugFlags do
	if v or not isStudio then
		DebugFlags[k] = false
	end

	if DebugFlags[k] then
		warn(string.format("DebugFlag \"%s\" is enabled", k))
	end
end

return DebugFlags