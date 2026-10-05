local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Utility = {
	Tween = function(p, p2, p3)
		local tween = TweenService:Create(p, p2, p3)
		tween:Play()
		task.delay(p2.Time, function()
			tween:Destroy()
		end)
		return tween
	end,
	Debris = function(instance, duration: number)
		task.delay(duration, function()
			instance:Destroy()
		end)
	end,
	FrameToTime = function(p: number, value: number)
		return p / (value or 60)
	end
}

local function hasProperty(p, p2)
	local _ = p[p2]
end

function Utility.PlaySound(soundId, items)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId

	for k, item in pairs(items) do
		local v = k

		if pcall(function()
			local v2 = sound[v]
		end) then
			sound[k] = item
		else
			sound:Destroy()
			return error("Sound property not found!", 3)
		end
	end

	return sound
end

function Utility.EmitAllParticles(folder, list)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if list and table.find(list, emitter.Name) then
			print(emitter.Name .. " Ignored")
		elseif emitter:GetAttribute("EmitDelay") then
			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay"), function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		else
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end

function Utility:PlayFlipbook(p, list, callback)
	local v = p / #list
	local v2 = 0
	local v3 = self:IsA("MeshPart") and "TextureID" or self:IsA("SpecialMesh") and "TextureId" or nil
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		v2 = math.min(v2 + dt, p)
		self[v3] = list[math.round(v2 / v)] or list[1]

		if v2 == p then
			heartbeatConnection:Disconnect()

			if callback then
				callback()
			end
		end
	end)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Built }

function Utility:Emit(_: number, _: string)
	task.spawn(function()
		for _, effect in pairs(self:GetDescendants()) do
			if effect:IsA("ParticleEmitter") then
				local emitCount = effect:GetAttribute("EmitCount") or 0
				local emitDelay = effect:GetAttribute("EmitDelay") or 0
				local emitDuration = effect:GetAttribute("EmitDuration") or 0
				local v = effect
				task.delay(emitDelay, function()
					if v.Parent:IsA("Attachment") and tostring(v.Parent) == "Dust" then
						local parent = v.Parent.Parent.Parent
						local raycastResult = workspace:Raycast(
							parent.Position,
							createVector(0, -100, 0),
							raycastParams
						)

						if raycastResult then
							v.Color = ColorSequence.new(raycastResult.Instance.Color)
						end
					end

					v:Emit(emitCount)
					v.Enabled = emitDuration > 0
				end)

				if emitDuration > 0 then
					local v4 = effect
					task.delay(emitDuration + emitDelay, function()
						v4.Enabled = false
					end)
				end
			elseif effect:IsA("Trail") or effect:IsA("Beam") then
				local v = effect:GetAttribute("EmitDelay") == nil and 0 or effect:GetAttribute("EmitDelay") or 0
				local v2 = effect:GetAttribute("EmitDuration") == nil and 0 or effect:GetAttribute("EmitDuration") or 0
				local v3 = effect
				task.delay(v, function()
					v3.Enabled = v2 > 0
				end)

				if v2 > 0 then
					local v5 = effect
					task.delay(v2 + v, function()
						v5.Enabled = false
					end)
				end
			end
		end
	end)
end

function Utility.ToggleVFX(folder, enabled: boolean)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end
end

function Utility.Highlight(parent, data)
	if parent:FindFirstChildWhichIsA("Highlight") then
		parent:FindFirstChildWhichIsA("Highlight"):Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.FillColor = data.FillColor or Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = data.OutlineColor or Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = data.FillTransparency or 0
	highlight.OutlineTransparency = data.OutlineTransparency or 0
	highlight.DepthMode = data.HighlightDepthMode or Enum.HighlightDepthMode.Occluded
	return highlight
end

function Utility.vfxTween(instance, p)
	local start = instance:FindFirstChild("Start")
	local firstChild = instance:FindFirstChild("End")
	Utility.Tween(start, p, {
		Size = firstChild.Size,
		CFrame = firstChild.CFrame,
		Color = firstChild.Color,
		Transparency = firstChild.Transparency
	})
	firstChild.Transparency = 1

	for _, child in pairs(start:GetChildren()) do
		if child:IsA("SpecialMesh") then
			local mesh = firstChild.Mesh
			Utility.Tween(child, p, {
				Scale = mesh.Scale
			})
		elseif child:IsA("Decal") and firstChild:FindFirstChildWhichIsA("Decal") then
			local decal = firstChild.Decal
			Utility.Tween(child, p, {
				Transparency = decal.Transparency,
				Color3 = decal.Color3
			})
		end
	end

	if firstChild:FindFirstChild("Decal") then
		local decal_2 = firstChild:FindFirstChild("Decal")
		decal_2.Transparency = 1
	end

	task.delay(p.Time, function()
		firstChild.Transparency = 1
		start.Transparency = 1

		if start:FindFirstChild("Decal") then
			local decal = start:FindFirstChild("Decal")
			decal.Transparency = 1
		end

		if start:FindFirstChildWhichIsA("Highlight") then
			start:FindFirstChildWhichIsA("Highlight"):Destroy()
		end
	end)
end

function Utility.Flash(folder, value: number, value2: number, value3: number)
	local v = value2 or 0
	local v2 = value or 0.1
	local v3 = value3 or 0

	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
			continue
		end

		local transparency = descendant.Transparency
		Utility.Tween(descendant, TweenInfo.new(v, Enum.EasingStyle.Linear), {
			Transparency = 1
		})
		local v4 = descendant
		task.delay(v2 - v3, function()
			Utility.Tween(v4, TweenInfo.new(v3, Enum.EasingStyle.Linear), {
				Transparency = transparency
			})
		end)
	end
end

return Utility