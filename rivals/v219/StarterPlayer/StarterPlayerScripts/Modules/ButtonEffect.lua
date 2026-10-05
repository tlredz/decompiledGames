local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("HapticService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:ClickSound()
	Utility:CreateSound("rbxassetid://177266782", 0.5, 1, script, true, 4)
end

function class:Add(instance, p, p2)
	local v

	if typeof(instance) == "Instance" then
		v = instance:IsA("ImageButton") or instance:IsA("TextButton") or instance:IsA("ClickDetector")
	else
		v = false
	end

	assert(v, "Argument 1 invalid, expected an ImageButton or TextButton or ClickDetector, got " .. tostring(instance))
	assert(not p or typeof(p) == "boolean", "Argument 2 invalid, expected a boolean or nil, got " .. tostring(p))
	assert(not p2 or typeof(p2) == "table", "Argument 3 invalid, expected a table or nil, got " .. tostring(p2))
	local clone = p2 and table.clone(p2) or {}
	clone.Speed = clone.Speed or 1
	clone.PressRatio = clone.PressRatio or 0.875
	clone.HoverRatio = clone.HoverRatio or 1.125
	clone.ReleaseRatio = clone.ReleaseRatio or 1.125
	clone.TargetElement = clone.TargetElement or instance
	clone.OnRelease = clone.OnRelease or nil
	clone.OnHover = clone.OnHover or nil
	clone.DontReposition = clone.DontReposition or nil
	local targetElement = clone.TargetElement

	if instance:IsA("ClickDetector") then
		instance.MouseClick:Connect(function()
			self:ClickSound()
		end)
		return
	end

	local size2 = nil
	local size3 = nil
	local size4 = nil
	local size5 = nil

	local function update_original_size(size)
		size2 = size
		size3 = typeof(clone.PressRatio) == "UDim2" and size2 + clone.PressRatio or UDim2.new(
			size2.X.Scale * clone.PressRatio,
			size2.X.Offset * clone.PressRatio,
			size2.Y.Scale * clone.PressRatio,
			size2.Y.Offset * clone.PressRatio
		)
		size4 = typeof(clone.HoverRatio) == "UDim2" and size2 + clone.HoverRatio or UDim2.new(
			size2.X.Scale * clone.HoverRatio,
			size2.X.Offset * clone.HoverRatio,
			size2.Y.Scale * clone.HoverRatio,
			size2.Y.Offset * clone.HoverRatio
		)
		size5 = typeof(clone.ReleaseRatio) == "UDim2" and size2 + clone.ReleaseRatio or UDim2.new(
			size2.X.Scale * clone.ReleaseRatio,
			size2.X.Offset * clone.ReleaseRatio,
			size2.Y.Scale * clone.ReleaseRatio,
			size2.Y.Offset * clone.ReleaseRatio
		)
	end

	update_original_size(targetElement.Size)
	local v6 = false

	local function release()
		v6 = false

		if not p then
			if targetElement:IsDescendantOf(workspace) or targetElement:IsDescendantOf(Players) then
				targetElement.Size = size5
				targetElement:TweenSize(size2, "Out", "Back", 0.25, true)
			else
				targetElement.Size = size2
			end
		end

		if clone.OnRelease then
			clone.OnRelease()
		end
	end

	instance.MouseButton1Up:Connect(release)
	instance.MouseLeave:Connect(release)
	instance.SelectionLost:Connect(release)

	local function hover()
		if not p then
			if targetElement:IsDescendantOf(workspace) or targetElement:IsDescendantOf(Players) then
				targetElement:TweenSize(size4, "Out", "Quint", 0.25, true)
			else
				targetElement.Size = size4
			end
		end

		if clone.OnHover then
			clone.OnHover()
		end
	end

	instance.MouseEnter:Connect(hover)
	instance.SelectionGained:Connect(hover)

	local function press()
		v6 = true

		if not p then
			if targetElement:IsDescendantOf(workspace) or targetElement:IsDescendantOf(Players) then
				targetElement:TweenSize(size3, "Out", "Quint", 0.25, true)
			else
				targetElement.Size = size3
			end
		end

		self:ClickSound()
	end

	instance.MouseButton1Down:Connect(press)

	if not (p or clone.DontReposition) then
		local v7 = 0.5 - targetElement.AnchorPoint.X
		local v8 = 0.5 - targetElement.AnchorPoint.Y
		targetElement.Position += UDim2.new(
			targetElement.Size.X.Scale * v7,
			targetElement.Size.X.Offset * v7,
			targetElement.Size.Y.Scale * v8,
			targetElement.Size.Y.Offset * v8
		)
		targetElement.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	return {
		UpdateOriginalSize = update_original_size
	}
end

function class:_Init() end

return class._new()