local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local damageIndicatorIcon = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("DamageIndicatorIcon")
local DamageIndicators = {}
DamageIndicators.__index = DamageIndicators

function DamageIndicators.new(fighterInterface)
	local self = setmetatable({}, DamageIndicators)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("DamageIndicators")
	self._current_damage_indicators = {}
	self:_Init()
	return self
end

function DamageIndicators:Create(p)
	local source = p[utf8.char(2)]

	if not source or p[utf8.char(0)] == 0 or not self.FighterInterface:IsActive() then
		return
	end

	for k, _current_damage_indicator in pairs(self._current_damage_indicators) do
		if _current_damage_indicator.Source ~= source then
			continue
		end

		k:Destroy()
		self._current_damage_indicators[k] = nil
	end

	local v2 = typeof(source) == "Instance"
	local v3 = Spring.new(0, 1, 40)
	local v4 = Spring.new(0.5, 1, 40)
	local clone = damageIndicatorIcon:Clone()
	clone.Parent = self.Frame
	BetterDebris:AddItem(clone, 10)
	local position

	if v2 then
		position = source.Position or source
	else
		position = source
	end

	local target = nil

	local function update(p2)
		local vector2 = (position - workspace.CurrentCamera.CFrame.Position) * createVector(1, 0, 1)
		local v5 = workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)
		local vector3 = v5.Magnitude <= 0.01 and createVector(1, 0, 0) or v5.Unit

		if vector2 ~= vector2 or vector2.Magnitude == 0 then
			clone.Visible = false
			return
		end

		clone.Visible = true
		local v6 = math.acos(vector2:Dot(vector3) / vector2.Magnitude)
		local v7 = v3

		if math.sign(vector3:Cross(vector2).Y) == 1 then
			v6 = 6.283185307179586 - v6 or v6
		end

		v7.Target = v6 + 1.5707963267948966
		v4.Target = math.max(0.125, 0.5 / math.max(1, (vector2.Magnitude - 5) / 25))

		if p2 then
			if target then
				local v8 = v3.Target - target

				if v8 > 3.141592653589793 then
					v3.Value += 6.283185307179586
				elseif v8 < -3.141592653589793 then
					v3.Value -= 6.283185307179586
				end
			end
		else
			v4.Value = v4.Target
			v3.Value = v3.Target
		end

		local v8 = Vector2.new(0.5, 0.5) - Vector2.new(math.cos(v3.Value), (math.sin(v3.Value))) * 0.75 / 2
		clone.Position = UDim2.new(v8.X, 0, v8.Y, 0)
		clone.Rotation = math.deg(v3.Value - 1.5707963267948966)
		clone.Size = UDim2.new(v4.Value, 0, v4.Value, 0)
		target = v3.Target
	end

	self._current_damage_indicators[clone] = {
		Source = source,
		Update = update
	}
	update(nil)
	wait(5)
	Utility:RenderstepForLoop(0, 100, 4, function(p2)
		clone.ImageTransparency = (p2 / 100) ^ 4
	end)
	clone:Destroy()
	self._current_damage_indicators[clone] = nil
end

function DamageIndicators:Update(p2, _)
	for _, _current_damage_indicator in pairs(self._current_damage_indicators) do
		pcall(_current_damage_indicator.Update, p2)
	end
end

function DamageIndicators:Clear()
	for k in pairs(self._current_damage_indicators) do
		k:Destroy()
	end

	self._current_damage_indicators = {}
end

function DamageIndicators:Destroy()
	self:Clear()
end

function DamageIndicators:_Init() end

return DamageIndicators