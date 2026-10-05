local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
local camerashaker = require(ReplicatedStorage.Packages.camerashaker)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local remo = require(ReplicatedStorage.Packages.remo)
local Icon = require(ReplicatedStorage.TopbarPlus.Icon)
local ZoneSystem = require(ReplicatedStorage.ZoneSystem)
local Common = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.Common)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local VFXUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.VFXUtils)
local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local v = {
	[3845375404] = "Scrt_Loki",
	[9625900006] = "Scrt_Loki",
	[10580349267] = "DOT_Pinpin",
	[175193570] = "LuckyMatg",
	[18298071] = "chichine",
	[52368542] = "Fabuss254",
	[3080402841] = "0V3RDRIVE_Dev",
	[162206312] = "homemade_sano",
	[109517370] = "ev1",
	[1445966223] = "Leorizoto",
	[5696625488] = "TLT_Rust",
	[4844587819] = "TLT_Rust",
	[1542855761] = "Dak"
}
local StaffTreadmill = {
	TREADMILL_SPEED_MULT = 30,
	TREADMILL_TAG = "StaffTreadmill"
}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = nil
StaffTreadmill.remotes = remo.createRemotes({
	toggleTreadmillEnabled = remo.remote(),
	updateTreadmillEnabled = remo.remote()
})

function isPlayerWhitelist(p)
	return v[p.UserId] ~= nil
end

function getPlayerTreadmillSkinName(p)
	return v[p.UserId]
end

function getCameraShaker()
	assert(RunService:IsClient(), "Camera Shaker is only accessible on client")

	if not v5 then
		v5 = camerashaker.new(Enum.RenderPriority.Camera.Value + 1, function(cframe2: CFrame)
			local currentCamera = Workspace.CurrentCamera

			if currentCamera then
				currentCamera.CFrame *= cframe2
			end
		end)
		v5:Start()
	end

	return v5
end

function getFactorBasedOnCameraDistance(vector2: Vector3, p: number, p2: number)
	return 1 - math.clamp(((vector2 - Workspace.CurrentCamera.CFrame.Position).Magnitude - p) / (p2 - p), 0, 1)
end

function getStaffTreadmillFolder()
	local staffTreadmills = ServerStorage:FindFirstChild("StaffTreadmills")
	assert(staffTreadmills, "Couldn't find the Staff Treadmill Folder.")
	return staffTreadmills
end

function setModelUncollideable(object, flag: boolean)
	for _, v6 in object:QueryDescendants("BasePart") do
		local savedCollideable = v6:GetAttribute("savedCollideable")

		if savedCollideable == nil then
			savedCollideable = v6.CanCollide
			v6:SetAttribute("savedCollideable", savedCollideable)
		end

		if flag then
			savedCollideable = false
		end

		v6.CanCollide = savedCollideable
	end
end

function getBoundingBox(instance)
	assert(instance:IsDescendantOf(getStaffTreadmillFolder()), "tried to get bounding size of a unrecognized model")

	if v3[instance] then
		return v3[instance][1], v3[instance][2]
	end

	local boundingBox, v6 = instance:GetBoundingBox()
	v3[instance] = { boundingBox, v6 }
	return boundingBox, v6
end

function initializeUI()
	local v6 = assert(Players.LocalPlayer, "StaffTreadmill UI requires a local player")

	if not isPlayerWhitelist(v6) then
		return
	end

	assert(Icon, "TopbarPlus is only available on the client").new():setName("StaffTreadmill"):setLabel("Staff Treadmill"):setImage("rbxassetid://132779544877241"):oneClick().selected:Connect(function()
		StaffTreadmill.remotes.toggleTreadmillEnabled:fire()
	end)
end

function getAllPlayersCharacters()
	local characters = {}

	for _, v6 in Players:GetPlayers() do
		if v6.Character then
			table.insert(characters, v6.Character)
		end
	end

	return characters
end

