local parent = script.Parent
local torso = parent:WaitForChild("Torso")
local rightShoulder = torso:WaitForChild("Right Shoulder")
local leftShoulder = torso:WaitForChild("Left Shoulder")
local rightHip = torso:WaitForChild("Right Hip")
local leftHip = torso:WaitForChild("Left Hip")
torso:WaitForChild("Neck")
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScaleRun")
end)
local v2 = success and result

local function getRigScale()
	if v2 then
		return parent:GetScale()
	end

	return 1
end

local v3 = ""
local v4 = nil
local track = nil
local keyframeReachedConnection = nil
local v5 = 1
local v6 = {}
local v7 = {
	idle = {
		{
			id = "http://www.roblox.com/asset/?id=180435571",
			weight = 9
		},
		{
			id = "http://www.roblox.com/asset/?id=180435792",
			weight = 1
		}
	},
	walk = {
		{
			id = "http://www.roblox.com/asset/?id=180426354",
			weight = 10
		}
	},
	run = {
		{
			id = "run.xml",
			weight = 10
		}
	},
	jump = {
		{
			id = "http://www.roblox.com/asset/?id=125750702",
			weight = 10
		}
	},
	fall = {
		{
			id = "http://www.roblox.com/asset/?id=180436148",
			weight = 10
		}
	},
	climb = {
		{
			id = "http://www.roblox.com/asset/?id=180436334",
			weight = 10
		}
	},
	sit = {
		{
			id = "http://www.roblox.com/asset/?id=178130996",
			weight = 10
		}
	},
	toolnone = {
		{
			id = "http://www.roblox.com/asset/?id=182393478",
			weight = 10
		}
	},
	toolslash = {
		{
			id = "http://www.roblox.com/asset/?id=129967390",
			weight = 10
		}
	},
	toollunge = {
		{
			id = "http://www.roblox.com/asset/?id=129967478",
			weight = 10
		}
	},
	wave = {
		{
			id = "http://www.roblox.com/asset/?id=128777973",
			weight = 10
		}
	},
	point = {
		{
			id = "http://www.roblox.com/asset/?id=128853357",
			weight = 10
		}
	},
	dance1 = {
		{
			id = "http://www.roblox.com/asset/?id=182435998",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491037",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491065",
			weight = 10
		}
	},
	dance2 = {
		{
			id = "http://www.roblox.com/asset/?id=182436842",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491248",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491277",
			weight = 10
		}
	},
	dance3 = {
		{
			id = "http://www.roblox.com/asset/?id=182436935",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491368",
			weight = 10
		},
		{
			id = "http://www.roblox.com/asset/?id=182491423",
			weight = 10
		}
	},
	laugh = {
		{
			id = "http://www.roblox.com/asset/?id=129423131",
			weight = 10
		}
	},
	cheer = {
		{
			id = "http://www.roblox.com/asset/?id=129423030",
			weight = 10
		}
	}
}
local v8 = { "dance1", "dance2", "dance3" }
local v9 = {
	wave = false,
	point = false,
	dance1 = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}

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
	local child = script:FindFirstChild(name)

	if child ~= nil then
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

function stopAllAnimations()
	local v12 = v3
	local v13 = v9[v12] ~= nil and v9[v12] == false and "idle" or v12
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

	return v13
end

function setAnimationSpeed(p)
	if p ~= v5 then
		v5 = p
		track:AdjustSpeed(v5)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		local v12 = v3
		local v13 = v9[v12] ~= nil and v9[v12] == false and "idle" or v12
		local v14 = v5
		playAnimation(v13, 0, humanoid)
		setAnimationSpeed(v14)
	end
end

function playAnimation(p, p2, animator2)
	local v12 = math.random(1, v6[p].totalWeight)
	local v13 = 1

	while v6[p][v13].weight < v12 do
		v12 -= v6[p][v13].weight
		v13 += 1
	end

	local anim = v6[p][v13].anim

	if anim ~= v4 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		v5 = 1
		track = animator2:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v3 = p
		v4 = anim

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)
	end
end

local v12 = ""
local track2 = nil
local v13 = nil
local keyframeReachedConnection2 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v12, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	local v14 = math.random(1, v6[p].totalWeight)
	local v15 = 1

	while v6[p][v15].weight < v14 do
		v14 -= v6[p][v15].weight
		v15 += 1
	end

	local anim = v6[p][v15].anim

	if v13 ~= anim then
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
		v12 = p
		v13 = anim
		keyframeReachedConnection2 = track2.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v14 = v12

	if keyframeReachedConnection2 ~= nil then
		keyframeReachedConnection2:disconnect()
	end

	v12 = ""
	v13 = nil

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v14
end

function onRunning(p)
	local v14 = p / (not v2 and 1 or parent:GetScale())

	if v14 > 0.01 then
		playAnimation("walk", 0.1, humanoid)

		if v4 and v4.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
			setAnimationSpeed(v14 / 14.5)
		end

		v = "Running"
	elseif v9[v3] == nil then
		playAnimation("idle", 0.1, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v11 = 0.3
	v = "Jumping"
end

function onClimbing(p)
	local v14 = p / (not v2 and 1 or parent:GetScale())
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(v14 / 12)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v11 <= 0 then
		playAnimation("fall", 0.3, humanoid)
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
	if p > 0 then
		v = "Running"
	else
		v = "Standing"
	end
end

function getTool()
	for _, child in ipairs(parent:GetChildren()) do
		if child.className == "Tool" then
			return child
		end
	end

	return nil
end

function getToolAnim(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child.Name == "toolanim" and child.className == "StringValue" then
			return child
		end
	end

	return nil
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

function moveSit()
	rightShoulder.MaxVelocity = 0.15
	leftShoulder.MaxVelocity = 0.15
	rightShoulder:SetDesiredAngle(1.57)
	leftShoulder:SetDesiredAngle(-1.57)
	rightHip:SetDesiredAngle(1.57)
	leftHip:SetDesiredAngle(-1.57)
end

local v14 = 0

function move(p)
	local v15 = 1
	local v16 = 1
	local v17 = p - v14
	v14 = p
	local flag = false

	if v11 > 0 then
		v11 -= v17
	end

	if v == "FreeFall" and v11 <= 0 then
		playAnimation("fall", 0.3, humanoid)
	else
		if v == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v == "Running" then
			playAnimation("walk", 0.1, humanoid)
		elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" or v == "PlatformStanding" then
			stopAllAnimations()
			flag = true
			v16 = 1
			v15 = 0.1
		end
	end

	if flag then
		local v18 = v15 * math.sin(p * v16)
		rightShoulder:SetDesiredAngle(v18 + 0)
		leftShoulder:SetDesiredAngle(v18 - 0)
		rightHip:SetDesiredAngle(-v18)
		leftHip:SetDesiredAngle(-v18)
	end

	local tool = getTool()

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

	if value2 == "/e dance" then
		v15 = v8[math.random(1, #v8)]
	elseif string.sub(value2, 1, 3) == "/e " then
		v15 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v15 = string.sub(value2, 8)
	end

	if v == "Standing" and v9[v15] ~= nil then
		playAnimation(v15, 0.1, humanoid)
	end
end)
local playEmote = script:WaitForChild("PlayEmote")

function playEmote.OnInvoke(p)
	if v ~= "Standing" then
		return
	end

	if v9[p] == nil then
		return false
	end

	playAnimation(p, 0.1, humanoid)
	return true, track
end

playAnimation("idle", 0.1, humanoid)
v = "Standing"

while parent.Parent ~= nil do
	local _, v15 = wait(0.1)
	move(v15)
end