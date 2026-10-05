local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local v = Component.new({
	Tag = "PropsBillboardSlider"
})
local TweenService = game:GetService("TweenService")
local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
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

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

	if not currentSelectedPropEditable then
		return
	end

	local instance = self.Instance

	if (instance:GetAttribute("Behavior") or "Rotate") == "Scale" then
		if GameUtil.IsPrivateServer() then
			if not currentSelectedPropEditable.Instance:GetAttribute("PropNoScale") then
				self:_startScaleBehavior(currentSelectedPropEditable, instance)
				return
			end

			instance.Enabled = false
			local parent = self.Instance.Parent

			if parent and parent:IsA("GuiObject") then
				applyGrayedOutAppearance(parent)
				self._Janitor:Add(parent.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						NotificationController.NotifyCenter("This prop cannot be scaled")
					end
				end))
			end
		else
			instance.Enabled = false
			local parent = self.Instance.Parent

			if parent and parent:IsA("GuiObject") then
				applyGrayedOutAppearance(parent)
				self._Janitor:Add(parent.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						NotificationController.NotifyCenter("Resizing is only available on private servers")
					end
				end))
			end
		end
	elseif currentSelectedPropEditable.Instance:GetAttribute("PropNoRotate") then
		instance.Enabled = false
		local parent = self.Instance.Parent

		if parent and parent:IsA("GuiObject") then
			applyGrayedOutAppearance(parent)
			self._Janitor:Add(parent.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					NotificationController.NotifyCenter("This prop cannot be rotated")
				end
			end))
		end
	else
		local dragAxis = instance:GetAttribute("DragAxis") or "X"

		if dragAxis ~= "X" and dragAxis ~= "Y" and dragAxis ~= "Z" then
			warn("PropsBillboardSlider: Invalid DragAxis attribute:", dragAxis)
			return
		end

		instance.DragUDim2 = UDim2.fromScale(0, 0)
		local v2 = nil
		local v3 = nil
		local gamepadCursorEnabled = false
		self.thumbstickConnection = nil
		local parent = self.Instance.Parent

		if not parent then
			return
		end

		self._Janitor:Add(instance.DragStart:Connect(function(_)
			gamepadCursorEnabled = GamepadService.GamepadCursorEnabled

			if not (self.Instance and self.Instance.ReferenceUIInstance) then
				return
			end

			local instance2 = currentSelectedPropEditable.Instance

			if instance2.PrimaryPart then
				instance2.PrimaryPart.Anchored = true
				v3 = instance2:GetPivot() - instance2:GetPivot().Position
				local dragUDim2 = instance.DragUDim2
				local scale

				if dragAxis == "X" then
					scale = dragUDim2.X.Scale
				elseif dragAxis == "Y" then
					scale = dragUDim2.Y.Scale
				else
					local scale2 = dragUDim2.X.Scale
					scale = dragUDim2.Y.Scale

					if math.abs(dragUDim2.X.Scale) > math.abs(dragUDim2.Y.Scale) then
						scale = scale2 or scale
					end
				end

				v2 = math.clamp(scale, -0.4, 0.4)
			end

			currentSelectedPropEditable:BeginPreview()
			self.Instance.ReferenceUIInstance.Visible = true
			local parent2 = parent.Parent.Parent

			for _, guiObject in parent2:GetChildren() do
				if guiObject:IsA("GuiObject") and guiObject.Name ~= parent.Parent.Name then
					guiObject.Visible = false
				end
			end

			if parent.Parent.Name == "RotateX" then
				parent2.RotateY.Visible = false
			elseif parent.Parent.Name == "RotateY" then
				parent2.RotateX.Visible = false
			end

			if gamepadCursorEnabled then
				if self.thumbstickConnection then
					self.thumbstickConnection:Disconnect()
					self.thumbstickConnection = nil
				end

				self.thumbstickConnection = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
						local position = input.Position
						local flag = false
						local v4 = 0
						local v5 = 0

						if dragAxis == "X" then
							if math.abs(position.X) > 0.05 then
								v4 = -position.X * 0.02
								flag = true
							end
						elseif dragAxis == "Y" then
							if math.abs(position.Y) > 0.05 then
								v5 = position.Y * 0.02
								flag = true
							end
						elseif math.abs(position.X) > 0.05 or math.abs(position.Y) > 0.05 then
							if math.abs(position.X) > math.abs(position.Y) then
								v4 = -position.X * 0.02
							else
								v5 = position.Y * 0.02
							end

							flag = true
						end

						if flag then
							local dragUDim2 = instance.DragUDim2
							local v6 = dragUDim2.X.Scale + v4
							local v7 = dragUDim2.Y.Scale + v5
							local v8 = math.clamp(v6, -0.4, 0.4)
							local v9 = math.clamp(v7, -0.4, 0.4)
							instance.DragUDim2 = UDim2.fromScale(v8, v9)
							parent.Position = UDim2.fromScale(0.5 + v8, 0.5 + v9)
							local dragUDim22 = instance.DragUDim2
							local v10 = dragUDim22.X.Scale * 1
							local v11 = dragUDim22.Y.Scale * 1
							local v12 = math.clamp(v10, -0.4, 0.4)
							local v13 = math.clamp(v11, -0.4, 0.4)

							if dragAxis == "X" then
								v13 = v12
							elseif dragAxis ~= "Y" and math.abs(dragUDim22.X.Scale) > math.abs(dragUDim22.Y.Scale) then
								v13 = v12 or v13
							end

							local v14 = math.clamp(v13, -0.4, 0.4)
							local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

							if currentSelectedPropEditable2 then
								local instance3 = currentSelectedPropEditable2.Instance

								if not instance3.PrimaryPart or (v2 == nil or v3 == nil) then
									return
								end

								instance3.PrimaryPart.Anchored = true
								local pivot = instance3:GetPivot()
								local v15 = (v14 - v2) * 450
								local cframe

								if dragAxis == "X" then
									cframe = CFrame.Angles(0, math.rad(v15), 0)
								elseif dragAxis == "Y" then
									cframe = CFrame.Angles(math.rad(v15), 0, 0)
								else
									cframe = CFrame.Angles(0, 0, -math.rad(v15))
								end

								local v16 = v3 * cframe
								currentSelectedPropEditable2:PreviewCFrame(CFrame.new(pivot.Position) * v16)
							end
						end
					end
				end)
			end
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
			v2 = nil
			v3 = nil
			local parent2 = parent.Parent.Parent

			for _, guiObject in parent2:GetChildren() do
				if not guiObject:IsA("GuiObject") or guiObject:GetAttribute("PropNoColor") or not (not guiObject:HasTag("HideOrShowInPrivateServer") or guiObject:GetAttribute("Visible")) then
					continue
				end

				guiObject.Visible = true
			end

			if parent.Parent.Name == "RotateX" then
				parent2.RotateY.Visible = true
			elseif parent.Parent.Name == "RotateY" then
				parent2.RotateX.Visible = true
			end

			local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

			if currentSelectedPropEditable2 then
				currentSelectedPropEditable2:RestorePrimaryPartAnchorAfterPreview()
				currentSelectedPropEditable2:SetCurrentCFrame(parent.Parent.Name)
				currentSelectedPropEditable2:EndPreview()
			end
		end))
		self._Janitor:Add(instance.DragContinue:Connect(function(_)
			if gamepadCursorEnabled then
				return
			end

			local dragUDim2 = instance.DragUDim2
			local v4 = dragUDim2.X.Scale * 1
			local v5 = dragUDim2.Y.Scale * 1
			local v6 = math.clamp(v4, -0.4, 0.4)
			local v7 = math.clamp(v5, -0.4, 0.4)

			if dragAxis == "X" then
				v7 = v6
			elseif dragAxis ~= "Y" and math.abs(dragUDim2.X.Scale) > math.abs(dragUDim2.Y.Scale) then
				v7 = v6 or v7
			end

			local v8 = math.clamp(v7, -0.4, 0.4)
			local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

			if currentSelectedPropEditable2 then
				local instance2 = currentSelectedPropEditable2.Instance

				if not instance2.PrimaryPart or (v2 == nil or v3 == nil) then
					return
				end

				instance2.PrimaryPart.Anchored = true
				local pivot = instance2:GetPivot()
				local v9 = (v8 - v2) * 450
				local cframe

				if dragAxis == "X" then
					cframe = CFrame.Angles(0, math.rad(v9), 0)
				elseif dragAxis == "Y" then
					cframe = CFrame.Angles(math.rad(v9), 0, 0)
				else
					cframe = CFrame.Angles(0, 0, -math.rad(v9))
				end

				local v10 = v3 * cframe
				currentSelectedPropEditable2:PreviewCFrame(CFrame.new(pivot.Position) * v10)
			end
		end))
	end
