local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Checker = require(ReplicatedStorage.CAM.Global.Checker)
local Allegiance = require(ReplicatedStorage.CAM.Global.Allegiance)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
local SequenceTeleport = require(ReplicatedStorage.CAM.Client.Modules.SequenceTeleport)
local PlayerProfile = require(ReplicatedStorage.CAM.Global.PlayerProfile)
local CameraInput = require(script.Parent.Parent.PlayerModule.CameraModule.CameraInput)

if type(CameraInput.addRotation) ~= "function" then
	warn("[AimAssist] the running PlayerModule is not the game's own (no CameraInput.addRotation): aim assist off. Is PlayerModule under StarterPlayerScripts in this place?")
	return
end

local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local humanoids = workspace:FindFirstChild("Humanoids")
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function config()
	return gameSettings.AimAssist
end

local v = DataValue.new(SettingsKeys.AimAssist.Path, SettingsKeys.AimAssist.Default, SettingsKeys.Scope)
local v2 = DataValue.new(SettingsKeys.AimAssistCombat.Path, SettingsKeys.AimAssistCombat.Default, SettingsKeys.Scope)

local function platformStrength()
	local platformStrength2 = gameSettings.AimAssist.PlatformStrength
	local v3 = Platform_Handler.IsGamepad() and "Console" or Platform_Handler.Platform.Value
	local v4

	if platformStrength2 ~= nil then
		v4 = tonumber(platformStrength2[v3])
	end

	if v4 == nil then
		return 1
	end

	return (math.max(v4, 0))
end

local function platformRadius()
	local platformRadius2 = gameSettings.AimAssist.PlatformRadius
	local v3 = Platform_Handler.IsGamepad() and "Console" or Platform_Handler.Platform.Value
	local v4

	if platformRadius2 ~= nil then
		v4 = tonumber(platformRadius2[v3])
	end

	if v4 == nil then
		return 1
	end

	return (math.max(v4, 0))
end

local function userStrength()
	local regularIncludeAI = InCombat.RegularIncludeAI(localPlayer.Character)
	local v3

	if regularIncludeAI then
		v3 = v2
	else
		v3 = v
	end

	local default

	if regularIncludeAI then
		default = SettingsKeys.AimAssistCombat.Default
	else
		default = SettingsKeys.AimAssist.Default
	end

	local v4 = tonumber(v3:Get())

	if v4 ~= nil then
		default = math.clamp(v4, 0, 1)
	end

	local platformStrength2 = gameSettings.AimAssist.PlatformStrength
	local v5 = Platform_Handler.IsGamepad() and "Console" or Platform_Handler.Platform.Value
	local v6

	if platformStrength2 ~= nil then
		v6 = tonumber(platformStrength2[v5])
	end

	return default * (v6 == nil and 1 or math.max(v6, 0))
end

local v3 = {}
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function Added(model)
	if model:IsA("Model") then
		v3[model] = true
	end
end

local function Removed(p)
	v3[p] = nil

	if v4 == p then
		v4 = nil
	end
end

local v5 = 0
local v6 = 0
local v7 = nil

for _, v8 in CollectionService:GetTagged("Humanoids") do
	Added(v8) -- equivalent call inferred; original call site unknown
end

local connection = CollectionService:GetInstanceAddedSignal("Humanoids"):Connect(Added)
local connection2 = CollectionService:GetInstanceRemovedSignal("Humanoids"):Connect(Removed)
local heartbeatConnection = nil
local v8 = true

local function shutdown(p: string)
	if not v8 then
		return
	end

	v8 = false
	v4 = nil
	Platform_Handler.SetAimLock(false)

	if heartbeatConnection ~= nil then
		heartbeatConnection:Disconnect()
	end

	RunService:UnbindFromRenderStep("AimAssist")
	connection:Disconnect()
	connection2:Disconnect()
	warn((`[AimAssist] {p} errored (the error above); the aim assist is off until the next join`))
end

local v9 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshPlatform()
	v9 = Platform_Handler.Platform.Value == "Mobile" or Platform_Handler.IsGamepad()
end

