local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local spring2 = Util.Spring2
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local magnetArms = FX:WaitForChild("Magnet"):WaitForChild("MagnetArms")
local repel = FX:WaitForChild("Magnet"):WaitForChild("Passive"):WaitForChild("Repel")
local attract = FX:WaitForChild("Magnet"):WaitForChild("Passive"):WaitForChild("Attract")
local passiveAura = FX:WaitForChild("Magnet"):WaitForChild("PassiveAura")
local hitPassive = FX:WaitForChild("Magnet"):WaitForChild("HitPassive")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function PlayArmAnimation(character, value: string, p: string, p2: number)
	local magnetArms2 = character:FindFirstChild("MagnetArms")

	if not magnetArms2 then
		warn("Magnet Arms Folder missing!")
	elseif p == "Both" then
		for i = 1, 2 do
			local v = i == 1 and "Right" or "Left"
			local child = magnetArms2:FindFirstChild("Floating" .. v .. "Arm")

			if not child then
				continue
			end

			local v2 = Util.Anims:Get(child, value .. "_" .. v)

			if not v2 then
				continue
			end

			if string.find(value, "Idle") then
				v2.Priority = Enum.AnimationPriority.Idle
			end

			v2:Play()
		end
	else
		local child = magnetArms2:FindFirstChild("Floating" .. p .. "Arm")
		local v = child and Util.Anims:Get(child, value)

		if v then
			v:Play()

			if p2 then
				v:AdjustSpeed(p2)
			end
		end
	end
end

