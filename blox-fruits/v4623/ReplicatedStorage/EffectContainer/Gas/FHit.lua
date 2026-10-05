local _WorldOrigin = workspace._WorldOrigin
local FX = require(game.ReplicatedStorage.FX)
local fHit = FX:WaitForChild("Gas").FHit
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Util)
return function(p)
	local targetRoot = p.TargetRoot
	local cFrame = targetRoot.CFrame
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	local clone = fHit.BeforeExplosion:Clone()
	clone.CFrame = targetRoot.CFrame
	clone.Parent = folder
	local emittersByEmitter = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emittersByEmitter[emitter] = emitter
		emitter.Enabled = true
	end

	local v = Util.Sound:Play("BF_GASFRUIT_UNTR_TravelingGasFlight_Enemy", cFrame)
	local v2 = tick() + 0.3

	while true do
		for _, v3 in pairs(emittersByEmitter) do
			v3:Emit(1)
		end

		task.wait(0.01)

		if not (v2 - tick() <= 0) then
			continue
		end

		if v then
			Util.Sound:FadeOut(v, 0.2)
		end

		local clone2 = fHit.Explosion:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = folder
		Util.Sound:Play("BF_GASFRUIT_UNTR_SmogDemon_Impact_01", cFrame, 4, 1.3)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		for _, v3 in pairs(emittersByEmitter) do
			v3.Enabled = false
		end

		task.delay(5, function()
			folder:Destroy()
		end)
		break
	end
end