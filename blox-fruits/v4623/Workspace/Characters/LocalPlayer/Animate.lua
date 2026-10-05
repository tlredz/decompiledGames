local createVector = vector.create
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local playerFromCharacter = game.Players:GetPlayerFromCharacter(parent)
local v = "Standing"
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNoUpdateOnLoop")
end)
local v2 = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserEmoteToRunThresholdChange")
end)
local v3 = success2 and result2
local success3, result3 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPlayEmoteByIdAnimTrackReturn2")
end)
local v4 = success3 and result3
local scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
local v5 = ""
local v6 = nil
local track = nil
local keyframeReachedConnection = nil
local v7 = 1
local v8 = nil
local keyframeReachedConnection2 = nil
local v9 = {}
local v10 = {}
local v11 = {
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
	idleKitsune = {
		{
			id = "rbxassetid://15518774250",
			weight = 10
		}
	},
	idleHuman = {
		{
			id = "rbxassetid://11567936323",
			weight = 10
		}
	},
	idleDragon = {
		{
			id = "rbxassetid://11567936323",
			weight = 10
		}
	},
	idleFishman = {
		{
			id = "rbxassetid://11567935460",
			weight = 10
		}
	},
	idleSkypiea = {
		{
			id = "rbxassetid://11567938113",
			weight = 10
		}
	},
	idleGhoul = {
		{
			id = "rbxassetid://11567935868",
			weight = 10
		}
	},
	idleMink = {
		{
			id = "rbxassetid://11567937581",
			weight = 10
		}
	},
	idleCyborg = {
		{
			id = "rbxassetid://11567934777",
			weight = 10
		}
	},
	idleDraco = {
		{
			id = "rbxassetid://18461641823",
			weight = 10
		}
	},
	idleDragonHybrid = {
		{
			id = "rbxassetid://134316320430222",
			weight = 10
		}
	},
	idleDarkBlade = {
		{
			id = "rbxassetid://15012018860",
			weight = 10
		}
	},
	walk = {
		{
			id = "rbxassetid://9802959564",
			weight = 10
		}
	},
	walkDarkBlade = {
		{
			id = "rbxassetid://15012020029",
			weight = 10
		}
	},
	walkKitsune = {
		{
			id = "rbxassetid://15518780433",
			weight = 10
		}
	},
	walkHover = {
		{
			id = "rbxassetid://18461645961",
			weight = 10
		}
	},
	run = {
		{
			id = "rbxassetid://9884584522",
			weight = 10
		}
	},
	runDarkBlade = {
		{
			id = "rbxassetid://15012021154",
			weight = 10
		}
	},
	runKitsune = {
		{
			id = "rbxassetid://15518775641",
			weight = 10
		}
	},
	runHover = {
		{
			id = "rbxassetid://18461645961",
			weight = 10
		}
	},
	idleSnowBall = {
		{
			id = "rbxassetid://128294990648266",
			weight = 10
		}
	},
	walkSnowBall = {
		{
			id = "rbxassetid://82326928164137",
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
			id = "rbxassetid://9884586404",
			weight = 10
		}
	},
	jumpKitsune = {
		{
			id = "rbxassetid://15518781446",
			weight = 10
		}
	},
	fall = {
		{
			id = "http://www.roblox.com/asset/?id=9811521002",
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
local v12 = {
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
	if v10[name] ~= nil then
		for _, connection in pairs(v10[name].connections) do
			connection:disconnect()
		end
	end

	v10[name] = {}
	v10[name].count = 0
	v10[name].totalWeight = 0
	v10[name].connections = {}
	script:FindFirstChild(name)

	if v10[name].count <= 0 then
		for k, item in pairs(items) do
			v10[name][k] = {}
			v10[name][k].anim = Instance.new("Animation")
			v10[name][k].anim.Name = name
			v10[name][k].anim.AnimationId = item.id
			v10[name][k].weight = item.weight
			v10[name].count = v10[name].count + 1
			v10[name].totalWeight = v10[name].totalWeight + item.weight
		end
	end

	for _, v13 in pairs(v10) do
		for i = 1, v13.count do
			if v9[v13[i].anim.AnimationId] ~= nil then
				continue
			end

			humanoid:LoadAnimation(v13[i].anim)
			v9[v13[i].anim.AnimationId] = true
		end
	end
end

function configureAnimationSetOld(name, items)
	if v10[name] ~= nil then
		for _, connection in pairs(v10[name].connections) do
			connection:disconnect()
		end
	end

	v10[name] = {}
	v10[name].count = 0
	v10[name].totalWeight = 0
	v10[name].connections = {}
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
		table.insert(v10[name].connections, child.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v10[name].connections, child.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v13 = 1

		for _, animation in pairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v10[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v10[name][v13] = {}
			v10[name][v13].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v10[name][v13].weight = 1
			else
				v10[name][v13].weight = weight.Value
			end

			v10[name].count = v10[name].count + 1
			v10[name].totalWeight = v10[name].totalWeight + v10[name][v13].weight
			v13 += 1
		end
	end

	if v10[name].count <= 0 then
		for k, item in pairs(items) do
			v10[name][k] = {}
			v10[name][k].anim = Instance.new("Animation")
			v10[name][k].anim.Name = name
			v10[name][k].anim.AnimationId = item.id
			v10[name][k].weight = item.weight
			v10[name].count = v10[name].count + 1
			v10[name].totalWeight = v10[name].totalWeight + item.weight
		end
	end

	for _, v13 in pairs(v10) do
		for i = 1, v13.count do
			humanoid:LoadAnimation(v13[i].anim)
		end
	end
end

function scriptChildModified(p)
	local v13 = v11[p.Name]

	if v13 ~= nil then
		configureAnimationSet(p.Name, v13)
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

for k, v13 in pairs(v11) do
	configureAnimationSet(k, v13)
end

local value = "None"
local v13 = 0
local v14 = 0
local flag = false

function stopAllAnimations()
	local v15 = v5
	local v16 = v12[v15] ~= nil and v12[v15] == false and "idle" or v15

	if flag then
		v16 = "idle"
		flag = false
	end

	v5 = ""
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

	if v8 ~= nil then
		v8:Stop()
		v8:Destroy()
		v8 = nil
	end

	return v16
end

function getHeightScale()
	if not (humanoid and humanoid.AutomaticScalingEnabled) then
		return 1
	end

	local v15 = humanoid.HipHeight / 2.66

	if scaleDampeningPercent == nil then
		scaleDampeningPercent = script:FindFirstChild("ScaleDampeningPercent")
	end

	if scaleDampeningPercent ~= nil then
		return 1 + (humanoid.HipHeight - 2.66) * scaleDampeningPercent.Value / 2.66
	end

	return v15
end

local function rootMotionCompensation(p)
	return p * 1.25 / getHeightScale()
end

local function setRunSpeed(p)
	local v15 = p * 1.25 / getHeightScale()
	local v16 = v15 / 0.5
	local v17 = v15 / 1

	if not (v15 <= 0.5) and v15 < 1 then
		local _ = 1 - (v15 - 0.5) / 0.5
		v16 = 1
		v17 = 1
	end

	track:AdjustSpeed(v16)
	v8:AdjustSpeed(v17)
end

function setAnimationSpeed(p)
	if v5:find("walk") or v5:find("run") then
		setRunSpeed(p)
	elseif p ~= v7 then
		v7 = p
		track:AdjustSpeed(v7)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v5:find("walk") or v5:find("run") then
			if v2 == true then
				if v8.Looped ~= true then
					v8.TimePosition = 0
				end

				if track.Looped ~= true then
					track.TimePosition = 0
				end
			else
				v8.TimePosition = 0
				track.TimePosition = 0
			end
		else
			local v15 = v5
			local v16 = v12[v15] ~= nil and v12[v15] == false and "idle" or v15

			if flag then
				if track.Looped then
					return
				end

				v16 = "idle"
				flag = false
			end

			local v17 = v7
			playAnimation(v16, 0.15, humanoid)
			setAnimationSpeed(v17)
		end
	end
end

function rollAnimation(p)
	local v15 = math.random(1, v10[p].totalWeight)
	local v16 = 1

	while v10[p][v16].weight < v15 do
		v15 -= v10[p][v16].weight
		v16 += 1
	end

	return v16
end

local function switchToAnim(animation, value2, p, animator2)
	if animation ~= v6 then
		if track ~= nil then
			track:Stop(p)
			track:Destroy()
		end

		if v8 ~= nil and v2 == true then
			v8 = nil
		end

		v7 = 1
		track = animator2:LoadAnimation(animation)
		track.Priority = Enum.AnimationPriority.Core
		track:Play(p)
		v5 = value2
		v6 = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if value2:find("walk") or value2:find("run") then
			v8 = track

			if keyframeReachedConnection2 ~= nil then
				keyframeReachedConnection2:disconnect()
			end

			keyframeReachedConnection2 = v8.KeyframeReached:connect(keyFrameReachedFunc)
		end
	end
end

function calculatePlayAnimation(p)
	local value2 = parent:FindFirstChild("RaceTransformed") and parent.RaceTransformed.Value
	local v15 = p == "walk" or p == "run"
	local v16

	if p == "idle" then
		if value2 then
			v16 = "idle" .. playerFromCharacter.Data.Race.Value
		else
			v16 = parent:FindFirstChild("DragonHybrid") and "idleDragonHybrid" or "idle"
		end
	else
		v16 = p
	end

	if v15 and value2 and (playerFromCharacter.Data.Race.Value == "Draco" or playerFromCharacter.Data.Race.Value == "Ghoul" or playerFromCharacter.Data.Race.Value == "Skypiea") then
		v16 = p .. "Hover"
	end

	if v16 == "idle" or v15 then
		local equippedWeapon = parent:FindFirstChild("EquippedWeapon")

		if equippedWeapon and equippedWeapon:GetAttribute("WeaponName") == "darkblade" then
			v16 = p .. "DarkBlade"
		end
	end

	if (v16 == "idle" or v15 or v16 == "jump") and parent:FindFirstChild("KitsuneTail3") then
		local tool = parent:FindFirstChildWhichIsA("Tool")

		if tool == nil or tool and tool.ToolTip ~= "Sword" and tool.ToolTip ~= "Gun" and tool.ToolTip ~= "Melee" then
			v16 = p .. "Kitsune"
		end
	end

	if p ~= "idle" and not v15 or parent:GetAttribute("PushingSnowball") ~= true then
		return v16
	end

	if v15 then
		return "walkSnowBall"
	end

	return "idleSnowBall"
end

function playAnimation(p, p2, p3)
	local v15 = calculatePlayAnimation(p)
	local v16 = rollAnimation(v15)
	switchToAnim(v10[v15][v16].anim, v15, p2, p3)
	flag = false
end

function playEmote(p, p2, p3)
	switchToAnim(p, p.Name, p2, p3)
	flag = true
end

local v15 = ""
local track2 = nil
local v16 = nil
local keyframeReachedConnection3 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v15, 0, humanoid)
	end
end

function playToolAnimation(p, p2, animator2, priority)
	local v17 = rollAnimation(p)
	local anim = v10[p][v17].anim

	if v16 ~= anim then
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
		v15 = p
		v16 = anim
		keyframeReachedConnection3 = track2.KeyframeReached:connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v17 = v15

	if keyframeReachedConnection3 ~= nil then
		keyframeReachedConnection3:disconnect()
	end

	v15 = ""
	v16 = nil

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v17
end

function onRunning(p)
	if (v3 and flag and humanoid.MoveDirection == createVector(0, 0, 0) and humanoid.WalkSpeed or 0.75) < p and not humanoidRootPart:FindFirstChild("BodyPosition") then
		local Global = require(game.ReplicatedStorage.Global)
		local v17 = Global.Running and 26 or 18
		local playAnimation2 = playAnimation
		local Global2 = require(game.ReplicatedStorage.Global)
		playAnimation2(Global2.Running and "run" or "walk", 0.2, humanoid)
		local v18

		if v5 == "walkDarkBlade" or v5 == "runDarkBlade" then
			v18 = p
		else
			v18 = (v5 == "walkHover" or v5 == "runHover") and 250 or v17
		end

		setAnimationSpeed(p / v18)
		v = "Running"
	elseif v12[v5] == nil and not flag then
		playAnimation("idle", 0.2, humanoid)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1, humanoid)
	v14 = 0.31
	v = "Jumping"
end

function onClimbing(p)
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(p / 5)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v14 <= 0 then
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
	if p > 1 then
		playAnimation("swim", 0.4, humanoid)
		setAnimationSpeed(1.8)
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

local v17 = 0
local v18 = false
local v19 = false
local v20 = false

function stepAnimate(p)
	local equippedWeapon = parent:FindFirstChild("EquippedWeapon")
	local v21 = equippedWeapon and equippedWeapon:GetAttribute("WeaponName") == "darkblade"

	if v21 ~= v19 then
		if v5:find("idle") then
			local v22 = v5
			playAnimation(not v21 and "idle" or v22, 0.1, humanoid)
		elseif v5:find("walk") or v5:find("run") then
			onRunning((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude)
		end
	end

	local kitsuneTail3 = parent:FindFirstChild("KitsuneTail3")

	if kitsuneTail3 then
		local tool = parent:FindFirstChildWhichIsA("Tool")

		if tool ~= nil and (not tool or tool.ToolTip == "Sword" or tool.ToolTip == "Gun" or tool.ToolTip == "Melee") then
			kitsuneTail3 = false
		end
	end

	if kitsuneTail3 ~= v18 then
		if v5:find("idle") then
			local v22 = v5
			playAnimation(not kitsuneTail3 and "idle" or v22, 0.1, humanoid)
		elseif v5:find("walk") or v5:find("run") then
			onRunning((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude)
		end
	end

	local pushingSnowball = parent:GetAttribute("PushingSnowball") == true

	if pushingSnowball ~= v20 then
		if v5:find("idle") then
			playAnimation("idle", 0.1, humanoid)
		elseif v5:find("walk") or v5:find("run") then
			onRunning((humanoidRootPart.Velocity * createVector(1, 0, 1)).Magnitude)
		end
	end

	local v22 = p - v17
	v17 = p

	if v14 > 0 then
		v14 -= v22
	end

	if v == "FreeFall" and v14 <= 0 then
		local Global = require(game.ReplicatedStorage.Global)

		if Global.Swimming then
			playAnimation("swimidle", 0.4, humanoid)
			v = "Standing"
		else
			playAnimation("fall", 0.2, humanoid)
		end
	else
		if v == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v == "Running" then
			local playAnimation2 = playAnimation
			local Global = require(game.ReplicatedStorage.Global)
			playAnimation2(Global.Running and "run" or "walk", 0.2, humanoid)
		elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" or v == "PlatformStanding" then
			stopAllAnimations()
		end
	end

	local tool = parent:FindFirstChildOfClass("Tool")

	if tool and tool:FindFirstChild("Handle") and tool.Name ~= "Skull Guitar" then
		local toolAnim = getToolAnim(tool)

		if toolAnim then
			value = toolAnim.Value
			toolAnim.Parent = nil
			v13 = p + 0.3
		end

		if v13 < p then
			v13 = 0
			value = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value = "None"
		v16 = nil
		v13 = 0
	end

	v19 = v21
	v18 = kitsuneTail3
	v20 = pushingSnowball
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
	local v21 = ""

	if string.sub(value2, 1, 3) == "/e " then
		v21 = string.sub(value2, 4)
	elseif string.sub(value2, 1, 7) == "/emote " then
		v21 = string.sub(value2, 8)
	end

	if v == "Standing" and v12[v21] ~= nil then
		playAnimation(v21, 0.1, humanoid)
	end
end)
local playEmote_2 = script:WaitForChild("PlayEmote")

function playEmote_2.OnInvoke(animation)
	if v ~= "Standing" then
		return
	end

	if v12[animation] == nil then
		if typeof(animation) ~= "Instance" or not animation:IsA("Animation") then
			return false
		end

		playEmote(animation, 0.1, humanoid)
	else
		playAnimation(animation, 0.1, humanoid)
	end

	if v4 then
		return true, track
	end

	return true
end

if parent.Parent ~= nil then
	playAnimation("idle", 0.1, humanoid)
	v = "Standing"
end

while parent.Parent ~= nil do
	local _, v21 = wait(0.1)
	stepAnimate(v21)
end