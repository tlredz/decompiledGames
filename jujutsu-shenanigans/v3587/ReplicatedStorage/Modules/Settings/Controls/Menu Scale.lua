return {
	Btn = 3,
	SortOrder = 4,
	Val = "UIS2",
	Desc = "Change the scale of some menus",
	Max = 2,
	Callback = function(p)
		local _ = game.ReplicatedStorage
		local playerGui = game.Players.LocalPlayer.PlayerGui
		local v = math.isnan(p) and 1 or p
		local menus = playerGui:WaitForChild("Menus")
		local roulette = playerGui:WaitForChild("Roulette")
		local ranked = playerGui:WaitForChild("Ranked")
		menus.UIScale.Scale = math.clamp(v, 0.2, 2)
		roulette.UIScale.Scale = math.clamp(v, 0.2, 2)
		ranked.UIScale.Scale = math.clamp(v, 0.2, 2)
	end
}