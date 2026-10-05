local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
UserSettings():GetService("UserGameSettings")
local _, _ = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun")
end)
local v2 = success and result
local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local v3 = 0
local v4 = 0
local v5 = {
	x = 0,
	y = 0
}
local v6 = 0
local v7 = ""
local v8 = nil
local track = nil
local keyframeReachedConnection = nil
local v9 = 1
local v10 = {}
local v11 = {}
local v12 = {
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
	}
}
local v13 = {}
local v14 = {}
local v15 = v13
local v16 = {}
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

local function destroyWalkAnimations()
	for _, v17 in pairs(v13) do
		if not v17.track then
			continue
		end

		v17.track:Stop()
		v17.track:Destroy()
		v17.track = nil
	end

	for _, v17 in pairs(v14) do
		if not v17.track then
			continue
		end

		v17.track:Stop()
		v17.track:Destroy()
		v17.track = nil
	end

	v4 = 0
end

local x = nil
local x2 = nil
local y = nil
local y2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function resetVelocityBounds(_)
	x2 = 0
	x = 0
	y2 = 0
	y = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVelocityBounds(lv)
	if lv then
		local x3 = lv.x

		if x < x3 then
			x = lv.x
		end

		local y3 = lv.y

		if y < y3 then
			y = lv.y
		end

		if lv.x < x2 then
			x2 = lv.x
		end

		if lv.y < y2 then
			y2 = lv.y
		end
	end
end

local function checkStrafingEnabled(_)
	if x == 0 or x2 == 0 or y == 0 or y2 == 0 then
		if v15 == v13 then
			warn("Strafe blending disabled.  Not all quadrants of motion represented.")
		end

		v15 = v14
	elseif v13.run and v13.walk then
		if v15 ~= v13 then
			v15 = v13
			warn("Strafing reenabled")
		end
	else
		if v15 == v13 then
			warn("Strafe blending disabled.  Run and walk must be strafing-friendly.")
		end

		v15 = v14
	end
end

local function setupWalkAnimations()
	resetVelocityBounds() -- equivalent call inferred; original call site unknown

	for _, v17 in pairs(v13) do
		updateVelocityBounds(v17.lv) -- equivalent call inferred; original call site unknown
	end

	checkStrafingEnabled()

	for k, v17 in pairs(v15) do
		v17.track = humanoid:LoadAnimation(v11[k][1].anim)
		v17.track.Priority = Enum.AnimationPriority.Core
	end
end

local function replaceLocomotionTrack(name, linearVelocity)
	local flag

	if v7 == "walk" and v15[name] then
		destroyWalkAnimations()
		flag = true
	else
		flag = false
	end

	if linearVelocity then
		v13[name] = {
			lv = linearVelocity,
			speed = linearVelocity.Magnitude
		}
	else
		v13[name] = nil
	end

	if name == "run" or name == "walk" then
		if linearVelocity then
			v14[name] = v13[name]
		else
			local speed = name == "run" and 12.8 or 6.4
			v14[name] = {
				lv = Vector2.new(0, speed),
				speed = speed
			}
			v13[name] = nil
		end
	end

	if flag then
		setupWalkAnimations()
		v6 = 0
	end
end

