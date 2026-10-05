local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	{
		Id = "banana_slip",
		Label = "Banana Slip"
	},
	{
		Id = "force_sit",
		Label = "Force Sit"
	},
	{
		Id = "freeze",
		Label = "Freeze"
	},
	{
		Id = "unfreeze",
		Label = "Unfreeze"
	},
	{
		Id = "fling",
		Label = "Fling"
	},
	{
		Id = "arm_lock",
		Label = "Arm Lock"
	},
	{
		Id = "electric_shock",
		Label = "Electric Shock"
	},
	{
		Id = "chicken_mode",
		Label = "Chicken Mode"
	},
	{
		Id = "clone",
		Label = "Clone"
	},
	{
		Id = "puppet",
		Label = "Puppet"
	},
	{
		Id = "bring",
		Label = "Bring"
	},
	{
		Id = "send_to_spawn",
		Label = "Send To Spawn"
	},
	{
		Id = "heal",
		Label = "Heal"
	},
	{
		Id = "kill",
		Label = "Kill",
		Critical = true
	},
	{
		Id = "kick",
		Label = "Kick",
		Critical = true
	}
}
local SpectateActions = {}
SpectateActions.__index = SpectateActions

local function CreateFallback()
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "ScrollingFrameActionsV2"
	scrollingFrame.AnchorPoint = Vector2.new(0, 0.5)
	scrollingFrame.Position = UDim2.new(0, 12, 0.5, 0)
	scrollingFrame.Size = UDim2.fromOffset(180, 340)
	scrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	scrollingFrame.BackgroundTransparency = 0.1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 5
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.CanvasSize = UDim2.new()
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 6)
	uICorner.Parent = scrollingFrame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0, 5)
	uIPadding.PaddingBottom = UDim.new(0, 5)
	uIPadding.PaddingLeft = UDim.new(0, 5)
	uIPadding.PaddingRight = UDim.new(0, 5)
	uIPadding.Parent = scrollingFrame
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, 4)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = scrollingFrame

	for k, v2 in v do
		local textButton = Instance.new("TextButton")
		textButton.Name = v2.Id
		textButton.LayoutOrder = k
		textButton.Size = UDim2.new(1, 0, 0, 30)
		local backgroundColor

		if v2.Critical then
			backgroundColor = Color3.fromRGB(130, 45, 45)
		else
			backgroundColor = Color3.fromRGB(40, 40, 55)
		end

		textButton.BackgroundColor3 = backgroundColor
		textButton.BorderSizePixel = 0
		textButton.Font = Enum.Font.GothamBold
		textButton.Text = v2.Label
		textButton.TextColor3 = Color3.new(1, 1, 1)
		textButton.TextSize = 13
		textButton:SetAttribute("AdminAction", v2.Id)
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = textButton
		textButton.Parent = scrollingFrame
	end

	return scrollingFrame
end

function SpectateActions.new()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local adminActionEvent = ReplicatedStorage:WaitForChild("AdminActionEvent")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminV2SpectateActions"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10001
	screenGui.Parent = playerGui
	local adminMenuGUI = playerGui:FindFirstChild("AdminMenuGUI") or playerGui:WaitForChild("AdminMenuGUI", 5)

	if adminMenuGUI and adminMenuGUI:IsA("ScreenGui") then
		screenGui.IgnoreGuiInset = adminMenuGUI.IgnoreGuiInset
		screenGui.ZIndexBehavior = adminMenuGUI.ZIndexBehavior
		screenGui.DisplayOrder = adminMenuGUI.DisplayOrder + 1
	end

	local scrollingFrameActions = adminMenuGUI and adminMenuGUI:FindFirstChild("ScrollingFrameActions")
	local clone

	if scrollingFrameActions and scrollingFrameActions:IsA("ScrollingFrame") then
		clone = scrollingFrameActions:Clone()
		clone.Name = "ScrollingFrameActionsV2"
	else
		clone = CreateFallback()
	end

	clone.Visible = false
	clone.Parent = screenGui
	local object = setmetatable({
		Target = nil,
		Gui = screenGui,
		Frame = clone,
		Destroyed = false
	}, SpectateActions)

	for _, button in clone:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local adminAction = button:GetAttribute("AdminAction")

		if type(adminAction) ~= "string" then
			continue
		end

		local v2 = adminAction
		button.MouseButton1Click:Connect(function()
			local target = object.Target

			if object.Destroyed or not target or target.Parent ~= Players then
				return
			end

			adminActionEvent:FireServer(v2, target.UserId, nil)
		end)
	end

	return object
end

function SpectateActions:SetTarget(target)
	if self.Destroyed then
		return
	end

	self.Target = target
	self.Frame.Visible = target ~= nil
end

function SpectateActions:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	self.Target = nil
	self.Gui:Destroy()
end

return SpectateActions