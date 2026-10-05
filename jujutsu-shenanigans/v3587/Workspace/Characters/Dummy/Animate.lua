local createVector = vector.create
local Debris = game:GetService("Debris")
local parent = script.Parent
local torso = parent:WaitForChild("Torso")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
local rightShoulder = torso:WaitForChild("Right Shoulder")
local leftShoulder = torso:WaitForChild("Left Shoulder")
local rightHip = torso:WaitForChild("Right Hip")
local leftHip = torso:WaitForChild("Left Hip")
torso:WaitForChild("Neck")
local humanoid = parent:WaitForChild("Humanoid")
local v = "Standing"
local CameraShaker = require(game.ReplicatedStorage.Modules.CameraShaker)
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
local animationId = nil
local v6 = {}
local v7 = {
	idle = {
		{
			id = "http://www.roblox.com/asset/?id=120133391090244",
			weight = 9
		},
		{
			id = "http://www.roblox.com/asset/?id=138196552148011",
			weight = 1
		}
	},
	walk = {
		{
			id = "http://www.roblox.com/asset/?id=96489184596023",
			weight = 10
		}
	},
	walkL = {
		{
			id = "http://www.roblox.com/asset/?id=117941450906936",
			weight = 10
		}
	},
	walkR = {
		{
			id = "http://www.roblox.com/asset/?id=77705898607209",
			weight = 10
		}
	},
	sprint = {
		{
			id = "http://www.roblox.com/asset/?id=140491244934559",
			weight = 10
		}
	},
	jump = {
		{
			id = "http://www.roblox.com/asset/?id=134343219970072",
			weight = 10
		}
	},
	fall = {
		{
			id = "http://www.roblox.com/asset/?id=126572575938378",
			weight = 10
		}
	},
	climb = {
		{
			id = "http://www.roblox.com/asset/?id=93938476274140",
			weight = 10
		}
	},
	sit = {
		{
			id = "http://www.roblox.com/asset/?id=137199497329581",
			weight = 10
		}
	}
}
local v8 = {
	Gojo = function(_)
		return 77992084875736
	end,
	Hakari = function(_)
		return 135750035707554
	end,
	Mahoraga = function(_)
		return 85570635517461
	end,
	Mahito = function(_)
		return 85012092465916
	end,
	Charles = function(_)
		return 72509133503569
	end,
	Hiromi = function(p)
		if p.SetAssets:FindFirstChild("ExecSword") then
			return 119619096808750
		end

		return 140491244934559
	end,
	Yuta = function(instance)
		if instance:GetAttribute("Sword") then
			return 119619096808750
		end

		return 140491244934559
	end,
	Nanami = function(instance)
		if instance:GetAttribute("InUlt") then
			return 98616794135588
		end

		return 119619096808750
	end,
	Haruta = function(instance)
		if instance:GetAttribute("Sword") == true then
			return 119619096808750
		end

		return 140491244934559
	end,
	Kurourushi = function(_)
		return 119619096808750
	end,
	Uro = function(_)
		return 88607563050254
	end,
	Heian = function(_)
		return 85570635517461
	end,
	Goku = function(instance)
		if instance:GetAttribute("InUlt") then
			return 97238189166310
		end

		return 125812953913280
	end,
	Mokou = function(_)
		return 77801551230831
	end,
	Chara = function(_)
		return 114113678077830
	end
}
local v9 = {}

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

local v10 = 0

function stopAllAnimations()
	local v11 = v3
	local v12 = v9[v11] ~= nil and v9[v11] == false and "idle" or v11
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

	return v12
end

function setAnimationSpeed(p)
	if p ~= v5 then
		v5 = p
		track:AdjustSpeed(v5)
	end
end

function keyFrameReachedFunc(p)
	if p == "End" then
		local v11 = v3
		local v12 = v9[v11] ~= nil and v9[v11] == false and "idle" or v11
		local v13 = v5
		playAnimation(v12, 0, humanoid)
		setAnimationSpeed(v13)
	end
end

function playAnimation(p, p2, animator2)
	local v11 = math.random(1, v6[p].totalWeight)
	local v12 = 1

	while v6[p][v12].weight < v11 do
		v11 -= v6[p][v12].weight
		v12 += 1
	end

	local anim = v6[p][v12].anim

	if p == "sprint" and v8[parent:GetAttribute("Moveset")] and v8[parent:GetAttribute("Moveset")](parent) then
		anim.AnimationId = "rbxassetid://" .. v8[parent:GetAttribute("Moveset")](parent)
		anim.Name = "sprint"

		if animationId ~= anim.AnimationId then
			animationId = anim.AnimationId
		end
	end

	if anim ~= v4 then
		if track ~= nil then
			track:Stop(p2)
			track = nil
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

local function getWalkAnimationName()
	local v11 = (1 - humanoid.Health / humanoid.MaxHealth) * 3
	local v12 = game.StarterPlayer.CharacterWalkSpeed * 1.375 - v11

	if parent:GetAttribute("Sprint") then
		local walkSpeed = humanoid.WalkSpeed

		if v12 - 1 <= walkSpeed then
			return "sprint"
		end
	end

	if parent.Info:FindFirstChild("Block") then
		return "walk"
	end

	local dot = humanoid.MoveDirection:Dot(humanoid.RootPart.CFrame.RightVector)

	if dot > 0.5 then
		return "walkR"
	end

	if dot < -0.5 then
		return "walkL"
	end

	return "walk"
end

