script.Brush.UIGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 2, 134)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 98, 244)),
	ColorSequenceKeypoint.new(0.54, Color3.fromRGB(0, 98, 244)),
	ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 98, 244)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 2, 134))
})
local outlineGlow = script.Parent:WaitForChild("Frame"):WaitForChild("Tile2"):WaitForChild("OutlineGlow")
outlineGlow.ImageColor3 = Color3.fromRGB(0, 98, 244)
local settings = script.Parent.Parent.HUDButtonBar.Settings
local ExperienceNotificationService = game:GetService("ExperienceNotificationService")

-- equivalent calls inferred from this helper; original call sites unknown
local function canPromptOptIn()
	local success, result = pcall(function()
		return ExperienceNotificationService:CanPromptOptInAsync()
	end)
	return success and result
end

local v = nil
local frame = script.Parent.Frame
frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.Activated:Connect(function()
	local _, _ = pcall(function()
		ExperienceNotificationService:PromptOptIn()
	end)
	ExperienceNotificationService.OptInPromptClosed:Wait()

	if not canPromptOptIn() then
		frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.Visible = false
		frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.Visible = true
		game.ReplicatedStorage.Remotes.UpdateLogComm:InvokeServer("clickedButton")
	end
end)
local numberValue = Instance.new("NumberValue")
numberValue.Value = 1
numberValue.Changed:Connect(function()
	settings.Notify2.UIGradient.Transparency = NumberSequence.new(numberValue.Value)
end)
local TweenService = game:GetService("TweenService")
local tween = TweenService:Create(
	numberValue,
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true),
	{
		Value = 0
	}
)
local updateLogButton = settings.Buttons.Page1.UpdateLogButton
local v2 = false

local function ApplyShownState()
	if v2 then
		task.spawn(
			game.ReplicatedStorage.Remotes.UpdateLogComm.InvokeServer,
			game.ReplicatedStorage.Remotes.UpdateLogComm,
			"openedLog"
		)
		local Global = require(game.ReplicatedStorage.Global)
		Global.closeOthers("WhatsNew")
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(frame.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
		frame.Parent.Visible = true

		if tween.PlaybackState == Enum.PlaybackState.Playing then
			tween:Cancel()
			updateLogButton.Notify2.Visible = false
			numberValue.Value = 1
			local TweenService3 = game:GetService("TweenService")
			tween = TweenService3:Create(
				numberValue,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true),
				{
					Value = 0
				}
			)
		end

		game.ReplicatedStorage.Remotes.GetUpdates:InvokeServer(true)
	else
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(frame.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0.5, 2.2)
		}):Play()
		frame.Parent.Visible = false
	end
end

local function SetShown(flag: boolean)
	if v2 == flag then
		return
	end

	v2 = flag
	ApplyShownState()
end

local function Toggle()
	v2 = not v2
	ApplyShownState()
end

local Global = require(game.ReplicatedStorage.Global)

function Global.updateLog(flag: boolean?)
	if flag == nil then
		v2 = not v2
	else
		if v2 == flag then
			return
		end

		v2 = flag
	end

	ApplyShownState()
end

updateLogButton.Activated:Connect(Toggle)
script.Parent:GetAttributeChangedSignal("Closed"):Connect(function()
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(frame.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 2.2)
	}):Play()
end)

