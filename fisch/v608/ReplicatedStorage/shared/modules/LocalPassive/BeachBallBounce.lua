game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local BeachBallBounce = {
	Morph = function(p, _, object)
		local reel_bar = object.reel_bar

		if not reel_bar then
			return
		end

		local v = (p.config.HitProgressSpeed or 5) / 100
		local initialProgress = p.config.InitialProgress or 30
		local v2 = v / 3
		local modifier = object:CreateModifier("progressefficiency", "add")
		local clone = script:WaitForChild("BeachBall"):Clone()
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Visible = false
		clone.Parent = reel_bar
		p.reelTrove:Add(clone)
		local icon = clone:FindFirstChild("Icon")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getFloorY()
			return -((icon and icon.AbsoluteSize.Y or clone.AbsoluteSize.Y) / math.max(reel_bar.AbsoluteSize.Y, 1) * 0.5) + 0
		end

		local random = object:GetRandom(777)
		local v3 = 0.5
		local floorY = getFloorY() -- equivalent call inferred; original call site unknown
		local v4 = (random:NextNumber(0, 1) < 0.5 and -1 or 1) * 2
		local v5 = -16
		local total = 0
		local v6 = 0
		local v7 = false
		local v8 = false

		local function registerHit()
			local v9 = math.max(object.barSize * 0.5, 0.02)
			local v10 = math.clamp((v3 - object.barPosition) / v9, -1, 1)
			v4 = v10 * 3
			v5 = -16
			v6 = v10 * 300 + random:NextNumber(-80, 80)
			modifier.Value += v
			object.fx:SpawnShake(object.reel_bar, 0.2, 1.5, 0.01, true)

			if not v8 then
				v8 = true
				object:AddProgress(initialProgress)
			end
		end

		task.spawn(function()
			object:WaitUntilReady()
			local fishPosition = object.fishPosition
			clone.Position = UDim2.fromScale(fishPosition, -18)
			clone.Visible = true
			local v9 = object.logicTweens:Create(
				clone,
				TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					Position = UDim2.fromScale(fishPosition, getFloorY())
				}
			)
			p.reelTrove:Add(v9.Completed:Once(function()
				object.fx:SpawnShake(object.reel_bar, 0.3, 3, 0.01, true)
				local floorY2 = getFloorY() -- equivalent call inferred; original call site unknown
				v3 = fishPosition
				floorY = floorY2
				v7 = true
				local v11 = clone.AbsoluteSize.X / math.max(reel_bar.AbsoluteSize.X, 1) * 0.5

				if object:IsInBar(v3, v11 + 0.15) then
					registerHit()
				else
					v5 = -16
				end
			end))
			v9:Play()
		end)
		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not (object.active and v7) then
				return
			end

			local v9 = clone.AbsoluteSize.X / math.max(reel_bar.AbsoluteSize.X, 1) * 0.5
			v5 += 20 * p2
			v4 -= v4 * 0.3 * p2
			v3 += v4 * p2
			floorY += v5 * p2

			if v3 <= v9 then
				v3 = v9
				v4 = math.abs(v4) * 0.85
			else
				local v10 = v3

				if 1 - v9 <= v10 then
					v3 = 1 - v9
					v4 = -math.abs(v4) * 0.85
				end
			end

			v4 = math.clamp(v4, -5, 5)

			if floorY <= -18 then
				floorY = -18
				v5 = math.abs(v5) * 0.85
			end

			local floorY2 = getFloorY() -- equivalent call inferred; original call site unknown

			if v5 > 0 and floorY2 <= floorY then
				floorY = floorY2

				if object:IsInBar(v3, v9 + 0.15) then
					registerHit()
				else
					v5 = -math.max(math.abs(v5) * 0.85, 11)
				end
			end

			total += (v6 + v4 * 40) * p2
			v6 -= v6 * 0.5 * p2
			clone.Position = UDim2.fromScale(v3, floorY)
			clone.Rotation = total

			if modifier.Value > 0 then
				modifier.Value = math.max(0, modifier.Value - v2 * p2)
			end
		end))
	end
}
setmetatable(BeachBallBounce, module)
return BeachBallBounce