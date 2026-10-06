local module = require("@game/ReplicatedStorage/Omni")
local cache = workspace:WaitForChild("Cache")
local v = nil
local Effects = {
	Refresh = function()
		if module.Data.Settings["Low Mode"] then
			if v then
				return
			end

			v = module.Utils.Instance:ObserveDescendants(workspace, function(effect)
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) or not effect.Enabled or effect:GetAttribute("MutationVFX") then
					return
				end

				local traits = cache:FindFirstChild("Traits")

				if traits and effect:IsDescendantOf(traits) then
					return
				end

				effect:SetAttribute("__LOWMODED", true)
				effect.Enabled = false
			end)
		else
			if not v then
				return
			end

			v:Destroy()
			v = nil

			for _, effect in workspace:GetDescendants() do
				if not ((effect:IsA("ParticleEmitter") or effect:IsA("Beam")) and effect:GetAttribute("__LOWMODED")) then
					continue
				end

				effect:SetAttribute("__LOWMODED", nil)

				if not effect:GetAttribute("MutationVFX") then
					effect.Enabled = true
				end
			end
		end
	end
}

function Effects.Init()
	Effects.Refresh()
end

module:OnDataChanged({ "Settings", "Low Mode" }, Effects.Refresh)
return Effects