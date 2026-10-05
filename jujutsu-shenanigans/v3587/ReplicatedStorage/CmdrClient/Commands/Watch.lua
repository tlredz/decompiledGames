return {
	Name = "watch",
	Description = "Watches a player.",
	Group = {
		"Owner",
		"Developer",
		"HeadMod",
		"Mod",
		"Tester",
		"TesterPublic",
		"Contrib",
		"Youtuber"
	},
	Args = {
		{
			Type = "player",
			Name = "Player"
		}
	},
	ClientRun = function(_, player)
		local character = player.Character

		if not character then
			return "Player has no character."
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return "Player has no humanoid."
		end

		workspace.CurrentCamera.CameraSubject = humanoid
		return "Watching player."
	end
}