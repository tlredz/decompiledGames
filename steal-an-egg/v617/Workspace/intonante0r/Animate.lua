local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"

local function getRigScale()
	return parent:GetScale()
end

local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local v2 = ""
local v3 = nil
local track = nil
local keyframeReachedConnection = nil
local v4 = 1
local track2 = nil
local keyframeReachedConnection2 = nil
local v5 = {}
local v6 = {}
local v7 = {
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
local v8 = {
	wave = false,
	point = false,
	dance = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}
local groundSensorChangedConnection = nil
local rootPartChangedConnection = nil
local ancestryChangedConnection = nil
local groundSensor = nil
local v9 = nil

function resetManagerListeners()
	if groundSensorChangedConnection then
		groundSensorChangedConnection:Disconnect()
		groundSensorChangedConnection = nil
	end

	if rootPartChangedConnection then
		rootPartChangedConnection:Disconnect()
		rootPartChangedConnection = nil
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end
end

function processIfManagerBelongsToCharacter(instance)
	if instance.RootPart ~= parent.PrimaryPart then
		return false
	end

	if v9 == instance then
		return true
	end

	resetManagerListeners()
	groundSensor = instance.GroundSensor
	groundSensorChangedConnection = instance:GetPropertyChangedSignal("GroundSensor"):Connect(function()
		if processIfManagerBelongsToCharacter(instance) then
			groundSensorChangedConnection:Disconnect()
			groundSensorChangedConnection = nil
		end
	end)
	rootPartChangedConnection = instance:GetPropertyChangedSignal("RootPart"):Connect(function()
		if processIfManagerBelongsToCharacter(instance) then
			rootPartChangedConnection:Disconnect()
			rootPartChangedConnection = nil
		end
	end)
	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent2)
		if parent2 == nil then
			resetManagerListeners()
			lookForControllerManager()
		end
	end)
	v9 = instance
	return true
end

function lookForControllerManager()
	groundSensor = nil
	v9 = nil
	local controllerManager = parent:FindFirstChildOfClass("ControllerManager")

	if controllerManager then
		processIfManagerBelongsToCharacter(controllerManager)
	end

	if v9 == nil then
		local childAddedConnection = nil
		childAddedConnection = parent.ChildAdded:Connect(function(controllerManager2)
			if controllerManager2:IsA("ControllerManager") and processIfManagerBelongsToCharacter(controllerManager2) then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end
		end)
	end
end

