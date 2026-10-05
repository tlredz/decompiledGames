local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local fx = require(ReplicatedStorage.shared.modules.fx)
local fishing = ReplicatedStorage.resources.replicated.fishing
local sfx = ReplicatedStorage.resources.sounds.sfx
local fire = ReplicatedStorage.resources.rod_vfx["Abyssal Aura"].VFX:FindFirstChild("Fire")
return {
	Burn = function(_, _, _: string, position: Vector3?)
		if typeof(position) ~= "Vector3" then
			return
		end

		local clone = fishing.splash:Clone()
		clone.Position = position
		clone.Parent = workspace.active.debrisfx
		clone.particles:Emit(12)

		if fire then
			local clone2 = fire:Clone()
			clone2.Enabled = false
			clone2.Parent = clone
			clone2:Emit(25)
		end

		fx:PlaySound(sfx.scylla.fireball_impact, clone, true)
		SaneDebris:AddItem(clone, 3)
	end
}