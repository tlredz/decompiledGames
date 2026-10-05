local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local audioVisualizerIcon = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("AudioVisualizerIcon")
local v = { "rbxassetid://131616644976154", "rbxassetid://101856596290673", "rbxassetid://78940013186909" }
local AudioVisualizers = {}
AudioVisualizers.__index = AudioVisualizers

function AudioVisualizers.new(fighterInterface)
	local self = setmetatable({}, AudioVisualizers)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.Frame:WaitForChild("AudioVisualizers")
	self._current_visualizers = {}
	self:_Init()
	return self
end

function AudioVisualizers:Create(sound, p, p2)
	if not self.FighterInterface:IsActive() then
		return
	end

	local _GetSourcePosition = self:_GetSourcePosition(sound)

	if not _GetSourcePosition then
		return
	end

	local v2 = self.FighterInterface.ClientFighter.Entity and (_GetSourcePosition - self.FighterInterface.ClientFighter.Entity.RootPart.Position).Magnitude <= 4
	local v3 = self:_GetEffectiveVolume(_GetSourcePosition, p, p2) <= 0

	if v2 or v3 then
		return
	end

	for k, _current_visualizer in pairs(self._current_visualizers) do
		if not (_current_visualizer.Source == sound or _current_visualizer.Source2 == sound) then
			continue
		end

		k:Destroy()
		self._current_visualizers[k] = nil
	end

	local clone = audioVisualizerIcon:Clone()
	clone.Parent = self.Frame
	BetterDebris:AddItem(clone, 30)
	local v4 = false
	local _ = workspace.CurrentCamera.CFrame
	local v5 = _GetSourcePosition
	local v6 = Spring.new(0, 1, 40)
	local v7 = Spring.new(0.5, 1, 40)
	local target = nil
	local count = 0
	local v8 = 0
	local v9 = false

	local function update(p3)
		local _GetSourcePosition2 = self:_GetSourcePosition(sound)

		if _GetSourcePosition2 then
			v5 = v5
		else
			v9 = true
			_GetSourcePosition2 = v5
		end

		local cFrame = workspace.CurrentCamera.CFrame
		local vector2 = (_GetSourcePosition2 - cFrame.Position) * createVector(1, 0, 1)
		local v10 = cFrame.LookVector * createVector(1, 0, 1)
		local vector3 = v10.Magnitude <= 0.01 and createVector(1, 0, 0) or v10.Unit

		if vector2 ~= vector2 or vector2.Magnitude == 0 then
			clone.Visible = false
			return
		end

		clone.Visible = true
		local v11 = math.acos(vector2:Dot(vector3) / vector2.Magnitude)
		local v12 = v6

		if math.sign(vector3:Cross(vector2).Y) == 1 then
			v11 = 6.283185307179586 - v11 or v11
		end

		v12.Target = v11 + 1.5707963267948966
		v7.Target = math.max(0.125, 0.5 / math.max(1, (vector2.Magnitude - 5) / 25))

		if p3 then
			if target then
				local v13 = v6.Target - target

				if v13 > 3.141592653589793 then
					v6.Value += 6.283185307179586
				elseif v13 < -3.141592653589793 then
					v6.Value -= 6.283185307179586
				end
			end
		else
			v7.Value = v7.Target
			v6.Value = v6.Target
		end

		local v13 = Vector2.new(0.5, 0.5) - Vector2.new(math.cos(v6.Value), (math.sin(v6.Value))) * 0.75 / 2
		clone.Position = UDim2.new(v13.X, 0, v13.Y, 0)
		clone.Rotation = math.deg(v6.Value - 1.5707963267948966)
		clone.Size = UDim2.new(v7.Value, 0, v7.Value, 0)

		if not v4 then
			clone.ImageTransparency = audioVisualizerIcon.ImageTransparency + (1 - audioVisualizerIcon.ImageTransparency) * (1 - self:_GetEffectiveVolume(
				_GetSourcePosition2,
				p,
				p2
			))
		end

		target = v6.Target
		local now = tick()

		if v8 < now then
			v8 = tick() + 0.04
			count += 1
			clone.Image = v[count % #v + 1]
		end
	end

	local _current_visualizers = self._current_visualizers
	_current_visualizers[clone] = {
		Source = sound,
		Update = update,
		Source2 = typeof(sound) == "Instance" and sound:IsA("Sound") and sound.Parent
	}
	update(nil)
	wait(0)
	v4 = true
	local imageTransparency = clone.ImageTransparency
	Utility:RenderstepForLoop(0, 100, 4, function(p3)
		clone.ImageTransparency = imageTransparency + (1 - imageTransparency) * (1 - (1 - p3 / 100) ^ 4)
	end)
	clone:Destroy()
	self._current_visualizers[clone] = nil
end

function AudioVisualizers:Update(p2, _)
	for _, _current_visualizer in pairs(self._current_visualizers) do
		pcall(_current_visualizer.Update, p2)
	end
end

function AudioVisualizers:Clear()
	for k in pairs(self._current_visualizers) do
		k:Destroy()
	end

	self._current_visualizers = {}
end

function AudioVisualizers:Destroy()
	self:Clear()
end

function AudioVisualizers:_GetSourcePosition(part)
	if typeof(part) == "Vector3" then
		return part
	end

	if part:IsA("BasePart") then
		return part.Position
	end

	if part.Parent and part.Parent:IsA("BasePart") then
		return part.Parent.Position
	end
end

function AudioVisualizers:_GetEffectiveVolume(p, p2, p3)
	return (1 - math.clamp(((workspace.CurrentCamera.CFrame.Position - p).Magnitude - p2) / (p3 - p2), 0, 1)) ^ 2
end

function AudioVisualizers:_Init() end

return AudioVisualizers