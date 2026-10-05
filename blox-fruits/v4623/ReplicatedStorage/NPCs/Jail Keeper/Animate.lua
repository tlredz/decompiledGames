local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local v2 = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun")
end)
local v3 = success2 and result2

local function getRigScale()
	if v3 then
		return parent:GetScale()
	end

	return 1
end

local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local v4 = ""
local v5 = nil
local track = nil
local keyframeReachedConnection = nil
local v6 = 1
local track2 = nil
local keyframeReachedConnection2 = nil
local v7 = {}
local v8 = {}
local v9 = {
	idle = {
		{
			id = "http://www.roblox.com/asset/?id=507766666",
			weight = 1
		},
		{
			id = "http://www.roblox.com/asset/?id=507766951",
			weight = 1
		},
		{
			id = "http://www.roblox.com/asset/?id=507766388",
			weight = 9
		}
	},
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
local v10 = {
	wave = false,
	point = false,
	dance = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
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
	if v8[name] ~= nil then
		for _, connection in pairs(v8[name].connections) do
			connection:disconnect()
		end
	end

	v8[name] = {}
	v8[name].count = 0
	v8[name].totalWeight = 0
	v8[name].connections = {}
	local allowCustomAnimations = true
	local success3, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success3 then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v8[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v8[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v8[name].count = v8[name].count + 1
			local count = v8[name].count
			v8[name][count] = {}
			v8[name][count].anim = animation
			v8[name][count].weight = weight2
			v8[name].totalWeight = v8[name].totalWeight + v8[name][count].weight
			table.insert(v8[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v8[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v8[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
		end
	end

	if v8[name].count <= 0 then
		for k, item in pairs(items) do
			v8[name][k] = {}
			v8[name][k].anim = Instance.new("Animation")
			v8[name][k].anim.Name = name
			v8[name][k].anim.AnimationId = item.id
			v8[name][k].weight = item.weight
			v8[name].count = v8[name].count + 1
			v8[name].totalWeight = v8[name].totalWeight + item.weight
		end
	end

	for _, v11 in pairs(v8) do
		for i = 1, v11.count do
			if v7[v11[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v11[i].anim)
			v7[v11[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v8[name] ~= nil then
		for _, connection in pairs(v8[name].connections) do
			connection:disconnect()
		end
	end

	v8[name] = {}
	v8[name].count = 0
	v8[name].totalWeight = 0
	v8[name].connections = {}
	local allowCustomAnimations = true
	local success3, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success3 then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v8[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v8[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v11 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v8[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v8[name][v11] = {}
			v8[name][v11].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v8[name][v11].weight = 1
			else
				v8[name][v11].weight = weight.Value
			end

			v8[name].count = v8[name].count + 1
			v8[name].totalWeight = v8[name].totalWeight + v8[name][v11].weight
			v11 += 1
		end
	end

	if v8[name].count <= 0 then
		for k, item in pairs(items) do
			v8[name][k] = {}
			v8[name][k].anim = Instance.new("Animation")
			v8[name][k].anim.Name = name
			v8[name][k].anim.AnimationId = item.id
			v8[name][k].weight = item.weight
			v8[name].count = v8[name].count + 1
			v8[name].totalWeight = v8[name].totalWeight + item.weight
		end
	end

	for _, v11 in pairs(v8) do
		for i = 1, v11.count do
			humanoid:LoadAnimation(v11[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v11 = v9[p.Name]

	if v11 ~= nil then
		configureAnimationSet(p.Name, v11)
	end
end

script.ChildAdded:connect(scriptChildModified)
script.ChildRemoved:connect(scriptChildModified)
local animator

if humanoid then
	animator = humanoid:FindFirstChildOfClass("Animator")
end

if animator then
	local playingAnimationTracks = animator:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
		playingAnimationTrack:Stop(0)
		playingAnimationTrack:Destroy()
	end
end

for k, v11 in pairs(v9) do
	configureAnimationSet(k, v11)
end

local value = "None"
local v11 = 0
local v12 = 0
local flag = false

function stopAllAnimations()
	local v13 = v4
	local v14 = v10[v13] ~= nil and v10[v13] == false and "idle" or v13

	if flag then
		v14 = "idle"
		flag = false
	end

	v4 = ""
	v5 = nil

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

	return v14
end

function getHeightScale()
	if not (humanoid and humanoid.AutomaticScalingEnabled) then
		return getRigScale()
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
	return p * 1.25 / getHeightScale()
end

local function setRunSpeed(p)
	local v13 = p * 1.25 / getHeightScale()
	local v14 = 0.0001
	local v15 = 0.0001
	local v16 = 1

	if v13 <= 0.5 then
		v16 = v13 / 0.5
		v14 = 1
	elseif v13 < 1 then
		v15 = (v13 - 0.5) / 0.5
		v14 = 1 - v15
	else
		v16 = v13 / 1
		v15 = 1
	end

	track:AdjustWeight(v14)
	track2:AdjustWeight(v15)
	track:AdjustSpeed(v16)
	track2:AdjustSpeed(v16)
end

function setAnimationSpeed(p)
	if v4 == "walk" then
		setRunSpeed(p)
	elseif p ~= v6 then
		v6 = p
		track:AdjustSpeed(v6)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v4 == "walk" then
			if v2 == true then
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
			local v13 = v4
			local v14 = v10[v13] ~= nil and v10[v13] == false and "idle" or v13

			if flag then
				if track.Looped then
					return
				end

				v14 = "idle"
				flag = false
			end

			local v15 = v6
			playAnimation(v14, 0.15, humanoid)
			setAnimationSpeed(v15)
		end
	end
end

function rollAnimation(p)
	local v13 = math.random(1, v8[p].totalWeight)
	local v14 = 1

	while v8[p][v14].weight < v13 do
		v13 -= v8[p][v14].weight
		v14 += 1
	end

	return v14
end

local function switchToAnim(animation, p, p2, animator2)
	if animation ~= v5 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if track2 ~= nil then
			track2:Stop(p2)
			track2:Destroy()

			if v2 == true then
				track2 = nil
			end
		end

		v6 = 1
		track = animator2:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v4 = p
		v5 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v13 = rollAnimation("run")
			track2 = animator2:LoadAnimation(v8.run[v13].anim)
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
	local v13 = rollAnimation(p)
	switchToAnim(v8[p][v13].anim, p, p2, p3)
	flag = false
end

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	flag = true
end

local v13 = ""
local track3 = nil
local v14 = nil
local keyframeReachedConnection3 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v13, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	local v15 = rollAnimation(p)
	local anim = v8[p][v15].anim

	if v14 ~= anim then
		if track3 ~= nil then
			track3:Stop()
			track3:Destroy()
			p2 = 0
		end

		track3 = animator2:LoadAnimation(anim)

		if priority then
			track3.Priority = priority
		end

		track3:Play(p2)
		v13 = p
		v14 = anim
		keyframeReachedConnection3 = track3.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v15 = v13

	if keyframeReachedConnection3 ~= nil then
		keyframeReachedConnection3:disconnect()
	end

	v13 = ""
	v14 = nil

	if track3 ~= nil then
		track3:Stop()
		track3:Destroy()
		track3 = nil
	end

	return v15
end

function onRunning(p)
	local v15 = not v3 and 1 or getHeightScale()

	if ((not flag or humanoid.MoveDirection ~= createVector(0, 0, 0)) and 0.75 or humanoid.WalkSpeed / v15 or 0.75) * v15 < p then
		playAnimation("walk", 0.2, humanoid)
		setAnimationSpeed(p / 16)
		v = "Running"
	elseif v10[v4] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v12 = 0.31
	v = "Jumping"
end

function onClimbing(p)
	if v3 then
		p /= getHeightScale()
	end

	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(p / 5)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v12 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	end

	v = "FreeFall"
end

function onFallingDown()
	v = "FallingDown"
end

function onSeated()
	v = "Seated"
end

function onPlatformStanding()
	v = "PlatformStanding"
end

function onSwimming(p)
	if v3 then
		p /= getHeightScale()
	end

	if p > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(p / 10)
		v = "Swimming"
	else
		playAnimation("swimidle", 0.4, humanoid)
		v = "Standing"
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

local v15 = 0

function stepAnimate(p)
	local v16 = p - v15
	v15 = p

	if v12 > 0 then
		v12 -= v16
	end

	if v == "FreeFall" and v12 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	else
		if v == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v == "Running" then
			playAnimation("walk", 0.2, humanoid)
		elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" or v == "PlatformStanding" then
			stopAllAnimations()
		end
	end

	local tool = parent:FindFirstChildOfClass("Tool")

	if tool and tool:FindFirstChild("Handle") then
		local toolAnim = getToolAnim(tool)

		if toolAnim then
			value = toolAnim.Value
			toolAnim.Parent = nil
			v11 = p + 0.3
		end

		if v11 < p then
			v11 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v14 = nil
		v11 = 0
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
	local v16 = ""

	if string.sub(value2, 1, 3) == "/e " then
		v16 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v16 = string.sub(value2, 8)
	end

	if v == "Standing" and v10[v16] ~= nil then
		playAnimation(v16, 0.1, humanoid)
	end
end)
local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v ~= "Standing" then
		return
	end

	if v10[animation] ~= nil then
		playAnimation(animation, 0.1, humanoid)
		return true, track
	end

	if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
		return false
	end

	playEmote(animation, 0.1, humanoid)
	return true, track
end

if parent.Parent ~= nil then
	playAnimation("idle", 0.1, humanoid)
	v = "Standing"
end

while parent.Parent ~= nil do
	local _, v16 = wait(0.1)
	stepAnimate(v16)
end