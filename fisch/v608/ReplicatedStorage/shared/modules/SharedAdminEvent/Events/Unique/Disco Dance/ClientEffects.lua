local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("adminEvents"):WaitForChild("vfx")
local sfx = ReplicatedStorage.resources.adminEvents:WaitForChild("sfx")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local renderSteppedConnection = nil
local clone = nil
local clone2 = nil
local music_special = SoundService:WaitForChild("music_special")
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local ClientEffects = {}

function ClientEffects.Open()
	clone = vfx:WaitForChild("Disco_Dance"):Clone()
	clone.Parent = workspace.CurrentCamera
	clone2 = sfx:WaitForChild("disco"):Clone()
	clone2.Parent = music_special
	clone2.SoundGroup = music_special
	clone2:Play()
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character

		if character then
			if clone then
				clone.Position = character:FindFirstChild("HumanoidRootPart").Position
			end

			if clone2 then
				local music = SoundService:WaitForChild("music")
				music.Volume = 0
			else
				local music_2 = SoundService:WaitForChild("music")
				music_2.Volume = music_special.Volume
			end
		end
	end)
end

function ClientEffects.Close()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	if clone then
		for _, emitter in clone:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		Debris:AddItem(clone, 25)
		clone.Name = "__WaitingToDelete"
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