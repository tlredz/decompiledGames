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
	end,
	Emit = function(self, _: number, _: string)
		task.spawn(function()
			for _, effect in pairs(self:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					local emitCount = effect:GetAttribute("EmitCount") or 0
					local emitDelay = effect:GetAttribute("EmitDelay") or 0
					local emitDuration = effect:GetAttribute("EmitDuration") or 0
					local v = effect
					task.delay(emitDelay, function()
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
	end,
	ToggleVFX = function(folder, enabled: boolean)
		for _, effect in folder:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = enabled
			end
		end
	end,
	Highlight = function(parent, data)
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
}

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