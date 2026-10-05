local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local clone = game.ReplicatedStorage.Assets.Models.RockEmitter:Clone()
	Util.Debris:AddItem(clone, 1)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	clone.Rock:Emit(20)

	for _ = 1, 2 do
		local clone2 = game.ReplicatedStorage.Assets.Models.ShockwaveNeon:Clone()
		clone2.CFrame = cFrame
		clone2.Size = createVector(10, 80, 10)
		clone2.Parent = _WorldOrigin
		local tween = TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = createVector(70, 20, 70),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone2:Destroy()
		end)
		tween:Play()
	end
end