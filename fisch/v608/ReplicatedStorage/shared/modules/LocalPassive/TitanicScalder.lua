local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.utils.GeneralUtils)
local module = require("./PassiveHandler")
local TitanicScalder = {
	MorphHarpoon = function(state, _, object)
		state.random = object:GetRandom(55)
		state.progLossModifier = object:CreateModifier("progressLossMultiplier", "multiply")
		state.progLossModifier.Value = 1
		state.buttonSpawnTimer = 1
		state.reelTrove:Add(object.core.pullButtons.OnClickEvent:Connect(function(_)
			state.bar.value = math.min(state.bar.value + state.config.HeatPerClick, state.config.MaxHeat)
		end))
		state.reelTrove:Add(object.core.pullButtons.OnMissEvent:Connect(function(_)
			state.bar.value = math.max(state.bar.value - state.config.HeatPerClick, 0)
		end))
		state.reelTrove:Add(object.core.pullButtons.OnButtonAdd:Connect(function(p)
			local v = math.clamp((state.bar.value - state.bar.min) / state.bar.max, 0, 1)
			local clone = script.heatButtonOverlay:Clone()
			clone.BackgroundTransparency = math.lerp(1, 0.7, v)
			clone.hoverStroke.Transparency = 1 - v
			clone.UIShadow1.Transparency = math.lerp(
				1,
				0,
				TweenService:GetValue(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			)
			clone.UIShadow2.Transparency = math.lerp(1, 0, v)
			clone.UIShadow3.Transparency = math.lerp(
				1,
				0,
				TweenService:GetValue(v, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			)
			p.buttonObject.UIShadow.Transparency = math.lerp(p.buttonObject.UIShadow.Transparency, 1, v)
			clone.Parent = p.buttonObject
		end))
		state.bar = object:CreatePassiveBar("heat", script.heat, {
			value = 0,
			min = 0,
			max = state.config.MaxHeat
		})
		object.BuildEndingData:Bind(function(p)
			p.TitanicScalder_EndingHeat = state.bar.value
			return p
		end)
	end,
	TickLogic_Harpoon = function(state, p, p2: number)
		local v = math.clamp((state.bar.value - state.bar.min) / state.bar.max, 0, 1)
		state.progLossModifier.Value = math.lerp(1, state.config.MaxLossPenaltyReduction, v)
		state.buttonSpawnTimer -= p2 / math.lerp(1, state.config.MaxExtraPullSpawnRate, v)

		while state.buttonSpawnTimer <= 0 do
			state.buttonSpawnTimer += 1
			p.core.pullButtons:SpawnButton()
		end
	end,
	TickRender_Harpoon = function(_, p, _: number)
		for _, activeButton in p.activeButtons do
			if activeButton.buttonType ~= "pull" then
				continue
			end

			local heatButtonOverlay = activeButton.buttonObject:FindFirstChild("heatButtonOverlay")

			if heatButtonOverlay then
				heatButtonOverlay.hoverStroke.Enabled = activeButton.isHovered
			end
		end
	end
}
setmetatable(TitanicScalder, module)
return TitanicScalder