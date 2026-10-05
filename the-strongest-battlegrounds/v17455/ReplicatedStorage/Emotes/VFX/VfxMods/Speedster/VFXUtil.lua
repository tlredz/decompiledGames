local VFXUtil = {}
game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Debris")
local BoatTween = require(game.ReplicatedStorage.BoatTween)
local v = { "ParticleEmitter", "Beam", "Trail" }

local function remove_task(list, p)
	if not (list and p) then
		return
	end

	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

local function delay_task(threads, duration, callback)
	local thread = nil
	thread = task.delay(duration, function()
		local v2 = threads
		local v3 = thread
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		callback()
	end)

	if threads then
		table.insert(threads, thread)
	end

	return thread
end

local function spawn_task(threads, callback)
	local thread = nil
	thread = task.spawn(function()
		local v2 = threads
		local v3 = thread
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		callback()
	end)

	if threads then
		table.insert(threads, thread)
	end

	return thread
end

function VFXUtil:Emit(p: string)
	if self == nil then
		warn("Enter the path to the object.")
		return
	end

	for _, descendant in pairs(self:GetDescendants()) do
		if not table.find(v, descendant.ClassName) then
			continue
		end

		local emitCount = tonumber(descendant:GetAttribute("EmitCount")) or tonumber(descendant.Name) or 0
		local emitDelay = tonumber(descendant:GetAttribute("EmitDelay")) or 0
		local emitDuration = tonumber(descendant:GetAttribute("EmitDuration")) or 0
		local emitter = descendant
		task.delay(emitDelay, function()
			if p and emitter.Name ~= p then
				return
			end

			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitCount)
			end

			if emitDuration > 0 then
				task.defer(function()
					emitter.Enabled = true
					task.wait(emitDuration)
					emitter.Enabled = false
				end)
			end
		end)
	end
end

function VFXUtil.ColorCorrection(data)
	if data == nil then
		warn("Enter the arguments.")
		return
	end

	local fadeOut = data.fadeOut or 0.1
	local easingStyle = data.easingStyle or "Cubic"
	local easingDirection = data.easingDirection or "Out"
	local brightness = data.brightness or 0
	local saturation = data.saturation or 0
	local contrast = data.contrast or 0
	local tint = data.tint or Color3.fromRGB(255, 255, 255)
	local cleanup_tasks = data.cleanup_tasks or data.cleanupTasks
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		if colorCorrectionEffect and colorCorrectionEffect.Parent then
			colorCorrectionEffect:Destroy()
		end
	end

	local thread = nil
	thread = task.delay(15, function()
		local v2 = cleanup_tasks
		local v3 = thread
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		fn()
	end)

	if cleanup_tasks then
		table.insert(cleanup_tasks, thread)
	end

	colorCorrectionEffect.Parent = game.Lighting
	colorCorrectionEffect.Brightness = brightness
	colorCorrectionEffect.Saturation = saturation
	colorCorrectionEffect.Contrast = contrast
	colorCorrectionEffect.TintColor = tint
	colorCorrectionEffect.Enabled = true
	BoatTween:Create(colorCorrectionEffect, {
		Time = fadeOut,
		EasingStyle = easingStyle,
		EasingDirection = easingDirection,
		StepType = "Heartbeat",
		Goal = {
			Brightness = 0,
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	}):Play()

	local function fn2()
		fn() -- equivalent call inferred; original call site unknown
	end

	local thread2 = nil
	thread2 = task.delay(fadeOut, function()
		local v2 = cleanup_tasks
		local v3 = thread2
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		fn2()
	end)

	if cleanup_tasks then
		table.insert(cleanup_tasks, thread2)
	end

	return colorCorrectionEffect
end

function VFXUtil.ScreenPulse(data)
	if data == nil then
		warn("Enter the arguments.")
		return
	end

	local fadeIn = data.fadeIn or 0.1
	local fadeOut = data.fadeOut or 0.1
	local pulseTransparency = data.pulseTransparency or 0.5
	local pulseColor = data.pulseColor or Color3.fromRGB(255, 255, 255)
	local easingStyle = data.easingStyle or "Cubic"
	local easingDirection = data.easingDirection or "Out"
	local delayTime = data.delayTime or 0
	local cleanup_tasks = data.cleanup_tasks or data.cleanupTasks
	local screenGui = Instance.new("ScreenGui")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end

	local thread = nil
	thread = task.delay(12, function()
		local v2 = cleanup_tasks
		local v3 = thread
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		fn()
	end)

	if cleanup_tasks then
		table.insert(cleanup_tasks, thread)
	end

	screenGui.Name = "ScreenFX"
	screenGui.Parent = game.StarterGui
	screenGui.Enabled = true
	screenGui.DisplayOrder = 5
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Pulse"
	imageLabel.Visible = true
	imageLabel.Parent = screenGui
	imageLabel.BackgroundTransparency = 1
	imageLabel.ImageTransparency = 1
	imageLabel.ImageColor3 = pulseColor
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Image = "rbxassetid://132274243010523"

	local function fn2()
		if not screenGui.Parent then
			return
		end

		BoatTween:Create(imageLabel, {
			Time = fadeIn,
			EasingStyle = easingStyle,
			EasingDirection = easingDirection,
			StepType = "Heartbeat",
			Goal = {
				ImageTransparency = pulseTransparency
			}
		}):Play()
		local threads = cleanup_tasks
		local v2 = fadeIn + delayTime

		local function fn3()
			if not screenGui.Parent then
				return
			end

			BoatTween:Create(imageLabel, {
				Time = fadeOut,
				EasingStyle = easingStyle,
				EasingDirection = easingDirection,
				StepType = "Heartbeat",
				Goal = {
					ImageTransparency = 1
				}
			}):Play()
			local threads2 = cleanup_tasks
			local v3 = fadeOut + 0.5

			local function fn4()
				fn() -- equivalent call inferred; original call site unknown
			end

			local thread2 = nil
			thread2 = task.delay(v3, function()
				local v4 = threads2
				local v5 = thread2
				local index = v4 and v5 and table.find(v4, v5)

				if index then
					table.remove(v4, index)
				end

				fn4()
			end)

			if threads2 then
				table.insert(threads2, thread2)
			end
		end

		local thread2 = nil
		thread2 = task.delay(v2, function()
			local v3 = threads
			local v4 = thread2
			local index = v3 and v4 and table.find(v3, v4)

			if index then
				table.remove(v3, index)
			end

			fn3()
		end)

		if threads then
			table.insert(threads, thread2)
		end
	end

	local thread2 = nil
	thread2 = task.spawn(function()
		local v2 = cleanup_tasks
		local v3 = thread2
		local index = v2 and v3 and table.find(v2, v3)

		if index then
			table.remove(v2, index)
		end

		fn2()
	end)

	if cleanup_tasks then
		table.insert(cleanup_tasks, thread2)
	end

	return screenGui
end

return VFXUtil