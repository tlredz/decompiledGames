local TweenService = game:GetService("TweenService")

local function disableVisual(instance)
	local v = 0

	if instance:IsA("ParticleEmitter") or instance:IsA("Trail") then
		instance.Enabled = false
		return instance:IsA("ParticleEmitter") and instance.Lifetime.Max or instance.Lifetime
	end

	if instance:IsA("Light") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") or instance:IsA("PointLight") then
		TweenService:Create(instance, TweenInfo.new(0.35), {
			Brightness = 0
		}):Play()
		return 0.35
	end

	if instance:IsA("Beam") then
		TweenService:Create(instance, TweenInfo.new(0.35), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		return 0.35
	end

	if instance:IsA("Decal") or instance:IsA("Texture") then
		TweenService:Create(instance, TweenInfo.new(0.35), {
			Transparency = 1
		}):Play()
		return 0.35
	end

	if instance:IsA("Sound") and instance.Playing then
		TweenService:Create(instance, TweenInfo.new(0.35), {
			Volume = 0
		}):Play()
		task.delay(0.35, function()
			instance:Stop()
		end)
		return 0.35
	end

	return v
end

local function playVisual(instance)
	local v = 0

	if instance:IsA("ParticleEmitter") then
		local emitCount = instance:GetAttribute("EmitCount") or 0
		local emitDelay = instance:GetAttribute("EmitDelay") or 0

		if emitCount > 0 then
			if emitDelay > 0 then
				task.delay(emitDelay, function()
					instance:Emit(emitCount)
				end)
			else
				instance:Emit(emitCount)
			end
		end

		return instance.Lifetime.Max + emitDelay
	elseif instance:IsA("Beam") then
		local duration = instance:GetAttribute("Duration")

		if not duration then
			return 0
		end

		local emitDelay = instance:GetAttribute("EmitDelay") or 0
		task.delay(emitDelay, function()
			instance.Enabled = true
			instance.Width0 = 0
			instance.Width1 = 0
			local fadeInTime = instance:GetAttribute("FadeInTime") or 0.25
			local fadeOutTime = instance:GetAttribute("FadeOutTime") or 0.5
			local tweenInfo = TweenInfo.new(fadeInTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			local tweenInfo2 = TweenInfo.new(fadeOutTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
			TweenService:Create(instance, tweenInfo, {
				Width0 = instance:GetAttribute("Width0") or 0,
				Width1 = instance:GetAttribute("Width1") or 0
			}):Play()
			task.delay(duration - fadeInTime - fadeOutTime, function()
				TweenService:Create(instance, tweenInfo2, {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end)
		end)
		return duration + emitDelay
	else
		if not instance:IsA("Sound") then
			return v
		end

		local emitDelay = instance:GetAttribute("EmitDelay") or 0

		if emitDelay > 0 then
			task.delay(emitDelay, function()
				instance:Play()
			end)
		else
			instance:Play()
		end

		return instance.TimeLength * instance.PlaybackSpeed + emitDelay
	end
end

local Visual = {}

function Visual.TurnOffVisuals(_, folder)
	local v = disableVisual(folder)

	for _, descendant in pairs(folder:GetDescendants()) do
		v = math.max(v, (disableVisual(descendant)))
	end

	return v
end

function Visual:PlayEffects(folder)
	local v = playVisual(folder)

	for _, descendant in pairs(folder:GetDescendants()) do
		v = math.max(v, (playVisual(descendant)))
	end

	return v
end

function Visual:PlayEffectsAt(cframe: CFrame, instance)
	instance:PivotTo(cframe)

	if not instance.Parent then
		instance.Parent = workspace
	end

	local v = self:PlayEffects(instance)
	task.delay(v, function()
		instance:Destroy()
	end)
end

return Visual