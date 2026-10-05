local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
return {
	InitiateState = function()
		local emoteWheel = localPlayer:FindFirstChild("EmoteWheel")

		if emoteWheel ~= nil then
			return emoteWheel
		end

		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "EmoteWheel"
		boolValue.Value = false
		boolValue.Parent = localPlayer
		return boolValue
	end
}