local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local _ = table.find
local normal = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Combat_Package"):WaitForChild("Normal")
return function(instance, p, p2)
	if instance == nil then
		return
	end

	local v = p2 == true and p == 1 and 0 or p
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart ~= nil and (humanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude <= 100 then
		local v2 = normal.Swing_Sounds:FindFirstChild("Swing" .. v) or normal.Swing_Sounds.Swing5

		if v2 ~= nil then
			local clone = v2:Clone()
			clone.Parent = humanoidRootPart
			clone:Play()
			DebrisModule:AddItem(clone, clone.TimeLength)
		end
	end
end