end

function v:_startScaleBehavior(object, instance)
	local dragAxis = instance:GetAttribute("DragAxis") or "Y"

	if dragAxis ~= "X" and dragAxis ~= "Y" then
		warn("PropsBillboardSlider: Invalid DragAxis for Scale:", dragAxis)
		return
	end

	instance.DragUDim2 = UDim2.fromScale(0, 0)
	local parent = self.Instance.Parent

	if not parent then
		return
	end

	local scale = nil
	local v2 = nil
	local v3 = nil
	local gamepadCursorEnabled = false
	self.thumbstickConnection = nil

	local function getModelBaseY(instance2)
		local boundingBox, v4 = instance2:GetBoundingBox()
		local v5 = v4.X / 2
		local v6 = v4.Y / 2
		local v7 = v4.Z / 2
		local Y = 1e999

		for i = -1, 1, 2 do
			for i2 = -1, 1, 2 do
				for i3 = -1, 1, 2 do
					local position = (boundingBox * CFrame.new(i * v5, i2 * v6, i3 * v7)).Position

					if position.Y < Y then
						Y = position.Y
					end
				end
			end
		end

		return Y
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getNormalizedValue()
		local dragUDim2 = instance.DragUDim2

		if dragAxis == "X" then
			return (math.clamp(dragUDim2.X.Scale, -0.4, 0.4))
		end

		return (math.clamp(dragUDim2.Y.Scale, -0.4, 0.4))
	end

	local function applyDragScale()
		if scale == nil or v2 == nil or v3 == nil then
			return
		end

		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if not currentSelectedPropEditable then
			return
		end

		local normalizedValue = getNormalizedValue() -- equivalent call inferred; original call site unknown
		local v4 = normalizedValue - v3

		if dragAxis == "Y" then
			v4 = -v4
		end

		currentSelectedPropEditable:PreviewScale(math.clamp(scale * (1 + v4 * 1.5), 0.5, 2.5), v2)
	end

	self._Janitor:Add(instance.DragStart:Connect(function(_)
		gamepadCursorEnabled = GamepadService.GamepadCursorEnabled

		if not (self.Instance and self.Instance.ReferenceUIInstance) then
			return
		end

		local instance2 = object.Instance

		if not instance2.PrimaryPart then
			return
		end

		instance2.PrimaryPart.Anchored = true
		scale = instance2:GetScale()
		v2 = getModelBaseY(instance2)
		v3 = getNormalizedValue() -- equivalent call inferred; original call site unknown
		object:BeginPreview()
		self.Instance.ReferenceUIInstance.Visible = true

		for _, guiObject in parent.Parent.Parent:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= parent.Parent.Name then
				guiObject.Visible = false
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

				local position = input.Position
				local v4 = 0
				local v5 = 0
				local flag = false

				if dragAxis == "X" then
					if math.abs(position.X) > 0.05 then
						v4 = position.X * 0.02
						flag = true
					end
				elseif math.abs(position.Y) > 0.05 then
					v5 = -position.Y * 0.02
					flag = true
				end

				if flag then
					local dragUDim2 = instance.DragUDim2
					local v6 = math.clamp(dragUDim2.X.Scale + v4, -0.4, 0.4)
					local v7 = math.clamp(dragUDim2.Y.Scale + v5, -0.4, 0.4)
					instance.DragUDim2 = UDim2.fromScale(v6, v7)
					parent.Position = UDim2.fromScale(v6 + 0.5, v7 + 0.5)
					applyDragScale()
				end
			end)
		end
	end))
	self._Janitor:Add(instance.DragContinue:Connect(function(_)
		if gamepadCursorEnabled then
			return
		end

		applyDragScale()
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

		for _, guiObject in parent.Parent.Parent:GetChildren() do
			if not guiObject:IsA("GuiObject") or guiObject:GetAttribute("PropNoColor") or not (not guiObject:HasTag("HideOrShowInPrivateServer") or guiObject:GetAttribute("Visible")) then
				continue
			end

			guiObject.Visible = true
		end

		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable then
			local instance2 = currentSelectedPropEditable.Instance
			currentSelectedPropEditable:RestorePrimaryPartAnchorAfterPreview()
			currentSelectedPropEditable:SetCurrentScale(instance2:GetScale())
			currentSelectedPropEditable:EndPreview()
		end

		scale = nil
		v2 = nil
		v3 = nil
	end))
end

function v:Stop()
	if self.thumbstickConnection then
		self.thumbstickConnection:Disconnect()
		self.thumbstickConnection = nil
	end

	self._Janitor:Destroy()
end

return v