local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
return function(_)
	local v = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y * 8
	local cframe = CFrame.Angles(0, 0, 0)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gura.Spikeball:Clone()
	clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -v / 3.33) * cframe
	clone.Size = Vector3.new(v, v, v)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Transparency = 0.75
	}):Play()
	local RunService = game:GetService("RunService")
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
		clone.CFrame = currentCamera.CFrame * CFrame.new(0, 0, -v / 3.33) * cframe
	end)
	spawn(function()
		wait(3)
		TweenService:Create(clone, TweenInfo.new(0.9, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
	end)
	spawn(function()
		wait(4)
		renderSteppedConnection:Disconnect()
	end)
end