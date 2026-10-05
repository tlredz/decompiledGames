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
local v5 = require3(ReplicatedStorage2.Common.Utils)
require3(script.Parent.Parent.ShowRoomUtility)
require3(script.Parent.Templates.ShowRoom3D)
require3(ReplicatedStorage2.Controllers.UI.LimitedSwordPacksController)
local v6 = require3(ReplicatedStorage2.Controllers.ShowRoomController)
require3(ReplicatedStorage2.Controllers.EmoteController)
local v7 = require3(ReplicatedStorage2.Controllers.VFXController)
local v8 = require3(ReplicatedStorage2.Shared.SwordAPI)
local v9 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteAccessories)
local v10 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.EmoteVFX)
local v11 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
require3(ReplicatedStorage2.Shared.RNG.Emotes)
require3(ReplicatedStorage2.Shared.Emotes)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v12 = require3(ReplicatedStorage2.Shared.EmotesShared)
require3(ReplicatedStorage2.ServerInfo)
local v13 = require3(ReplicatedStorage2.Shared.AnimationProfiles)
local v14 = require3(ReplicatedStorage2.Packages.Observers)
local atmosphere = Lighting:FindFirstChild("Atmosphere")
local gameSettings = UserSettings().GameSettings
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

-- equivalent calls inferred from this helper; original call sites unknown
local function thumbstickCurve(p: number)
	local v15 = (math.exp((math.abs(p) - 0.1) / 0.9 * 2) - 1) / 6.38905609893065
	return math.sign(p) * math.clamp(v15, 0, 1)
end

local v15 = CFrame.new(-8.5, 2, -17) * CFrame.Angles(0, 3.9269908169872414, 0)
local SwordForge = {}
SwordForge.Template = ReplicatedStorage2.Misc.ShowRooms.SwordForge

