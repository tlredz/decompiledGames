game:GetService("ReplicatedStorage")
game:GetService("ServerStorage")
local cardModifiers = workspace.Info.CardModifiers
local _ = workspace.Info.PlayerStats
return {
	Name = "First Aid",
	Icon = "rbxassetid://16790556042",
	Description = "Heals every Toon by 1 Heart if they are injured.",
	ApplyCardEffects = function()
		if not cardModifiers:FindFirstChild(script.Name) then
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = script.Name
			numberValue.Value = 1
			numberValue.Parent = cardModifiers

			for _, child in pairs(workspace.InGamePlayers:GetChildren()) do
				local v = child
				local success, result = pcall(function()
					if v then
						local humanoid = v:WaitForChild("Humanoid")
						humanoid.Health += 1
					end
				end)

				if not success then
					warn(result)
				end
			end
		end
	end
}