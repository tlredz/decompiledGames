local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
return table.freeze({
	IsCustomModeServer = function()
		return v.isTrainingServer()
	end,
	IsMultiplayerCustomMode = function()
		local isMultiplayer = ReplicatedStorage2.ServerInfo:FindFirstChild("isMultiplayer")

		if isMultiplayer then
			return isMultiplayer.Value
		end

		return false
	end
})