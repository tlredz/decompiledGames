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
Color3.fromRGB(175, 221, 255)
return function(p)
	local part = p.Part

	if (part.CFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	while part and part.Parent and part:IsDescendantOf(workspace) do
		local clone = part:Clone()
		clone.CFrame = part.CFrame
		clone.Parent = workspace._WorldOrigin
		local weld = Instance.new("Weld", clone)
		weld.Part0 = clone
		weld.Part1 = part
		TweenService:Create(clone, TweenInfo.new(0.2), {
			Transparency = 1
		}):Play()
		local tween = TweenService:Create(clone.Mesh, TweenInfo.new(0.2), {
			Scale = clone.Mesh.Scale * 1.5
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		wait(0.25)
	end
end