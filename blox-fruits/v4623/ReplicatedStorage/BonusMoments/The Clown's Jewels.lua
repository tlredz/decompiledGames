local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local v = {
	"LowerSkyBonusMomentSFX.Chest_Rattle_01",
	"LowerSkyBonusMomentSFX.Chest_Rattle_02",
	"LowerSkyBonusMomentSFX.Chest_Rattle_03"
}
local v2 = {
	"LowerSkyBonusMomentSFX.Get_Treasure_01",
	"LowerSkyBonusMomentSFX.Get_Treasure_02",
	"LowerSkyBonusMomentSFX.Get_Treasure_03"
}
local v3 = { "idle", "ChestIdle" }
local v4 = { "open", "ChestOpen" }
local v5 = nil
local v6 = nil
local v7 = nil
local model = nil
local v8 = 0
local v9 = 0
local v10 = nil
local renderSteppedConnection = nil
local spawnChest
local flag = false
local v11 = false
local v12 = false
local v13 = false
local heartbeatConnection = nil
local v14 = nil

local function findAnimation(instance, items)
	for _, childName in items do
		local animation = instance:FindFirstChild(childName)

		if animation and animation:IsA("Animation") then
			return animation
		end
	end

	return nil
end

local function isFinalChest()
	return v9 > 0 and v9 <= v8
end

local function buildChest(name: string, cframe: CFrame)
	local v16 = v9 > 0 and v9 <= v8 and "DiamondChest" or "Rusted Chest"
	local model2 = script:FindFirstChild(v16)

	if not (model2 and model2:IsA("Model")) then
		warn((`[ClownJewels] chest template missing - found {model2} under {script:GetFullName()}`))
		return nil
	end

	if #model2:GetChildren() == 0 then
		warn((`[ClownJewels] chest template '{v16}' is EMPTY at {model2:GetFullName()} - the rbxm did not sync, restart Rojo/Studio`))
		return nil
	end

	local clone = model2:Clone()
	clone.Name = name
	local primaryPart = clone.PrimaryPart

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = primaryPart == nil or part == primaryPart
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
	end

	clone:PivotTo(cframe)
	clone.Parent = workspace
	local animationController = clone:FindFirstChildOfClass("AnimationController")
	local animator

	if animationController then
		animator = animationController:FindFirstChildOfClass("Animator")
	end

	if animationController and not animator then
		animator = Instance.new("Animator")
		animator.Parent = animationController
	end

	local animation = findAnimation(clone, v3)
	local track

	if animator and animation then
		track = animator:LoadAnimation(animation)
		track.Looped = true
		track:Play()
	end

	return {
		model = clone,
		animator = animator,
		idleTrack = track
	}
end

local function renderedBottomY(folder)
	local v15 = 1e999

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and part.Transparency < 1) then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v16 = 0.5 * (math.abs(cFrame.XVector.Y) * size.X + math.abs(cFrame.YVector.Y) * size.Y + math.abs(cFrame.ZVector.Y) * size.Z)
		v15 = math.min(v15, cFrame.Position.Y - v16)
	end

	if v15 == 1e999 then
		local boundingBox, v16 = folder:GetBoundingBox()
		return boundingBox.Position.Y - v16.Y * 0.5
	end

	return v15
end

