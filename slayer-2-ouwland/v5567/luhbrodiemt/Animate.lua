local createVector = vector.create
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
local localPlayer = game.Players.LocalPlayer
game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Animations"):WaitForChild("Default_Core")
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
local currentAnimInstance = script:WaitForChild("currentAnimInstance")
current_anims_ft = {}
local equipped = game.Players.LocalPlayer:WaitForChild("Items_Config", 999):WaitForChild("Equipped")
local child = game.ReplicatedStorage:WaitForChild("Player_Service"):WaitForChild("Data"):WaitForChild(
	game.Players.LocalPlayer.Name,
	9999
)
child:WaitForChild("slotEquipped")
local child2 = child.slots:FindFirstChild("Slot" .. child.slotEquipped.Value)
local curPower = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Skills_Provider"):WaitForChild("CurPower")

function upd_animz()
	task.wait()

	if parent and parent:FindFirstChild("Humanoid") and parent.Humanoid.Health > 0 then
		playAnimation(v5, 0.2, humanoid)
	end
end

parent.ChildAdded:Connect(function(child3)
	if child3.Name == "Mode" then
		upd_animz()
	end
end)
parent.ChildRemoved:Connect(function(child3)
	if child3.Name == "Mode" then
		upd_animz()
	end
end)
curPower.Changed:Connect(upd_animz)
child2.Race.Changed:Connect(upd_animz)
local v6 = {}
local v7 = {}
local keyframeReachedConnection = nil
local track = nil
local keyframeReachedConnection2 = nil
local track2 = nil
local v8 = 1

for _, child3 in pairs(child2.Powers:GetChildren()) do
	child3.Changed:Connect(upd_animz)
end

equipped.Changed:Connect(upd_animz)

for _, child3 in pairs(child2.Inventory.Toolbar:GetChildren()) do
	local v10

	if child3.Name == "One" then
		v10 = 1
	elseif child3.Name == "Two" then
		v10 = 2
	elseif child3.Name == "Three" then
		v10 = 3
	elseif child3.Name == "Four" then
		v10 = 4
	elseif child3.Name == "Five" then
		v10 = 5
	else
		v10 = false
	end

	child3.Changed:Connect(function()
		if v10 == equipped.Value then
			upd_animz()
		end
	end)
end

