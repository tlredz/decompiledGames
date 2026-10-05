local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserEmoteToRunThresholdChange")
end)
local v = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPlayEmoteByIdAnimTrackReturn2")
end)
local v2 = success3 and result3
local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local v3 = {}
local v4 = {}
local v5 = {
	idle = {},
	walk = {
		{
			id = "http://www.roblox.com/asset/?id=507777826",
			weight = 10
		}
	},
	run = {
		{
			id = "http://www.roblox.com/asset/?id=507767714",
			weight = 10
		}
	},
	swim = {
		{
			id = "http://www.roblox.com/asset/?id=507784897",
			weight = 10
		}
	},
	swimidle = {
		{
			id = "http://www.roblox.com/asset/?id=507785072",
			weight = 10
		}
	},
	jump = {
		{
			id = "http://www.roblox.com/asset/?id=507765000",
			weight = 10
		}
	},
	fall = {
		{
			id = "http://www.roblox.com/asset/?id=507767968",
			weight = 10
		}
	},
	climb = {
		{
			id = "http://www.roblox.com/asset/?id=507765644",
			weight = 10
		}
	},
	sit = {
		{
			id = "http://www.roblox.com/asset/?id=2506281703",
			weight = 10
		}
	},
	toolnone = {
		{
			id = "http://www.roblox.com/asset/?id=507768375",
			weight = 10
		}
	},
	toolslash = {
		{
			id = "http://www.roblox.com/asset/?id=522635514",
			weight = 10
		}
	},
	toollunge = {
		{
			id = "http://www.roblox.com/asset/?id=522638767",
			weight = 10
		}
	},
	wave = {
		{
			id = "http://www.roblox.com/asset/?id=507770239",
			weight = 10
		}
	},
	point = {
		{
			id = "http://www.roblox.com/asset/?id=507770453",
			weight = 10
		}
	},
	dance = {
		{
			id = "http://www.roblox.com/asset/?id=507771019",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507771955",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507772104",
			weight = 10
		}
	},
	dance2 = {
		{
			id = "http://www.roblox.com/asset/?id=507776043",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507776720",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507776879",
			weight = 10
		}
	},
	dance3 = {
		{
			id = "http://www.roblox.com/asset/?id=507777268",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507777451",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=507777623",
			weight = 10
		}
	},
	laugh = {
		{
			id = "http://www.roblox.com/asset/?id=507770818",
			weight = 10
		}
	},
	cheer = {
		{
			id = "http://www.roblox.com/asset/?id=507770677",
			weight = 10
		}
	}
}
math.randomseed(tick())

function findExistingAnimationInSet(p, p2)
	if p == nil or p2 == nil then
		return 0
	end

	for i = 1, p.count do
		if p[i].anim.AnimationId == p2.AnimationId then
			return i
		end
	end

	return 0
end

