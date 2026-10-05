local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local child = game.ReplicatedStorage.Player_Service:WaitForChild("Values"):WaitForChild(localPlayer.Name)
local Combat_presets = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Combat_presets"))
local clock = os.clock
local Run_Handler = require(game.ReplicatedStorage.CAM:WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))
local Platform_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Platform_Handler"))
local Checker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Checker"))
local gameSettings = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("gameSettings"))
local v = false
humanoid:WaitForChild("Animator")
local cleanit = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("cleanit"))
local Cam_Shaker = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("Effects"):WaitForChild("Cam_Shaker"))
local Character_info_provider = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Character_info_provider"))
local PlayerProfile = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("PlayerProfile"))
local manage_cd = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Gameplay"):WaitForChild("manage_cd"))
local vfxUtility = require(game.ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local dialogue = ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Components"):WaitForChild("Layout"):WaitForChild("Visibility"):WaitForChild("Dialogue")

local function menuOpened()
	local menuDestination = localPlayer:FindFirstChild("MenuDestination")
	return menuDestination ~= nil and menuDestination.Value ~= ""
end

local Camera_Traffic_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Camera_Traffic_Handler)
local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true, 0)
local color = Color3.fromRGB(200, 120, 120)
local tweenInfo2 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local volume = nil
local v3 = nil

local function lowHealthCorrection()
	local currentCamera = workspace.CurrentCamera
	local v4 = currentCamera:FindFirstChild("LowHealthColorCorrection")

	if v4 ~= nil and v4:IsA("ColorCorrectionEffect") then
		return v4
	end

	v4 = Instance.new("ColorCorrectionEffect")
	v4.Name = "LowHealthColorCorrection"
	v4.TintColor = Color3.new(1, 1, 1)
	v4.Parent = currentCamera
	return v4
end

local lowHealthColorCorrection = workspace.CurrentCamera:FindFirstChild("LowHealthColorCorrection")

if lowHealthColorCorrection ~= nil then
	lowHealthColorCorrection:Destroy()
end

local v4 = false
local v5 = nil
local track = nil

local function setLowHealth(flag: boolean)
	if v4 == flag then
		return
	end

	v4 = flag
	local v6 = lowHealthCorrection()
	local heartBeat = script:FindFirstChild("HeartBeat")

	if flag then
		v5 = TweenService:Create(v6, tweenInfo, {
			TintColor = color
		})
		v5:Play()

		if heartBeat ~= nil and heartBeat:IsA("Sound") then
			if volume == nil then
				volume = heartBeat.Volume * 0.5
			end

			if v3 ~= nil then
				v3:Cancel()
			end

			if not heartBeat.IsPlaying then
				heartBeat.Volume = 0
				heartBeat:Play()
			end

			v3 = TweenService:Create(heartBeat, tweenInfo2, {
				Volume = volume
			})
			v3:Play()
		end

		local get_core_anim = Character_info_provider.get_core_anim(localPlayer, "Low_Hp")
		local animator = humanoid:FindFirstChildOfClass("Animator")

		if get_core_anim ~= nil and animator ~= nil then
			track = animator:LoadAnimation(get_core_anim)
			track:Play()
		end
	else
		if v5 ~= nil then
			v5:Cancel()
			v5 = nil
		end

		v6.TintColor = Color3.new(1, 1, 1)

		if heartBeat ~= nil and heartBeat:IsA("Sound") then
			if v3 ~= nil then
				v3:Cancel()
			end

			v3 = TweenService:Create(heartBeat, tweenInfo2, {
				Volume = 0
			})
			v3.Completed:Once(function(p)
				if p == Enum.PlaybackState.Completed and not v4 then
					heartBeat:Stop()

					if volume ~= nil then
						heartBeat.Volume = volume
					end
				end
			end)
			v3:Play()
		end

		if track ~= nil then
			track:Stop()
			track = nil
		end
	end
end

script.Destroying:Once(function()
	if v5 ~= nil then
		v5:Cancel()
	end
end)
local CollectionService = game:GetService("CollectionService")

local function isInWater()
	local character2 = localPlayer.Character or character
	local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

	if character2 then
		local swimState = character2:GetAttribute("SwimState")

		if typeof(swimState) == "number" and swimState > 0 then
			return true
		end
	end

	if humanoidRootPart2 == nil then
		return false
	end

	local position = humanoidRootPart2.Position

	for _, part in CollectionService:GetTagged("SwimParts") do
		if not part:IsA("BasePart") then
			continue
		end

		local pointToObjectSpace = part.CFrame:PointToObjectSpace(position)
		local halfSize = part.Size / 2

		if math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Z) <= halfSize.Z and pointToObjectSpace.Y <= halfSize.Y then
			return true
		end
	end

	return false