refreshPlatform() -- equivalent call inferred; original call site unknown
Platform_Handler.Platform.Changed.Event:Connect(refreshPlatform)
local v10 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshTool()
	local get_equipped_tool = Character_info_provider.Get_equipped_tool(localPlayer)
	v10 = get_equipped_tool ~= nil and gameSettings.AimAssist.DisabledForTools[get_equipped_tool.Name] == true
end

task.spawn(function()
	local items_Config = localPlayer:WaitForChild("Items_Config", 60)
	local equipped

	if items_Config ~= nil then
		equipped = items_Config:WaitForChild("Equipped", 60)
	end

	if equipped == nil then
		return
	end

	equipped.Changed:Connect(refreshTool)
	refreshTool() -- equivalent call inferred; original call site unknown
end)

local function assistAllowed()
	if gameSettings.AimAssist.Enabled ~= true or not v9 or userStrength() <= 0 or Camera_Traffic_Handler.Equipped_Hirearchy ~= "" then
		return nil
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil or currentCamera.CameraType == Enum.CameraType.Scriptable or HUD.Value ~= true or localPlayer:GetAttribute("Spectating") == true then
		return nil
	end

	if SequenceTeleport.IsActive() or localPlayer:GetAttribute("LoadingScreen") == true or v10 then
		return nil
	end

	local character = localPlayer.Character

	if character == nil or character.Parent == nil then
		return nil
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoidRootPart == nil or humanoid == nil or humanoid.Health <= 0 then
		return nil
	end

	return character, humanoidRootPart, humanoid
end

local function toScreen(object, vector2: Vector3)
	local worldToViewportPoint, v11 = object:WorldToViewportPoint(vector2)
	local guiInset = GuiService:GetGuiInset()
	return
		Vector2.new(worldToViewportPoint.X - guiInset.X, worldToViewportPoint.Y - guiInset.Y),
		v11 and worldToViewportPoint.Z > 0
end

local function tradingWith(p)
	local aimAssist = config() -- equivalent call inferred; original call site unknown
	local getvaluesfolder = Utility.getvaluesfolder(p)
	local DMG

	if getvaluesfolder ~= nil then
		DMG = getvaluesfolder:FindFirstChild("DMG")
	end

	if DMG == nil then
		return nil
	end

	local v12 = Utility.Tick()
	local lastAttacked = tonumber(DMG:GetAttribute("LastAttacked")) or 0
	local lastEngaged = tonumber(DMG:GetAttribute("LastEngaged")) or 0
	local lastAttackerId

	if lastEngaged < lastAttacked then
		if v12 - lastAttacked > aimAssist.AttackedMemory then
			return nil
		else
			lastAttackerId = DMG:GetAttribute("LastAttackerId")
		end
	elseif v12 - lastEngaged > aimAssist.ComboMemory then
		return nil
	else
		lastAttackerId = DMG:GetAttribute("LastEngangedWithId")
	end

	if type(lastAttackerId) ~= "string" or lastAttackerId == "" then
		return nil
	end

	for k in v3 do
		if not (k ~= p and k.Parent ~= nil and (k:GetAttribute("UniqueName") or k.Name) == lastAttackerId and humanoids ~= nil) then
			continue
		end

		if not k:IsDescendantOf(humanoids) then
			continue
		end

		local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")
		local humanoid = k:FindFirstChildOfClass("Humanoid")

		if humanoidRootPart ~= nil and humanoid ~= nil and humanoid.Health > 0 then
			return k
		end
	end

	return nil
end

