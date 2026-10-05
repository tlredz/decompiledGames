local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserAnimateScriptEmoteHook")
end)
local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage2:WaitForChild("Database"):WaitForChild("Sync"))
local v = {
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
local loopsByCommand = {
	wave = false,
	point = false,
	dance = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}
local v2 = {}
local v3 = {}
local v4 = ""
local v5 = success2 and result2
local v6 = nil
local keyframeReachedConnection = nil
local track = nil
local keyframeReachedConnection2 = nil
local track2 = nil
local v7 = 1
local v8 = success and result
local v9 = "Standing"

for _, emote in Sync.Emotes do
	if not emote.AnimationID then
		continue
	end

	local command = emote.Command
	v[command] = {
		{
			id = "http://www.roblox.com/asset/?id=" .. emote.AnimationID,
			weight = emote.Weight or 10
		}
	}
	loopsByCommand[command] = emote.Loop or false
end

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
	if v2[name] ~= nil then
		for _, connection in pairs(v2[name].connections) do
			connection:disconnect()
		end
	end

	v2[name] = {}
	v2[name].count = 0
	v2[name].totalWeight = 0
	v2[name].connections = {}
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
		table.insert(v2[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v2[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local weight = animation:FindFirstChild("Weight")
			local weight2 = weight == nil and 1 or weight.Value
			v2[name].count = v2[name].count + 1
			local count = v2[name].count
			v2[name][count] = {}
			v2[name][count].anim = animation
			v2[name][count].weight = weight2
			v2[name].totalWeight = v2[name].totalWeight + v2[name][count].weight
			table.insert(v2[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v2[name].connections, animation.ChildAdded:connect(function(_)
				configureAnimationSet(name, items)
			end))
			table.insert(v2[name].connections, animation.ChildRemoved:connect(function(_)
				configureAnimationSet(name, items)
			end))
		end
	end

	if v2[name].count <= 0 then
		for k, item in pairs(items) do
			v2[name][k] = {}
			v2[name][k].anim = Instance.new("Animation")
			v2[name][k].anim.Name = name
			v2[name][k].anim.AnimationId = item.id
			v2[name][k].weight = item.weight
			v2[name].count = v2[name].count + 1
			v2[name].totalWeight = v2[name].totalWeight + item.weight
		end
	end

	for _, v10 in pairs(v2) do
		for i = 1, v10.count do
			if v3[v10[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v10[i].anim)
			v3[v10[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v2[name] ~= nil then
		for _, connection in pairs(v2[name].connections) do
			connection:disconnect()
		end
	end

	v2[name] = {}
	v2[name].count = 0
	v2[name].totalWeight = 0
	v2[name].connections = {}
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
		table.insert(v2[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v2[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v10 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v2[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v2[name][v10] = {}
			v2[name][v10].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v2[name][v10].weight = 1
			else
				v2[name][v10].weight = weight.Value
			end

			v2[name].count = v2[name].count + 1
			v2[name].totalWeight = v2[name].totalWeight + v2[name][v10].weight
			v10 += 1
		end
	end

	if v2[name].count <= 0 then
		for k, item in pairs(items) do
			v2[name][k] = {}
			v2[name][k].anim = Instance.new("Animation")
			v2[name][k].anim.Name = name
			v2[name][k].anim.AnimationId = item.id
			v2[name][k].weight = item.weight
			v2[name].count = v2[name].count + 1
			v2[name].totalWeight = v2[name].totalWeight + item.weight
		end
	end

	for _, v10 in pairs(v2) do
		for i = 1, v10.count do
			humanoid:LoadAnimation(v10[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v10 = v[p.Name]

	if v10 ~= nil then
		configureAnimationSet(p.Name, v10)
	end
end

script.ChildAdded:connect(scriptChildModified)
script.ChildRemoved:connect(scriptChildModified)

for k, v10 in pairs(v) do
	configureAnimationSet(k, v10)
end

local value = "None"
local v10 = 0
local v11 = 0
local v12 = false

function stopAllAnimations()
	local v13 = v4
	local v14 = loopsByCommand[v13] ~= nil and loopsByCommand[v13] == false and "idle" or v13

	if v5 and v12 then
		v14 = "idle"
		v12 = false
	end

	v4 = ""
	v6 = nil

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

function setRunSpeed(p)
	local v13 = p * 1.25 / getHeightScale()

	if v13 ~= v7 then
		if v13 < 0.33 then
			track:AdjustWeight(1)
			track2:AdjustWeight(0.0001)
		elseif v13 < 0.66 then
			local v14 = (v13 - 0.33) / 0.33
			track:AdjustWeight(1 - v14 + 0.0001)
			track2:AdjustWeight(v14 + 0.0001)
		else
			track:AdjustWeight(0.0001)
			track2:AdjustWeight(1)
		end

		v7 = v13
		track2:AdjustSpeed(v13)
		track:AdjustSpeed(v13)
	end
end

function setAnimationSpeed(p)
	if v4 == "walk" then
		setRunSpeed(p)
	elseif p ~= v7 then
		v7 = p
		track:AdjustSpeed(v7)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v4 == "walk" then
			if v8 == true then
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
			local v14 = loopsByCommand[v13] ~= nil and loopsByCommand[v13] == false and "idle" or v13

			if v5 and v12 then
				if track.Looped then
					return
				end

				v14 = "idle"
				v12 = false
			end

			local v15 = v7
			playAnimation(v14, 0.15, humanoid)
			setAnimationSpeed(v15)
		end
	end
end

function rollAnimation(p)
	local v13 = math.random(1, v2[p].totalWeight)
	local v14 = 1

	while v2[p][v14].weight < v13 do
		v13 -= v2[p][v14].weight
		v14 += 1
	end

	return v14
end

local function switchToAnim(animation, p, p2, animator)
	if animation ~= v6 then
		if track ~= nil then
			track:Stop(p2)
			track:Destroy()
		end

		if track2 ~= nil then
			track2:Stop(p2)
			track2:Destroy()

			if v8 == true then
				track2 = nil
			end
		end

		v7 = 1
		track = animator:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p2)
		v4 = p
		v6 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v13 = rollAnimation("run")
			track2 = animator:LoadAnimation(v2.run[v13].anim)
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
	switchToAnim(v2[p][v13].anim, p, p2, p3)
	v12 = false
end

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	v12 = true
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

local toolAnimOverride = nil

function playToolAnimation(p, p2, animator, priority)
	local v15 = rollAnimation(p)
	local anim = v2[p][v15].anim

	if v14 ~= anim then
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
	if p > 0.75 then
		playAnimation("walk", 0.2, humanoid)
		setAnimationSpeed(p / 16)
		v9 = "Running"
	elseif loopsByCommand[v4] == nil and not v12 then
		playAnimation("idle", 0.2, humanoid)
		v9 = "Standing"
	end
end

function onDied()
	v9 = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v11 = 0.31
	v9 = "Jumping"
end

function onClimbing(p)
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(p / 5)
	v9 = "Climbing"
end

function onGettingUp()
	v9 = "GettingUp"
end

function onFreeFall()
	if v11 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	end

	v9 = "FreeFall"
end

function onFallingDown()
	v9 = "FallingDown"
end

function onSeated()
	v9 = "Seated"
end

function onPlatformStanding()
	v9 = "PlatformStanding"
end

function onSwimming(p)
	if p > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(p / 10)
		v9 = "Swimming"
	else
		playAnimation("swimidle", 0.4, humanoid)
		v9 = "Standing"
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
local v16 = nil

function stepAnimate(p)
	local v17 = p - v15
	v15 = p

	if v11 > 0 then
		v11 -= v17
	end

	if v9 == "FreeFall" and v11 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	else
		if v9 == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v9 == "Running" then
			playAnimation("walk", 0.2, humanoid)
		elseif v9 == "Dead" or v9 == "GettingUp" or v9 == "FallingDown" or v9 == "Seated" or v9 == "PlatformStanding" then
			stopAllAnimations()
		end
	end

	local tool = parent:FindFirstChildOfClass("Tool")
	toolAnimOverride = parent:FindFirstChild("ToolAnimOverride")
	local animationId = script.toolnone.ToolNoneAnim.AnimationId

	if animationId ~= v16 and tool or toolAnimOverride then
		value = "None"
		v14 = nil
		v10 = 0
	end

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
		v14 = nil
		v10 = 0
	end

	v16 = animationId
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

	if Sync.Emotes[v17] then
		local flag = true
		local flag2

		for _, v18 in pairs(ProfileData.Emotes.Owned) do
			if v18 ~= v17 then
				continue
			end

			flag2 = true
			flag = false
			break
		end

		if flag then
			flag2 = false
		end

		if flag2 then
			if v9 == "Standing" and loopsByCommand[v17] ~= nil then
				playAnimation(v17, 0.1, humanoid)
			end
		elseif not Sync.Emotes[v17] and v9 == "Standing" and loopsByCommand[v17] ~= nil then
			playAnimation(v17, 0.1, humanoid)
		end
	elseif not Sync.Emotes[v17] and v9 == "Standing" and loopsByCommand[v17] ~= nil then
		playAnimation(v17, 0.1, humanoid)
	end
end)
game.ReplicatedStorage.Remotes.Misc.PlayEmote.Event:Connect(function(childName)
	local flag = nil
	local v17 = nil

	if Sync.Emotes[childName] then
		v17 = Sync.Emotes[childName]
	elseif Sync.Toys[childName] then
		v17 = Sync.Toys[childName]
		flag = true
	end

	if not v17 then
		return
	end

	if flag then
		local child = game.Players.LocalPlayer.Backpack:FindFirstChild(childName)

		if game.Players.LocalPlayer.Backpack.Toys:FindFirstChild(childName) then
			child = game.ReplicatedStorage.Remotes.Extras.ReplicateToy:InvokeServer(childName)
			task.wait()
		end

		if child then
			child.Parent = game.Players.LocalPlayer.Backpack
			task.wait()
			humanoid:EquipTool(child)
		end
	else
		local command = v17.Command

		if v9 == "Standing" and loopsByCommand[command] ~= nil then
			playAnimation(command, 0.1, humanoid)
		end
	end
end)

if v5 then
	local playEmote_2 = script:WaitForChild("PlayEmote")

	function playEmote_2.OnInvoke(animation)
		if v9 ~= "Standing" then
			return
		end

		if loopsByCommand[animation] ~= nil then
			playAnimation(animation, 0.1, humanoid)
			return true
		end

		if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
			return false
		end

		playEmote(animation, 0.1, humanoid)
		return true
	end
end

playAnimation("idle", 0.1, humanoid)
v9 = "Standing"

while parent.Parent ~= nil do
	local _, v17 = wait(0.1)
	stepAnimate(v17)
end