local function GetNumberSequenceValue(sequence, value: number)
	local v3 = math.clamp(value, 0, 1)
	local keypoints = sequence.Keypoints

	if #keypoints == 0 then
		return 0
	end

	if #keypoints == 1 then
		return keypoints[1].Value
	end

	local keypoint = keypoints[1]
	local keypoint2 = keypoints[#keypoints]

	for i = 1, #keypoints do
		if not (v3 <= keypoints[i].Time) then
			continue
		end

		keypoint2 = keypoints[i]

		if i > 1 then
			keypoint = keypoints[i - 1]
		end

		break
	end

	if keypoint.Time == keypoint2.Time then
		return keypoint.Value
	end

	local v4 = (v3 - keypoint.Time) / (keypoint2.Time - keypoint.Time)
	return keypoint.Value + (keypoint2.Value - keypoint.Value) * v4
end

local brush = script.Brush
brush.UIGradient.Offset = Vector2.new(-1, 0)
local flag = false

function PlayParticles()
	if flag then
		return
	end

	flag = true
	local v3 = {
		"rbxassetid://140262202462861",
		"rbxassetid://140262202462861",
		"rbxassetid://140262202462861",
		"rbxassetid://140262202462861"
	}
	local v4 = {}

	for i = 1, 4 do
		local imageLabel = Instance.new("ImageLabel", brush)
		imageLabel.Image = v3[i]
		imageLabel.BackgroundTransparency = 1
		imageLabel.ImageTransparency = 0
		imageLabel.Visible = false
		imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeXX
		imageLabel.Parent = brush
		imageLabel.Size = UDim2.fromScale(0.2, 0.2)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.ZIndex = 10
		v4[i] = {
			Object = imageLabel,
			Elapsed = 0,
			Lifetime = 0
		}
	end

	task.spawn(function()
		while flag do
			task.wait(math.random() * 0.2 + 0.6)

			for i = 1, 4 do
				local v5 = i
				task.spawn(function()
					local object = v4[v5].Object
					local v6 = math.random() * 0.5 + 0.5
					object.Position = UDim2.fromScale(
						math.random() < 0.5 and math.random() * 0.2 or 0.8 + math.random() * 0.2,
						math.random() < 0.5 and math.random() * 0.2 or 0.8 + math.random() * 0.2
					)
					object.Rotation = math.random() * 360
					object.Visible = false

					for i2 = 1, 6 do
						task.wait(0.03 * v6)
						object.Visible = not object.Visible
					end
				end)
			end
		end

		for _, v5 in pairs(v4) do
			v5.Object:Destroy()
		end
	end)
end

function StopParticles()
	flag = false
end

local function Refresh()
	if not v then
		return
	end

	frame.Tile1.ImageLabel.Image = v.CurrentWeek.Image == "" and "rbxassetid://130878632431027" or v.CurrentWeek.Image

	for k, v3 in pairs(v.CurrentWeek.Text) do
		v.CurrentWeek.Text[k] = "• " .. v3
	end

	frame.Tile1.ScrollingFrame.TextLabel.Text = table.concat(v.CurrentWeek.Text, "<br/>")

	if v.NextWeek then
		if #v.NextWeek.Text == 1 then
			frame.Tile2.ImageLabel.Image = v.NextWeek.Image == "" and "rbxassetid://130878632431027" or v.NextWeek.Image
			brush.Parent = frame.Tile2.ScrollingFrame.CanvasGroup
			brush.TextLabel.Text = v.NextWeek.Text[1]
			brush.TextLabel.TextLabel.Text = v.NextWeek.Text[1]
			frame.Tile2.ScrollingFrame.CanvasGroup.TextLabel.Visible = false
			frame.Tile2.OutlineGlow.Visible = true
		else
			frame.Tile2.ScrollingFrame.CanvasGroup.TextLabel.Visible = true
			frame.Tile2.ImageLabel.Image = v.NextWeek.Image == "" and "rbxassetid://130878632431027" or v.NextWeek.Image

			for k, v3 in pairs(v.NextWeek.Text) do
				v.NextWeek.Text[k] = "• " .. v3
			end

			frame.Tile2.OutlineGlow.Visible = false
			frame.Tile2.ScrollingFrame.CanvasGroup.TextLabel.Text = table.concat(v.NextWeek.Text, "<br/>") .. "<br/>... and more!"
		end
	else
		frame.Title2.ImageLabel.Image = ""
		frame.Title2.ScrollingFrame.CanvasGroup.TextLabel.Text = "More info coming later!"
	end

	if canPromptOptIn() then
		frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.Visible = true
		frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.Visible = false
	else
		frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.Visible = false
		frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.Visible = true
	end
end

local function UpdateTextSize()
	local textSize = math.max(math.round(frame.Tile1.AbsoluteSize.Y * 0.05646173149309912), 15)
	frame.Tile1.ScrollingFrame.TextLabel.TextSize = textSize
	frame.Tile2.ScrollingFrame.CanvasGroup.TextLabel.TextSize = frame.Tile1.ScrollingFrame.TextLabel.TextSize
	frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.TextSize = frame.Tile1.ScrollingFrame.TextLabel.TextSize

	if frame.Tile2.ScrollingFrame.AbsoluteSize.Y > frame.Tile2.ScrollingFrame.AbsoluteCanvasSize.Y + 1 then
		frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.LayoutOrder = -11
		frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.LayoutOrder = -11
		frame.Tile2.ScrollingFrame.CanvasGroup.Padding.LayoutOrder = -10
	else
		frame.Tile2.ScrollingFrame.CanvasGroup.Padding.LayoutOrder = 10
		frame.Tile2.ScrollingFrame.CanvasGroup.BottomText.LayoutOrder = 11
		frame.Tile2.ScrollingFrame.CanvasGroup.NotifyButton.LayoutOrder = 11
	end
end

script.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTextSize)
frame.Tile1.ScrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
	if frame.Tile1.ScrollingFrame.AbsoluteCanvasSize.Y > frame.Tile1.ScrollingFrame.AbsoluteSize.Y then
		frame.Tile1.ScrollingFrame.TextLabel.Size = UDim2.new(1, -9, 0, 0)
	else
		frame.Tile1.ScrollingFrame.TextLabel.Size = UDim2.new(1, 0, 0, 0)
	end
end)
frame.Tile2.ScrollingFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
	if frame.Tile2.ScrollingFrame.AbsoluteCanvasSize.Y > frame.Tile1.ScrollingFrame.AbsoluteSize.Y then
		frame.Tile2.ScrollingFrame.CanvasGroup.Size = UDim2.new(1, -9, 0, 0)
	else
		frame.Tile2.ScrollingFrame.CanvasGroup.Size = UDim2.new(1, 0, 0, 0)
	end
end)
UpdateTextSize()
frame.Parent.Title.Close.Activated:Connect(function()
	v2 = false
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(frame.Parent, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.fromScale(0.5, 2.2)
	}):Play()
end)
task.spawn(function()
	if canPromptOptIn() then
		game.ReplicatedStorage.Remotes:WaitForChild("UpdateLogComm", 1e999):InvokeServer("canPromptAtSpawn")
	end
end)

while true do
	local success, result = pcall(function()
		local v3 = nil

		while not v3 do
			local _, _ = pcall(function()
				v3 = game.ReplicatedStorage.Remotes.GetUpdates:InvokeServer()
			end)

			if not v3 then
				task.wait(1)
			end
		end

		v = v3

		if v.Notify and tween.PlaybackState ~= Enum.PlaybackState.Playing then
			tween:Play()
			settings.Buttons.Page1.UpdateLogButton.Notify2.Visible = true
		elseif not v.Notify and tween.PlaybackState == Enum.PlaybackState.Playing then
			settings.Buttons.Page1.UpdateLogButton.Notify2.Visible = false
			tween:Cancel()
			numberValue.Value = 1
			local TweenService2 = game:GetService("TweenService")
			tween = TweenService2:Create(
				numberValue,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true),
				{
					Value = 0
				}
			)
		end

		Refresh()
	end)

	if not success then
		warn(result)
	end

	task.wait(60)
end