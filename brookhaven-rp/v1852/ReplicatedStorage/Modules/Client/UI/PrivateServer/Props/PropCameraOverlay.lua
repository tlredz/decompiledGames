local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local v = Component.new({
	Tag = "PropCameraOverlay"
})

function v:Construct()
	self._janitor = Janitor.new()
	self._sessionJanitor = nil
	self._props = {}
	self._index = 1
	self._yaw = 0
	self._pitch = 0
	self._distance = 5
	self._targetPosition = createVector(0, 0, 0)
	self._highlight = nil
end

function v:Start()
	local panelContext = PanelController.GetPanelContextByInstance(self.Instance)
	self._panel = PanelController.WaitForPanel(panelContext.Name, self.Instance.Name)
	self._panel:RegisterListener(self, self._panel.Events.Opening, function()
		self:_OnOpening()
	end)

	if self._panel:IsOpen() then
		self:_OnOpening()
	end

	self._panel:RegisterListener(self, self._panel.Events.Closing, function()
		self:_OnClosing()
	end)
end

function v:_OnOpening()
	self._sessionJanitor = self._janitor:Add(Janitor.new(), nil, "session")
	local instance = self.Instance
	local picks = instance.Frame.Picks
	local frame = instance.Frame.Frame
	self._sessionJanitor:Add(picks.Delete.Activated:Connect(function()
		self:_DeleteCurrent()
	end))
	self._sessionJanitor:Add(frame.Left.Activated:Connect(function()
		self:_Navigate(-1)
	end))
	self._sessionJanitor:Add(frame.Right.Activated:Connect(function()
		self:_Navigate(1)
	end))
	local v2 = nil
	local vector2 = Vector2.new(0, 0)
	local flag = false
	self._sessionJanitor:Add(instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v2 = input
			vector2 = input.Position
		elseif input.UserInputType == Enum.UserInputType.Touch and v2 == nil then
			v2 = input
			vector2 = input.Position
		end
	end))
	self._sessionJanitor:Add(UserInputService.InputChanged:Connect(function(input)
		if flag then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement and v2 and v2.UserInputType == Enum.UserInputType.MouseButton1 then
			local v3 = input.Position - vector2
			vector2 = input.Position
			self._yaw -= v3.X * 0.01
			self._pitch = math.clamp(self._pitch - v3.Y * 0.01, -1.0471975511965976, 1.0471975511965976)
		elseif input.UserInputType == Enum.UserInputType.Touch and input == v2 then
			local v3 = input.Position - vector2
			vector2 = input.Position
			self._yaw -= v3.X * 0.01
			self._pitch = math.clamp(self._pitch - v3.Y * 0.01, -1.0471975511965976, 1.0471975511965976)
		end
	end))
	self._sessionJanitor:Add(UserInputService.InputEnded:Connect(function(input)
		if input == v2 then
			v2 = nil
		end
	end))
	self._sessionJanitor:Add(UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self._distance = math.clamp(self._distance - input.Position.Z * 3, 5, 200)
		end
	end))
	self._sessionJanitor:Add(UserInputService.TouchPinch:Connect(function(_, lastPinchScale: number, _: number, p)
		if p == Enum.UserInputState.Begin then
			flag = true
			self._lastPinchScale = 1
		elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			flag = false

			if v2 and v2.UserInputType == Enum.UserInputType.Touch then
				vector2 = v2.Position
			end
		else
			if p ~= Enum.UserInputState.Change then
				return
			end

			local v3 = lastPinchScale - (self._lastPinchScale or 1)
			self._lastPinchScale = lastPinchScale
			self._distance = math.clamp(self._distance - v3 * self._distance * 0.5, 5, 200)
		end
	end))
	self._sessionJanitor:Add(RunService.RenderStepped:Connect(function()
		if not self.Instance.Visible then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		currentCamera.CFrame = CFrame.new(self._targetPosition) * CFrame.Angles(0, self._yaw, 0) * CFrame.Angles(
			self._pitch,
			0,
			0
		) * CFrame.new(0, 0, self._distance)
	end))
	self:_FocusProp()
end

function v:_OnClosing()
	self:_RemoveHighlight()

	if self._sessionJanitor then
		self._janitor:Remove("session")
		self._sessionJanitor = nil
	end

	CameraController.SetDefaultCamera()
end

function v:SetProps(props, p: number)
	self._props = props
	self._index = p
	self._yaw = 0
	self._pitch = 0
	self:_FocusProp()
end

function v:_OpenReturnPanel()
	local returnPanel = self.Instance:GetAttribute("ReturnPanel")
	PanelController.OpenPanelByContext("MainGUIHandler", returnPanel)
end

function v:UpdateProps(props)
	local index = table.find(props, self._props[self._index])

	if index ~= nil then
		self._index = index
	end

	self._props = props

	if #props == 0 then
		self:_OpenReturnPanel()
		return
	end

	if self._index > #props then
		self._index = #props
	end

	self:_FocusProp()
end

function v:_RemoveHighlight()
	if self._highlight then
		self._highlight:Destroy()
		self._highlight = nil
	end
end

function v:_HighlightProp(parent)
	self:_RemoveHighlight()
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromHex("#00aaff")
	highlight.OutlineColor = Color3.fromHex("#00aaff")
	highlight.OutlineTransparency = 0.3
	highlight.FillTransparency = 1
	highlight.Parent = parent
	self._highlight = highlight
end

function v:_FocusProp()
	local _prop = self._props[self._index]

	if not (_prop and _prop.PrimaryPart) then
		self:_RemoveHighlight()
		return
	end

	self:_HighlightProp(_prop)
	local boundingBox, v2 = _prop:GetBoundingBox()
	self._targetPosition = boundingBox.Position
	self._distance = math.clamp(v2.Magnitude * 1.25, 5, 200)
	self._yaw = 0
	self._pitch = 0
end

function v:_Navigate(p: number)
	if #self._props == 0 then
		self:_OpenReturnPanel()
		return
	end

	self._index = (self._index - 1 + p) % #self._props + 1

	if self._index < 1 then
		self._index += #self._props
	end

	self:_FocusProp()
end

function v:_DeleteCurrent()
	local _prop = self._props[self._index]

	if not _prop then
		return
	end

	Remotes.fireServer(self.Instance:GetAttribute("PropDeleteRemote"), _prop)
end

function v:Stop()
	self:_RemoveHighlight()
	self._panel:UnregisterListener(self, self._panel.Events.Opening)
	self._panel:UnregisterListener(self, self._panel.Events.Closing)
	self._janitor:Destroy()
end

return v