function getOriginalTreadmillModel(childName: string)
	local staffTreadmills = ServerStorage:FindFirstChild("StaffTreadmills")
	assert(staffTreadmills, "Couldn't find the Staff Treadmill Folder.")
	local selected = staffTreadmills:FindFirstChild(childName) or staffTreadmills:FindFirstChild("Default")
	assert(selected, "Couldn't find a staff treadmill inside the staff treadmill folder.")
	return selected
end

function getCharacterCFrame(player, p)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return false, "No character found"
	end

	local _, v6 = getBoundingBox(p)
	local raycastParams = RaycastParams.new()
	raycastParams.ExcludeInstances = {
		game.Workspace:FindFirstChild("Keycaps"),
		table.unpack(getAllPlayersCharacters())
	}
	local v7 = humanoidRootPart.CFrame * CFrame.new(0, 5, -(v6.Z / 2 + 5))
	local raycastResult = Workspace:Raycast(v7.Position, createVector(-0, -10, -0), raycastParams)

	if not raycastResult then
		return false, "No floor found"
	end

	local cframe2 = CFrame.lookAlong(raycastResult.Position, v7.LookVector * createVector(1, 0, 1))

	if not ZoneSystem.GetZoneAt(cframe2, ZoneSystem.GetSafeZones()) then
		return false, "Not in safezone"
	end

	if isCFrameSafe(cframe2, v6 + v6.Y * createVector(0, 1, 0) * 0.5) then
		return true, cframe2 * cframe
	end

	return false, "Spawn position obstructed"
end

function isCFrameSafe(_: CFrame, _: Vector3)
	return true
end

function spawnTreadmill(instance, cframe2: CFrame)
	local treadmill = Workspace:FindFirstChild("Treadmill")
	assert(treadmill, "No treadmill folder found in workspace")
	local clone = instance:Clone()
	clone.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	clone:AddTag("StaffTreadmill_Add")
	local boundingBox, v6 = getBoundingBox(instance)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Name = "Root"
	part.CFrame = boundingBox - createVector(0, 1, 0) * v6.Y * 0.5
	part.Parent = clone
	clone.PrimaryPart = part
	local vFXRoot = getStaffTreadmillFolder():FindFirstChild("VFXRoot")

	if vFXRoot then
		local clone_2 = vFXRoot:Clone()
		clone_2.Parent = part
	end

	local potentialInstance = InstanceUtils.getPotentialInstance(clone, "TreadmillBillboard/Frame/TextLabel")

	if potentialInstance then
		potentialInstance.Text = `x{StaffTreadmill.TREADMILL_SPEED_MULT} SPEED`
	end

	local conveyor = clone:FindFirstChild("Conveyor")

	if conveyor and not conveyor:HasTag(StaffTreadmill.TREADMILL_TAG) then
		for _, tag in conveyor:GetTags() do
			conveyor:RemoveTag(tag)
		end

		conveyor:AddTag(StaffTreadmill.TREADMILL_TAG)
	end

	clone:PivotTo(cframe2)
	clone.Parent = treadmill
	return clone
end

