local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
game:GetService("ContentProvider")
local currentCamera = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local spring2 = Util.Spring2
local RestoreDefaultColorProperties = require(ReplicatedStorage.Util.RestoreDefaultColorProperties)
local WrapColor3Constructor = require(ReplicatedStorage.Util.WrapColor3Constructor)
local Effect = require(game.ReplicatedStorage.Effect)
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

local function GetMagnetColorOwner(player, model)
	local player2 = player.Player or player.player

	if typeof(player2) == "Instance" and player2.Parent then
		return player2
	end

	if model and model:IsA("Model") then
		local playerFromCharacter = Players:GetPlayerFromCharacter(model)

		if playerFromCharacter and playerFromCharacter.Parent then
			return playerFromCharacter
		end
	end

	return nil
end

local function RecolorMagnetColor(instance, p)
	if typeof(instance) == "Instance" and instance.Parent then
		return WrapColor3Constructor(p, instance, "MagnetFruitVFXColor")
	end

	return p
end

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
				clone.Massless = true
				local player2 = player.Player or player.player

				if player2 == nil and player[3] and typeof(player[3]) == "Instance" then
					player2 = player[3]
				end

				local v = {
					Player = player2
				}
				local parent = part.Parent
				local player3 = v.Player or v.player

				if typeof(player3) ~= "Instance" or not player3.Parent then
					if parent and parent:IsA("Model") then
						player3 = Players:GetPlayerFromCharacter(parent)

						if not (player3 and player3.Parent) then
							player3 = nil
						end
					else
						player3 = nil
					end
				end

				if player3 then
					Util.SetParentOverrideWithColor(clone, part.Parent, player3, "MagnetFruitVFXColor", true)
				else
					clone.Parent = part.Parent
				end

				Util.Debris:AddItem(clone, 25)
				clone.Anchored = false
				clone:SetAttribute("DestroyAt", tick() + 0.33)
				Util.Sound:Play("Magnet_MISC_Pull_Guy_In_01", clone)
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
		local player2 = player.Player or player.player

		if typeof(player2) ~= "Instance" or not player2.Parent then
			if character and character:IsA("Model") then
				player2 = Players:GetPlayerFromCharacter(character)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		local function resolveMagnetColorOwner()
			if character:FindFirstChild("MagnetFruitVFXColor") then
				return character
			end

			local v = player
			local model = character
			local player3 = v.Player or v.player

			if typeof(player3) == "Instance" and player3.Parent then
				return player3
			end

			if model and model:IsA("Model") then
				local playerFromCharacter = Players:GetPlayerFromCharacter(model)

				if playerFromCharacter and playerFromCharacter.Parent then
					return playerFromCharacter
				end
			end

			return nil
		end

		local function isCrimsonGoldSkinEquipped()
			if typeof(player2) == "Instance" then
				local magnetFruitVFXColor = player2:FindFirstChild("MagnetFruitVFXColor")

				if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
					return true
				end
			end

			if typeof(character) == "Instance" then
				local magnetFruitVFXColor = character:FindFirstChild("MagnetFruitVFXColor")

				if magnetFruitVFXColor and magnetFruitVFXColor:GetAttribute("SkinStorageKey") == "MAGNETSKINarksteel" then
					return true
				end
			end

			local primaryPart = character and character.PrimaryPart

			if primaryPart and primaryPart:GetAttribute("MagnetSkin") == "MAGNETSKINarksteel" then
				return true
			end

			return false
		end

		local proxy = player.Proxy
		local currentTier = proxy:GetAttribute("CurrentTier") or 1
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin.InteractiveEffects
		local folder2 = nil
		local v = false
		local v2 = {}
		local v3 = false
		local v4 = {}
		local total = 0
		local flag = false
		local color = Color3.fromRGB(71, 89, 255)
		local color2 = Color3.fromRGB(179, 90, 106)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SetParentWithMagnetColor(p, parent, p2)
			local player3

			if character:FindFirstChild("MagnetFruitVFXColor") then
				player3 = character
			else
				local v5 = player
				local model = character
				player3 = v5.Player or v5.player

				if typeof(player3) ~= "Instance" or not player3.Parent then
					if model and model:IsA("Model") then
						player3 = Players:GetPlayerFromCharacter(model)

						if not (player3 and player3.Parent) then
							player3 = nil
						end
					else
						player3 = nil
					end
				end
			end

			if player3 then
				Util.SetParentOverrideWithColor(p, parent, player3, "MagnetFruitVFXColor", p2)
			else
				p.Parent = parent
			end
		end

		local v5 = {
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
		local v6 = "Attract"
		local v7 = {}
		local children

		if isCrimsonGoldSkinEquipped() then
			children = passiveAura.Phase3.ArcsteelScrapModelA:GetChildren()
		else
			children = passiveAura.Phase3.ScrapModelA:GetChildren()
		end

		local function createFloatingScrap(i)
			local clone = children[math.random(1, #children)]:Clone()
			clone.Anchored = false
			clone.CanCollide = false
			clone.Massless = true
			clone.Size *= math.random(8, 20) / 10
			clone.CFrame = humanoidRootPart.CFrame
			SetParentWithMagnetColor(clone, folder, true) -- equivalent call inferred; original call site unknown
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
			table.insert(v7, {
				part = clone,
				goalPart = part,
				angle = i / 12 * 3.141592653589793 * 2,
				radius = 6 + math.random() * 2,
				height = -2 + math.random() * 6,
				bobOffset = math.random() * 3.141592653589793 * 2,
				spinAxis = Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)).Unit
			})
		end

		local v8 = nil

		local function CleanupArm()
			if folder then
				for _, child in pairs(folder:GetChildren()) do
					child:Destroy()
				end
			end

			if v8 then
				Util.Sound:FadeOut(v8, 0.2)
			end

			if folder2 then
				for _, v9 in pairs(v5) do
					if v9.PositionProxy then
						spring2.stop(v9.PositionProxy)
					end

					if v9.RotationProxy then
						spring2.stop(v9.RotationProxy)
					end

					if v9.StrafeProxy then
						spring2.stop(v9.StrafeProxy)
					end
				end

				for _, v9 in ipairs(v2) do
					if v9.proxy then
						spring2.stop(v9.proxy)
					end
				end

				folder2:Destroy()
				folder2 = nil
			end

			table.clear(v4)
			table.clear(v2)
			v = false

			for _, v9 in pairs(v5) do
				v9.Model = nil
				v9.PositionProxy = nil
				v9.RotationProxy = nil
				v9.StrafeProxy = nil
			end
		end

		local function GetHistoryCFrameInterpolated(p: number)
			if #v4 == 0 then
				return humanoidRootPart.CFrame
			end

			if p <= v4[1].time then
				return v4[1].cframe
			end

			if v4[#v4].time <= p then
				return v4[#v4].cframe
			end

			for i = 1, #v4 - 1 do
				local v9 = v4[i]
				local v10 = v4[i + 1]

				if not (v9.time <= p and p <= v10.time) then
					continue
				end

				local v11 = v10.time - v9.time
				local v12 = not (v11 > 0) and 0 or (p - v9.time) / v11
				return v9.cframe:Lerp(v10.cframe, v12)
			end

			return v4[#v4].cframe
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

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RecolorArmModel(floatingLeftArm)
			if not (floatingLeftArm and floatingLeftArm.Parent) then
				return
			end

			RestoreDefaultColorProperties(floatingLeftArm)
			SetParentWithMagnetColor(floatingLeftArm, floatingLeftArm.Parent, true) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RecolorAuraVisuals()
			if not (folder and folder.Parent) then
				return
			end

			RestoreDefaultColorProperties(folder)
			SetParentWithMagnetColor(folder, folder.Parent, true) -- equivalent call inferred; original call site unknown
		end

		local function RecolorFloatingArms()
			if not folder2 then
				return
			end

			RecolorArmModel(folder2:FindFirstChild("FloatingLeftArm")) -- equivalent call inferred; original call site unknown
			local floatingRightArm = folder2:FindFirstChild("FloatingRightArm")

			if floatingRightArm then
				if not floatingRightArm.Parent then
					return
				end

				RestoreDefaultColorProperties(floatingRightArm)
				SetParentWithMagnetColor(floatingRightArm, floatingRightArm.Parent, true) -- equivalent call inferred; original call site unknown
			end
		end

		local function ApplyModeColorToArmNeon(p: string, p2: string)
			if not folder2 then
				return
			end

			local child = folder2:FindFirstChild("Floating" .. p .. "Arm")
			local neon = child and child:FindFirstChild("Neon")

			if not (neon and neon:IsA("BasePart") and neon.Parent) then
				return
			end

			neon.Color = p2 == "Attract" and color or color2
			SetParentWithMagnetColor(neon, neon.Parent, nil) -- equivalent call inferred; original call site unknown
		end

		local function CreateSingleArm(childName: string, child)
			local v9 = v5[childName]
			local child2 = child:FindFirstChild(childName)

			if not child2 then
				warn("Missing arm template for side:", childName)
				return
			end

			local clone = child2:Clone()
			clone.Name = "Floating" .. childName .. "Arm"
			SetParentWithMagnetColor(clone, folder2, true) -- equivalent call inferred; original call site unknown
			v9.Model = clone

			if not clone.PrimaryPart then
				warn("Arm model missing PrimaryPart:", clone:GetFullName())
				return
			end

			for _, part in ipairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
			end

			local cFrame = humanoidRootPart.CFrame * CFrame.new(v9.LocalOffset) * CFrame.Angles(
				math.rad(v9.LocalOrientation.X),
				math.rad(v9.LocalOrientation.Y),
				(math.rad(v9.LocalOrientation.Z))
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
			v9.PositionProxy = part
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
			v9.RotationProxy = part2
			v9.StrafeProxy = CreateNumberProxy(childName .. "StrafeProxy", 0)
		end

		local function SetMode(p)
			local player3

			if character:FindFirstChild("MagnetFruitVFXColor") then
				player3 = character
			else
				local v9 = player
				local model = character
				player3 = v9.Player or v9.player

				if typeof(player3) ~= "Instance" or not player3.Parent then
					if model and model:IsA("Model") then
						player3 = Players:GetPlayerFromCharacter(model)

						if not (player3 and player3.Parent) then
							player3 = nil
						end
					else
						player3 = nil
					end
				end
			end

			if character:FindFirstChild("MagnetRig") then
				local magnetRig = character.MagnetRig:FindFirstChild("MagnetRig")

				if magnetRig then
					for _, surfaceAppearance in pairs(magnetRig:GetDescendants()) do
						if not surfaceAppearance:IsA("SurfaceAppearance") then
							continue
						end

						local tweenInfo = TweenInfo.new(0.2)
						local color3 = p == "Attract" and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 60)

						if typeof(player3) == "Instance" and player3.Parent then
							color3 = WrapColor3Constructor(color3, player3, "MagnetFruitVFXColor")
						end

						TweenService:Create(surfaceAppearance, tweenInfo, {
							EmissiveTint = color3,
							EmissiveStrength = p == "Attract" and 80 or 40
						}):Play()
					end
				end

				v6 = p
			end

			if not (folder2 and folder2:IsDescendantOf(workspace)) then
				return
			end

			ApplyModeColorToArmNeon("Left", p)
			ApplyModeColorToArmNeon("Right", p)
			v6 = p
		end

		local function CreateFloatingArms()
			CleanupArm()
			folder2 = Instance.new("Folder")
			folder2.Name = "MagnetArms"
			folder2.Parent = character
			v3 = isCrimsonGoldSkinEquipped()
			local v9 = "Tier" .. tostring(currentTier)

			if v3 then
				v9 = "Tier" .. tostring(currentTier) .. "_Arcsteel"
			end

			local child = magnetArms:WaitForChild(v9)
			CreateSingleArm("Left", child)
			CreateSingleArm("Right", child)
			SetMode(character:FindFirstChild("MagnetModeProxy").Value)
			local v10 = passiveAura["Phase" .. tostring(currentTier)]
			local flag2 = false
			local v11 = {}

			local function enableAuraFx(p)
				if flag2 then
					p.Enabled = true
					return
				end

				p.Enabled = false
				table.insert(v11, p)
			end

			if currentTier == 1 then
				v8 = Util.Sound:Play("Magnet_Hands_Idle_TierOne_01", humanoidRootPart)
			elseif currentTier == 2 then
				v8 = Util.Sound:Play("Magnet_Hands_Idle_TierTwo_01", humanoidRootPart)
			else
				v8 = Util.Sound:Play("Magnet_Hands_Idle_TierThree_01", humanoidRootPart)
			end

			local clone = v10.MagnetAura:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Massless = true
			SetParentWithMagnetColor(clone, folder, true) -- equivalent call inferred; original call site unknown
			clone.Anchored = false
			local weld = Instance.new("Weld", clone)
			weld.Part0 = clone
			weld.Part1 = humanoidRootPart

			for _, effect in pairs(clone:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
					continue
				end

				if flag2 then
					effect.Enabled = true
				else
					effect.Enabled = false
					table.insert(v11, effect)
				end
			end

			for i = 1, 2 do
				local v13 = i
				task.spawn(function()
					local part

					if v13 == 1 then
						part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"]["Engine.R"], folder)
					else
						part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"]["Engine.L"], folder)
					end

					local clone2 = v10.ArmAura:Clone()
					clone2.CFrame = part.CFrame
					SetParentWithMagnetColor(clone2, folder, true) -- equivalent call inferred; original call site unknown
					clone2.Anchored = false
					clone2.Massless = true
					clone2.Weld.Part0 = part

					for i2, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if emitter:IsDescendantOf(clone2.Boost) then
							emitter.Enabled = false
						elseif flag2 then
							emitter.Enabled = true
						else
							emitter.Enabled = false
							table.insert(v11, emitter)
						end
					end
				end)

				if currentTier ~= 3 then
					continue
				end

				local v14 = i
				task.spawn(function()
					if v3 then
						local clone2 = v10.ArmSideAuraArcsteel:Clone()
						clone2.Name = "ArmSideAura"
						SetParentWithMagnetColor(clone2, folder, true) -- equivalent call inferred; original call site unknown
						local v16 = folder2
						local floatingRightArm

						if v14 == 2 then
							floatingRightArm = v16.FloatingRightArm
						else
							floatingRightArm = v16.FloatingLeftArm
						end

						local jetR = floatingRightArm:FindFirstChild("Jet.R", true)
						local jetL = floatingRightArm:FindFirstChild("Jet.L", true)
						local topJet = floatingRightArm:FindFirstChild("TopJet", true)

						local function pinToBone(parent, bone)
							if not (parent and bone) then
								return
							end

							parent.Anchored = false
							parent.Massless = true
							parent.CanCollide = false
							local cFrame

							if bone:IsA("Bone") then
								cFrame = bone.TransformedWorldCFrame
							else
								cFrame = bone.WorldCFrame
							end

							parent.CFrame = cFrame
							local attachment = Instance.new("Attachment")
							attachment.Parent = parent
							local rigidConstraint = Instance.new("RigidConstraint")
							rigidConstraint.Attachment0 = bone
							rigidConstraint.Attachment1 = attachment
							rigidConstraint.Parent = parent
						end

						local function trackBone(parent, p2)
							if not (parent and p2) then
								return
							end

							local part = Instance.new("Part")
							part.Transparency = 1
							part.Anchored = true
							part.CanCollide = false
							part.CanQuery = false
							part.CanTouch = false
							part.CastShadow = false
							part.Massless = true
							part.Size = createVector(1, 1, 1)
							part.CFrame = p2.WorldCFrame
							part.Parent = folder
							local attachment = Instance.new("Attachment")
							attachment.Parent = part
							pinToBone(parent, attachment)
							local v17 = nil
							local renderSteppedConnection = nil
							renderSteppedConnection = RunService.RenderStepped:Connect(function()
								if part.Parent and p2.Parent then
									if not v17 then
										for i2, v18 in ipairs(v2) do
											if v18.jet ~= p2 then
												continue
											end

											v17 = v18
											break
										end
									end

									if v17 and v17.proxy then
										part.CFrame = CFrame.new(v17.proxy.Value) * p2.WorldCFrame.Rotation * CFrame.new(
											0,
											1.5,
											0
										)
									else
										part.CFrame = p2.WorldCFrame
									end
								else
									part:Destroy()
									renderSteppedConnection:Disconnect()
								end
							end)
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function weldToPart(p, part)
							if not (p and part) then
								return
							end

							p.Anchored = false
							p.Massless = true
							p.CanCollide = false
							local weld2 = Instance.new("Weld")
							weld2.Part0 = part
							weld2.Part1 = p
							weld2.C0 = part.CFrame:Inverse() * p.CFrame
							weld2.Parent = p
						end

						local aura1 = clone2:FindFirstChild("Aura1")
						local aura2 = clone2:FindFirstChild("Aura2")
						local aura3 = clone2:FindFirstChild("Aura3")
						local boost = clone2:FindFirstChild("Boost")

						if boost then
							weldToPart(boost:FindFirstChild("Aura1"), aura1) -- equivalent call inferred; original call site unknown
							weldToPart(boost:FindFirstChild("Aura2"), aura2) -- equivalent call inferred; original call site unknown
							weldToPart(boost:FindFirstChild("Aura3"), aura3) -- equivalent call inferred; original call site unknown
						end

						trackBone(aura1, jetR)
						trackBone(aura2, jetL)
						pinToBone(aura3, topJet)

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if boost and emitter:IsDescendantOf(boost) then
								emitter.Enabled = false
							elseif flag2 then
								emitter.Enabled = true
							else
								emitter.Enabled = false
								table.insert(v11, emitter)
							end
						end
					else
						local clone2 = v10.ArmSideAura:Clone()
						clone2.CFrame = humanoidRootPart.CFrame
						SetParentWithMagnetColor(clone2, folder, true) -- equivalent call inferred; original call site unknown
						local part

						if v14 == 2 then
							part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"], folder)
						else
							part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"], folder)
						end

						clone2.Anchored = false
						clone2.Massless = true
						clone2.Weld.Part0 = part

						for i2, emitter in pairs(clone2:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if emitter:IsDescendantOf(clone2.Boost) then
								emitter.Enabled = false
							elseif flag2 then
								emitter.Enabled = true
							else
								emitter.Enabled = false
								table.insert(v11, emitter)
							end
						end
					end
				end)
				local v15 = i
				task.spawn(function()
					local clone2 = v10.ArmJointAura:Clone()
					clone2.CFrame = humanoidRootPart.CFrame
					SetParentWithMagnetColor(clone2, folder, true) -- equivalent call inferred; original call site unknown
					local part

					if v15 == 2 then
						part = makeProxyPartAtBone(folder2.FloatingRightArm.RootPart["Arm.R"]["Cog.R"], folder)
					else
						part = makeProxyPartAtBone(folder2.FloatingLeftArm.RootPart["Arm.L"]["Cog.L"], folder)
					end

					clone2.Anchored = false
					clone2.Massless = true
					clone2.Weld.Part0 = part

					for i2, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						if flag2 then
							emitter.Enabled = true
						else
							emitter.Enabled = false
							table.insert(v11, emitter)
						end
					end
				end)
			end

			if currentTier == 3 then
				if isCrimsonGoldSkinEquipped() then
					children = passiveAura.Phase3.ArcsteelScrapModelA:GetChildren()
				else
					children = passiveAura.Phase3.ScrapModelA:GetChildren()
				end

				for i = 1, 12 do
					createFloatingScrap(i)
				end

				task.spawn(function()
					local total2 = 0

					while clone and clone:IsDescendantOf(workspace) do
						local v13 = task.wait()
						total2 += v13

						if not (humanoidRootPart and clone and folder) then
							break
						end

						if v7 == {} then
							continue
						end

						for _, v14 in ipairs(v7) do
							if not (v14.part and v14.part.Parent) then
								continue
							end

							v14.angle += 0.5 * v13
							local v15 = math.sin(total2 * 1.5 + v14.bobOffset) * 0.8
							local vector2 = Vector3.new(
								math.cos(v14.angle) * v14.radius,
								v14.height + v15,
								math.sin(v14.angle) * v14.radius
							)
							local v16 = humanoidRootPart.Position + vector2
							local cframe = CFrame.Angles(
								total2 * v14.spinAxis.X,
								total2 * v14.spinAxis.Y,
								total2 * v14.spinAxis.Z
							)
							v14.goalPart.CFrame = CFrame.new(v16) * cframe
						end
					end

					for _, v13 in ipairs(v7) do
						if v13.part and v13.part.Parent then
							v13.part:Destroy()
						end

						if v13.goalPart and v13.goalPart.Parent then
							v13.goalPart:Destroy()
						end
					end
				end)
			end

			task.spawn(function()
				local v13 = folder2
				local children2 = {}

				for _, childName in { "FloatingLeftArm", "FloatingRightArm" } do
					local child2 = v13 and v13:FindFirstChild(childName)

					if child2 then
						table.insert(children2, child2)
					end
				end

				if #children2 > 0 then
					pcall(function() end)
				end

				if folder2 ~= v13 or not (v13 and v13.Parent) then
					return
				end

				flag2 = true

				for _, v14 in v11 do
					if v14.Parent then
						v14.Enabled = true
					end
				end
			end)
			PlayArmAnimation(character, "MagnetTier" .. tostring(currentTier) .. "Idle", "Both")
			v = currentTier == 3 and isCrimsonGoldSkinEquipped()

			if v and folder2 then
				for _, v14 in { "Left", "Right" } do
					local child2 = folder2:FindFirstChild("Floating" .. v14 .. "Arm")
					local child3 = child2 and child2:FindFirstChild(v14 == "Right" and "Arm.R" or "Arm.L", true)

					if not (child2 and child3) then
						continue
					end

					for _, childName in { "Jet.R", "Jet.L" } do
						local child4 = child2:FindFirstChild(childName, true)

						if not child4 then
							continue
						end

						local transformedWorldCFrame = child4.TransformedWorldCFrame
						local vector3Value = Instance.new("Vector3Value")
						vector3Value.Name = v14 .. childName .. "JetDrift"
						vector3Value.Value = transformedWorldCFrame.Position
						vector3Value.Parent = folder2
						local v15

						if v14 == "Left" and childName == "Jet.L" then
							v15 = true
						elseif v14 == "Right" then
							v15 = childName == "Jet.R"
						else
							v15 = false
						end

						local v16, strafeBoost

						if v15 and v14 == "Left" then
							v16 = "Left"
							strafeBoost = 0.72
						elseif v15 then
							v16 = "Right"
							strafeBoost = 0.6
						elseif v14 == "Left" then
							v16 = "Right"
							strafeBoost = 0.25
						else
							v16 = "Left"
							strafeBoost = 0.3375
						end

						table.insert(v2, {
							jet = child4,
							center = child3,
							restOffset = child3.TransformedWorldCFrame:Inverse() * transformedWorldCFrame,
							proxy = vector3Value,
							frequency = 4 * (1 + (math.random() * 2 - 1) * 0.35),
							strafeProxy = v5[v16].StrafeProxy,
							strafeSign = v5[v16].SideSign,
							strafeBoost = strafeBoost
						})
					end
				end
			end
		end

		local v9 = false
		local flag2 = false
		local v10 = false
		local flag3 = false
		local v11 = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function SnapArmsToRoot(duration)
			task.spawn(function()
				flag2 = true
				flag = false

				for _, v12 in pairs(v5) do
					if not v12.StrafeProxy then
						continue
					end

					spring2.stop(v12.StrafeProxy)
					v12.StrafeProxy.Value = 0
				end

				if duration then
					v11 = tick() + duration

					repeat
						task.wait()
						local now = tick()
					until v11 < now
				else
					v9 = true

					repeat
						task.wait()
					until v9 == false
				end

				if not v9 then
					flag2 = false
					flag = false
				end
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function HardSnapToRoot()
			task.spawn(function()
				flag3 = true

				for _, v12 in pairs(v5) do
					if not v12.StrafeProxy then
						continue
					end

					spring2.stop(v12.StrafeProxy)
					v12.StrafeProxy.Value = 0
				end

				v10 = true

				repeat
					task.wait()
				until v10 == false

				flag3 = false
			end)
		end

		CreateFloatingArms()
		local v12 = {}
		local connections = {}
		local flag4 = false
		local v13 = true

		-- equivalent calls inferred from this helper; original call sites unknown
		local function disconnectVFXColorConnections()
			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
		end

		local function FullCleanup()
			v13 = false
			CleanupArm()

			if folder then
				Util.Debris:AddItem(folder, 5)
			end

			disconnectVFXColorConnections() -- equivalent call inferred; original call site unknown

			for _, connection in pairs(v12) do
				connection:Disconnect()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RefreshFloatingArmColors()
			RecolorAuraVisuals() -- equivalent call inferred; original call site unknown
			SetMode(v6)
		end

		local function OnVFXColorUpdated()
			if isCrimsonGoldSkinEquipped() ~= v3 then
				CreateFloatingArms()
				return
			end

			RefreshFloatingArmColors() -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function scheduleVFXColorRefresh()
			if flag4 then
				return
			end

			flag4 = true
			task.defer(function()
				flag4 = false

				if not (v13 and folder and folder.Parent) then
					return
				end

				if isCrimsonGoldSkinEquipped() ~= v3 then
					CreateFloatingArms()
					return
				end

				if folder and folder.Parent then
					RestoreDefaultColorProperties(folder)
					local v14 = folder
					local parent = folder.Parent
					local v15

					if character:FindFirstChild("MagnetFruitVFXColor") then
						v15 = character
					else
						v15 = GetMagnetColorOwner(player, character)
					end

					if v15 then
						Util.SetParentOverrideWithColor(v14, parent, v15, "MagnetFruitVFXColor", true)
					else
						v14.Parent = parent
					end
				end

				SetMode(v6)
			end)
		end

		local ConnectVFXColorRefresh

		ConnectVFXColorRefresh = function()
			disconnectVFXColorConnections() -- equivalent call inferred; original call site unknown
			local player3

			if character:FindFirstChild("MagnetFruitVFXColor") then
				player3 = character
			else
				local v14 = player
				local model = character
				player3 = v14.Player or v14.player

				if typeof(player3) ~= "Instance" or not player3.Parent then
					if model and model:IsA("Model") then
						player3 = Players:GetPlayerFromCharacter(model)

						if not (player3 and player3.Parent) then
							player3 = nil
						end
					else
						player3 = nil
					end
				end
			end

			if not player3 then
				return
			end

			if not v12.VFXColorFolderAdded then
				v12.VFXColorFolderAdded = player3.ChildAdded:Connect(function(child)
					if child.Name == "MagnetFruitVFXColor" then
						ConnectVFXColorRefresh()
						scheduleVFXColorRefresh() -- equivalent call inferred; original call site unknown
					end
				end)
			end

			local magnetFruitVFXColor = player3:FindFirstChild("MagnetFruitVFXColor")

			if not magnetFruitVFXColor then
				return
			end

			table.insert(
				connections,
				magnetFruitVFXColor:GetAttributeChangedSignal("SkinStorageKey"):Connect(scheduleVFXColorRefresh)
			)
			table.insert(
				connections,
				magnetFruitVFXColor:GetAttributeChangedSignal("PaletteVersion"):Connect(scheduleVFXColorRefresh)
			)
			table.insert(connections, magnetFruitVFXColor.ChildAdded:Connect(function(child)
				if child.Name == "Default" or child.Name == "Shifted" then
					ConnectVFXColorRefresh()
					scheduleVFXColorRefresh() -- equivalent call inferred; original call site unknown
				end
			end))

			for _, childName in { "Default", "Shifted" } do
				local child = magnetFruitVFXColor:FindFirstChild(childName)

				if child then
					table.insert(connections, child.AttributeChanged:Connect(scheduleVFXColorRefresh))
				end
			end
		end

		ConnectVFXColorRefresh()
		v12.MagnetSkinAttribute = humanoidRootPart:GetAttributeChangedSignal("MagnetSkin"):Connect(scheduleVFXColorRefresh)
		local total2 = 0
		local transformedProxy = player.TransformedProxy
		local v14 = {}
		local v15 = nil
		local v16 = 1

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
			SetParentWithMagnetColor(clone, workspace._WorldOrigin, nil) -- equivalent call inferred; original call site unknown

			if player2 ~= Players.LocalPlayer and (workspace.CurrentCamera.CFrame.Position - cframe.Position).Magnitude < 40 then
				Util.CameraShaker:ShakeOnce(3, 4, 0.1, 0.4, createVector(1, 2, 1), createVector(1, 2, 2))
			end

			DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
			v16 = 1
			Util.Sound:Play("Magnet_Transformed_Misc_Footsteps_0" .. tostring(v16), cframe.Position)

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Color = ColorSequence.new(raycastResult.Instance.Color)
				local v17 = emitter
				task.spawn(function()
					local emitDelay = v17:GetAttribute("EmitDelay")

					if emitDelay and emitDelay ~= 0 then
						task.wait(emitDelay)
					end

					v17:Emit(v17:GetAttribute("EmitCount"))
				end)
			end
		end

		v12.Transformed = transformedProxy.Changed:Connect(function()
			if transformedProxy.Value == nil then
				if v15 then
					Util.Sound:FadeOut(v15, 0.2)
				end

				if not folder2 then
					CreateFloatingArms()
				end

				for _, connection in pairs(v14) do
					connection:Disconnect()
				end
			else
				if folder2 then
					CleanupArm()
				end

				local value = transformedProxy.Value
				local animationController = value and value:FindFirstChild("AnimationController", true)
				local foot1L = value:FindFirstChild("Foot1.L", true)
				local foot1R = value:FindFirstChild("Foot1.R", true)
				v15 = Util.Sound:Play("Magnet_MISC_Giant_Mecha_Idle_01", humanoidRootPart)
				local v17 = tick() + math.random(5, 10)
				v14.breathRandomizer = RunService.Heartbeat:Connect(function(_)
					local now = tick()

					if v17 <= now then
						v17 = tick() + math.random(5, 16)
						Util.Sound:Play(
							"MagnetTransformedVox_Breath_Shorter_V2_0" .. tostring(math.random(1, 2)),
							humanoidRootPart
						)
					end
				end)

				if player.Player and typeof(player.Player) ~= "table" then
					local v18 = 0
					v14.breathChatter = player.Player.Chatted:Connect(function(value2)
						local v19 = string.len(value2)
						local now = tick()

						if v18 < now then
							v18 = tick() + 1.6

							if v19 < 10 then
								Util.Sound:Play(
									"MagnetTransformedVox_Breath_Shorter_V2_0" .. tostring(math.random(1, 2)),
									humanoidRootPart
								)
							elseif v19 < 25 then
								Util.Sound:Play(
									"MagnetTransformedVox_Typing_Speak_Short_0" .. tostring(math.random(1, 2)),
									humanoidRootPart
								)
							else
								Util.Sound:Play(
									"MagnetTransformedVox_Typing_Speak_Long_0" .. tostring(math.random(1, 2)),
									humanoidRootPart
								)
							end

							if v17 then
								v17 = tick() + math.random(5, 16)
							end
						end
					end)
				end

				local v18 = 1

				if value and animationController then
					v14.animationListener = animationController.AnimationPlayed:Connect(function(object)
						if object.Name == "Transformed Magnet Mech Walk" or object.Name == "Arcsteel Transformed Magnet Mech Walk" then
							v14.footstepListener = object:GetMarkerReachedSignal("Footstep"):Connect(function()
								v18 = v18 == 1 and 2 or 1
								Footstep(v18 == 1 and foot1L or foot1R)
							end)
							object.Stopped:Once(function()
								v14.footstepListener:Disconnect()
								v18 = 1
							end)
						end
					end)
				end
			end
		end)
		v12.FloatConn = RunService.RenderStepped:Connect(function(dt)
			if not (folder2 and folder2.Parent) then
				return
			end

			total2 += dt
			total += dt
			table.insert(v4, {
				time = total,
				cframe = humanoidRootPart.CFrame
			})

			while v4[1] and total - v4[1].time > 1.5 do
				table.remove(v4, 1)
			end

			local v17 = humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)
			local vectorToObjectSpace = humanoidRootPart.CFrame:VectorToObjectSpace(v17)
			local v18 = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

			for _, v19 in pairs(v5) do
				if not (v19.Model and v19.PositionProxy and v19.RotationProxy and v19.StrafeProxy) then
					continue
				end

				if flag3 then
					local cFrame = humanoidRootPart.CFrame * CFrame.new(v19.LocalOffset) * CFrame.Angles(
						math.rad(v19.LocalOrientation.X),
						math.rad(v19.LocalOrientation.Y),
						(math.rad(v19.LocalOrientation.Z))
					)
					v19.PositionProxy.CFrame = cFrame
					v19.RotationProxy.CFrame = cFrame.Rotation
					v19.Model:PivotTo(cFrame)
				elseif flag2 then
					local v20 = humanoidRootPart.CFrame * CFrame.new(v19.LocalOffset) * CFrame.Angles(
						math.rad(v19.LocalOrientation.X),
						math.rad(v19.LocalOrientation.Y),
						(math.rad(v19.LocalOrientation.Z))
					)
					spring2.target(v19.PositionProxy, 0.9, 7.5, {
						Position = v20.Position
					})
					spring2.target(v19.RotationProxy, 0.95, 8.5, {
						CFrame = v20.Rotation
					})
					v19.Model:PivotTo(CFrame.new(v19.PositionProxy.Position) * v19.RotationProxy.CFrame.Rotation)
					local v21 = (v19.PositionProxy.Position - v20.Position).Magnitude <= 0.08
					local _, v22 = v19.RotationProxy.CFrame.Rotation:ToObjectSpace(v20.Rotation):ToAxisAngle()
					local v23 = math.abs(v22) <= 0.03490658503988659

					if v21 and v23 then
						flag = true
					end
				elseif flag then
					local v20 = humanoidRootPart.CFrame * CFrame.new(v19.LocalOffset) * CFrame.Angles(
						math.rad(v19.LocalOrientation.X),
						math.rad(v19.LocalOrientation.Y),
						(math.rad(v19.LocalOrientation.Z))
					)
					spring2.target(v19.PositionProxy, 0.95, 10, {
						Position = v20.Position
					})
					spring2.target(v19.RotationProxy, 0.98, 11, {
						CFrame = v20.Rotation
					})
					v19.Model:PivotTo(CFrame.new(v19.PositionProxy.Position) * v19.RotationProxy.CFrame.Rotation)
				else
					local historyCFrameInterpolated = GetHistoryCFrameInterpolated(total - v19.FollowDelay)
					local v21 = math.sin(total2 * 1.5 + v19.BobOffset) * 0.8
					local v22 = not v18 and 0 or math.min(
						math.max(0, vectorToObjectSpace.X * v19.SideSign) * v19.StrafePushStrength,
						v19.StrafePushMax
					)
					local v23 = v19.StrafeProxy.Value < v22
					spring2.target(
						v19.StrafeProxy,
						v19.StrafeSpringDamping,
						v23 and v19.StrafeSpringInFrequency or v19.StrafeSpringOutFrequency,
						{
							Value = v22
						}
					)
					local value = v19.StrafeProxy.Value
					local v24 = math.clamp(value / math.max(v19.StrafePushMax, 0.001), 0, 1)
					local vector2 = Vector3.new(v24 * 0 * v19.SideSign, v24 * 0 * v19.SideSign, v24 * 16 * v19.SideSign)
					local v25 = historyCFrameInterpolated * CFrame.new(v19.LocalOffset) * CFrame.new(-v17 * 0.022) * CFrame.new(
						v19.SideSign * value,
						v21,
						0
					)
					local v26 = historyCFrameInterpolated.Rotation * CFrame.Angles(
						math.rad(v19.LocalOrientation.X + vector2.X),
						math.rad(v19.LocalOrientation.Y + vector2.Y),
						(math.rad(v19.LocalOrientation.Z + vector2.Z))
					)
					local v27 = CFrame.new(v25.Position) * v26
					local v28 = math.clamp(((v27.Position - v19.PositionProxy.Position).Magnitude - 4) / 7, 0, 1)
					local v29 = v28 * 2.1 + 2.15 + v24 * v19.StrafeFreqBoost
					local v30 = v28 * 1.0000000000000002 + 1.2 + v24 * 0.35
					spring2.target(v19.PositionProxy, 0.92, v29, {
						Position = v27.Position
					})
					spring2.target(v19.RotationProxy, 0.98, v30, {
						CFrame = v27.Rotation
					})
					v19.Model:PivotTo(CFrame.new(v19.PositionProxy.Position) * v19.RotationProxy.CFrame.Rotation)
				end
			end

			if v then
				local v19 = flag3 or flag2 or flag

				for _, v20 in ipairs(v2) do
					local jet = v20.jet

					if not jet.Parent then
						continue
					end

					local cframe = jet.TransformedWorldCFrame * jet.Transform:Inverse()
					local position

					if v19 then
						position = cframe.Position
					else
						position = (v20.center.TransformedWorldCFrame * v20.restOffset).Position

						if v20.strafeProxy then
							local v21 = v20.strafeProxy.Value * v20.strafeBoost
							position += humanoidRootPart.CFrame.RightVector * v20.strafeSign * v21
						end
					end

					local v21 = v19 and 12 or v20.frequency
					spring2.target(v20.proxy, v19 and 1 or 0.9, v21, {
						Value = position
					})
					jet.Transform = CFrame.new(cframe:PointToObjectSpace(v20.proxy.Value))
				end
			end
		end)

		if player2 and player2:IsA("Player") then
			v12.CharRemoving = player2.CharacterRemoving:Connect(function()
				FullCleanup()
			end)
		end

		v12.Died = humanoid.Died:Connect(function()
			FullCleanup()
		end)
		v12.ProxyDestroyed = proxy.AncestryChanged:Once(function()
			FullCleanup()
		end)

		if player2 and Players.LocalPlayer ~= player2 then
			local v17 = 0
			local localPlayer = Players.LocalPlayer
			local v18 = {
				{
					Radius = 20,
					Power = 6
				},
				{
					Radius = 30,
					Power = 12
				},
				{
					Radius = 45,
					Power = 18
				}
			}
			v12.LoopPull = RunService.Heartbeat:Connect(function(_)
				local now = tick()

				if v17 < now then
					v17 = tick() + 0.1
					local v19 = localPlayer.Team == game.Teams.Marines
					local v20

					if typeof(player2) == "Instance" then
						v20 = player2:IsA("Player")
					else
						v20 = false
					end

					local v21 = v20 and CollectionService:HasTag(player2, "Ally" .. localPlayer.Name) or v20 and v19 and player2.Team == game.Teams.Marines
					local v22 = localPlayer:GetAttribute("InSafeZone") == true or v20 and player2:GetAttribute("InSafeZone") == true
					local pvpDisabled = localPlayer:GetAttribute("PvpDisabled") == true

					if not (v21 or v22 or pvpDisabled) then
						local character2 = localPlayer.Character
						local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")
						local humanoidRootPart3 = nil

						if typeof(player2) == "Instance" and player2:IsA("Player") then
							if player2.Character then
								humanoidRootPart3 = player2.Character:FindFirstChild("HumanoidRootPart")
							end
						elseif not v20 then
							humanoidRootPart3 = player2:FindFirstChild("HumanoidRootPart")
						end

						local magnetArms2 = character2 and character2:FindFirstChild("MagnetArms")
						local magnetRig = character2 and character2:FindFirstChild("MagnetRig")

						if humanoidRootPart2 and humanoidRootPart3 and not magnetArms2 and not magnetRig and currentTier > 1 then
							if humanoidRootPart2:GetAttribute("LastHitMagnet") and humanoidRootPart2:GetAttribute("LastHitMagnet") > tick() then
								return
							end

							local v23 = v18[currentTier] or v18[1]
							local v24 = humanoidRootPart3.Position - humanoidRootPart2.Position
							local radius = v23.Radius
							local power = v23.Power
							local maxForce = nil

							if currentTier == 1 or transformedProxy.Value then
								if transformedProxy.Value then
									radius = 80
									power = 5
									maxForce = createVector(400, 0, 400)
								else
									maxForce = createVector(2500, 0, 2500)
								end
							elseif currentTier == 2 then
								maxForce = createVector(5000, 0, 5000)
							elseif currentTier == 3 then
								maxForce = createVector(30000, 0, 30000)
							end

							if v24.Magnitude <= radius then
								local v26 = v24.Magnitude - 5

								if v26 > 0 then
									Effect.new("Magnet.Passive"):play({ humanoidRootPart2, 1, player2 })
									local v27 = math.min(power, v26 / 0.15)
									Util.BodyMover.new(humanoidRootPart2.Parent):Create("BodyVelocity", {
										Duration = 0.15,
										Velocity = v24.Unit * v27,
										MaxForce = maxForce,
										Priority = -1
									})
								end
							end
						end
					end
				end
			end)
		end

		v12.ProxyAdded = proxy.ChildAdded:Connect(function(child)
			if child.Name == "HoldingSkill" then
				if child:GetAttribute("HardSnap") then
					if not flag3 then
						HardSnapToRoot() -- equivalent call inferred; original call site unknown
					end
				elseif not flag3 then
					if child:GetAttribute("Duration") then
						task.delay(child:GetAttribute("Duration"), function()
							child:Destroy()
						end)
					end

					SnapArmsToRoot(child:GetAttribute("Duration")) -- equivalent call inferred; original call site unknown
				end
			elseif child.Name == "EnableBoost" then
				if folder then
					for _, child2 in pairs(folder:GetChildren()) do
						if not ((child2.Name == "ArmAura" or child2.Name == "ArmSideAura") and child2:FindFirstChild("Boost")) then
							continue
						end

						local folder3 = child2
						pcall(function()
							for i, emitter in pairs(folder3:GetDescendants()) do
								if emitter:IsA("ParticleEmitter") and emitter:IsDescendantOf(folder3.Boost) then
									emitter.Enabled = true
								end
							end

							task.delay(0.2, function()
								for i, emitter in pairs(folder3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") and emitter:IsDescendantOf(folder3.Boost) then
										emitter.Enabled = false
									end
								end
							end)
						end)
					end

					if child:GetAttribute("Jump") then
						local magnetArms2 = character:FindFirstChild("MagnetArms")

						if magnetArms2 then
							local floatingLeftArm = magnetArms2:FindFirstChild("FloatingLeftArm")
							local v17 = floatingLeftArm and Util.Anims:Get(floatingLeftArm, "MagnetArms Jump L")

							if v17 then
								v17:Play()
							end
						else
							warn("Magnet Arms Folder missing!")
						end

						local magnetArms3 = character:FindFirstChild("MagnetArms")

						if not magnetArms3 then
							warn("Magnet Arms Folder missing!")
							return
						end

						local floatingRightArm = magnetArms3:FindFirstChild("FloatingRightArm")
						local v17 = floatingRightArm and Util.Anims:Get(floatingRightArm, "MagnetArms Jump R")

						if v17 then
							v17:Play()
						end
					end
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
			elseif child.Name == "TierChange" and currentTier ~= child.Value then
				local value = child.Value

				if currentTier < value then
					if value == 3 then
						Util.Sound:Play("Magnet_Arm_Increase_Size_04", humanoidRootPart)
					else
						Util.Sound:Play("Magnet_Arm_Increase_Size_01", humanoidRootPart)
					end
				else
					Util.Sound:Play("Magnet_Arm_Decrease_Size_01", humanoidRootPart)
				end

				local v17

				if v6 == "Repel" then
					v17 = repel
				else
					v17 = attract
				end

				if value == 1 then
					local folder3 = Instance.new("Folder")
					folder3.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(folder3, 5)
					local cFrame = humanoidRootPart.CFrame

					for i = 1, 2 do
						local clone = v17.Phase1.EndImpactModel:Clone()
						SetParentWithMagnetColor(clone, folder3, nil) -- equivalent call inferred; original call site unknown
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

							local v18 = emitter
							task.spawn(function()
								if v18:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v18:GetAttribute("EmitDelay"))
								end

								v18:Emit(v18:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
					end
				else
					local v18 = value == 3 and 1.5 or 1
					local folder3 = Instance.new("Folder")
					folder3.Parent = workspace._WorldOrigin
					Util.Debris:AddItem(folder3, 5)
					local cFrame = humanoidRootPart.CFrame

					for i = 1, 2 do
						local clone = v17.Phase1.ImpactModel:Clone()
						SetParentWithMagnetColor(clone, folder3, nil) -- equivalent call inferred; original call site unknown
						clone:ScaleTo(v18)

						if i == 2 then
							clone:PivotTo(cFrame * CFrame.new(5, 0, 0))
						else
							clone:PivotTo(cFrame * CFrame.new(-5, 0, 0))
						end

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v19 = emitter
							task.spawn(function()
								if v19:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v19:GetAttribute("EmitDelay"))
								end

								v19:Emit(v19:GetAttribute("EmitCount"))
							end)
						end

						DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown
					end
				end

				currentTier = child.Value
				CreateFloatingArms()
			end
		end)
		v12.ProxyRemoved = proxy.ChildRemoved:Connect(function(child)
			if child.Name == "HoldingSkill" then
				if child:GetAttribute("HardSnap") then
					local v17 = false

					for _, child2 in pairs(proxy:GetChildren()) do
						if not (child2 ~= child and child2.Name == "HoldingSkill" and child2:GetAttribute("HardSnap")) then
							continue
						end

						v17 = true
						break
					end

					if not v17 then
						v10 = false
					end
				elseif not child:GetAttribute("Duration") then
					v9 = false
				end
			end
		end)
	end
end