end

local now = 0
local now2 = 0
humanoid.Jumping:Connect(function()
	now2 = clock()
end)
humanoid.StateChanged:Connect(function(p)
	if p == Enum.HumanoidStateType.Landed and humanoidRootPart ~= nil and humanoid ~= nil then
		if isInWater() or clock() - now < 0.2 then
			now2 = clock()
			return
		end

		local _, v6 = manage_cd.skillStatus(localPlayer)
		local v7 = not (humanoidRootPart:FindFirstChild("ClimbAttachment") or clock() - Combat_presets.Last_Climb < 0.15)

		if PlayerProfile.lastperformedaskill and os.clock() - PlayerProfile.lastperformedaskill <= 0.8 then
			v7 = false
		end

		if v6 == true then
			v7 = false
		end

		local get_core_anim = Character_info_provider.get_core_anim(localPlayer, "land")

		if clock() - now2 > 1 and v7 then
			if humanoidRootPart then
				local v8 = humanoidRootPart.Position + createVector(0, 3, 0)
				local raycastResult = workspace:Raycast(v8, createVector(0, -10, 0), RaycastHelper.Crater)

				if raycastResult and raycastResult.Instance then
					local clone = script.Part:Clone()
					clone.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position - raycastResult.Normal) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Parent = workspace.Debree
					vfxUtility.EmitAll(clone, vfxUtility.Owned(humanoidRootPart, raycastResult.Instance.Color))
					DebrisModule:AddItem(clone, 2.5)
				end
			end

			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.12,
				SustainTime = 0.12,
				FadeOutTime = 0.15,
				RotationInfluence = createVector(0.1, 0.1, 0.1),
				PositionInfluence = createVector(0.4, 0.4, 0.4)
			})
		end

		now2 = clock()
		humanoid.Animator:LoadAnimation(get_core_anim):Play()
	end
end)
local find = table.find
local v6 = { "gamatunda_hip_height", "hip_height" }
local v7 = false
local hipHeight = humanoid.HipHeight

function upd_Hip()
	local hipHeight2 = 0
	local v8 = false

	for _, child2 in pairs(child:GetChildren()) do
		if find(v6, child2.Name) == nil then
			continue
		end

		v8 = true

		if hipHeight2 < child2.Value then
			hipHeight2 = child2.Value
		end
	end

	if v7 ~= v8 then
		if v8 == true then
			hipHeight = humanoid.HipHeight
		end

		v7 = v8
	end

	if v8 == true then
		humanoid.HipHeight = hipHeight2
	else
		humanoid.HipHeight = hipHeight
	end
end

upd_Hip()
child.ChildAdded:Connect(function(child2)
	if find(v6, child2.Name) ~= nil then
		upd_Hip()
	end
end)
child.ChildRemoved:Connect(function(child2)
	if find(v6, child2.Name) ~= nil then
		upd_Hip()
	end
end)
local currentCamera = workspace.CurrentCamera
local intValue = Instance.new("IntValue")
intValue.Name = "Field_of_View"
intValue.Parent = script
intValue.Value = 70
intValue.Changed:Connect(function()
	if intValue ~= nil then
		currentCamera.FieldOfView = intValue.Value
	end
end)
local v8 = cleanit.new()
local v9 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function isFovValue(instance)
	return instance.Name == "FOV" or CollectionService:HasTag(instance, "FOV")
end

function updFOV()
	local v10 = nil
	local v11 = -99

	for _, child2 in pairs(child:GetChildren()) do
		if not isFovValue(child2) then
			continue
		end

		if v10 == nil then
			v10 = child2
		end

		local priority = child2:GetAttribute("Priority")

		if not (priority ~= nil and v11 < priority) then
			continue
		end

		v11 = priority
		v10 = child2
	end

	if v10 == nil then
		v8:Clean()
		intValue.Value = 70
	elseif v10 ~= v9 then
		v8:Clean()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updVALUE()
			if v10 ~= nil then
				intValue.Value = v10.Value
			end
		end

		updVALUE() -- equivalent call inferred; original call site unknown
		v8:Connect(v10:GetPropertyChangedSignal("Value"), updVALUE)
	end

	v9 = v10
end

child.ChildAdded:Connect(function(child2)
	task.wait()

	if isFovValue(child2) then
		updFOV()
	end
end)
child.ChildRemoved:Connect(function(child2)
	task.wait()

	if isFovValue(child2) then
		updFOV()
	end
end)
updFOV()
currentCamera.FieldOfView = intValue.Value
local Allegiance = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Allegiance"))
local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v10 = {}

