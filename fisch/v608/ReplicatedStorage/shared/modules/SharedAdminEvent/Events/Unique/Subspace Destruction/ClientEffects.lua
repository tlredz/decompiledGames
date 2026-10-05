local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("adminEvents"):WaitForChild("vfx")
local sfx = ReplicatedStorage.resources.adminEvents:WaitForChild("sfx")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local renderSteppedConnection = nil
local clone = nil
local clone2 = nil
local colorCorrectionEffect = nil
local music_special = SoundService:WaitForChild("music_special")
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local ClientEffects = {}

function ClientEffects.Open()
	local subspaceDestructionVFX = vfx:WaitForChild("SubspaceDestructionVFX")

	if not subspaceDestructionVFX:IsA("BasePart") then
		subspaceDestructionVFX = subspaceDestructionVFX:FindFirstChildWhichIsA("BasePart")
	end

	clone = subspaceDestructionVFX:Clone()
	clone.Parent = workspace.CurrentCamera
	clone2 = sfx:WaitForChild("destruction"):Clone()
	clone2.Parent = music_special
	clone2.SoundGroup = music_special
	clone2:Play()
	colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Enabled = not SettingsController:GetSettingValue("photosensitiveMode")
	colorCorrectionEffect.Parent = Lighting
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			if clone then
				clone.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, clone.Size.Y / 2, 0)) * clone.CFrame.Rotation
			end

			if clone2 then
				local music = SoundService:WaitForChild("music")
				music.Volume = 0
			else
				local music_2 = SoundService:WaitForChild("music")
				music_2.Volume = music_special.Volume
			end

			colorCorrectionEffect.Brightness = clone2.PlaybackLoudness / 6000
		end
	end)
end

function ClientEffects.Close()
	sfx:WaitForChild("destruction"):Stop()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if clone then
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
				TweenService:Create(descendant, TweenInfo.new(2, Enum.EasingStyle.Linear), {
					LocalTransparencyModifier = 1
				}):Play()
			elseif descendant:IsA("Highlight") then
				descendant:Destroy()
			end
		end

		Debris:AddItem(clone, 3)
		clone.Name = "__WaitingToDelete"
		clone = nil
	end

	if colorCorrectionEffect then
		colorCorrectionEffect:Destroy()
		colorCorrectionEffect = nil
	end

	if clone2 then
		TweenService:Create(clone2, tweenInfo, {
			Volume = 0
		}):Play()

		if SoundService.music:FindFirstChildOfClass("Sound") then
			local sound = SoundService.music:FindFirstChildOfClass("Sound")
			local volume = sound.Volume
			sound.Volume = 0
			TweenService:Create(sound, tweenInfo, {
				Volume = volume
			}):Play()
		end

		Debris:AddItem(clone2, tweenInfo.Time)
	end

	local music = SoundService:WaitForChild("music")
	music.Volume = music_special.Volume
end

return ClientEffects