local v9 = {
	idle = {
		{
			id = "rbxassetid://10586618784",
			weight = 9
		}
	},
	walk = {
		{
			id = "rbxassetid://10586557245",
			weight = 10
		}
	},
	run = {
		{
			id = "rbxassetid://10559842909",
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
			id = "rbxassetid://11872465397",
			weight = 10
		}
	},
	fall = {
		{
			id = "rbxassetid://10586578992",
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
	local success4, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success4 then
		allowCustomAnimations = true
	end

	local child3 = script:FindFirstChild(name)

	if allowCustomAnimations and child3 ~= nil then
		table.insert(v6[name].connections, child3.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v6[name].connections, child3.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))

		for _, animation in pairs(child3:GetChildren()) do
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

	for _, v11 in pairs(v6) do
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
	local success4, _ = pcall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		allowCustomAnimations = StarterPlayer.AllowCustomAnimations
	end)

	if not success4 then
		allowCustomAnimations = true
	end

	local child3 = script:FindFirstChild(name)

	if allowCustomAnimations and child3 ~= nil then
		table.insert(v6[name].connections, child3.ChildAdded:connect(function(_)
			configureAnimationSet(name, items)
		end))
		table.insert(v6[name].connections, child3.ChildRemoved:connect(function(_)
			configureAnimationSet(name, items)
		end))
		local v11 = 1

		for _, animation in pairs(child3:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v6[name].connections, animation.Changed:connect(function(_)
				configureAnimationSet(name, items)
			end))
			v6[name][v11] = {}
			v6[name][v11].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v6[name][v11].weight = 1
			else
				v6[name][v11].weight = weight.Value
			end

			v6[name].count = v6[name].count + 1
			v6[name].totalWeight = v6[name].totalWeight + v6[name][v11].weight
			v11 += 1
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

	for _, v11 in pairs(v6) do
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

local v11 = 0
local flag = false

function stopAllAnimations()
	local v12 = v5
	local v13 = v10[v12] ~= nil and v10[v12] == false and "idle" or v12

	if flag then
		v13 = "idle"
		flag = false
	end

	v5 = ""
	currentAnimInstance.Value = nil

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
	return p * 1.25 / getHeightScale()
end

local function setRunSpeed(p)
	local v12 = p * 1.25 / getHeightScale()
	local v13 = 0.0001
	local _ = v12 / 0.5
	local _ = v12 / 1
	local v14

	if v12 <= 0.5 then
		v13 = 1
		v14 = 0.0001
	elseif v12 < 1 then
		v14 = (v12 - 0.5) / 0.5
		v13 = 1 - v14
	else
		v14 = 1
	end

	track:AdjustWeight(v13)
	track2:AdjustWeight(v14)
end

function keyFrameReachedFunc(p)
	if p == "End" then
		if v5 == "walk" then
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
			local v12 = v5
			local v13 = v10[v12] ~= nil and v10[v12] == false and "idle" or v12

			if flag then
				if track.Looped then
					return
				end

				v13 = "idle"
				flag = false
			end

			playAnimation(v13, 0.15, humanoid)
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
	if animation ~= currentAnimInstance.Value then
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

		v8 = 1
		track = animator2:LoadAnimation(animation)

		if p ~= "jump" then
			track.Priority = Enum.AnimationPriority.Core
		end

		track:Play(p2)
		v5 = p
		currentAnimInstance.Value = animation

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:connect(keyFrameReachedFunc)

		if p == "walk" then
			local v12 = rollAnimation("run")
			track2 = animator2:LoadAnimation(Character_info_provider.get_core_anim(localPlayer, "run") or v6.run[v12].anim)
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
	if p == nil then
		p = v5
	end

	local v12 = rollAnimation(p)
	local anim = v6[p][v12].anim
	switchToAnim(Character_info_provider.get_core_anim(localPlayer, p) or anim, p, p2, p3)
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

local v14 = nil

function onRunning(p)
	local walkSpeed = v3 and flag and humanoid.MoveDirection == createVector(0, 0, 0) and humanoid.WalkSpeed or 0.75
	local v15 = walkSpeed < p

	if v15 ~= v14 or v ~= "Running" and v ~= "Standing" then
		if walkSpeed < p then
			playAnimation("walk", 0.2, humanoid)
			v = "Running"
		elseif v10[v5] == nil and not flag then
			playAnimation("idle", 0.2, humanoid)
			v = "Standing"
		end

		v14 = v15
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

function onClimbing(_)
	playAnimation("climb", 0.1, humanoid)
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
	if p > 1 then
		playAnimation("swim", 0.4, humanoid)
		v = "Swimming"
	else
		playAnimation("swimidle", 0.4, humanoid)
		v = "Standing"
	end
end

function animateTool()
	playToolAnimation("toolnone", 0.1, humanoid, Enum.AnimationPriority.Idle)
end

function getToolAnim(instance)
	for _, child3 in ipairs(instance:GetChildren()) do
		if child3.Name == "toolanim" and child3.className == "StringValue" then
			return child3
		end
	end

	return nil
end

local v15 = 0

function stepAnimate(p)
	local v16 = p - v15
	v15 = p

	if v11 > 0 then
		v11 -= v16
	end

	if v == "FreeFall" and v11 <= 0 then
		playAnimation("fall", 0.2, humanoid)
	elseif v == "Seated" then
		playAnimation("sit", 0.5, humanoid)
	elseif v == "Running" then
		playAnimation("walk", 0.2, humanoid)
	elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" or v == "PlatformStanding" then
		stopAllAnimations()
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
Players.LocalPlayer.Chatted:connect(function(value)
	local v16 = ""

	if string.sub(value, 1, 3) == "/e " then
		v16 = string.sub(value, 4)
	elseif string.sub(value, 1, 7) == "/emote " then
		v16 = string.sub(value, 8)
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

	if v10[animation] == nil then
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
	local _, v16 = wait(0.1)
	stepAnimate(v16)
end