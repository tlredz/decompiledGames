local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CompanionPluginInput = {}
CompanionPluginInput.__index = CompanionPluginInput

function CompanionPluginInput.new()
	return (setmetatable({}, CompanionPluginInput))
end

function CompanionPluginInput.GetCurrentText(_)
	local __EnigmaPluginData = ReplicatedStorage:FindFirstChild("__EnigmaPluginData")

	if __EnigmaPluginData then
		return __EnigmaPluginData.Value
	end

	return ""
end

return CompanionPluginInput