function SwordForge.AfterInit(data)
	local v16 = nil
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

	local maid = v4.new()
	local swordForge = localPlayer.PlayerGui.SwordForge
	local track = nil
	swordForge:GetAttributeChangedSignal("Forging"):Connect(function()
		maid:Clean()
		local instance2 = data.Instance
		local swordForgeNPC = instance2 and instance2.ShowRoom and instance2.ShowRoom.SwordForgeNPC
		local animator = swordForgeNPC and swordForgeNPC.SwordForgeNPC.Humanoid.Animator

		if not animator then
			warn("No SwordForgeNPC animator found")
		elseif swordForge:GetAttribute("Forging") and v6.UI == "SwordForge" then
			track = animator:LoadAnimation(script.Hammer)
			maid:Add(track:GetMarkerReachedSignal("Hit"):Connect(function()
				v5.Visual:PlayEffects(swordForgeNPC.Anvil.VFX)
			end))
			track:Play()
			maid:Add(function()
				if track.IsPlaying then
					track:Stop()
				end

				track:Destroy()
			end)
		elseif track and track.IsPlaying then
			track:Stop()
		end
	end)
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
	local maid2 = v4.new()
	local animator = clone2.Humanoid.Animator

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playExplosion(name: string)
		xpcall(function()
			maid2:Add(v7:PlayExplosion(name, clone2.HumanoidRootPart.Position - createVector(0, 3, 0), nil, clone2, nil))
		end, warn)
	end

	local function equipSword(p: string)
		local sword = v11:GetSword(p)
		local v17

		if sword and v16 then
			v17 = sword.AccessoryUnlockable and v16.Accessory ~= true
		end

		local v18 = v11:EquipSwordTo(clone2, p, clone2:GetScale(), v17)
		local v19 = nil

		for _, child in clone2:GetChildren() do
			if not child:GetAttribute("_swordAccessory") then
				continue
			end

			v19 = child
			break
		end

		if v19 then
			maid2:Add(v14.observeChildren(v19, function(instance2)
				if not instance2:HasTag("AnimatedAccessory") then
					return nil
				end

				instance2:RemoveTag("AnimatedAccessory")
				local animator2 = instance2:FindFirstChildWhichIsA("Animator", true)
				local walk = animator2 and animator2:FindFirstChild("Walk", true)

				if not (animator2 and walk) then
					return nil
				end

				local track2 = animator2:LoadAnimation(walk)
				maid2:Add(function()
					track2:Stop()
					track2:Destroy()
				end)
				track2:Play()
				local v21 = v13[p]

				if v21 and v21.walk then
					local id = v21.walk[1].id
					local v22 = maid2:Add(Instance.new("Animation"))
					v22.AnimationId = id
					local track3 = animator:LoadAnimation(v22)
					maid2:Add(function()
						track3:Stop()
						track3:Destroy()
					end)
					track3:Play()
				end

				return nil
			end))
		end

		return v18
	end

	local tracks = nil
	local sword = nil

	local function parry()
		if tracks and sword then
			for _, v17 in tracks do
				v17:Play(0)
			end

			ReplicatedStorage2.Remotes.ParrySuccessClient:Fire(
				v8:GetSlashName(sword.Name, sword.SlashName),
				clone2.HumanoidRootPart,
				sword.Name
			)
		end
	end

	local maid3 = v4.new()
	local name = nil

	local function playEmote()
		maid3:Clean()

		if not name then
			return
		end

		local v17 = true
		maid3:Add(function()
			v17 = false
		end)
		clone2:SetAttribute("PassiveRNGEmote", nil)
		v12:Play(clone2, maid3, name, true, workspace:GetServerTimeNow())

		if not v17 then
			return
		end

		maid3:Add(function()
			local v18 = v4.new()
			v12:Play(clone2, v18, name, false, workspace:GetServerTimeNow())
			v18:Destroy()
		end)
		maid3:Add(function()
			clone2:SetAttribute("PassiveRNGEmote", nil)
		end)
	end

	local name2 = nil

	local function renderSword(p: string?)
		local sword2 = v11:GetSword(p or name2 or "Base Sword")

		if sword2 then
			equipSword(sword2.Name)

			for _, animation in v8:GetAnimations(clone2, "Idle", sword2.AnimationType, sword2.SwordType) do
				local track2 = animator:LoadAnimation(animation)
				maid2:Add(function()
					track2:Stop()
					track2:Destroy()
				end)
				track2:Play()
			end
		end
	end

	local function render(_, p, p2)
		local maid4 = v4.new()
		local v17 = equipSword("Nothing")

		if p == "Sword" then
			if p2.Mesh then
				p2.Mesh.Anchored = true
				p2.Mesh:PivotTo(v17.sord:GetPivot())
				local v18 = require3(script.Drag)
				v18.attach(p2.Mesh)
				local swordForge2 = localPlayer.PlayerGui.SwordForge

				local function setAction(p3: string)
					v18.setMode(p3)

					for _, button in swordForge2.Frame.BTools:GetChildren() do
						if not button:IsA("GuiButton") then
							continue
						end

						local icon = button.Icon
						local imageColor

						if button.Name == p3 then
							imageColor = Color3.fromRGB(0, 85, 255)
						else
							imageColor = Color3.fromRGB(255, 255, 255)
						end

						icon.ImageColor3 = imageColor
					end
				end

				maid4:Add(v.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Two then
						setAction("Move")
					elseif input.KeyCode == Enum.KeyCode.Three then
						setAction("Scale")
					elseif input.KeyCode == Enum.KeyCode.Four then
						setAction("Rotate")
					elseif input.KeyCode == Enum.KeyCode.L then
						v18.toggleWorld()
					end
				end))

				for _, childName in { "Move", "Scale", "Rotate" } do
					local child = swordForge2.Frame.BTools:FindFirstChild(childName)

					if not child then
						continue
					end

					local v19 = childName
					maid4:Add(child.Activated:Connect(function()
						setAction(v19)
					end))
				end

				maid4:Add(function()
					v18.detach()
					local nothing = localPlayer.Character:FindFirstChild("Nothing")

					if not nothing then
						return
					end

					for _, child in nothing.sord:GetChildren() do
						if child.Name == "DELETE_ME" then
							child:Destroy()
						end
					end

					if not _G.SWORD_FORGE_SAVE then
						p2.Mesh:Destroy()
						return
					end

					p2.Mesh.Name = "DELETE_ME"
					p2.Mesh.Anchored = false
					p2.Mesh.Parent = nothing.sord
					local weld = Instance.new("Weld")
					weld.Part0 = p2.Mesh
					weld.Part1 = nothing.sord
					weld.C0 = p2.Mesh.CFrame:ToObjectSpace(v17.sord.CFrame)
					weld.C1 = CFrame.identity
					weld.Parent = p2.Mesh
				end)

				for _, animation in v8:GetAnimations(clone2, "Idle") do
					local track2 = animator:LoadAnimation(animation)
					maid2:Add(function()
						track2:Stop()
						track2:Destroy()
					end)
					track2:Play()
				end
			else
				sword = v11:GetSword(p2.Name)

				if not sword then
					return maid4
				end

				name2 = p2.Name
				renderSword(p2.Name)
			end

			local animations = v8:GetAnimations(
				clone2,
				{ "Parry", "SuccessParry" },
				sword and sword.AnimationType,
				sword and sword.SwordType
			)
			tracks = table.create(#animations)

			for k, animation in animations do
				local track2 = animator:LoadAnimation(animation)
				maid4:Add(function()
					track2:Stop()
					track2:Destroy()
				end)
				track2.Looped = false
				tracks[k] = track2
			end

			return maid4
		else
			if p ~= "Emote" then
				return maid4
			end

			local instance2 = v9:GetInstance(p2.Name)
			local instance3 = v10:GetInstance(p2.Name)

			if not (instance2 and instance2:GetAttribute("HideSword")) then
				renderSword(instance3 and instance3:GetAttribute("Sword"))
			end

			if ReplicatedStorage2.Misc.Emotes:FindFirstChild(p2.Name) then
				name = p2.Name
				playEmote()
				maid4:Add(maid3)
			end

			return maid4
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
		local _ = v6.ShowRoom == nil
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
			maid2:Clean()
			renderSword()
			playExplosion(p2.Name) -- equivalent call inferred; original call site unknown
		elseif p2 and v16 and v3.Dictionary.equals(v16, p2) then
			if p == "Sword" then
				parry()
			elseif p == "Emote" then
				playEmote()
			end
		else
			v16 = p2
			updateCamera() -- equivalent call inferred; original call site unknown
			maid2:Clean()

			if p2 then
				maid2:Add((render(clone.Object, p, p2)))
			end
		end
	end

	data.Info.Zoom = 0
end

function SwordForge.BeforeShow(data)
	local NPC = data.Info.NPC
	local trove = data.Trove
	task.defer(data.Info.UpdateCamera)
	local mouseLocation = nil
	local zero = Vector2.zero
	local vector2 = nil
	local v16 = 0
	local v17 = false

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
		v16 = 0
	end

	trove:Add(v.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or v17 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			mouseLocation = v:GetMouseLocation()
		end
	end))
	trove:Add(v.InputChanged:Connect(function(input, gameProcessed: boolean)
		if input.KeyCode == Enum.KeyCode.Thumbstick1 and not GamepadService.GamepadCursorEnabled then
			v16 = -thumbstickCurve(input.Position.Y)
		end

		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			applyDeltaToZoom(-input.Position.Z) -- equivalent call inferred; original call site unknown
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local v18 = thumbstickCurve(input.Position.X) -- equivalent call inferred; original call site unknown
			local Y = input.Position.Y
			vector2 = Vector3.new(v18, -thumbstickCurve(Y), 0)
		end
	end))
	trove:Add(v.InputEnded:Connect(function(input, _: boolean)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch or input.KeyCode == Enum.KeyCode.Thumbstick2 then
			clear() -- equivalent call inferred; original call site unknown
		end
	end))
	local v18 = nil

	local function roundVector2(point: Vector2, p: number)
		local v19 = 10 ^ p
		return Vector2.new(math.floor(point.X * v19) / v19, math.floor(point.Y * v19) / v19)
	end

	trove:Add(v.TouchPinch:Connect(function(list, _: number, _: number, p, _: boolean)
		v17 = p == Enum.UserInputState.Begin or p == Enum.UserInputState.Change
		mouseLocation = nil
		local v19 = list[1]
		local vector3 = Vector2.new(math.floor(v19.X * 100) / 100, math.floor(v19.Y * 100) / 100)
		local v20 = list[2]
		local v21 = (vector3 - Vector2.new(math.floor(v20.X * 100) / 100, math.floor(v20.Y * 100) / 100)).Magnitude * 0.4

		if (p == Enum.UserInputState.Change or p == Enum.UserInputState.End) and v18 then
			applyDeltaToZoom(v21 - v18) -- equivalent call inferred; original call site unknown
		end

		v18 = v21
	end))
	local zoom = data.Info.Zoom
	local instance = data.Instance
	local v19 = v2.new(createVector(0, 0, 0), 2.75, nil, 0.6)
	trove:Add(RunService.PostSimulation:Connect(function(dt: number)
		local vector3 = Vector2.new(1, gameSettings:GetCameraYInvertValue())

		if v16 ~= 0 then
			applyDeltaToZoom(v16 * dt * 60) -- equivalent call inferred; original call site unknown
		end

		if vector2 then
			zero += Vector2.new(vector2.X, vector2.Y * 0.77) * vector3 * gameSettings.GamepadCameraSensitivity * 4 * dt * 60 * 45
		end

		local zero2 = Vector2.zero

		if mouseLocation then
			zero2 += v:GetMouseLocation() - mouseLocation
		end

		local v20 = zero2 * vector3 + zero
		zoom += (data.Info.Zoom - zoom) * (dt * 0.3 * 60)
		v19.goal = Vector3.new(
			math.rad(-v20.X * gameSettings.MouseSensitivity),
			math.rad((math.clamp(v20.Y * gameSettings.MouseSensitivity, -89, 89))),
			0
		)
		local v21 = v19:update(dt)
		currentCamera.CFrame = NPC:GetPivot() * CFrame.Angles(0, v21.X, 0) * CFrame.Angles(v21.Y, 0, 0) * CFrame.new(
			data.Info.CurrentCamera ~= "Right" and 0 or (1 - -math.clamp(zoom / 6, -1, 0)) * 3,
			0.5,
			-(zoom + 12)
		) * CFrame.Angles(0, 3.141592653589793, 0)
		local v22 = zoom + 40
		local v23 = math.tan((math.rad(currentCamera.FieldOfView / 2))) * 2 * v22
		instance.Bg.Size = Vector3.new(v23 * (currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y), v23, 0)
		instance.Bg:PivotTo(currentCamera.CFrame * CFrame.new(0, 0, -v22))
		local v24 = not localPlayer.PlayerGui.SwordForge.Frame.BTools.Visible
		local swordForgeNPC = instance.ShowRoom.SwordForgeNPC
		local v25

		if v24 then
			v25 = currentCamera.CFrame * v15
		else
			v25 = CFrame.new(0, 1000000, 0)
		end

		swordForgeNPC:PivotTo(v25)
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

return SwordForge