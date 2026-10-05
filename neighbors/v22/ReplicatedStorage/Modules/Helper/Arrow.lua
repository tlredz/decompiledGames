local Arrow = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Janitor = require(ReplicatedStorage.Modules.Janitor)
local UI = require(ReplicatedStorage.Modules.UI)
local localPlayer = Players.LocalPlayer

function Arrow.new(target)
	local object = setmetatable({}, {
		__index = Arrow
	})
	object.Janitor = Janitor.new()
	object.Target = target
	object.Offset = Vector2.new(-5, 0)
	object.Arrow = script.Arrow:Clone()
	object.Arrow.Visible = false
	object.Arrow.Parent = localPlayer.PlayerGui.HelperUI
	local target2 = object.Target

	while true do
		if target2:IsA("ScreenGui") then
			object.Janitor:Add(target2:GetPropertyChangedSignal("Enabled"):Connect(function()
				object:UpdateVisibility()
			end))
		else
			object.Janitor:Add(target2:GetPropertyChangedSignal("Visible"):Connect(function()
				object:UpdateVisibility()
			end))
		end

		target2 = target2:FindFirstAncestorWhichIsA("GuiObject") or target2:FindFirstAncestorWhichIsA("ScreenGui")

		if target2 then
			continue
		end

		object.Enabled = false
		object.Visible = false
		object:SetEnabled(true)
		object:SetScale(1)
		object.Janitor:LinkToInstances(object.Arrow, target)
		object:UpdateVisibility()
		return object
	end
end

function Arrow:SetOffset(offset: Vector2)
	self.Offset = offset
end

function Arrow:SetScale(p2: number)
	local v = p2 * 0.025 * (UserInputService.TouchEnabled and 1.5 or 1)
	self.Arrow.Size = UDim2.fromScale(v, 1)
end

function Arrow:SetEnabled(enabled: boolean)
	if self.Enabled == enabled then
		return
	end

	self.Enabled = enabled

	if self.Enabled then
		self.Janitor:Add(RunService.Heartbeat:Connect(function()
			return self:Update()
		end), nil, "Update")
		return
	end

	self.Janitor:Remove("Update")
	task.defer(function()
		self.Arrow.Visible = false
	end)
end

function Arrow:UpdateVisibility()
	self.Visible = UI:IsGuiObjectVisible(self.Target)
end

function Arrow:Update()
	local absolutePosition = self.Target.AbsolutePosition
	local absoluteSize = self.Target.AbsoluteSize
	local absoluteSize2 = self.Arrow.AbsoluteSize
	local offset = self.Offset

	if offset.X > 0 then
		offset += Vector2.new(absoluteSize.X * 0.5 + absoluteSize2.X * 0.5, 0)
	elseif offset.X < 0 then
		offset -= Vector2.new(absoluteSize.X * 0.5 + absoluteSize2.X * 0.5, 0)
	end

	if offset.Y > 0 then
		offset += Vector2.new(0, absoluteSize.Y * 0.5 + absoluteSize2.Y * 0.5)
	elseif offset.Y < 0 then
		offset -= Vector2.new(0, absoluteSize.Y * 0.5 + absoluteSize2.Y * 0.5)
	end

	local v = absolutePosition + absoluteSize * 0.5 + offset
	local v2 = absolutePosition + absoluteSize * 0.5 - v
	local rotation = math.deg((math.atan2(v2.Y, v2.X)))
	self.Arrow.Icon.Position = UDim2.new(0.5 - math.sin(os.clock() * 5) * 0.06, 0, 0.5, 0)
	self.Arrow.Position = UDim2.new(0, v.X, 0, v.Y)
	self.Arrow.Rotation = rotation
	self.Arrow.Visible = self.Visible
end

function Arrow:Destroy()
	self.Arrow:Destroy()
end

return Arrow