lookForControllerManager()
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
	if v6[name] ~= nil then
		for _, connection in pairs(v6[name].connections) do
			connection:disconnect()
		end
	end

	v6[name] = {}
	v6[name].count = 0
	v6[name].totalWeight = 0
	v6[name].connections = {}
	local allowCustomAnimations = true
	local success, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v6[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v6[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v6[name].count = v6[name].count + 1
			local count = v6[name].count
			v6[name][count] = {}
			v6[name][count].anim = animation
			v6[name][count].weight = weight2
			v6[name].totalWeight = v6[name].totalWeight + v6[name][count].weight
			table.insert(v6[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v6[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v6[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
		end
	end

	if v6[name].count <= 0 then
		for k, item in pairs(items) do
			v6[name][k] = {}
			v6[name][k].anim = Instance.new("Animation")
			v6[name][k].anim.Name = name
			v6[name][k].anim.AnimationId = item.id
			v6[name][k].weight = item.weight
			v6[name].count = v6[name].count + 1
			v6[name].totalWeight = v6[name].totalWeight + item.weight
		end
	end

	for _, v10 in pairs(v6) do
		for i = 1, v10.count do
			if v5[v10[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v10[i].anim)
			v5[v10[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v6[name] ~= nil then
		for _, connection in pairs(v6[name].connections) do
			connection:disconnect()
		end
	end

	v6[name] = {}
	v6[name].count = 0
	v6[name].totalWeight = 0
	v6[name].connections = {}
	local allowCustomAnimations = true
	local success, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success then
		allowCustomAnimations = true
	end

	local child = script:FindFirstChild(name)

	if allowCustomAnimations and child ~= nil then
		table.insert(v6[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v6[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v10 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v6[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v6[name][v10] = {}
			v6[name][v10].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v6[name][v10].weight = 1
			else
				v6[name][v10].weight = weight.Value
			end

			v6[name].count = v6[name].count + 1
			v6[name].totalWeight = v6[name].totalWeight + v6[name][v10].weight
			v10 += 1
		end
	end

	if v6[name].count <= 0 then
		for k, item in pairs(items) do
			v6[name][k] = {}
			v6[name][k].anim = Instance.new("Animation")
			v6[name][k].anim.Name = name
			v6[name][k].anim.AnimationId = item.id
			v6[name][k].weight = item.weight
			v6[name].count = v6[name].count + 1
			v6[name].totalWeight = v6[name].totalWeight + item.weight
		end
	end

	for _, v10 in pairs(v6) do
		for i = 1, v10.count do
			humanoid:LoadAnimation(v10[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v10 = v7[p.Name]

	if v10 ~= nil then
		configureAnimationSet(p.Name, v10)
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

for k, v10 in pairs(v7) do
	configureAnimationSet(k, v10)
end

local value = "None"
local v10 = 0
local v11 = 0
local flag = false

function stopAllAnimations()
	local v12 = v2
	local v13 = v8[v12] ~= nil and v8[v12] == false and "idle" or v12

	if flag then
		v13 = "idle"
		flag = false
	end

	v2 = ""
	v3 = nil

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

	return v13
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
	local v12 = p * 1.25 / getHeightScale()
	local v13 = 0.0001
	local v14 = 0.0001
	local v15 = 1

	if v12 <= 0.5 then
		v15 = v12 / 0.5
		v13 = 1
	elseif v12 < 1 then
		v14 = (v12 - 0.5) / 0.5
		v13 = 1 - v14
	else
		v15 = v12 / 1
		v14 = 1
	end

	track:AdjustWeight(v13)
	track2:AdjustWeight(v14)
	track:AdjustSpeed(v15)
	track2:AdjustSpeed(v15)
end

function setAnimationSpeed(p)
	if v2 == "walk" then
		setRunSpeed(p)
	elseif p ~= v4 then
		v4 = p
		track:AdjustSpeed(v4)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v2 == "walk" then
			if track2.Looped ~= true then
				track2.TimePosition = 0
			end

			if track.Looped ~= true then
				track.TimePosition = 0
			end
		else
			local v12 = v2
			local v13 = v8[v12] ~= nil and v8[v12] == false and "idle" or v12

			if flag then
				if track.Looped then
					return
				end

				v13 = "idle"
				flag = false
			end

			local v14 = v4
			playAnimation(v13, 0.15, humanoid)
			setAnimationSpeed(v14)
		end
	end
end

function rollAnimation(p)
	local v12 = math.random(1, v6[p].totalWeight)
	local v13 = 1

	while v6[p][v13].weight < v12 do
		v12 -= v6[p][v13].weight
		v13 += 1
	end

	return v13
end

local function switchToAnim(animation, p, p2, animator2)
	if animation ~= v3 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if track2 ~= nil then
			track2:Stop(p2)
			track2:Destroy()
			track2 = nil
		end

		v4 = 1
		track = animator2:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v2 = p
		v3 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v12 = rollAnimation("run")
			track2 = animator2:LoadAnimation(v6.run[v12].anim)
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
	local v12 = rollAnimation(p)
	switchToAnim(v6[p][v12].anim, p, p2, p3)
	flag = false
end

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	flag = true
end

local v12 = ""
local track3 = nil
local v13 = nil
local keyframeReachedConnection3 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v12, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	local v14 = rollAnimation(p)
	local anim = v6[p][v14].anim

	if v13 ~= anim then
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
		v12 = p
		v13 = anim
		keyframeReachedConnection3 = track3.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v14 = v12

	if keyframeReachedConnection3 ~= nil then
		keyframeReachedConnection3:disconnect()
	end

	v12 = ""
	v13 = nil

	if track3 ~= nil then
		track3:Stop()
		track3:Destroy()
		track3 = nil
	end

	return v14
end

function onRunning(p)
	local heightScale = getHeightScale()

	if groundSensor ~= nil and humanoid.EvaluateStateMachine == false then
		local rootPart = humanoid.RootPart
		local sensedPart = groundSensor.SensedPart

		if sensedPart then
			local velocityAtPosition = sensedPart:GetVelocityAtPosition(groundSensor.HitFrame.Position)
			local assemblyLinearVelocity = rootPart.AssemblyLinearVelocity
			local magnitude = Vector3.new(
				assemblyLinearVelocity.X - velocityAtPosition.X,
				0,
				assemblyLinearVelocity.Z - velocityAtPosition.Z
			).Magnitude
			local magnitude2 = v9.MovingDirection.Magnitude

			if magnitude2 < 0.1 then
				magnitude = 0
				magnitude2 = 0
			elseif magnitude2 > 1 then
				magnitude2 = 1
			end

			p = magnitude * magnitude2
		end
	end

	if ((not flag or humanoid.MoveDirection ~= createVector(0, 0, 0)) and 0.75 or humanoid.WalkSpeed / heightScale or 0.75) * heightScale < p then
		playAnimation("walk", 0.2, humanoid)
		setAnimationSpeed(p / 16)
		v = "Running"
	elseif v8[v2] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v11 = 0.31
	v = "Jumping"
end

function onClimbing(p)
	local v14 = p / getHeightScale()
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(v14 / 5)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v11 <= 0 then
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
	local v14 = p / getHeightScale()

	if v14 > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(v14 / 10)
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

local v14 = 0

function stepAnimate(p)
	local v15 = p - v14
	v14 = p

	if v11 > 0 then
		v11 -= v15
	end

	if v == "FreeFall" and v11 <= 0 then
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
			v10 = p + 0.3
		end

		if v10 < p then
			v10 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v13 = nil
		v10 = 0
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
	local v15 = ""

	if string.sub(value2, 1, 3) == "/e " then
		v15 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v15 = string.sub(value2, 8)
	end

	if v == "Standing" and v8[v15] ~= nil then
		playAnimation(v15, 0.1, humanoid)
	end
end)
local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v ~= "Standing" then
		return
	end

	if v8[animation] ~= nil then
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
	local _, v15 = wait(0.1)
	stepAnimate(v15)
end