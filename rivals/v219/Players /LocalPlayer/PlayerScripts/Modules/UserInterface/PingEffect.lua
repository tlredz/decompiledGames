local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local pingEffect = Players.LocalPlayer.PlayerScripts.Assets.Misc.PingEffect
local pingSlot = Players.LocalPlayer.PlayerScripts.UserInterface.PingSlot
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "PingEffect")
	self._ping_objects = {}
	self._ping_slots = {}
	self._is_looping = false
	self:_Init()
	return self
end

function class:Play(position, instance)
	if (position - workspace.CurrentCamera.CFrame.Position).Magnitude > CONSTANTS.RENDER_DISTANCE or not PlayerDataController:GetSetting("Pings") then
		return
	end

	if self._ping_objects[instance] then
		self._ping_objects[instance]:Destroy()
	end

	local teamColor = DuelLibrary:GetTeamColor(instance:GetAttribute("TeamID"), Color3.fromRGB(255, 255, 255))
	local clone = pingEffect:Clone()
	clone.CFrame = CFrame.new(position)
	clone.OnTop.Picture.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, instance.UserId)
	clone.OnTop.Shadow.ImageColor3 = teamColor
	clone.OnTop.Ping.ImageColor3 = teamColor
	clone.Bright.Shadow.ImageColor3 = teamColor
	clone.Bright.Ping.ImageColor3 = teamColor
	clone.Parent = workspace
	BetterDebris:AddItem(clone, 8)
	self._ping_objects[instance] = clone
	clone.OnTop.Picture:TweenPosition(UDim2.new(0.5, 0, 0.25, 0), "Out", "Quint", 0.25, true)
	clone.OnTop.Ping:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
	clone.Bright.Ping:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
	Utility:CreateSound("rbxassetid://17270018886", 1, 1.5, clone, true, 5)
	clone.Destroying:Connect(function()
		if self._ping_objects[instance] == clone then
			self._ping_objects[instance] = nil
		end

		if self._ping_slots[clone] then
			self._ping_slots[clone]:Destroy()
			self._ping_slots[clone] = nil
		end
	end)
	local clone2 = pingSlot:Clone()
	clone2.Picture.Image = clone.OnTop.Picture.Image
	clone2.Ping.ImageColor3 = teamColor
	clone2.Parent = self.Frame
	self._ping_slots[clone] = clone2
	task.spawn(self._StartLoop, self)
end

function class:_StartLoop()
	if self._is_looping then
		return
	end

	self._is_looping = true

	while true do
		local flag = true

		for k, _ping_slot in pairs(self._ping_slots) do
			flag = false
			local v = Vector2.one * 40 + _ping_slot.AbsoluteSize / 2
			local v2 = self.Frame.AbsoluteSize - Vector2.one * 40 - _ping_slot.AbsoluteSize / 2
			local worldToScreenPoint, v3 = workspace.CurrentCamera:WorldToScreenPoint(k.Position)
			local screenPointToPosition = UILibrary:ScreenPointToPosition(
				Vector2.new(worldToScreenPoint.X, worldToScreenPoint.Y),
				self.Frame.AbsolutePosition
			)
			local vector = Vector2.new(
				math.clamp(screenPointToPosition.X, v.X, v2.X),
				(math.clamp(screenPointToPosition.Y, v.Y, v2.Y))
			)

			if v3 or worldToScreenPoint.Z < 0 then
				_ping_slot.Visible = not v3 and _ping_slot.Visible
			else
				local rotation = 360 - math.deg((math.atan2(
					screenPointToPosition.X - vector.X,
					screenPointToPosition.Y - vector.Y
				)))
				_ping_slot.Rotation = rotation
				_ping_slot.Picture.Rotation = -rotation
				_ping_slot.Position = UDim2.new(0, vector.X, 0, vector.Y)
				_ping_slot.Visible = true
			end
		end

		if flag then
			self._is_looping = false
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

function class:_Init() end

return class._new()