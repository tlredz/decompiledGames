local Players = game:GetService("Players")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local AvatarAbilitiesInterface = require(script.Parent:WaitForChild("AvatarAbilitiesInterface"))
local v = AvatarAbilitiesInterface.get(Players.LocalPlayer)
local InputSlots = require(script.Parent:WaitForChild("InputSlots"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserAbilitiesUserInterfaceA")
local userFlag2 = flagUtil.getUserFlag("UserAbilitiesUserInterfaceC")
local v2 = {
	{
		small = { 72, 60, 60 },
		large = { 92, 112, 112 }
	},
	{
		small = { 44, 132, 132 },
		large = { 56, 200, 200 }
	},
	{
		small = { 44, 132, 16 },
		large = { 56, 200, 60 }
	},
	{
		small = { 44, 16, 132 },
		large = { 56, 60, 200 }
	},
	{
		small = { 44, 156, 74 },
		large = { 56, 228, 130 }
	},
	{
		small = { 44, 74, 156 },
		large = { 56, 130, 228 }
	},
	{
		small = { 44, 16, 16 },
		large = { 56, 60, 60 }
	}
}
local v3 = { 28, 44 }
local v4 = { 36, 56 }
local v5 = { 16, 12 }
local v6 = { 16, 12 }

-- equivalent calls inferred from this helper; original call sites unknown
local function IsPortrait()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		return playerGui.CurrentScreenOrientation == Enum.ScreenOrientation.Portrait
	end

	return false
end

local TouchAbilities = {}
TouchAbilities.__index = TouchAbilities

function TouchAbilities.new(parentUIFrame)
	local self = setmetatable({}, TouchAbilities)
	self.parentUIFrame = parentUIFrame
	self.managedButtons = {}
	self.created = false
	self.enabled = false
	self.enabledChangedEvent = Instance.new("BindableEvent")
	return self
end

function TouchAbilities:Enable(enabled)
	if self.enabled == enabled then
		return
	end

	self.enabled = enabled

	if enabled and not self.created then
		self:Create()
		self.created = true
	end

	self.enabledChangedEvent:Fire()
end

function TouchAbilities:CreateAbilityButton(p, data2, instance, p2, p3)
	local buttonPressedAssetId = "rbxassetid://76895455502876"
	local buttonInvalidAssetId = nil
	local v7 = false
	local image = not data2.ButtonAssetId and "rbxassetid://136780077406114" or data2.ButtonAssetId

	if data2.ButtonPressedAssetId then
		buttonPressedAssetId = data2.ButtonPressedAssetId
	end

	if data2.ButtonInvalidAssetId then
		buttonInvalidAssetId = data2.ButtonInvalidAssetId
	end

	local imageButton = Instance.new("ImageButton")
	imageButton.Name = p .. "Button"
	imageButton.Visible = false
	imageButton.BackgroundTransparency = 1
	imageButton.Image = image
	imageButton.Parent = self.parentUIFrame

	for _, inputBinding in instance:GetChildren() do
		if not (string.find(inputBinding.Name, "Touch") and inputBinding:IsA("InputBinding")) then
			continue
		end

		inputBinding.UIButton = imageButton
		break
	end

	local function ResizeButton()
		local small = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y) <= 500 and p2.small or p2.large
		local v9 = small[1]
		local v10 = small[2]
		local v11 = small[3]
		local v12 = -v10 - v9
		imageButton.Size = UDim2.new(0, v9, 0, v9)

		if p3 then
			imageButton.Position = UDim2.new(1, v12, 0, v11)
			return
		end

		local v13 = -v11 - v9
		imageButton.Position = UDim2.new(1, v12, 1, v13)
	end

	ResizeButton()
	local connections = {}
	table.insert(connections, self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeButton))

	local function UpdateButtonState()
		local abilityValid = v:GetAbilityValid(p)
		local abilityActive = v:GetAbilityActive(p)
		imageButton.Visible = self.enabled and instance.Enabled

		if imageButton.Visible then
			if abilityActive or v7 and abilityValid then
				imageButton.Image = buttonPressedAssetId
				imageButton.ImageTransparency = 0
			elseif abilityValid then
				imageButton.Image = image
				imageButton.ImageTransparency = 0
			elseif buttonInvalidAssetId then
				imageButton.Image = buttonInvalidAssetId
				imageButton.ImageTransparency = 0
			else
				imageButton.Image = image
				imageButton.ImageTransparency = 0.6
			end
		end
	end

	UpdateButtonState()
	imageButton.MouseButton1Down:Connect(function()
		v7 = true
		UpdateButtonState()
	end)
	imageButton.MouseButton1Up:Connect(function()
		v7 = false
		UpdateButtonState()
	end)
	imageButton.MouseLeave:Connect(function()
		v7 = false
		UpdateButtonState()
	end)
	table.insert(connections, v:GetAbilityActiveChangedSignal(p):Connect(UpdateButtonState))
	table.insert(connections, v:GetAbilityValidChangedSignal(p):Connect(UpdateButtonState))
	table.insert(connections, self.enabledChangedEvent.Event:Connect(UpdateButtonState))
	table.insert(connections, instance:GetPropertyChangedSignal("Enabled"):Connect(UpdateButtonState))
	imageButton.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end)
	return imageButton
end

