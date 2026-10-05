local NecroticRod = {}
game:GetService("ContentProvider")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local Trove = require(game.ReplicatedStorage.packages.Trove)
local maid = Trove.new()

function NecroticRod.Morph(_, instance, object)
	maid:AttachToInstance(instance)
	local icon_2 = instance:WaitForChild("fish"):WaitForChild("icon")
	icon_2.ImageTransparency = 0

	local function fastTween(p, p2, p3)
		return object.renderTweens:CreateAndPlay(p, p2, p3)
	end

	local function round(p)
		return math.round(p * 10) / 10
	end

	local function showFX(instance2)
		local shine = instance2.Shine
		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)
		local v = {
			ImageColor3 = Color3.fromRGB(145, 0, 0)
		}
		object.renderTweens:CreateAndPlay(shine, tweenInfo, v)
		local icon = instance2.fish.icon
		local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)
		local v2 = {
			ImageColor3 = Color3.fromRGB(145, 0, 0),
			Size = UDim2.fromScale(icon.Size.X.Scale * 1.1, icon.Size.Y.Scale * 1.1)
		}
		object.renderTweens:CreateAndPlay(icon, tweenInfo2, v2).Completed:Wait()
	end

	maid:Add(task.spawn(function()
		object:WaitUntilReady()
		local modifier = object:CreateModifier("resilience", "add")
		local modifier2 = object:CreateModifier("barSize", "multiply")
		local modifier3 = object:CreateModifier("progressefficiency", "force_add")

		while object:WaitLogic(2) and instance.Parent do
			local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
			local v = {
				Value = modifier2.Value * 0.9
			}
			object.renderTweens:CreateAndPlay(modifier2, tweenInfo, v)
			modifier3.Value += (object.progressefficiency + 1) * 0.1
			modifier.Value += 10
			showFX(instance)
		end
	end))
end

setmetatable(NecroticRod, module)
return NecroticRod