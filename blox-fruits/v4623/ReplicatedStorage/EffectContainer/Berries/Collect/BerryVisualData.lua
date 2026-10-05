local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local pick = script.Pick
local idle = script.Idle
local touch = script.Touch
local BerryVisualData = {}

local function easeInOutQuart(p)
	if p < 0.5 then
		return 8 * p ^ 4
	end

	return 1 - (-2 * p + 2) ^ 4 / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInExpo(p)
	if p == 0 then
		return 0
	end

	return (math.pow(2, 10 * p - 10))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeInBack(p)
	return 2.70158 * p * p * p - 1.70158 * p * p
end

local function easeOutCubic(p)
	return p ^ 3
end

function easeInOutExpo(p)
	if p == 0 then
		return 0
	elseif p == 1 then
		return 1
	end

	if p < 0.5 then
		return math.pow(2, 20 * p - 10) / 2
	end

	return (2 - math.pow(2, -20 * p + 10)) / 2
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function cflerp(cframe, p, p2)
	return cframe:lerp(p, p2)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function determineGoal(position)
	if typeof(position) ~= Vector3 then
		position = position.Position or position
	end

	return position
end

local function getEmitterPairs(idle2)
	local children = idle2:GetChildren()
	local result = {}

	for _, emitter in ipairs(children) do
		if emitter:IsA("ParticleEmitter") then
			result[emitter] = {
				emitter:GetAttribute("EmitCount") or 1,
				emitter:GetAttribute("EmitDelay") or 0.2,
				os.clock()
			}
		end
	end

	return result
end

