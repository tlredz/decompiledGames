local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
game:GetService("TweenService")
game:GetService("RunService")
local _ = Util.RocksModule
local destroyAfter = Util.DestroyAfter
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage.FX)
local gravityCane = FX:WaitForChild("GravityCane")

local function gravityflurry(player, hrp, cFrame, caught)
	local clone = gravityCane.summon:Clone()
	local clone2 = gravityCane.slice:Clone()
	local clone3 = gravityCane.smash:Clone()
	clone3.CFrame = cFrame
	clone3.Parent = _WorldOrigin
	destroyAfter(clone3, 5)
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 3)
	clone2.CFrame = cFrame + createVector(0, 60, 0)
	clone2.Parent = _WorldOrigin
	destroyAfter(clone2, 3)
	local clone4 = gravityCane.swordfx.Attachment:Clone()
	clone4.Parent = hrp
	destroyAfter(clone4, 6)
	wait(0.15)
	clone4.upwards:Emit(clone4.upwards:GetAttribute("EmitCount"))
	Util.Sound:Play("GravityCane_rise", clone)
	Util.Sound:Play("GravityCane_rise2", clone)
	clone.linesu:Emit(clone.linesu:GetAttribute("EmitCount"))
	clone.linesu2:Emit(clone.linesu2:GetAttribute("EmitCount"))
	clone.Flare:Emit(clone.Flare:GetAttribute("EmitCount"))

	for _, attachment in ipairs(clone:GetDescendants()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		for _, emitter in ipairs(attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end
	end

	if not caught then
		return
	end

	task.spawn(function()
		wait(0.364)
		local v = Util.Sound:Play("GravityCane_slice", clone2)
		Util.Sound:FadeOut(v, 1)
		clone2.Attachment["2"].Enabled = true
		clone2.Flare.Enabled = true

		for _ = 1, 5 do
			task.wait(0.1)
			clone4.Slashes:Emit(clone4.Slashes:GetAttribute("EmitCount"))
			clone2.Flare:Emit(clone2.Flare:GetAttribute("EmitCount"))

			for _, attachment in ipairs(clone2:GetChildren()) do
				if not attachment:IsA("Attachment") then
					continue
				end

				for _, emitter in ipairs(attachment:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end
		end

		clone2.Attachment["2"].Enabled = false
		clone2.Flare.Enabled = false
	end)
	wait(0.6)

	if player and player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(20, 80, 0, 1)
	end

	wait(0.68)
	clone2.linesu:Emit(clone2.linesu:GetAttribute("EmitCount"))
	clone2.linesu2:Emit(clone2.linesu2:GetAttribute("EmitCount"))
	Util.Sound:Play("GravityCane_drop", clone2)
	wait(0.124)

	if player and player == game.Players.LocalPlayer then
		Util.CameraShaker:ShakeOnce(30, 60, 0, 0.5)
	end

	local rayMap, v, v2 = Util.RayMap(cFrame.Position, createVector(-0, -60, -0))

	if rayMap then
		clone3.CFrame = CFrame.new(v, v + v2) * CFrame.Angles(-1.5707963267948966, 0, 0)
		Util.Sound:Play("GravityCane_Sound3", clone3)
		clone3.Sparks2:Emit(clone3.Sparks2:GetAttribute("EmitCount"))
		clone3.Sparks3:Emit(clone3.Sparks3:GetAttribute("EmitCount"))

		for _, attachment in ipairs(clone3:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			for _, emitter in ipairs(attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end
	end
end

return function(data)
	local hrp = data.hrp
	local cFrame = data.CFrame
	local caught = data.caught

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	gravityflurry(data.player, hrp, cFrame, caught)
end