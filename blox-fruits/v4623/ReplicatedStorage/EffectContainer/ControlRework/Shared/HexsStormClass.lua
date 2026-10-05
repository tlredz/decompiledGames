local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local HexsStormClass = {
	Assets = 0
}
local FX = require(ReplicatedStorage:WaitForChild("FX"))
HexsStormClass.Assets = FX:WaitForChild("ControlRework"):WaitForChild("Gameplay"):WaitForChild("HexsStormClassFolder")
HexsStormClass.__index = HexsStormClass

function HexsStormClass.new(adornee, worldOrientation: boolean?, player)
	return (setmetatable({
		Data = {},
		Adornee = adornee,
		WorldOrientation = worldOrientation,
		Player = player
	}, HexsStormClass))
end

function HexsStormClass:Enable()
	if self:IsEnabled() then
		return
	end

	self.Connection = RunService.PostSimulation:Connect(function(dt)
		self:Update(dt)
	end)
end

function HexsStormClass:Update(p: number)
	for k, v in self.Data do
		local surfaces = k.Surfaces
		local image = surfaces.Left.Image
		local imageTransparency = surfaces.Right.Image.ImageTransparency
		image.ImageTransparency = imageTransparency
		local v2 = math.noise(v.Angle * 0.01, v.Factor * 0.1)
		local v3 = (self.WorldOrientation and CFrame.new(self.Adornee.Position) or self.Adornee.CFrame) * CFrame.Angles(
			0,
			math.rad(v.Angle),
			0
		) * CFrame.new(
			0,
			v.Factor * (self.YFactor or 2.25) + v2 * 2.5,
			v.Range - (v.Range * 0.35 * math.abs(v.Factor) + v2)
		).Position
		k.CFrame = CFrame.lookAt(v3, self.Adornee.Position) * CFrame.new(0, 0, imageTransparency * 3) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		v.Angle += v.Speed * p
	end
end

function HexsStormClass.AddHex(data, p: string, value: number, range: number, angle: number, speed: number)
	local factor = math.clamp(value, -1, 1)
	local clone = data.Assets[`{p}NeonHex`]:Clone()
	clone.CFrame = CFrame.new(0, -100000, 0)
	clone.Size -= createVector(1, 0, 1) * math.abs(factor)
	clone.Name = `Hex-Storm: {HttpService:GenerateGUID()}`
	Util.SetParentOverrideWithColor(clone, workspace.Terrain, data.Player, "ControlFruitVFXColor")
	local v2 = {
		Factor = factor,
		Range = range,
		Angle = angle,
		Speed = speed,
		Instance = clone
	}
	data.Data[clone] = v2
	return v2
end

function HexsStormClass:RemoveHex(instance)
	self.Data[instance] = nil
	instance:Destroy()
end

function HexsStormClass.ApplyTransparencyTransition(p, p2, imageTransparency: number, imageTransparency2: number)
	for k in p.Data do
		local image = k.Surfaces.Right.Image
		image.ImageTransparency = imageTransparency
		TweenService:Create(image, p2, {
			ImageTransparency = imageTransparency2
		}):Play()
	end
end

function HexsStormClass:Disable()
	if not self:IsEnabled() then
		return
	end

	self.Connection:Disconnect()
end

function HexsStormClass:IsEnabled()
	return typeof(self.Connection) == "RBXScriptConnection" and self.Connection.Connected
end

function HexsStormClass:Destroy()
	for k in self.Data do
		self:RemoveHex(k)
	end

	self:Disable()
	table.clear(self)
end

return HexsStormClass