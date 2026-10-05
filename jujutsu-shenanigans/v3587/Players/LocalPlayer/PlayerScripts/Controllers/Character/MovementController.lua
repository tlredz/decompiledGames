local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local animations = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local gameSettings = UserSettings().GameSettings
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local controller = Knit.CreateController({
	Name = "MovementController"
})
local now = tick()
_G.Shift = false
controller.LockOn = nil
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains, workspace.Spawns }
_G.MapParams = raycastParams
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Map }
local parkour = animations.Misc.Movement.Parkour
local water = sounds.Misc.Footstep.Water
local v = {
	[Enum.Material.Plastic] = "rbxassetid://5761648082",
	[Enum.Material.SmoothPlastic] = "rbxassetid://5761648082",
	[Enum.Material.Slate] = "rbxassetid://5639243489",
	[Enum.Material.Concrete] = "rbxassetid://5639243489",
	[Enum.Material.Brick] = "rbxassetid://5639243489",
	[Enum.Material.Cobblestone] = "rbxassetid://5639243489",
	[Enum.Material.Fabric] = "rbxassetid://619083295",
	[Enum.Material.Glass] = "rbxassetid://3437778169",
	[Enum.Material.Metal] = "rbxassetid://5639245164",
	[Enum.Material.DiamondPlate] = "rbxassetid://5639245590",
	[Enum.Material.Wood] = "rbxassetid://5632735811",
	[Enum.Material.WoodPlanks] = "rbxassetid://5632735811",
	[Enum.Material.Grass] = "rbxassetid://5639244517",
	[Enum.Material.Ground] = "rbxassetid://5639243992",
	[Enum.Material.Sand] = "rbxassetid://5639245918",
	[Enum.Material.Snow] = "rbxassetid://7437372937"
}
local v2 = nil
local v3 = {
	Back = createVector(0, 0, 1),
	Front = createVector(0, 0, -1),
	Left = createVector(-1, 0, 0),
	Right = createVector(1, 0, 0)
}
local v4 = nil
local v5 = {
	Vault = {
		"125187993473697",
		"95602001882956",
		"107860751460547",
		"79201532345509"
	},
	Dive = { "98195977533316", "85222050280022" },
	Slide = { "98500512116998" },
	Climb = { "104763108763761" },
	BounceR = { "94327920127463" },
	BounceL = { "113609963676386" }
}
local v6 = nil
local v7 = nil
local v8 = nil
local count = 0
local now2 = 0
local v9 = nil

for k, soundId in v do
	local clone = water:Clone()
	clone.SoundId = soundId
	clone.Parent = water.Parent
	v[k] = clone
end

function controller:Dash(p, instance, p2)
	local humanoidRootPart = instance.HumanoidRootPart

	if not humanoidRootPart then
		return
	end

	local humanoid = instance.Humanoid

	if not humanoid then
		return
	end

	v2:PlaySound(sounds.Misc.Dash, humanoidRootPart, game.SoundService.Effect)
	local v10 = v2
	local cframe = p2 == "Left" and CFrame.new() or p2 == "Back" and CFrame.Angles(0, 1.5707963267948966, 0) or p2 == "Right" and CFrame.Angles(
		0,
		3.141592653589793,
		0
	)

	if not cframe then
		if p2 == "Front" then
			cframe = CFrame.Angles(0, -1.5707963267948966, 0)
		else
			cframe = false
		end
	end

	v10:DustTrail(instance, 0.4, cframe)

	if localPlayer == p then
		local dashMultiplier = instance.Info:FindFirstChild("DashMultiplier")
		local value = dashMultiplier and dashMultiplier.Value or 1
		TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.5), {
			FieldOfView = 70
		}):Play()
		local v12 = v3[p2] * (200 * value)
		local track = humanoid:LoadAnimation((animations.Misc.Movement:FindFirstChild("Dash" .. p2)))
		track.Priority = Enum.AnimationPriority.Movement
		track:Play(nil, nil, p2 == "Back" and 0.8 or 1.8)
		now = tick()
		v4:ClearForce(instance.Torso)
		v4:ClearForce(humanoidRootPart)
		local info = instance:FindFirstChild("Info")
		local boolValue

		if info and info.Parent then
			boolValue = Instance.new("BoolValue")
			boolValue.Name = "InDash"
			boolValue.Parent = info
		else
			boolValue = nil
		end

		local bodyVelocity = Instance.new("BodyVelocity", instance.Torso)
		bodyVelocity.MaxForce = createVector(40000, 0, 40000)
		bodyVelocity.P = 400000
		bodyVelocity.Name = "MovementForce"
		Debris:AddItem(bodyVelocity, 0.4)
		v4:Swing(humanoidRootPart, bodyVelocity, 0.4, v12)
		local numberValue = bodyVelocity:FindFirstChildWhichIsA("NumberValue")

		if numberValue then
			TweenService:Create(numberValue, TweenInfo.new(0.4, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
				Value = 16 * value
			}):Play()
		end

		local renderSteppedConnection = nil
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not bodyVelocity.Parent then
				renderSteppedConnection:Disconnect()
			end

			if not (humanoid.AutoRotate ~= false and instance.Head.LocalTransparencyModifier == 0) then
				return
			end

			local lookVector = workspace.CurrentCamera.CFrame.LookVector
			humanoidRootPart.CFrame = CFrame.new(
				humanoidRootPart.Position,
				humanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
			)
		end)
		local stunChangedConnection = instance:GetAttributeChangedSignal("Stun"):Connect(function()
			if instance:GetAttribute("Stun") and bodyVelocity.Parent then
				if boolValue and boolValue.Parent then
					boolValue:Destroy()
				end

				bodyVelocity.Velocity = createVector(0, 0, 0)
				bodyVelocity:Destroy()
				track:Stop()
				renderSteppedConnection:Disconnect()
			end
		end)
		task.delay(0.4, function()
			if boolValue and boolValue.Parent then
				boolValue:Destroy()
			end

			stunChangedConnection:Disconnect()
			renderSteppedConnection:Disconnect()
		end)
	end
