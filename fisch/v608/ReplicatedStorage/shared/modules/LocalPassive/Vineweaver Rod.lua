local VineweaverRod = {}
game:GetService("ContentProvider")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
require(game.ReplicatedStorage.packages.Trove)

function VineweaverRod.Morph(p, p2, object)
	local random = object:GetRandom(5)

	local function fastTween(...)
		return object.logicTweens:CreateAndPlay(...)
	end

	local function tangle(p3, p4)
		local clone = script.vinesbar:Clone()
		clone.ImageTransparency = 1
		clone.Parent = p3.fish
		local clone2 = script.fishvines:Clone()
		clone2.ImageTransparency = 1
		clone2.Parent = p3.fish.icon
		fastTween(clone, TweenInfo.new(0.5), {
			ImageTransparency = 0
		})
		fastTween(clone2, TweenInfo.new(0.5), {
			ImageTransparency = 0
		})
		object:WaitLogic(0.5)

		if not p4 then
			return
		end

		object:WaitLogic(p4)
		fastTween(clone, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		fastTween(clone2, TweenInfo.new(0.5), {
			ImageTransparency = 1
		})
		object:WaitLogic(0.5)
		clone:Destroy()
		clone2:Destroy()
	end

	object:Preload({ script })
	p.reelTrove:Add(task.spawn(function()
		object:WaitUntilReady()

		while not (object.progress > 70) do
			if random:NextInteger(1, 100) <= 10 then
				object.core.fish:DelayNextMovement(2)
				object.logicTweens:Create(p2.fish, TweenInfo.new(0), {
					Position = UDim2.fromScale(p2.fish.Position.X.Scale, p2.fish.Position.Y.Scale)
				}):Play()
				tangle(p2, 1)
			end

			object:WaitLogic(1)
		end

		object.core.fish:DelayNextMovement(1e999)
		tangle(p2)
	end))
end

setmetatable(VineweaverRod, module)
return VineweaverRod