local function clearOtherHighlights()
	for _, v11 in v10 do
		local tween = TweenService:Create(v11, tweenInfo3, {
			FillTransparency = 1,
			OutlineTransparency = 1
		})
		local v12 = v11
		tween.Completed:Once(function()
			v12:Destroy()
		end)
		tween:Play()
	end

	table.clear(v10)
end

local function highlightOthers()
	clearOtherHighlights()
	local humanoids = workspace:FindFirstChild("Humanoids")

	if humanoids == nil then
		return
	end

	local character2 = localPlayer.Character

	for _, model in humanoids:GetChildren() do
		if not (model ~= character2 and model:IsA("Model")) then
			continue
		end

		if not (character2 == nil or not (Allegiance.Protected(character2, model) or Allegiance.SameOwner(
			character2,
			model
		))) then
			continue
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "HighlightOthers"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = model
		TweenService:Create(highlight, tweenInfo3, {
			FillTransparency = 0.5,
			OutlineTransparency = 0
		}):Play()
		table.insert(v10, highlight)
	end
end

child.ChildAdded:Connect(function(child2)
	if child2.Name == "HighlightOthers" then
		highlightOthers()
	end
end)
child.ChildRemoved:Connect(function(child2)
	if child2.Name == "HighlightOthers" and child:FindFirstChild("HighlightOthers") == nil then
		clearOtherHighlights()
	end
end)

if child:FindFirstChild("HighlightOthers") ~= nil then
	highlightOthers()
end

local defaultMaxZoom = gameSettings.defaultMaxZoom or localPlayer.CameraMaxZoomDistance
local cameraMinZoomDistance = localPlayer.CameraMinZoomDistance

local function getZoomOverride(p: string)
	local v11 = -1e999
	local v12 = nil

	for _, child2 in child:GetChildren() do
		if child2.Name ~= p then
			continue
		end

		local priority = child2:GetAttribute("Priority") or 0

		if not (v11 < priority) then
			continue
		end

		v12 = child2
		v11 = priority
	end

	if v12 == nil then
		return nil
	end

	return v12.Value
end

local magnitude = nil
local v11 = 0
local changedConnection = nil

function updSHC(p)
	if changedConnection ~= nil then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	changedConnection = p.Changed:Connect(function(p2)
		if p2 == "" then
			Run_Handler.SkillBeingPerformed = false
		else
			Run_Handler.SkillBeingPerformed = true
		end
	end)
end

character.ChildAdded:Connect(function(child2)
	if child2.Name == "SHC" then
		updSHC(child2)
	end
end)

local function getWalkSpeedOverride()
	local v12 = -1e999
	local v13 = nil

	for _, child2 in child:GetChildren() do
		if child2.Name ~= "WalkSpeed" then
			continue
		end

		local priority = child2:GetAttribute("Priority") or 0

		if not (v12 < priority) then
			continue
		end

		v13 = child2
		v12 = priority
	end

	if v13 == nil then
		return nil
	end

	return v13.Value
end

local track2 = nil

