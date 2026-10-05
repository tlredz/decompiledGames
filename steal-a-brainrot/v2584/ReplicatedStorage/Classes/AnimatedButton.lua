local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local SoundController = require(controllers.SoundController)
local packages = ReplicatedStorage.Packages
local Signal = require(packages.Signal)
local Trove = require(packages.Trove)
local AnimatedButton = {}
AnimatedButton.__index = AnimatedButton

function AnimatedButton:Rotate(rotation: number, duration: number)
	local target = self.Target or self.Instance
	local tween = TweenService:Create(target, TweenInfo.new(duration, Enum.EasingStyle.Quint), {
		Rotation = rotation
	})
	tween:Play()
	return tween
end

function AnimatedButton:Expand(p: number, duration: number)
	local target = self.Target or self.Instance
	local uDim = UDim2.new(
		self.DefaultSize.X.Scale * p,
		self.DefaultSize.X.Offset * p,
		self.DefaultSize.Y.Scale * p,
		self.DefaultSize.Y.Offset * p
	)
	local tween = TweenService:Create(target, TweenInfo.new(duration, Enum.EasingStyle.Quint), {
		Size = uDim
	})
	self.SizeTween = tween
	tween.Completed:Once(function()
		if self.SizeTween == tween then
			self.SizeTween = nil
		end
	end)
	tween:Play()
	return tween
end

function AnimatedButton:SetExpandDuration(expandDuration: number)
	self.ExpandDuration = expandDuration
	return self
end

function AnimatedButton:SetExpandModifier(expandModifier: number)
	self.ExpandModifier = expandModifier
	return self
end

function AnimatedButton:Animate(p: number?, p2: number?, p3: number?)
	self.AnimatedRotation = p3 or self.DefaultRotation

	if p then
		self:SetExpandModifier(p)
	end

	if p2 then
		self:SetExpandDuration(p2)
	end

	if self.Animated == true then
		return self
	end

	self.Animated = true
	self.Collector:Add(self.OnMouseEnter:Connect(function(_, _)
		self.Hovered = true
		self:Expand(self.ExpandModifier, self.ExpandDuration)
		self:Rotate(self.AnimatedRotation, self.ExpandDuration)
	end))
	self.Collector:Add(self.OnMouseLeave:Connect(function(_, _)
		self.Hovered = false
		self:Expand(1, self.ExpandDuration)
		self:Rotate(self.DefaultRotation, self.ExpandDuration)
	end))
	self.Collector:Add(self.OnActivated:Connect(function()
		SoundController:PlaySound("Sounds.Sfx.Activated")
		self:Expand(1, 0.1).Completed:Once(function()
			self:Expand(not self.Hovered and 1 or self.ExpandModifier, 0.1)
		end)
	end))
	return self
end

function AnimatedButton.new(instance, target)
	local object = setmetatable({}, AnimatedButton)
	object.Instance = instance
	object.Target = target
	object.Collector = Trove.new()
	object.Animated = false
	object.Hovered = false
	object.ExpandModifier = 1.05
	object.ExpandDuration = 0.2
	object.DefaultSize = target and target.Size or instance.Size
	object.DefaultPosition = target and target.Position or instance.Position
	object.DefaultRotation = target and target.Rotation or instance.Rotation
	object.SizeTween = nil
	object.OnActivated = Signal.new()
	object.Collector:Add(object.OnActivated, "Destroy")
	object.OnMouseEnter = Signal.new()
	object.Collector:Add(object.OnMouseEnter, "Destroy")
	object.OnMouseLeave = Signal.new()
	object.Collector:Add(object.OnMouseLeave, "Destroy")
	local v = target or instance
	object.Collector:Add(v:GetPropertyChangedSignal("Size"):Connect(function()
		if not object.SizeTween then
			object.DefaultSize = v.Size
		end
	end))
	object.Collector:Add(v:GetPropertyChangedSignal("Position"):Connect(function()
		object.DefaultPosition = v.Position
	end))
	object.Collector:Add(object.Instance.Activated:Connect(function(...)
		object.OnActivated:Fire(...)
	end))
	object.Collector:Add(object.Instance.MouseEnter:Connect(function(...)
		object.OnMouseEnter:Fire(...)
	end))
	object.Collector:Add(object.Instance.MouseLeave:Connect(function(...)
		object.OnMouseLeave:Fire(...)
	end))
	return object
end

function AnimatedButton:Destroy(flag: boolean?)
	if self.SizeTween then
		self.SizeTween:Cancel()
		self.SizeTween = nil
	end

	self.Collector:Destroy()

	if flag then
		if self.Target then
			self.Target:Destroy()
		end

		if self.Instance and self.Instance.Parent then
			self.Instance:Destroy()
		end
	else
		local target = self.Target or self.Instance
		target.Size = self.DefaultSize or target.Size
		target.Position = self.DefaultPosition or target.Position
		target.Rotation = self.DefaultRotation or target.Rotation
	end
end

return AnimatedButton