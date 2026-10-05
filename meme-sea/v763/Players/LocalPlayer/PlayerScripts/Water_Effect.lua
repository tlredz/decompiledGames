local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local seaBlock = workspace.Sea:WaitForChild("SeaBlock")
local mesh = seaBlock:WaitForChild("Mesh")
local ambientReverb = SoundService.AmbientReverb
local fogEnd = Lighting.FogEnd
local fieldOfView = currentCamera.FieldOfView
local fogColor = Lighting.FogColor
local colorCorrection = Lighting:WaitForChild("ColorCorrection")
local sea = ReplicatedStorage.Sound_Effect:WaitForChild("Sea")

if mesh and mesh.MeshType ~= Enum.MeshType.Brick then
	mesh.MeshType = Enum.MeshType.Brick
end

while localPlayer:GetAttribute("TeamSelected") == nil do
	task.wait(1)
end

colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
sea:Play()

function Update_Camera()
	local v = seaBlock.Size.Y / 2
	local fieldOfView2 = fieldOfView - 8
	SoundService.AmbientReverb = ambientReverb
	colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
	sea.Volume = 0
	Lighting.FogEnd = fogEnd
	Lighting.FogColor = fogColor
	currentCamera.FieldOfView = fieldOfView

	if currentCamera.CFrame.Position.Y <= -108 + v then
		SoundService.AmbientReverb = Enum.ReverbType.UnderWater
		colorCorrection.TintColor = Color3.fromRGB(85, 175, 255)
		sea.Volume = 0.25
		Lighting.FogEnd = 3000
		Lighting.FogColor = seaBlock.Color
		currentCamera.FieldOfView = fieldOfView2
	end
end

currentCamera.Changed:Connect(function(p)
	if p == "CFrame" then
		Update_Camera()
	end
end)