local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GingerTargetBeamController = require(ReplicatedStorage.Modules.ClientUI.GingerTargetBeamController)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local tower = TowerLUT:GetTower("Ginger")
local module = require(tower)
local GingerMeterController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	return tween
end

function GingerMeterController.create(instance, p, p2)
	local parts = ReplicatedStorage:FindFirstChild("Parts")
	local renderParts = parts and parts:FindFirstChild("RenderParts")
	local ginger = renderParts and renderParts:FindFirstChild("Ginger")
	local gingerMeter = ginger and ginger:FindFirstChild("GingerMeter")

	if not gingerMeter then
		warn("GingerMeterController: GingerMeter template not found")
		return nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		warn("GingerMeterController: Target has no HumanoidRootPart")
		return nil
	end

	local clone = gingerMeter:Clone()
	clone.Adornee = humanoidRootPart
	clone.Parent = humanoidRootPart
	local v = p2 or module.HealRange
	local v2 = {
		billboard = clone,
		meter = clone:FindFirstChild("Meter"),
		progress = clone.Meter and clone.Meter:FindFirstChild("Progress"),
		progressBaked = clone.Meter and clone.Meter:FindFirstChild("ProgressBaked"),
		cook = clone.Meter and clone.Meter:FindFirstChild("Cook"),
		running = false,
		threads = {},
		tweens = {},
		beam = 0
	}
	local beam

	if p ~= nil then
		beam = GingerTargetBeamController.new(p, v) or nil
	end

	v2.beam = beam
	return v2
end

function GingerMeterController:cancel()
	if not self then
		return
	end

	self.running = false

	for _, thread in ipairs(self.threads) do
		pcall(task.cancel, thread)
	end

	self.threads = {}

	for _, tween in ipairs(self.tweens) do
		local v = tween
		pcall(function()
			v:Cancel()
		end)
	end

	self.tweens = {}

	if self.billboard then
		self.billboard.Enabled = false
		self.billboard:Destroy()
		self.billboard = nil
	end

	if self.beam then
		local beam = self.beam
		self.beam = nil
		local tweens = self.tweens
		local frame1 = beam.Part.SurfaceGui.Frame1
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		table.insert(tweens, playTween(frame1, tweenInfo, {
			BackgroundTransparency = 1
		}))
		task.delay(0.2, function()
			if beam then
				pcall(function()
					beam:Destroy()
				end)
			end
		end)
	end
end

