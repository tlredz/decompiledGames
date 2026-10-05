workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local _ = game.ReplicatedStorage.Util
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local part = p.Part

	if (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	while part and part.Parent and part:IsDescendantOf(workspace) do
		if part.Mesh.Scale.Y > 0.7 then
			local clone = part:Clone()
			clone.CFrame = part.CFrame
			clone.Mesh.Scale *= 2
			clone.Transparency = 1
			clone.Parent = workspace._WorldOrigin
			local weld = Instance.new("Weld", clone)
			weld.Part0 = clone
			weld.Part1 = part
			TweenService:Create(clone, TweenInfo.new(0.33), {
				Transparency = 0
			}):Play()
			local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.33), {
				Scale = Vector3.new()
			})
			tween.Completed:Connect(function()
				clone:Destroy()
			end)
			tween:Play()
		end

		wait(0.1)
	end
end