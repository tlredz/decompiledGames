local SpookyRod = {}
game:GetService("ContentProvider")
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function SpookyRod.Morph(p, parent2, object)
	object:Preload(script:GetChildren())
	local random = object:GetRandom(5)

	local function fastTween(...)
		return object.logicTweens:CreateAndPlay(...)
	end

	local function burn(parent)
		local clone = script.flame:Clone()
		clone.ZIndex = 1
		clone.ImageTransparency = 1
		local size = clone.Size
		clone.Size = UDim2.fromScale(0, 0)
		clone.Parent = parent
		script.Sound:Play()
		local fish = parent.fish
		local stroke = fish.stroke

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updPos()
			clone.Position = UDim2.new(fish.Position.X.Scale, 0, fish.Position.Y.Scale, -15)
		end

		fish.Changed:Connect(updPos)
		updPos() -- equivalent call inferred; original call site unknown
		fastTween(fish, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(91, 64, 59)
		})
		fastTween(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(255, 179, 92)
		})
		fastTween(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0.15,
			Size = size
		}).Completed:Wait()
		fastTween(fish, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(67, 75, 91)
		})
		fastTween(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(141, 161, 191)
		})
		object:WaitLogic(0.5)
		fastTween(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			ImageTransparency = 1,
			Size = UDim2.fromScale(0, 0)
		}).Completed:Wait()
		clone:Destroy()
	end

	local v = 1
	p.reelTrove:Add(object.OnLogicStep:Connect(function(p3)
		if not object.active then
			return
		end

		v -= p3

		if v <= 0 then
			v += 1

			if random:NextInteger(1, 100) <= 50 then
				p.current.core.fish:DelayNextMovement(0.5)
				object:AddProgress(4)
				burn(parent2)
			end
		end
	end))
end

setmetatable(SpookyRod, module)
return SpookyRod