BerryVisualData.Variants = {
	[1] = {
		Name = "Red Cherry",
		AnimationIndex = 1,
		Colors = {
			Primary = Color3.fromRGB(214, 22, 29),
			Secondary = Color3.fromRGB(182, 0, 0),
			Tertiary = Color3.fromRGB(109, 0, 0)
		},
		Pick = pick.Default,
		Idle = idle.Default,
		Touch = touch.Default
	},
	[2] = {
		Name = "Orange",
		AnimationIndex = 1,
		Colors = {
			Primary = Color3.fromRGB(209, 139, 0),
			Secondary = Color3.fromRGB(190, 70, 0),
			Tertiary = Color3.fromRGB(198, 38, 0)
		},
		Pick = pick.Orange,
		Idle = idle.Orange,
		Touch = touch.Default
	},
	[3] = {
		Name = "Yellow Star",
		AnimationIndex = 6,
		Colors = {
			Primary = Color3.fromRGB(224, 227, 117),
			Secondary = Color3.fromRGB(240, 206, 28),
			Tertiary = Color3.fromRGB(181, 105, 0)
		},
		Pick = pick.Sparkle,
		Idle = idle.Sparkle,
		Touch = touch.Default
	},
	[4] = {
		Name = "Green Toad",
		AnimationIndex = 2,
		Colors = {
			Primary = Color3.fromRGB(136, 228, 43),
			Secondary = Color3.fromRGB(107, 183, 35),
			Tertiary = Color3.fromRGB(81, 138, 26)
		},
		Pick = pick.Default,
		Idle = idle.Default,
		Touch = touch.Default
	},
	[5] = {
		Name = "Blue Icicle",
		AnimationIndex = 4,
		Colors = {
			Primary = Color3.fromRGB(103, 170, 254),
			Secondary = Color3.fromRGB(59, 90, 253),
			Tertiary = Color3.fromRGB(37, 42, 242)
		},
		Pick = pick.Frosty,
		Idle = idle.Frosty,
		Touch = touch.Default
	},
	[6] = {
		Name = "Purple Jelly",
		AnimationIndex = 5,
		Colors = {
			Primary = Color3.fromRGB(156, 0, 178),
			Secondary = Color3.fromRGB(135, 2, 166),
			Tertiary = Color3.fromRGB(57, 1, 80)
		},
		Pick = pick.Purple,
		Idle = idle.Purple,
		Touch = touch.Default
	},
	[7] = {
		Name = "Pink Pig",
		AnimationIndex = 3,
		Colors = {
			Primary = Color3.fromRGB(214, 120, 220),
			Secondary = Color3.fromRGB(172, 2, 141),
			Tertiary = Color3.fromRGB(206, 17, 111)
		},
		Pick = pick.Sparkle,
		Idle = idle.Default,
		Touch = touch.Default
	},
	[8] = {
		Name = "White Cloud",
		AnimationIndex = 6,
		Colors = {
			Primary = Color3.fromRGB(230, 238, 255),
			Secondary = Color3.fromRGB(125, 135, 159),
			Tertiary = Color3.fromRGB(98, 102, 127)
		},
		Pick = pick.Smoke,
		Idle = idle.Smoke,
		Touch = touch.Default
	},
	[98] = {
		Name = "FireFlower",
		AnimationIndex = 4,
		Colors = {
			Primary = Color3.fromRGB(255, 55, 4),
			Secondary = Color3.fromRGB(255, 208, 141),
			Tertiary = Color3.fromRGB(71, 12, 0)
		},
		Pick = pick.FireFlower,
		Idle = idle.FireFlower,
		Touch = touch.FireFlower,
		CollectSound = "FireFlower",
		Model = game.ReplicatedStorage.Assets.Models.DracoFireFlower
	},
	[99] = {
		Name = "Debug",
		Colors = {
			Primary = Color3.fromRGB(0, 0, 0),
			Secondary = Color3.fromRGB(128, 0, 213),
			Tertiary = Color3.fromRGB(103, 90, 127)
		}
	}
}
BerryVisualData.Animations = {
	function(instance, p, p2, p3)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local cframe = CFrame.new(p, v)
		local v2

		if typeof(p2) == Vector3 then
			v2 = p2
		else
			v2 = p2.Position or p2
		end

		local _ = CFrame.new(v2) * (cframe - cframe.Position)
		local v3 = {
			CFrame.new(math.random(-10, 10), math.random(10, 20), 0),
			CFrame.new(math.random(-10, 10), math.random(10, 15), 0)
		}
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local lastTime = os.clock()
		os.clock()

		while true do
			local v4 = os.clock() - lastTime

			if p3 < v4 then
				break
			end

			local v5

			if typeof(p2) == Vector3 then
				v5 = p2
			else
				v5 = p2.Position or p2
			end

			local v6 = CFrame.new(v5) * (cframe - cframe.Position)
			local v7 = { cframe:lerp(v6, 0.33) * v3[1], cframe:lerp(v6, 0.66) * v3[2] }
			local p4 = v7[1].p
			local p5 = v7[2].p
			local v9

			if typeof(p2) == Vector3 then
				v9 = p2
			else
				v9 = p2.Position or p2
			end

			local v10 = (v4 / p3) ^ 3
			local v11, v12, v13, v14 = unpack({
				p,
				p4,
				p5,
				v9
			})
			local v15 = cubicBezier(v10, v11, v12, v13, v14)
			instance:PivotTo(CFrame.new(v15))

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end

			RunService.Heartbeat:Wait()
		end
	end,
	function(instance, p, p2, p3)
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local v2 = p + (v - p) * 0.5
		local ray, v3, _ = Util.Ray(
			v2,
			CFrame.new(v2 + createVector(0, 10, 0)).UpVector.Unit * -20,
			{ workspace.Characters, workspace.Enemies },
			false
		)
		local v4 = { Vector3.new(0, math.random(15, 20), 0), (Vector3.new(0, math.random(6, 10), 0)) }
		local v6 = p + (v2 - p) * 0.33 + createVector(0, 15, 0)
		local v7 = p + (v2 - p) * 0.66 + createVector(0, 6, 0)
		local v8

		if ray then
			v8 = v3 or v2
		else
			v8 = v2
		end

		local v5 = {
			p,
			v6,
			v7,
			v8
		}
		local v9 = p3 / 2
		local lastTime = os.clock()
		os.clock()

		while true do
			local v10 = os.clock() - lastTime

			if p3 < v10 then
				break
			end

			local position

			if typeof(p2) == Vector3 then
				position = p2
			else
				position = p2.Position or p2
			end

			local v11 = {
				v5[4],
				v2 + (position - v2) * 0.33 + v4[1],
				v2 + (position - v2) * 0.66 + v4[2],
				position
			}
			local v12

			if v10 < v9 then
				local v13 = v10 / v9
				local v14, v15, v16, v17 = unpack(v5)
				v12 = cubicBezier(v13, v14, v15, v16, v17)
			else
				local v13 = (v10 - v9) / v9
				local v14, v15, v16, v17 = unpack(v11)
				v12 = cubicBezier(v13, v14, v15, v16, v17)
			end

			instance:PivotTo(CFrame.new(v12))

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end

			RunService.Heartbeat:Wait()
		end
	end,
	function(instance, p, p2, p3)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local cframe = CFrame.new(p, v)
		local v2

		if typeof(p2) == Vector3 then
			v2 = p2
		else
			v2 = p2.Position or p2
		end

		local _ = CFrame.new(v2) * (cframe - cframe.Position)
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local v3 = 1.57 / p3
		local lastTime = os.clock()
		local v4 = 0.016666666666666666

		while true do
			local _ = v4 * 60
			local v5 = os.clock() - lastTime

			if p3 < v5 then
				break
			end

			local v6

			if typeof(p2) == Vector3 then
				v6 = p2
			else
				v6 = p2.Position or p2
			end

			local cframe2 = CFrame.new(p, v6)
			local v7

			if typeof(p2) == Vector3 then
				v7 = p2
			else
				v7 = p2.Position or p2
			end

			local v8 = CFrame.new(v7) * (cframe2 - cframe2.Position)
			local v9 = v5 / p3 * 20 * math.abs((math.cos(v5 * v3)))
			local _ = v5 < p3 / 2
			instance:PivotTo(CFrame.new(cframe2.Position, v8.Position):lerp(v8, v5 / p3) * CFrame.new(
				v9 * math.cos(20 * v5),
				v9 * math.sin(20 * v5),
				0
			))

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end

			v4 = RunService.Heartbeat:Wait()
		end
	end,
	function(instance, p, p2, p3)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local cframe = CFrame.new(p, v)
		local v2

		if typeof(p2) == Vector3 then
			v2 = p2
		else
			v2 = p2.Position or p2
		end

		local _ = CFrame.new(v2) * (cframe - cframe.Position)
		local v3 = {
			CFrame.new(math.random(-15, -10), math.random(10, 15), math.random(-15, 15)),
			CFrame.new(math.random(9, 12), math.random(6, 9), math.random(-10, 10)),
			CFrame.new(math.random(-10, -5), math.random(6, 8), math.random(-5, 5))
		}
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local lastTime = os.clock()
		os.clock()
		local v4 = p3 / 4
		local v5 = 0.016666666666666666
		local total = 0

		while true do
			local v6 = os.clock() - lastTime

			if p3 < v6 then
				break
			end

			local v7

			if typeof(p2) == Vector3 then
				v7 = p2
			else
				v7 = p2.Position or p2
			end

			local v8 = CFrame.new(v7) * (cframe - cframe.Position)
			total += v5 * 10 * 60
			local v9 = {
				cframe:lerp(v8, 0.25) * v3[1],
				cframe:lerp(v8, 0.5) * v3[2],
				cframe:lerp(v8, 0.75) * v3[3],
				cflerp(cframe, v8, 1)
			}

			if v6 < v4 then
				local position = cframe.Position
				local position2 = v9[1].Position
				local v10 = easeInOutExpo(v6 / v4)
				instance:PivotTo(CFrame.new(position + (position2 - position) * v10) * CFrame.Angles(
					0,
					math.rad(total),
					0
				))
			elseif v6 < v4 * 2 then
				local position = v9[1].Position
				local position2 = v9[2].Position
				local v10 = easeInOutExpo((v6 - v4) / v4)
				instance:PivotTo(CFrame.new(position + (position2 - position) * v10) * CFrame.Angles(
					0,
					math.rad(total),
					0
				))
			elseif v6 < v4 * 3 then
				local position = v9[2].Position
				local position2 = v9[3].Position
				local v10 = easeInOutExpo((v6 - v4 * 2) / v4)
				instance:PivotTo(CFrame.new(position + (position2 - position) * v10) * CFrame.Angles(
					0,
					math.rad(total),
					0
				))
			elseif v6 < p3 then
				local position = v9[3].Position
				local position2 = v9[4].Position
				local v10 = easeInOutExpo((v6 - v4 * 3) / v4)
				instance:PivotTo(CFrame.new(position + (position2 - position) * v10) * CFrame.Angles(
					0,
					math.rad(total),
					0
				))
			end

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end

			v5 = RunService.Heartbeat:Wait()
		end
	end,
	function(instance, p, p2, p3)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local cframe = CFrame.new(p, v)
		local v2

		if typeof(p2) == Vector3 then
			v2 = p2
		else
			v2 = p2.Position or p2
		end

		local _ = CFrame.new(v2) * (cframe - cframe.Position)
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local v3 = 1.57 / p3
		local lastTime = os.clock()
		local v4 = 0.016666666666666666

		while true do
			local _ = v4 * 60
			local v5 = os.clock() - lastTime

			if p3 < v5 then
				break
			end

			local v6

			if typeof(p2) == Vector3 then
				v6 = p2
			else
				v6 = p2.Position or p2
			end

			local cframe2 = CFrame.new(p, v6)
			local v7

			if typeof(p2) == Vector3 then
				v7 = p2
			else
				v7 = p2.Position or p2
			end

			local v8 = CFrame.new(v7) * (cframe2 - cframe2.Position)
			local v9 = v5 / p3 * 20 * math.abs((math.cos(v5 * v3)))
			local _ = v5 < p3 / 2
			instance:PivotTo(CFrame.new(cframe2.Position, v8.Position):lerp(v8, v5 / p3) * CFrame.new(
				v9 * math.cos(20 * v5),
				0,
				0
			))

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end

			v4 = RunService.Heartbeat:Wait()
		end
	end,
	function(instance, p, p2, p3)
		local v

		if typeof(p2) == Vector3 then
			v = p2
		else
			v = p2.Position or p2
		end

		local cframe = CFrame.new(p, v)
		local v2

		if typeof(p2) == Vector3 then
			v2 = p2
		else
			v2 = p2.Position or p2
		end

		local _ = CFrame.new(v2) * (cframe - cframe.Position)
		local emitterPairs = getEmitterPairs(instance._Base.Idle)
		local lastTime = os.clock()
		local v3 = p3 * 0.5
		local v4 = p3 * 0.9
		local v5 = 4
		local total = 0
		local v6 = 0

		while true do
			local v7 = RunService.Heartbeat:Wait() * 60
			local v8 = os.clock() - lastTime

			if p3 < v8 then
				break
			end

			if v3 < v8 then
				v5 -= v7 * 0.25
				total += v7 * 0.01
			else
				total += v7 * 0.1
			end

			if v4 < v8 then
				v6 = 8 + -8 * easeInBack((v8 - v4) / (p3 * 0.1))
			end

			local v9 = instance.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(v5) * v7, 0) * CFrame.new(
				0,
				math.sin(total) * 0.8 * v7,
				v7 * -0.5
			)
			local v10 = 0.01 + 0.99 * math.min(1, v8 / p3)
			local v12

			if typeof(p2) == Vector3 then
				v12 = p2
			else
				v12 = p2.Position or p2
			end

			instance:PivotTo(cflerp(v9, CFrame.new(v12) * CFrame.new(0, v4 < v8 and v6 or 8, 0), easeInExpo(v10)))

			for k, nows in pairs(emitterPairs) do
				if not (os.clock() - nows[3] > nows[2]) then
					continue
				end

				k:Emit(nows[1])
				nows[3] = os.clock()
			end
		end
	end
}
local v = {}

for i, variant in ipairs(BerryVisualData.Variants) do
	v[variant.Name] = i
end

function BerryVisualData.trimModelName(value)
	local v2 = string.lower("Berry")

	if string.lower(value):sub(-5) == v2 then
		return (tostring(string.gsub(value:sub(1, #value - 5), "^%s*(.-)%s*$", "%1")))
	end

	return value
end

function BerryVisualData.dataFromName(p)
	local trimModelName = BerryVisualData.trimModelName(p)

	if BerryVisualData.Variants[v[trimModelName]] then
		return BerryVisualData.Variants[v[trimModelName]]
	end

	return nil
end

function BerryVisualData.indexFromName(p)
	local trimModelName = BerryVisualData.trimModelName(p)

	for k, variant in pairs(BerryVisualData.Variants) do
		if trimModelName:lower() == variant.Name:lower() then
			return k
		end
	end

	return 1
end

return BerryVisualData