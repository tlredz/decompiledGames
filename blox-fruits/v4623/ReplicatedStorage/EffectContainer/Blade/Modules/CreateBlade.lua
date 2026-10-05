local localPlayer = game.Players.LocalPlayer
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local createBlade = FX:WaitForChild("Blade").Modules.CreateBlade

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

local function CreateBlade(part, p, cframe: CFrame?, p2)
	local clone = createBlade.Blade:Clone()
	clone.CFrame = part.CFrame
	clone.Anchored = false
	clone.Weld.Part1 = part
	clone.Weld.Enabled = true
	clone.Weld.C0 *= CFrame.Angles(0, 1.5707963267948966, 0)

	if cframe then
		clone.Weld.C0 *= cframe
	end

	Util.SetParentOverrideWithColor(clone, p, p2 or localPlayer, "BladeFruitVFXColor")
	return {
		Shrink = function(_, ...)
			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("Beam") then
					effect.Enabled = false
				elseif effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				end
			end

			local clone2 = createBlade.BladeEndImpact.Attachment:Clone()
			Util.SetParentOverrideWithColor(clone2, clone, p2 or localPlayer, "BladeFruitVFXColor")

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			DeleteImpactAfterDuration(clone2) -- equivalent call inferred; original call site unknown
			task.wait(1)
			clone:Destroy()
		end
	}
end

return CreateBlade