local function makeProxyPartAtBone(attachment, folder, _, cframe: CFrame?)
	local cFrame = cframe or CFrame.new()
	local part = Instance.new("Part")
	part.CastShadow = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.Locked = true
	part.Size = createVector(2, 0.2, 2)
	part.Name = "ProxyPart_" .. attachment.Name
	local attachment2 = Instance.new("Attachment")
	attachment2.CFrame = cFrame
	attachment2.Parent = part
	local rigidConstraint = Instance.new("RigidConstraint")
	rigidConstraint.Attachment0 = attachment
	rigidConstraint.Attachment1 = attachment2
	rigidConstraint.Parent = part
	part.Transparency = 1
	part.Parent = folder
	return part
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
return function(player)
	if player.Stage or player[2] and player[2] == 1 then
		local stage = player.Stage
		local proxy = player.Proxy

		if player[2] and player[2] == 1 then
			local part = player[1]
			local position = part:IsA("BasePart") and part.Position

			if not position or (currentCamera.CFrame.Position - position).Magnitude > 300 then
				return
			end

			local magnetHitAura = part.Parent:FindFirstChild("MagnetHitAura")

			if magnetHitAura then
				magnetHitAura:SetAttribute("DestroyAt", tick() + 0.33)
			else
				local clone = hitPassive.Phase1.HitAura:Clone()
				clone.Name = "MagnetHitAura"
				clone.CFrame = part.CFrame
				clone.Parent = part.Parent
				Util.Debris:AddItem(clone, 25)
				clone.Anchored = false
				clone:SetAttribute("DestroyAt", tick() + 0.33)
				local weld = Instance.new("Weld", clone)
				weld.Part0 = clone
				weld.Part1 = part

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				task.spawn(function()
					repeat
						task.wait()
					until tick() >= clone:GetAttribute("DestroyAt") or not (clone and clone:IsDescendantOf(workspace))

					if clone then
						clone:Destroy()
					end
				end)
			end
		elseif not proxy then
			warn("MagnetArmsFuctions proxy missing!")
		elseif stage == "Holding" then
			local holdingProxy = player.HoldingProxy

			if not holdingProxy then
				return
			end

			local folder = Instance.new("Folder")
			folder.Name = "HoldingSkill"
			folder.Parent = proxy

			repeat
				task.wait()
			until not (holdingProxy and holdingProxy:IsDescendantOf(workspace))

			if folder then
				folder:Destroy()
			end
		end
	else
		local character = player.Character
		local humanoid = character:WaitForChild("Humanoid")
		local noMagnetArm = player.NoMagnetArm == true

		if character:GetAttribute("MagnetPassiveDisabled") == true then
			return
		end

		local flag = false
		local proxy = player.Proxy

		if not (proxy and proxy.Parent) or (proxy:GetAttribute("PassiveDisabled") == true or proxy:FindFirstChild("DisablePassive")) then
			return
		end

		local value = 1
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin.InteractiveEffects
		local folder2 = nil
		local v = {}
		local total = 0
		local flag2 = false
		local color = Color3.fromRGB(71, 89, 255)
		local color2 = Color3.fromRGB(179, 90, 106)
		local v2 = {
			Left = {
				Model = nil,
				PositionProxy = nil,
				RotationProxy = nil,
				StrafeProxy = nil,
				LocalOffset = createVector(0, 0, 0),
				LocalOrientation = createVector(0, 0, 0),
				BobOffset = 3.141592653589793,
				FollowDelay = 0.05,
				SideSign = -1,
				StrafePushStrength = 2.75,
				StrafePushMax = 6,
				StrafeFreqBoost = 1.15,
				StrafeSpringDamping = 0.92,
				StrafeSpringInFrequency = 3.8,
				StrafeSpringOutFrequency = 2
			},
			Right = {
				Model = nil,
				PositionProxy = nil,
				RotationProxy = nil,
				StrafeProxy = nil,
				LocalOffset = createVector(0, 0, 0),
				LocalOrientation = createVector(0, 0, 0),
				BobOffset = 0,
				FollowDelay = 0.14,
				SideSign = 1,
				StrafePushStrength = 3.75,
				StrafePushMax = 9.25,
				StrafeFreqBoost = 1.15,
				StrafeSpringDamping = 0.92,
				StrafeSpringInFrequency = 3.8,
				StrafeSpringOutFrequency = 2
			}
		}
		local v3 = "Attract"
		local v4 = {}
		local children = passiveAura.Phase3.ScrapModelA:GetChildren()

		local function createFloatingScrap(i)
			local clone = children[math.random(1, #children)]:Clone()
			clone.Anchored = false
			clone.CanCollide = false
			clone.Massless = true
			clone.Size *= math.random(8, 20) / 10
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = folder
			local attachment = Instance.new("Attachment")
			attachment.Parent = clone
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Attachment0 = attachment
			alignPosition.MaxForce = 1e999
			alignPosition.Responsiveness = 20
			alignPosition.Parent = clone
			local alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.Attachment0 = attachment
			alignOrientation.MaxTorque = 1e999
			alignOrientation.Responsiveness = 15
			alignOrientation.Parent = clone
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.Size = createVector(0.1, 0.1, 0.1)
			part.CFrame = clone.CFrame
			part.Parent = folder
			local attachment2 = Instance.new("Attachment")
			attachment2.Parent = part
			alignPosition.Attachment1 = attachment2
			alignOrientation.Attachment1 = attachment2
			table.insert(v4, {
				part = clone,
				goalPart = part,
				angle = i / 12 * 3.141592653589793 * 2,
				radius = 6 + math.random() * 2,
				height = -2 + math.random() * 6,
				bobOffset = math.random() * 3.141592653589793 * 2,
				spinAxis = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)).Unit
			})
		end

		local v5 = nil

		local function CleanupArm()
			if folder then
				for _, child in pairs(folder:GetChildren()) do
					child:Destroy()
				end
			end

			if v5 then
				Util.Sound:FadeOut(v5, 0.2)
			end

			if folder2 then
				for _, v6 in pairs(v2) do
					if v6.PositionProxy then
						spring2.stop(v6.PositionProxy)
					end

					if v6.RotationProxy then
						spring2.stop(v6.RotationProxy)
					end

					if v6.StrafeProxy then
						spring2.stop(v6.StrafeProxy)
					end
				end

				folder2:Destroy()
				folder2 = nil
			end

			table.clear(v)

			for _, v6 in pairs(v2) do
				v6.Model = nil
				v6.PositionProxy = nil
				v6.RotationProxy = nil
				v6.StrafeProxy = nil
			end
		end

		local function GetHistoryCFrameInterpolated(p: number)
			if #v == 0 then
				return humanoidRootPart.CFrame
			end

			if p <= v[1].time then
				return v[1].cframe
			end

			if v[#v].time <= p then
				return v[#v].cframe
			end

			for i = 1, #v - 1 do
				local v6 = v[i]
				local v7 = v[i + 1]

				if not (v6.time <= p and p <= v7.time) then
					continue
				end

				local v8 = v7.time - v6.time
				local v9 = not (v8 > 0) and 0 or (p - v6.time) / v8
				return v6.cframe:Lerp(v7.cframe, v9)
			end

			return v[#v].cframe
		end

		local function CreateProxy(name: string, cFrame: CFrame)
			local part = Instance.new("Part")
			part.Name = name
			part.Size = createVector(1, 1, 1)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.CFrame = cFrame
			part.Parent = folder2
			return part
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function CreateNumberProxy(name: string, p: number)
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = name
			numberValue.Value = p
			numberValue.Parent = folder2
			return numberValue
		end

		local function CreateSingleArm(childName: string, child)
			local v6 = v2[childName]
			local child2 = child:FindFirstChild(childName)

			if not child2 then
				warn("Missing arm template for side:", childName)
				return
			end

			local clone = child2:Clone()
			clone.Name = "Floating" .. childName .. "Arm"
			clone.Parent = folder2
			v6.Model = clone

			if not clone.PrimaryPart then
				warn("Arm model missing PrimaryPart:", clone:GetFullName())
				return
			end

			clone:ScaleTo(0.45)

			for _, part in ipairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
			end

			local cFrame = humanoidRootPart.CFrame * CFrame.new(v6.LocalOffset) * CFrame.Angles(
				math.rad(v6.LocalOrientation.X),
				math.rad(v6.LocalOrientation.Y),
				(math.rad(v6.LocalOrientation.Z))
			)
			clone:PivotTo(cFrame)
			local name = childName .. "PositionProxy"
			local part = Instance.new("Part")
			part.Name = name
			part.Size = createVector(1, 1, 1)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.CFrame = cFrame
			part.Parent = folder2
			v6.PositionProxy = part
			local name2 = childName .. "RotationProxy"
			local part2 = Instance.new("Part")
			part2.Name = name2
			part2.Size = createVector(1, 1, 1)
			part2.Transparency = 1
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanQuery = false
			part2.CanTouch = false
			part2.CastShadow = false
			part2.CFrame = cFrame
			part2.Parent = folder2
			v6.RotationProxy = part2
			v6.StrafeProxy = CreateNumberProxy(childName .. "StrafeProxy", 0)
		end

		local function SetMode(value2)
			local v6 = value2 or "Attract"
			v3 = v6

			if character:FindFirstChild("MagnetRig") then
				local magnetRig = character.MagnetRig:FindFirstChild("MagnetRig")

				if magnetRig then
					for _, child in pairs(magnetRig:GetChildren()) do
						local surfaceAppearance = child:FindFirstChild("SurfaceAppearance")

						if surfaceAppearance then
							TweenService:Create(surfaceAppearance, TweenInfo.new(0.2), {
								EmissiveTint = v6 == "Attract" and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(
									255,
									0,
									60
								),
								EmissiveStrength = v6 == "Attract" and 80 or 40
							}):Play()
						end
					end
				end
			end

			if noMagnetArm or not (folder2 and folder2:IsDescendantOf(workspace)) then
				return
			end

			local floatingLeftArm = folder2:FindFirstChild("FloatingLeftArm")
			local floatingRightArm = folder2:FindFirstChild("FloatingRightArm")
			local neon = floatingLeftArm and floatingLeftArm:FindFirstChild("Neon")
			local neon2 = floatingRightArm and floatingRightArm:FindFirstChild("Neon")

			if neon then
				neon.Color = v6 == "Attract" and color or color2
			end

			if neon2 then
				neon2.Color = v6 == "Attract" and color or color2
			end
		end

		local function CreateFloatingArms()
			CleanupArm()
			local magnetModeProxy = character:FindFirstChild("MagnetModeProxy")
			SetMode(not magnetModeProxy and "Attract" or magnetModeProxy.Value or "Attract")

			if not noMagnetArm then
				folder2 = Instance.new("Folder")
				folder2.Name = "MagnetArms"
				folder2.Parent = character
				local child = magnetArms:WaitForChild("Tier" .. tostring(value))
				CreateSingleArm("Left", child)
				CreateSingleArm("Right", child)
				SetMode(magnetModeProxy and magnetModeProxy.Value or "Attract")
			end

			local v6 = passiveAura["Phase" .. tostring(value)]

			if value == 1 then
				v5 = Util.Sound:Play("Magnet_Hands_Idle_TierOne_01", humanoidRootPart)
			elseif value == 2 then
				v5 = Util.Sound:Play("Magnet_Hands_Idle_TierTwo_01", humanoidRootPart)
			else
				v5 = Util.Sound:Play("Magnet_Hands_Idle_TierThree_01", humanoidRootPart)
			end

			local clone = v6.MagnetAura:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = folder
			clone.Anchored = false
			local weld = Instance.new("Weld", clone)
			weld.Part0 = clone
			weld.Part1 = humanoidRootPart

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
					effect.Enabled = true
				end
			end

			if not noMagnetArm then
				for i = 1, 2 do
					local v7 = i
					task.spawn(function()
						local part

						if v7 == 1 then
							part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"]["Engine.R"], folder)
						else
							part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"]["Engine.L"], folder)
						end

						local clone2 = v6.ArmAura:Clone()
						clone2.CFrame = part.CFrame
						clone2.Parent = folder
						clone2.Anchored = false
						clone2.Massless = true
						clone2.Weld.Part0 = part

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end)

					if value ~= 3 then
						continue
					end

					local v8 = i
					task.spawn(function()
						local clone2 = v6.ArmSideAura:Clone()
						clone2.CFrame = humanoidRootPart.CFrame
						clone2.Parent = folder
						local part

						if v8 == 2 then
							part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"], folder)
						else
							part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"], folder)
						end

						clone2.Anchored = false
						clone2.Massless = true
						clone2.Weld.Part0 = part

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end)
					local v9 = i
					task.spawn(function()
						local clone2 = v6.ArmJointAura:Clone()
						clone2.CFrame = humanoidRootPart.CFrame
						clone2.Parent = folder
						local part

						if v9 == 2 then
							part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"]["Cog.R"], folder)
						else
							part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"]["Cog.L"], folder)
						end

						clone2.Anchored = false
						clone2.Massless = true
						clone2.Weld.Part0 = part

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if emitter:IsA("ParticleEmitter") then
								emitter.Enabled = true
							end
						end
					end)
				end
			end

			if value == 3 then
				for i = 1, 12 do
					createFloatingScrap(i)
				end

				task.spawn(function()
					local total2 = 0

					while clone and clone:IsDescendantOf(workspace) do
						local v7 = task.wait()
						total2 += v7

						if not (humanoidRootPart and clone and folder) then
							break
						end

						if v4 == {} then
							continue
						end

						for _, v8 in ipairs(v4) do
							if not (v8.part and v8.part.Parent) then
								continue
							end

							v8.angle += 0.5 * v7
							local v9 = math.sin(total2 * 1.5 + v8.bobOffset) * 0.8
							local vector2 = Vector3.new(
								math.cos(v8.angle) * v8.radius,
								v8.height + v9,
								math.sin(v8.angle) * v8.radius
							)
							local v10 = humanoidRootPart.Position + vector2
							local cframe = CFrame.Angles(
								total2 * v8.spinAxis.X,
								total2 * v8.spinAxis.Y,
								total2 * v8.spinAxis.Z
							)
							v8.goalPart.CFrame = CFrame.new(v10) * cframe
						end
					end

					for _, v7 in ipairs(v4) do
						if v7.part and v7.part.Parent then
							v7.part:Destroy()
						end

						if v7.goalPart and v7.goalPart.Parent then
							v7.goalPart:Destroy()
						end
					end
				end)
			end

			if not noMagnetArm then
				PlayArmAnimation(character, "MagnetTier" .. tostring(value) .. "Idle", "Both")
			end
		end

		local v6 = false
		local flag3 = false
		local v7 = false
		local flag4 = false
		local v8 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SnapArmsToRoot(duration)
			task.spawn(function()
				flag3 = true
				flag2 = false

				for _, v9 in pairs(v2) do
					if not v9.StrafeProxy then
						continue
					end

					spring2.stop(v9.StrafeProxy)
					v9.StrafeProxy.Value = 0
				end

				if duration then
					v8 = tick() + duration

					repeat
						task.wait()
						local now = tick()
					until v8 < now
				else
					v6 = true

					repeat
						task.wait()
					until v6 == false
				end

				if not v6 then
					flag3 = false
					flag2 = false
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function HardSnapToRoot()
			task.spawn(function()
				flag4 = true

				for _, v9 in pairs(v2) do
					if not v9.StrafeProxy then
						continue
					end

					spring2.stop(v9.StrafeProxy)
					v9.StrafeProxy.Value = 0
				end

				v7 = true

				repeat
					task.wait()
				until v7 == false

				flag4 = false
			end)
		end

		CreateFloatingArms()
		local v9 = {}

		local function FullCleanup()
			if flag then
				return
			end

			flag = true
			CleanupArm()

			for _, connection in pairs(v9) do
				if connection then
					connection:Disconnect()
				end
			end

			table.clear(v9)
		end

		v9.PassiveDisabledAttribute = character:GetAttributeChangedSignal("MagnetPassiveDisabled"):Connect(function()
			if character:GetAttribute("MagnetPassiveDisabled") == true then
				FullCleanup()
			end
		end)

		if character:GetAttribute("MagnetPassiveDisabled") == true then
			FullCleanup()
			return
		end

		local total2 = 0
		local transformedProxy = player.TransformedProxy
		local v10 = {}
		local v11 = nil
		local v12 = 1

		local function Footstep(p)
			local worldPosition = p.WorldPosition
			local raycastResult = workspace:Raycast(
				worldPosition + createVector(0, 2, 0),
				createVector(0, -10, 0),
				raycastParams
			)

			if not raycastResult then
				return
			end

			local normal = raycastResult.Normal
			local cframe

			if math.abs((normal:Dot(createVector(0, 1, 0)))) > 0.99 then
				cframe = CFrame.new(raycastResult.Position)
			else
				local unit = normal:Cross(createVector(1, 0, 0)).Unit
				local unit2 = unit:Cross(normal).Unit
				cframe = CFrame.fromMatrix(raycastResult.Position, unit2, normal, -unit)
			end

			local clone = repel.Footsteps.StepImpact:Clone()
			clone.CFrame = cframe
			clone.Parent = workspace._WorldOrigin

			if player.Player ~= game.Players.LocalPlayer and (workspace.CurrentCamera.CFrame.Position - cframe.Position).Magnitude < 40 then
				Util.CameraShaker:ShakeOnce(3, 4, 0.1, 0.4, createVector(1, 2, 1), createVector(1, 2, 2))
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			v12 = 1
			Util.Sound:Play("Magnet_Transformed_Misc_Footsteps_0" .. tostring(v12), cframe.Position)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
				local v13 = emitter
				task.spawn(function()
					local emitDelay = v13:GetAttribute("EmitDelay")

					if emitDelay and emitDelay ~= 0 then
						task.wait(emitDelay)
					end

					v13:Emit(v13:GetAttribute("EmitCount"))
				end)
			end
		end

		v9.Transformed = transformedProxy.Changed:Connect(function()
			if transformedProxy.Value == nil then
				if v11 then
					Util.Sound:FadeOut(v11, 0.2)
				end

				if not folder2 then
					CreateFloatingArms()
				end

				for _, connection in pairs(v10) do
					connection:Disconnect()
				end
			else
				if folder2 then
					CleanupArm()
				end

				local value2 = transformedProxy.Value
				local animationController = value2 and value2:FindFirstChild("AnimationController", true)
				local foot1L = value2:FindFirstChild("Foot1.L", true)
				local foot1R = value2:FindFirstChild("Foot1.R", true)
				v11 = Util.Sound:Play("Magnet_MISC_Giant_Mecha_Idle_01", humanoidRootPart)
				local v13 = 1

				if value2 and animationController then
					v10.animationListener = animationController.AnimationPlayed:Connect(function(object)
						if object.Name == "Transformed Magnet Mech Walk" then
							v10.footstepListener = object:GetMarkerReachedSignal("Footstep"):Connect(function()
								v13 = v13 == 1 and 2 or 1
								Footstep(v13 == 1 and foot1L or foot1R)
							end)
							object.Stopped:Once(function()
								v10.footstepListener:Disconnect()
								v13 = 1
							end)
						end
					end)
				end
			end
		end)
		v9.FloatConn = RunService.RenderStepped:Connect(function(dt)
			if flag or not (folder2 and folder2.Parent) then
				return
			end

			total2 += dt
			total += dt
			table.insert(v, {
				time = total,
				cframe = humanoidRootPart.CFrame
			})

			while v[1] and total - v[1].time > 1.5 do
				table.remove(v, 1)
			end

			local v13 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)
			local vectorToObjectSpace = humanoidRootPart.CFrame:VectorToObjectSpace(v13)
			local v14 = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

			for _, v15 in pairs(v2) do
				if not (v15.Model and v15.PositionProxy and v15.RotationProxy and v15.StrafeProxy) then
					continue
				end

				if flag4 then
					local cFrame = humanoidRootPart.CFrame * CFrame.new(v15.LocalOffset) * CFrame.Angles(
						math.rad(v15.LocalOrientation.X),
						math.rad(v15.LocalOrientation.Y),
						(math.rad(v15.LocalOrientation.Z))
					)
					v15.PositionProxy.CFrame = cFrame
					v15.RotationProxy.CFrame = cFrame.Rotation
					v15.Model:PivotTo(cFrame)
				elseif flag3 then
					local v16 = humanoidRootPart.CFrame * CFrame.new(v15.LocalOffset) * CFrame.Angles(
						math.rad(v15.LocalOrientation.X),
						math.rad(v15.LocalOrientation.Y),
						(math.rad(v15.LocalOrientation.Z))
					)
					spring2.target(v15.PositionProxy, 0.9, 7.5, {
						Position = v16.Position
					})
					spring2.target(v15.RotationProxy, 0.95, 8.5, {
						CFrame = v16.Rotation
					})
					v15.Model:PivotTo(CFrame.new(v15.PositionProxy.Position) * v15.RotationProxy.CFrame.Rotation)
					local v17 = (v15.PositionProxy.Position - v16.Position).Magnitude <= 0.08
					local _, v18 = v15.RotationProxy.CFrame.Rotation:ToObjectSpace(v16.Rotation):ToAxisAngle()
					local v19 = math.abs(v18) <= 0.03490658503988659

					if v17 and v19 then
						flag2 = true
					end
				elseif flag2 then
					local v16 = humanoidRootPart.CFrame * CFrame.new(v15.LocalOffset) * CFrame.Angles(
						math.rad(v15.LocalOrientation.X),
						math.rad(v15.LocalOrientation.Y),
						(math.rad(v15.LocalOrientation.Z))
					)
					spring2.target(v15.PositionProxy, 0.95, 10, {
						Position = v16.Position
					})
					spring2.target(v15.RotationProxy, 0.98, 11, {
						CFrame = v16.Rotation
					})
					v15.Model:PivotTo(CFrame.new(v15.PositionProxy.Position) * v15.RotationProxy.CFrame.Rotation)
				else
					local historyCFrameInterpolated = GetHistoryCFrameInterpolated(total - v15.FollowDelay)
					local v17 = math.sin(total2 * 1.5 + v15.BobOffset) * 0.8
					local v18 = not v14 and 0 or math.min(
						math.max(0, vectorToObjectSpace.X * v15.SideSign) * v15.StrafePushStrength,
						v15.StrafePushMax
					)
					local v19 = v15.StrafeProxy.Value < v18
					spring2.target(
						v15.StrafeProxy,
						v15.StrafeSpringDamping,
						v19 and v15.StrafeSpringInFrequency or v15.StrafeSpringOutFrequency,
						{
							Value = v18
						}
					)
					local value2 = v15.StrafeProxy.Value
					local v20 = math.clamp(value2 / math.max(v15.StrafePushMax, 0.001), 0, 1)
					local vector2 = Vector3.new(v20 * 0 * v15.SideSign, v20 * 0 * v15.SideSign, v20 * 16 * v15.SideSign)
					local v21 = historyCFrameInterpolated * CFrame.new(v15.LocalOffset) * CFrame.new(-v13 * 0.022) * CFrame.new(
						v15.SideSign * value2,
						v17,
						0
					)
					local v22 = historyCFrameInterpolated.Rotation * CFrame.Angles(
						math.rad(v15.LocalOrientation.X + vector2.X),
						math.rad(v15.LocalOrientation.Y + vector2.Y),
						(math.rad(v15.LocalOrientation.Z + vector2.Z))
					)
					local v23 = CFrame.new(v21.Position) * v22
					local v24 = math.clamp(((v23.Position - v15.PositionProxy.Position).Magnitude - 4) / 7, 0, 1)
					local v25 = v24 * 2.1 + 2.15 + v20 * v15.StrafeFreqBoost
					local v26 = v24 * 1.0000000000000002 + 1.2 + v20 * 0.35
					spring2.target(v15.PositionProxy, 0.92, v25, {
						Position = v23.Position
					})
					spring2.target(v15.RotationProxy, 0.98, v26, {
						CFrame = v23.Rotation
					})
					v15.Model:PivotTo(CFrame.new(v15.PositionProxy.Position) * v15.RotationProxy.CFrame.Rotation)
				end
			end
		end)
		v9.CharRemoving = player.Player.CharacterRemoving:Connect(function()
			FullCleanup()
		end)
		v9.Died = humanoid.Died:Connect(function()
			FullCleanup()
		end)
		v9.ProxyAdded = proxy.ChildAdded:Connect(function(child)
			if child.Name == "DisablePassive" or child.Name == "DestroyPassive" or child.Name == "DisableMagnetArms" then
				child:Destroy()
				FullCleanup()
			elseif flag then
				child:Destroy()
			elseif child.Name == "HoldingSkill" then
				if child:GetAttribute("HardSnap") then
					if not flag4 then
						HardSnapToRoot() -- equivalent call inferred; original call site unknown
					end
				elseif not flag4 then
					if child:GetAttribute("Duration") then
						task.delay(child:GetAttribute("Duration"), function()
							child:Destroy()
						end)
					end

					SnapArmsToRoot(child:GetAttribute("Duration")) -- equivalent call inferred; original call site unknown
				end
			elseif child.Name == "SetMode" then
				SetMode(child.Value)
			elseif child.Name == "PlayAnimation" then
				PlayArmAnimation(
					character,
					child:GetAttribute("Animation"),
					child:GetAttribute("Side"),
					child:GetAttribute("AdjustSpeed")
				)
			elseif child.Name == "TierChange" and value ~= child.Value then
				local value2 = child.Value

				if value < value2 then
					if value2 == 3 then
						Util.Sound:Play("Magnet_Arm_Increase_Size_04", humanoidRootPart)
					else
						Util.Sound:Play("Magnet_Arm_Increase_Size_01", humanoidRootPart)
					end
				else
					Util.Sound:Play("Magnet_Arm_Decrease_Size_01", humanoidRootPart)
				end

				local v13

				if v3 == "Repel" then
					v13 = repel
				else
					v13 = attract
				end

				if value2 == 1 then
					local folder3 = Instance.new("Folder")
					folder3.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(folder3, 5)
					local cFrame = humanoidRootPart.CFrame

					for i = 1, 2 do
						local clone = v13.Phase1.EndImpactModel:Clone()
						clone.Parent = folder3
						clone:ScaleTo(2)

						if i == 2 then
							clone:PivotTo(cFrame * CFrame.new(5, 0, 0))
						else
							clone:PivotTo(cFrame * CFrame.new(-5, 0, 0))
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v14 = emitter
							task.spawn(function()
								if v14:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v14:GetAttribute("EmitDelay"))
								end

								v14:Emit(v14:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
					end
				else
					local v14 = value2 == 3 and 1.5 or 1
					local folder3 = Instance.new("Folder")
					folder3.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(folder3, 5)
					local cFrame = humanoidRootPart.CFrame

					for i = 1, 2 do
						local clone = v13.Phase1.ImpactModel:Clone()
						clone.Parent = folder3
						clone:ScaleTo(v14)

						if i == 2 then
							clone:PivotTo(cFrame * CFrame.new(5, 0, 0))
						else
							clone:PivotTo(cFrame * CFrame.new(-5, 0, 0))
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v15 = emitter
							task.spawn(function()
								if v15:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v15:GetAttribute("EmitDelay"))
								end

								v15:Emit(v15:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
					end
				end

				value = child.Value
				CreateFloatingArms()
			end
		end)
		v9.ProxyRemoved = proxy.ChildRemoved:Connect(function(child)
			if child.Name == "HoldingSkill" then
				if child:GetAttribute("HardSnap") then
					v7 = false
				elseif not child:GetAttribute("Duration") then
					v6 = false
				end
			end
		end)
	end
end