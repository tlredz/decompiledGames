local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("ContentProvider")
require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.shared.utils.FischUtils)
local random = Random.new()
local RelicConstructTwistedAttack = {
	MorphSpear = true,
	Morph = function(p, p2, object)
		script.sfx.SoundId = script.sfx:GetAttribute("SoundId") or script.sfx.SoundId
		object:Preload(script:GetChildren())
		local random2 = object:GetRandom(9)
		task.spawn(function()
			object:WaitUntilReady()
			p.reelTrove:Add(task.spawn(function()
				while object:WaitLogic(p.config.Interval) do
					if not (random2:NextNumber(0, 100) < p.config.TriggerChance) then
						continue
					end

					object:AddProgress(p.config.ProgressBoost)
					local clone = script.twisted:Clone()
					clone.Parent = object.reel_bar.fish
					object.renderTweens:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quart), {
						Size = UDim2.fromScale(30, 30),
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						ImageTransparency = 1,
						Rotation = 82
					}):Play()
					object.renderTweens:Create(clone.glow, TweenInfo.new(1, Enum.EasingStyle.Quart), {
						ImageColor3 = Color3.fromRGB(0, 0, 0),
						ImageTransparency = 1
					}):Play()
					fx:PlaySound(script.sfx, p2, random:NextNumber(0.6, 1.1))
					object:DelayRender(2, clone.Destroy, clone)
				end
			end))
		end)
	end
}
setmetatable(RelicConstructTwistedAttack, module)
return RelicConstructTwistedAttack