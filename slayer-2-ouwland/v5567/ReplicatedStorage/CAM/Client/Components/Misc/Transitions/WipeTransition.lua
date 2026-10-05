local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local faye = require(ReplicatedStorage.Packages.faye)
local quad = Enum.EasingStyle.Quad
return function(options)
	local v = options or {}
	local v2 = faye.new()
	local timeBetween = v.TimeBetween or 0.5
	local color = v.Color or Color3.new()
	local duration = v.Duration or 0.35
	local tweenInfo = TweenInfo.new(duration, quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(duration, quad, Enum.EasingDirection.In)
	local screenGui = Instance.new("ScreenGui")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.DisplayOrder = v.DisplayOrder or 999999
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.Name = `{script.Name}-Transition`
	screenGui.Parent = game.Players.LocalPlayer.PlayerGui
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local v3 = (viewportSize.X + viewportSize.Y) * 0.7071067811865476
	local v4 = v3 + 96
	local v5 = (viewportSize.X - viewportSize.Y) * 0.25

	-- equivalent calls inferred from this helper; original call sites unknown
	local function centerAt(p: number)
		local v6 = (p - v4 * 0.5) * 0.7071067811865476
		return UDim2.fromOffset(v6 + v5, v6 - v5)
	end

	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = color
	frame.Rotation = 45
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Size = UDim2.fromOffset(v4, v4)
	frame.Position = centerAt(0)
	frame.Parent = screenGui
	v2:Add(screenGui)
	TweenService:Create(frame, tweenInfo, {
		Position = centerAt(v3)
	}):Play()

	if v.OnCovered ~= nil then
		task.delay(duration, function()
			task.spawn(v.OnCovered)
		end)
	end

	local function Do()
		TweenService:Create(frame, tweenInfo2, {
			Position = centerAt(v3 + v4)
		}):Play()
		task.wait(duration + 0.05)
		v2:Destroy()
	end

	if v.Switch == nil then
		task.delay(timeBetween, Do)
	else
		task.spawn(function()
			repeat
				task.wait()
			until v.Switch

			Do()
		end)
	end
end