function onRunning(p)
	local v11 = p / (not v2 and 1 or parent:GetScale())

	if v11 > 2 then
		playAnimation(getWalkAnimationName(), 0.2, humanoid)
		local v12 = parent:GetAttribute("Sprint") and 22 or game.StarterPlayer.CharacterWalkSpeed
		setAnimationSpeed(v11 / v12)
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
	v10 = 0.3
	v = "Jumping"
end

function onClimbing(p)
	local v11 = p / (not v2 and 1 or parent:GetScale())
	playAnimation("climb", 0.1, humanoid)
	setAnimationSpeed(v11 / 12)
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

function moveSit()
	rightShoulder.MaxVelocity = 0.15
	leftShoulder.MaxVelocity = 0.15
	rightShoulder:SetDesiredAngle(1.57)
	leftShoulder:SetDesiredAngle(-1.57)
	rightHip:SetDesiredAngle(1.57)
	leftHip:SetDesiredAngle(-1.57)
end

local v11 = 0

function move(p)
	local v12 = 1
	local v13 = 1
	local v14 = p - v11
	v11 = p
	local flag = false

	if v10 > 0 then
		v10 -= v14
	end

	if v == "FreeFall" and v10 <= 0 then
		playAnimation("fall", 0.3, humanoid)
	else
		if v == "Seated" then
			playAnimation("sit", 0.5, humanoid)
			return
		end

		if v == "Running" then
			playAnimation(getWalkAnimationName(), 0.2, humanoid)
		elseif v == "Dead" or v == "GettingUp" or v == "FallingDown" or v == "Seated" then
			stopAllAnimations()
			flag = true
			v13 = 1
			v12 = 0.1
		end
	end

	if flag then
		local v15 = v12 * math.sin(p * v13)
		rightShoulder:SetDesiredAngle(v15 + 0)
		leftShoulder:SetDesiredAngle(v15 - 0)
		rightHip:SetDesiredAngle(-v15)
		leftHip:SetDesiredAngle(-v15)
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
humanoid.Swimming:connect(onSwimming)

local function fixSprint()
	for _, v12 in pairs(humanoid:GetPlayingAnimationTracks()) do
		if animationId and v12.Animation.AnimationId == animationId then
			v12:Stop()
		end
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
end

parent:GetAttributeChangedSignal("Moveset"):Connect(fixSprint)
parent:GetAttributeChangedSignal("InUlt"):Connect(fixSprint)
parent:GetAttributeChangedSignal("Sword"):Connect(fixSprint)
task.spawn(function()
	local track2 = humanoid:LoadAnimation(game.ReplicatedStorage.Animations.Misc.Movement.Land)
	local track3 = humanoid:LoadAnimation(game.ReplicatedStorage.Animations.Misc.Movement.Roll)
	track2.Priority = Enum.AnimationPriority.Movement
	track3.Priority = Enum.AnimationPriority.Movement
	local now = -1000
	humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump == true then
			now = tick()
		end
	end)
	local sounds = game.ReplicatedStorage.Sounds
	local Knit = require(game.ReplicatedStorage.Knit.Knit)
	Knit.OnStart():await()
	local service = Knit.GetService("MovementService")
	local controller = Knit.GetController("FXController")
	humanoid.StateChanged:Connect(function(_, p)
		if p == Enum.HumanoidStateType.Landed then
			local Y = humanoidRootPart.Velocity.Y

			if Y < -50 and not parent:GetAttribute("Movement") and not parent.Info:FindFirstChild("InSkill") and not parent.Info:FindFirstChild("Block") and not parent.Info:FindFirstChild("Stun") and not parent.Info:FindFirstChild("NoParkour") and tick() - now < 0.25 then
				humanoid.JumpPower = 0
				parent:SetAttribute("Movement", true)
				local boolValue = Instance.new("BoolValue")
				boolValue.Name = "NoJump"
				boolValue.Parent = parent.Info
				Debris:AddItem(boolValue, 0.4)
				local boolValue2 = Instance.new("BoolValue")
				boolValue2.Name = "InRoll"
				boolValue2.Parent = parent.Info
				Debris:AddItem(boolValue2, 0.4)
				local bodyVelocity = Instance.new("BodyVelocity", parent.Torso)
				bodyVelocity.MaxForce = createVector(40000, 0, 40000)
				bodyVelocity.P = 40000
				bodyVelocity.Name = "MovementForce"
				Debris:AddItem(bodyVelocity, 0.4)
				sounds.Misc.Parkour.Roll.Pitch = math.random(90, 110) / 100
				controller:PlaySound(sounds.Misc.Parkour.Roll, humanoidRootPart, game.SoundService.Effect)
				service.Parkour:Fire(true)
				bodyVelocity.Velocity = createVector(0, -30, 0) + parent.HumanoidRootPart.CFrame.LookVector * math.clamp(
					-Y / 1.5,
					0,
					60
				)
				local TweenService = game:GetService("TweenService")
				TweenService:Create(bodyVelocity, TweenInfo.new(0.6), {
					MaxForce = createVector(0, 0, 0)
				}):Play()
				track3:Play(0.1, nil, 0.7)
				task.wait(0.4)
				parent:SetAttribute("Movement", nil)
				controller:DustTrail(parent, 0.4)
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			else
				track2:Play(nil, math.clamp(-humanoidRootPart.Velocity.Y / 100, 0, 1), 2)
			end
		end
	end)
end)
playAnimation("idle", 0.1, humanoid)
v = "Standing"

while parent.Parent ~= nil do
	local _, v12 = wait(0.1)
	move(v12)
end