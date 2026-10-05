local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local GamepadService = game:GetService("GamepadService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local v = Component.new({
	Tag = "PropsBillboardRelativePositionSlider"
})
local color = Color3.fromRGB(62, 63, 63)

local function applyGrayedOutAppearance(guiObject)
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.ImageColor3 = color
	end

	guiObject.BackgroundColor3 = color
	local icon = guiObject:FindFirstChild("Icon")

	if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
		icon.ImageColor3 = color
	end
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function scaleToOffset(p: number)
	if p <= 1 then
		return ((p - 0.5) / 0.5 - 1) * 0.3
	end

	return (p - 1) / 1.5 * 0.3
end

local function offsetToScale(value: number)
	local v2 = math.clamp(value, -0.3, 0.3)

	if v2 <= 0 then
		return (v2 + 0.3) / 0.3 * 0.5 + 0.5
	end

	return v2 / 0.3 * 1.5 + 1
end

local function getModelBaseY(instance)
	local boundingBox, v2 = instance:GetBoundingBox()
	local v3 = v2.X / 2
	local v4 = v2.Y / 2
	local v5 = v2.Z / 2
	local Y = 1e999

	for i = -1, 1, 2 do
		for i2 = -1, 1, 2 do
			for i3 = -1, 1, 2 do
				local position = (boundingBox * CFrame.new(i * v3, i2 * v4, i3 * v5)).Position

				if position.Y < Y then
					Y = position.Y
				end
			end
		end
	end

	return Y
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

	if not currentSelectedPropEditable then
		return
	end

	local instance = self.Instance
	local parent = self.Instance.Parent

	if not (parent and parent:IsA("GuiObject")) then
		return
	end

	if GameUtil.IsPrivateServer() then
		if currentSelectedPropEditable.Instance:GetAttribute("PropNoScale") then
			instance.Enabled = false
			applyGrayedOutAppearance(parent)
			self._Janitor:Add(parent.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					NotificationController.NotifyCenter("This prop cannot be scaled")
				end
			end))
		else
			local dragAxis = instance:GetAttribute("DragAxis") or "Y"

			if dragAxis ~= "X" and dragAxis ~= "Y" then
				warn("PropsBillboardRelativePositionSlider: Invalid DragAxis:", dragAxis)
				return
			end

			local parent2 = parent.Parent

			if not (parent2 and parent2:IsA("GuiObject")) then
				return
			end

			local slider = parent2:FindFirstChild("Slider")

			if not (slider and slider:IsA("GuiObject")) then
				warn("PropsBillboardRelativePositionSlider: missing 'Slider' sibling under", parent2:GetFullName())
				return
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getDragValue()
				local dragUDim2 = instance.DragUDim2

				if dragAxis == "X" then
					return (math.clamp(dragUDim2.X.Scale, -0.6, 0.6))
				end

				return (math.clamp(dragUDim2.Y.Scale, -0.6, 0.6))
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function applySliderOffsetForScale(scale: number)
				local position = slider.Position
				slider.Position = UDim2.new(
					scaleToOffset(scale),
					position.X.Offset,
					position.Y.Scale,
					position.Y.Offset
				)
			end

			local scale = currentSelectedPropEditable.Instance:GetScale()
			local position = slider.Position
			slider.Position = UDim2.new(scaleToOffset(scale), position.X.Offset, position.Y.Scale, position.Y.Offset)
			local v3 = nil
			local v4 = nil
			local v5 = nil
			local gamepadCursorEnabled = false
			self.thumbstickConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function computeTargetScale()
				if v3 == nil or v5 == nil then
					return nil
				end

				local dragValue = getDragValue() -- equivalent call inferred; original call site unknown
				local v6 = dragValue - v5

				if dragAxis == "Y" then
					v6 = -v6
				end

				local v8 = scaleToOffset(v3)
				local v9 = math.clamp(math.clamp(v8 + v6, -0.3, 0.3), -0.3, 0.3)

				if v9 <= 0 then
					return (v9 + 0.3) / 0.3 * 0.5 + 0.5
				end

				return v9 / 0.3 * 1.5 + 1
			end

			local function rebaseDragAtScaleLimit(p: number)
				if v3 == nil or v5 == nil then
					return
				end

				if p <= 0.5 then
					v3 = 0.5
					v5 = getDragValue() -- equivalent call inferred; original call site unknown
				elseif p >= 2.5 then
					v3 = 2.5
					v5 = getDragValue() -- equivalent call inferred; original call site unknown
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function applyDrag()
				local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

				if not (currentSelectedPropEditable2 and v4 ~= nil) then
					return
				end

				local targetScale = computeTargetScale() -- equivalent call inferred; original call site unknown

				if targetScale == nil then
					return
				end

				currentSelectedPropEditable2:PreviewScale(targetScale, v4)

				if v3 ~= nil then
					if v5 == nil then
						return
					end

					if targetScale <= 0.5 then
						v3 = 0.5
						v5 = getDragValue() -- equivalent call inferred; original call site unknown
					elseif targetScale >= 2.5 then
						v3 = 2.5
						v5 = getDragValue() -- equivalent call inferred; original call site unknown
					end
				end
			end

			self._Janitor:Add(instance.DragStart:Connect(function(_)
				gamepadCursorEnabled = GamepadService.GamepadCursorEnabled

				if not (self.Instance and self.Instance.ReferenceUIInstance) then
					return
				end

				local instance2 = currentSelectedPropEditable.Instance

				if not instance2.PrimaryPart then
					return
				end

				instance2.PrimaryPart.Anchored = true
				local scale2 = instance2:GetScale()
				v3 = scale2
				v4 = getModelBaseY(instance2)
				v5 = getDragValue() -- equivalent call inferred; original call site unknown
				applySliderOffsetForScale(scale2) -- equivalent call inferred; original call site unknown
				currentSelectedPropEditable:BeginPreview()
				self.Instance.ReferenceUIInstance.Visible = true
				local parent3 = parent2.Parent

				if parent3 then
					for _, guiObject in parent3:GetChildren() do
						if guiObject:IsA("GuiObject") and guiObject.Name ~= parent2.Name then
							guiObject.Visible = false
						end
					end
				end

				if gamepadCursorEnabled then
					if self.thumbstickConnection then
						self.thumbstickConnection:Disconnect()
						self.thumbstickConnection = nil
					end

					self.thumbstickConnection = UserInputService.InputChanged:Connect(function(input)
						if input.UserInputType ~= Enum.UserInputType.Gamepad1 or input.KeyCode ~= Enum.KeyCode.Thumbstick1 then
							return
						end

						local position2 = input.Position
						local v6 = 0
						local v7 = 0
						local flag = false

						if dragAxis == "X" then
							if math.abs(position2.X) > 0.05 then
								v6 = position2.X * 0.02
								flag = true
							end
						elseif math.abs(position2.Y) > 0.05 then
							v7 = -position2.Y * 0.02
							flag = true
						end

						if flag then
							local dragUDim2 = instance.DragUDim2
							local v8 = math.clamp(dragUDim2.X.Scale + v6, -0.6, 0.6)
							local v9 = math.clamp(dragUDim2.Y.Scale + v7, -0.6, 0.6)
							instance.DragUDim2 = UDim2.fromScale(v8, v9)
							applyDrag() -- equivalent call inferred; original call site unknown
						end
					end)
				end
			end))
			self._Janitor:Add(instance.DragContinue:Connect(function(_)
				if gamepadCursorEnabled then
					return
				end

				applyDrag() -- equivalent call inferred; original call site unknown
			end))
			self._Janitor:Add(instance.DragEnd:Connect(function(_)
				if self.thumbstickConnection then
					self.thumbstickConnection:Disconnect()
					self.thumbstickConnection = nil
				end

				gamepadCursorEnabled = false

				if not (self.Instance and self.Instance.ReferenceUIInstance) then
					return
				end

				self.Instance.ReferenceUIInstance.Visible = false
				local tween = TweenService:Create(
					parent,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{
						Position = UDim2.fromScale(0.5, 0.5)
					}
				)
				tween:Play()
				self._Janitor:Add(tween, "Cancel", "resetTween")
				self._Janitor:Add(tween.Completed:Connect(function()
					instance.DragUDim2 = UDim2.fromScale(0, 0)
					parent.Position = UDim2.fromScale(0.5, 0.5)
				end), "Disconnect", "resetTweenCompleted")
				local parent3 = parent2.Parent

				if parent3 then
					for _, guiObject in parent3:GetChildren() do
						if not guiObject:IsA("GuiObject") or guiObject:GetAttribute("PropNoColor") or not (not guiObject:HasTag("HideOrShowInPrivateServer") or guiObject:GetAttribute("Visible")) then
							continue
						end

						guiObject.Visible = true
					end
				end

				local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

				if currentSelectedPropEditable2 then
					local instance2 = currentSelectedPropEditable2.Instance
					currentSelectedPropEditable2:RestorePrimaryPartAnchorAfterPreview()
					currentSelectedPropEditable2:SetCurrentScale(instance2:GetScale())
					currentSelectedPropEditable2:EndPreview()
				end

				v3 = nil
				v4 = nil
				v5 = nil
			end))
		end
	else
		instance.Enabled = false
		applyGrayedOutAppearance(parent)
		self._Janitor:Add(parent.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				NotificationController.NotifyCenter("Resizing is only available on private servers")
			end
		end))
	end
end

function v:Stop()
	if self.thumbstickConnection then
		self.thumbstickConnection:Disconnect()
		self.thumbstickConnection = nil
	end

	self._Janitor:Destroy()
end

return v