local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
return function(parent, p, parent2)
	if parent ~= nil and p ~= nil and (workspace.CurrentCamera.CFrame.Position - parent.Position).Magnitude <= 200 then
		if p == -1 then
			p = math.random(1, 4)
		end

		local clone = script.PunchEffect.Attachment:Clone()
		local cFrame = clone.CFrame

		if parent2 == nil or parent2.Parent == nil or not Utility.IsMeshRig(parent.Parent) then
			clone.Parent = parent
		else
			clone.Parent = parent2
			clone.CFrame = CFrame.new(0, 0, gameSettings.rigHitEffectOffset) * cFrame
		end

		DebrisModule:AddItem(clone, 0.4)
		vfxUtility.EmitAll(clone, vfxUtility.Owned(parent))
		local child = script.Sounds:FindFirstChild("Punched" .. p)

		if child ~= nil then
			local clone2 = child:Clone()
			clone2.Parent = parent
			clone2:Play()
			DebrisModule:AddItem(clone2, clone2.TimeLength)
		end

		Utility.Damagehighlight(parent, p)
	end
end