game.Players.LocalPlayer:GetMouse()
local sounds = script:WaitForChild("Sounds")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Network = require(game.ReplicatedStorage.Modules.Network)
local spitBlur = game.Lighting:FindFirstChild("SpitBlur") or Instance.new("BlurEffect", game.Lighting)
spitBlur.Name = "SpitBlur"
spitBlur.Size = 0
spitBlur.Enabled = true
local v = 0

local function random(p, p2)
	return p + (p2 - p) * math.random()
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function play_random_spit_sound()
	local clone = sounds:GetChildren()[math.random(1, #sounds:GetChildren())]:Clone()
	clone.Parent = workspace
	clone:Play()

	if clone:GetAttribute("Delay") then
		clone.TimePosition = clone:GetAttribute("Delay")
	end

	clone.Ended:connect(function()
		clone:Destroy()
	end)
end

local function n_to_udim2(p)
	return UDim2.new(p, 0, p, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function generate_random_position()
	local v2 = math.random() * 2 * 3.141592653589793
	local v3 = 0 + 0.4 * math.random()
	return UDim2.new(0.5 + v3 * math.cos(v2), 0, 0.5 + v3 * math.sin(v2), 0)
end

local function place_spit_effect()
	local v2 = 0.4 + 0.4 * math.random()
	local clone = script.Sample:Clone()
	clone.ImageTransparency = 0.3
	clone.Rotation = math.random() * 360
	clone.Size = UDim2.new(0, 0, 0, 0)
	clone.Position = generate_random_position()
	v += 1
	clone.Parent = script.Parent
	TweenService:Create(clone, TweenInfo.new(0.2), {
		Size = UDim2.new(v2, 0, v2, 0)
	}):Play()
	task.delay(0.5 + 1 * math.random(), function()
		task.delay(1 + 1 * math.random(), function()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.5 + 0.5 * math.random(), Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					ImageTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:connect(function()
				clone:Destroy()
				v -= 1
			end)
		end)
		local v3 = (0.5 + 1 * math.random()) * (math.random(1, 2) == 1 and -1 or 1)
		local v4 = -(60 + 40 * math.random())
		local v5 = -20 + 40 * math.random()
		local total = 0
		local total2 = -70
		task.spawn(function()
			local lastTime = os.clock()
			local total3 = 0

			while true do
				local v6 = os.clock() - lastTime
				local v7 = RunService.Heartbeat:wait()
				total2 += v4 * v7
				total += v5 * v7
				total3 += v7

				if not clone.Parent then
					continue
				end

				local position = clone.Position
				clone.Position = UDim2.new(position.X.Scale, math.sin(v3 * v6) * 0, position.Y.Scale, position.Y.Offset) + UDim2.new(
					0,
					0,
					0,
					-total2 * v7
				)
				clone.Rotation += total * v7
			end
		end)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function splatter()
	for _ = 1, math.random(3, 14) do
		place_spit_effect()
	end
end

Network:listen("Spit", function()
	play_random_spit_sound()
	splatter() -- equivalent call inferred; original call site unknown
end)
local RunService2 = game:GetService("RunService")
RunService2.Heartbeat:connect(function(p)
	local v2 = spitBlur
	local size = spitBlur.Size
	local v3 = v * 1
	local v4 = p * 15
	v2.Size = size + (v3 - size) * v4
end)