local function scan()
	local v11, v12 = assistAllowed()

	if v11 == nil or v12 == nil then
		v4 = nil
		return
	end

	if humanoids == nil or humanoids.Parent == nil then
		humanoids = workspace:FindFirstChild("Humanoids")
	end

	if os.clock() < v5 then
		v4 = nil
		return
	end

	local v13 = tradingWith(v11)

	if v13 ~= nil then
		v4 = v13
		return
	end

	if not Platform_Handler.HoldingSkill() and CameraInput.getRotationActivated() then
		v4 = nil
		return
	end

	local aimAssist = config() -- equivalent call inferred; original call site unknown
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local v15 = currentCamera.ViewportSize.Y - GuiService:GetGuiInset().Y
	local platformRadius2 = gameSettings.AimAssist.PlatformRadius
	local v16 = Platform_Handler.IsGamepad() and "Console" or Platform_Handler.Platform.Value
	local v17

	if platformRadius2 ~= nil then
		v17 = tonumber(platformRadius2[v16])
	end

	local v18 = v17 == nil and 1 or math.max(v17, 0)
	local aimPoint = Platform_Handler.AimPoint()
	local v19 = Utility.Tick()
	local v20 = 1e999
	local v21 = 1e999
	local v22 = nil
	local v23 = nil
	local v24 = nil
	local v25 = false

	for k in v3 do
		if not (k ~= v11 and k.Parent ~= nil and humanoids ~= nil and k:IsDescendantOf(humanoids)) then
			continue
		end

		if Players:GetPlayerFromCharacter(k) == localPlayer then
			continue
		end

		local partyId = v11:GetAttribute("partyId")

		if not (partyId == nil or partyId == "" or k:GetAttribute("partyId") ~= partyId) then
			continue
		end

		local humanoidRootPart = k:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		local humanoid = k:FindFirstChildOfClass("Humanoid")

		if humanoid == nil or (humanoid.Health <= 0 or vector.magnitude(humanoidRootPart.Position - v12.Position) > aimAssist.Range) then
			continue
		end

		local v26 = humanoidRootPart.Position - cFrame.Position

		if vector.magnitude(v26) < 0.05 or vector.dot(cFrame.LookVector, (vector.normalize(v26))) < aimAssist.MinFacingDot then
			continue
		end

		local worldToViewportPoint, v27 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
		local guiInset = GuiService:GetGuiInset()
		local vector2 = Vector2.new(worldToViewportPoint.X - guiInset.X, worldToViewportPoint.Y - guiInset.Y)

		if not (v27 and worldToViewportPoint.Z > 0) then
			continue
		end

		local magnitude = (vector2 - aimPoint).Magnitude
		local v28

		if k == v4 then
			v28 = aimAssist.HoldRadius
		else
			v28 = aimAssist.CaptureRadius
		end

		if v28 * v15 * v18 < magnitude or Checker.check_can_select(script, v11, k) ~= true or Allegiance.SameOwner(
			v11,
			k
		) then
			continue
		end

		local getvaluesfolder = Utility.getvaluesfolder(k)

		if not (not aimAssist.SkipRagdolled or getvaluesfolder == nil or getvaluesfolder:FindFirstChild("RagDoll") == nil) then
			continue
		end

		local DMG

		if getvaluesfolder ~= nil then
			DMG = getvaluesfolder:FindFirstChild("DMG")
		end

		if DMG ~= nil and DMG:GetAttribute("LastAttacker") == localPlayer.Name and v19 - (tonumber(DMG:GetAttribute("LastAttacked")) or 0) <= aimAssist.ComboMemory then
			v25 = k == v4 or v25

			if magnitude < v20 then
				v22 = k
				v20 = magnitude
			end
		end

		if k == v4 then
			v23 = magnitude
		end

		if not (magnitude < v21) then
			continue
		end

		v24 = k
		v21 = magnitude
	end

	if v22 == nil then
		if v23 ~= nil and (v24 == v4 or v23 * aimAssist.SwitchRatio < v21) then
			return
		end

		v4 = v24
	elseif not v25 or v23 == nil then
		v4 = v22
	end
end

local total = 0
local v11 = true
heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
	if not v11 then
		shutdown("the target scan")
		return
	end

	total += dt

	if total < gameSettings.AimAssist.Refresh then
		return
	end

	total = 0
	v11 = false
	scan()
	v11 = true
end)

