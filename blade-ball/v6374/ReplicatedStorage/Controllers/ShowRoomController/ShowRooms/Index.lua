local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local GamepadService = game:GetService("GamepadService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Packages.Spring)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Common.Utils)
require3(script.Parent.Parent.ShowRoomUtility)
require3(script.Parent.Templates.ShowRoom3D)
require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
local v5 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
require3(ReplicatedStorage2.Controllers.EmoteController)
local v6 = require3(ReplicatedStorage2.Controllers.VFXController)
local v7 = require3(ReplicatedStorage2.Shared.SwordAPI)
local v8 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v9 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v10 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
require3(ReplicatedStorage2.Shared.RNG.Emotes)
require3(ReplicatedStorage2.Shared.Emotes)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v11 = require3(ReplicatedStorage2.Shared.EmotesShared)
require3(ReplicatedStorage2.ServerInfo)
local v12 = require3(ReplicatedStorage2.Shared.AnimationProfiles)
local v13 = require3(ReplicatedStorage2.Packages.Observers)
local atmosphere = Lighting:FindFirstChild("Atmosphere")
local gameSettings = UserSettings().GameSettings
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function thumbstickCurve(p: number)
	local v14 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v14, 0, 1)
end

local Index = {}
Index.Template = ReplicatedStorage2.Misc.ShowRooms.Index

