local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
local vfxUtility = require(ReplicatedStorage.CAM.Client.Modules.Effects.vfxUtility)
local OuwCraters = require(ReplicatedStorage.CAM.Client.Modules.Effects.Craters.OuwCraters)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local RaycastHelper = require(ReplicatedStorage.CAM.Global.RaycastHelper)
local Config = require(ReplicatedStorage.Skills.Wind["Idaten Typhoon"].Config)
local localPlayer = Players.LocalPlayer
return function(instance, p: string, data, instance2, value, cframe, owner, p2)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	if p == "Cancel" then
		local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)
		local idatenTyphoonFOV = child and child:FindFirstChild("IdatenTyphoonFOV")

		if idatenTyphoonFOV ~= nil then
			idatenTyphoonFOV:Destroy()
		end

		for _, child2 in Lighting:GetChildren() do
			if string.sub(child2.Name, 1, 22) == "IdatenTyphoonCutscene_" then
				child2:Destroy()
			end
		end
	elseif p == "Start" then
		vfxUtility.PlaySound(script.Parent, "PS2windGENERALinitiate", humanoidRootPart, true)
		local has_Blade = instance:FindFirstChild("Has_Blade", true)
		local blade

		if has_Blade ~= nil then
			blade = has_Blade.Parent:FindFirstChild("Blade")
		end

		if blade ~= nil then
			local clone = script.PartInit:Clone()
			clone.Parent = blade
			clone.Weld.Part1 = blade
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone, 2)
		end

		for _, child in ipairs(script.TorsoParticles:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = instance.UpperTorso
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone, 2)
		end

		Cam_Shaker(humanoidRootPart.Position, "activate_shakelessaggresive")
	elseif p == "Jump" then
		vfxUtility.PlaySound(script.Sound, "PS2windIDATENTYPHOONvar1JUMP", humanoidRootPart, true)
		local clone = script.Jump:Clone()
		clone.Parent = workspace.Debree
		clone:PivotTo(data)
		local raycastResult = workspace:Raycast(data.Position, data.UpVector * -11, RaycastHelper.Crater)
		local v = raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
		Ouwmit.Emit(clone.Jump, Ouwmit.Owned(instance, v))
		DebrisModule:AddItem(clone, 2)
		Cam_Shaker(humanoidRootPart.Position, "activate_shake")
		task.wait(0.1)
		Ouwmit.Emit(clone.Air, Ouwmit.Owned(instance, v))
	elseif p == "Cutscene" then
		if data == "Close" then
			local v

			if owner == nil or localPlayer.Character == nil then
				v = false
			else
				v = table.find(owner, localPlayer.Character) ~= nil
			end

			local playSound = vfxUtility.PlaySound
			local sound = script.Sound
			local v3

			if v then
				v3 = workspace.CurrentCamera or humanoidRootPart
			else
				v3 = humanoidRootPart
			end

			playSound(sound, "PS2windIDATENTYPHOONvar2CINEMATIC", v3, true)

			if v then
				local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(localPlayer.Name)

				if child ~= nil then
					local numberValue = Instance.new("NumberValue")
					numberValue.Name = "IdatenTyphoonFOV"
					CollectionService:AddTag(numberValue, "FOV")
					numberValue.Value = 50
					numberValue.Parent = child
					DebrisModule:AddItem(numberValue, Config.V1_CUTSCENE_DURATION)
					local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						humanoid.Died:Once(function()
							if numberValue.Parent ~= nil then
								numberValue:Destroy()
							end
						end)
					end
				end
			end

			local configuration = Instance.new("Configuration")
			configuration.Name = `{instance.Name}_IdatenTyphoon_Cutscene`
			configuration.Parent = workspace.Debree
			DebrisModule:AddItem(configuration, Config.V1_CUTSCENE_DURATION + 5)
			local part = nil

			local function cameraWeld(instance3, p3: number)
				if configuration.Parent == nil or not v or part == nil then
					return
				end

				local clone = instance3:Clone()
				clone.Weld.Part0 = part
				clone.Parent = configuration
				Ouwmit.Emit(clone, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone, p3)
			end

			task.spawn(function()
				local v5 = value or workspace.Debree:WaitForChild(instance2, 3)
				local bone = v5 and v5:WaitForChild("Bone", 3)

				if bone == nil or configuration.Parent == nil then
					return
				end

				part = bone
				cameraWeld(script.Cutscene.BeamLightPart, 4)
				cameraWeld(script.Cutscene.BeamWind, 4)
			end)
			local lowerTorso = instance:FindFirstChild("LowerTorso") or humanoidRootPart
			local clone = script.Cutscene.Aura:Clone()
			local auraVFX = clone.AuraVFX
			auraVFX.Anchored = false
			auraVFX.CFrame = lowerTorso.CFrame
			local weld = Instance.new("Weld")
			weld.Part0 = lowerTorso
			weld.Part1 = auraVFX
			weld.Parent = auraVFX
			clone.Parent = configuration
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			DebrisModule:AddItem(clone, 5)

			if v then
				local clone2 = script.Cutscene.Screenspeedlines:Clone()
				clone2.Parent = configuration
				Ouwmit.Emit(clone2, {
					Owner = owner
				})
				DebrisModule:AddItem(clone2, 4)
			end

			local function lightingEffect(className: string, items)
				if not v then
					return
				end

				local instance3 = Instance.new(className)
				instance3.Name = "IdatenTyphoonCutscene_" .. className
				instance3.Parent = Lighting
				local v5 = 0
				local v6 = {}

				for _, item in items do
					local v7 = item[1]
					local v8 = item[2]
					v5 = math.max(v5, v7)

					for k, v9 in v8 do
						v6[k] = v6[k] or {}
						table.insert(v6[k], { v7, v9 })
					end
				end

				for k, list2 in v6 do
					table.sort(list2, function(a, b)
						return a[1] < b[1]
					end)
					local v7 = list2[1][1]
					local v8 = list2[1][2]

					if v7 <= 0 then
						instance3[k] = v8
					else
						local v9 = k
						local v10 = v8
						task.delay(v7, function()
							if instance3.Parent ~= nil then
								instance3[v9] = v10
							end
						end)
					end

					for i = 2, #list2 do
						local v9 = list2[i - 1][1]
						local v12 = list2[i][1]
						local v14 = k
						local v15 = list2[i][2]
						task.delay(v9, function()
							if instance3.Parent == nil then
								return
							end

							TweenService:Create(
								instance3,
								TweenInfo.new(math.max(v12 - v9, 0), Enum.EasingStyle.Linear),
								{
									[v14] = v15
								}
							):Play()
						end)
					end
				end

				DebrisModule:AddItem(instance3, (math.max(Config.V1_CUTSCENE_DURATION, v5)))
				return instance3
			end

			lightingEffect("DepthOfFieldEffect", {
				{
					0,
					{
						FocusDistance = 0.05,
						InFocusRadius = 10,
						FarIntensity = 0.75,
						NearIntensity = 0.75
					}
				},
				{
					0.9666666666666667,
					{
						FocusDistance = 5,
						InFocusRadius = 30
					}
				}
			})
			lightingEffect("ColorCorrectionEffect", {
				{
					0,
					{
						TintColor = Color3.fromRGB(0, 0, 0),
						Brightness = -0.8,
						Contrast = 0.7,
						Saturation = 0.5
					}
				},
				{
					0.3333333333333333,
					{
						TintColor = Color3.fromRGB(255, 255, 255)
					}
				},
				{
					0.8333333333333334,
					{
						Brightness = 0.03,
						Contrast = 0.1,
						Saturation = 0.3
					}
				},
				{
					0.9666666666666667,
					{
						Brightness = -0.5,
						Contrast = 0.7,
						Saturation = 0.3
					}
				},
				{
					1.3333333333333333,
					{
						Brightness = 0.03,
						Contrast = 0.1,
						Saturation = 0.3
					}
				},
				{
					1.6,
					{
						Brightness = -0.5,
						Contrast = 0.7,
						Saturation = 0.3
					}
				},
				{
					1.9666666666666666,
					{
						Brightness = 0.03,
						Contrast = 0.1,
						Saturation = 0.3
					}
				},
				{
					2.3666666666666667,
					{
						Brightness = -0.15,
						Contrast = 0.5,
						Saturation = 0.3
					}
				},
				{
					2.45,
					{
						Brightness = 0
					}
				},
				{
					2.7,
					{
						Brightness = -0.12
					}
				},
				{
					2.783333333333333,
					{
						Brightness = 0
					}
				},
				{
					3.033333333333333,
					{
						Brightness = -0.12
					}
				},
				{
					3.1166666666666667,
					{
						Brightness = 0
					}
				},
				{
					3.3666666666666667,
					{
						Brightness = -0.12
					}
				},
				{
					3.466666666666667,
					{
						Brightness = 0
					}
				},
				{
					3.6999999999999997,
					{
						Brightness = -0.12
					}
				},
				{
					3.783333333333333,
					{
						Brightness = 0
					}
				},
				{
					4.033333333333333,
					{
						Brightness = -0.12
					}
				},
				{
					4.116666666666666,
					{
						Brightness = 0
					}
				},
				{
					4.366666666666666,
					{
						Brightness = -0.12
					}
				},
				{
					4.45,
					{
						Brightness = 0
					}
				},
				{
					4.533333333333333,
					{
						Brightness = -0.12,
						Contrast = 0.1,
						Saturation = 0.3
					}
				},
				{
					4.616666666666666,
					{
						Brightness = 0,
						Contrast = 0.1,
						Saturation = 0.3
					}
				},
				{
					4.7,
					{
						Brightness = 0.8,
						Saturation = 0.3
					}
				},
				{
					5.083333333333333,
					{
						Brightness = 0.03,
						Contrast = 0.1,
						Saturation = 0.3
					}
				}
			})

			local function screenEmit(instance3)
				if configuration.Parent == nil or not v then
					return
				end

				local clone2 = instance3:Clone()
				clone2.Parent = configuration
				Ouwmit.Emit(clone2, {
					Owner = owner
				})
				DebrisModule:AddItem(clone2, 1.5)
			end

			local function fireSlashes(cframe2: CFrame)
				if configuration.Parent == nil then
					return
				end

				local position = (instance:FindFirstChild("LowerTorso") or humanoidRootPart).Position

				for _, v5 in owner or {} do
					if not (v5 ~= instance and v5.Parent ~= nil) then
						continue
					end

					local lowerTorso2 = v5:FindFirstChild("LowerTorso") or v5:FindFirstChild("HumanoidRootPart")

					if lowerTorso2 == nil then
						continue
					end

					local position2 = lowerTorso2.Position

					if (position2 - position).Magnitude < 0.001 then
						continue
					end

					local clone2 = script.Projectile.SlashTravel:Clone()
					local cFrame = CFrame.lookAt(position, position2) * cframe2
					clone2.Root.Anchored = true
					clone2.Root.Massless = false
					clone2.Root.CFrame = cFrame
					clone2.Parent = configuration
					Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
					local tween = TweenService:Create(clone2.Root, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
						CFrame = CFrame.new(position2) * cFrame.Rotation
					})
					tween.Completed:Once(function()
						if clone2.Parent == nil then
							return
						end

						Ouwmit.Enable(clone2, false)
						DebrisModule:AddItem(clone2, 2)
					end)
					tween:Play()
				end
			end

			local cframe2 = CFrame.Angles(0, 0, 1.5707963267948966)

			local function userSlash(cframe3: CFrame)
				if configuration.Parent == nil then
					return
				end

				local lowerTorso2 = instance:FindFirstChild("LowerTorso") or humanoidRootPart
				local clone2 = script.Cutscene.UserSlash:Clone()
				clone2:PivotTo(lowerTorso2.CFrame * cframe3)
				clone2.Parent = configuration
				Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
			end

			task.delay(0.9166666666666666, function()
				if configuration.Parent == nil then
					return
				end

				screenEmit(script.Cutscene.SlashEmit)
				screenEmit(script.Cutscene.ScreenEmit)
				cameraWeld(script.Cutscene.BeamWind, 4)
				userSlash(cframe2)
				fireSlashes(cframe2)
			end)
			task.delay(1.6833333333333333, function()
				userSlash(CFrame.identity)
			end)
			task.delay(1.7166666666666666, function()
				fireSlashes(CFrame.identity)
			end)

			local function impactAtVictims(instance3)
				if configuration.Parent == nil then
					return
				end

				for _, v5 in owner or {} do
					if not (v5 ~= instance and v5.Parent ~= nil) then
						continue
					end

					local lowerTorso2 = v5:FindFirstChild("LowerTorso") or v5:FindFirstChild("HumanoidRootPart")

					if lowerTorso2 == nil then
						continue
					end

					local position = lowerTorso2.Position
					local v6 = (instance:FindFirstChild("LowerTorso") or humanoidRootPart).Position - position
					local unit

					if v6.Magnitude > 0.001 then
						unit = v6.Unit
					else
						unit = -humanoidRootPart.CFrame.LookVector
					end

					local clone2 = instance3:Clone()
					clone2:PivotTo(CFrame.lookAt(position, position + unit))
					clone2.Parent = configuration
					Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				end
			end

			task.delay(1.3333333333333333, function()
				impactAtVictims(script.Cutscene.SlashImpact)
				screenEmit(script.Cutscene.ScreenEmit)
			end)
			task.delay(1.9666666666666666, function()
				impactAtVictims(script.Cutscene.SlashImpact2)
				screenEmit(script.Cutscene.ScreenEmit)
			end)
			task.delay(2.3666666666666667, function()
				if configuration.Parent == nil then
					return
				end

				for _, v5 in owner or {} do
					if not (v5 ~= instance and v5.Parent ~= nil) then
						continue
					end

					local lowerTorso2 = v5:FindFirstChild("LowerTorso") or v5:FindFirstChild("HumanoidRootPart")

					if lowerTorso2 == nil then
						continue
					end

					local clone2 = script.Cutscene.Barrage:Clone()
					clone2:PivotTo(CFrame.new(lowerTorso2.Position + createVector(0, 2.5, 0)) * clone2:GetPivot().Rotation)
					clone2.Parent = configuration
					Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				end

				impactAtVictims(script.Cutscene.BarrageImpact)
				cameraWeld(script.Cutscene.BeamWindBarrage, 4)
				cameraWeld(script.Cutscene.BarrageBeams, 4)
			end)
			task.delay(2.783333333333333, screenEmit, script.Cutscene.ScreenEmit2)
			task.delay(3.466666666666667, screenEmit, script.Cutscene.ScreenEmit2)
			task.delay(4.7, function()
				screenEmit(script.Cutscene.ScreenEmit)
				screenEmit(script.Cutscene.ScreenEmit2)
			end)
			task.delay(4.716666666666667, function()
				if configuration.Parent == nil then
					return
				end

				local position = (humanoidRootPart.CFrame * CFrame.new(
					0,
					-Config.V1_END_IMPACT_DROP,
					-Config.V1_END_IMPACT_FORWARD
				)).Position
				local raycastResult = workspace:Raycast(
					position + createVector(0, 10, 0),
					createVector(-0, -30, -0),
					RaycastHelper.Crater
				)

				if raycastResult ~= nil then
					position = raycastResult.Position + createVector(0, 0.5, 0)
				end

				local clone2 = script.Cutscene.EndImpact:Clone()
				clone2:PivotTo(CFrame.new(position) * clone2:GetPivot().Rotation)
				clone2.Parent = configuration
				local emit = Ouwmit.Emit
				local owned = Ouwmit.Owned
				local v6

				if raycastResult then
					v6 = vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil
				end

				emit(clone2, owned(instance, v6))

				if raycastResult ~= nil then
					local cframe3 = CFrame.new(raycastResult.Position)
					OuwCraters.Scales({
						Center = cframe3,
						Radius = 14,
						Count = 10,
						ScaleMult = 1.2,
						OffsetMargin = 5
					})
					OuwCraters.Scales({
						Center = cframe3,
						Radius = 24,
						Count = 14,
						ScaleMult = 1.5,
						OffsetMargin = 8
					})
				end
			end)
		elseif data == "Far" then
			vfxUtility.PlaySound(script.Sound, "PS2windIDATENTYPHOONvar1COMBO", humanoidRootPart, true)

			if instance2 == nil or value == nil or cframe == nil then
				return
			end

			local configuration = Instance.new("Configuration")
			configuration.Parent = workspace.Debree
			configuration.Name = "idatentyphoon_final_explosion"
			DebrisModule:AddItem(configuration, 6.5)
			local clone = script.Projectile.BeforeTeleport:Clone()
			clone:PivotTo(p2 or value)
			clone.Parent = configuration
			Ouwmit.Emit(clone, Ouwmit.Owned(instance))
			task.wait(0.1)
			local raycastResult = workspace:Raycast(
				cframe.Position + createVector(0, 2, 0),
				createVector(-0, -25, -0),
				RaycastHelper.Crater
			)
			local clone2 = script.Projectile.TeleportImpact:Clone()

			if raycastResult == nil then
				clone2:PivotTo(cframe)
			else
				clone2:PivotTo(CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)) * cframe.Rotation)
			end

			clone2.Parent = configuration
			Ouwmit.Emit(
				clone2,
				Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
			)
			task.wait(0.1)
			local raycastResult2 = workspace:Raycast(
				instance2.Position + createVector(0, 2, 0),
				createVector(-0, -25, -0),
				RaycastHelper.Crater
			)
			local clone3 = script.Projectile.Barrage:Clone()

			if raycastResult2 == nil then
				clone3:PivotTo(instance2)
			else
				clone3:PivotTo(CFrame.new(raycastResult2.Position + createVector(0, 0.5, 0)) * instance2.Rotation)
			end

			clone3.Parent = configuration
			Ouwmit.Emit(
				clone3,
				Ouwmit.Owned(
					instance,
					raycastResult2 and vfxUtility.GetDustColorSettings(raycastResult2.Instance) or nil
				)
			)
			Cam_Shaker(humanoidRootPart.Position, {
				FadeInTime = 0,
				Frequency = 0.1,
				Amplitude = 0.75,
				SustainTime = 1,
				FadeOutTime = 0.25,
				RotationInfluence = createVector(0.1, 0.1, 0.1),
				PositionInfluence = createVector(0.4, 0.4, 0.4)
			})
		end
	elseif p == "ProjectileFired" then
		local v = instance2 or data and workspace.Debree.Projectiles:WaitForChild(data, 0.2)

		if v == nil then
			return
		end

		local v2 = value or 1
		vfxUtility.PlaySound(script.Sound, `PS2windIDATENTYPHOONvar1shoot{math.random(1, 3)}`, humanoidRootPart, true)
		local clone = script.Projectile.SlashTravel:Clone()
		local cframe2

		if v2 >= 2 then
			cframe2 = CFrame.Angles(0, 0, 1.5707963267948966)
		else
			cframe2 = CFrame.identity
		end

		clone:PivotTo(v.CFrame * cframe2)
		clone.Parent = v
		local weld = Instance.new("Weld")
		weld.Part0 = v
		weld.Part1 = clone.Root
		weld.C0 = cframe2
		weld.Parent = v
		Ouwmit.Emit(clone, Ouwmit.Owned(instance))
		local configuration = Instance.new("Configuration")
		configuration.Name = "Release"
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 3.5)
		local v3

		if v2 >= 2 then
			v3 = script.Projectile.UserSlash2
		else
			v3 = script.Projectile.UserSlash1
		end

		local clone2 = v3:Clone()
		clone2:PivotTo(humanoidRootPart.CFrame)
		clone2.Parent = configuration
		Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
		Cam_Shaker(humanoidRootPart.Position, {
			FadeInTime = 0,
			Frequency = 0.12,
			Amplitude = 1,
			SustainTime = 0.05,
			FadeOutTime = 0.2,
			RotationInfluence = createVector(0.1, 0.1, 0.1),
			PositionInfluence = createVector(0.5, 0.5, 0.5)
		})
	elseif p == "ProjectileExplosion" then
		if data == nil then
			return
		end

		vfxUtility.PlaySound(script.Sound, "PS2windIDATENTYPHOONvar1impact", humanoidRootPart, true)
		Cam_Shaker(data.Position, {
			FadeInTime = 0,
			Frequency = 0.15,
			Amplitude = 1,
			SustainTime = 0.14,
			FadeOutTime = 0.5,
			RotationInfluence = createVector(0.25, 0.25, 0.25),
			PositionInfluence = createVector(2, 2, 2)
		})
		local configuration = Instance.new("Configuration")
		configuration.Parent = workspace.Debree
		DebrisModule:AddItem(configuration, 3)
		local raycastResult = workspace:Raycast(
			data.Position + createVector(0, 2, 0),
			createVector(-0, -30, -0),
			RaycastHelper.Map
		)
		local clone = script.Projectile.SlashImpact:Clone()

		if raycastResult == nil then
			clone:PivotTo(data)
		else
			clone:PivotTo(CFrame.new(raycastResult.Position + createVector(0, 0.5, 0)) * data.Rotation)
		end

		clone.Parent = configuration
		Ouwmit.Emit(
			clone,
			Ouwmit.Owned(instance, raycastResult and vfxUtility.GetDustColorSettings(raycastResult.Instance) or nil)
		)

		if instance2 ~= nil and instance2.Parent ~= nil then
			local upperTorso = instance2:FindFirstChild("UpperTorso")

			if upperTorso ~= nil then
				local clone2 = script.HitShort:Clone()
				clone2.Parent = upperTorso
				Ouwmit.Emit(clone2, Ouwmit.Owned(instance))
				DebrisModule:AddItem(clone2, 2)
			end
		end
	end
end