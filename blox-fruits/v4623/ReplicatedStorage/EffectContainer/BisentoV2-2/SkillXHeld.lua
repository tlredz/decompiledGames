local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local bisentoZ = FX:WaitForChild("BisentoV2").BisentoZ
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
return function(data)
	local effectID = data.EffectID or data.EffectId
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera
	local cFrame = hrp.CFrame
	local _ = data.origin
	local _ = data.fireDir

	if data.skillHeld == true then
		if (cFrame.Position - currentCamera.CFrame.Position).Magnitude > 500 then
			return
		end

		local part2 = nil

		for _, model in pairs(hrp.Parent:GetChildren()) do
			if not (model:IsA("Model") and model.Name == "Bisento") then
				continue
			end

			for _, part in pairs(model:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Name == "Blade") then
					continue
				end

				part2 = part
				break
			end
		end

		if not part2 then
			return
		end

		local clone = bisentoZ.ArmBall:Clone()
		clone.Name = "BisentoBall" .. effectID
		clone.CFrame = part2.CFrame
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = part2
		weldConstraint.Parent = clone
		clone.Massless = true
		clone.Parent = _WorldOrigin
	else
		local folder = data.skillHeld == false and _WorldOrigin:FindFirstChild("BisentoBall" .. effectID)

		if folder then
			for _, descendant in ipairs(folder:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
					descendant.Enabled = false
				elseif descendant:IsA("BasePart") then
					descendant.Transparency = 1
				end
			end

			folder.Transparency = 1
			task.wait(2)
			folder:Destroy()
		end
	end
end