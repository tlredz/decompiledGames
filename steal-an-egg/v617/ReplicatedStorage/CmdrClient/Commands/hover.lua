local Players = game:GetService("Players")
return {
	Name = "hover",
	Description = "Returns the name of the player you are hovering over.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function()
		local target = Players.LocalPlayer:GetMouse().Target

		if not target then
			return ""
		end

		local playerFromCharacter = Players:GetPlayerFromCharacter(target:FindFirstAncestorOfClass("Model"))
		return playerFromCharacter and playerFromCharacter.Name or ""
	end
}