while humanoidRootPart ~= nil and humanoid ~= nil do
	local slow_walk_speed = 16
	local autoRotate = true
	local platformStand = false
	local state = humanoid:GetState()
	local swimState = (localPlayer.Character or character):GetAttribute("SwimState")

	if typeof(swimState) == "number" and swimState > 0 then
		now = clock()
	end

	setLowHealth(PlayerStatResolver.GetStat(localPlayer, "Low Health") == true or PlayerStatResolver.GetStat(
		localPlayer,
		"Fear"
	) == true)
	local v15 = child:FindFirstChild("Strict_Stun") ~= nil
	local v16 = child:FindFirstChild("Stun") ~= nil or (child:FindFirstChild("CombatStun") or v15)

	if v ~= v16 then
		if track2 ~= nil then
			track2:Stop()
			track2 = nil
		end

		if v16 == true then
			track2 = humanoid.Animator:LoadAnimation(Character_info_provider.get_core_anim(
				localPlayer,
				"Stun_Idle_Animation"
			))
			track2:Play()
		end

		v = v16
	end

	if humanoid.Health > 0 and state ~= Enum.HumanoidStateType.Dead then
		local v17 = localPlayer.Name .. localPlayer.UserId .. "'s gamatundeasd12-12"
		platformStand = workspace.Debree:FindFirstChild(v17) and true or false
	end

	local skill_stand_still = humanoidRootPart:FindFirstChild("skill_stand_still") or child:FindFirstChild("skill_stand_still")
	local walkSpeed

	if v16 == true or child:FindFirstChild("RagDoll") ~= nil or skill_stand_still then
		walkSpeed = 0
	else
		Run_Handler.IsWalking = clock() - Combat_presets.Last_Punched < Combat_presets.slow_walk_duration

		if Run_Handler.IsWalking or humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil then
			slow_walk_speed = Combat_presets.slow_walk_speed
		elseif Run_Handler.Is_Running == true then
			if Checker.ShallowWater then
				slow_walk_speed = Run_Handler.shallow_water_run_speed
			else
				slow_walk_speed = Run_Handler.run_speed
			end

			local stat = PlayerStatResolver.GetStat(localPlayer, "Run Speed Factor")

			if typeof(stat) == "number" and stat ~= 0 then
				slow_walk_speed *= 1 + stat
			end
		end

		local v18 = slow_walk_speed * PlayerStatResolver.GetMovementMultiplier(localPlayer)
		walkSpeed = (child:FindFirstChild("Blocking") ~= nil or humanoidRootPart:FindFirstChild("skill_slow")) and 4 or v18
		local walkSpeedOverride = getWalkSpeedOverride()

		if walkSpeedOverride ~= nil then
			walkSpeed = walkSpeedOverride
		end
	end

	local swimDrowning = (localPlayer.Character or character):GetAttribute("SwimDrowning") == true
	local jumpPower = (v16 == true or child:FindFirstChild("RagDoll") ~= nil or child:FindFirstChild("Blocking") ~= nil or skill_stand_still or swimDrowning or child:FindFirstChild("JumpingDisabled") ~= nil) and 0 or (clock() - Combat_presets.Last_Punched_Jump <= Combat_presets.No_Jump_Duration or humanoidRootPart:FindFirstChild("air_combo_bp") ~= nil) and 0 or 50

	if jumpPower > 0 then
		jumpPower *= 1 + (PlayerStatResolver.GetStat(localPlayer, "Jump Power Factor") or 0)
	end

	if child:FindFirstChild("RagDoll") ~= nil or humanoidRootPart:FindFirstChild("ClimbAttachment") or child:FindFirstChild("NR") ~= nil or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		autoRotate = false
	end

	local camsubject = child:FindFirstChild("camsubject")
	local cameraSubject

	if camsubject == nil or camsubject.Value == nil or not camsubject.Value:IsDescendantOf(workspace) then
		cameraSubject = humanoid
	else
		cameraSubject = camsubject.Value
	end

	if cameraSubject and cameraSubject ~= currentCamera.CameraSubject then
		currentCamera.CameraSubject = cameraSubject
	end

	local zoomOverride = getZoomOverride("MaxZoom")
	local zoomOverride2 = getZoomOverride("MinZoom")
	local v19 = zoomOverride ~= nil or zoomOverride2 ~= nil

	if v19 and magnitude == nil then
		magnitude = (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude
		v11 = 0
	elseif not v19 and magnitude ~= nil and v11 == 0 then
		v11 = clock() + 0.1
	end

	local cameraMaxZoomDistance = zoomOverride or defaultMaxZoom
	local cameraMinZoomDistance2 = zoomOverride2 or cameraMinZoomDistance

	if not v19 and magnitude ~= nil then
		if clock() < v11 then
			cameraMaxZoomDistance = math.clamp(magnitude, cameraMinZoomDistance2, cameraMaxZoomDistance)
			cameraMinZoomDistance2 = cameraMaxZoomDistance
		else
			magnitude = nil
		end
	end

	if localPlayer.CameraMaxZoomDistance ~= cameraMaxZoomDistance then
		localPlayer.CameraMaxZoomDistance = cameraMaxZoomDistance
	end

	if localPlayer.CameraMinZoomDistance ~= cameraMinZoomDistance2 then
		localPlayer.CameraMinZoomDistance = cameraMinZoomDistance2
	end

	humanoid.WalkSpeed = walkSpeed
	humanoid.JumpPower = jumpPower
	humanoid.AutoRotate = autoRotate

	if Platform_Handler.IsGamepad() or Platform_Handler.Platform.Value == "Mobile" then
		humanoid.CameraOffset = Run_Handler.Shift_lock == 1 and createVector(0, 1.35, 0) or createVector(0, 0, 0)
	end

	humanoid.PlatformStand = platformStand
	local touchControlsEnabled

	if dialogue.Value == true or Camera_Traffic_Handler.Equipped_Hirearchy == "Cutscene" or localPlayer:GetAttribute("MapOpened") == true then
		touchControlsEnabled = false
	else
		local menuDestination = localPlayer:FindFirstChild("MenuDestination")
		touchControlsEnabled = menuDestination == nil or menuDestination.Value == ""
	end

	if GuiService.TouchControlsEnabled ~= touchControlsEnabled then
		GuiService.TouchControlsEnabled = touchControlsEnabled
	end

	task.wait(0.075)
end