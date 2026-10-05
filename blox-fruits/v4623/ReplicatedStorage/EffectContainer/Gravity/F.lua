local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GravityRock = require(game.ReplicatedStorage.Util.GravityRock)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Curve(p, p2, p3, p4)
	return p2:Lerp(p3, p):Lerp(p3:Lerp(p4, p), p)
end

local function RotateTowards(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local v = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))

	if v == 0 then
		return unit2
	end

	local v2 = math.min(p * p2, v)
	local vector4 = unit:Cross(unit2)

	if vector4.Magnitude == 0 then
		vector4 = math.abs(unit.X) > math.abs(unit.Z) and Vector3.new(-unit.Y, unit.X, 0) or Vector3.new(
			0,
			-unit.Z,
			unit.Y
		)
	end

	return CFrame.fromAxisAngle(vector4.Unit, v2) * unit
end

local function emitAll(folder)
	local v = folder.Name == "ImpactAir"

	for _, effect in folder:GetDescendants() do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
			continue
		end

		if effect:IsA("Beam") then
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v2 = effect:GetAttribute("EmitDuration")
			local v3 = effect
			task.delay(tonumber(emitDelay) or 0, function()
				if tonumber(v2) and v2 ~= 0 then
					v3.Enabled = true

					if not v3:GetAttribute("pr3") then
						v3:SetAttribute("pr3", 0)
					end

					local v4 = (v3:GetAttribute("pr3") + 1) % 1000
					v3:SetAttribute("pr3", v4)
					task.wait(v2)

					if v4 == v3:GetAttribute("pr3") then
						v3.Enabled = false
					end
				end
			end)
		else
			if v then
				print("partiucle detectedf wrtf?")
			end

			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local v2 = effect
			local v4 = effect:GetAttribute("EmitDuration")
			task.delay(tonumber(emitDelay) or 0, function()
				v2:Emit(emitCount or 0)

				if tonumber(v4) and v4 ~= 0 then
					v2.Enabled = true

					if not v2:GetAttribute("pr3") then
						v2:SetAttribute("pr3", 0)
					end

					local v5 = (v2:GetAttribute("pr3") + 1) % 1000
					v2:SetAttribute("pr3", v5)
					task.wait(v4)

					if v5 == v2:GetAttribute("pr3") then
						v2.Enabled = false
					end
				end
			end)
		end
	end
end

local Util = require(game.ReplicatedStorage.Util)
local Players = game:GetService("Players")
local color = Color3.fromRGB(232, 194, 100)
local color2 = Color3.new(0, 0, 0)
local color3 = Color3.fromRGB(247, 130, 0)
local color4 = Color3.fromRGB(237, 18, 0)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, color),
	ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 118, 0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 64, 0)),
	ColorSequenceKeypoint.new(1, color2)
})
local colorSequence2 = ColorSequence.new(color, Color3.fromRGB(255, 110, 30))

local function GetGravityColorOwner(player)
	local player2 = player.Player

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		return player2
	end

	if player.Character then
		local playerFromCharacter = Players:GetPlayerFromCharacter(player.Character)

		if playerFromCharacter and playerFromCharacter.Parent then
			return playerFromCharacter
		end
	end

	return nil
end

local function colorAttributeMatches(instance, attributeName, p)
	local attribute = instance and instance:GetAttribute(attributeName)
	return typeof(attribute) == "Color3" and attribute == p
end

