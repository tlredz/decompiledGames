local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local CameraShaker = require(packages.CameraShaker)
local module = require("./Utility")
local assets = script.Parent.Assets
local currentCamera = Workspace.CurrentCamera
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera.CFrame = Workspace.CurrentCamera.CFrame * p
end)
local cameraShakeInstance = CameraShaker.CameraShakeInstance.new(1.2, 7, 0, 0)
cameraShakeInstance.PositionInfluence = vector.create(0, 0.3, 0)
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Brightness = -0.5
colorCorrectionEffect.Enabled = false
colorCorrectionEffect.Parent = Lighting
local VFX = {}

function VFX.SetCavernLightingState(enabled: boolean)
	colorCorrectionEffect.Enabled = enabled
end

function VFX.CameraShake(value: number?)
	v:Start()
	v:ShakeSustain(cameraShakeInstance)
	task.delay(value or 3, function()
		v:StopSustained()
		v:Stop()
	end)
end

function VFX.SeaMineExplosion(folder)
	module.SetCrackVFXState(true)
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local v2 = {
		Color = Color3.fromRGB(183, 0, 0)
	}
	local parts = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") and part.Name == "ColorChangePart" then
			table.insert(parts, part)
		end
	end

	for _, v3 in parts do
		local v4 = TweenService:Create(v3, tweenInfo, v2)
		task.defer(function()
			v4:Play()
		end)
	end

	task.wait(2.25)

	if not folder.PrimaryPart then
		folder:Destroy()
		return
	end

	local clone = assets.Explosion:Clone()
	local particleEmitter = clone.ParticleEmitter
	local sound = clone.Sound
	particleEmitter.Parent = folder.PrimaryPart
	sound.Parent = folder.PrimaryPart
	local total = 0

	while sound.TimeLength == 0 do
		task.wait(0.1)
		total += 0.1

		if total > 1 then
			break
		end
	end

	particleEmitter.Enabled = true
	sound:Play()
	local character = Players.LocalPlayer.Character

	if character then
		local position = character.PrimaryPart and character.PrimaryPart.Position
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if position and humanoid and (position - folder.PrimaryPart.Position).Magnitude < 22 then
			humanoid:SetAttribute("LastDamagedBy", "Sea Mines")
			humanoid:TakeDamage(100)
		end
	end

	task.wait(1)
	folder:Destroy()
	clone:Destroy()
	module.SetCrackVFXState(false)
end

return VFX