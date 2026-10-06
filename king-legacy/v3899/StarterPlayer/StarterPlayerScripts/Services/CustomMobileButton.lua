local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

if not UserInputService.TouchEnabled then
	warn("Not Mobile")
	return
end

print("Touch Enabled: Running on Mobile")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Assets"):WaitForChild("Modules")
local MobileInteract = require(ReplicatedStorage.Chest.Assets.Modules.MobileInteract)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
local touchControlFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("TouchGui"):WaitForChild("TouchControlFrame")
local jumpButton = touchControlFrame:WaitForChild("JumpButton")
local customButton = script:WaitForChild("CustomButton")
game:GetService("UserInputService")
jumpButton.ZIndex = 3

local function SolveEquation(p, p2)
	local v = nil

	if p == "x" then
		return -120 / (p2 + 170)
	elseif p == "y" then
		return -120 / (p2 + 210)
	end

	return v
end

local v = { "DFFrame", "FSFrame", "SWFrame" }
local clones = {}
local prioritiesByName = {}
local clones2 = {}

function CreateButton(instance)
	local buttonName = instance.ButtonName
	local minusSize = instance.MinusSize
	local newPosition = instance.NewPosition
	local iconLabel = instance.IconLabel
	local clone = customButton:Clone()
	clone.Size = UDim2.new(0, jumpButton.Size.X.Offset / minusSize, 0, jumpButton.Size.Y.Offset / minusSize)
	clone.Position = newPosition
	clone.Name = instance.Name or buttonName .. "Button"
	clone.TextLabel.Text = buttonName
	clone.Visible = true
	clone.ZIndex = 0
	clone.Visible = true

	if iconLabel then
		clone.TextLabel.Visible = nil
		clone.IconLabel.Image = iconLabel
	end

	clone.Parent = instance.Parent or touchControlFrame

	if instance.LockAtPosition then
		table.insert(clones2, clone)
	end

	if not instance.AlwayShow then
		table.insert(clones, clone)
		prioritiesByName[clone.Name] = instance.Priority or 6
	end

	if instance.MouseButton1Click then
		clone.MouseButton1Click:Connect(instance.MouseButton1Click)
	end

	clone.MouseButton1Down:Connect(function()
		clone.IconLabel.ImageColor3 = Color3.fromRGB()
		clone.TextLabel.TextColor3 = Color3.fromRGB()
		clone.TextLabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	end)
	clone.MouseButton1Up:Connect(function()
		clone.IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone.TextLabel.TextStrokeColor3 = Color3.fromRGB()
	end)
	clone.MouseLeave:Connect(function()
		clone.IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		clone.TextLabel.TextStrokeColor3 = Color3.fromRGB()
	end)
	return clone
end

local v2 = {}