function spawnTreadmillFX(instance)
	assert(RunService:IsClient(), "Should NEVER play FX function on server")
	setModelUncollideable(instance, true)
	local vFXRoot = instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("VFXRoot")

	local function playVFX(childName: string)
		if not vFXRoot then
			return
		end

		local child = vFXRoot:FindFirstChild(childName)

		if child then
			VFXUtils.emitAttachment(child)
		end
	end

	local function playSound(childName: string)
		if not vFXRoot then
			return
		end

		local child = vFXRoot:FindFirstChild(childName)

		if child then
			child.PlaybackSpeed += Common.GetRandom():NextNumber(-0.1, 0.1)
			child:Play()
		end
	end

	local pivot = instance:GetPivot()
	local scale = instance:GetScale()
	local cFrameValue = nil
	local numberValue = nil
	local numberValue2 = nil

	local function update()
		instance:ScaleTo(numberValue.Value)
		instance:PivotTo(cFrameValue.Value * CFrame.Angles(0, numberValue2.Value, 0))
	end

	cFrameValue = Instance.new("CFrameValue")
	Debris:AddItem(cFrameValue, 2)
	cFrameValue.Value = pivot + createVector(0, 10, 0)
	cFrameValue.Changed:Connect(update)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0.1),
		{
			Value = pivot
		}
	)
	tween:Play()
	numberValue2 = Instance.new("NumberValue")
	Debris:AddItem(numberValue2, 2)
	numberValue2.Value = -9.42477796076938
	numberValue2.Changed:Connect(update)
	TweenService:Create(
		numberValue2,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0),
		{
			Value = 0
		}
	):Play()
	numberValue = Instance.new("NumberValue")
	Debris:AddItem(numberValue, 2)
	numberValue.Value = 0.2
	numberValue.Changed:Connect(update)
	TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0), {
		Value = scale
	}):Play()
	tween.Completed:Connect(function()
		local factorBasedOnCameraDistance = getFactorBasedOnCameraDistance(pivot.Position, 30, 70)

		if factorBasedOnCameraDistance > 0 then
			getCameraShaker():ShakeOnce(factorBasedOnCameraDistance * 2, 8, 0.05, 0.5, 0, 1)
		end

		local land = vFXRoot and vFXRoot:FindFirstChild("Land")

		if land then
			VFXUtils.emitAttachment(land)
		end

		local landsfx = vFXRoot and vFXRoot:FindFirstChild("landsfx")

		if landsfx then
			landsfx.PlaybackSpeed += Common.GetRandom():NextNumber(-0.1, 0.1)
			landsfx:Play()
		end

		setModelUncollideable(instance, false)
	end)
	instance:ScaleTo(numberValue.Value)
	instance:PivotTo(cFrameValue.Value * CFrame.Angles(0, numberValue2.Value, 0))
	local spin = vFXRoot and vFXRoot:FindFirstChild("Spin")

	if spin then
		VFXUtils.emitAttachment(spin)
	end

	local woosh = vFXRoot and vFXRoot:FindFirstChild("woosh")

	if woosh then
		woosh.PlaybackSpeed += Common.GetRandom():NextNumber(-0.1, 0.1)
		woosh:Play()
	end
end

function despawnTreadmillFX(instance)
	assert(RunService:IsClient(), "Should NEVER play FX function on server")
	setModelUncollideable(instance, true)
	local vFXRoot = instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("VFXRoot")

	local function playVFX(childName: string)
		if not vFXRoot then
			return
		end

		local child = vFXRoot:FindFirstChild(childName)

		if child then
			VFXUtils.emitAttachment(child)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playSound(childName: string)
		if not vFXRoot then
			return
		end

		local child = vFXRoot:FindFirstChild(childName)

		if child then
			child.PlaybackSpeed += Common.GetRandom():NextNumber(-0.1, 0.1)
			child:Play()
		end
	end

	local pivot = instance:GetPivot()
	local scale = instance:GetScale()
	local cFrameValue = nil
	local numberValue = nil
	local numberValue2 = nil

	local function update()
		instance:ScaleTo(numberValue.Value)
		instance:PivotTo(cFrameValue.Value * CFrame.Angles(0, numberValue2.Value, 0))
	end

	cFrameValue = Instance.new("CFrameValue")
	Debris:AddItem(cFrameValue, 2)
	cFrameValue.Value = pivot
	cFrameValue.Changed:Connect(update)
	TweenService:Create(cFrameValue, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Value = pivot + createVector(0, 10, 0)
	}):Play()
	numberValue2 = Instance.new("NumberValue")
	Debris:AddItem(numberValue2, 2)
	numberValue2.Changed:Connect(update)
	TweenService:Create(
		numberValue2,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In, 0, false, 0.1),
		{
			Value = 9.42477796076938
		}
	):Play()
	numberValue = Instance.new("NumberValue")
	Debris:AddItem(numberValue, 2)
	numberValue.Value = scale
	numberValue.Changed:Connect(update)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false, 0.1),
		{
			Value = 0.2
		}
	)
	tween.Completed:Connect(function()
		instance:Destroy()
	end)
	tween:Play()
	local factorBasedOnCameraDistance = getFactorBasedOnCameraDistance(pivot.Position, 30, 70)

	if factorBasedOnCameraDistance > 0 then
		getCameraShaker():ShakeOnce(factorBasedOnCameraDistance * 3, 8, 0.05, 0.25, 0, 1)
	end

	local land = vFXRoot and vFXRoot:FindFirstChild("Land")

	if land then
		VFXUtils.emitAttachment(land)
	end

	local lift = vFXRoot and vFXRoot:FindFirstChild("lift")

	if lift then
		lift.PlaybackSpeed += Common.GetRandom():NextNumber(-0.1, 0.1)
		lift:Play()
	end

	task.delay(0.3, function()
		local spin2 = vFXRoot and vFXRoot:FindFirstChild("Spin2")

		if spin2 then
			VFXUtils.emitAttachment(spin2)
		end

		playSound("woosh") -- equivalent call inferred; original call site unknown
	end)
