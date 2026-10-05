local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local pages = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("Pages")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.BUTTON_BACKGROUND_TRANSPARENCY = 0.08
	self.BUTTON_BACKGROUND_COLOR = Color3.fromRGB(18, 18, 21)
	self.BUTTON_ICON_COLOR = Color3.fromRGB(247, 247, 248)
	self.PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.MainGui = self.PlayerGui:WaitForChild("MainGui")
	self:_Init()
	return self
end

function class:GetMouseLocation()
	return UserInputService:GetMouseLocation() - Vector2.new(0, GuiService.TopbarInset.Height)
end

function class.GetMouseLocationCentered(_)
	return workspace.CurrentCamera.ViewportSize / 2 - Vector2.new(0, GuiService.TopbarInset.Height)
end

function class.ScreenPointToPosition(p, p2, p3)
	local v = p3 or p.MainGui.AbsolutePosition
	return Vector2.new(p2.X - v.X, p2.Y - v.Y)
end

function class:IsWithinBounds(p, p2, p3, p4)
	return p3.X <= p and p <= p3.X + p4.X and p3.Y <= p2 and p2 <= p3.Y + p4.Y
end

function class:IsMouseWithinBounds(p, p2)
	local mouseLocation = self:GetMouseLocation()
	return self:IsWithinBounds(mouseLocation.X, mouseLocation.Y, p, p2)
end

function class.GetTo(p, ...)
	return Utility:WaitForChild(p.MainGui, ...)
end

function class.GetPage(_, childName)
	return pages:WaitForChild(childName)
end

function class.ScrollingTextLabel(p, instance, instance2, instance3)
	local v = nil
	local v2 = 0
	local count = 0
	local check_tween

	check_tween = function(p2)
		task.defer(function()
			if tick() < v2 then
				return
			end

			if not instance:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
				v = nil
				return
			end

			local v3 = instance2.TextBounds.X - instance.AbsoluteSize.X

			if v3 <= 0 or v and math.abs(v3 - v) < 0.1 then
				return
			end

			count += 1
			local v4 = count
			local v5 = v3 / p.MainGui.AbsoluteSize.X * 50
			local uDim = UDim2.new(0, 0, 0.5, 0)
			local uDim2 = UDim2.new(0, -v3, 0.5, 0)
			v2 = tick() + 1
			v = v3
			instance2.Position = p2 and uDim2 or uDim

			if p2 then
				uDim2 = uDim or uDim2
			end

			instance2:TweenPosition(uDim2, "InOut", "Linear", v5, true, function()
				if count ~= v4 then
					return
				end

				v = nil
				task.delay(1, check_tween, not p2)
			end)
		end)
	end

	instance.AncestryChanged:Connect(check_tween)
	instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(check_tween)
	instance2:GetPropertyChangedSignal("TextBounds"):Connect(check_tween)
	local v3 = nil
	task.defer(function()
		if tick() < v2 then
			return
		end

		if not instance:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
			v = nil
			return
		end

		local v4 = instance2.TextBounds.X - instance.AbsoluteSize.X

		if v4 <= 0 or v and math.abs(v4 - v) < 0.1 then
			return
		end

		count += 1
		local v5 = count
		local v6 = v4 / p.MainGui.AbsoluteSize.X * 50
		local uDim = UDim2.new(0, 0, 0.5, 0)
		local uDim2 = UDim2.new(0, -v4, 0.5, 0)
		v2 = tick() + 1
		v = v4
		instance2.Position = v3 and uDim2 or uDim

		if v3 then
			uDim2 = uDim or uDim2
		end

		instance2:TweenPosition(uDim2, "InOut", "Linear", v6, true, function()
			if count ~= v5 then
				return
			end

			v = nil
			task.delay(1, check_tween, not v3)
		end)
	end)

	if instance3 then
		local function update()
			local v4 = not instance3.Visible and 0 or instance3.TextBounds.X
			local v5 = not v4 and 0 or instance3.AbsoluteSize.Y * 0.5 + instance.AbsolutePosition.X
			instance.Size = UDim2.new(
				0,
				instance3.AbsolutePosition.X + instance3.AbsoluteSize.X - v4 - v5,
				instance.Size.Y.Scale,
				instance.Size.Y.Offset
			)
			v2 = 0
			local v6 = nil
			task.defer(function()
				if tick() < v2 then
					return
				end

				if not instance:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
					v = nil
					return
				end

				local v7 = instance2.TextBounds.X - instance.AbsoluteSize.X

				if v7 <= 0 or v and math.abs(v7 - v) < 0.1 then
					return
				end

				count += 1
				local v8 = count
				local v9 = v7 / p.MainGui.AbsoluteSize.X * 50
				local uDim = UDim2.new(0, 0, 0.5, 0)
				local uDim2 = UDim2.new(0, -v7, 0.5, 0)
				v2 = tick() + 1
				v = v7
				instance2.Position = v6 and uDim2 or uDim

				if v6 then
					uDim2 = uDim or uDim2
				end

				instance2:TweenPosition(uDim2, "InOut", "Linear", v9, true, function()
					if count ~= v8 then
						return
					end

					v = nil
					task.delay(1, check_tween, not v6)
				end)
			end)
		end

		instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
		instance3:GetPropertyChangedSignal("AbsolutePosition"):Connect(update)
		instance3:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		instance3:GetPropertyChangedSignal("TextBounds"):Connect(update)
		instance3:GetPropertyChangedSignal("Visible"):Connect(update)
		update()
	end
end

function class:_Init() end

return class._new()