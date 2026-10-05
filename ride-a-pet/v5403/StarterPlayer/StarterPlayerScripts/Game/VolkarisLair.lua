local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VolkarisLairAnimation = require(ReplicatedStorage.GameServices:WaitForChild("VolkarisLairAnimation"))
local Guardian = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Guardian"))
local Observers = require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Observers"))
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(
	Guardian.PulseSeconds / 2,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.InOut,
	Guardian.PulseCount - 1,
	true
)

local function ShowAlert(instance)
	local dragon = instance:FindFirstChild("Dragon")

	if not (dragon and dragon:IsA("BasePart")) then
		dragon = instance.PrimaryPart
	end

	if not dragon then
		return function() end
	end

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "GuardianAlert"
	billboardGui.Adornee = dragon
	billboardGui.AlwaysOnTop = true
	billboardGui.LightInfluence = 0
	billboardGui.Size = UDim2.fromScale(10, 16)
	billboardGui.StudsOffsetWorldSpace = Vector3.new(0, dragon.Size.Y / 2 + 10, 0)
	billboardGui.MaxDistance = 1500
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = "!"
	textLabel.TextScaled = true
	textLabel.TextColor3 = Guardian.AlertColor
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 4
	uIStroke.Color = Color3.new(0, 0, 0)
	uIStroke.Parent = textLabel
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 0
	uIScale.Parent = textLabel
	textLabel.Parent = billboardGui
	billboardGui.Parent = instance
	local highlight = Instance.new("Highlight")
	highlight.Name = "GuardianPulse"
	highlight.Adornee = instance
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillColor = Guardian.AlertColor
	highlight.OutlineColor = Guardian.AlertColor
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = instance
	TweenService:Create(uIScale, tweenInfo, {
		Scale = 1
	}):Play()
	TweenService:Create(highlight, tweenInfo3, {
		FillTransparency = 0.35,
		OutlineTransparency = 0
	}):Play()
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Remove()
		if flag then
			return
		end

		flag = true
		billboardGui:Destroy()
		highlight:Destroy()
	end

	task.delay(Guardian.AlertSeconds, function()
		if flag then
			return
		end

		local tween = TweenService:Create(uIScale, tweenInfo2, {
			Scale = 0
		})
		tween:Play()
		tween.Completed:Wait()
		Remove() -- equivalent call inferred; original call site unknown
	end)
	return Remove
end

Observers.observeTag(Guardian.RigTag, function(p)
	local success, result = pcall(VolkarisLairAnimation.Prepare, p)

	if not success then
		warn("[VolkarisLair] " .. tostring(result))
		return nil
	end

	local v = nil
	local v2 = Observers.observeAttribute(p, "GuardianState", function(p2)
		if p2 == "Sleeping" then
			VolkarisLairAnimation.Sleep(p)
		elseif p2 == "Waking" then
			local success2, result2 = pcall(VolkarisLairAnimation.Wake, p)

			if not success2 then
				warn("[VolkarisLair] " .. tostring(result2))
			end

			if v then
				v()
			end

			v = ShowAlert(p)
		elseif p2 == "Chasing" or p2 == "Returning" then
			VolkarisLairAnimation.Fly(p)
		end

		return nil
	end)
	return function()
		v2()

		if v then
			v()
		end

		VolkarisLairAnimation.Remove(p)
	end
end, { workspace })