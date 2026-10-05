local RoseRod = {}
game:GetService("ContentProvider")
require(game.ReplicatedStorage.packages.Trove)
local module = require("./PassiveHandler")

function RoseRod.Morph(p, p2, object)
	local random = object:GetRandom(5)

	local function fastTween(p3, p4, p5)
		return object.logicTweens:CreateAndPlay(p3, p4, p5)
	end

	local function applyThorns(p3, p4: number?)
		local clone = script.thornsbar:Clone()
		clone.ImageTransparency = 1
		clone.Parent = p3.fish
		local clone2 = script.fishthorns:Clone()
		clone2.ImageTransparency = 1
		clone2.Parent = p3.fish.icon
		local tweenInfo = TweenInfo.new(0.5)
		object.logicTweens:CreateAndPlay(clone, tweenInfo, {
			ImageTransparency = 0
		})
		local tweenInfo2 = TweenInfo.new(0.5)
		object.logicTweens:CreateAndPlay(clone2, tweenInfo2, {
			ImageTransparency = 0
		})
		object:WaitLogic(0.5)

		if not p4 then
			return
		end

		object:WaitLogic(p4)
		local tweenInfo3 = TweenInfo.new(0.5)
		object.logicTweens:CreateAndPlay(clone, tweenInfo3, {
			ImageTransparency = 1
		})
		local tweenInfo4 = TweenInfo.new(0.5)
		object.logicTweens:CreateAndPlay(clone2, tweenInfo4, {
			ImageTransparency = 1
		})
		object:WaitLogic(0.5)
		clone:Destroy()
		clone2:Destroy()
	end

	object:Preload(script:GetChildren())
	p.reelTrove:Add(task.spawn(function()
		object:WaitUntilReady()

		while not (object.progress > 65) do
			if random:NextInteger(1, 100) <= 0 then
				object.core.fish:DelayNextMovement(2.5)
				object.logicTweens:CreateAndPlay(p2.fish, TweenInfo.new(0), {
					Position = UDim2.fromScale(p2.fish.Position.X.Scale, p2.fish.Position.Y.Scale)
				})
				applyThorns(p2, 1.5)
			end

			object:WaitLogic(0.8)
		end

		object.core.fish:DelayNextMovement(1e999)
		applyThorns(p2)
	end))
end

setmetatable(RoseRod, module)
return RoseRod