function TouchAbilities:CreateOverflowScrollButton(p2)
	local imageButton = Instance.new("ImageButton")
	imageButton.Name = "ScrollButton"
	imageButton.BackgroundTransparency = 1
	imageButton.Image = "rbxassetid://120193229129639"
	imageButton.PressedImage = "rbxassetid://122643389561468"
	imageButton.Parent = self.parentUIFrame

	local function ResizeButton()
		local v7 = math.min(self.parentUIFrame.AbsoluteSize.x, self.parentUIFrame.AbsoluteSize.y)
		local portrait = IsPortrait() -- equivalent call inferred; original call site unknown
		local v9 = v7 <= 500
		local v10 = v9 and v3 or v4
		local v11 = v9 and v5 or v6
		local v12 = v9 and 8 or 10
		local v13 = v9 and 44 or 56
		imageButton.Size = UDim2.new(0, v10[1], 0, v10[2])

		if p2 then
			if portrait then
				imageButton.Position = UDim2.new(
					1,
					-v11[1] - v10[2] + 0.5 * (v10[2] - v10[1]),
					0,
					v11[2] + v10[1] + 4 * v12 + 3 * v13 - 0.5 * (v10[2] - v10[1])
				)
				imageButton.Rotation = 270
			else
				imageButton.Position = UDim2.new(1, -v11[1] - 2 * v10[1] - 4 * v12 - 3 * v13, 0, v11[2])
				imageButton.Rotation = 0
			end
		else
			imageButton.Position = UDim2.new(1, -v11[1] - v10[1], 0, v11[2])

			if portrait then
				imageButton.Position = UDim2.new(
					1,
					-v11[1] - v10[2] + 0.5 * (v10[2] - v10[1]),
					0,
					v11[2] - 0.5 * (v10[2] - v10[1])
				)
				imageButton.Rotation = 90
			else
				imageButton.Position = UDim2.new(1, -v11[1] - v10[1], 0, v11[2])
				imageButton.Rotation = 180
			end
		end
	end

	ResizeButton()
	local connections = {}
	table.insert(connections, self.parentUIFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizeButton))
	imageButton.Activated:Connect(function()
		if p2 then
			InputSlots.setOverflowScrollIndex(InputSlots.getOverflowScrollIndex() + 1)
		else
			InputSlots.setOverflowScrollIndex(InputSlots.getOverflowScrollIndex() - 1)
		end
	end)
	imageButton.Destroying:Connect(function()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end)
	return imageButton
end

function TouchAbilities:Create()
	if not self.parentUIFrame then
		return
	end

	local function CreateButtons()
		for _, managedButton in self.managedButtons do
			managedButton:Destroy()
		end

		self.managedButtons = {}

		if v:isEnabled() then
			local slotMap = InputSlots.GetSlotMap()

			for k, v7 in pairs(slotMap) do
				local actionInSlot = InputSlots.GetActionInSlot(k)

				if not (v7 and actionInSlot and k <= #v2 and (userFlag or k == 1)) then
					continue
				end

				local abilityConfig = v:GetAbilityConfig(v7)
				table.insert(
					self.managedButtons,
					self:CreateAbilityButton(v7, abilityConfig, actionInSlot, v2[k], false)
				)
			end

			if userFlag and userFlag2 then
				local abilitiesInOverflow = InputSlots.GetAbilitiesInOverflow()
				local v7, v8

				if #abilitiesInOverflow > InputSlots.GetNumOverflowSlots() then
					if InputSlots.getOverflowScrollIndex() > 0 then
						table.insert(self.managedButtons, self:CreateOverflowScrollButton(false))
					end

					if InputSlots.getOverflowScrollIndex() < #abilitiesInOverflow - InputSlots.GetNumOverflowSlots() then
						table.insert(self.managedButtons, self:CreateOverflowScrollButton(true))
					end

					v7 = v3[1] + 8
					v8 = v4[1] + 10
				else
					v7 = 0
					v8 = 0
				end

				for i = 1, math.min(#abilitiesInOverflow, InputSlots.GetNumOverflowSlots()) do
					local v9 = abilitiesInOverflow[i + InputSlots.getOverflowScrollIndex()]
					local overflowAction = InputSlots.GetOverflowAction(i)

					if not (v9 and overflowAction) then
						continue
					end

					local abilityConfig = v:GetAbilityConfig(v9)
					local portrait = IsPortrait() -- equivalent call inferred; original call site unknown
					local v11

					if portrait then
						v11 = {
							small = { 44, v5[1], v5[2] + v7 + (i - 1) * 52 },
							large = { 56, v6[1], v6[2] + v8 + (i - 1) * 66 }
						}
					else
						v11 = {
							small = { 44, v5[1] + v7 + (i - 1) * 52, v5[2] },
							large = { 56, v6[1] + v8 + (i - 1) * 66, v6[2] }
						}
					end

					table.insert(
						self.managedButtons,
						self:CreateAbilityButton(v9, abilityConfig, overflowAction, v11, true)
					)
				end
			end
		end
	end

	CreateButtons()
	InputSlots.GetSlotMapChangedSignal():Connect(CreateButtons)
	v:GetEnabledChangedSignal():Connect(CreateButtons)
	InputSlots.getScrollIndexChangedEvent():Connect(CreateButtons)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui", 5)

	if playerGui then
		playerGui:GetPropertyChangedSignal("CurrentScreenOrientation"):Connect(CreateButtons)
	end
end

return TouchAbilities