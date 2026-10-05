local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"

local function getRigScale()
	return parent:GetScale()
end

local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateRemoveEmoteChatHook")
end)
local v3 = ""
local v4 = nil
local track = nil
local keyframeReachedConnection = nil
local v5 = 1
local track2 = nil
local keyframeReachedConnection2 = nil
local v6 = {}
local v7 = {}
local v8 = {
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
local v9 = {
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
local v10 = nil
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimationAbilityManagerFixed")
end)
local v11 = success2 and result2

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

function teardownManager()
	resetManagerListeners()
	groundSensor = nil
	v10 = nil
end

function processIfManagerBelongsToCharacter(instance)
	if instance.RootPart ~= parent.PrimaryPart then
		return false
	end

	if v10 == instance then
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
	v10 = instance
	return true
end

function setupManager(instance)
	v10 = instance
	groundSensor = instance.GroundSensor
	groundSensorChangedConnection = instance:GetPropertyChangedSignal("GroundSensor"):Connect(function()
		groundSensor = v10.GroundSensor
	end)
	rootPartChangedConnection = instance:GetPropertyChangedSignal("RootPart"):Connect(function()
		if instance.RootPart ~= parent.PrimaryPart then
			teardownManager()
			lookForControllerManager()
		end
	end)
	ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent2)
		if parent2 == nil then
			teardownManager()
			lookForControllerManager()
		end
	end)
end

