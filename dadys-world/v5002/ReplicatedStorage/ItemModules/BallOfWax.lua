local BallOfWax = {
	Name = "BallOfWax",
	AbilityOnlyItem = true,
	Rarity = "Rare",
	PointCost = 0,
	Icon = "rbxassetid://6794188517",
	Description = "A heavy lump of wax. Using it will slow you to a crawl for 10 seconds.",
	SlowStrength = 3,
	SlowDuration = 10
}

function BallOfWax.UseItem(parent, p)
	local ServerStorage = game:GetService("ServerStorage")
	local scripts = ServerStorage:FindFirstChild("Scripts")
	local debuffScript = scripts and scripts:FindFirstChild("DebuffScript")

	if debuffScript then
		local clone = debuffScript:Clone()
		clone.DebuffType.Value = "Slow"
		clone.DebuffStrength.Value = BallOfWax.SlowStrength
		clone.Duration.Value = BallOfWax.SlowDuration
		clone.Parent = parent
		clone.Disabled = false
	else
		warn("[BallOfWax] ServerStorage.Scripts.DebuffScript missing — no slow applied")
	end

	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(parent.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "The wax sticks to your feet!"
	}
end

return BallOfWax