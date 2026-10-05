local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("adminEvents"):WaitForChild("vfx")
local sfx = ReplicatedStorage.resources.adminEvents:WaitForChild("sfx")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local renderSteppedConnection = nil
local clone = nil
local colorCorrectionEffect = nil
local music_special = SoundService:WaitForChild("music_special")
TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local ClientEffects = {}

function ClientEffects.Open()
	clone = vfx:WaitForChild("Landfill"):Clone()
	clone.Parent = workspace.CurrentCamera

	if workspace:WaitForChild("Terrain"):FindFirstChildOfClass("Clouds") then
		local clouds = workspace:WaitForChild("Terrain"):FindFirstChildOfClass("Clouds")
		clouds.Enabled = false
	end

	colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = Lighting
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character

		if character then
			if clone then
				clone.Position = character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(
					0,
					clone.Size.Y / 2,
					0
				)
			end

			local music = SoundService:WaitForChild("music")
			music.Volume = music_special.Volume
			colorCorrectionEffect.Brightness = (nil).PlaybackLoudness / 6000
		end
	end)
end

function ClientEffects.Close()
	sfx:WaitForChild("corruptionstorm"):Stop()

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

	if colorCorrectionEffect then
		colorCorrectionEffect:Destroy()
	end

	if workspace:WaitForChild("Terrain"):FindFirstChildOfClass("Clouds") then
		local clouds = workspace:WaitForChild("Terrain"):FindFirstChildOfClass("Clouds")
		clouds.Enabled = true
	end

	local music = SoundService:WaitForChild("music")
	music.Volume = music_special.Volume
end

return ClientEffects