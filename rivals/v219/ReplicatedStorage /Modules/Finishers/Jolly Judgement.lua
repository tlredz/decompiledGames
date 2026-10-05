local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("HttpService")
game:GetService("Lighting")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local FighterController = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(p)
	Ragdoll.PlayClient(self, p)

	if not p then
		local fighter = FighterController:GetFighter(self._eliminator)

		if not (fighter and fighter:Get("IsSpectating")) then
			return
		end
	end

	self:CreateSound("rbxassetid://127879822444105", 1.25, 0.95 + 0.1 * math.random(), script, true, 10)
	self:CreateSound("rbxassetid://118355855043527", 0.875, 0.98 + 0.04 * math.random(), script, true, 10)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local part = Instance.new("Part")
	part.CFrame = CFrame.new(rootPart.Position)
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Anchored = true
	part.Parent = rootPart
	table.insert(self._destroy_these, part)
	local v = math.random() < 0.5
	local clone = script.BillboardGui:Clone()
	clone.Value.Text = v and "NAUGHTY." or "NICE!"
	clone.Value.TextColor3 = v and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(100, 255, 50)
	clone.Value.UIStroke.Color = v and Color3.fromRGB(127, 25, 25) or Color3.fromRGB(50, 127, 25)
	clone.Value.UIStroke.Transparency = 0
	clone.Parent = part
	table.insert(self._destroy_these, clone)
	local value = clone.Value
	local v2 = v and 1 or -1
	Utility:RenderstepForLoop(0, 100, 3, function(p2)
		local v3 = p2 / 100
		local value2 = TweenService:GetValue(v3, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local value3 = TweenService:GetValue(v3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local v4 = 1 - 0.5 * value3
		value.Position = UDim2.new(0.5 + 0.125 * value2 * v2, 0, 0.5 + 0.125 * value3, 0)
		value.Size = UDim2.new(1 * v4, 0, 0.075 * v4, 0)
		value.Rotation = v3 ^ 4 * 260 * v2
	end)
	clone:Destroy()
end

function object:_Init() end

return object