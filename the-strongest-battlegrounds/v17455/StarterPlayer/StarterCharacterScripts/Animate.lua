local parent = script.Parent
local torso = parent:WaitForChild("Torso")
local rightShoulder = torso:WaitForChild("Right Shoulder")
local leftShoulder = torso:WaitForChild("Left Shoulder")
local rightHip = torso:WaitForChild("Right Hip")
local leftHip = torso:WaitForChild("Left Hip")
torso:WaitForChild("Neck")
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
local v2 = ""
local v3 = nil
local track = nil
local keyframeReachedConnection = nil
local v4 = 1
local v5 = {}
local v6 = {
	idle = {
		{
			id = "http://www.roblox.com/asset/?id=14516273501",
			weight = 9
		}
	},
	walk = {
		{
			id = "http://www.roblox.com/asset/?id=7807831448",
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
local v7 = { "dance1", "dance2", "dance3" }
local v8 = {
	wave = false,
	point = false,
	dance1 = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}

function configureAnimationSet(name, items)
	if v5[name] ~= nil then
		for _, connection in pairs(v5[name].connections) do
			connection:disconnect()
		end
	end

	v5[name] = {}
	v5[name].count = 0
	v5[name].totalWeight = 0
	v5[name].connections = {}
	local child = script:FindFirstChild(name)

	if child ~= nil then
		table.insert(v5[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v5[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v9 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v5[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v5[name][v9] = {}
			v5[name][v9].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v5[name][v9].weight = 1
			else
				v5[name][v9].weight = weight.Value
			end

			v5[name].count = v5[name].count + 1
			v5[name].totalWeight = v5[name].totalWeight + v5[name][v9].weight
			v9 += 1
		end
	end

	if v5[name].count <= 0 then
		for k, item in pairs(items) do
			v5[name][k] = {}
			v5[name][k].anim = Instance.new("Animation")
			v5[name][k].anim.Name = name
			v5[name][k].anim.AnimationId = item.id
			v5[name][k].weight = item.weight
			v5[name].count = v5[name].count + 1
			v5[name].totalWeight = v5[name].totalWeight + item.weight
		end
	end
end

function scriptChildModified(p)
	local v9 = v6[p.Name]

	if v9 ~= nil then
		configureAnimationSet(p.Name, v9)
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

for k, v9 in pairs(v6) do
	configureAnimationSet(k, v9)
end

local value = "None"
local v9 = 0
local v10 = 0

function stopAllAnimations()
	local v11 = v2
	local v12 = v8[v11] ~= nil and v8[v11] == false and "idle" or v11
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

	return v12
end

function setAnimationSpeed(p)
	if p ~= v4 and track then
		v4 = p
		track:AdjustSpeed(v4)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		local v11 = v2
		local v12 = v8[v11] ~= nil and v8[v11] == false and "idle" or v11
		local v13 = v4
		playAnimation(v12, 0, humanoid)
		setAnimationSpeed(v13)
	end
end

function playAnimation(p, value2, animator2)
	if parent:GetAttribute("InMech") and parent:FindFirstChild("Mech") then
		if track ~= nil then
			track:Stop(value2 or 0)
			track:Destroy()
			track = nil
			v3 = nil
			v2 = ""
		end
	else
		local v11 = math.random(1, v5[p].totalWeight)
		local v12 = 1

		while v5[p][v12].weight < v11 do
			v11 -= v5[p][v12].weight
			v12 += 1
		end

		local anim = v5[p][v12].anim

		if anim ~= v3 then
			if track ~= nil then
				track:Stop(value2)
				track:Destroy()
			end

			v4 = 1
			track = animator2:LoadAnimation(anim)
			track.Priority = Enum.AnimationPriority.Core
			track:Play(value2)
			v2 = p
			v3 = anim

			if keyframeReachedConnection ~= nil then
				keyframeReachedConnection:disconnect()
			end

			keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)
		end
	end
end

local v11 = ""
local track2 = nil
local v12 = nil
local keyframeReachedConnection2 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v11, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	if parent:GetAttribute("InMech") and parent:FindFirstChild("Mech") then
		if track2 ~= nil then
			track2:Stop()
			track2:Destroy()
			track2 = nil
			v12 = nil
		end
	else
		local v13 = math.random(1, v5[p].totalWeight)
		local v14 = 1

		while v5[p][v14].weight < v13 do
			v13 -= v5[p][v14].weight
			v14 += 1
		end

		local anim = v5[p][v14].anim

		if v12 ~= anim then
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
			v11 = p
			v12 = anim
			keyframeReachedConnection2 = track2.KeyframeReached:connect(toolKeyFrameReachedFunc)
		end
	end
end

function stopToolAnimations()
	local v13 = v11

	if keyframeReachedConnection2 ~= nil then
		keyframeReachedConnection2:disconnect()
	end

	v11 = ""
	v12 = nil

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v13
end

function onRunning(p)
	if p > 0.01 then
		playAnimation("walk", 0.1, humanoid)

		if v3 and v3.AnimationId == "rbxassetid://7807831448" then
			setAnimationSpeed(p / 14.5)
		end

		v = "Running"
	elseif v8[v2] == nil then
		playAnimation("idle", 0.1, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v10 = 0.3
	v = "Jumping"
end

function onClimbing(p)
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(p / 12)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v10 <= 0 then
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

local v13 = 0

function move(p)
	local v14 = 1
	local v15 = 1
	local v16 = p - v13
	v13 = p
	local flag = false

	if v10 > 0 then
		v10 -= v16
	end

	if v == "FreeFall" and v10 <= 0 then
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
			v15 = 1
			v14 = 0.1
		end
	end

	if flag then
		local v17 = v14 * math.sin(p * v15)
		rightShoulder:SetDesiredAngle(v17 + 0)
		leftShoulder:SetDesiredAngle(v17 - 0)
		rightHip:SetDesiredAngle(-v17)
		leftHip:SetDesiredAngle(-v17)
	end

	local tool = getTool()

	if tool and tool:FindFirstChild("Handle") then
		local toolAnim = getToolAnim(tool)

		if toolAnim then
			value = toolAnim.Value
			toolAnim.Parent = nil
			v9 = p + 0.3
		end

		if v9 < p then
			v9 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v12 = nil
		v9 = 0
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
	local v14 = ""

	if value2 == "/e dance" then
		v14 = v7[math.random(1, #v7)]
	elseif string.sub(value2, 1, 3) == "/e " then
		v14 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v14 = string.sub(value2, 8)
	end

	if v == "Standing" and v8[v14] ~= nil then
		playAnimation(v14, 0.1, humanoid)
	end
end)
playAnimation("idle", 0.1, humanoid)
v = "Standing"

while parent.Parent ~= nil do
	local _, v14 = wait(0.1)

	if not (parent:GetAttribute("InMech") and parent:FindFirstChild("Mech")) then
		move(v14)
	end
end