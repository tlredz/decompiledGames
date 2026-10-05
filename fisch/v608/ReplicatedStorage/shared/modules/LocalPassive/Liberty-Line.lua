local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local v = {
	Color3.fromRGB(255, 60, 60),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(70, 130, 255),
	Color3.fromRGB(255, 220, 120)
}
local firework = script:FindFirstChild("Firework")
local spark = script:FindFirstChild("Spark")
local LibertyLine = {
	Morph = function(p, p2, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local initialProgress = p.config.InitialProgress or 30
		local repeatProgress = p.config.RepeatProgress or 5
		local minDelay = p.config.MinDelay or 1.5
		local maxDelay = p.config.MaxDelay or 3.5

		if not (firework and spark) then
			task.spawn(function()
				object:WaitUntilReady()
				object:AddProgress(initialProgress)
			end)
			return
		end

		local random = Random.new()

		local function fishCentre()
			local fishPosition = object.fishPosition
			local fish = reel_bar:FindFirstChild("fish")
			local icon = fish and fish:FindFirstChild("icon")
			local v2

			if icon and icon.AbsoluteSize.X > 0 then
				local absolutePosition = reel_bar.AbsolutePosition
				local absoluteSize = reel_bar.AbsoluteSize
				local v3 = icon.AbsolutePosition + icon.AbsoluteSize * 0.5
				fishPosition = (v3.X - absolutePosition.X) / math.max(absoluteSize.X, 1)
				v2 = (v3.Y - absolutePosition.Y) / math.max(absoluteSize.Y, 1)
			else
				v2 = 0.5
			end

			return fishPosition, v2
		end

		local function spawnBurst(p3: number, p4: number)
			local v2 = math.max(reel_bar.AbsoluteSize.X, 1)
			local v3 = math.max(reel_bar.AbsoluteSize.Y, 1)
			local v4 = v3 * 1.7
			local clone = spark:Clone()
			clone.BackgroundColor3 = Color3.fromRGB(255, 255, 240)
			clone.Size = UDim2.fromScale(0.05, 0.05)
			clone.Position = UDim2.fromScale(p3, p4)
			clone.Visible = true
			clone.Parent = reel_bar
			p.reelTrove:Add(clone)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.fromScale(1.4, 1.4),
					BackgroundTransparency = 1
				}
			)
			tween.Completed:Once(function()
				clone:Destroy()
			end)
			tween:Play()

			for i = 1, 34 do
				local clone2 = spark:Clone()
				clone2.BackgroundColor3 = v[random:NextInteger(1, #v)]
				local v5 = 0.18 * random:NextNumber(0.5, 1.5)
				clone2.Size = UDim2.fromScale(v5, v5)
				clone2.Position = UDim2.fromScale(p3, p4)
				clone2.Visible = true
				clone2.Parent = reel_bar
				p.reelTrove:Add(clone2)
				local v6 = i / 34 * 3.141592653589793 * 2 + random:NextNumber(-0.25, 0.25)
				local v7 = v4 * random:NextNumber(0.4, 1.3)
				local v8 = math.cos(v6) * v7 / v2
				local v9 = math.sin(v6) * v7 / v3 + 0.25
				local uDim = UDim2.fromScale(p3 + v8, p4 + v9)
				local tween2 = TweenService:Create(
					clone2,
					TweenInfo.new(random:NextNumber(0.7, 1.3), Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = uDim,
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0, 0)
					}
				)
				tween2.Completed:Once(function()
					clone2:Destroy()
				end)
				tween2:Play()
			end
		end

		local function dropFirework(p3: number)
			local clone = firework:Clone()
			clone.Visible = false
			clone.Parent = reel_bar
			p.reelTrove:Add(clone)
			local v2, v3 = fishCentre()
			local v4 = v3 - clone.AbsoluteSize.Y / math.max(reel_bar.AbsoluteSize.Y, 1) * 0.5
			clone.Position = UDim2.fromScale(v2, -18)
			clone.Visible = true
			local v5 = object.logicTweens:Create(
				clone,
				TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Position = UDim2.fromScale(v2, v4)
				}
			)
			p.reelTrove:Add(v5.Completed:Once(function()
				object.fx:SpawnShake(object.reel_bar, 0.5, 5, 0.01, true)
				fx:PlaySound(script.Pop, p2, true)
				fx:PlaySound(script.Bang, p2, true)
				object:AddProgress(p3)
				clone.Visible = false
				spawnBurst(v2, v3)
				object:DelayLogic(0.6, function()
					if clone then
						clone:Destroy()
					end
				end)
			end))
			v5:Play()
		end

		task.spawn(function()
			object:WaitUntilReady()
			dropFirework(initialProgress)

			while object.active and reel_bar.Parent do
				local libertyFireworkDelay = ReplicatedStorage:GetAttribute("LibertyFireworkDelay")

				if typeof(libertyFireworkDelay) == "number" and libertyFireworkDelay > 0 then
					object:WaitLogic(libertyFireworkDelay)
				else
					object:WaitLogic(random:NextNumber(minDelay, maxDelay))
				end

				if object.active and reel_bar.Parent then
					dropFirework(repeatProgress)
				else
					break
				end
			end
		end)
	end
}
setmetatable(LibertyLine, module)
return LibertyLine