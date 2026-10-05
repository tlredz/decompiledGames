local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local smokeClouds = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("SmokeClouds")
local SmokeCloud = {}
SmokeCloud.__index = SmokeCloud

function SmokeCloud.new(part, _)
	local self = setmetatable({}, SmokeCloud)
	self.Part = part
	self.Name = self.Part.Name
	self.EnvironmentID = self.Part:GetAttribute("EnvironmentID")
	self.Model = nil
	self._destroyed = false
	self._start_spring = Spring.new(0, 0.875, 10)
	self._finish_spring = Spring.new(0, 1, 2)
	self._position_spring = Spring.new(self.Part.Position, 1, 20)
	self._speed = 0.75 + 0.25 * math.random()
	self._spin = 6.283185307179586 * math.random()
	self._last_size = self.Part.Size
	self._idle_sound = nil
	self._idle_sound_original_volume = nil
	self:_Init()
	return self
end

function SmokeCloud:IsDestroyed()
	return self._destroyed
end

function SmokeCloud:Update(p)
	if self:_UpdateCoreLogic() then
		return true
	end

	self._position_spring.Target = self.Part.Position
	self:_StepSpin(p)
	self.Model:PivotTo(CFrame.new(self._position_spring.Value) * CFrame.Angles(0, self._spin, 0))
end

function SmokeCloud:Clear()
	self._finish_spring.Target = 1
	BetterDebris:AddItem(self, 10)
end

function SmokeCloud:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self.Model:Destroy()
end

function SmokeCloud:_CreateIdleSound()
	return Utility:CreateSound("rbxassetid://16540273153", 0.1, 1, nil, true)
end

function SmokeCloud:_StepSpin(p)
	self._spin = (self._spin + self._speed * (1 + 5 * self._start_spring.Velocity) * p) % 6.283185307179586
end

function SmokeCloud:_UpdateCoreLogic()
	if not self._idle_sound then
		self._idle_sound = self:_CreateIdleSound()
		self._idle_sound.Parent = self.Part
		self._idle_sound_original_volume = self._idle_sound.Volume
	end

	self.Model:ScaleTo(self.Part.Size.Y * self._start_spring.Value)

	if not (self._finish_spring.Target > 0) then
		self._idle_sound.Volume = self._start_spring.Value * self._idle_sound_original_volume
		return
	end

	if self._finish_spring.Value >= 1 then
		self:Destroy()
		return true
	end

	for _, descendant in pairs(self.Model:GetDescendants()) do
		descendant.LocalTransparencyModifier = math.clamp(
			self._finish_spring.Value * (descendant:GetAttribute("DecaySpeed") or 1) + (descendant:GetAttribute("DecayOffset") or 0),
			0,
			1
		)
	end

	self._idle_sound.Volume = self._idle_sound_original_volume * math.clamp(1 - self._finish_spring.Value * 2, 0, 1)
end

function SmokeCloud:_AppearSound()
	Utility:CreateSound("rbxassetid://16540273321", 1, 1 + 0.1 * math.random(), self.Part, true, 5)
end

function SmokeCloud:_Setup()
	local template = self.Part:GetAttribute("Template")
	local folder = smokeClouds:FindFirstChild(self.Part.Name)
	self.Model = (folder and folder:IsA("Folder") and (template and folder[template] or folder:GetChildren()[math.random(#folder:GetChildren())]) or folder or smokeClouds.Default):Clone()
	self.Model.Destroying:Connect(function()
		self:Destroy()
	end)
	self._start_spring.Target = 1
end

function SmokeCloud:_Init()
	self.Part:GetPropertyChangedSignal("Size"):Connect(function()
		self:_AppearSound()
		self._start_spring.Value = self._last_size.Magnitude / self.Part.Size.Magnitude
		self._last_size = self.Part.Size
	end)
	self:_Setup()
	self:_AppearSound()
end

return SmokeCloud