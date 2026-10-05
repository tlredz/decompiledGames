local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Back)
return function(p)
	local clone = script.TouchedEffect:Clone()
	clone.Parent = p.Cube
	clone.PS2pinkrockCONFIRM:Play()
	Ouwmit.Emit(clone)
	DebrisModule:AddItem(clone, 2)
	p.Cube.SurfaceAppearance.EmissiveStrength = 50
	TweenService:Create(p.Cube.SurfaceAppearance, tweenInfo, {
		EmissiveStrength = 8
	}):Play()
	local cube = p.Cube
	local size = cube:GetAttribute("Size")

	if size == nil then
		size = cube.Size
		cube:SetAttribute("Size", size)
	end

	cube.Size = size * 0.6
	TweenService:Create(cube, tweenInfo2, {
		Size = size
	}):Play()
	Cam_Shaker(p.Cube.Position, "tinyshake_less_aggresive_preset")
end