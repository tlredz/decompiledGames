local createVector = vector.create
local EffectUtils = {}
local TweenService = game:GetService("TweenService")
local effects = workspace.Effects
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }

function EffectUtils.Debris(instance, duration: number)
	task.delay(duration, function()
		if typeof(instance) == "Instance" and instance.Destroy then
			instance:Destroy()
		end
	end)
	return instance
end

function EffectUtils.Visibility(folder, flag: boolean, p: number?)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("BasePart") and not descendant:GetAttribute("Invisible") then
			if p then
				EffectUtils.Tween(descendant, p, "Sine", "InOut", {
					Transparency = flag and 0 or 1
				})
			else
				descendant.Transparency = flag and 0 or 1
			end
		elseif descendant:IsA("ParticleEmitter") and not flag then
			descendant.Enabled = false
		end
	end
end

function EffectUtils:EmitParticle(max: number)
	self:Emit(self:GetAttribute("EmitCount") or self.Rate)

	if max < self.Lifetime.Max then
		max = self.Lifetime.Max or max
	end

	return max
end

function EffectUtils.Emit(clone, cframe, p: number?)
	if cframe then
		clone = clone:Clone()

		if clone:IsA("Attachment") then
			clone.Parent = cframe
		else
			if typeof(cframe) == "CFrame" then
				if clone:IsA("Model") then
					clone:PivotTo(cframe)
				else
					clone.CFrame = cframe
				end
			else
				local primaryPart

				if clone:IsA("Model") then
					primaryPart = clone.PrimaryPart or clone
				else
					primaryPart = clone
				end

				local weld = Instance.new("Weld")
				weld.Part0 = cframe
				weld.Part1 = primaryPart
				weld.Parent = primaryPart
			end

			clone.Parent = effects
		end
	end

	local v = 0

	for _, emitter in clone:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")

		if emitDelay and emitDelay ~= 0 then
			local v2 = emitter
			task.delay(emitDelay, function()
				if clone then
					v = EffectUtils.EmitParticle(v2, v)
				end
			end)
		else
			v = EffectUtils.EmitParticle(emitter, v)
		end
	end

	task.delay(p or v, function()
		if clone then
			clone:Destroy()
		end
	end)
	return clone
end

function EffectUtils.Enable(value, clone, p, duration: number?, flag: boolean?)
	if p then
		clone = clone:Clone()

		if typeof(p) == "CFrame" then
			clone.CFrame = p
			clone.Parent = effects
		elseif clone:IsA("BasePart") then
			local weld = Instance.new("Weld")
			weld.Part0 = p
			weld.Part1 = clone
			weld.Parent = clone
			clone.Parent = p
		elseif clone:IsA("Attachment") then
			clone.Parent = p
		end
	end

	local beams = {}
	local v = 0

	for _, beam in clone:GetDescendants() do
		if not (typeof(value) ~= "string" or beam:IsA(value)) then
			continue
		end

		if not (typeof(value) ~= "table" or table.find(value, beam.ClassName)) then
			continue
		end

		beam.Enabled = not flag

		if not duration then
			continue
		end

		if not beam:IsA("Beam") then
			local max = typeof(beam.Lifetime) == "NumberRange" and beam.Lifetime.Max or beam.Lifetime
			v = v < max and max or v
		end

		table.insert(beams, beam)
	end

	if duration then
		task.delay(duration, function()
			for _, v2 in beams do
				v2.Enabled = flag and true or false
			end

			task.wait(v)

			if clone then
				clone:Destroy()
			end
		end)
	end

	return clone
end

function EffectUtils.Mesh(instance, p, p2: number?)
	local clone = instance:Clone()
	clone.Parent = effects

	if typeof(p) == "CFrame" then
		clone.CFrame = p
	elseif typeof(p) == "Vector3" then
		clone.Position = p
	else
		clone.Anchored = false
		local weld = Instance.new("Weld")
		weld.Part0 = p
		weld.Part1 = clone
		weld.Parent = clone
	end

	if p2 then
		EffectUtils.Debris(clone, p2)
	end

	return clone
end