end

local v10 = {
	createVector(0.5, 0.5, 0.5),
	createVector(-0.5, 0.5, 0.5),
	createVector(0.5, 0.5, -0.5),
	createVector(-0.5, 0.5, -0.5),
	createVector(0.5, -0.5, 0.5),
	createVector(-0.5, -0.5, 0.5),
	createVector(0.5, -0.5, -0.5),
	createVector(-0.5, -0.5, -0.5)
}
local v11 = {}

for k, _ in v10 do
	v11[k] = v10[k].Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function accessoryLoad(accessory)
	local handle = accessory:FindFirstChild("Handle")

	if handle then
		handle.Parent = Instance.new("Folder", accessory)
	end
end

function controller:Tilt(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) or instance:GetAttribute("NoProcess") then
		return
	end

	if localPlayer.Character == instance then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

		for _, v12 in v5 do
			for _, v13 in v12 do
				parkour.AnimationId = "rbxassetid://" .. v13
				humanoid:LoadAnimation(parkour)
			end
		end

		if instance:GetAttribute("Ragdoll") > 0 and not instance:GetAttribute("NoRagdoll") then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end

		instance:GetAttributeChangedSignal("Ragdoll"):Connect(function()
			if instance:GetAttribute("NoRagdoll") then
				return
			end

			if instance:GetAttribute("Ragdoll") > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			else
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end

	for _, accessory in instance:GetChildren() do
		if not accessory:IsA("Accessory") then
			continue
		end

		accessoryLoad(accessory) -- equivalent call inferred; original call site unknown
	end

	instance.ChildAdded:Connect(function(accessory)
		if accessory:IsA("Accessory") then
			task.defer(accessoryLoad, accessory)
		end
	end)
	local now3 = 0
	local v12 = {
		["Left Arm"] = false,
		["Right Arm"] = false,
		["Left Leg"] = false,
		["Right Leg"] = false,
		Head = false
	}
	local steppedConnection = nil
	steppedConnection = RunService.Stepped:Connect(function()
		if not (humanoidRootPart and humanoidRootPart.parent) then
			steppedConnection:Disconnect()
		elseif instance:GetAttribute("Ragdoll") <= 0 or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 300 then
			for k, _ in v12 do
				v12[k] = false
			end
		else
			if not _G.Settings.RagSFX then
				return
			end

			for childName, _ in v12 do
				local child = instance:FindFirstChild(childName)

				if not child then
					continue
				end

				local lookVector = child.CFrame.LookVector
				local rightVector = child.CFrame.RightVector
				local upVector = child.CFrame.UpVector
				local v13 = false

				for i = 1, 8 do
					local v14 = lookVector * v10[i].Z + rightVector * v10[i].X + upVector * v10[i].Y
					local v15 = humanoidRootPart.Position + v14 * child.Size

					if not workspace:Raycast(v15, v14.Unit * 0.2, _G.MapParams) then
						continue
					end

					v13 = true
					break
				end

				if v13 and v12[childName] == false then
					v12[childName] = true

					if tick() - now3 > 0.075 then
						now3 = tick()
						local v14 = sounds.Impact.Players.Ragdoll_Collision["Hit" .. math.random(1, 8)]
						v2:PlaySound(v14, child, game.SoundService.Effect)
					end
				elseif not v13 and v12[childName] == true then
					v12[childName] = false
				end
			end
		end
	end)
	local rootJoint = humanoidRootPart:WaitForChild("RootJoint")
	local C1 = rootJoint.C1
	local steppedConnection2 = nil
	steppedConnection2 = RunService.Stepped:Connect(function(_, dt)
		if humanoidRootPart and rootJoint then
			local vectorToObjectSpace = humanoidRootPart.CFrame:VectorToObjectSpace(humanoidRootPart.Velocity)
			rootJoint.C1 = rootJoint.C1:lerp(
				C1 * CFrame.Angles(
					math.rad((math.clamp(vectorToObjectSpace.Z, -6, 6))),
					math.rad((math.clamp(vectorToObjectSpace.X, -6, 6))),
					(math.rad((math.clamp(vectorToObjectSpace.X, -6, 6))))
				) * CFrame.Angles(0, 0, (math.rad((math.clamp(humanoidRootPart.RotVelocity.Y, -6, 6))))),
				6 * dt
			)
		else
			steppedConnection2:Disconnect()
		end
	end)
	local v13 = {
		{ false, tick() },
		{ false, tick() }
	}
	local v14 = { instance:FindFirstChild("Left Leg"), instance:FindFirstChild("Right Leg") }
	local steppedConnection3 = nil
	steppedConnection3 = RunService.Stepped:Connect(function()
		if not (instance.Parent and v14[1] and v14[2]) then
			steppedConnection3:Disconnect()
			return
		end

		local scale = instance:GetScale()

		for k, v15 in v14 do
			local v16 = v15.Position + v15.CFrame.UpVector * (1 * scale)
			local raycastResult = workspace:Raycast(v16, v15.CFrame.UpVector * -(2 * scale + 0.3), raycastParams2)

			if raycastResult and v13[k][1] == false then
				v13[k][1] = true

				if not (tick() - v13[k][2] < 0.1) then
					v13[k][2] = tick()
					local material = raycastResult.Material

					if material == Enum.Material.Water then
						v2:PlaySound(water, humanoidRootPart, game.SoundService.Effect)
						local clone = utils.Water:Clone()
						clone.CFrame = CFrame.new(
							raycastResult.Position + raycastResult.Normal * 0.1,
							raycastResult.Position + raycastResult.Normal
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
						clone.Ring:Emit(3)
						clone.Splash:Emit(7)
						clone.Parent = workspace.Effects
						Debris:AddItem(clone, 4)
					else
						if not v[material] then
							material = Enum.Material.Plastic
						end

						if material == Enum.Material.Air then
							break
						end

						if instance:GetAttribute("Makora") or instance:GetAttribute("UltMecha") then
							v[material].Volume = 3
							v[material].PlaybackSpeed = k == 1 and 0.8 or 0.9

							if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 30 then
								CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
							end
						else
							v[material].Volume = 0.5
							v[material].PlaybackSpeed = k == 1 and 0.9 or 1
						end

						v2:PlaySound(v[material], humanoidRootPart, game.SoundService.Effect)
					end
				end
			elseif not raycastResult and v13[k][1] == true then
				v13[k][1] = false
			end
		end
	end)
end

local v12 = 2

function controller:DashRequest()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local humanoid = character.Humanoid

	if not (humanoidRootPart and humanoid) then
		return
	end

	local lookVector = workspace.CurrentCamera.CFrame.LookVector
	local cframe = CFrame.new(
		humanoidRootPart.Position,
		humanoidRootPart.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
	)
	local v13 = math.round((humanoid.MoveDirection:Dot(cframe.LookVector)))
	local v14 = math.round((humanoid.MoveDirection:Dot(cframe.RightVector)))
	local v15

	if v13 == 1 then
		v15 = "Front"
	elseif v13 == -1 then
		v15 = "Back"
	elseif v14 == 1 then
		v15 = "Right"
	elseif v14 == -1 then
		v15 = "Left"
	else
		v15 = "Front"
	end

	if character.Info:FindFirstChild("Knockback") or character:GetAttribute("Burst") and not character.Info:GetAttribute("Burst") or character.Info:FindFirstChild("ForceEsc") and character.Info.ForceEsc.Value then
		v6.Dash:Fire(v15, true)
		return
	end

	local customChase = character:FindFirstChild("CustomChar") and character.CustomChar:GetAttribute("CustomChase")

	if not customChase or v15 ~= "Front" then
		if character.Info:FindFirstChild("Block") or character.Info:FindFirstChild("Stun") or character:GetAttribute("Ragdoll") > 0 then
			return
		end

		local inSkill = character.Info:FindFirstChild("InSkill")

		if inSkill and inSkill.Value == false and not character.Info:FindFirstChild("AllowDashInSkill") then
			return
		end
	end

	if character.Info:FindFirstChild("NoDash") then
		return
	end

	local v16 = false

	if character.Info:FindFirstChild("DisableChase") then
		local target = v7:GetTarget(200)

		if target and target:GetAttribute("Ragdoll") <= 0 and not target:GetAttribute("Stun") then
			local unit = (CFrame.lookAt(humanoidRootPart.Position, target.HumanoidRootPart.Position).LookVector * createVector(
				1,
				0,
				1
			)).Unit
			local unit2 = (target.HumanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)).Unit
			local unit3 = (target.HumanoidRootPart.Velocity * createVector(1, 0, 1)).Unit
			v16 = unit:Dot(unit2) > -0.2 and unit:Dot(unit3) > 0.2 or false
		end
	end

	if v15 == "Front" and character:GetAttribute("Moveset") ~= "Naoya" and not (character.Info:FindFirstChild("DomainClash") or v16) then
		if tick() - now < 0.4 and not customChase then
			return
		end

		local item = character.Info:FindFirstChild("Item")

		if item and item:FindFirstChild("Dash") then
			v8.Dash:Fire()
		elseif customChase then
			v7:GetToolService("CustomService").Chase:Fire(v7.ExtraData.Custom())
		else
			v7:UseSetService("Chase", humanoid.FloorMaterial == Enum.Material.Air)
		end
	else
		local noSprint = character.Info:FindFirstChild("NoSprint")

		if noSprint and noSprint.Value == false and not noSprint:GetAttribute("AllowDash") then
			return
		end

		if character:GetAttribute("Moveset") == "Naoya" or character.Info:FindFirstChild("DomainClash") or v16 then
			if tick() - now < ((v16 or character.Info:FindFirstChild("DomainClash")) and 0.3 or 0.45) then
				return
			end

			if tick() - now > (character.Info:FindFirstChild("DomainClash") and 1 or 2) then
				v12 = 2
			end

			if v12 <= 0 then
				return
			end

			if not v16 then
				v12 -= 1
			end
		elseif tick() - now < 2 then
			return
		end

		v6.Dash:Fire(v15)
		self:Dash(localPlayer, character, v15)
	end
end

function controller:Parkour(instance, instance2, animator)
	if instance.Info:GetAttribute("Parkour") or instance.Info:FindFirstChild("NoParkour") then
		return
	end

	local position = instance2.Position
	local state = animator:GetState()

	if state == Enum.HumanoidStateType.Climbing then
		return
	end

	local cFrame = instance2.CFrame
	local cframe = CFrame.lookAlong(cFrame.Position, cFrame.LookVector * createVector(1, 0, 1))
	local scale = instance:GetScale()
	local lookVector = cframe.LookVector * scale
	local upVector = cframe.UpVector * scale
	local rightVector = cframe.RightVector * scale

	if state == Enum.HumanoidStateType.Running then
		if workspace:Raycast(position, upVector * -3, raycastParams2) then
			count = 0
		end

		local raycastResult = workspace:Raycast(position, lookVector * 3.5, raycastParams2)

		if raycastResult then
			local raycastResult2 = workspace:Raycast(position + upVector * 1.5, lookVector * 3.5, raycastParams2)
			local raycastResult3 = workspace:Raycast(position - upVector * 2.5, lookVector * 3.5, raycastParams2)

			if raycastResult2 or not raycastResult3 then
				local raycastResult4 = workspace:Raycast(position + upVector * 1.5, lookVector * 6, raycastParams2)
				local raycastResult5 = workspace:Raycast(position - upVector * 2.5, lookVector * 6, raycastParams2)

				if raycastResult4 and not raycastResult5 then
					local v13 = position - upVector * 2.5 + lookVector * 6

					if not workspace:Raycast(v13, upVector * 5, raycastParams2) then
						v4:ClearForce(instance.Torso)
						instance:SetAttribute("Movement", true)
						animator.HipHeight = -2
						task.delay(0.35, function()
							instance:SetAttribute("Movement", nil)
							animator.HipHeight = 0
						end)
						sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
						v2:PlaySound(sounds.Misc.Parkour.Parkour, instance2, game.SoundService.Effect)
						v6.Parkour:Fire()
						parkour.AnimationId = "rbxassetid://" .. v5.Slide[math.random(1, #v5.Slide)]
						local track = animator:LoadAnimation(parkour)
						track.Priority = Enum.AnimationPriority.Movement
						track:Play(0.06)
						v4:MovementForce(instance, lookVector * 35 - upVector * 80, lookVector * 28, 0.3)
					end
				end
			elseif workspace:Raycast(position + upVector * 4, lookVector * 3.5, raycastParams2) then
				v4:ClearForce(instance.Torso)
				instance:SetAttribute("Movement", true)
				animator.HipHeight = -2
				task.delay(0.4, function()
					instance:SetAttribute("Movement", nil)
					animator.HipHeight = 0
				end)
				sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
				v2:PlaySound(sounds.Misc.Parkour.Parkour, instance2, game.SoundService.Effect)
				v6.Parkour:Fire()
				parkour.AnimationId = "rbxassetid://" .. v5.Dive[math.random(1, #v5.Dive)]
				local track = animator:LoadAnimation(parkour)
				track.Priority = Enum.AnimationPriority.Movement
				track:Play(0.1)
				v4:MovementForce(instance, lookVector * 35 + createVector(0, 30, 0), lookVector * 28, 0.3)
			else
				local v13 = raycastResult3.Distance - raycastResult.Distance

				if -2 * scale < v13 then
					v4:ClearForce(instance.Torso)
					instance:SetAttribute("Movement", true)
					task.delay(0.3, function()
						instance:SetAttribute("Movement", nil)
					end)
					sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
					v2:PlaySound(sounds.Misc.Parkour.Parkour, instance2, game.SoundService.Effect)
					v6.Parkour:Fire()
					parkour.AnimationId = "rbxassetid://" .. v5.Vault[math.random(1, #v5.Vault)]
					local track = animator:LoadAnimation(parkour)
					track.Priority = Enum.AnimationPriority.Movement
					track:Play(0.1)
					v4:MovementForce(instance, lookVector * 24 + upVector * 40, lookVector * 24, 0.3)
				end
			end
		end
	elseif state == Enum.HumanoidStateType.Freefall then
		local raycastResult = workspace:Raycast(position, upVector * 4, raycastParams2)

		if not raycastResult then
			local position2 = position + upVector * 4 + lookVector * 3
			local raycastResult2 = workspace:Raycast(position + upVector * 4, lookVector * 3, raycastParams2)

			if raycastResult2 then
				position2 = raycastResult2.Position
			end

			local raycastResult3 = workspace:Raycast(position2 - lookVector * 0.2, upVector * -2, raycastParams2)

			if raycastResult3 then
				local v13 = true
				local raycastResult4 = workspace:Raycast(
					Vector3.new(position.X, raycastResult3.Position.Y - 0.02, position.Z),
					lookVector * 3,
					raycastParams2
				)

				if raycastResult4 then
					local v14 = (raycastResult2 and raycastResult2.Distance or 3) - raycastResult4.Distance

					if v14 < 0 then
						v14 = -v14
					end

					if v14 < 0.4 then
						v13 = false
					end
				end

				if v13 == true then
					v4:ClearForce(instance.Torso)
					instance:SetAttribute("Movement", true)
					task.delay(0.3, function()
						instance:SetAttribute("Movement", nil)
					end)
					sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
					v2:PlaySound(sounds.Misc.Parkour.Parkour, instance2, game.SoundService.Effect)
					v6.Parkour:Fire()
					parkour.AnimationId = "rbxassetid://" .. v5.Climb[math.random(1, #v5.Climb)]
					local track = animator:LoadAnimation(parkour)
					track.Priority = Enum.AnimationPriority.Movement
					track:Play(0.1)
					local v15 = upVector * 40
					local v16 = upVector * 10 + lookVector * 12
					v4:MovementForce(instance, v15, v16, 0.3)
				end
			end
		end

		local v13 = math.round((animator.MoveDirection:Dot(instance2.CFrame.RightVector)))
		local v14 = instance.Info:FindFirstChild("DomainClash") and 1 or instance:GetAttribute("Moveset") == "Goku" and 4 or 3

		if animator.Health < animator.MaxHealth * 0.33 then
			v14 -= 2
		elseif animator.Health < animator.MaxHealth * 0.66 then
			v14 -= 1
		end

		if v13 ~= 0 and count < v14 and not instance:GetAttribute("Movement") and animator.Jump == true and not raycastResult and workspace:Raycast(
			position,
			rightVector * (v13 * 3),
			raycastParams2
		) then
			v4:ClearForce(instance.Torso)
			instance:SetAttribute("Movement", true)
			count += 1
			task.delay(0.4, function()
				instance:SetAttribute("Movement", nil)
			end)
			sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
			v2:PlaySound(sounds.Misc.Parkour.Parkour, instance2, game.SoundService.Effect)
			v6.Parkour:Fire()
			local bounceR = v13 == 1 and v5.BounceR or v5.BounceL

			if scale > 1 and scale < 1.5 then
				lookVector = cframe.LookVector
				upVector = cframe.UpVector
				rightVector = cframe.RightVector
			end

			parkour.AnimationId = "rbxassetid://" .. bounceR[math.random(1, #bounceR)]
			local track = animator:LoadAnimation(parkour)
			track.Priority = Enum.AnimationPriority.Movement
			track:Play(0.1)
			local v16 = instance2.Velocity + rightVector * (v13 * 50)
			local v17 = upVector * 20 - rightVector * (v13 * 40) + lookVector * 30
			v4:MovementForce(instance, v16, v17, 0.4)
		end
	end
end

local _ = {
	Itadori = { Color3.fromRGB(85, 255, 255), Color3.fromRGB(255, 0, 0) },
	Hakari = { Color3.fromRGB(85, 255, 127) },
	Megumi = { Color3.fromRGB(31, 31, 31) },
	Mahoraga = { Color3.fromRGB(255, 255, 127) },
	Mahito = { Color3.fromRGB(170, 85, 255) },
	Choso = { Color3.fromRGB(170, 0, 0) },
	Locust = { Color3.fromRGB(0, 170, 127) },
	Yuki = { Color3.fromRGB(255, 170, 255) },
	Mechamaru = { Color3.fromRGB(225, 10, 75) }
}

function controller:KnitStart()
	for _, child in workspace.Characters:GetChildren() do
		self:Tilt(child)
	end

	workspace.Characters.ChildAdded:Connect(function(child)
		task.defer(function()
			self:Tilt(child)
		end)
	end)
	v6.Effects:Connect(function(p, p2, p3, p4)
		if p2 == "Dash" then
			self:Dash(p, p3, p4)
		elseif p2 == "Parkour" then
			local humanoidRootPart = p3.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p4 then
				sounds.Misc.Parkour.Roll.Pitch = math.random(90, 110) / 100
				v2:PlaySound(sounds.Misc.Parkour.Roll, humanoidRootPart, game.SoundService.Effect)
			else
				sounds.Misc.Parkour.Parkour.Pitch = math.random(90, 110) / 100
				v2:PlaySound(sounds.Misc.Parkour.Parkour, humanoidRootPart, game.SoundService.Effect)
			end
		elseif p2 == "Escape" then
			local humanoidRootPart = p3.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p == 1 then
				local clone = utils.DashCancel:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				clone.Ring:Emit(7)
				clone.Wind:Emit(4)
				Debris:AddItem(clone, 0.5)
			else
				v2:PlaySound(sounds.Misc.Burst2, humanoidRootPart, game.SoundService.Effect)
				v2:Flash(p3, Color3.new(1, 1, 1), 1)
				local clone = utils.DashCancel:Clone()
				clone.Position = humanoidRootPart.Position
				clone.Parent = workspace.Effects
				clone.Burst:Emit(8)
				clone.Sparks:Emit(20)
				clone.Ring:Emit(7)
				clone.Wind:Emit(4)
				Debris:AddItem(clone, 1)
				local clone2 = utils.Damage.Rage:Clone()
				clone2.Color = ColorSequence.new(Color3.new(1, 1, 1))
				clone2.Parent = p3.Torso
				Debris:AddItem(clone2, 8)
				clone2.Rate = 80
				TweenService:Create(clone2, TweenInfo.new(1), {
					Rate = 0
				}):Play()
				task.delay(1, function()
					clone2.Enabled = false
				end)
			end
		elseif p2 == "Grab" then
			local humanoidRootPart = p3.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc["Throwable" .. p], humanoidRootPart, game.SoundService.Effect)
		elseif p2 == "Hit" then
			local humanoidRootPart = p3.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v2:Flash(p3, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.DivergentFist.DivergentHit, humanoidRootPart, game.SoundService.Effect)
		end
	end)
	v6.Throwable:Connect(function(instance, instance2, cframe)
		local weld = instance.PrimaryPart:FindFirstChildWhichIsA("Weld")

		if not weld then
			return
		end

		local head = instance2:FindFirstChild("Head")

		if not head then
			return
		end

		local C1 = weld.C1
		weld.C1 = cframe:ToObjectSpace(head.CFrame)
		TweenService:Create(
			weld,
			TweenInfo.new(0.26666666666666666, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				C1 = C1
			}
		):Play()
	end)
	v6.ResetDash:Connect(function()
		now = tick() - 2
	end)
	replicatedStorage.Keybind.Combat.Dash.Pressed:Connect(function()
		if not localPlayer.Character or localPlayer.Character:IsDescendantOf(workspace.Effects) then
			return
		end

		self:DashRequest()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local character = localPlayer.Character

		if not character or character:IsDescendantOf(workspace.Effects) then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			if character.Info:FindFirstChild("NoSprint") then
				return
			end

			if tick() - now2 >= 0.2 then
				now2 = tick()
			else
				character:SetAttribute("Sprint", true)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input, _)
		local character = localPlayer.Character

		if not character or character:IsDescendantOf(workspace.Effects) then
			return
		end

		if input.KeyCode == Enum.KeyCode.W then
			character:SetAttribute("Sprint", nil)
		end
	end)
	local character = nil
	local humanoidRootPart = nil
	local humanoid = nil
	local info = nil
	local v13 = {
		Stun = 0,
		NoJump = 0,
		Block = 0,
		Emote = 0,
		NoLock = 0
	}
	local childAddedConnection = nil
	local childRemovedConnection = nil
	local PlayerModule = require(localPlayer.PlayerScripts.PlayerModule)
	local total = 0
	local clone = nil
	local highlight = nil
	RunService.Stepped:Connect(function(_, dt)
		if character and character.Parent and humanoidRootPart and humanoid and info then
			local v14 = math.clamp(1 - humanoid.Health / humanoid.MaxHealth, 0, 1) * 3
			local v15 = v14 ~= v14 and 0 or v14
			local dot = (workspace.CurrentCamera.CFrame.LookVector * createVector(1, 0, 1)).Unit:Dot(humanoid.MoveDirection)
			local S = game.StarterPlayer.CharacterWalkSpeed - v15
			local characterJumpPower = game.StarterPlayer.CharacterJumpPower
			local v16 = v13.NoJump > 0 and 0 or characterJumpPower
			local noSprint = info:FindFirstChild("NoSprint")

			if noSprint then
				character:SetAttribute("Sprint", nil)

				if noSprint:GetAttribute("S") then
					S = noSprint:GetAttribute("S")
				end
			elseif dot > 0.5 and _G.Settings.AutoRun then
				character:SetAttribute("Sprint", true)
			elseif dot < 0.5 then
				character:SetAttribute("Sprint", nil)
			end

			if v13.Stun > 0 then
				S = 0.1
				v16 = 0
			elseif v13.Block > 0 then
				S = dot < 0 and 4 or 6
				v16 = 0
			elseif character:GetAttribute("Sprint") then
				S = game.StarterPlayer.CharacterWalkSpeed * 1.375 - v15

				if not character:GetAttribute("Movement") then
					self:Parkour(character, humanoidRootPart, humanoid)
				end
			end

			local emote = info:FindFirstChild("Emote")

			if emote then
				local CollectionService = game:GetService("CollectionService")

				for _, v17 in CollectionService:GetTagged("Emote") do
					v17.Enabled = false
				end

				if emote:GetAttribute("Team") then
					total += dt

					if total >= 300 then
						total = 0
						v9.Give:Fire("Committed to the peace")
					end
				end
			else
				local CollectionService = game:GetService("CollectionService")

				for _, v17 in CollectionService:GetTagged("Emote") do
					v17.Enabled = true
				end

				total = 0
			end

			if humanoid:GetAttribute("Speed") then
				S *= humanoid:GetAttribute("Speed")
			end

			if humanoid:GetAttribute("Speed2") then
				S *= humanoid:GetAttribute("Speed2")
			end

			if humanoid:GetAttribute("Jump") then
				v16 *= humanoid:GetAttribute("Jump")
			end

			if localPlayer:GetAttribute("Spectate") == true then
				S = 0
				v16 = 0
			end

			local jumpPower = character:GetAttribute("Movement") and 0 or v16
			humanoid.WalkSpeed = S
			humanoid.JumpPower = jumpPower
			humanoidRootPart.Anchored = false
			local fill = localPlayer.PlayerGui.Main.Controls.Ultimate.Evade.Fill
			fill.Size = UDim2.new(character:GetAttribute("Evade") / 50, 0, 1, 0)

			if character:GetAttribute("Dead") then
				fill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				fill.Gradient.Enabled = true

				if clone then
					clone:Destroy()
					clone = nil
				end

				if highlight then
					highlight:Destroy()
					highlight = nil
				end
			else
				local v18 = character:GetAttribute("Burst") and not character.Info:GetAttribute("Burst")
				local knockback = character:GetAttribute("Evade") == 50 and character.Info:FindFirstChild("Knockback") or character.Info:FindFirstChild("ForceEsc") and character.Info.ForceEsc.Value

				if knockback then
					for _, child in character.Info:GetChildren() do
						if child:GetAttribute("Disable") then
							knockback = false
						end
					end
				end

				if v18 then
					fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					fill.Gradient.Enabled = false

					if not (clone and clone.Parent) then
						clone = utils.Damage.BurstIcon.BurstIcon:Clone()
						clone.Parent = humanoidRootPart
						clone.Glow:Emit(1)
						TweenService:Create(clone.Icon.Glow, TweenInfo.new(0.1), {
							ImageTransparency = 0
						}):Play()
						v2:PlaySound(sounds.Misc.Evade, humanoidRootPart, game.SoundService.Effect)
					end

					if not (highlight and highlight.Parent) then
						highlight = Instance.new("Highlight", character)
						highlight.FillColor = Color3.fromRGB(255, 255, 255)
						highlight.FillTransparency = 0.95
					end
				else
					fill.BackgroundColor3 = knockback and Color3.fromRGB(0, 174, 255) or Color3.fromRGB(0, 85, 127)
					fill.Gradient.Enabled = true

					if clone then
						clone:Destroy()
						clone = nil
					end

					if highlight then
						highlight:Destroy()
						highlight = nil
					end
				end

				if character:GetAttribute("Ragdoll") > 0 then
					local dot2 = Vector3.new(humanoidRootPart.Velocity.X, 0, humanoidRootPart.Velocity.Z).Unit:Dot(humanoid.MoveDirection)
					local v19 = not (dot2 > 0) and 1 or -(dot2 - 1)
					local v20 = humanoidRootPart.Velocity.Magnitude * 1.3 * v19
					humanoidRootPart.Velocity += humanoid.MoveDirection * v20 * dt
					local moveVector = PlayerModule:GetControls():GetMoveVector()

					if moveVector.X ~= 0 then
						humanoidRootPart.RotVelocity += workspace.CurrentCamera.CFrame.LookVector * (moveVector.X * 60 * dt)
					end

					if moveVector.Z ~= 0 then
						humanoidRootPart.RotVelocity += workspace.CurrentCamera.CFrame.RightVector * (moveVector.Z * 60 * dt)
					end
				end
			end
		else
			character = localPlayer.Character

			if not character then
				return
			end

			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			humanoid = character:FindFirstChild("Humanoid")
			info = character:FindFirstChild("Info")

			if not (humanoidRootPart and humanoid and info) then
				return
			end

			for k, _ in v13 do
				v13[k] = 0
			end

			for _, child in info:GetChildren() do
				if v13[child.Name] then
					v13[child.Name] = math.clamp(v13[child.Name] + 1, 0, 1e999)
				end
			end

			if childAddedConnection then
				childAddedConnection:Disconnect()
				childAddedConnection = nil
			end

			childAddedConnection = info.ChildAdded:Connect(function(child)
				if not v13[child.Name] then
					return
				end

				v13[child.Name] = math.clamp(v13[child.Name] + 1, 0, 1e999)
			end)

			if childRemovedConnection then
				childRemovedConnection:Disconnect()
				childRemovedConnection = nil
			end

			childRemovedConnection = info.ChildRemoved:Connect(function(child)
				if not v13[child.Name] then
					return
				end

				v13[child.Name] = math.clamp(v13[child.Name] - 1, 0, 1e999)
			end)
		end
	end)
	RunService:BindToRenderStep("Cam", Enum.RenderPriority.Camera.Value + 1, function(p)
		if not (character and character.Parent and humanoidRootPart and humanoid and info) then
			return
		end

		if not character:FindFirstChild("Head") then
			return
		end

		local currentCamera = workspace.CurrentCamera
		local magnitude = (character.Head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
		local v15

		if _G.Shift == true and magnitude > 2 then
			gameSettings.RotationType = Enum.RotationType.CameraRelative
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			v15 = v7.LastInput == "Mobile" and createVector(2, 0.75, 0) or createVector(1.75, 0, 0)
		else
			v15 = createVector(0, 0, 0)
		end

		local scale = character:GetScale()
		local v16 = v15 * scale
		local lockTarget = localPlayer.PlayerGui.Controls.LockTarget

		if self.LockOn == nil then
			lockTarget.Adornee = nil
			lockTarget.Enabled = false
			localPlayer:SetAttribute("LockOn", nil)
		else
			local humanoidRootPart2 = self.LockOn:FindFirstChild("HumanoidRootPart")

			if humanoid.Health <= 0 or not humanoidRootPart2 then
				self.LockOn = nil
				_G.Shift = false
				lockTarget.Adornee = nil
				lockTarget.Enabled = false
				localPlayer:SetAttribute("LockOn", nil)
			elseif info:FindFirstChild("NoLockOn") then
				_G.Shift = false
			elseif currentCamera.CameraType ~= Enum.CameraType.Scriptable then
				_G.Shift = true
				localPlayer:SetAttribute("LockOn", true)

				if v13.NoLock <= 0 then
					local v17 = humanoidRootPart2.Position + humanoidRootPart.CFrame.RightVector * 1.75 * scale
					local cframe = CFrame.lookAt(currentCamera.CFrame.Position, v17)
					local v18 = math.clamp(54 * p, 0, 1)
					local lerped = currentCamera.CFrame:Lerp(cframe, v18)
					currentCamera.CFrame = lerped - lerped.Position + currentCamera.CFrame.Position
					lockTarget.Adornee = humanoidRootPart2
					lockTarget.Enabled = true
				end
			end
		end

		if currentCamera.CameraSubject ~= humanoid then
			humanoid.CameraOffset = humanoid.CameraOffset:Lerp(createVector(0, 0, 0), 0.5)
			return
		end

		local v17 = _G.Settings.Follow ~= true and createVector(0, 0, 0) or (humanoidRootPart.CFrame + humanoidRootPart.CFrame.UpVector * 1.5):PointToObjectSpace(character.Head.Position) or createVector(
			0,
			0,
			0
		)

		if character:GetAttribute("Dead") then
			currentCamera.CameraSubject = character.Head
		else
			humanoid.CameraOffset = v16 + (humanoid.CameraOffset - v16):Lerp(
				v17,
				character:GetAttribute("Ragdoll") > 0 and 1 or 0.5
			)
		end
	end)
end

function controller.KnitInit(_)
	v6 = Knit.GetService("MovementService")
	v8 = Knit.GetService("ItemService")
	v9 = Knit.GetService("AchievementService")
	v7 = Knit.GetController("ToolController")
	v4 = Knit.GetController("HandicapController")
	v2 = Knit.GetController("FXController")
end

return controller