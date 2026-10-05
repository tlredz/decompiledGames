game:GetService("TweenService")
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local AuraEffects = {}

function AuraEffects.TurnOnAura(instance, p: number?)
	local v = p == nil and 12 or p
	local has_Blade = instance:FindFirstChild("Has_Blade", true)

	if has_Blade ~= nil then
		local blade = has_Blade.Parent:FindFirstChild("Blade")

		if blade ~= nil then
			local clone = script.Assets.Aura:Clone()
			clone.CFrame = blade.CFrame
			clone.Parent = blade
			clone.Name = "Aura"
			vfxUtility.WeldConstraint(clone, blade)
			vfxUtility.TweenBeams(clone, {
				Time = 0.4
			})
			DebrisModule:AddItem(clone, v)
		end
	end
end

function AuraEffects.TurnOffAura(instance)
	local has_Blade = instance:FindFirstChild("Has_Blade", true)

	if has_Blade ~= nil then
		local blade = has_Blade.Parent:FindFirstChild("Blade")

		if blade ~= nil then
			for _, child in ipairs(blade:GetChildren()) do
				if child.Name ~= "Aura" then
					continue
				end

				vfxUtility.TweenBeams(child, {
					Time = 0.4,
					Off = true
				})
				DebrisModule:AddItem(child, 1)
			end
		end
	end
end

return AuraEffects