local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.CAM.Global.RaycastHelper)
local ManuelCancel = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.ManuelCancel)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
local RideAnimator = require(script.Parent.RideAnimator)
local ServerClientPortal = require(ReplicatedStorage.CAM.Global.ServerClientPortal)
local horseModel = ReplicatedStorage.Assets:FindFirstChild("HorseModel")
local v = {}

local function equipCooldownLeft(p)
	return (math.max((v[p] or 0) - os.clock(), 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stampEquipCooldown(p)
	v[p] = os.clock() + gameSettings.horseEquipCooldown
end

Players.PlayerRemoving:Connect(function(player)
	v[player] = nil
end)
local animations = script.Parent:FindFirstChild("Animations")
local player = animations and animations:FindFirstChild("Player")
local horse = animations and animations:FindFirstChild("Horse")
local v2 = {
	Gallop = true,
	Sprint = true
}
local sounds = script:FindFirstChild("Sounds") or ReplicatedStorage.Effects.Misc.HorseEffects:FindFirstChild("Sounds")

if sounds == nil then
	warn("HorseServer: no Sounds folder found (checked HorseServer and Effects/Misc/HorseEffects) -- horse movement SFX disabled")
end

local v3 = {
	"PS2horseWALK",
	"PS2horseGALLOP",
	"PS2horseSPRINT",
	"PS2horseMOVEMENT"
}
local v4 = {
	Walk = {
		PS2horseWALK = true
	},
	Gallop = {
		PS2horseGALLOP = true,
		PS2horseMOVEMENT = true
	},
	Sprint = {
		PS2horseSPRINT = true,
		PS2horseMOVEMENT = true
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function playAnim(parent, animation)
	if parent == nil or animation == nil then
		return nil
	end

	local v5 = parent:FindFirstChildOfClass("Animator")

	if v5 == nil then
		v5 = Instance.new("Animator")
		v5.Parent = parent
	end

	local track = v5:LoadAnimation(animation)
	track:Play()
	return track
end

local function startRideAnimation(p, parent, clone)
	local humanoid = parent:FindFirstChildOfClass("Humanoid")
	local humanoid2 = clone:FindFirstChild("Humanoid")
	local v5 = RideAnimator.new({
		{
			animator = humanoid:FindFirstChildOfClass("Animator"),
			folder = player
		},
		{
			animator = humanoid2:FindFirstChildOfClass("Animator"),
			folder = horse
		}
	})
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fireHorseEffect(p2: string, flag: boolean?)
		if flag then
			EffectsEvent.ToAll("HorseEffects", parent, clone, p2)
			return
		end

		local v6

		if clone.Parent == nil then
			v6 = parent
		else
			v6 = humanoidRootPart or clone
		end

		EffectsEvent.ToAllInRange(v6, "HorseEffects", parent, clone, p2)
	end

	local function playHorseSound(childName: string, looped: boolean)
		if sounds == nil or humanoidRootPart == nil then
			return
		end

		local child = sounds:FindFirstChild(childName)

		if child == nil then
			return
		end

		local clone2 = child:Clone()
		clone2.Looped = looped
		clone2.Parent = humanoidRootPart
		clone2:Play()

		if not looped then
			Debris:AddItem(clone2, clone2.TimeLength > 0 and clone2.TimeLength or 3)
		end
	end

	local function reconcileLoops(p2: string)
		if humanoidRootPart == nil then
			return
		end

		local v6 = v4[p2] or {}

		for _, childName in v3 do
			local child = humanoidRootPart:FindFirstChild(childName)

			if v6[childName] then
				if child == nil and sounds ~= nil and humanoidRootPart ~= nil then
					local child2 = sounds:FindFirstChild(childName)

					if child2 ~= nil then
						local clone2 = child2:Clone()
						clone2.Looped = true
						clone2.Parent = humanoidRootPart
						clone2:Play()
					end
				end
			elseif child then
				child:Stop()
				child:Destroy()
			end
		end
	end

	local v6 = nil
	local v7 = nil
	local v8 = ServerClientPortal.Create(p, "HorseGait", -1)
	local now = 0
	local v9 = nil
	local v10 = nil
	local v11 = false
	local applyEffects

	applyEffects = function()
		local v12 = v9
		local v13 = v10

		if v12 ~= v6 or v13 ~= v7 then
			local v14 = 0.25 - (os.clock() - now)

			if v14 > 0 then
				if not v11 then
					v11 = true
					task.delay(v14, function()
						v11 = false

						if v8.__Active then
							applyEffects()
						end
					end)
				end

				return
			else
				now = os.clock()
			end
		end

		if v12 ~= v6 then
			local v14

			if v2[v6] == true then
				v14 = v2[v12] ~= true
			else
				v14 = false
			end

			v6 = v12

			if v14 then
				fireHorseEffect(v12, true) -- equivalent call inferred; original call site unknown
			else
				local v15

				if clone.Parent == nil then
					v15 = parent
				else
					v15 = humanoidRootPart or clone
				end

				EffectsEvent.ToAllInRange(v15, "HorseEffects", parent, clone, v12)
			end

			reconcileLoops(v12)
		end

		if humanoid.Health > 0 then
			if v13 == "Gallop" and v7 ~= "Gallop" then
				playHorseSound("PS2horseKICKOFFweak", false)
			elseif v13 == "Sprint" and v7 ~= "Sprint" then
				local v14

				if clone.Parent == nil then
					v14 = parent
				else
					v14 = humanoidRootPart or clone
				end

				EffectsEvent.ToAllInRange(v14, "HorseEffects", parent, clone, "SprintActivated")
				playHorseSound("PS2horseKICKOFFstrong", false)
			end
		end

		v7 = v13
	end

	v8:Connect(function(flag: boolean, p2: string, flag2: boolean)
		if humanoid.Health <= 0 then
			flag = false
		end

		v5:SetFalling(flag2)
		v5:Update(flag, p2)
		v9 = (not flag or flag2) and "Idle" or p2
		v10 = p2
		applyEffects()
	end)
	local flag = false

	local function stop()
		if flag then
			return
		end

		flag = true
		fireHorseEffect("Idle", true) -- equivalent call inferred; original call site unknown
		reconcileLoops("Idle")
		v8:Destroy()
		v5:Destroy()
	end

	clone.Destroying:Connect(stop)
	return stop
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restorePlayerNetwork(p, instance)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and p.Parent ~= nil and humanoidRootPart:CanSetNetworkOwnership() then
		humanoidRootPart:SetNetworkOwner(p)
	end
end

local function addFreeze(state, getvaluesfolder, parent, p: number)
	state.Freeze = {
		Utility.AddValue(getvaluesfolder, "skill_stand_still"),
		Utility.AddValue(getvaluesfolder, "pause_gameplay"),
		Utility.AddValue(getvaluesfolder, "NR"),
		Utility.AddValue(getvaluesfolder, "NOMouvementlines"),
		Utility.AddValue(getvaluesfolder, "hip_height", nil, "NumberValue", p)
	}
	local head = parent and parent:FindFirstChild("Head")

	if head then
		table.insert(state.Freeze, Utility.AddValue(getvaluesfolder, "camsubject", nil, "ObjectValue", head))
	end

	parent:SetAttribute("OnHorse", true)
end

local function removeFreeze(freeze)
	if freeze == nil then
		return
	end

	for _, item in freeze do
		if item.Name == "NOMouvementlines" then
			local v5 = item
			task.delay(0.1, function()
				v5:Destroy()
			end)
		else
			item:Destroy()
		end
	end
end

local function groundParams(parent)
	local humanoids = { parent, workspace.Debree }
	local humanoids2 = workspace:FindFirstChild("Humanoids")

	if humanoids2 then
		table.insert(humanoids, humanoids2)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = humanoids
	return raycastParams
end

local function placeHorse(clone, humanoidRootPart, humanoidRootPart2, p)
	local cFrame = humanoidRootPart2.CFrame
	local position = gameSettings.horseRidingPlayerOffset.Position
	local position2 = (cFrame * CFrame.new(-position.X, 0, -position.Z)).Position
	local raycastResult = workspace:Raycast(position2 + createVector(0, 5, 0), createVector(0, -60, 0), p)
	local v5 = humanoidRootPart2.Position.Y - 3

	if raycastResult then
		v5 = math.max(raycastResult.Position.Y, v5)
	end

	local hipheight = clone:GetAttribute("hipheight")

	if hipheight == nil then
		local boundingBox, v6 = clone:GetBoundingBox()
		hipheight = humanoidRootPart.Position.Y - (boundingBox.Position.Y - v6.Y / 2)
		warn("Horse: HorseModel has no hipheight attribute; falling back to the stored-pose bounding box (likely wrong -- author the attribute)")
	end

	clone:SetAttribute("RestHeight", hipheight)
	clone.PrimaryPart = humanoidRootPart
	local vector2 = Vector3.new(position2.X, v5 + hipheight, position2.Z)
	clone:PivotTo(CFrame.lookAt(vector2, vector2 + cFrame.LookVector))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeHorse(folder)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.Anchored = true
	end

	task.spawn(function()
		local tweenInfo = TweenInfo.new(0.35)

		for _, descendant in folder:GetDescendants() do
			if not ((descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) and descendant.Transparency < 1) then
				continue
			end

			TweenService:Create(descendant, tweenInfo, {
				Transparency = 1
			}):Play()
		end

		task.wait(0.35)
		folder:Destroy()
	end)
end

local function forceCleanup(p, instance, state, flag: boolean?)
	if state.CancelDestroy then
		state.CancelDestroy()
		state.CancelDestroy = nil
	end

	if state.SwimWatch then
		state.SwimWatch:Disconnect()
		state.SwimWatch = nil
	end

	if state.StopRideAnim then
		state.StopRideAnim()
		state.StopRideAnim = nil
	end

	if state.RidingHorse then
		state.RidingHorse:Destroy()
		state.RidingHorse = nil
	end

	if state.GetOnTrack then
		state.GetOnTrack:Stop()
		state.GetOnTrack = nil
	end

	if state.Weld then
		state.Weld:Destroy()
		state.Weld = nil
	end

	restorePlayerNetwork(p, instance) -- equivalent call inferred; original call site unknown
	removeFreeze(state.Freeze)
	state.Freeze = nil
	instance:SetAttribute("OnHorse", nil)
	local horse2 = state.Horse
	state.Horse = nil
	state.HorseRoot = nil
	state.Sequencing = false

	if horse2 then
		if flag then
			horse2:Destroy()
			return
		end

		fadeHorse(horse2) -- equivalent call inferred; original call site unknown
	end
end

local function mount(p, parent, state)
	if state.Horse ~= nil or state.Sequencing or horseModel == nil then
		return
	end

	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or humanoid == nil then
		return
	end

	local clone = horseModel:Clone()
	local humanoidRootPart2 = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart2 == nil then
		clone:Destroy()
		return
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v5 = vector2.Magnitude < 0.0001 and createVector(0, 0, -1) or vector2
	humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + v5.Unit)
	local v6 = groundParams(parent)
	local raycastResult = workspace:Raycast(
		humanoidRootPart.Position + createVector(0, 5, 0),
		createVector(0, -60, 0),
		v6
	)
	local lookVector2 = humanoidRootPart.CFrame.LookVector
	local vector3 = Vector3.new(lookVector2.X, 0, lookVector2.Z)
	local v7 = vector3.Magnitude < 0.001 and createVector(-0, -0, -1) or vector3
	local position = humanoidRootPart.Position

	if raycastResult then
		position = Vector3.new(position.X, math.max(raycastResult.Position.Y + 3, position.Y), position.Z)
	end

	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.CFrame = CFrame.lookAt(position, position + v7.Unit)
	clone.Parent = parent
	placeHorse(clone, humanoidRootPart2, humanoidRootPart, v6)
	humanoidRootPart2.Anchored = true
	state.StopRideAnim = startRideAnimation(p, parent, clone)
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart2
	weld.Part1 = humanoidRootPart
	weld.C0 = gameSettings.horseRidingPlayerOffset
	weld.Parent = humanoidRootPart2
	humanoidRootPart.CFrame = humanoidRootPart2.CFrame * weld.C0
	local getvaluesfolder = Utility.getvaluesfolder(parent)
	state.Horse = clone
	state.HorseRoot = humanoidRootPart2
	state.Weld = weld
	state.Sequencing = true
	local v8 = math.max(
		(clone:GetAttribute("RestHeight") or 0) + gameSettings.horseRidingPlayerOffset.Position.Y - humanoidRootPart.Size.Y / 2,
		1.35
	)

	if getvaluesfolder then
		addFreeze(state, getvaluesfolder, parent, v8)
	end

	local function bail()
		forceCleanup(p, parent, state, true)

		if humanoid.Health <= 0 then
			return
		end

		SignalEvent.ToClient(p, "ForceEquip", 0)
	end

	local v9, cancelDestroy = ManuelCancel.new(p, -1)
	state.CancelDestroy = cancelDestroy

	if v9 then
		v9:Connect(bail)
	end

	state.SwimWatch = parent:GetAttributeChangedSignal("SwimState"):Connect(function()
		if (parent:GetAttribute("SwimState") or 0) > 0 then
			forceCleanup(p, parent, state, true)

			if humanoid.Health <= 0 then
				return
			else
				SignalEvent.ToClient(p, "ForceEquip", 0)
			end
		end
	end)
	task.spawn(function()
		local v11 = state
		local getOnTrack = playAnim(humanoid, script:FindFirstChild("PlayerGetOn")) -- equivalent call inferred; original call site unknown
		v11.GetOnTrack = getOnTrack
		task.wait(1)

		if state.Horse ~= clone then
			return
		end

		humanoidRootPart2.Anchored = false
		humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		task.spawn(function()
			while state.Horse == clone and clone.Parent ~= nil do
				if humanoidRootPart2:CanSetNetworkOwnership() then
					humanoidRootPart2:SetNetworkOwner(p)
					break
				else
					task.wait(0.1)
				end
			end
		end)

		if getvaluesfolder then
			state.RidingHorse = Utility.AddValue(getvaluesfolder, "RidingHorse", nil, "ObjectValue", clone)
		end

		state.Sequencing = false
	end)
end

local function dismount(p, instance, state)
	if state.Horse == nil then
		return
	end

	local horse2 = state.Horse
	local horseRoot = state.HorseRoot
	local weld = state.Weld
	local ridingHorse = state.RidingHorse
	local freeze = state.Freeze
	local getOnTrack = state.GetOnTrack
	local stopRideAnim = state.StopRideAnim

	if state.CancelDestroy then
		state.CancelDestroy()
		state.CancelDestroy = nil
	end

	if state.SwimWatch then
		state.SwimWatch:Disconnect()
		state.SwimWatch = nil
	end

	state.StopRideAnim = nil
	state.Horse = nil
	state.HorseRoot = nil
	state.Weld = nil
	state.RidingHorse = nil
	state.Freeze = nil
	state.GetOnTrack = nil
	state.Sequencing = false

	if ridingHorse then
		ridingHorse:Destroy()
	end

	if getOnTrack then
		getOnTrack:Stop()
	end

	horseRoot.Anchored = true

	for _, v5 in freeze do
		if v5.Name == "hip_height" then
			v5:Destroy()
		end
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	task.spawn(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local flag = false

		local function release()
			if flag then
				return
			end

			flag = true

			if humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.Anchored = false
			end

			pcall(restorePlayerNetwork, p, instance)

			for _, v5 in freeze do
				if v5 ~= nil then
					v5:Destroy()
				end
			end

			if instance ~= nil then
				instance:SetAttribute("OnHorse", nil)
			end

			fadeHorse(horse2) -- equivalent call inferred; original call site unknown
		end

		local success, result = pcall(function()
			local track = playAnim(humanoid, script:FindFirstChild("PlayerGetOff")) -- equivalent call inferred; original call site unknown

			if stopRideAnim then
				stopRideAnim()
			end

			weld:Destroy()

			if humanoidRootPart then
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.Anchored = true
			end

			task.wait(0.5)

			if humanoidRootPart then
				humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
				humanoidRootPart.Anchored = false
			end

			restorePlayerNetwork(p, instance) -- equivalent call inferred; original call site unknown
			task.wait(0.833)

			if track then
				track:Stop()
			end
		end)

		if not success then
			warn("[Horse] dismount choreography failed, releasing rider anyway:", result)
		end

		release()
	end)
end

local HorseServer = {}

function HorseServer.check(p, _, _, _: string)
	if not Checker.check(p) then
		return false
	end

	return not (math.max((v[p] or 0) - os.clock(), 0) > 0) and not InCombat.biasedCheck(p)
end

function HorseServer.Equipped(p, parent, p3, _: string)
	mount(p, parent, p3)
end

function HorseServer.UnEquipped(p, instance, p2, _: string)
	if p2.Horse == nil then
		return
	end

	stampEquipCooldown(p) -- equivalent call inferred; original call site unknown
	local humanoid = instance and instance:FindFirstChildOfClass("Humanoid")
	local v5

	if humanoid == nil or not (humanoid.Health > 0) then
		v5 = false
	else
		v5 = instance.Parent ~= nil
	end

	if p2.Sequencing or not v5 then
		forceCleanup(p, instance, p2, not v5)
	else
		dismount(p, instance, p2)
	end
end

function HorseServer.MouseDown(_, _, _, _: string) end

function HorseServer.MouseUp(_, _, _, _: string) end

return HorseServer