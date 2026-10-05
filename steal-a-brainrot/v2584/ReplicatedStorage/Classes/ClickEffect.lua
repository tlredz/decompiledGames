local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(packages.Trove)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ClickEffect = {
	GetSize = function(self)
		return 35
	end
}

function ClickEffect.new(point: Vector2)
	if not point then
		warn("[ClickEffect] targetPosition nil")
		return
	end

	local parent = playerGui:FindFirstChild("ClickEffect")

	if not parent then
		parent = Instance.new("ScreenGui")
		parent.Name = "ClickEffect"
		parent.DisplayOrder = 100
		parent.IgnoreGuiInset = false
		parent.ResetOnSpawn = false
		parent.Parent = playerGui
	end

	local v2 = Trove.new()
	local v3 = 2

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onWaveFinished()
		v3 -= 1

		if v3 <= 0 then
			v2:Destroy()
		end
	end

	local function spawnWave(p: number, duration: number)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromOffset(point.X, point.Y)
		frame.Size = UDim2.fromOffset(1, 1)
		frame.BackgroundColor3 = Color3.new(1, 1, 1)
		frame.BackgroundTransparency = 1
		frame.ZIndex = 10
		frame.Parent = parent
		v2:Add(frame)
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame
		v2:Add(uICorner)
		local tween = TweenService:Create(frame, tweenInfo, {
			Size = UDim2.fromOffset(p, p),
			BackgroundTransparency = 0.3
		})
		v2:Add(tween)
		tween.Completed:Once(function()
			local tween2 = TweenService:Create(frame, tweenInfo, {
				Size = UDim2.fromOffset(1, 1),
				BackgroundTransparency = 1
			})
			v2:Add(tween2)
			tween2.Completed:Once(function()
				frame:Destroy()
				onWaveFinished() -- equivalent call inferred; original call site unknown
			end)
			tween2:Play()
		end)
		task.delay(duration, tween.Play, tween)
	end

	spawnWave(ClickEffect:GetSize(), 0)
	spawnWave(ClickEffect:GetSize() * 1.25, 0.05)
end

return ClickEffect