end

function StaffTreadmill.setTreadmillEnabled(p, flag: boolean, p2: string?)
	assert(RunService:IsServer(), "setTreadmillEnabled is not clientsided")

	if not (isPlayerWhitelist(p) and StaffTreadmill.isTreadmillEnabled(p) ~= flag) then
		return
	end

	if flag then
		local originalTreadmillModel = getOriginalTreadmillModel(p2 or getPlayerTreadmillSkinName(p))
		local characterCFrame, v6 = getCharacterCFrame(p, originalTreadmillModel)

		if not characterCFrame then
			NotificationSystem:ShowGeneralNotificationForPlayer(
				p,
				`Couldn't spawn treadmill: {v6}`,
				Color3.new(1, 0.5, 0.5),
				4
			)
			return
		end

		v2[p] = spawnTreadmill(originalTreadmillModel, v6)
		NotificationSystem:ShowGeneralNotificationForPlayer(p, "Staff treadmill spawned!", Color3.new(0.5, 1, 0.5), 4)
	else
		StaffTreadmill.remotes.updateTreadmillEnabled:fireAll(v2[p], false)
		Debris:AddItem(v2[p], 1)
		v2[p] = nil
		NotificationSystem:ShowGeneralNotificationForPlayer(p, "Staff treadmill despawned!", Color3.new(0.5, 1, 0.5), 4)
	end
end

function StaffTreadmill.isTreadmillEnabled(p)
	assert(RunService:IsServer(), "isTreadmillEnabled is not clientsided")

	if v2[p] then
		return true
	end

	return false
end

function StaffTreadmill.getTreadmillForPlayer(p)
	assert(RunService:IsServer(), "getTreadmillForPlayer is not clientsided")
	return v2[p]
end

FeatureManager.RegisterFeature(script.Name, {
	OnUIInit = initializeUI,
	OnInit = function()
		if RunService:IsServer() then
			StaffTreadmill.remotes.toggleTreadmillEnabled:connect(function(p)
				if os.clock() - (v4[p] or 0) < 1 then
					NotificationSystem:ShowGeneralNotificationForPlayer(p, "On cooldown", Color3.new(1, 0.5, 0.5), 4)
					return
				end

				v4[p] = os.clock()
				StaffTreadmill.setTreadmillEnabled(p, not StaffTreadmill.isTreadmillEnabled(p))
			end)
			Players.PlayerRemoving:Connect(function(player)
				StaffTreadmill.setTreadmillEnabled(player, false)
				v4[player] = nil
			end)
		else
			StaffTreadmill.remotes.updateTreadmillEnabled:connect(function(p, p2)
				if p2 then
					spawnTreadmillFX(p)
				else
					despawnTreadmillFX(p)
				end
			end)
			CollectionService:GetInstanceAddedSignal("StaffTreadmill_Add"):Connect(function(model)
				if model:IsA("Model") and model:IsDescendantOf(Workspace) then
					spawnTreadmillFX(model)
				end
			end)
		end
	end
})
return StaffTreadmill