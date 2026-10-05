local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardMoveUpButton"
})
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

	if not currentSelectedPropEditable then
		return
	end

	if currentSelectedPropEditable.Instance:GetAttribute("PropNoMove") then
		self.Instance.Visible = false
		return
	end

	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	local v2 = false
	local v3 = false
	local Y = nil
	local Y2 = nil
	local Y3 = nil
	local heartbeatConnection = nil
	local v4 = nil
	local v5 = {}
	local v6 = nil
	local size = instance.Size

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getInputPosition()
		if v6 == nil then
			return UserInputService:GetMouseLocation()
		end

		return Vector2.new(v6.Position.X, v6.Position.Y)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getPlayerPosition()
		local character = localPlayer.Character

		if not character then
			return nil
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			return humanoidRootPart.Position
		end

		return nil
	end

	local function clampToPlayerDistance(vector: Vector3)
		local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown

		if not playerPosition then
			return vector
		end

		if (vector - playerPosition).Magnitude > 100 then
			return playerPosition + (vector - playerPosition).Unit * 100
		end

		return vector
	end

	local function animateButtonSize(p2: number)
		if v4 then
			v4:Cancel()
			v4 = nil
		end

		local uDim = UDim2.new(size.X.Scale * p2, size.X.Offset * p2, size.Y.Scale * p2, size.Y.Offset * p2)
		local tween = TweenService:Create(
			instance,
			TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		)
		v4 = tween
		tween:Play()
	end

	local function hideSiblingButtons()
		local parent = instance.Parent

		if not parent then
			return
		end

		v5 = {}

		for _, guiObject in parent:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject ~= instance and guiObject.Visible) then
				continue
			end

			v5[guiObject] = true
			guiObject.Visible = false
		end
	end

	local function showSiblingButtons()
		for k, _ in pairs(v5) do
			if k and k.Parent then
				k.Visible = true
			end
		end

		v5 = {}
	end

	local function stopDragging()
		if not v2 then
			return
		end

		v2 = false
		v3 = false
		Y = nil
		Y2 = nil
		Y3 = nil
		v6 = nil
		animateButtonSize(1)
		showSiblingButtons()

		if heartbeatConnection then
			self._Janitor:Remove(heartbeatConnection)
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable2 then
			local v7, v8 = currentSelectedPropEditable2:SetCurrentCFrame("MoveY")

			if not v7 then
				warn(string.format("[PropsBillboardMoveUpButton] Failed to set CFrame: %s", v8))
			end

			currentSelectedPropEditable2:EndPreview()
		end
	end

	self._Janitor:Add(instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch and v6 == nil then
			v6 = input
		end
	end))
	self._Janitor:Add(instance.MouseButton1Down:Connect(function()
		local currentSelectedPropEditable2 = PropEditable.GetCurrentSelectedPropEditable()

		if not currentSelectedPropEditable2 then
			return
		end

		local instance2 = currentSelectedPropEditable2.Instance

		if not instance2.PrimaryPart then
			return
		end

		v2 = true
		currentSelectedPropEditable2:BeginPreview()
		Y = instance2:GetPivot().Position.Y
		local lastInputType = UserInputService:GetLastInputType()
		v3 = string.match(tostring(lastInputType), "Gamepad") ~= nil

		if v3 then
			Y2 = nil
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				Y3 = currentCamera.CFrame.LookVector.Y
			end
		else
			local inputPosition = getInputPosition() -- equivalent call inferred; original call site unknown
			Y2 = inputPosition.Y
			Y3 = nil
		end

		hideSiblingButtons()
		animateButtonSize(0.7)
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not v2 then
				return
			end

			local currentSelectedPropEditable3 = PropEditable.GetCurrentSelectedPropEditable()

			if not currentSelectedPropEditable3 then
				stopDragging()
				return
			end

			local instance3 = currentSelectedPropEditable3.Instance

			if not (instance3.PrimaryPart and Y) then
				return
			end

			local v7

			if v3 then
				local currentCamera = workspace.CurrentCamera

				if currentCamera and Y3 then
					local v8 = currentCamera.CFrame.LookVector.Y - Y3
					v7 = Y + v8 * 20
				else
					return
				end
			else
				if not Y2 then
					return
				end

				local inputPosition = getInputPosition() -- equivalent call inferred; original call site unknown
				local Y4 = inputPosition.Y
				local v8 = (Y2 - Y4) * 0.05
				v7 = Y + v8
			end

			local position = instance3:GetPivot().Position
			local vector = Vector3.new(position.X, v7, position.Z)
			local playerPosition = getPlayerPosition() -- equivalent call inferred; original call site unknown

			if playerPosition and (vector - playerPosition).Magnitude > 100 then
				vector = playerPosition + (vector - playerPosition).Unit * 100
			end

			local pivot = instance3:GetPivot()
			local v8 = pivot - pivot.Position
			currentSelectedPropEditable3:PreviewCFrame(CFrame.new(vector) * v8)
		end)

		if heartbeatConnection then
			self._Janitor:Add(heartbeatConnection)
		end
	end))
	self._Janitor:Add(instance.MouseButton1Up:Connect(function()
		stopDragging()
	end))
	self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, _)
		if not v2 then
			return
		end

		if input == v6 then
			stopDragging()
			return
		end

		if v6 ~= nil then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Gamepad1 and (input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.ButtonR2) then
			stopDragging()
		end
	end))
end

function v:Stop()
	local instance = self.Instance

	if instance and instance.Parent then
		for _, guiObject in instance.Parent:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject ~= instance then
				guiObject.Visible = true
			end
		end
	end

	self._Janitor:Destroy()
end

return v