function lookForControllerManager()
	if v11 then
		local controllerManager = parent:FindFirstChildOfClass("ControllerManager")

		if controllerManager then
			if controllerManager.RootPart == parent.PrimaryPart then
				setupManager(controllerManager)
				return
			end

			local rootPartChangedConnection2 = nil
			rootPartChangedConnection2 = controllerManager:GetPropertyChangedSignal("RootPart"):Connect(function()
				if controllerManager.RootPart == parent.PrimaryPart then
					rootPartChangedConnection2:Disconnect()
					setupManager(controllerManager)
				end
			end)
		else
			local childAddedConnection = nil
			childAddedConnection = parent.ChildAdded:Connect(function(controllerManager2)
				if controllerManager2:IsA("ControllerManager") then
					childAddedConnection:Disconnect()
					lookForControllerManager()
				end
			end)
		end
	else
		groundSensor = nil
		v10 = nil
		local controllerManager = parent:FindFirstChildOfClass("ControllerManager")

		if controllerManager then
			processIfManagerBelongsToCharacter(controllerManager)
		end

		if v10 == nil then
			local childAddedConnection = nil
			childAddedConnection = parent.ChildAdded:Connect(function(controllerManager2)
				if controllerManager2:IsA("ControllerManager") and processIfManagerBelongsToCharacter(controllerManager2) then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end
			end)
		end
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
	if v7[name] ~= nil then
		for _, connection in pairs(v7[name].connections) do
			connection:disconnect()
		end
	end

	v7[name] = {}
	v7[name].count = 0
	v7[name].totalWeight = 0
	v7[name].connections = {}
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
		table.insert(v7[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v7[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v7[name].count = v7[name].count + 1
			local count = v7[name].count
			v7[name][count] = {}
			v7[name][count].anim = animation
			v7[name][count].weight = weight2
			v7[name].totalWeight = v7[name].totalWeight + v7[name][count].weight
			table.insert(v7[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v7[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v7[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
		end
	end

	if v7[name].count <= 0 then
		for k, item in pairs(items) do
			v7[name][k] = {}
			v7[name][k].anim = Instance.new("Animation")
			v7[name][k].anim.Name = name
			v7[name][k].anim.AnimationId = item.id
			v7[name][k].weight = item.weight
			v7[name].count = v7[name].count + 1
			v7[name].totalWeight = v7[name].totalWeight + item.weight
		end
	end

	for _, v12 in pairs(v7) do
		for i = 1, v12.count do
			if v6[v12[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v12[i].anim)
			v6[v12[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v7[name] ~= nil then
		for _, connection in pairs(v7[name].connections) do
			connection:disconnect()
		end
	end

	v7[name] = {}
	v7[name].count = 0
	v7[name].totalWeight = 0
	v7[name].connections = {}
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
		table.insert(v7[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v7[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v12 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v7[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v7[name][v12] = {}
			v7[name][v12].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v7[name][v12].weight = 1
			else
				v7[name][v12].weight = weight.Value
			end

			v7[name].count = v7[name].count + 1
			v7[name].totalWeight = v7[name].totalWeight + v7[name][v12].weight
			v12 += 1
		end
	end

	if v7[name].count <= 0 then
		for k, item in pairs(items) do
			v7[name][k] = {}
			v7[name][k].anim = Instance.new("Animation")
			v7[name][k].anim.Name = name
			v7[name][k].anim.AnimationId = item.id
			v7[name][k].weight = item.weight
			v7[name].count = v7[name].count + 1
			v7[name].totalWeight = v7[name].totalWeight + item.weight
		end
	end

	for _, v12 in pairs(v7) do
		for i = 1, v12.count do
			humanoid:LoadAnimation(v12[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v12 = v8[p.Name]

	if v12 ~= nil then
		configureAnimationSet(p.Name, v12)
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

for k, v12 in pairs(v8) do
	configureAnimationSet(k, v12)
end

local value = "None"
local v12 = 0
local v13 = 0
local flag = false

function stopAllAnimations()
	local v14 = v3
	local v15 = v9[v14] ~= nil and v9[v14] == false and "idle" or v14

	if flag then
		v15 = "idle"
		flag = false
	end

	v3 = ""
	v4 = nil

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
	local v14 = p * 1.25 / getHeightScale()
	local v15 = 0.0001
	local v16 = 0.0001
	local v17 = 1

	if v14 <= 0.5 then
		v17 = v14 / 0.5
		v15 = 1
	elseif v14 < 1 then
		v16 = (v14 - 0.5) / 0.5
		v15 = 1 - v16
	else
		v17 = v14 / 1
		v16 = 1
	end

	track:AdjustWeight(v15)
	track2:AdjustWeight(v16)
	track:AdjustSpeed(v17)
	track2:AdjustSpeed(v17)
end

function setAnimationSpeed(p)
	if v3 == "walk" then
		setRunSpeed(p)
	elseif p ~= v5 then
		v5 = p
		track:AdjustSpeed(v5)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v3 == "walk" then
			if track2.Looped ~= true then
				track2.TimePosition = 0
			end

			if track.Looped ~= true then
				track.TimePosition = 0
			end
		else
			local v14 = v3
			local v15 = v9[v14] ~= nil and v9[v14] == false and "idle" or v14

			if flag then
				if track.Looped then
					return
				end

				v15 = "idle"
				flag = false
			end

			local v16 = v5
			playAnimation(v15, 0.15, humanoid)
			setAnimationSpeed(v16)
		end
	end
end

function rollAnimation(p)
	local v14 = math.random(1, v7[p].totalWeight)
	local v15 = 1

	while v7[p][v15].weight < v14 do
		v14 -= v7[p][v15].weight
		v15 += 1
	end

	return v15
end

local function switchToAnim(animation, p, p2, animator2)
	if animation ~= v4 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if track2 ~= nil then
			track2:Stop(p2)
			track2:Destroy()
			track2 = nil
		end

		v5 = 1
		track = animator2:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v3 = p
		v4 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v14 = rollAnimation("run")
			track2 = animator2:LoadAnimation(v7.run[v14].anim)
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
	switchToAnim(v7[p][v14].anim, p, p2, p3)
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

function playToolAnimation(p, p2, animator2, priority)
	local v16 = rollAnimation(p)
	local anim = v7[p][v16].anim

	if v15 ~= anim then
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
			local magnitude2 = v10.MovingDirection.Magnitude

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
	elseif v9[v3] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v13 = 0.31
	v = "Jumping"
end

function onClimbing(p)
	local v16 = p / getHeightScale()
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(v16 / 5)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v13 <= 0 then
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
	local v16 = p / getHeightScale()

	if v16 > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(v16 / 10)
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

local v16 = 0

function stepAnimate(p)
	local v17 = p - v16
	v16 = p

	if v13 > 0 then
		v13 -= v17
	end

	if v == "FreeFall" and v13 <= 0 then
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

if not (success and result) then
	local Players = game:GetService("Players")
	Players.LocalPlayer.Chatted:connect(function(value2)
		local v17 = ""

		if string.sub(value2, 1, 3) == "/e " then
			v17 = string.sub(value2, 4)
		elseif string.sub(value2, 1, 7) == "/emote " then
			v17 = string.sub(value2, 8)
		end

		if v == "Standing" and v9[v17] ~= nil then
			playAnimation(v17, 0.1, humanoid)
		end
	end)
end

local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v ~= "Standing" then
		return
	end

	if v9[animation] ~= nil then
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
	local _, v17 = wait(0.1)
	stepAnimate(v17)
end