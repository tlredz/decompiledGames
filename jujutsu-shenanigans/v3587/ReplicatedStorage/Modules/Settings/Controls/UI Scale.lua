return {
	Btn = 3,
	SortOrder = 3,
	Val = "UIS",
	Desc = "Change the scale of your toolbar / guides",
	Max = 2,
	Callback = function(scale)
		local _ = game.ReplicatedStorage
		local playerGui = game.Players.LocalPlayer.PlayerGui
		playerGui.Main.UIScale.Scale = scale
		playerGui.Controls.Gamepad.UIScale.Scale = scale
		playerGui.Emotes.UIScale.Scale = scale

		if playerGui:FindFirstChild("Miracles") then
			playerGui.Miracles.UIScale.Scale = scale
		end

		if playerGui:FindFirstChild("Adaptation") then
			playerGui.Adaptation.UIScale.Scale = scale
		end
	end
}