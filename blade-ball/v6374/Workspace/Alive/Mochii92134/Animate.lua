local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local alive = workspace:WaitForChild("Alive")
workspace:WaitForChild("Dead")
local ServerInfo = require(ReplicatedStorage:WaitForChild("ServerInfo"))
local LTM = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LTM"))
local DeepCopy = require(ReplicatedStorage.Shared.DeepCopy)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local parent = script.Parent
local torso = parent:WaitForChild("Torso")
local rightShoulder = torso:WaitForChild("Right Shoulder")
local leftShoulder = torso:WaitForChild("Left Shoulder")
local rightHip = torso:WaitForChild("Right Hip")
local leftHip = torso:WaitForChild("Left Hip")
torso:WaitForChild("Neck")
local humanoid = parent:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local v = "Standing"
local flag = false
local v2 = {
	Cloud = true
}
local v3 = {
	jump = true,
	fall = true,
	idle = true,
	walk = true
}
local v4 = {
	Cloud = "rbxassetid://76300887593029"
}
local currentLTM = LTM.getCurrentLTM()
local lTMServer = ServerInfo.isLTMServer()

if lTMServer then
	lTMServer = currentLTM and currentLTM.getGameMode() == "Flying"
end

LTM.OnModeChange(function(p)
	lTMServer = ServerInfo.isLTMServer() and p.getGameMode() == "Flying"
end)
local v5 = nil
local ancestryChangedConnection = nil
local PlayerModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
PlayerModule:GetControls()

-- equivalent calls inferred from this helper; original call sites unknown
local function DestroyController()
	if v5 then
		v5:Destroy()
		v5 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartFlying()
	task.defer(function()
		if parent and parent:IsDescendantOf(alive) then
			local playingAnimationTracks = animator:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
				if playingAnimationTrack:GetAttribute("Idle") then
					continue
				end

				playingAnimationTrack:Stop(0)
				playingAnimationTrack:Destroy()
			end

			v = "Standing"
			DestroyController() -- equivalent call inferred; original call site unknown
			local CharacterFlight = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("LTM"):WaitForChild("CharacterFlight"))
			v5 = CharacterFlight.new(parent)
			flag = true
		else
			DestroyController() -- equivalent call inferred; original call site unknown
			flag = false
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function EnableFlyingMode()
	local PlayerModule2 = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
	PlayerModule2:GetControls()

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
	end

	ancestryChangedConnection = parent.AncestryChanged:Connect(StartFlying)
end

if lTMServer then
	EnableFlyingMode() -- equivalent call inferred; original call site unknown
end

local function CheckHovergoalMode()
	if workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal" then
		StartFlying() -- equivalent call inferred; original call site unknown
		EnableFlyingMode() -- equivalent call inferred; original call site unknown
	else
		if flag then
			DestroyController() -- equivalent call inferred; original call site unknown
			flag = false
		end

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end
	end
end

if workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal" then
	task.defer(function()
		if parent and parent:IsDescendantOf(alive) then
			local playingAnimationTracks = animator:GetPlayingAnimationTracks()

			for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
				if playingAnimationTrack:GetAttribute("Idle") then
					continue
				end

				playingAnimationTrack:Stop(0)
				playingAnimationTrack:Destroy()
			end

			v = "Standing"
			DestroyController() -- equivalent call inferred; original call site unknown
			local CharacterFlight = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("LTM"):WaitForChild("CharacterFlight"))
			v5 = CharacterFlight.new(parent)
			flag = true
		else
			DestroyController() -- equivalent call inferred; original call site unknown
			flag = false
		end
	end)
	EnableFlyingMode() -- equivalent call inferred; original call site unknown
else
	if flag then
		DestroyController() -- equivalent call inferred; original call site unknown
		flag = false
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
		ancestryChangedConnection = nil
	end
end

workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(CheckHovergoalMode)
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPlayEmoteByIdAnimTrackReturn2")
end)
local AnimationProfiles = require(ReplicatedStorage.Shared.AnimationProfiles)
local v6 = {
	walk = {
		{
			id = "rbxassetid://13772468608",
			weight = 10
		}
	},
	run = {
		{
			id = "rbxassetid://13772468608",
			weight = 10
		}
	},
	jump = {
		{
			id = "http://www.roblox.com/asset/?id=125750702",
			weight = 10
		}
	},
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
local v7 = {}
local v8 = ""
local v9 = {
	wave = false,
	point = false,
	dance1 = true,
	dance2 = true,
	dance3 = true,
	laugh = false,
	cheer = false
}
local v10 = nil
local keyframeReachedConnection = nil
local track = nil
local value = 1
local flag2 = false
local v11 = { "dance1", "dance2", "dance3" }
local v12 = success and result

for _, child in ReplicatedStorage.Misc.Emotes:GetChildren() do
	if child:GetAttribute("UseAsIdle") then
		AnimationProfiles[child.Name] = {
			idle = {
				{
					id = child.AnimationId,
					weight = 10
				}
			}
		}
	end
end

function configureAnimationSet(name)
	local v13 = v6[name]

	if v7[name] ~= nil then
		for _, connection in pairs(v7[name].Connections) do
			connection:Disconnect()
		end
	end

	v7[name] = {}
	v7[name].count = 0
	v7[name].totalWeight = 0
	v7[name].Connections = {}
	local child = script:FindFirstChild(name)

	if child ~= nil then
		table.insert(v7[name].Connections, child.ChildAdded:Connect(function(_)
			configureAnimationSet(name)
		end))
		table.insert(v7[name].Connections, child.ChildRemoved:Connect(function(_)
			configureAnimationSet(name)
		end))
		local v14 = 1

		for _, animation in ipairs(child:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			table.insert(v7[name].Connections, animation.Changed:Connect(function(_)
				configureAnimationSet(name)
			end))
			v7[name][v14] = {}
			v7[name][v14].anim = animation
			local weight = animation:FindFirstChild("Weight")

			if weight == nil then
				v7[name][v14].weight = 1
			else
				v7[name][v14].weight = weight.Value
			end

			v7[name].count += 1
			v7[name].totalWeight += v7[name][v14].weight
			v14 += 1
		end
	end

	if v7[name].count <= 0 then
		for k, v14 in v13 do
			local animation = Instance.new("Animation")
			animation.Name = name
			animation.AnimationId = v14.id

			if v14.animationSpeed then
				local intValue = Instance.new("IntValue")
				intValue.Name = "AnimationSpeed"
				intValue.Value = v14.animationSpeed
				intValue.Parent = animation
			end

			v7[name][k] = {}
			v7[name][k].anim = animation
			v7[name][k].weight = v14.weight
			v7[name].count += 1
			v7[name].totalWeight += v14.weight
		end
	end
end

local animator2

if humanoid then
	animator2 = humanoid:FindFirstChildOfClass("Animator")
end

if animator2 then
	local playingAnimationTracks = animator2:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
		playingAnimationTrack:Stop(0)
		playingAnimationTrack:Destroy()
	end
end

for k in v6 do
	configureAnimationSet(k)
end

local value2 = "None"
local v13 = 0
local v14 = 0

function stopAllAnimations()
	local v15 = v8
	local v16 = v9[v15] ~= nil and v9[v15] == false and "idle" or v15
	v8 = ""
	v10 = nil

	if keyframeReachedConnection ~= nil then
		keyframeReachedConnection:Disconnect()
	end

	if track ~= nil then
		track:Stop()
		track:Destroy()
		track = nil
	end

	return v16
end

function setAnimationSpeed(p: number)
	if p ~= value then
		value = p
		track:AdjustSpeed(value)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		local v15 = v8
		local v16 = v9[v15] ~= nil and v9[v15] == false and "idle" or v15
		local v17 = value
		playAnimation(v16, 0)
		setAnimationSpeed(v17)
	end
end

local v15 = nil
local v16 = nil

local function updateAuxAnim()
	local currentlyEquippedSword = parent:GetAttribute("CurrentlyEquippedSword")
	local animationId = currentlyEquippedSword and v4[currentlyEquippedSword]

	if animationId == v16 then
		return
	end

	if v15 then
		v15:Stop()
		v15:Destroy()
		v15 = nil
	end

	v16 = animationId

	if not animationId then
		return
	end

	local animation = Instance.new("Animation")
	animation.Name = "AuxAnim" .. currentlyEquippedSword
	animation.AnimationId = animationId
	local track2 = animator:LoadAnimation(animation)
	track2.Priority = Enum.AnimationPriority.Core
	track2.Looped = true
	track2:Play()
	v15 = track2
end

local function shouldFreezeAirAnimation(currentlyPlayingAnimation)
	local swordAnimationProfile = parent:GetAttribute("SwordAnimationProfile")

	if swordAnimationProfile == nil or v2[swordAnimationProfile] ~= true or not parent:GetAttribute("HasAccessoryEquipped") then
		return false
	end

	if currentlyPlayingAnimation == "jump" or currentlyPlayingAnimation == "fall" then
		return true
	end

	if v3[currentlyPlayingAnimation] then
		local state = humanoid:GetState()

		if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
			return true
		end
	end

	return false
end

function playAnimation(currentlyPlayingAnimation: string, p: number?)
	if shouldFreezeAirAnimation(currentlyPlayingAnimation) then
		return
	end

	local v17 = math.random(1, v7[currentlyPlayingAnimation].totalWeight)
	local v18 = 1

	while v7[currentlyPlayingAnimation][v18].weight < v17 do
		v17 -= v7[currentlyPlayingAnimation][v18].weight
		v18 += 1
	end

	local anim = v7[currentlyPlayingAnimation][v18].anim
	local priority = v7[currentlyPlayingAnimation][v18].priority or Enum.AnimationPriority.Core
	local transition = v7[currentlyPlayingAnimation][v18].transition or p

	if anim ~= v10 then
		parent:SetAttribute("CurrentlyPlayingAnimation", currentlyPlayingAnimation)

		if track ~= nil then
			track:Stop(transition)
			track:Destroy()
		end

		value = 1
		local animationSpeed = anim:FindFirstChild("AnimationSpeed")

		if animationSpeed then
			value = animationSpeed.Value
		end

		track = animator:LoadAnimation(anim)
		track.Priority = priority
		track:AdjustSpeed(value)
		local timePositions = {}
		track:GetMarkerReachedSignal("Pin"):Connect(function(p2: string)
			timePositions[p2] = track.TimePosition
		end)
		track:GetMarkerReachedSignal("GOTO"):Connect(function(p2: string)
			local timePosition = timePositions[p2]

			if timePosition then
				track.TimePosition = timePosition
			end
		end)
		track:Play(transition)
		v8 = currentlyPlayingAnimation
		v10 = anim

		if keyframeReachedConnection ~= nil then
			keyframeReachedConnection:Disconnect()
		end

		keyframeReachedConnection = track.KeyframeReached:Connect(keyFrameReachedFunc)
	end
end

local v17 = ""
local track2 = nil
local v18 = nil
local keyframeReachedConnection2 = nil

function toolKeyFrameReachedFunc(p)
	if p == "End" then
		playToolAnimation(v17, 0)
	end
end

function playToolAnimation(p: string, p2: number?, priority)
	local v19 = math.random(1, v7[p].totalWeight)
	local v20 = 1

	while v7[p][v20].weight < v19 do
		v19 -= v7[p][v20].weight
		v20 += 1
	end

	local anim = v7[p][v20].anim

	if v18 ~= anim then
		if track2 ~= nil then
			track2:Stop()
			track2:Destroy()
			p2 = 0
		end

		track2 = animator:LoadAnimation(anim)

		if priority then
			track2.Priority = priority
		end

		track2:Play(p2)
		v17 = p
		v18 = anim
		keyframeReachedConnection2 = track2.KeyframeReached:Connect(toolKeyFrameReachedFunc)
	end
end

function stopToolAnimations()
	local v19 = v17

	if keyframeReachedConnection2 ~= nil then
		keyframeReachedConnection2:Disconnect()
	end

	v17 = ""
	v18 = nil

	if track2 ~= nil then
		track2:Stop()
		track2:Destroy()
		track2 = nil
	end

	return v19
end

function onRunning(p)
	if p > 0.01 then
		playAnimation("walk", 0.1)

		if v10 and v10.AnimationId == "http://www.roblox.com/asset/?id=180426354" then
			setAnimationSpeed(p / 14.5)
		end

		v = "Running"
	elseif v9[v8] == nil then
		playAnimation("idle", 0.1)
		v = "Standing"
	end
end

function onDied()
	v = "Dead"
end

function onJumping()
	playAnimation("jump", 0.1)
	v14 = 0.3
	v = "Jumping"
end

function onClimbing(p: number)
	playAnimation("climb", 0.1)
	setAnimationSpeed(p / 12)
	v = "Climbing"
end

function onGettingUp()
	v = "GettingUp"
end

function onFreeFall()
	if v14 <= 0 then
		playAnimation("fall", 0.3)
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
		if child.Name == "toolanim" and child.ClassName == "StringValue" then
			return child
		end
	end

	return nil
end

function animateTool()
	if value2 == "None" then
		playToolAnimation("toolnone", 0.1, Enum.AnimationPriority.Idle)
		return
	elseif value2 == "Slash" then
		playToolAnimation("toolslash", 0, Enum.AnimationPriority.Action)
		return
	end

	if value2 ~= "Lunge" then
		return
	end

	playToolAnimation("toollunge", 0, Enum.AnimationPriority.Action)
end

function moveSit()
	rightShoulder.MaxVelocity = 0.15
	leftShoulder.MaxVelocity = 0.15
	rightShoulder:SetDesiredAngle(1.57)
	leftShoulder:SetDesiredAngle(-1.57)
	rightHip:SetDesiredAngle(1.57)
	leftHip:SetDesiredAngle(-1.57)
end

local v19 = 0

function move(p: number)
	local v20 = 1
	local v21 = 1
	local v22 = p - v19
	v19 = p
	local flag3 = false

	if v14 > 0 then
		v14 -= v22
	end

	if v == "FreeFall" and v14 <= 0 then
		playAnimation("fall", 0.3)
	else
		if v == "Seated" then
			playAnimation("sit", 0.5)
			return
		end

		if v == "Running" then
			playAnimation("walk", 0.1)
		elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" or v == "PlatformStanding" then
			stopAllAnimations()
			flag3 = true
			v21 = 1
			v20 = 0.1
		end
	end

	if flag3 then
		local v23 = v20 * math.sin(p * v21)
		rightShoulder:SetDesiredAngle(v23 + 0)
		leftShoulder:SetDesiredAngle(v23 - 0)
		rightHip:SetDesiredAngle(-v23)
		leftHip:SetDesiredAngle(-v23)
	end

	local tool = getTool()

	if tool and tool:FindFirstChild("Handle") then
		local toolAnim = getToolAnim(tool)

		if toolAnim then
			value2 = toolAnim.Value
			toolAnim.Parent = nil
			v13 = p + 0.3
		end

		if v13 < p then
			v13 = 0
			value2 = "None"
		end

		animateTool()
	else
		stopToolAnimations()
		value2 = "None"
		v18 = nil
		v13 = 0
	end
end

function scriptChildModified(p)
	if flag2 then
		return
	end

	if v6[p.Name] ~= nil then
		configureAnimationSet(p.Name)
	end
end

DeepCopy(v6)
local v20 = nil
local v21 = nil
local v22 = nil
local v23 = nil
local v24 = {
	idle = Enum.AnimationPriority.Idle,
	run = Enum.AnimationPriority.Movement,
	walk = Enum.AnimationPriority.Movement,
	jump = Enum.AnimationPriority.Action,
	fall = Enum.AnimationPriority.Action
}

local function applyProfile(items, p)
	flag2 = true

	for k, item in items do
		v6[k] = item
		local lower = k:lower()
		local child = script:FindFirstChild(lower)

		if not child then
			continue
		end

		child:ClearAllChildren()

		for k2, v25 in pairs(item) do
			local animation = Instance.new("Animation")
			animation.Name = ("AnimProfile_%s_%s_%d"):format(p, k, k2)
			animation.AnimationId = v25.id
			local intValue = Instance.new("IntValue")
			intValue.Name = "Weight"
			intValue.Value = v25.weight or 1
			intValue.Parent = animation
			local intValue2 = Instance.new("IntValue")
			intValue2.Name = "AnimationSpeed"
			intValue2.Value = v25.animationSpeed or 1
			intValue2.Parent = animation
			animation.Parent = child
			v7[k][k2].anim = animation
			v7[k][k2].priority = v25.priority or v24[k] or Enum.AnimationPriority.Core
			v7[k][k2].transition = v25.transition
		end
	end

	flag2 = false
end

local function onAnimationProfileChanged()
	local emoteAnimationProfile = parent:GetAttribute("EmoteAnimationProfile")
	local swordAnimationProfile = parent:GetAttribute("SwordAnimationProfile")
	local animationProfile = parent:GetAttribute("AnimationProfile")
	local hiding = AbilityUtils.isHiding()

	if animationProfile == v20 and emoteAnimationProfile == v21 and swordAnimationProfile == v22 and hiding == v23 then
		return
	end

	applyProfile(AnimationProfiles.Original, "Original")
	v23 = hiding
	v20 = animationProfile
	v21 = emoteAnimationProfile
	v22 = swordAnimationProfile

	if swordAnimationProfile and AnimationProfiles[swordAnimationProfile] and not hiding then
		parent:SetAttribute("SwordAnimationProfileApplied", true)
		applyProfile(AnimationProfiles[swordAnimationProfile], swordAnimationProfile)
	else
		parent:SetAttribute("SwordAnimationProfileApplied", false)
	end

	if animationProfile and AnimationProfiles[animationProfile] then
		applyProfile(AnimationProfiles[animationProfile], animationProfile)
		parent:SetAttribute("AnimationProfileApplied", animationProfile)
		parent:SetAttribute("SwordAnimationProfileApplied", false)
	else
		parent:SetAttribute("AnimationProfileApplied", false)
	end

	if emoteAnimationProfile and AnimationProfiles[emoteAnimationProfile] then
		applyProfile(AnimationProfiles[emoteAnimationProfile], emoteAnimationProfile)
	end

	if v == "Standing" then
		playAnimation("idle", 0.1)
	elseif v == "Running" then
		playAnimation("walk", 0.1)
	elseif v == "Jumping" then
		playAnimation("jump", 0.1)
	elseif v == "Climbing" then
		playAnimation("climb", 0.1)
	elseif v == "FreeFall" then
		playAnimation("fall", 0.1)
	end
end

parent:GetAttributeChangedSignal("SwordAnimationProfile"):Connect(onAnimationProfileChanged)
parent:GetAttributeChangedSignal("EmoteAnimationProfile"):Connect(onAnimationProfileChanged)
parent:GetAttributeChangedSignal("AnimationProfile"):Connect(onAnimationProfileChanged)
parent:GetAttributeChangedSignal("CurrentlyEquippedSword"):Connect(updateAuxAnim)
local updateSignalConnection = AbilityUtils.updateSignal:Connect(onAnimationProfileChanged)
task.delay(0, onAnimationProfileChanged)
task.delay(0, updateAuxAnim)
script.ChildAdded:Connect(scriptChildModified)
script.ChildRemoved:Connect(scriptChildModified)
humanoid.Died:Connect(onDied)
humanoid.Running:Connect(onRunning)
humanoid.Jumping:Connect(onJumping)
humanoid.Climbing:Connect(onClimbing)
humanoid.GettingUp:Connect(onGettingUp)
humanoid.FreeFalling:Connect(onFreeFall)
humanoid.FallingDown:Connect(onFallingDown)
humanoid.Seated:Connect(onSeated)
humanoid.PlatformStanding:Connect(onPlatformStanding)
humanoid.Swimming:Connect(onSwimming)
local Players2 = game:GetService("Players")
Players2.LocalPlayer.Chatted:Connect(function(value3)
	local v25 = ""

	if value3 == "/e dance" then
		v25 = v11[math.random(1, #v11)]
	elseif string.sub(value3, 1, 3) == "/e " then
		v25 = string.sub(value3, 4)
	elseif string.sub(value3, 1, 7) == "/emote " then
		v25 = string.sub(value3, 8)
	end

	if v == "Standing" and v9[v25] ~= nil then
		playAnimation(v25, 0.1)
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

	playAnimation(p, 0.1)

	if v12 then
		return true, track
	end

	return true
end

playAnimation("idle", 0.1)
v = "Standing"

while parent.Parent ~= nil do
	local _, v25 = wait(0.1)
	move(v25)
end

updateSignalConnection:Disconnect()