function Index.AfterInit(data)
	local v14 = nil
	local instance = data.Instance
	local _ = data.Trove
	local character = localPlayer.Character
	local humanoid

	if character then
		humanoid = character:FindFirstChildWhichIsA("Humanoid")
	end

	local appliedDescription

	if humanoid then
		appliedDescription = humanoid:GetAppliedDescription()
	else
		appliedDescription = nil
	end

	if not (appliedDescription and humanoid and character) then
		return
	end

	local showRoom = instance.ShowRoom
	showRoom.Parent = nil
	local pivot = showRoom:GetPivot()
	showRoom:GetExtentsSize()
	local clone = showRoom:Clone()
	clone.Parent = instance
	clone:PivotTo(pivot)
	local clone2 = instance.NPC:Clone()
	instance.NPC.Parent = nil
	data.Info.NPC = clone2
	clone2:PivotTo(clone.Object:GetPivot())
	clone2.Parent = clone.Object
	task.spawn(pcall, function()
		clone2.Humanoid:ApplyDescription(appliedDescription)
	end)
	local maid = v4.new()
	local animator = clone2.Humanoid.Animator

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playExplosion(name: string)
		xpcall(function()
			maid:Add(v6:PlayExplosion(name, clone2.HumanoidRootPart.Position - createVector(0, 3, 0), nil, clone2, nil))
		end, warn)
	end

	local function equipSword(p: string)
		local sword = v10:GetSword(p)
		local v15

		if sword and v14 then
			v15 = sword.AccessoryUnlockable and v14.Accessory ~= true
		end

		local v16 = v10:EquipSwordTo(clone2, p, clone2:GetScale(), v15)
		local v17 = nil

		for _, child in clone2:GetChildren() do
			if not child:GetAttribute("_swordAccessory") then
				continue
			end

			v17 = child
			break
		end

		if v17 then
			maid:Add(v13.observeChildren(v17, function(instance2)
				if not instance2:HasTag("AnimatedAccessory") then
					return nil
				end

				instance2:RemoveTag("AnimatedAccessory")
				local animator2 = instance2:FindFirstChildWhichIsA("Animator", true)
				local walk = animator2 and animator2:FindFirstChild("Walk", true)

				if not (animator2 and walk) then
					return nil
				end

				local track = animator2:LoadAnimation(walk)
				maid:Add(function()
					track:Stop()
					track:Destroy()
				end)
				track:Play()
				local v19 = v12[p]

				if v19 and v19.walk then
					local id = v19.walk[1].id
					local v20 = maid:Add(Instance.new("Animation"))
					v20.AnimationId = id
					local track2 = animator:LoadAnimation(v20)
					maid:Add(function()
						track2:Stop()
						track2:Destroy()
					end)
					track2:Play()
				end

				return nil
			end))
		end

		return v16
	end

	local tracks = nil
	local sword = nil

	local function parry()
		if tracks and sword then
			for _, v15 in tracks do
				v15:Play(0)
			end

			ReplicatedStorage2.Remotes.ParrySuccessClient:Fire(
				v7:GetSlashName(sword.Name, sword.SlashName),
				clone2.HumanoidRootPart,
				sword.Name
			)
		end
	end

	local maid2 = v4.new()
	local name = nil

	local function playEmote()
		maid2:Clean()

		if not name then
			return
		end

		local v15 = true
		maid2:Add(function()
			v15 = false
		end)
		clone2:SetAttribute("PassiveRNGEmote", nil)
		v11:Play(clone2, maid2, name, true, workspace:GetServerTimeNow())

		if not v15 then
			return
		end

		maid2:Add(function()
			local v16 = v4.new()
			v11:Play(clone2, v16, name, false, workspace:GetServerTimeNow())
			v16:Destroy()
		end)
		maid2:Add(function()
			clone2:SetAttribute("PassiveRNGEmote", nil)
		end)
	end

	local name2 = nil

	local function renderSword(p: string?)
		local sword2 = v10:GetSword(p or name2 or "Base Sword")

		if sword2 then
			equipSword(sword2.Name)

			for _, animation in v7:GetAnimations(clone2, "Idle", sword2.AnimationType, sword2.SwordType) do
				local track = animator:LoadAnimation(animation)
				maid:Add(function()
					track:Stop()
					track:Destroy()
				end)
				track:Play()
			end
		end
	end

	local function render(_, p, p2)
		local maid3 = v4.new()
		equipSword("Nothing")

		if p == "Sword" then
			sword = v10:GetSword(p2.Name)

			if not sword then
				return maid3
			end

			name2 = p2.Name
			renderSword(p2.Name)
			local animations = v7:GetAnimations(
				clone2,
				{ "Parry", "SuccessParry" },
				sword.AnimationType,
				sword.SwordType
			)
			tracks = table.create(#animations)

			for k, animation in animations do
				local track = animator:LoadAnimation(animation)
				maid3:Add(function()
					track:Stop()
					track:Destroy()
				end)
				track.Looped = false
				tracks[k] = track
			end

			return maid3
		else
			if p ~= "Emote" then
				return maid3
			end

			local instance2 = v8:GetInstance(p2.Name)
			local instance3 = v9:GetInstance(p2.Name)

			if not (instance2 and instance2:GetAttribute("HideSword")) then
				renderSword(instance3 and instance3:GetAttribute("Sword"))
			end

			if ReplicatedStorage2.Misc.Emotes:FindFirstChild(p2.Name) then
				name = p2.Name
				playEmote()
				maid3:Add(maid2)
			end

			return maid3
		end
	end

	local currentCamera2 = "Right"

	local function getCameraCFrame()
		local child = clone:FindFirstChild((`Camera{currentCamera2}`))

		if child then
			return child.CFrame
		end

		return CFrame.identity
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCamera()
		local _ = v5.ShowRoom == nil
		data.Info.CurrentCamera = currentCamera2
	end

	data.Info.UpdateCamera = updateCamera
	data.Info.GetCameraCFrame = getCameraCFrame

	function data.Info.PreviewClicked() end

	function data.Info.SetCamera(p: string)
		currentCamera2 = p
		updateCamera() -- equivalent call inferred; original call site unknown
	end

	task.spawn(updateCamera)

	function data.Info.Render(p, p2)
		if p2 and p == "Explosion" then
			maid:Clean()
			renderSword()
			playExplosion(p2.Name) -- equivalent call inferred; original call site unknown
		elseif p2 and v14 and v3.Dictionary.equals(v14, p2) then
			if p == "Sword" then
				parry()
			elseif p == "Emote" then
				playEmote()
			end
		else
			v14 = p2
			updateCamera() -- equivalent call inferred; original call site unknown
			maid:Clean()

			if p2 then
				maid:Add((render(clone.Object, p, p2)))
			end
		end
	end

	data.Info.Zoom = 0
end

function Index.BeforeShow(data)
	local NPC = data.Info.NPC
	local trove = data.Trove
	task.defer(data.Info.UpdateCamera)
	local mouseLocation = nil
	local zero = Vector2.zero
	local vector2 = nil
	local v14 = 0
	local v15 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyDeltaToZoom(p)
		data.Info.Zoom = math.clamp(data.Info.Zoom + p, -10, 60)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function clear()
		if mouseLocation then
			zero += v:GetMouseLocation() - mouseLocation
			mouseLocation = nil
		end

		vector2 = nil
		v14 = 0
	end

	trove:Add(v.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or v15 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mouseLocation = v:GetMouseLocation()
		end
	end))
	trove:Add(v.InputChanged:Connect(function(input, gameProcessed: boolean)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 and not GamepadService.GamepadCursorEnabled then
			v14 = -thumbstickCurve(input.Position.Y)
		end

		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			applyDeltaToZoom(-input.Position.Z) -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local v16 = thumbstickCurve(input.Position.X) -- equivalent call inferred; original call site unknown
			local Y = input.Position.Y
			vector2 = Vector3.new(v16, -thumbstickCurve(Y), 0)
		end
	end))
	trove:Add(v.InputEnded:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.Thumbstick2 then
			clear() -- equivalent call inferred; original call site unknown
		end
	end))
	local v16 = nil

	local function roundVector2(point: Vector2, p: number)
		local v17 = 10 ^ p
		return Vector2.new(math.floor(point.X * v17) / v17, math.floor(point.Y * v17) / v17)
	end

	trove:Add(v.TouchPinch:Connect(function(list, _: number, _: number, p, _: boolean)
		v15 = p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change
		mouseLocation = nil
		local v17 = list[1]
		local vector3 = Vector2.new(math.floor(v17.X * 100) / 100, math.floor(v17.Y * 100) / 100)
		local v18 = list[2]
		local v19 = (vector3 - Vector2.new(math.floor(v18.X * 100) / 100, math.floor(v18.Y * 100) / 100)).Magnitude * 0.4

		if (p == Enum.UserInputState.Change or p == Enum.UserInputState.End) and v16 then
			applyDeltaToZoom(v19 - v16) -- equivalent call inferred; original call site unknown
		end

		v16 = v19
	end))
	local zoom = data.Info.Zoom
	local instance = data.Instance
	local v17 = v2.new(createVector(0, 0, 0), 2.75, nil, 0.6)
	trove:Add(RunService.PostSimulation:Connect(function(dt: number)
		local vector3 = Vector2.new(1, gameSettings:GetCameraYInvertValue())

		if v14 ~= 0 then
			applyDeltaToZoom(v14 * dt * 60) -- equivalent call inferred; original call site unknown
		end

		if vector2 then
			zero += Vector2.new(vector2.X, vector2.Y * 0.77) * vector3 * gameSettings.GamepadCameraSensitivity * 4 * dt * 60 * 45
		end

		local zero2 = Vector2.zero

		if mouseLocation then
			zero2 += v:GetMouseLocation() - mouseLocation
		end

		local v18 = zero2 * vector3 + zero
		zoom += (data.Info.Zoom - zoom) * (dt * 0.3 * 60)
		v17.goal = Vector3.new(
			math.rad(-v18.X * gameSettings.MouseSensitivity),
			math.rad((math.clamp(v18.Y * gameSettings.MouseSensitivity, -89, 89))),
			0
		)
		local v19 = v17:update(dt)
		currentCamera.CFrame = NPC:GetPivot() * CFrame.Angles(0, v19.X, 0) * CFrame.Angles(v19.Y, 0, 0) * CFrame.new(
			data.Info.CurrentCamera ~= "Right" and 0 or (1 - -math.clamp(zoom / 6, -1, 0)) * 3,
			0.5,
			-(zoom + 12)
		) * CFrame.Angles(0, 3.141592653589793, 0)
		local v20 = zoom + 40
		local v21 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * 2 * v20
		instance.Bg.Size = Vector3.new(v21 * (currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y), v21, 0)
		instance.Bg:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -v20))
	end))
	local density, densityChangedConnection

	if atmosphere then
		density = atmosphere.Density
		atmosphere.Density = 0
		densityChangedConnection = atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
			if atmosphere.Density == 0 then
				return
			end

			density = atmosphere.Density
			atmosphere.Density = 0
		end)
	else
		densityChangedConnection = nil
		density = nil
	end

	data.Trove:Add(function()
		if densityChangedConnection then
			densityChangedConnection:Disconnect()
		end

		if atmosphere and density then
			atmosphere.Density = density
		end
	end)
end

return Index