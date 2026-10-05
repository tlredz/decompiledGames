local Acidgrinder = {}
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("Acidgrinder/SetChainSpeed")

function Acidgrinder.Morph(p, parent, object)
	local config = p.config
	local modifier = object:CreateModifier("progressefficiency", "add")
	local modifier2 = object:CreateModifier("progressefficiency", "force_add")
	modifier.Value = 0
	local v = 0
	local total = 0
	local v2 = false
	local v3 = -1
	local v4 = 0
	local clone = script.power:Clone()
	local fill = clone.Bar.Fill
	local label = clone:FindFirstChild("Label")
	clone.Parent = parent
	object.trove:Add(clone)

	if label then
		object:DelayLogic(2, function()
			if not label.Parent then
				return
			end

			object.renderTweens:CreateAndPlay(label, TweenInfo.new(0.5), {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			})
		end)
	end

	object.OnBarDirectionChange:Connect(function(p2: number)
		v2 = p2 > 0
	end)
	v2 = object.core.rod.CurrentInputDirection > 0 or v2
	object.trove:Add(object.OnLogicStep:Connect(function(p2: number)
		if object.isPaused then
			return
		end

		local v5

		if v2 then
			v5 = config.RampUpTime
		else
			v5 = config.RampDownTime
		end

		local v6 = (v2 and 1 or -1) * (p2 / v5)
		v = math.clamp(v + v6, 0, 1)
		local value = TweenService:GetValue(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		modifier.Value = (config.MaxSpeedMult - 1) * value * 0.5
		modifier2.Value = (config.MaxSpeedMult - 1) * value * 0.5
		total += (value - total) * math.min(p2 * 12, 1)
		fill.Size = UDim2.fromScale(total, 1)

		if v >= 0.4 then
			local now = tick()

			if now - v4 >= 0.08 then
				v4 = now
				local v7 = (v - 0.4) / 0.6 * 0.075 + 0.025
				object.fx:SpawnShake(object.reel_bar, v7, 0.096, 0.01, false)
			end
		end

		local v7 = v < 0.1 and 0 or v < 0.4 and 1 or 2

		if v7 ~= v3 then
			v3 = v7
			remoteEvent:FireServer(v7)
		end
	end))
	object.trove:Add(function()
		if v3 ~= 0 then
			remoteEvent:FireServer(0)
		end
	end)
end

setmetatable(Acidgrinder, module)
return Acidgrinder