local function skillFollowUp(p)
	local aimAssist = config() -- equivalent call inferred; original call site unknown

	if os.clock() - (PlayerProfile.lastperformedaskill or 0) > aimAssist.SkillHitMemory then
		return false
	end

	local getvaluesfolder = Utility.getvaluesfolder(p)
	local DMG

	if getvaluesfolder ~= nil then
		DMG = getvaluesfolder:FindFirstChild("DMG")
	end

	return DMG ~= nil and DMG:GetAttribute("LastAttacker") == localPlayer.Name and Utility.Tick() - (tonumber(DMG:GetAttribute("LastAttacked")) or 0) <= aimAssist.SkillHitMemory
end

local function step(p: number)
	local v12 = v4
	local aimAssist = config() -- equivalent call inferred; original call site unknown
	local v14 = p * 60
	local isGamepad = Platform_Handler.IsGamepad()
	local v15 = assistAllowed()
	local v16

	if v12 == nil or v15 == nil then
		v16 = false
	else
		v16 = tradingWith(v15) == v12
	end

	if v12 ~= nil and not v16 and not Platform_Handler.HoldingSkill() and not skillFollowUp(v12) and CameraInput.getRotationActivated() then
		v4 = nil
		v12 = nil
	end

	if v12 == nil then
		Platform_Handler.SetAimLock(false)
		v6 = 0
		v7 = nil

		if isGamepad then
			local v17 = Platform_Handler.AimCentre() - Platform_Handler.AimPoint()

			if v17.Magnitude > aimAssist.CursorDeadZone then
				local v18 = math.min(aimAssist.CursorStrength * userStrength(), aimAssist.MaxStrength)
				Platform_Handler.NudgeAim(v17 * (1 - (1 - v18) ^ v14))
			end
		end
	else
		local v17 = assistAllowed()

		if v17 == nil then
			v4 = nil
			return
		end

		if humanoids == nil or not v12:IsDescendantOf(humanoids) then
			v4 = nil
			return
		end

		local humanoidRootPart = v12:FindFirstChild("HumanoidRootPart")
		local humanoid = v12:FindFirstChildOfClass("Humanoid")

		if v12.Parent == nil or humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") or humanoid == nil or humanoid.Health <= 0 then
			v4 = nil
			return
		end

		local currentCamera = workspace.CurrentCamera
		local cFrame = currentCamera.CFrame
		local v18 = humanoidRootPart.Position - cFrame.Position

		if vector.magnitude(v18) < 0.05 then
			return
		end

		local normalized = vector.normalize(v18)
		local lookVector = cFrame.LookVector

		if not v16 and vector.dot(lookVector, normalized) < aimAssist.MinFacingDot then
			v4 = nil
			return
		end

		local worldToViewportPoint, v19 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)
		local guiInset = GuiService:GetGuiInset()
		local vector2 = Vector2.new(worldToViewportPoint.X - guiInset.X, worldToViewportPoint.Y - guiInset.Y)
		local v20 = v19 and worldToViewportPoint.Z > 0

		if not (v16 or v20) then
			v4 = nil
			return
		end

		local v21 = Platform_Handler.HoldingSkill() or v16 or skillFollowUp(v12)
		local humanoidRootPart2 = v17:FindFirstChild("HumanoidRootPart")
		local v22 = (humanoidRootPart2 == nil or not humanoidRootPart2:IsA("BasePart")) and 1e999 or vector.magnitude(humanoidRootPart.Position - humanoidRootPart2.Position)
		local v23 = not (v22 < 1e999) and 0 or 1 - math.clamp(v22 / aimAssist.Range, 0, 1)

		local function scaled(p2: number)
			return (math.min(p2 + (aimAssist.MaxStrength - p2) * v23, aimAssist.MaxStrength))
		end

		local v24 = userStrength()
		local v25

		if v21 then
			local holdingStrength = aimAssist.HoldingStrength
			v25 = math.min(holdingStrength + (aimAssist.MaxStrength - holdingStrength) * v23, aimAssist.MaxStrength)
		else
			local cameraStrength = aimAssist.CameraStrength
			v25 = math.min(cameraStrength + (aimAssist.MaxStrength - cameraStrength) * v23, aimAssist.MaxStrength) * v24
		end

		local v26 = math.min(v25, aimAssist.MaxStrength)

		if not v21 and CameraInput.getRotationActivated() then
			v26 *= aimAssist.SteeringFactor
		end

		local holdingMaxYawPerFrame

		if v21 then
			holdingMaxYawPerFrame = aimAssist.HoldingMaxYawPerFrame
		else
			holdingMaxYawPerFrame = aimAssist.MaxYawPerFrame
		end

		local holdingMaxPitchPerFrame

		if v21 then
			holdingMaxPitchPerFrame = aimAssist.HoldingMaxPitchPerFrame
		else
			holdingMaxPitchPerFrame = aimAssist.MaxPitchPerFrame
		end

		local rightVector = cFrame.RightVector
		local vector3 = vector.create(lookVector.X, 0, lookVector.Z)
		local vector4 = vector.create(rightVector.X, 0, rightVector.Z)
		local vector5 = vector.create(normalized.X, 0, normalized.Z)
		local v27 = not (vector.magnitude(vector3) > 0.001 and vector.magnitude(vector5) > 0.001) and 0 or math.atan2(
			vector.dot(vector5, (vector.normalize(vector4))),
			(vector.dot(vector5, (vector.normalize(vector3))))
		)
		local v28 = math.asin((math.clamp(lookVector.Y, -1, 1))) - math.asin((math.clamp(normalized.Y, -1, 1)))

		if v7 ~= v12 then
			v7 = v12
			v6 = 0
		end

		local vector6 = Vector2.new(v27, v28)
		local vector7 = CameraInput.peekUserRotation(p)
		local v29 = not (vector6.Magnitude > aimAssist.AngleDeadZone) and 0 or vector7:Dot(vector6.Unit)

		if v29 < 0 then
			v6 = math.min(v6 - v29 / aimAssist.FightBreak, 1)
		else
			v6 = math.max(v6 - p / aimAssist.FightRecover, 0)
		end

		if v6 >= 1 then
			v6 = 0
			v7 = nil
			v4 = nil
			v5 = os.clock() + aimAssist.FightRelock
		else
			local v30 = 1 - (1 - v26 * (1 - v6)) ^ v14

			-- equivalent calls inferred from this helper; original call sites unknown
			local function shape(p2: number, max: number)
				if math.abs(p2) < aimAssist.AngleDeadZone then
					return 0
				end

				return (math.clamp(p2 * v30, -max, max))
			end

			local vector8 = Vector2.new(shape(v27, holdingMaxYawPerFrame), shape(v28, holdingMaxPitchPerFrame))

			if vector8 ~= Vector2.zero then
				CameraInput.addRotation(vector8)
			end

			if isGamepad then
				Platform_Handler.SetAimLock(true)
			end

			if isGamepad or Platform_Handler.AimActive() then
				local v31 = vector2 - Platform_Handler.AimPoint()

				if v31.Magnitude > aimAssist.CursorDeadZone then
					local v32

					if v21 then
						local holdingStrength = aimAssist.HoldingStrength
						v32 = math.min(
							holdingStrength + (aimAssist.MaxStrength - holdingStrength) * v23,
							aimAssist.MaxStrength
						)
					else
						local cursorStrength = aimAssist.CursorStrength
						v32 = math.min(
							cursorStrength + (aimAssist.MaxStrength - cursorStrength) * v23,
							aimAssist.MaxStrength
						) * v24
					end

					local v33 = v31 * (1 - (1 - math.min(v32, aimAssist.MaxStrength)) ^ v14)

					if v33.Magnitude > aimAssist.MaxCursorPerFrame then
						v33 = v33.Unit * aimAssist.MaxCursorPerFrame
					end

					Platform_Handler.NudgeAim(v33)
				end
			end
		end
	end
end

local v12 = true
RunService:BindToRenderStep("AimAssist", Enum.RenderPriority.Camera.Value - 1, function(p: number)
	if not v12 then
		shutdown("the per frame step")
		return
	end

	v12 = false
	step(p)
	v12 = true
end)
localPlayer.CharacterAdded:Connect(function()
	v4 = nil
end)
localPlayer.CharacterRemoving:Connect(function()
	v4 = nil
end)