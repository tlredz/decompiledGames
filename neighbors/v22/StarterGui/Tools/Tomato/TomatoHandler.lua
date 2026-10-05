game.Players.LocalPlayer:GetMouse()
local sounds = script:WaitForChild("Sounds")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Network = require(game.ReplicatedStorage.Modules.Network)
local tomatoBlur = game.Lighting:FindFirstChild("TomatoBlur") or Instance.new("BlurEffect", game.Lighting)
tomatoBlur.Name = "TomatoBlur"
tomatoBlur.Size = 0
tomatoBlur.Enabled = true
local v = 0

local function random(p, p2)
	return p + (p2 - p) * math.random()
end

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function play_random_Snowball_sound()
	local clone = script.SnowSounds:GetChildren()[math.random(1, #script.SnowSounds:GetChildren())]:Clone()
	clone.Parent = workspace
	clone:Play()

	if clone:GetAttribute("Delay") then
		clone.TimePosition = clone:GetAttribute("Delay")
	end

	clone.Ended:connect(function()
		clone:Destroy()
	end)
end

local function play_random_Tomato_sound()
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

local function place_Tomato_effect(color, p, image)
	local v2 = 0.8 + 0.5 * math.random()
	local clone

	if p == "snowball" then
		clone = script.Snow:Clone()
	elseif p == "Water" then
		clone = script.Water:Clone()
	else
		clone = script.Sample:Clone()
		v2 = 0.4 + 0.4 * math.random()
	end

	if image then
		clone.Image = image
	end

	if p == "snowball" or not color then
		color = Color3.new(1, 1, 1)
	end

	clone.ImageColor3 = color
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

local function splatter(p, p2, image)
	place_Tomato_effect(p, p2, image)
end

local function hearts()
	for _ = 1, math.random(6, 7) do
		local clone = script.Heart:Clone()
		local _ = 0.8 + 0.5 * math.random()
		clone.Size = UDim2.fromScale(0, 0)
		clone.Position = generate_random_position()
		clone.Rotation = math.random(-5, 5)
		clone.Parent = script.Parent
		TweenService:Create(clone, TweenInfo.new(0.71, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0.096, 0, -0.042, 250)
		}):Play()
		task.delay(3, function()
			TweenService:Create(
				clone,
				TweenInfo.new(math.random(50, 150) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = UDim2.new(0, 0, 0, 0)
				}
			):Play()
		end)
		Debris:AddItem(clone, 5)
		task.wait(math.random(20, 40) / 1000)
	end
end

Network:listen("Tomato", function(p, image)
	if p == "Hearts" then
		hearts()
	elseif p == "Water" then
		place_Tomato_effect(Color3.fromRGB(83, 218, 255), "Water", nil)
	elseif p == Color3.fromRGB(229, 229, 229) then
		play_random_Snowball_sound()
		place_Tomato_effect(p, "snowball", nil)
	else
		play_random_Tomato_sound()
		place_Tomato_effect(p, nil, image)
	end
end)
local RunService2 = game:GetService("RunService")
RunService2.Heartbeat:connect(function(p)
	local v2 = tomatoBlur
	local size = tomatoBlur.Size
	local v3 = v * 1
	local v4 = p * 15
	v2.Size = size + (v3 - size) * v4
end)