function configureAnimationSet(name, items)
	if v11[name] ~= nil then
		for _, connection in pairs(v11[name].connections) do
			connection:disconnect()
		end
	end

	v11[name] = {}
	v11[name].count = 0
	v11[name].totalWeight = 0
	v11[name].connections = {}
	local child = script:FindFirstChild(name)

	if child ~= nil then
		table.insert(v11[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v11[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v11[name].count = v11[name].count + 1
			local count = v11[name].count
			v11[name][count] = {}
			v11[name][count].anim = animation
			v11[name][count].weight = weight2
			v11[name].totalWeight = v11[name].totalWeight + v11[name][count].weight
			table.insert(v11[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v11[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v11[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
			replaceLocomotionTrack(name, animation:GetAttribute("LinearVelocity"))
		end
	end

	if v11[name].count <= 0 then
		for k, item in pairs(items) do
			v11[name][k] = {}
			v11[name][k].anim = Instance.new("Animation")
			v11[name][k].anim.Name = name
			v11[name][k].anim.AnimationId = item.id
			v11[name][k].weight = item.weight
			v11[name].count = v11[name].count + 1
			v11[name].totalWeight = v11[name].totalWeight + item.weight
		end
	end

	for _, v17 in pairs(v11) do
		for i = 1, v17.count do
			if v10[v17[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v17[i].anim)
			v10[v17[i].anim.AnimationId] = true
		end
	end
end

function scriptChildModified(object)
	local v17 = v12[object.Name]

	if v17 ~= nil then
		configureAnimationSet(object.Name, v17)
	elseif object:isA("StringValue") then
		v12[object.Name] = {}
		configureAnimationSet(object.Name, v12[object.Name])
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

for k, v17 in pairs(v12) do
	configureAnimationSet(k, v17)
end

for _, child in script:GetChildren() do
	if not child:isA("StringValue") then
		continue
	end

	v12[child.Name] = {}
	configureAnimationSet(child.Name, v12[child.Name])
end

local value = "None"
local v17 = 0
local v18 = 0
local flag = false

function stopAllAnimations()
	local v19 = v7
	local v20 = v16[v19] ~= nil and v16[v19] == false and "idle" or v19

	if flag then
		v20 = "idle"
		flag = false
	end

	v7 = ""
	v8 = nil

	if keyframeReachedConnection ~= nil then
		keyframeReachedConnection:disconnect()
	end

	if track ~= nil then
		track:Stop()
		track:Destroy()
		track = nil
	end

	for _, v21 in pairs(v15) do
		if not v21.track then
			continue
		end

		v21.track:Stop()
		v21.track:Destroy()
		v21.track = nil
	end

	return v20
end

local function getRigScale()
	if v2 then
		return parent:GetScale()
	end

	return 1
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

-- equivalent calls inferred from this helper; original call sites unknown
local function signedAngle(p, p2)
	return -math.atan2(p.x * p2.y - p.y * p2.x, p.x * p2.x + p.y * p2.y)
end

local function get2DWeight(p, lv, lv2, p2, speed, speed2)
	local v19 = 0.5 * (speed + speed2)
	local v20 = {
		x = (p2 - speed) / v19,
		y = 2 * signedAngle(lv, p)
	}
	local v21 = {
		x = (speed2 - speed) / v19,
		y = 2 * signedAngle(lv, lv2)
	}
	local v22 = 0.0001 + (v21.x * v21.x + v21.y * v21.y)
	return (math.clamp(1 - (v20.x * v21.x + v20.y * v21.y) / v22, 0, 1))
end

local function blend2D(p, p2)
	if v2 then
		local heightScale = getHeightScale()
		p /= heightScale
		p2 /= heightScale
	end

	local v19 = {}
	local total = 0

	for k, v20 in pairs(v15) do
		if p.x * v20.lv.x < 0 or p.y * v20.lv.y < 0 then
			v19[k] = 0
		else
			v19[k] = 1e999

			for _, v21 in pairs(v15) do
				if not (p.x * v21.lv.x < 0 or p.y * v21.lv.y < 0) then
					v19[k] = math.min(v19[k], (get2DWeight(p, v20.lv, v21.lv, p2, v20.speed, v21.speed)))
				end
			end

			total += v19[k]
		end
	end

	local total2 = 0
	local total3 = 0
	local total4 = 0

	for k, v20 in pairs(v15) do
		if v19[k] / total > 0.1 then
			total2 += v19[k]
			total3 += v19[k] * v20.lv.x
			total4 += v19[k] * v20.lv.y
		else
			v19[k] = 0
		end
	end

	local v20 = total3 * total3 + total4 * total4
	local v21 = not (v20 > 0.0001) and 0 or math.sqrt(p2 * p2 / v20)

	if not v2 then
		v21 /= getHeightScale()
	end

	local timePosition = 0

	for _, v23 in pairs(v15) do
		if not v23.track.IsPlaying then
			continue
		end

		timePosition = v23.track.TimePosition
		break
	end

	for k, v23 in pairs(v15) do
		if v19[k] > 0 then
			if not v23.track.IsPlaying then
				v23.track:Play(0.2)
				v23.track.TimePosition = timePosition
			end

			local v24 = math.max(0.0001, v19[k] / total2)
			v23.track:AdjustWeight(v24, 0.2)
			v23.track:AdjustSpeed(v21)
		else
			v23.track:Stop(0.2)
		end
	end
end

local function getWalkDirection()
	local walkToPoint = humanoid.WalkToPoint
	local walkToPart = humanoid.WalkToPart

	if humanoid.MoveDirection ~= createVector(0, 0, 0) or not walkToPart and walkToPoint == createVector(0, 0, 0) then
		return humanoid.MoveDirection
	end

	if walkToPart then
		walkToPoint = walkToPart.CFrame:PointToWorldSpace(walkToPoint)
	end

	local vector2

	if humanoid.RootPart then
		local v19 = walkToPoint - humanoid.RootPart.CFrame.Position
		vector2 = Vector3.new(v19.x, 0, v19.z)
		local magnitude = vector2.Magnitude

		if magnitude > 0.01 then
			vector2 /= magnitude
		end
	else
		vector2 = createVector(0, 0, 0)
	end

	return vector2
end

local function updateVelocity(p)
	if v15 == v13 then
		local walkDirection = getWalkDirection()

		if not humanoid.RootPart then
			return
		end

		local cFrame = humanoid.RootPart.CFrame

		if math.abs(cFrame.UpVector.Y) < 0.0001 or v ~= "Running" or v3 < 0.001 then
			for _, v19 in pairs(v15) do
				if v19.track then
					v19.track:AdjustWeight(0.0001, 0.2)
				end
			end
		else
			local lookVector = cFrame.LookVector
			local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local v19 = vector2 / vector2.Magnitude
			local dot = walkDirection:Dot(v19)
			local v20 = dot <= 0 and dot > -0.05 and 0.0001 or dot
			local v21 = v19.X * walkDirection.Z - v19.Z * walkDirection.X
			local vector3 = Vector2.new(v21, v20)
			local vector4 = Vector2.new(vector3.x - v5.x, vector3.y - v5.y)

			if vector4:Dot(vector4) > 0.001 or math.abs(v3 - v4) > 0.01 or p - v6 > 1 then
				v5 = vector3
				v4 = v3
				v6 = p
				blend2D(v5, v4)
			end
		end
	elseif math.abs(v3 - v4) > 0.01 or p - v6 > 1 then
		v4 = v3
		v6 = p
		blend2D(Vector2.yAxis, v4)
	end
end

function setAnimationSpeed(p)
	if v7 ~= "walk" and p ~= v9 then
		v9 = p
		track:AdjustSpeed(v9)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		local v19 = v7
		local v20 = v16[v19] ~= nil and v16[v19] == false and "idle" or v19

		if flag then
			if track.Looped then
				return
			end

			v20 = "idle"
			flag = false
		end

		local v21 = v9
		playAnimation(v20, 0.15, humanoid)
		setAnimationSpeed(v21)
	end
end

function rollAnimation(p)
	local v19 = math.random(1, v11[p].totalWeight)
	local v20 = 1

	while v11[p][v20].weight < v19 do
		v19 -= v11[p][v20].weight
		v20 += 1
	end

	return v20
end

local function switchToAnim(animation, p, p2, animator2, p3)
	if animation ~= v8 or p3 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
			keyframeReachedConnection = nil
		end

		v9 = 1
		v7 = p
		v8 = animation

		if p == "walk" then
			setupWalkAnimations()
			return
		end

		destroyWalkAnimations()
		track = animator2:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)
	end
end

local v19 = nil

function playAnimation(p, p2, p3, ...)
	v19 = { p, p2, p3 }
	local v20 = rollAnimation(p)
	switchToAnim(v11[p][v20].anim, p, p2, p3, ...)
	flag = false
end

script:WaitForChild("Refresh").Event:Connect(function(...)
	if not v19 then
		return
	end

	for _, v20 in pairs(script.Parent.Humanoid:GetPlayingAnimationTracks()) do
		v20:Stop()
		v20:Destroy()
	end

	script.RefreshServer:FireServer()
	playAnimation(v19[1], v19[2], v19[3], true, ...)
end)

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	flag = true
end

local v20 = ""
local track2 = nil
local v21 = nil
local keyframeReachedConnection2 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v20, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	local v22 = rollAnimation(p)
	local anim = v11[p][v22].anim

	if v21 ~= anim then
		if track2 ~= nil then
			track2:Stop()
			track2:Destroy()
			p2 = 0
		end

		track2 = animator2:LoadAnimation(anim)

		if priority then
			track2.Priority = priority
		end

		track2:Play(p2)
		v20 = p
		v21 = anim
		keyframeReachedConnection2 = track2.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v22 = v20

	if keyframeReachedConnection2 ~= nil then
		keyframeReachedConnection2:disconnect()
	end

	v20 = ""
	v21 = nil

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v22
end

function onRunning(p)
	local v22 = not v2 and 1 or getHeightScale()
	local v23 = (not flag or humanoid.MoveDirection ~= createVector(0, 0, 0)) and 0.75 or humanoid.WalkSpeed / v22 or 0.75
	v3 = p

	if v23 * v22 < p then
		playAnimation("walk", 0.2, humanoid)

		if v ~= "Running" then
			v = "Running"
			updateVelocity(0)
		end
	elseif v16[v7] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v18 = 0.31
	v = "Jumping"
end

function onClimbing(p)
	if v2 then
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
	if v18 <= 0 then
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
	if v2 then
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

local v22 = 0

function stepAnimate(p)
	local v23 = p - v22
	v22 = p

	if v18 > 0 then
		v18 -= v23
	end

	if v == "FreeFall" and v18 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	else
		if v == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v == "Running" then
			playAnimation("walk", 0.2, humanoid)
			updateVelocity(p)
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
			v17 = p + 0.3
		end

		if v17 < p then
			v17 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v21 = nil
		v17 = 0
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
	local v23 = ""

	if string.sub(value2, 1, 3) == "/e " then
		v23 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v23 = string.sub(value2, 8)
	end

	if v == "Standing" and v16[v23] ~= nil then
		playAnimation(v23, 0.1, humanoid)
	end
end)
local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v ~= "Standing" then
		return
	end

	if v16[animation] ~= nil then
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
	local _, v23 = wait(0.1)
	stepAnimate(v23)
end