for _, childName in ipairs(v) do
	local clone = touchControlFrame:FindFirstChild(childName)

	if not clone then
		clone = script.TypeFrame:Clone()
		clone.Name = childName
		clone.Parent = touchControlFrame
	end

	CreateButton({
		Parent = clone,
		ButtonName = "Z",
		Name = "SkillZ",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 1.3333333333333333,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / -2
		),
		Priority = 0
	})
	CreateButton({
		Parent = clone,
		ButtonName = "X",
		Name = "SkillX",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 1.3333333333333333,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 4
		),
		Priority = 0
	})
	CreateButton({
		Parent = clone,
		ButtonName = "C",
		Name = "SkillC",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 8,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 1.3333333333333333
		),
		Priority = 0
	})
	CreateButton({
		Parent = clone,
		ButtonName = "V",
		Name = "SkillV",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / -1.5,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 1.7142857142857142
		),
		Priority = 0
	})
	CreateButton({
		Parent = clone,
		ButtonName = "E",
		Name = "SkillE",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 0.7058823529411765,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / -8
		),
		Priority = 0
	})
	CreateButton({
		Parent = clone,
		ButtonName = "B",
		Name = "SkillB",
		MinusSize = 1.6,
		NewPosition = UDim2.new(
			jumpButton.Position.X.Scale,
			jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 1.2,
			jumpButton.Position.Y.Scale,
			jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 1
		),
		Priority = 0
	})
	local v3 = childName

	MobileInteract[`{childName}UpdateRequirementSkills`] = function(value, items)
		local v4 = "DF"
		local v5 = value:sub(1, #value / 2)

		if v3 == "FSFrame" then
			v5 = value
			v4 = "Melee"
		elseif v3 == "SWFrame" then
			v5 = value:gsub("%s+", "")
			v4 = "sword"
		end

		for k, item in pairs(items) do
			local visible

			if localPlayer.PlayerStats[v4].Value < item then
				warn("locked", k, "low stats")
			else
				visible = true
			end

			local v7 = string.sub(k, 1, 1)

			if not (not string.find(k, "Awake") or _G.CheckAwakeClient(localPlayer, (`{v5}{v7}`))) then
				continue
			end

			clone[`Skill{v7}`].Visible = visible
		end
	end

	MobileInteract[`{childName}`] = clone

	MobileInteract[`{childName}Visible`] = function(visible: boolean)
		for _, child in ipairs(clone:GetChildren()) do
			child.Visible = visible
		end
	end

	MobileInteract[`{childName}Cooldown`] = function(p, p2)
		local child = clone:FindFirstChild((`Skill{p}`))

		if not child then
			return
		end

		if v2[child] then
			for _, v4 in ipairs(v2[child]) do
				if typeof(v4) == "Tween" then
					v4:Pause()
				end

				v4:Destroy()
			end

			v2[child] = nil
		end

		local cooldownGroup = child.CooldownGroup
		local timeCount = cooldownGroup.TimeCount
		local left = cooldownGroup.Left
		local right = cooldownGroup.Right
		left.Visible = true
		right.Visible = true
		timeCount.Visible = true
		cooldownGroup.BGFrame.Visible = true
		left.UIGradient.Rotation = 0
		right.UIGradient.Rotation = 0
		local tween = TweenService:Create(right.UIGradient, TweenInfo.new(p2 / 2, Enum.EasingStyle.Linear), {
			Rotation = 180
		})
		local tween2 = TweenService:Create(left.UIGradient, TweenInfo.new(p2 / 2, Enum.EasingStyle.Linear), {
			Rotation = 180
		})
		math.random(1, 99999999)
		local v4 = Scheduler.new(p2):Ignore():Wait(0.1):OnStep(function(p3)
			local v5 = (1 - p3) * p2
			timeCount.Text = string.format("%.1f", v5)
		end):Execute()
		v2[child] = { tween, tween2, v4 }
		tween:Play()
		tween.Completed:Wait()
		tween2:Play()
		tween2.Completed:Wait()
		left.Visible = nil
		right.Visible = nil
		timeCount.Visible = nil
		cooldownGroup.BGFrame.Visible = false
		tween2:Destroy()
		tween:Destroy()
		v4:Destroy()
		v2[child] = nil
	end
end

function MobileInteract.VisibleAllSkillFrame(p)
	for _, v3 in ipairs(v) do
		MobileInteract[`{v3}Visible`](p)
	end
end

function MobileInteract.VisibleSkillFrame(p, p2)
	MobileInteract[`{p}Visible`](p2)
end

MobileInteract.VisibleAllSkillFrame(nil)
CreateButton({
	ButtonName = "Lock",
	IconLabel = "rbxassetid://135269091981742",
	MinusSize = 2.2,
	NewPosition = UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset + jumpButton.Size.Y.Offset / 1.15,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset + jumpButton.Size.Y.Offset / 1.25
	),
	AlwayShow = true
}).MouseButton1Click:Connect(function()
	if not shared.MouseLockInit then
		return
	end

	shared.MouseLockInit:ToggleShiftLock(not shared.MouseLockInit.Enabled)
	shared.MouseLockInit:UpdateMobileImageButton()
end)
local _ = {
	UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 1.0909090909090908,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / -4.8
	),
	UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 1.7391304347826086,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 2.1818181818181817
	),
	UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / -12,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 1.3333333333333333
	),
	UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 0.7692307692307693,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 2.6666666666666665
	),
	(UDim2.new(
		jumpButton.Position.X.Scale,
		jumpButton.Position.X.Offset - jumpButton.Size.Y.Offset / 2.1818181818181817,
		jumpButton.Position.Y.Scale,
		jumpButton.Position.Y.Offset - jumpButton.Size.Y.Offset / 0.9230769230769231
	))
}