local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local v = nil
local SelectedSkill = {}
local events = game.ReplicatedStorage.Events
local v2 = nil
local localPlayer = game.Players.LocalPlayer
local frame = nil
local skillNameLabel = nil
local toolIcon = nil
local scale = nil
local offset = nil
local v3 = nil
local PlayerUtil = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlayerUtil"))
PlayerUtil.ScreenReady({ "HUDNoInset" }, function(p)
	frame = assert(p.HUDNoInset, "package.HUDNoInset").Frame
	skillNameLabel = frame.SkillNameLabel
	toolIcon = frame.ToolIcon
	scale = frame.Position.Y.Scale
	offset = frame.ListLayout.Padding.Offset
	v3 = frame.Padding.PaddingLeft.Offset + frame.Padding.PaddingRight.Offset
end, (`Init {script.Name}`))

local function getToolName(value)
	local v4 = typeof(value) == "string" and value or value.Name
	local v5 = string.match(v4, "(.+)%-")
	return v5 or v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateText(text, p)
	skillNameLabel.Text = text
	local X = toolIcon.AbsoluteSize.X
	local v4 = skillNameLabel.TextBounds.X + 20
	local uDim = UDim2.new(0, X + v4 + offset + v3, 0.05, 0)

	if p then
		TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Size = uDim
		}):Play()
	else
		frame.Size = uDim
	end

	frame.Position = UDim2.fromScale(1, scale)
end

local function activatedSkill(text, p2)
	if not v:IsNewUIEnabled() or (p2 == "G" or p2 == "TAP") then
		return
	end

	updateText(text, true)
	frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
end

local function deactivatedSkill(value, _)
	if not v:IsNewUIEnabled() then
		return
	end

	local v5 = typeof(value) == "string" and value or value.Name
	updateText(string.match(v5, "(.+)%-") or v5, true)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
end

local function equippedTool(tool)
	if not v:IsNewUIEnabled() then
		return
	end

	local imageForToolInstance = ImageUtil.getImageForToolInstance(tool, nil)
	toolIcon.Image = not imageForToolInstance and "" or imageForToolInstance.Icon.Image
	local v4 = toolIcon
	local imageRectOffset

	if imageForToolInstance then
		imageRectOffset = imageForToolInstance.Icon.ImageRectOffset
	else
		imageRectOffset = Vector2.zero
	end

	v4.ImageRectOffset = imageRectOffset
	local v6 = toolIcon
	local imageRectSize

	if imageForToolInstance then
		imageRectSize = imageForToolInstance.Icon.ImageRectSize
	else
		imageRectSize = Vector2.zero
	end

	v6.ImageRectSize = imageRectSize
	toolIcon.Visible = imageForToolInstance ~= nil and imageForToolInstance.Icon.Image:len() > 0
	local v10 = typeof(tool) == "string" and tool or tool.Name
	local text = string.match(v10, "(.+)%-") or v10
	updateText(text, false) -- equivalent call inferred; original call site unknown
	frame.Position = UDim2.new(1, frame.AbsoluteSize.X, scale, 0)
	frame.Visible = true
	v2 = text
	TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(1, scale)
	}):Play()
end

local function unequippedTool(p)
	TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
		Position = UDim2.new(1, frame.AbsoluteSize.X, scale, 0)
	}):Play()
	task.delay(0.15, function()
		if p then
			local text = skillNameLabel.Text
			local v4 = p
			local v5 = typeof(v4) == "string" and v4 or v4.Name

			if text == (string.match(v5, "(.+)%-") or v5) then
				frame.Visible = false
				v2 = nil
			end
		else
			frame.Visible = false
			v2 = nil
		end
	end)
end

function SelectedSkill.OnStart(_)
	local MobileUIController = require(game.ReplicatedStorage.Controllers.UI.MobileUIController)
	v = MobileUIController
	ContextActionService.LocalToolEquipped:Connect(equippedTool)
	ContextActionService.LocalToolUnequipped:Connect(unequippedTool)
	localPlayer.CharacterRemoving:Connect(unequippedTool)
	events.ActivatedSkill.Event:Connect(activatedSkill)
	events.DeactivatedSkill.Event:Connect(deactivatedSkill)
	events.MobileUIModeUpdated.Event:Connect(function(p)
		if p then
			local tool = localPlayer.Character and localPlayer.Character:FindFirstChildWhichIsA("Tool")

			if tool then
				equippedTool(tool)
			end
		else
			unequippedTool()
		end
	end)

	local function reflectVisibility()
		frame.Visible = v2 ~= nil and GuiService.TouchControlsEnabled
	end

	GuiService:GetPropertyChangedSignal("TouchControlsEnabled"):Connect(reflectVisibility)
end

return SelectedSkill