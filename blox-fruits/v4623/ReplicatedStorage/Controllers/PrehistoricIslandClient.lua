local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local ModelUtil = require(game.ReplicatedStorage.Modules.ModelUtil)
local Observers = require(game.ReplicatedStorage.Modules.Observers)
local Net = require(game.ReplicatedStorage.Modules.Net)
return {
	WorldCriteria = {
		Worlds = { "Sea3" },
		OnFailure = function(_)
			return {}
		end
	},
	OnStart = function(_)
		local Util = require(game.ReplicatedStorage.Util)
		local remoteEvent = Net:RemoteEvent("CollectedDragonEgg")
		local remoteEvent2 = Net:RemoteEvent("PlayRelicHitEffect")
		Observers.observeTag("PrehistoricIslandDragonEgg", function(instance)
			local thread = task.defer(function()
				local pivot = instance:GetPivot()

				while task.wait(0.016666666666666666) and instance.Parent do
					instance:PivotTo(pivot * CFrame.new(0, math.sin(tick() * 2) * 0.5, 0))
				end
			end)
			local proximityPrompt = not game.Players.LocalPlayer:GetAttribute("PrehistoricIslandParticipant") and instance:FindFirstChildWhichIsA(
				"ProximityPrompt",
				true
			)

			if proximityPrompt then
				proximityPrompt:Destroy()
			end

			return function()
				task.cancel(thread)
				thread = nil
			end
		end, { workspace })

		local function destroyProximityPrompts()
			for _, child in workspace.Map.PrehistoricIsland.Core.SpawnedDragonEggs:GetChildren() do
				local proximityPrompt = child:FindFirstChildWhichIsA("ProximityPrompt", true)

				if proximityPrompt then
					proximityPrompt:Destroy()
				end
			end
		end

		remoteEvent.OnClientEvent:Connect(destroyProximityPrompts)
		local count = 0
		remoteEvent2.OnClientEvent:Connect(function(parent)
			local clone = WrapHighlight(game.ReplicatedStorage.Modules.CombatUtil.DamageHighlight):Clone()
			clone.Parent = parent
			game.TweenService:Create(clone, TweenInfo.new(0.2), {
				FillTransparency = 0.5
			}):Play()
			task.delay(0.2, function()
				game.TweenService:Create(clone, TweenInfo.new(0.2), {
					FillTransparency = 1
				}):Play()
				task.wait(0.2)
				clone:Destroy()
			end)
			count += 1
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local pivot = parent:GetPivot()
			local v = pivot * CFrame.Angles(0, 0, (math.rad(count % 2 == 0 and 5 or -5)))
			ModelUtil.tweenModelCFrame(parent, v, tweenInfo, function()
				ModelUtil.tweenModelCFrame(
					parent,
					pivot,
					TweenInfo.new(0.4, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
				)
			end)
			Util.Sound:Play("Hit1", pivot.Position)
		end)
	end
}