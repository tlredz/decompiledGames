local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()
Client.Events.AnimateKidRodCast:Connect(function(instance, instance2, position: Vector3)
	local animations = instance:FindFirstChild("Animations")
	animations:SetAttribute("Rod_Cast", (animations:GetAttribute("Rod_Cast") or 0) + 1)
	local bobber = instance2:FindFirstChild("Bobber")

	if bobber then
		task.wait(0.5)

		if not instance2.Parent then
			return
		end

		local clone = bobber:Clone()
		bobber:Destroy()

		for _, descendant in pairs(clone:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.CanCollide = true
				descendant.CanQuery = false
			elseif descendant:IsA("WeldConstraint") then
				descendant:Destroy()
			end
		end

		clone.Parent = workspace.Particles
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Parent = workspace.Terrain
			local attachment2 = instance2.RopeAttach.Attachment
			instance2.RopeAttach.RopeConstraint.Attachment0 = attachment
			instance2.RopeAttach.RopeConstraint.Attachment1 = clone.PrimaryPart.RopeAttachment

			while instance2.Parent do
				task.wait()
				attachment.WorldCFrame = attachment2.WorldCFrame
			end

			attachment:Destroy()
			clone:Destroy()
		end)
		local pivot = bobber:GetPivot()
		local cframe = CFrame.new(position)
		Client.TweenModule.new(function(p)
			clone:PivotTo((pivot:Lerp(cframe, p)))
		end, 0.3):Play()
	end
end)

function Range(p, p2)
	return p + (p2 - p) * random:NextNumber()
end

Client.Events.AnimateKidCatchFish:Connect(function(instance, instance2, position: Vector3)
	local animations = instance:FindFirstChild("Animations")
	animations:SetAttribute("Rod_Reel", (animations:GetAttribute("Rod_Reel") or 0) + 1)
	local clone = instance2:Clone()

	for k, _ in pairs(clone:GetAttributes()) do
		clone:SetAttribute(k, nil)
	end

	for _, tag in pairs(clone:GetTags()) do
		clone:RemoveTag(tag)
	end

	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	clone:PivotTo(CFrame.new(position))
	clone.Parent = workspace.Particles
	local unit = (instance:GetPivot().Position - position).Unit
	local assemblyMass = clone.PrimaryPart.AssemblyMass
	local v = unit * assemblyMass * 40
	clone.PrimaryPart:ApplyImpulse(v + Vector3.new(0, 40 * assemblyMass, 0))
	local v2 = Vector3.new(Range(-20, 20), Range(-20, 20), (Range(-20, 20))) * assemblyMass
	clone.PrimaryPart:ApplyAngularImpulse(v2)
	task.delay(1, function()
		clone:Destroy()
	end)
end)
return {}