function configureAnimationSet(name, items)
	if v4[name] ~= nil then
		for _, connection in pairs(v4[name].connections) do
			connection:disconnect()
		end
	end

	v4[name] = {}
	v4[name].count = 0
	v4[name].totalWeight = 0
	v4[name].connections = {}
	local allowCustomAnimations = true
	local success4, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success4 then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v4[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v4[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v4[name].count = v4[name].count + 1
			local count = v4[name].count
			v4[name][count] = {}
			v4[name][count].anim = animation
			v4[name][count].weight = weight2
			v4[name].totalWeight = v4[name].totalWeight + v4[name][count].weight
			table.insert(v4[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v4[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v4[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
		end
	end

	if v4[name].count <= 0 then
		for k, item in pairs(items) do
			v4[name][k] = {}
			v4[name][k].anim = Instance.new("Animation")
			v4[name][k].anim.Name = name
			v4[name][k].anim.AnimationId = item.id
			v4[name][k].weight = item.weight
			v4[name].count = v4[name].count + 1
			v4[name].totalWeight = v4[name].totalWeight + item.weight
		end
	end

	for _, v6 in pairs(v4) do
		for i = 1, v6.count do
			if v3[v6[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v6[i].anim)
			v3[v6[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v4[name] ~= nil then
		for _, connection in pairs(v4[name].connections) do
			connection:disconnect()
		end
	end

	v4[name] = {}
	v4[name].count = 0
	v4[name].totalWeight = 0
	v4[name].connections = {}
	local allowCustomAnimations = true
	local success4, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success4 then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v4[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v4[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v6 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v4[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v4[name][v6] = {}
			v4[name][v6].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v4[name][v6].weight = 1
			else
				v4[name][v6].weight = weight.Value
			end

			v4[name].count = v4[name].count + 1
			v4[name].totalWeight = v4[name].totalWeight + v4[name][v6].weight
			v6 += 1
		end
	end

	if v4[name].count <= 0 then
		for k, item in pairs(items) do
			v4[name][k] = {}
			v4[name][k].anim = Instance.new("Animation")
			v4[name][k].anim.Name = name
			v4[name][k].anim.AnimationId = item.id
			v4[name][k].weight = item.weight
			v4[name].count = v4[name].count + 1
			v4[name].totalWeight = v4[name].totalWeight + item.weight
		end
	end

	for _, v6 in pairs(v4) do
		for i = 1, v6.count do
			humanoid:LoadAnimation(v6[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v6 = v5[p.Name]

	if v6 ~= nil then
		configureAnimationSet(p.Name, v6)
	end
end

script.ChildAdded:connect(scriptChildModified)
script.ChildRemoved:connect(scriptChildModified)
local v6 = ""
local v7 = {
	wave = false,
	point = false,
	dance = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}
local v8 = nil
local keyframeReachedConnection = nil
local track = nil
local keyframeReachedConnection2 = nil
local track2 = nil
local v9 = 1
local v10 = success and result
local v11 = "Standing"

for k, v12 in pairs(v5) do
	configureAnimationSet(k, v12)
end

local value = "None"
local v12 = 0
local v13 = 0
local flag = false

function stopAllAnimations()
	local v14 = v6
	local v15 = v7[v14] ~= nil and v7[v14] == false and "idle" or v14

	if flag then
		v15 = "idle"
		flag = false
	end

	v6 = ""
	v8 = nil

	if keyframeReachedConnection ~= nil then
		keyframeReachedConnection:disconnect()
	end

	if track ~= nil then
		track:Stop()
		track:Destroy()
		track = nil
	end

	if keyframeReachedConnection2 ~= nil then
		keyframeReachedConnection2:disconnect()
	end

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v15
end

function getHeightScale()
	if not (humanoid and humanoid.AutomaticScalingEnabled) then
		return 1
	end

	local halfHipHeight = humanoid.HipHeight / 2

	if scaleDampeningPercent == nil then
		scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
	end

	if scaleDampeningPercent ~= nil then
		return 1 + (humanoid.HipHeight - 2) * scaleDampeningPercent.Value / 2
	end

	return halfHipHeight
end

local function rootMotionCompensation(p)
	return p
end

local function setRunSpeed(p)
	local v14 = 0.0001
	local v15 = p / 1
	local v16 = p / 1
	local v17

	if p <= 1 then
		v14 = 1
		v17 = 0.0001
	elseif p < 1 then
		v17 = (p - 1) / 0
		v14 = 1 - v17
		v15 = 1
		v16 = 1
	else
		v17 = 1
	end

	track:AdjustWeight(v14)
	track2:AdjustWeight(v17)
	track:AdjustSpeed(v15)
	track2:AdjustSpeed(v16)
end

function setAnimationSpeed(p)
	if v6 == "walk" then
		setRunSpeed(p)
	elseif p ~= v9 then
		v9 = p
		track:AdjustSpeed(v9)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v6 == "walk" then
			if v10 == true then
				if track2.Looped ~= true then
					track2.TimePosition = 0
				end

				if track.Looped ~= true then
					track.TimePosition = 0
				end
			else
				track2.TimePosition = 0
				track.TimePosition = 0
			end
		else
			local v14 = v6
			local v15 = v7[v14] ~= nil and v7[v14] == false and "idle" or v14

			if flag then
				if track.Looped then
					return
				end

				v15 = "idle"
				flag = false
			end

			local v16 = v9
			playAnimation(v15, 0.15, humanoid)
			setAnimationSpeed(v16)
		end
	end
end

function rollAnimation(p)
	local v14 = math.random(1, v4[p].totalWeight)
	local v15 = 1

	while v4[p][v15].weight < v14 do
		v14 -= v4[p][v15].weight
		v15 += 1
	end

	return v15
end

local function switchToAnim(animation, p, p2, animator)
	if animation ~= v8 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if track2 ~= nil then
			track2:Stop(p2)
			track2:Destroy()

			if v10 == true then
				track2 = nil
			end
		end

		v9 = 1
		track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v6 = p
		v8 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v14 = rollAnimation("run")
			track2 = animator:LoadAnimation(v4.run[v14].anim)
			track2.Priority = Enum.AnimationPriority.Core
			track2:Play(p2)

			if keyframeReachedConnection2 ~= nil then
				keyframeReachedConnection2:disconnect()
			end

			keyframeReachedConnection2 = track2.KeyframeReached:connect(keyFrameReachedFunc)
		end
	end
end

function playAnimation(p, p2, p3)
	local v14 = rollAnimation(p)
	switchToAnim(v4[p][v14].anim, p, p2, p3)
	flag = false
end

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	flag = true
end

local v14 = ""
local track3 = nil
local v15 = nil
local keyframeReachedConnection3 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v14, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator, priority)
	local v16 = rollAnimation(p)
	local anim = v4[p][v16].anim

	if v15 ~= anim then
		if track3 ~= nil then
			track3:Stop()
			track3:Destroy()
			p2 = 0
		end

		track3 = animator:LoadAnimation(anim)

		if priority then
			track3.Priority = priority
		end

		track3:Play(p2)
		v14 = p
		v15 = anim
		keyframeReachedConnection3 = track3.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v16 = v14

	if keyframeReachedConnection3 ~= nil then
		keyframeReachedConnection3:disconnect()
	end

	v14 = ""
	v15 = nil

	if track3 ~= nil then
		track3:Stop()
		track3:Destroy()
		track3 = nil
	end

	return v16
end

function onRunning(p)
	if (v and flag and humanoid.MoveDirection == createVector(0, 0, 0) and humanoid.WalkSpeed or 0.75) < p then
		playAnimation("run", 0.2, humanoid)
		setAnimationSpeed(p / 16)
		v11 = "Running"
	elseif v7[v6] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v11 = "Standing"
	end
end

function onDied()
	v11 = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v13 = 0.31
	v11 = "Jumping"
end

function onClimbing(p)
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(p / 5)
	v11 = "Climbing"
end

function onGettingUp()
	v11 = "GettingUp"
end

function onFreeFall()
	if v13 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	end

	v11 = "FreeFall"
end

function onFallingDown()
	v11 = "FallingDown"
end

function onSeated()
	v11 = "Seated"
end

function onPlatformStanding()
	v11 = "PlatformStanding"
end

function onSwimming(p)
	if p > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(p / 10)
		v11 = "Swimming"
	else
		playAnimation("swimidle", 0.4, humanoid)
		v11 = "Standing"
	end
end

function animateTool()
	if value == "None" then
		playToolAnimation("toolnone", 0.1, humanoid, Enum.AnimationPriority.Idle)
		return
	elseif value == "Slash" then
		playToolAnimation("toolslash", 0, humanoid, Enum.AnimationPriority.Action)
		return
	end

	if value ~= "Lunge" then
		return
	end

	playToolAnimation("toollunge", 0, humanoid, Enum.AnimationPriority.Action)
end

function getToolAnim(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child.Name == "toolanim" and child.className == "StringValue" then
			return child
		end
	end

	return nil
end

local v16 = 0

function stepAnimate(p)
	local v17 = p - v16
	v16 = p

	if v13 > 0 then
		v13 -= v17
	end

	if v11 == "FreeFall" and v13 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	else
		if v11 == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v11 == "Running" then
			playAnimation("run", 0.2, humanoid)
		elseif v11 == "Dead" or v11 == "GettingUp" or v11 == "FallingDown" or v11 == "Seated" or v11 == "PlatformStanding" then
			stopAllAnimations()
		end
	end

	local tool = parent:FindFirstChildOfClass("Tool")

	if tool and tool:FindFirstChild("Handle") then
		local toolAnim = getToolAnim(tool)

		if toolAnim then
			value = toolAnim.Value
			toolAnim.Parent = nil
			v12 = p + 0.3
		end

		if v12 < p then
			v12 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v15 = nil
		v12 = 0
	end
end

humanoid.Died:connect(onDied)
humanoid.Running:connect(onRunning)
humanoid.Jumping:connect(onJumping)
humanoid.Climbing:connect(onClimbing)
humanoid.GettingUp:connect(onGettingUp)
humanoid.FreeFalling:connect(onFreeFall)
humanoid.FallingDown:connect(onFallingDown)
humanoid.Seated:connect(onSeated)
humanoid.PlatformStanding:connect(onPlatformStanding)
humanoid.Swimming:connect(onSwimming)
local Players = game:GetService("Players")
Players.LocalPlayer.Chatted:connect(function(value2)
	local v17 = ""

	if string.sub(value2, 1, 3) == "/e " then
		v17 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v17 = string.sub(value2, 8)
	end

	if v11 == "Standing" and v7[v17] ~= nil then
		playAnimation(v17, 0.1, humanoid)
	end
end)
local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v11 ~= "Standing" then
		return
	end

	if v7[animation] == nil then
		if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
			return false
		end

		playEmote(animation, 0.1, humanoid)
	else
		playAnimation(animation, 0.1, humanoid)
	end

	if v2 then
		return true, track
	end

	return true
end

if parent.Parent ~= nil then
	playAnimation("idle", 0.1, humanoid)
	v11 = "Standing"
end

while parent.Parent ~= nil do
	local _, v17 = wait(0.1)
	stepAnimate(v17)
end