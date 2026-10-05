local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(player)
	local duration = player.Duration
	local character = player.Character

	if not character then
		return
	end

	local head = character:WaitForChild("Head", 1)

	if not head then
		return
	end

	for i = 1, 4 do
		local clone = script.SpinWind:Clone()
		clone.Size = clone.Size * (1 + math.random() * i / 10) * 0.5
		clone.CFrame = head.CFrame * CFrame.Angles(3.141592653589793, 0, 1.5707963267948966) * CFrame.Angles(
			6.283185307179586 * math.random(),
			0,
			0
		) + Vector3.new(0, i / 3, 0)
		clone.Parent = workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(i / 22.5 + 0.1, Enum.EasingStyle.Quad), {
			Size = clone.Size * createVector(1, 4, 2) * (1 + math.random() * 0.3) * 1.4,
			CFrame = clone.CFrame * CFrame.Angles(3.141592653589793, math.random() - 0.5, 0),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end

	if character == game.Players.LocalPlayer.Character then
		local clone = script.DoorCC:Clone()
		clone.Parent = game.Lighting
		local currentCamera = workspace.CurrentCamera
		local lastTime = tick()

		while tick() - lastTime < duration do
			local RunService = game:GetService("RunService")
			local v = RunService.RenderStepped:Wait() / duration
			currentCamera.CFrame = CFrame.new(head.Position) * CFrame.Angles(0, v * 3.141592653589793 * 2, 0) * (currentCamera.CFrame - currentCamera.CFrame.p) * CFrame.new(
				0,
				0,
				(currentCamera.CFrame.p - head.Position).Magnitude
			)
		end

		clone:Destroy()
	end
end