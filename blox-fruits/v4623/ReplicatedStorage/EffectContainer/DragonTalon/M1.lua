game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local M1 = FX:WaitForChild("DragonTalon").M1
Random.new()
game:GetService("TweenService")
game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

return function(p)
	local position = p.Root.Position

	if (currentCamera.CFrame.p - position).Magnitude > 500 then
		return
	end

	local index = p.Index
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 5)
	local cFrame = p.Root.CFrame

	if index == 1 then
		local cFrame2 = cFrame * CFrame.new(-2, 0, 4)
		local clone = M1.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	elseif index == 2 then
		local cFrame2 = cFrame * CFrame.new(2, 0, 4)
		local clone = M1.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	elseif index == 3 then
		local cFrame2 = cFrame * CFrame.new(-2.15, 0.5, 4)
		local clone = M1.Phase1.StartImpact:Clone()
		clone.CFrame = cFrame2
		clone.Parent = folder

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v2 = emitter
			task.spawn(function()
				if v2:GetAttribute("EmitDelay") ~= 0 then
					task.wait(v2:GetAttribute("EmitDelay"))
				end

				v2:Emit(v2:GetAttribute("EmitCount"))
			end)
		end

		DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
	elseif index == 4 then
		task.wait(0.15)

		for i = 1, 2 do
			local cFrame2

			if i == 1 then
				cFrame2 = cFrame * CFrame.new(2, 0, -17)
			else
				cFrame2 = cFrame * CFrame.new(-2, 0, -17)
			end

			local clone = M1.Phase1.StartImpact:Clone()
			clone.CFrame = cFrame2
			clone.Parent = folder

			for _, emitter in pairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local v2 = emitter
				task.spawn(function()
					if v2:GetAttribute("EmitDelay") ~= 0 then
						task.wait(v2:GetAttribute("EmitDelay"))
					end

					v2:Emit(v2:GetAttribute("EmitCount"))
				end)
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
		end
	end
end