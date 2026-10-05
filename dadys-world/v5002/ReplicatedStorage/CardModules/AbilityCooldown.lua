game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "Practice",
	Icon = "rbxassetid://18166409734",
	Description = "Decreases Toon Active Ability cooldowns by 5 seconds.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 10
			numberValue.Parent = cardModifiers

			for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
				if not (child and child:FindFirstChild("Abilities") and child:FindFirstChild("Abilities"):FindFirstChild("Ability1")) then
					continue
				end

				local ability1 = child:WaitForChild("Abilities"):WaitForChild("Ability1")
				local cooldown = ability1:WaitForChild("Cooldown")
				ability1:WaitForChild("CurrentCooldown")
				cooldown.Value -= 5

				if cooldown.Value <= 5 then
					cooldown.Value = 5
				end
			end
		end
	end
}