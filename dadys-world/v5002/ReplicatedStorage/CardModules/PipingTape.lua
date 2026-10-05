game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Piping Tape",
	Icon = "rbxassetid://71163421724965",
	Description = "Decreases the chance of an Ichor Leak occurring on future floors.",
	ApplyCardEffects = function()
		if cardModifiers:FindFirstChild(script.Name) then
			print("PipingTape: Card effect already applied, modifier exists:", script.Name)
			return
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Name = script.Name
		numberValue.Value = 0.9
		numberValue.Parent = cardModifiers
		print("PipingTape: Card effect applied! Modifier created:", script.Name)
		print("PipingTape: Current ichor chance before:", workspace.Info.IchorLeakChance.Value, "%")
	end
}