-- equivalent calls inferred from this helper; original call sites unknown
local function seatOnGround(model2, Y: number)
	model2:PivotTo(model2:GetPivot() + Vector3.new(0, Y - renderedBottomY(model2), 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chestBase(model2)
	local boundingBox = model2:GetBoundingBox()
	return (Vector3.new(boundingBox.Position.X, renderedBottomY(model2), boundingBox.Position.Z))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function chestRevealCFrame(cframe: CFrame)
	local v15 = cframe.Position + cframe.LookVector * 9 + cframe.RightVector * 3 + createVector(0, 6, 0)
	return CFrame.lookAt(v15, cframe.Position + createVector(0, 0.5, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bruteFocusCFrame(cframe: CFrame)
	local v15 = cframe.Position + createVector(0, -1, 0)
	local v16 = cframe.Position + cframe.LookVector * 7 + cframe.RightVector * 2.5 + createVector(0, 1, 0)
	return CFrame.lookAt(v16, v15)
end

local function bruteSpawnCFrame()
	local v15 = v5
	local character

	if v15 then
		character = v15.Player.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local v16 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local unit

	if v16.Magnitude > 0.01 then
		unit = v16.Unit
	else
		unit = humanoidRootPart.CFrame.LookVector
	end

	local v17 = humanoidRootPart.Position - unit * 22
	return CFrame.lookAt(v17, v17 + unit)
end

local function behindPlayerCFrame(cframe: CFrame)
	local v15 = v5
	local character

	if v15 then
		character = v15.Player.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local v16 = cframe.Position - humanoidRootPart.Position
	local vector2 = Vector3.new(v16.X, 0, v16.Z)
	local v17

	if vector2.Magnitude > 0.01 then
		v17 = vector2.Unit
	else
		v17 = humanoidRootPart.CFrame.LookVector
	end

	local v18 = humanoidRootPart.Position - v17 * 12 + createVector(0, 4.5, 0)
	return CFrame.lookAt(v18, cframe.Position + createVector(0, 2, 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function distanceToChest()
	local v15 = v5
	local v16 = v6

	if not (v15 and v16) then
		return nil
	end

	local character = v15.Player.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return (humanoidRootPart.Position - v16.Position).Magnitude
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disarmTrigger()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	v13 = false
end

local function buildContestDialogue(object, flag2: boolean)
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
	local v15 = {
		controller = nil,
		cancelled = false
	}
	local v16 = DialogueController.new()
	v16:setTitle("...")
	return v16:addPage("Main", function(object2)
		local v17 = v6

		if v17 and not v15.controller then
			local controller = CameraController.new()
			v15.controller = controller
			v16:getMaid():GiveTask(function()
				v15.cancelled = true
				controller:FadeOut(0.6)
			end)
			controller.Animations:AnimateTo(chestRevealCFrame(v17), 1, 1.5)
		end

		object2:setTitle("...")
		object2:noCancel()
		object2:addText("The chest that cloud spat out is bound in diamond chains.")
		object2:addText("So this is where the Skylands money grows. Crack it open?")
		object2:addOptionType("Chat", function(object3)
			object3:setText("🔨 Smash Chains")
			object3:onSelected(function()
				v11 = true
				disarmTrigger() -- equivalent call inferred; original call site unknown
				object:FireServer("Provoke")
			end)
			object3:jumpTo(flag2 and "BruteBusy" or "Brute")
		end)
		object2:addOptionType("Leave", function(object3)
			object3:setText("❌ Sneak Out")
		end)
	end):addPage("Brute", function(object2)
		object2:setTitle("Strong Brute")
		object2:setSubtitle("Sky Bandit")
		object2:noCancel()
		local controller = v15.controller
		local v17 = bruteSpawnCFrame() or v7

		if controller and not v15.cancelled and v17 then
			local animations = controller.Animations
			local v18 = behindPlayerCFrame(v17)

			if not v18 then
				v18 = bruteFocusCFrame(v17)
			end

			animations:AnimateTo(v18, 1, 1.8)
		end

		object2:addText("Hey! We saw that first. That treasure is ours!")
		object2:addText("The clouds pay out for US, thief. Me and my boys trailed that one all morning.")
		object2:addText("The key stays on MY belt. Come and take it.")
		object2:onFinished(function()
			object:FireServer("BeginFight")
		end)
	end):addPage("BruteBusy", function(object2)
		object2:setTitle("...")
		object2:noCancel()
		object2:addText("The bandits who followed my chest down are still on their feet.")
		object2:addText("Their leader carries the key. Put him down and the treasure is mine.")
		object2:onFinished(function()
			object:FireServer("BeginFight")
		end)
	end):build()
end

local function startContest()
	local v15 = v5

	if not v15 or flag or v11 or v12 then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)

	if DialogueController.Active then
		return
	end

	v12 = true
	local success, result = pcall(function()
		return v15:InvokeServer("IsBruteActive") == true
	end)
	v12 = false

	if v5 ~= v15 or flag or v11 or DialogueController.Active then
		return
	end

	local contestDialogue = buildContestDialogue(v15, success and result == true)
	flag = true
	contestDialogue:getMaid():GiveTask(function()
		flag = false
	end)
	DialogueController.start(contestDialogue)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function armTrigger()
	if heartbeatConnection then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	v13 = false
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local v15 = distanceToChest() -- equivalent call inferred; original call site unknown

		if flag then
			if v15 == nil or v15 > 50 then
				DialogueController.close()
			end

			v13 = true
		else
			local v16

			if v15 == nil then
				v16 = false
			else
				v16 = v15 <= 35
			end

			if v16 and not v13 then
				startContest()
			end

			v13 = v16
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startChestRattle(model2)
	model2:SetAttribute("ClownJewelsRattling", true)
	task.spawn(function()
		while true do
			task.wait(2 + math.random() * 2)
			local primaryPart = model2.PrimaryPart

			if not model2.Parent or not primaryPart or model2:GetAttribute("ClownJewelsRattling") ~= true then
				break
			end

			pcall(function()
				Sound:Play(v[math.random(#v)], primaryPart.Position)
			end)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopChestRattle(model2)
	model2:SetAttribute("ClownJewelsRattling", false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeLockedChest()
	if model then
		model:Destroy()
		model = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnLockedChest(cframe: CFrame)
	removeLockedChest() -- equivalent call inferred; original call site unknown
	local chest = buildChest("ClownJewelsLockedChest", cframe)

	if chest then
		seatOnGround(chest.model, cframe.Position.Y) -- equivalent call inferred; original call site unknown
		model = chest.model
		startChestRattle(chest.model) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopEject()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if v10 then
		v10:Destroy()
		v10 = nil
	end
end

local function ejectCurve(position: Vector3, position2: Vector3)
	local vector2 = Vector3.new(position2.X - position.X, 0, position2.Z - position.Z)
	local magnitude = vector2.Magnitude
	local v15 = not (magnitude > 0.01) and createVector(1, 0, 0) or vector2.Unit
	local v16 = Vector3.new(-v15.Z, 0, v15.X) * ((math.random() - 0.5) * 2 * 22)
	return
		position + v15 * (magnitude * 0.5) + createVector(0, 60, 0) + v16,
		position2 + v15 * (magnitude * 0.5 * 0.5) + createVector(0, 26, 0) + v16 * 0.5
end

local function bezierPoint(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
	local v15 = 1 - p
	return vector2 * (v15 * v15 * v15) + vector3 * (v15 * 3 * v15 * p) + vector4 * (v15 * 3 * p * p) + vector5 * (p * p * p)
end

local function playChestEject(p, cframe: CFrame, position: Vector3)
	stopEject() -- equivalent call inferred; original call site unknown
	local chest = buildChest("ClownJewelsFlyingChest", CFrame.new(position))

	if chest then
		local model2 = chest.model

		for _, part in model2:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		v10 = model2
		local v15, v16 = ejectCurve(position, cframe.Position)
		local v17 = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 9
		local lastTime = os.clock()
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if v10 ~= model2 or not model2.Parent then
				return
			end

			local v18 = math.min((os.clock() - lastTime) / 2.1, 1)
			local position2 = cframe.Position
			local v22 = 1 - v18
			local v23 = position * (v22 * v22 * v22) + v15 * (v22 * 3 * v22 * v18) + v16 * (v22 * 3 * v18 * v18) + position2 * (v18 * v18 * v18)
			local cframe2 = CFrame.Angles(v17.X * v18, v17.Y * v18, v17.Z * v18)
			model2:PivotTo(CFrame.new(v23) * cframe2)

			if v18 < 1 then
				return
			end

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			v10 = nil
			model2:Destroy()
			local v24

			if v9 > 0 then
				v24 = v9 <= v8
			else
				v24 = false
			end

			if not v24 then
				spawnChest(p, cframe)
				return
			end

			spawnLockedChest(cframe) -- equivalent call inferred; original call site unknown
			armTrigger() -- equivalent call inferred; original call site unknown
		end)
	else
		local v15

		if v9 > 0 then
			v15 = v9 <= v8
		else
			v15 = false
		end

		if not v15 then
			spawnChest(p, cframe)
			return
		end

		spawnLockedChest(cframe) -- equivalent call inferred; original call site unknown
		armTrigger() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupChest()
	local v15 = v14

	if not v15 then
		return
	end

	v14 = nil

	if v15.conn then
		v15.conn:Disconnect()
	end

	v15.hitbox:Destroy()
	v15.model:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addFxAnchor(model2, name: string, cframe: CFrame)
	if model2:FindFirstChild(name) then
		return
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Size = createVector(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = cframe
	part.Parent = model2
end

local function openChest(object)
	local v15 = v14

	if not v15 then
		return
	end

	v14 = nil

	if v15.conn then
		v15.conn:Disconnect()
	end

	v15.hitbox:Destroy()
	object:FireServer("Collect")
	local model2 = v15.model
	stopChestRattle(model2) -- equivalent call inferred; original call site unknown
	pcall(function()
		Sound:Play(v2[math.random(#v2)], model2:GetPivot().Position)
	end)

	if v15.idleTrack then
		v15.idleTrack:Stop()
	end

	local animation = findAnimation(model2, v4)

	if v15.animator and animation then
		local track = v15.animator:LoadAnimation(animation)
		track.Looped = false
		track:Play()
		track.Stopped:Once(function()
			if not model2.Parent then
				return
			end

			track:Play()
			track:AdjustSpeed(0)
			track.TimePosition = math.max(track.Length - 0.05, 0)
		end)
	end

	local ac008 = model2:FindFirstChild("Ac.008")

	if ac008 and ac008:IsA("BasePart") then
		ac008.Transparency = 1
	end

	local v16

	if v9 > 0 then
		v16 = v9 <= v8
	else
		v16 = false
	end

	local animationController = model2:FindFirstChildOfClass("AnimationController")

	if animationController and not v16 then
		animationController.Name = "Controller"
	end

	local v17 = chestBase(model2) -- equivalent call inferred; original call site unknown
	addFxAnchor(model2, "BottomWood", CFrame.new(v17 + createVector(0, 3, 0))) -- equivalent call inferred; original call site unknown
	addFxAnchor(model2, "LootTexture", CFrame.new(v17 + createVector(0, 4, 0))) -- equivalent call inferred; original call site unknown
	pcall(function()
		Effect.new("Chests.Open"):play({
			ID = v16 and 3 or 2,
			Model = model2,
			Character = object.Player.Character
		})
	end)
	local primaryPart = model2.PrimaryPart
	task.delay(3, function()
		if primaryPart then
			pcall(function()
				Effect.new("Chests.Despawn"):play({
					CFrame = primaryPart.CFrame
				})
			end)
		end

		model2:Destroy()
	end)
end

spawnChest = function(p, cframe: CFrame)
	cleanupChest() -- equivalent call inferred; original call site unknown
	local chest = buildChest("ClownJewelsChest", cframe)

	if not chest then
		return
	end

	seatOnGround(chest.model, cframe.Position.Y) -- equivalent call inferred; original call site unknown
	startChestRattle(chest.model) -- equivalent call inferred; original call site unknown
	local part = Instance.new("Part")
	part.Name = "ClownJewelsChestHitbox"
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = true
	part.Size = createVector(8, 8, 8)
	part.CFrame = cframe + createVector(0, 4, 0)
	part.Parent = workspace
	local v15 = {
		model = chest.model,
		hitbox = part,
		conn = nil,
		animator = chest.animator,
		idleTrack = chest.idleTrack
	}
	v14 = v15
	v15.conn = part.Touched:Connect(function(otherPart)
		local character = p.Player.Character

		if character and otherPart:IsDescendantOf(character) then
			openChest(p)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideGuard(model2)
	model2:ClearAllChildren()
	model2.ChildAdded:Connect(function(child)
		task.defer(function()
			if child.Parent == model2 then
				child:Destroy()
			end
		end)
	end)
end

local onGuardTagged

onGuardTagged = function(model2)
	if not model2:IsA("Model") then
		return
	end

	local localEnemy = model2:GetAttribute("LocalEnemy")

	if localEnemy == nil then
		local localEnemyChangedConnection = nil
		localEnemyChangedConnection = model2:GetAttributeChangedSignal("LocalEnemy"):Connect(function()
			localEnemyChangedConnection:Disconnect()
			onGuardTagged(model2)
		end)
	elseif localEnemy ~= Players.LocalPlayer.Name then
		hideGuard(model2) -- equivalent call inferred; original call site unknown
	end
end

CollectionService:GetInstanceAddedSignal("ClownJewelsGuard"):Connect(onGuardTagged)

for _, v15 in CollectionService:GetTagged("ClownJewelsGuard") do
	onGuardTagged(v15)
end

local TheClownSJewels = {}
TheClownSJewels.DataName = script.Name

function TheClownSJewels.OnLoad(p)
	v5 = p
end

function TheClownSJewels.OnComplete(_, _, _)
	disarmTrigger() -- equivalent call inferred; original call site unknown
	stopEject() -- equivalent call inferred; original call site unknown
	removeLockedChest() -- equivalent call inferred; original call site unknown
	cleanupChest() -- equivalent call inferred; original call site unknown
	v11 = false
	flag = false
	v12 = false
	v5 = nil
	v6 = nil
	v7 = nil
	v8 = 0
	v9 = 0
end

TheClownSJewels.RemoteEvents = {
	Reset = function(_)
		v11 = false
		armTrigger() -- equivalent call inferred; original call site unknown
		v13 = true
	end,
	Setup = function(_)
		disarmTrigger() -- equivalent call inferred; original call site unknown
		stopEject() -- equivalent call inferred; original call site unknown
		removeLockedChest() -- equivalent call inferred; original call site unknown
		v6 = nil
		v7 = nil
	end,
	CloudStruck = function(p, position, p2, p3, value, value2)
		if typeof(p2) ~= "CFrame" then
			p2 = nil
		end

		v6 = p2

		if typeof(p3) ~= "CFrame" then
			p3 = nil
		end

		v7 = p3
		v8 = typeof(value) ~= "number" and 0 or value
		v9 = typeof(value2) ~= "number" and 0 or value2
		local v15 = v6

		if not v15 then
			return
		end

		disarmTrigger() -- equivalent call inferred; original call site unknown
		removeLockedChest() -- equivalent call inferred; original call site unknown
		cleanupChest() -- equivalent call inferred; original call site unknown
		v11 = false

		if typeof(position) ~= "Vector3" then
			position = v15.Position
		end

		playChestEject(p, v15, position)
	end,
	Restore = function(p, p2, p3, value, value2, p4)
		if typeof(p2) ~= "CFrame" then
			return
		end

		v6 = p2

		if typeof(p3) ~= "CFrame" then
			p3 = nil
		end

		v7 = p3
		v8 = typeof(value) ~= "number" and 0 or value
		v9 = typeof(value2) ~= "number" and 0 or value2
		disarmTrigger() -- equivalent call inferred; original call site unknown
		stopEject() -- equivalent call inferred; original call site unknown
		removeLockedChest() -- equivalent call inferred; original call site unknown
		cleanupChest() -- equivalent call inferred; original call site unknown
		v11 = false

		if p4 == true then
			spawnChest(p, p2)
			return
		end

		spawnLockedChest(p2) -- equivalent call inferred; original call site unknown
		armTrigger() -- equivalent call inferred; original call site unknown
	end,
	Poof = function(_, position)
		if typeof(position) ~= "Vector3" then
			return
		end

		pcall(function()
			Effect.new("Chests.Despawn"):play({
				CFrame = CFrame.new(position)
			})
		end)
		pcall(function()
			local Util = require(game.ReplicatedStorage.Util)
			Util.Sound:PlayUI("PodiumsComplete")
		end)
	end,
	ChestReady = function(p, cframe: CFrame)
		removeLockedChest() -- equivalent call inferred; original call site unknown
		spawnChest(p, cframe)
	end
}
return TheClownSJewels