function GingerMeterController:start(duration)
	if not (self and self.billboard and self.meter) then
		warn("GingerMeterController: Invalid meter")
		return
	end

	if self.running then
		GingerMeterController.cancel(self)
		return
	end

	if self.beam then
		self.beam:Attach(game.Players.LocalPlayer.Character, self.billboard.Adornee)
		self.beam.Selection.SurfaceGui.Frame1.UIScale.Scale = 0
		local tweens = self.tweens
		local uIScale = self.beam.Selection.SurfaceGui.Frame1.UIScale
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		table.insert(tweens, playTween(uIScale, tweenInfo, {
			Scale = 1
		}))
	end

	self.running = true
	self.threads = {}
	self.tweens = {}
	local billboard = self.billboard
	local meter = self.meter
	local progress = self.progress
	local progressBaked = self.progressBaked
	local cook = self.cook
	local tweens = self.tweens
	local textLabel = billboard.TextLabel
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local v = {
		AnchorPoint = Vector2.new(0, 0.6)
	}
	table.insert(tweens, playTween(textLabel, tweenInfo, v))

	if progress and progress:FindFirstChild("UIGradient") then
		local offsetEnd = progress.UIGradient:GetAttribute("OffsetEnd") or 1
		progress.UIGradient.Offset = Vector2.new(0, offsetEnd)
	end

	if progressBaked and progressBaked:FindFirstChild("UIGradient") then
		local offsetEnd = progressBaked.UIGradient:GetAttribute("OffsetEnd") or 1
		progressBaked.UIGradient.Offset = Vector2.new(0, offsetEnd)
	end

	if cook then
		cook.ImageTransparency = 1
	end

	billboard.Enabled = true
	local thread = task.spawn(function()
		if not self.running then
			return
		end

		if cook then
			local tweens2 = self.tweens
			local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
			table.insert(tweens2, playTween(cook, tweenInfo2, {
				ImageTransparency = 0
			}))
		end

		local v2 = not (progress and progress:FindFirstChild("UIGradient")) and 0 or progress.UIGradient:GetAttribute("OffsetStart") or 0

		if progress and progress:FindFirstChild("UIGradient") then
			local tweens2 = self.tweens
			local uIGradient = progress.UIGradient
			local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Linear)
			local v3 = {
				Offset = Vector2.new(0, v2)
			}
			table.insert(tweens2, playTween(uIGradient, tweenInfo2, v3))
		end

		if progressBaked and progressBaked:FindFirstChild("UIGradient") then
			local tweens2 = self.tweens
			local uIGradient = progressBaked.UIGradient
			local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Linear)
			local v3 = {
				Offset = Vector2.new(0, v2)
			}
			table.insert(tweens2, playTween(uIGradient, tweenInfo2, v3))
		end

		if progress then
			local tweens2 = self.tweens
			local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Cubic)
			local v4 = {
				ImageColor3 = Color3.fromRGB(162, 74, 1)
			}
			table.insert(tweens2, playTween(progress, tweenInfo2, v4))
		end

		if progressBaked then
			local tweens2 = self.tweens
			local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Cubic)
			table.insert(tweens2, playTween(progressBaked, tweenInfo2, {
				ImageTransparency = 0
			}))
		end

		if meter then
			local tweens2 = self.tweens
			local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Cubic)
			local v4 = {
				ImageColor3 = Color3.fromRGB(77, 13, 0)
			}
			table.insert(tweens2, playTween(meter, tweenInfo2, v4))
		end

		local total = 0

		while total < duration and self.running do
			task.wait(0.1)
			total += 0.1
		end

		if self.beam then
			local tweens2 = self.tweens
			local frame1 = self.beam.Part.SurfaceGui.Frame1
			local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			table.insert(tweens2, playTween(frame1, tweenInfo2, {
				BackgroundTransparency = 1
			}))
			local tweens3 = self.tweens
			local uIScale = self.beam.Selection.SurfaceGui.Frame1.UIScale
			local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			table.insert(tweens3, playTween(uIScale, tweenInfo3, {
				Scale = 0
			}))
		end

		local tweens2 = self.tweens
		local textLabel2 = billboard.TextLabel
		local tweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		table.insert(tweens2, playTween(textLabel2, tweenInfo2, {
			TextTransparency = 1
		}))

		if not self.running then
			return
		end

		if cook then
			local tweens3 = self.tweens
			local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Cubic)
			local v4 = {
				ImageTransparency = 1,
				Size = UDim2.fromScale(1.2, 1.2)
			}
			table.insert(tweens3, playTween(cook, tweenInfo3, v4))
		end

		if meter then
			local tweens3 = self.tweens
			local tweenInfo3 = TweenInfo.new(0.15, Enum.EasingStyle.Sine)
			table.insert(tweens3, playTween(meter, tweenInfo3, {
				ImageTransparency = 1
			}))
			local tweens4 = self.tweens
			local tweenInfo4 = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
			local v5 = {
				Size = UDim2.fromScale(1, 0.8)
			}
			table.insert(tweens4, playTween(meter, tweenInfo4, v5))
		end

		if progress then
			local tweens3 = self.tweens
			local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
			local v4 = {
				Position = UDim2.fromScale(0.5, 0.6)
			}
			table.insert(tweens3, playTween(progress, tweenInfo3, v4))
		end

		if progressBaked then
			local tweens3 = self.tweens
			local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Sine)
			local v4 = {
				Position = UDim2.fromScale(0.5, 0.6)
			}
			table.insert(tweens3, playTween(progressBaked, tweenInfo3, v4))
		end

		if meter then
			local tweenInfo3 = TweenInfo.new(0.05, Enum.EasingStyle.Sine)

			for _, rotation in ipairs({
				10,
				0,
				-10,
				0
			}) do
				if not self.running then
					return
				end

				local tweens3 = self.tweens
				table.insert(tweens3, playTween(meter, tweenInfo3, {
					Rotation = rotation
				}))
				task.wait(0.05)
			end
		end

		task.wait(0.25)

		if not self.running then
			return
		end

		local tweenInfo3 = TweenInfo.new(0.15, Enum.EasingStyle.Sine)

		if meter then
			local tweens3 = self.tweens
			local v4 = {
				Size = UDim2.fromScale(1, 1)
			}
			table.insert(tweens3, playTween(meter, tweenInfo3, v4))
		end

		if progress then
			local tweens3 = self.tweens
			local v4 = {
				Position = UDim2.fromScale(0.5, 0.2),
				ImageTransparency = 1
			}
			table.insert(tweens3, playTween(progress, tweenInfo3, v4))
		end

		if progressBaked then
			local tweens3 = self.tweens
			local v4 = {
				Position = UDim2.fromScale(0.5, 0.2),
				ImageTransparency = 1
			}
			table.insert(tweens3, playTween(progressBaked, tweenInfo3, v4))
		end

		task.wait(0.2)
		GingerMeterController.cancel(self)
	end)
	table.insert(self.threads, thread)
end

return GingerMeterController