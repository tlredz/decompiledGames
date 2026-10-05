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

	for i = 150, 15, -15 do
		local clone = game.ReplicatedStorage.Assets.Models.CrescentSlash:Clone()
		clone.CFrame = cFrame * CFrame.new(0, i, 0) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
		clone.Size = createVector(4, 1, 5)
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
			Size = createVector(80, 2, 100),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		wait()
	end

	local ray = Util.Ray
	local p2 = cFrame.p
	local v = { workspace.Characters, workspace.Enemies }

	if ray(p2, createVector(0, -10, 0), v) then
		local clone = game.ReplicatedStorage.Assets.Models.RockEmitter:Clone()
		Util.Debris:AddItem(clone, 1)
		clone.Size *= 1.75
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clone.Rock:Emit(20)
	end

	for _ = 1, 1 do
		local clone = game.ReplicatedStorage.Assets.Models.ShockwaveNeon:Clone()
		clone.CFrame = cFrame
		clone.Size = createVector(10, 80, 10)
		clone.Parent = _WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Size = createVector(140, 40, 140),
			Transparency = 1
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end
end