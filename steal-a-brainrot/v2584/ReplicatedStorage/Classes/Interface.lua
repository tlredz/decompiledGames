local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local CameraController = require(controllers.CameraController)
local classes = ReplicatedStorage:WaitForChild("Classes")
local AnimatedButton = require(classes.AnimatedButton)
local packages = ReplicatedStorage.Packages
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local Styles = require(script.Styles)
local toggle = controllers.InterfaceController.Toggle
local Interface = {}
Interface.__index = Interface

function Interface.AttachCloseButton(p, p2, p3)
	local v = AnimatedButton.new(p2, p3)
	p.Collector:Add(v, "Destroy")
	v:Animate(nil, nil, 5)
	p.Collector:Add(v.OnActivated:Connect(function()
		toggle:Fire(p.Name, false)
	end))
end

function Interface.GetName(p)
	return p.Name
end

function Interface:GetStyleData()
	return Styles[self:GetStyle()]
end

function Interface:GetStyle()
	return self.Style
end

function Interface:SetStyle(style)
	self.Style = style
end

function Interface:Open(_: boolean?)
	if self.ToggleConnection then
		self.ToggleConnection:Disconnect()
		self.ToggleConnection = nil
	end

	if self.ToggleTween then
		self.ToggleTween:Cancel()
		self.ToggleTween = nil
	end

	self.State = true
	self.Object.Visible = self.State

	if self.Style ~= "Custom" then
		local style = Styles[self.Style]
		local position = self.Defaults.Position
		local size = self.Defaults.Size
		local tweenInfo = TweenInfo.new(style.ToggleTime, style.Style)
		local tween = TweenService:Create(self.Object, tweenInfo, {
			Position = position,
			Size = size
		})
		self.ToggleTween = tween
		tween.Completed:Once(function()
			if self.ToggleTween == tween then
				self.ToggleTween = nil
			end
		end)
		tween:Play()
		CameraController:Blur(style.BlurSize or 0, style.ToggleTime)
		CameraController:Fov(style.Fov or CameraController:GetDefaultFov(), style.ToggleTime)
	end

	self.OnOpen:Fire()
end

function Interface:Close(_: boolean?)
	if self.ToggleConnection then
		self.ToggleConnection:Disconnect()
		self.ToggleConnection = nil
	end

	if self.ToggleTween then
		self.ToggleTween:Cancel()
		self.ToggleTween = nil
	end

	self.State = false

	if self.Style ~= "Custom" then
		local style = Styles[self.Style]
		local position = self.Defaults.Position + style.Position
		local size = self.Defaults.Size + style.Size
		local tweenInfo = TweenInfo.new(style.ToggleTime, style.Style)
		local tween = TweenService:Create(self.Object, tweenInfo, {
			Position = position,
			Size = size
		})
		self.ToggleTween = tween
		self.ToggleConnection = tween.Completed:Connect(function()
			if self.ToggleTween == tween then
				self.ToggleTween = nil
			end

			self.Object.Visible = false
		end)
		tween:Play()
	end

	self.OnClose:Fire()
end

function Interface.Toggle(p, flag: boolean?)
	p[(flag or not p.State) == true and "Open" or "Close"](p)
end

function Interface.IsOpened(p)
	return p.State
end

function Interface:Destroy()
	if self.ToggleConnection then
		self.ToggleConnection:Disconnect()
		self.ToggleConnection = nil
	end

	if self.ToggleTween then
		self.ToggleTween:Cancel()
		self.ToggleTween = nil
	end

	self.Collector:Destroy()
	self.OnOpen:Destroy()
	self.OnClose:Destroy()
	self.Object.Position = self.Defaults.Position
	self.Object.Size = self.Defaults.Size
	self.Object.Visible = false
end

function Interface.new(name: string, object, value)
	local self = setmetatable({}, Interface)
	self.Name = name
	self.Object = object
	self.Defaults = {}
	self.Defaults.Position = self.Object.Position
	self.Defaults.Size = self.Object.Size
	self.State = true
	self.ToggleTween = nil
	self.Style = value or "TopQuint"
	self.OnOpen = Signal.new()
	self.OnClose = Signal.new()
	self.Collector = Trove.new()
	local layerCollector = object:FindFirstAncestorWhichIsA("LayerCollector")

	if not layerCollector then
		return self
	end

	local function updateLayerCollectorVisibility()
		if #layerCollector:GetChildren() == 1 then
			layerCollector.Enabled = object.Visible
		else
			layerCollector.Enabled = true
		end
	end

	self.Collector:Add(layerCollector.ChildAdded:Connect(updateLayerCollectorVisibility))
	self.Collector:Add(layerCollector.ChildRemoved:Connect(updateLayerCollectorVisibility))
	self.Collector:Add(object:GetPropertyChangedSignal("Visible"):Connect(updateLayerCollectorVisibility))
	task.spawn(updateLayerCollectorVisibility)
	return self
end

return Interface