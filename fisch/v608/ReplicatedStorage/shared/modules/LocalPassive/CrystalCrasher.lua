local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local sfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx")
local CrystalCrasher = {
	MorphHarpoon = function(state, _, object)
		state.bar = object:CreatePassiveBar("crystalpower", script.crystalpower, {
			value = 0,
			min = 0,
			max = state.config.CrystalChargeMax,
			springTime = 0.1
		})
		state.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(state2)
			if state.bar.value >= state.bar.max then
				local clone = script.crystalGlowOverlay:Clone()
				clone.Parent = state2.buttonObject
				local clone_2 = script.crystalGlow:Clone()
				clone_2.Parent = state2.buttonObject
				state2.buttonObject.UIShadow.Enabled = false
			else
				state2.requiredClicks *= state.config.BaseRequiredClicks
				state2.clicksRemaining *= state.config.BaseRequiredClicks
			end
		end))
		state.reelTrove:Add(object.core.pullButtons.HookClickEvent:BindAtPriority(5000, function(state2)
			if state.bar.value < state.bar.max then
				if state2.clickCount % 2 ~= 0 then
					state2.valid = false
				end
			else
				state2.progress *= state.config.EnhancedProgressMultiplier
			end

			if state2.valid then
				fx:PlaySound(sfx.fishing.crystalClick, object.ui, true)
			end

			return state2
		end))
		state.reelTrove:Add(object.core.pullButtons.OnClickEvent:Connect(function(_)
			state.bar.value += 1
		end))
	end
}
setmetatable(CrystalCrasher, module)
return CrystalCrasher