local function isShootingStarsGravitySkin(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false
	end

	local character = player and player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("GravitySkin") == "GRAVITYSKINheavenly" then
		return true
	end

	local gravityFruitVFXColor = player:FindFirstChild("GravityFruitVFXColor")

	if gravityFruitVFXColor and gravityFruitVFXColor:GetAttribute("SkinStorageKey") == "GRAVITYSKINheavenly" then
		return true
	end

	local shifted = gravityFruitVFXColor and gravityFruitVFXColor:FindFirstChild("Shifted")
	local v = color2
	local shifted_Color1 = shifted and shifted:GetAttribute("Shifted_Color1")
	local v2

	if typeof(shifted_Color1) == "Color3" then
		v2 = shifted_Color1 == v
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local v3 = color
	local shifted_Color2 = shifted and shifted:GetAttribute("Shifted_Color2")

	if typeof(shifted_Color2) == "Color3" then
		v2 = shifted_Color2 == v3
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local v4 = color3
	local shifted_Color3 = shifted and shifted:GetAttribute("Shifted_Color3")

	if typeof(shifted_Color3) == "Color3" then
		v2 = shifted_Color3 == v4
	else
		v2 = false
	end

	if v2 then
		local v5 = color4
		local shifted_Color4 = shifted and shifted:GetAttribute("Shifted_Color4")

		if typeof(shifted_Color4) == "Color3" then
			return shifted_Color4 == v5
		else
			return false
		end
	end

	return v2
end

local function applyShootingStarsGravityRockVFX(enable)
	local auraflipbookbig = enable:FindFirstChild("auraflipbookbig")

	if auraflipbookbig and auraflipbookbig:IsA("ParticleEmitter") then
		auraflipbookbig.Color = colorSequence
		auraflipbookbig.Enabled = true
		auraflipbookbig.Lifetime = NumberRange.new(0.25)
	end

	local spec19 = enable:FindFirstChild("Spec19")

	if spec19 and spec19:IsA("ParticleEmitter") then
		spec19.Color = colorSequence2
		spec19.Enabled = true
	end
end

local function recolorGravityRockVFX(instance, p)
	local enable = instance:FindFirstChild("Enable")

	if enable then
		Util.SetParentOverrideWithColor(enable, instance, p, "GravityFruitVFXColor", true)

		if isShootingStarsGravitySkin(p) then
			warn("applying shooting stars gravity rock vfx")
			applyShootingStarsGravityRockVFX(enable)
		end
	end
end

local Rock2 = require(game.ReplicatedStorage.Util.Rock2)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local F = FX:WaitForChild("Gravity").F
local FX2 = require(ReplicatedStorage:WaitForChild("FX"))
local clone = FX2:WaitForChild("Gravity").M1.METEORBAMP:Clone()
local clone_2 = F.METEORBAMPRemains.Lights:Clone()
clone_2.Parent = clone
local clone_3 = F.METEORBAMPRemains.Enable:Clone()
clone_3.Parent = clone
local clone2 = F.METEORBAMPRemains.Gravity:Clone()
clone2.Parent = clone
local clone3 = F.METEORBAMPRemains.Gravityx:Clone()
clone3.Part0 = clone
clone3.Part1 = clone2
clone3.Parent = clone

for _, child in pairs(clone:GetChildren()) do
	if not (child.Name == "Waves" or child.Name == "BEAMS1" or child.Name == "beams" or child.Name == "HitFX" or child.Name == "FX") then
		continue
	end

	child:Destroy()
end

return function(player)
	if player.BlowUp then
		local character = player.Character
		local folder = workspace._WorldOrigin:FindFirstChild(character.Name .. "_GravBoulder")

		if not folder then
			return
		end

		if folder:FindFirstChild("Motor6D") then
			folder.Motor6D:Destroy()
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
			elseif descendant:IsA("Weld") then
				descendant.Enabled = false
			end
		end

		folder.Name = "DESTROYING"
		local flag = false

		local function shatterBoulder(p)
			if flag then
				return
			end

			flag = true

			if folder then
				folder.Neon:Destroy()
				folder.Rock.Transparency = 1

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.Enabled = false
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false

						if descendant.Lifetime.Max >= 0.9 then
							descendant:Clear()
						end
					elseif descendant:IsA("Bone") and descendant.Name ~= "Cube_bone" then
						if math.random() > 0.5 then
							descendant:Destroy()
						else
							local clone4 = F.Rocks:GetChildren()[math.random(1, #F.Rocks:GetChildren())]:Clone()
							clone4.CFrame = descendant.WorldCFrame
							clone4.Color = folder.Rock.Color
							clone4.Material = folder.Rock.Material
							clone4.Anchored = false
							clone4.CanCollide = false
							clone4.Velocity = (p and (p + Vector3.new(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							) * 0.5).Unit or Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit) * math.random(
								90,
								200
							)
							clone4.RotVelocity = clone4.Velocity * (0.03 + math.random() * 0.02)
							clone4.Parent = workspace._WorldOrigin
							Util.Debris:AddItem(clone4, 2.5)
						end
					end
				end

				task.delay(3, function()
					folder:Destroy()
				end)
			end
		end

		local clone4 = F.ImpactAir:Clone()
		Util.ResizeModel(clone4, 1.2)
		clone4.Anchored = true
		clone4.Position = folder.Neon.Position
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local _WorldOrigin = workspace._WorldOrigin
		local player2 = player.Player

		if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
			if player.Character then
				player2 = Players:GetPlayerFromCharacter(player.Character)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		setParentOverrideWithColor(clone4, _WorldOrigin, player2, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone4, 3)
		clone4.vfx.Smoke2:Destroy()
		clone4.vfx.Smoke3:Destroy()
		Util.Sound:Play("GravFruit_F_RedMeteor_Explode_01", folder.Neon.Position)
		emitAll(clone4)
		shatterBoulder()
	elseif player.Drop then
		local character = player.Character
		local folder = workspace._WorldOrigin:FindFirstChild(character.Name .. "_GravBoulder")
		local proxy = player.Proxy

		if not (folder and proxy) then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			local cFrame = humanoidRootPart.CFrame
			task.spawn(function()
				RunService.PreSimulation:Wait()
				humanoidRootPart.CFrame = cFrame
				RunService.PreSimulation:Wait()
				humanoidRootPart.CFrame = cFrame
				RunService.PreSimulation:Wait()
				humanoidRootPart.CFrame = cFrame
			end)
		end

		task.wait()

		if folder:FindFirstChild("Motor6D") then
			folder.Motor6D:Destroy()
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = true
				descendant.AssemblyLinearVelocity = createVector(0, 0, 0)
				descendant.AssemblyAngularVelocity = createVector(0, 0, 0)
			elseif descendant:IsA("Weld") then
				descendant.Enabled = false
			end
		end

		folder.Name = "DESTROYING"
		task.wait()
		folder:PivotTo(CFrame.lookAt(folder:GetPivot().Position, player.TargetPosition))
		Util.Sound:Play("GravFruit_F_RockThrow_Release_02", humanoidRootPart.Position)

		for _, beam in pairs(folder:GetDescendants()) do
			if beam:IsA("Beam") then
				beam.Enabled = true
			end
		end

		emitAll(folder.Root.Push)

		for _, emitter in pairs(folder.Root.SHOOTFX:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, emitter in pairs(folder.GravityPUSH:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local flag = false

		local function shatterBoulder(p)
			if flag then
				return
			end

			flag = true

			if folder then
				folder.Neon:Destroy()
				folder.Rock.Transparency = 1

				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant:IsA("Beam") then
						descendant.Enabled = false
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false

						if descendant.Lifetime.Max >= 0.9 then
							descendant:Clear()
						end
					elseif descendant:IsA("Bone") and descendant.Name ~= "Cube_bone" then
						if math.random() > 0.5 then
							descendant:Destroy()
						else
							local clone4 = F.Rocks:GetChildren()[math.random(1, #F.Rocks:GetChildren())]:Clone()
							clone4.CFrame = descendant.WorldCFrame
							clone4.Color = folder.Rock.Color
							clone4.Material = folder.Rock.Material
							clone4.Anchored = false
							clone4.CanCollide = false
							clone4.Velocity = (p and (p + Vector3.new(
								math.random() - 0.5,
								math.random() - 0.5,
								math.random() - 0.5
							) * 0.5).Unit or Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit) * math.random(
								90,
								200
							)
							clone4.RotVelocity = clone4.Velocity * (0.03 + math.random() * 0.02)
							clone4.Parent = workspace._WorldOrigin
							Util.Debris:AddItem(clone4, 2.5)
						end
					end
				end

				task.delay(3, function()
					folder:Destroy()
				end)
			end
		end

		local v = false
		local lastTime = os.clock()
		local duration = player.Duration
		local targetPosition = player.TargetPosition
		local v2 = false
		local heartbeatConnection = nil
		local RunService2 = game:GetService("RunService")
		heartbeatConnection = RunService2.Heartbeat:Connect(function(dt)
			if duration <= os.clock() - lastTime or (folder.PrimaryPart.Position - targetPosition).Magnitude <= 2 or proxy:GetAttribute("Exploding") then
				heartbeatConnection:Disconnect()

				if proxy:GetAttribute("Exploding") then
					targetPosition = proxy:GetAttribute("Exploding")
					v2 = true
				end

				folder.Rock:SetAttribute("Stop", true)

				if player.RayData and not v2 then
					local rayData = player.RayData
					local cFrame = CFrame.new(rayData.Position, rayData.Position + rayData.Normal) * CFrame.Angles(
						-1.5707963267948966,
						0.001,
						0
					)
					shatterBoulder(rayData.Normal)
					local clone4 = F.ExplodeFloor:Clone()
					Util.ResizeModel(clone4, 1.2)
					clone4.CFrame = cFrame
					local setParentOverrideWithColor = Util.SetParentOverrideWithColor
					local _WorldOrigin = workspace._WorldOrigin
					local v5 = player
					local player2 = v5.Player

					if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
						if v5.Character then
							player2 = Players:GetPlayerFromCharacter(v5.Character)

							if not (player2 and player2.Parent) then
								player2 = nil
							end
						else
							player2 = nil
						end
					end

					setParentOverrideWithColor(clone4, _WorldOrigin, player2, "GravityFruitVFXColor")
					emitAll(clone4)
					Util.Sound:Play("GravFruit_F_RedMeteor_Explode_01", clone4.Position)
					Util.Sound:Play("GravFruit_GenericDebrisLayer_Large_05", clone4.Position)
					clone4.vfx.Smoke2.Color = ColorSequence.new(rayData.Instance.Color)
					clone4.vfx.Smoke3.Color = ColorSequence.new(rayData.Instance.Color)
					task.spawn(function()
						local v6 = clone4.Position + createVector(0, 2, 0)

						for i = 1, 22 do
							local v8 = CFrame.new(v6, v6 + rayData.Normal * 2) * CFrame.Angles(
								-1.5707963267948966,
								0,
								0
							) * CFrame.Angles(0, math.rad(i * 16.363636363636363), 0) * CFrame.new(0, 0, -49)
							local ray, v9, v10 = Util.Ray(
								v8.Position,
								v8.upVector.Unit * -30,
								{ workspace.Characters, workspace.Enemies },
								false
							)

							if not ray then
								continue
							end

							local v11 = Rock2.new({
								FadeIn = { 0.1, 0.3 },
								Lifetime = math.random(25, 30) / 10,
								FadeOut = { 0.4, 0.5 },
								Size = Vector3.new(math.random(3, 4), 2, math.random(3, 4)) * 1.33,
								Scale = { 1.2, 3 }
							})
							v11:Spawn(CFrame.new(v9, v9 + v10) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
								0,
								0,
								0
							))

							if not (math.random(1, 100) <= 25) then
								continue
							end

							v11.Type = "Flying"
							v11:Eject({
								Velocity = v8.UpVector * (workspace.Gravity / 2 + math.random(-10, 20)) + v11.Part.CFrame.lookVector * math.random(
									10,
									20
								),
								RotVelocity = createVector(3.1415927, 3.1415927, 3.1415927)
							})
						end
					end)
				else
					local clone4 = F.ImpactAir:Clone()
					Util.ResizeModel(clone4, 1.2)
					clone4.Anchored = true
					clone4.Position = targetPosition
					local setParentOverrideWithColor = Util.SetParentOverrideWithColor
					local _WorldOrigin = workspace._WorldOrigin
					local v4 = player
					local player2 = v4.Player

					if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
						if v4.Character then
							player2 = Players:GetPlayerFromCharacter(v4.Character)

							if not (player2 and player2.Parent) then
								player2 = nil
							end
						else
							player2 = nil
						end
					end

					setParentOverrideWithColor(clone4, _WorldOrigin, player2, "GravityFruitVFXColor")
					Util.Debris:AddItem(clone4, 3)
					clone4.vfx.Smoke2:Destroy()
					clone4.vfx.Smoke3:Destroy()
					Util.Sound:Play("GravFruit_F_RedMeteor_Explode_01", targetPosition)
					emitAll(clone4)
					shatterBoulder()
				end
			else
				folder:PivotTo(CFrame.lookAt(folder:GetPivot().Position, targetPosition) * CFrame.new(
					0,
					0,
					-player.FallSpeed * dt
				))

				if v == false and folder:GetPivot().Y < -4 then
					v = true
					local Effect = require(game.ReplicatedStorage.Effect)
					Effect.new("Water.Splash"):play({
						CFrame = CFrame.new(folder:GetPivot().Position.X, -4, folder:GetPivot().Position.Z),
						Scale = 50,
						Duration = 2.5
					})
				end
			end
		end)
		task.wait(duration + 0.5)
		shatterBoulder()
	else
		local character = player.Character
		local humanoidRootPart = character.HumanoidRootPart
		local holding = player.Holding
		local v = player.Meteor and 17 or 20
		local cframe = CFrame.new(0, -v, 0)
		local color5 = Color3.fromRGB(71, 71, 71)
		local slate = Enum.Material.Slate
		local rayMap, _, _ = Util.RayMap(humanoidRootPart.Position, createVector(-0, -100, -0))

		if rayMap then
			color5 = rayMap.Color
			slate = rayMap.Material
		end

		local clone4 = nil
		local clone5 = nil
		local rock = nil
		local v2 = {}
		local welds = {}

		if player.Meteor then
			local folder = Instance.new("Folder")
			folder.Name = character.Name .. "_GravBoulder"
			clone5 = clone:Clone()
			clone5.Transparency = 1
			clone5.Shape = Enum.PartType.Ball
			clone5.CanCollide = false
			clone5.Anchored = true
			clone5.CFrame = CFrame.lookAt(player.MeteorSpawnCFrame.Position, humanoidRootPart.CFrame * cframe.Position)
			clone5.Parent = folder
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local _WorldOrigin = workspace._WorldOrigin
			local player2 = player.Player

			if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
				if player.Character then
					player2 = Players:GetPlayerFromCharacter(player.Character)

					if not (player2 and player2.Parent) then
						player2 = nil
					end
				else
					player2 = nil
				end
			end

			setParentOverrideWithColor(folder, _WorldOrigin, player2, "GravityFruitVFXColor")
			Util.Sound:Play("GravFruit_F_CallMeteorDown_01", humanoidRootPart.Position)
			emitAll(clone5.BAMPLASH)
		else
			clone4 = F.FBoulder:Clone()
			clone4.Name = character.Name .. "_GravBoulder"
			clone4.Neon.Transparency = 1
			clone4:PivotTo(humanoidRootPart.CFrame * cframe)
			Util.Sound:Play("GravFruit_F_Rock_Formation_05", clone4.PrimaryPart)
			rock = clone4.Rock

			for _, weld in pairs(clone4.RootPart:GetChildren()) do
				if weld:IsA("Weld") then
					table.insert(welds, weld)
				end
			end

			clone4.Neon.Anchored = true
			clone4.Root.Anchored = true
			clone4.RootPart.Anchored = true
			table.insert(v2, clone4.Neon)
			table.insert(v2, clone4.Root)
			rock.Material = slate
			rock.Anchored = true
			local setParentOverrideWithColor = Util.SetParentOverrideWithColor
			local _WorldOrigin = workspace._WorldOrigin
			local player2 = player.Player

			if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
				if player.Character then
					player2 = Players:GetPlayerFromCharacter(player.Character)

					if not (player2 and player2.Parent) then
						player2 = nil
					end
				else
					player2 = nil
				end
			end

			setParentOverrideWithColor(clone4, _WorldOrigin, player2, "GravityFruitVFXColor")
			rock.Color = color5
		end

		local function tweenRock(instance, tweenInfo, p)
			local _ = Util.Tween.ease["in"].quad
			local back = Util.Tween.ease.inout.back
			local transformedWorldCFrame = instance.TransformedWorldCFrame
			local v3 = math.random(250, 500) / 4
			local v4 = math.random() * 3.141592653589793 * 2
			local lastTime = tick()
			task.spawn(function()
				instance:SetAttribute("Animating", true)

				while tick() - lastTime < tweenInfo.Time and rock.Anchored ~= false do
					local v6 = back((tick() - lastTime) / tweenInfo.Time, 0, 1, 1)
					local v7 = instance.WorldCFrame:Inverse() * (p.Goal.CFrame * p.Offset)
					local v8 = CFrame.lookAt(transformedWorldCFrame.Position, v7.Position) * CFrame.Angles(0, v4, 0) * CFrame.new(
						0,
						v3,
						0
					)
					local v9 = instance.WorldCFrame:Inverse() * v8
					instance.Transform = (instance.WorldCFrame:Inverse() * transformedWorldCFrame):Lerp(v9, v6):Lerp(
						v9:Lerp(v7, v6),
						v6
					)

					if rock:GetAttribute("Stop") then
						break
					end

					local v10 = task.wait()
					v4 += v10
				end

				instance:SetAttribute("Animating", false)

				if not rock:GetAttribute("Stop") then
					instance.Transform = instance.WorldCFrame:Inverse() * (p.Goal.CFrame * p.Offset)
				end
			end)
		end

		local v3 = rayMap or {
			Color = Color3.fromRGB(134, 109, 93),
			Material = Enum.Material.Slate
		}

		if clone4 then
			task.spawn(function()
				task.wait(0.25)
				local clone6 = F.Push.Enable:Clone()
				local setParentOverrideWithColor = Util.SetParentOverrideWithColor
				local v5 = player
				local player2 = v5.Player

				if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
					if v5.Character then
						player2 = Players:GetPlayerFromCharacter(v5.Character)

						if not (player2 and player2.Parent) then
							player2 = nil
						end
					else
						player2 = nil
					end
				end

				setParentOverrideWithColor(clone6, humanoidRootPart, player2, "GravityFruitVFXColor")
				emitAll(clone6)
				Util.Debris:AddItem(clone6, 2.5)
			end)
			local ray = Util.Ray
			local position = humanoidRootPart.Position
			local v4 = { workspace.Characters, workspace.Enemies }
			local _, v5, v6 = ray(position, createVector(-0, -500, -0), v4)
			local v7 = CFrame.new(v5, v5 + v6) * CFrame.Angles(1.5707963267948966, 0, 0)
			task.spawn(function()
				for _, bone in ipairs(clone4.RootPart:GetDescendants()) do
					if not (bone:IsA("Bone") and bone.Name ~= "Cube_bone") then
						continue
					end

					local clone = F.Smoke:Clone()
					clone.Parent = bone
					local objectSpace = clone4.PrimaryPart.CFrame:ToObjectSpace(bone.WorldCFrame)
					local v8 = Vector3.new(math.random(-200, 200), 20, math.random(-200, 200)) / 2
					local v9 = v7 * CFrame.new(v8)
					bone.Transform = bone.WorldCFrame:Inverse() * v9
					bone:SetAttribute("StartCFrame", bone.WorldCFrame:Inverse() * v9)
					emitAll(bone)
					bone.Smoke.Color = ColorSequence.new(v3.Color)
					local v10 = bone
					task.spawn(function()
						local v12 = math.random() * 0.1
						task.wait(v12)
						tweenRock(
							v10,
							TweenInfo.new(math.random(40, 90) / 110, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{
								Offset = objectSpace,
								Goal = clone4.PrimaryPart
							}
						)
					end)
				end
			end)
		else
			TweenService:Create(clone5, TweenInfo.new(0.7, Enum.EasingStyle.Sine), {
				CFrame = CFrame.lookAt(humanoidRootPart.CFrame * cframe.Position, clone5.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			}):Play()
		end

		local v4 = {}
		local motor6D = Instance.new("Motor6D")
		motor6D.C0 = cframe
		local part2

		if clone4 then
			part2 = clone4.RootPart or clone5
		else
			part2 = clone5
		end

		motor6D.Part1 = part2
		motor6D.Part0 = humanoidRootPart
		motor6D.Enabled = false
		local flag = false
		task.delay(0.6, function()
			if clone4 then
				if clone4.Name == "DESTROYING" then
					return
				else
					pcall(function()
						emitAll(clone4.Root.Pre)
						clone4.Root.Pre.Smoke.Color = ColorSequence.new(v3.Color)
						clone4.Root.Pre.Rocks.Color = ColorSequence.new(v3.Color)
						clone4.Root.Rocks.Color = ColorSequence.new(v3.Color)
						TweenService:Create(clone4.Neon, TweenInfo.new(0.2), {
							Transparency = 0
						}):Play()
						task.spawn(function()
							task.wait(0.1)
							emitAll(clone4.Root.AGH.Emit)
							task.wait(0.1)
							local neon = clone4.Neon
							local tweenInfo = TweenInfo.new(0.3)
							local wrapColor3Constructor = Util.WrapColor3Constructor
							local color6 = Color3.fromRGB(35, 25, 56)
							local v8 = player
							local player2 = v8.Player

							if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
								if v8.Character then
									player2 = Players:GetPlayerFromCharacter(v8.Character)

									if not (player2 and player2.Parent) then
										player2 = nil
									end
								else
									player2 = nil
								end
							end

							TweenService:Create(neon, tweenInfo, {
								Color = wrapColor3Constructor(color6, player2, "GravityFruitVFXColor")
							}):Play()
						end)
						clone4.Root.AGH.Enable.auraflipbookbig.Enabled = true
						clone4.Root.AGH.Enable.circlebig.Enabled = true
						clone4.Root.Rocks.Enabled = true
						clone4.Root.AGH.Enable.Glow.Enabled = true

						for _, descendant in pairs(clone4.Root:GetDescendants()) do
							if descendant.Name == "Shards" then
								descendant.Enabled = true
							end
						end

						for _, descendant in pairs(clone4.Gravity:GetDescendants()) do
							if descendant.Name == "Shards" then
								descendant.Enabled = true
							end
						end

						task.wait(1)
						clone4.Rock.Anchored = false
						clone4.RootPart.Anchored = false

						for _, v6 in v2 do
							v6.Anchored = false
						end

						for _, v6 in welds do
							v6.Enabled = true
						end
					end)
				end
			else
				for _, effect in pairs(clone5:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					elseif effect:IsA("Beam") then
						TweenService:Create(effect, TweenInfo.new(0.2), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					end
				end

				clone5.Anchored = false

				for _, emitter in pairs(clone5.Enable:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end

				for _, emitter in pairs(clone5.Gravity:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = true
					end
				end
			end

			flag = true
			motor6D.Enabled = true
			pcall(function()
				motor6D.Parent = clone4 and clone4.RootPart or clone5
			end)
		end)
		local lastTime = tick()
		local lastTime2 = tick()
		local v6 = Util.Sound:Play(
			player.Meteor and "GravFruit_F_RedFlameMeteor_FlyingLoop_01" or "GravFruit_F_Rock_FlyingLoop_01",
			player.Meteor and clone5 or clone4.PrimaryPart
		)
		local v7 = nil
		local clone6 = F.GroundBoulder:Clone()
		local setParentOverrideWithColor = Util.SetParentOverrideWithColor
		local _WorldOrigin = workspace._WorldOrigin
		local player2 = player.Player

		if typeof(player2) ~= "Instance" or not (player2:IsA("Player") and player2.Parent) then
			if player.Character then
				player2 = Players:GetPlayerFromCharacter(player.Character)

				if not (player2 and player2.Parent) then
					player2 = nil
				end
			else
				player2 = nil
			end
		end

		setParentOverrideWithColor(clone6, _WorldOrigin, player2, "GravityFruitVFXColor")
		local size = clone6.Attachment.Smoke.Size
		local size2 = clone6.Shockwaves.Shock.Size

		while holding and holding.Value and holding:IsDescendantOf(game) do
			local v8 = (tick() - lastTime2) / 2

			if flag then
				motor6D.C0 = cframe * (clone5 and CFrame.Angles(
					math.sin(v8) / 7 + -0.25,
					math.cos(v8) / 7 + -0.4,
					math.sin(v8) / 7 + -0.1
				) or CFrame.Angles(math.sin(v8) / 7, math.cos(v8) / 7, -math.sin(v8) / 7))
			elseif clone4 then
				clone4:PivotTo(humanoidRootPart.CFrame * cframe * CFrame.Angles(
					math.sin(v8) / 7,
					math.cos(v8) / 7,
					-math.sin(v8) / 7
				))
			end

			task.spawn(function()
				if clone4 or clone5 then
					local ray = Util.Ray
					local v9 = (clone4 and clone4.PrimaryPart.Position or clone5 and clone5.Position) + createVector(
						0,
						2,
						0
					)
					local v10 = { workspace.Characters, workspace.Enemies, workspace._WorldOrigin }
					local v11, v12, _ = ray(v9, createVector(-0, -55, -0), v10, false)

					if v11 == nil then
						if v7 then
							if clone6 then
								clone6.Attachment.Smoke.Enabled = false
								clone6.Shockwaves.Shock.Enabled = false
							end

							Util.Sound:FadeOut(v7, 0.2)
							v7 = nil
						end
					else
						local cframe2 = CFrame.new(v12)
						local v13 = math.clamp(
							(((clone4 and clone4.PrimaryPart.Position or clone5 and clone5.Position) - v12).Magnitude - 10) / 50,
							0,
							1
						) * -1.5 + 2.5

						if clone6 then
							clone6.CFrame = cframe2
							local smoke = clone6.Attachment.Smoke
							local numberSequenceKeypoints = {}

							for _, keypoint in ipairs(size.Keypoints) do
								table.insert(
									numberSequenceKeypoints,
									NumberSequenceKeypoint.new(
										keypoint.Time,
										keypoint.Value * v13,
										keypoint.Envelope * v13
									)
								)
							end

							smoke.Size = NumberSequence.new(numberSequenceKeypoints)
							local shock = clone6.Shockwaves.Shock
							local numberSequenceKeypoints2 = {}

							for _, keypoint in ipairs(size2.Keypoints) do
								table.insert(
									numberSequenceKeypoints2,
									NumberSequenceKeypoint.new(
										keypoint.Time,
										keypoint.Value * v13,
										keypoint.Envelope * v13
									)
								)
							end

							shock.Size = NumberSequence.new(numberSequenceKeypoints2)
						end

						if not v7 then
							if clone6 then
								clone6.CFrame = cframe2
								clone6.Attachment.Smoke.Enabled = true
								clone6.Shockwaves.Shock.Enabled = true
							end

							v7 = Util.Sound:Play(
								"GravFruit_F_Rock_FlyingCloseToGround_01",
								player.Meteor and clone5 or clone4.PrimaryPart
							)
						end

						clone6.Attachment.Smoke.Color = ColorSequence.new(v11.Color)
					end
				end
			end)

			if clone4 and tick() - lastTime > 0.3 and #v4 < 7 then
				local v9 = GravityRock.new(humanoidRootPart.CFrame * cframe, {
					Chaotic = true,
					GravityStrength = math.random(50, 80) / 1.5,
					OrbitRadius = math.random(70, 90) / 3,
					RotationSpeed = math.random(5, 10) / 1.5
				})
				v9.Part.Size = createVector(1, 1, 1) * math.random(5, 11) / 3
				local part = v9.Part
				local player3 = player.Player

				if typeof(player3) ~= "Instance" or not (player3:IsA("Player") and player3.Parent) then
					if player.Character then
						player3 = Players:GetPlayerFromCharacter(player.Character)

						if not (player3 and player3.Parent) then
							player3 = nil
						end
					else
						player3 = nil
					end
				end

				recolorGravityRockVFX(part, player3)
				v9:Orbit(clone4.Root)
				table.insert(v4, v9)
			end

			RunService.Heartbeat:Wait()
		end

		if v6 then
			Util.Sound:FadeOut(v6, 0.2)
		end

		if v7 then
			Util.Sound:FadeOut(v7, 0.2)
		end

		if clone6 then
			clone6.Attachment.Smoke.Enabled = false
			clone6.Shockwaves.Shock.Enabled = false
			task.delay(1, function()
				clone6:Destroy()
			end)
		end

		local cFrame = humanoidRootPart.CFrame
		task.spawn(function()
			RunService.PreSimulation:Wait()
			humanoidRootPart.CFrame = cFrame
			RunService.PreSimulation:Wait()
			humanoidRootPart.CFrame = cFrame
			RunService.PreSimulation:Wait()
			humanoidRootPart.CFrame = cFrame
		end)
		pcall(function()
			motor6D:Destroy()
		end)

		for _, v8 in ipairs(v4) do
			v8.Connection:Disconnect()
			v8.Part.Anchored = false
			v8.Part.Velocity = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit * math.random(15, 25)

			for _, emitter in pairs(v8.Part:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local v9 = v8
			task.delay(2, function()
				v9:Destroy()
			end)
		end

		table.clear(v4)

		if clone5 then
			clone5.Parent:Destroy()
		end

		task.wait(10)

		if rock then
			rock:Destroy()

			if clone4 then
				clone4:Destroy()
			end
		end
	end
end