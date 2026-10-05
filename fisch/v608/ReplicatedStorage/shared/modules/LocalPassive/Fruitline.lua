local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local remoteEvent = Net:RemoteEvent("Fruitline/Collect")
local color = Color3.fromRGB(140, 110, 70)
local color2 = Color3.fromRGB(255, 214, 92)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo5 = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
local tweenInfo6 = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo7 = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo8 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo9 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo10 = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, true)

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

local Fruitline = {
	Morph = function(p, _, object)
		local config = p.config
		local random = object:GetRandom(41)
		local reel_bar = object.reel_bar
		local fruits = script:FindFirstChild("fruits")

		if not (reel_bar and fruits) then
			return
		end

		local children = fruits:GetChildren()

		if #children == 0 then
			return
		end

		local function fastTween(p2, p3, p4)
			return object.logicTweens:CreateAndPlay(p2, p3, p4)
		end

		local fish = reel_bar:FindFirstChild("fish")
		local icon = fish and fish:FindFirstChild("icon")
		local stroke = fish and fish:FindFirstChild("stroke")
		local imageColor3 = icon and icon.ImageColor3
		local size = icon and icon.Size
		local color3 = stroke and stroke.Color
		local trailSpacing = config.TrailSpacing or 0.07
		local spawnGap = config.SpawnGap or 0.01
		local fruitY = config.FruitY or 0.5
		local streakWindow = config.StreakWindow or 1.5
		local streakBonus = config.StreakBonus or 0
		local streakCap = config.StreakCap or 10
		local streakMilestone = config.StreakMilestone or 5
		local blessingGlow = config.BlessingGlow or 2
		local glowColor = config.GlowColor or color2
		object:AddModifier("barSize", "multiply", config.BarSizeMultiplier or 0.8)
		local clone = script.streaklabel:Clone()
		clone.TextColor3 = glowColor
		clone.TextTransparency = 1
		clone.Parent = reel_bar
		p.reelTrove:Add(clone)
		local size2 = clone.Size
		local v = {}
		local total = 0
		local barPosition = object.barPosition
		local barPosition2 = object.barPosition
		local v2 = -1
		local v3 = 0
		local v4 = -1e999
		local v5 = 0
		local v6 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeFruit(p2: number)
			local v7 = table.remove(v, p2)
			v7.bob:Cancel()
			v7.bob:Destroy()
			return v7.instance
		end

		p.reelTrove:Add(function()
			while #v > 0 do
				(removeFruit(#v)):Destroy()
			end
		end)

		local function setGlow(flag: boolean)
			v6 = flag
			local v7 = flag and tweenInfo8 or tweenInfo9

			if icon and imageColor3 then
				object.logicTweens:CreateAndPlay(icon, v7, {
					ImageColor3 = flag and glowColor or imageColor3
				})
			end

			if stroke and color3 then
				object.logicTweens:CreateAndPlay(stroke, v7, {
					Color = flag and glowColor or color3
				})
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pulseFish()
			if not (icon and size) then
				return
			end

			icon.Size = size
			local size3 = size
			local v9 = {
				Size = UDim2.new(size3.X.Scale * 1.2, size3.X.Offset * 1.2, size3.Y.Scale * 1.2, size3.Y.Offset * 1.2)
			}
			object.logicTweens:CreateAndPlay(icon, tweenInfo10, v9)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showStreak()
			clone.Text = `x{v3}`
			clone.TextTransparency = 0
			local size3 = size2
			clone.Size = UDim2.new(size3.X.Scale * 1.4, size3.X.Offset * 1.4, size3.Y.Scale * 1.4, size3.Y.Offset * 1.4)
			object.logicTweens:CreateAndPlay(clone, tweenInfo6, {
				Size = size2
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideStreak()
			object.logicTweens:CreateAndPlay(clone, tweenInfo7, {
				TextTransparency = 1
			})
		end

		local function spawnFruit(instance, position: number)
			local clone2 = instance:Clone()
			clone2.Position = UDim2.fromScale(position, fruitY - 0.6)
			clone2.Rotation = random:NextNumber(4, 9) * (random:NextInteger(0, 1) == 0 and -1 or 1)
			clone2.ImageTransparency = 1
			clone2.Visible = true
			clone2.Parent = reel_bar
			local v8 = {
				Position = UDim2.fromScale(position, fruitY),
				ImageTransparency = 0
			}
			object.logicTweens:CreateAndPlay(clone2, tweenInfo, v8)
			local bob = object.renderTweens:Create(clone2, tweenInfo2, {
				Rotation = -clone2.Rotation
			})
			bob:Play()
			table.insert(v, {
				instance = clone2,
				position = position,
				age = 0,
				bob = bob,
				spoiling = false
			})
		end

		local function eatFruit(i: number)
			local position = v[i].position
			local instance = removeFruit(i) -- equivalent call inferred; original call site unknown
			local now = os.clock()
			v3 = not (now - v4 <= streakWindow) and 1 or v3 + 1
			v4 = now
			v5 = now + blessingGlow
			local v8 = math.min(v3 - 1, streakCap)
			object:AddProgress(config.ProgressPerFruit * (1 + streakBonus * v8))
			remoteEvent:FireServer()
			fx:PlaySound(script.collect, script, v8 * 0.04 + 1)
			object.fx:SpawnShake(reel_bar, 0.15, 0.6, 0.01, false)

			if not v6 then
				setGlow(true)
			end

			if v3 >= 2 then
				showStreak() -- equivalent call inferred; original call site unknown
			end

			if v3 % streakMilestone == 0 then
				fx:PlaySound(script.streak, script)
				pulseFish() -- equivalent call inferred; original call site unknown
				object.fx:SpawnShake(reel_bar, 0.3, 0.8, 0.01, true)
			end

			local size3 = instance.Size
			local v10 = {
				ImageTransparency = 1,
				Size = UDim2.new(size3.X.Scale * 1.6, size3.X.Offset * 1.6, size3.Y.Scale * 1.6, size3.Y.Offset * 1.6),
				Position = UDim2.fromScale(position, fruitY - 0.9)
			}
			object.logicTweens:CreateAndPlay(instance, tweenInfo3, v10)
			object:DelayLogic(tweenInfo3.Time, instance.Destroy, instance)
		end

		local function dropFruit(i: number)
			local position = v[i].position
			local instance = removeFruit(i) -- equivalent call inferred; original call site unknown
			local v9 = {
				ImageTransparency = 1,
				Position = UDim2.fromScale(position, fruitY + 1.5),
				Rotation = instance.Rotation + 50
			}
			object.logicTweens:CreateAndPlay(instance, tweenInfo4, v9)
			object:DelayLogic(tweenInfo4.Time, instance.Destroy, instance)
		end

		p.reelTrove:Add(object.OnLogicStep:Connect(function(p2)
			if not object.active then
				return
			end

			local barPosition3 = object.barPosition
			local v7 = barPosition3 - barPosition2

			if math.abs(v7) > 0.0001 then
				v2 = v7 > 0 and 1 or -1
			end

			barPosition2 = barPosition3
			total += p2

			if total >= config.DropInterval and trailSpacing <= math.abs(barPosition3 - barPosition) then
				local v9 = children[random:NextInteger(1, #children)]
				local v10 = object.barSize * 0.5 + v9.Size.X.Scale * 0.5 + spawnGap
				local position = barPosition3 - v2 * v10

				if position > 0.02 and position < 0.98 and not object:IsInBar(position, config.CollectSize) then
					total = 0
					barPosition = barPosition3
					spawnFruit(v9, position)
				end
			end

			for i = #v, 1, -1 do
				local v8 = v[i]
				v8.age += p2

				if object:IsInBar(v8.position, config.CollectSize) then
					eatFruit(i)
				elseif v8.age >= config.FruitLifetime then
					dropFruit(i)
				elseif not v8.spoiling and v8.age >= config.FruitLifetime - 1.5 then
					v8.spoiling = true
					local instance = v8.instance
					object.logicTweens:CreateAndPlay(instance, tweenInfo5, {
						ImageColor3 = color
					})
				end
			end

			local now = os.clock()

			if v3 > 0 and streakWindow < now - v4 then
				v3 = 0
				hideStreak() -- equivalent call inferred; original call site unknown
			end

			if v6 and v5 <= now then
				setGlow(false)
			end
		end))
	end
}
setmetatable(Fruitline, module)
return Fruitline