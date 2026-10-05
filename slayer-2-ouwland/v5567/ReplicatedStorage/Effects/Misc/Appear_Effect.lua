local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
return function(cFrame: CFrame, instance, p: number?)
	if instance then
		cFrame = instance.CFrame or cFrame
	end

	if cFrame == nil then
		return
	end

	local spawnEffectOffset = instance and instance:GetAttribute("SpawnEffectOffset")

	if spawnEffectOffset then
		cFrame += Vector3.new(0, spawnEffectOffset, 0)
	end

	if (cFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 150 then
		return
	end

	local spawn_Effect = script.Spawn_Effect
	local v

	if spawn_Effect:IsA("Model") then
		v = p or vfxUtility.GetRigEffectScale(instance) or nil
	end

	local clone, spawn_Effect2

	if v == nil then
		if spawn_Effect:IsA("Model") then
			spawn_Effect = spawn_Effect:FindFirstChild("Spawn_Effect") or spawn_Effect
		end

		clone = spawn_Effect:Clone()
		clone.Parent = workspace.Debree
		clone.CFrame = cFrame
		spawn_Effect2 = clone
	else
		clone = spawn_Effect:Clone()
		clone:ScaleTo(v)
		clone.Parent = workspace.Debree
		clone:PivotTo(cFrame)
		spawn_Effect2 = clone:FindFirstChild("Spawn_Effect") or clone
	end

	vfxUtility.EmitAll(clone, vfxUtility.Owned(instance))
	spawn_Effect2.Attachment.Sound:Play()
	DebrisModule:AddItem(clone, 2.15)
end