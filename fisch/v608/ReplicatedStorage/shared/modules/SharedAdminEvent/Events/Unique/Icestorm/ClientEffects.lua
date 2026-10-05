local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("SoundService")
local Debris = game:GetService("Debris")
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("adminEvents"):WaitForChild("vfx")
ReplicatedStorage.resources.adminEvents:WaitForChild("sfx")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local renderSteppedConnection = nil
local clone = nil
local ClientEffects = {}

function ClientEffects.Open()
	clone = vfx:WaitForChild("Icestorm"):Clone()
	clone.Parent = workspace.CurrentCamera
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local character = localPlayer.Character

		if character and clone then
			clone.Position = character:FindFirstChild("HumanoidRootPart").Position
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
end

return ClientEffects