function EffectUtils.Tween(p, p2: number, p3: string, p4: string, p5)
	local tween = TweenService:Create(
		p,
		TweenInfo.new(tonumber(p2), Enum.EasingStyle[p3], Enum.EasingDirection[p4]),
		p5
	)
	tween:Play()
	return tween
end

function EffectUtils.AutoMeshes(instance, part, _: number?)
	local cFrame = part.CFrame
	local start = instance.Start
	local v = instance.End
	local startTransparency = instance:GetAttribute("StartTransparency")
	local distortion = instance:GetAttribute("Distortion")
	local duration = instance:GetAttribute("Duration")
	local welded = instance:GetAttribute("Welded")
	local parts = instance:GetAttribute("Part_TweenParams"):split(",")
	local part2 = parts[1]
	local part3 = parts[2]
	local part4 = EffectUtils.Debris(start:Clone(), duration)

	if distortion then
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.Parent = part4
	end

	if welded then
		local weld = Instance.new("Weld")
		weld.Part0 = part
		weld.Part1 = part4
		weld.C0 = start.CFrame
		weld.Parent = part4
		EffectUtils.Tween(weld, duration, part2, part3, {
			C0 = v.CFrame
		})
	else
		part4.CFrame = cFrame * start.CFrame
	end

	local isA = part4:IsA("Part")

	if isA then
		local parts2 = instance:GetAttribute("Mesh_TweenParams"):split(",")
		local part5 = parts2[1]
		local part6 = parts2[2]
		local parts3 = instance:GetAttribute("Decal_TweenParams"):split(",")
		local part7 = parts3[1]
		local part8 = parts3[2]
		part4.Decal.Transparency = startTransparency
		EffectUtils.Tween(part4.Decal, duration, part7, part8, {
			Transparency = tonumber(instance:GetAttribute("EndTransparency")) or 1
		})
		EffectUtils.Tween(part4.Mesh, duration, part5, part6, {
			Scale = v.Mesh.Scale
		})
	else
		part4.Transparency = startTransparency
	end

	local tween = EffectUtils.Tween
	local cFrame2

	if not welded then
		cFrame2 = cFrame * v.CFrame or nil
	end

	tween(part4, duration, part2, part3, {
		CFrame = cFrame2,
		Size = v.Size,
		Transparency = isA and 1 or instance:GetAttribute("EndTransparency") or 1
	})
	part4.Parent = effects
end

function EffectUtils.AutoEmit(instance, instance2)
	local parent = instance:GetAttribute("Parent")
	local raycast = instance:GetAttribute("Raycast")
	local parent2

	if parent then
		parent2 = instance2.Parent

		for _, childName in parent:split(".") do
			if not parent2 then
				return
			end

			parent2 = parent2:FindFirstChild(childName)
		end
	else
		parent2 = instance2
	end

	if raycast then
		local position = (instance2.CFrame * instance.CFrame).Position
		local raycastResult = workspace:Raycast(position, raycast, raycastParams)

		if not raycastResult then
			return
		end

		local raycastHitOffset = instance:GetAttribute("RaycastHitOffset") or createVector(0, 0, 0)
		parent2 = CFrame.new(raycastResult.Position + raycastHitOffset) * (instance2.CFrame - instance2.Position)
	end

	EffectUtils.Emit(instance, parent2)
end

function EffectUtils.AutoEnabled(instance, p)
	local parent = instance:GetAttribute("Parent")
	local parent2 = p.Parent

	if parent then
		for _, childName in parent:split(".") do
			if not parent2 then
				return
			end

			parent2 = parent2:FindFirstChild(childName)
		end
	end

	if not parent2 then
		return
	end

	local time = tonumber(instance:GetAttribute("Time"))
	EffectUtils.Enable({ "ParticleEmitter", "Trail", "Beam" }, instance, parent2, time)
end

function EffectUtils.AutoEffects(instance, p)
	for _, child in instance:GetChildren() do
		if not EffectUtils[`Auto{child.Name}`] then
			continue
		end

		for _, child2 in child:GetChildren() do
			EffectUtils[`Auto{child.Name}`](child2, p)
		end
	end
end

return EffectUtils