local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
require(game.ReplicatedStorage.Util.Rock2)
local GravityRock = require(game.ReplicatedStorage.Util.GravityRock)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
require(script.Parent.Modules.RockRipple)
local Beziers = require(script.Parent.Modules.Beziers)
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local x_New = FX:WaitForChild("Gravity").X_New

local function Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

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
local v = nil
local flag = false

local function colorAttributeMatches(instance, attributeName, p)
	local attribute = instance and instance:GetAttribute(attributeName)
	return typeof(attribute) == "Color3" and attribute == p
end

local function isShootingStarsGravitySkin(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return false
	end

	local character = player.Character
	local primaryPart = character and character.PrimaryPart

	if primaryPart and primaryPart:GetAttribute("GravitySkin") == "GRAVITYSKINheavenly" then
		return true
	end

	local gravityFruitVFXColor = player:FindFirstChild("GravityFruitVFXColor")

	if gravityFruitVFXColor and gravityFruitVFXColor:GetAttribute("SkinStorageKey") == "GRAVITYSKINheavenly" then
		return true
	end

	local shifted = gravityFruitVFXColor and gravityFruitVFXColor:FindFirstChild("Shifted")
	local v2 = color2
	local shifted_Color1 = shifted and shifted:GetAttribute("Shifted_Color1")
	local v3

	if typeof(shifted_Color1) == "Color3" then
		v3 = shifted_Color1 == v2
	else
		v3 = false
	end

	if not v3 then
		return v3
	end

	local v4 = color
	local shifted_Color2 = shifted and shifted:GetAttribute("Shifted_Color2")

	if typeof(shifted_Color2) == "Color3" then
		v3 = shifted_Color2 == v4
	else
		v3 = false
	end

	if not v3 then
		return v3
	end

	local v5 = color3
	local shifted_Color3 = shifted and shifted:GetAttribute("Shifted_Color3")

	if typeof(shifted_Color3) == "Color3" then
		v3 = shifted_Color3 == v5
	else
		v3 = false
	end

	if v3 then
		local v6 = color4
		local shifted_Color4 = shifted and shifted:GetAttribute("Shifted_Color4")

		if typeof(shifted_Color4) == "Color3" then
			return shifted_Color4 == v6
		else
			return false
		end
	end

	return v3
end

local function getShootingStarsTrailTemplate()
	if flag then
		return v
	end

	flag = true
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local gravCachedUltimate = assets and assets:FindFirstChild("GravCachedUltimate")
	local ultimateModel = gravCachedUltimate and gravCachedUltimate:FindFirstChild("UltimateModel")
	local additionallandignrocks = ultimateModel and ultimateModel:FindFirstChild("additional landign rocks")
	local trails = additionallandignrocks and additionallandignrocks:FindFirstChild("trails")
	local m1 = trails and trails:FindFirstChild("m1")
	local attachment = m1 and m1:FindFirstChild("Attachment")
	local t2 = attachment and attachment:FindFirstChild("t2")
	local spikyTrail = t2 and t2:FindFirstChild("SpikyTrail")

	if spikyTrail and spikyTrail:IsA("Trail") then
		v = spikyTrail
	end

	return v
end

local function addShootingStarsGravityRockTrail(parent)
	if parent:FindFirstChild("ShootingStarsSpikyTrail") then
		return
	end

	local attachment = parent:FindFirstChild("ShootingStarsTrail0")

	if not (attachment and attachment:IsA("Attachment")) then
		attachment = Instance.new("Attachment")
		attachment.Name = "ShootingStarsTrail0"
		attachment.Parent = parent
	end

	attachment.Position = Vector3.new(0, parent.Size.Y * 0.7, 0)
	local attachment2 = parent:FindFirstChild("ShootingStarsTrail1")

	if not (attachment2 and attachment2:IsA("Attachment")) then
		attachment2 = Instance.new("Attachment")
		attachment2.Name = "ShootingStarsTrail1"
		attachment2.Parent = parent
	end

	attachment2.Position = Vector3.new(0, parent.Size.Y * -0.7, 0)
	local shootingStarsTrailTemplate = getShootingStarsTrailTemplate()
	local v4

	if shootingStarsTrailTemplate then
		v4 = shootingStarsTrailTemplate:Clone()
	else
		v4 = Instance.new("Trail")
	end

	v4.Name = "ShootingStarsSpikyTrail"
	v4.Attachment0 = attachment
	v4.Attachment1 = attachment2
	v4.Color = colorSequence
	v4.Enabled = false
	v4.Lifetime = 0.25

	if not shootingStarsTrailTemplate then
		v4.FaceCamera = true
		v4.LightInfluence = 0
		v4.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) })
		v4.WidthScale = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.35, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
	end

	v4.Parent = parent
end

local function setShootingStarsProjectileTrailEnabled(instance, enabled)
	local shootingStarsSpikyTrail = instance:FindFirstChild("ShootingStarsSpikyTrail")

	if not (shootingStarsSpikyTrail and shootingStarsSpikyTrail:IsA("Trail")) then
		return
	end

	shootingStarsSpikyTrail.Enabled = enabled
	local enable = instance:FindFirstChild("Enable")
	local auraflipbookbig = enable and enable:FindFirstChild("auraflipbookbig")

	if auraflipbookbig and auraflipbookbig:IsA("ParticleEmitter") then
		auraflipbookbig.Enabled = enabled
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableShootingStarsProjectileTrailAfterDelay(instance)
	setShootingStarsProjectileTrailEnabled(instance, false)
	task.delay(0.1, function()
		if instance.Parent and instance:IsDescendantOf(workspace) and instance.Transparency < 1 then
			setShootingStarsProjectileTrailEnabled(instance, true)
		end
	end)
end

local function applyShootingStarsGravityRockVFX(instance, enable)
	addShootingStarsGravityRockTrail(instance)
	local auraflipbookbig = enable:FindFirstChild("auraflipbookbig")

	if auraflipbookbig and auraflipbookbig:IsA("ParticleEmitter") then
		auraflipbookbig.Color = colorSequence
		auraflipbookbig.Enabled = false
		auraflipbookbig.Lifetime = NumberRange.new(0.25)
	end

	local spec19 = enable:FindFirstChild("Spec19")

	if spec19 and spec19:IsA("ParticleEmitter") then
		spec19.Color = colorSequence2
		spec19.Enabled = true
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recolorGravityRockVFX(part, player)
	local enable = part:FindFirstChild("Enable")

	if enable then
		Util.SetParentOverrideWithColor(enable, part, player, "GravityFruitVFXColor", true)

		if isShootingStarsGravitySkin(player) then
			applyShootingStarsGravityRockVFX(part, enable)
		end
	end
end

local function emitAll(folder)
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

return function(data)
	local origin = data.Origin

	if (workspace.CurrentCamera.CFrame.p - origin).Magnitude > 1200 then
		return
	end

	local stage = data.Stage
	local root = data.Root

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local child = workspace._WorldOrigin:FindFirstChild("GravX_" .. data.Player.Name)

		if child then
			child.Name = "HIDE"
		end

		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		local folder2 = Instance.new("Folder")
		folder2.Name = "GravX_" .. data.Player.Name
		folder2.Parent = workspace._WorldOrigin
		folder2:SetAttribute("FireRate", data.FireRate)
		folder2:SetAttribute("Amount", data.Amount)
		local clone = x_New.BLACKHOLE:Clone()
		clone.Name = "Blackhole"
		clone.Size = createVector(6, 6, 6)
		clone.Anchored = true
		clone.CanCollide = false
		clone.CFrame = root.CFrame
		Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
		local v2 = Util.Sound:Play("GravFruit_X_Hold_Upper_01", clone)
		emitAll(clone.EMIT)
		local v3 = nil

		for _, emitter in pairs(clone.Enable:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local ray = Util.Ray
		local v4 = root.Position + createVector(0, 2, 0)
		local v5 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v6, v7, v8 = ray(v4, createVector(-0, -10, -0), v5, false)
		local clone2

		if v6 == nil then
			clone2 = nil
		else
			local cFrame = CFrame.new(v7, v7 + v8) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
			clone2 = x_New.GroundToucher:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, data.Player, "GravityFruitVFXColor")
			v3 = Util.Sound:Play("GravFruit_X_Hold_LowerCircle_01", clone2)
		end

		if clone2 then
			task.spawn(function()
				local now = tick()
				local now2 = tick()

				while true do
					task.wait()

					if now < tick() then
						now = tick() + 0.035

						if root.Parent == game.Players.LocalPlayer.Character then
							Util.CameraShaker:ShakeOnce(
								1,
								1,
								0.05,
								0.1,
								createVector(0.5, 0.5, 0.5),
								createVector(0.5, 0.3, 0.3)
							)
						end
					end

					if now2 < tick() then
						now2 = tick() + 0.1
						task.spawn(function()
							local clone3 = x_New.partflybamp:Clone()
							clone3.CFrame = clone2.CFrame * CFrame.new(
								math.random(-35, 35),
								math.random(1.2, 1.5),
								math.random(-35, 35)
							)
							Util.SetParentOverrideWithColor(clone3, _WorldOrigin, data.Player, "GravityFruitVFXColor")
							Util.Debris:AddItem(clone3, 2)
							local v9 = math.random(15, 35) / 100
							Beziers.Interpolate(
								"Cubic",
								v9,
								100,
								v9,
								nil,
								clone3.CFrame,
								clone3.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 45),
									math.random(-25, 25)
								),
								clone3.CFrame * CFrame.new(
									math.random(-25, 25),
									math.random(-1, 15),
									math.random(-25, 25)
								),
								clone.CFrame,
								clone3,
								"CFrame"
							)
						end)
						local clone3 = x_New.PulseDistortBig:Clone()
						clone3.CFrame = clone.CFrame
						Util.SetParentOverrideWithColor(clone3, _WorldOrigin, data.Player, "GravityFruitVFXColor")
						local tween = TweenService:Create(
							clone3,
							TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 0, 0)
							}
						)
						local clone4 = x_New.SPINWIND:Clone()
						clone4.CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone4, _WorldOrigin, data.Player, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone4, 2)
						TweenService:Create(
							clone4,
							TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone4.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone4.Mesh,
							TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(19.852, 34.222, 19.037)
							}
						):Play()
						TweenService:Create(
							clone4.Decal,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
						local clone5 = x_New.SPINWIND2:Clone()
						clone5.CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0)
						Util.SetParentOverrideWithColor(clone5, _WorldOrigin, data.Player, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone5, 2)
						TweenService:Create(
							clone5,
							TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
							{
								CFrame = clone5.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, -3.0543261909900767, 0)
							}
						):Play()
						TweenService:Create(
							clone5.Mesh,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Scale = createVector(24.852, 38.222, 24.037)
							}
						):Play()
						TweenService:Create(
							clone5.Decal,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
							{
								Transparency = 1
							}
						):Play()
						tween.Completed:Connect(function()
							clone3:Destroy()
						end)
						tween:Play()
					end

					if holding:IsDescendantOf(workspace) and holding.Value then
						continue
					end

					task.wait(5)
					folder:Destroy()
					break
				end
			end)
		end

		for _ = 1, data.Amount do
			if folder2.Name == "DESTROYING" then
				print("YO STOP")
				break
			end

			local cFrame = root.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
				0,
				0,
				-math.random(23.333333333333332, 30)
			)
			local rock, v10, v11 = Util.RayMap(cFrame.Position, createVector(-0, -10, -0))

			if rock then
				cFrame = CFrame.lookAt(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
				local clone3 = x_New.PopUp:Clone()
				clone3.Size = createVector(5, 5, 5)
				clone3.CFrame = cFrame
				Util.SetParentOverrideWithColor(clone3, folder, data.Player, "GravityFruitVFXColor")
				Util.Debris:AddItem(clone3, 3)
				emitAll(clone3)
				clone3.Smoke.Color = rock and ColorSequence.new(rock.Color) or ColorSequence.new(clone3.Color)
			elseif data.Tool.InFlight.Value then
				local child2 = workspace._WorldOrigin:FindFirstChild(data.Player.Name .. "_GravBoulder")

				if child2 then
					rock = child2:FindFirstChild("Rock") or child2:FindFirstChild("Neon")
					cFrame = root.CFrame * CFrame.new(math.random(-9, 9), math.random(-17, -9), math.random(-9, 9)) * CFrame.Angles(
						0,
						math.random() * 3.141592653589793 * 2,
						0
					)
				end
			end

			local v12 = GravityRock.new(cFrame, {
				Chaotic = false,
				ForceColor = data.Tool.InFlight.Value and rock and rock.Color or nil,
				GravityStrength = math.random(50, 80),
				OrbitRadius = math.random(23.333333333333332, 30),
				RotationSpeed = math.random(10, 20) * 2,
				Parent = folder2
			})
			v12.Part.Size = createVector(1, 1, 1) * math.random(6, 12) / 2
			recolorGravityRockVFX(v12.Part, data.Player) -- equivalent call inferred; original call site unknown
			v12:Orbit(clone)
		end

		local childRemovedConnection = folder2.ChildRemoved:Connect(function(_)
			local fireRate = folder2:GetAttribute("FireRate")
			local count = #folder2:GetChildren()
			local amount = folder2:GetAttribute("Amount")

			if count < amount then
				for _ = 1, amount - count do
					if folder2.Name == "DESTROYING" then
						break
					end

					local v9 = root.CFrame * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0) * CFrame.new(
						0,
						0,
						-math.random(23.333333333333332, 30)
					)
					local rock, v10, v11 = Util.RayMap(v9.Position, createVector(-0, -100, -0))

					if rock then
						local clone3 = x_New.PopUp:Clone()
						clone3.Size = createVector(5, 5, 5)
						clone3.CFrame = CFrame.new(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
						Util.SetParentOverrideWithColor(clone3, folder, data.Player, "GravityFruitVFXColor")
						Util.Debris:AddItem(clone3, 3)
						emitAll(clone3)
						clone3.Smoke.Color = rock and ColorSequence.new(rock.Color) or ColorSequence.new(clone3.Color)
						Util.Sound:Play("GravFruit_X_RockPullFromGround_0" .. tostring(math.random(1, 9)), v9.Position)
						v9 = CFrame.lookAt(v10, v10 + v11) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					elseif data.Tool.InFlight.Value then
						local child2 = workspace._WorldOrigin:FindFirstChild(data.Player.Name .. "_GravBoulder")

						if child2 then
							rock = child2:FindFirstChild("Rock") or child2:FindFirstChild("Neon")
							v9 = root.CFrame * CFrame.new(math.random(-9, 9), math.random(-17, -9), math.random(-9, 9)) * CFrame.Angles(
								0,
								math.random() * 3.141592653589793 * 2,
								0
							)
						end
					end

					local v12 = not (fireRate > 0.05) and 2 or math.max(0.5, 2 - fireRate * 3.5)
					local v13 = GravityRock.new(v9, {
						Chaotic = false,
						ForceColor = rock and rock.Color,
						GravityStrength = math.random(50, 80),
						OrbitRadius = math.random(23.333333333333332, 30),
						RotationSpeed = math.random(10, 20) * v12,
						Parent = folder2
					})
					v13.Part.Size = createVector(1, 1, 1) * math.random(6, 12) / 2
					recolorGravityRockVFX(v13.Part, data.Player) -- equivalent call inferred; original call site unknown
					v13:Orbit(clone)
				end
			end
		end)

		while holding:IsDescendantOf(workspace) and holding.Value and folder2.Name ~= "DESTROYING" do
			clone.CFrame = root.CFrame * CFrame.new(0, 25, 0)

			if folder2.Name == "DESTROYING" then
				break
			else
				RunService.Heartbeat:Wait()
			end
		end

		childRemovedConnection:Disconnect()

		if v2 then
			Util.Sound:FadeOut(v2, 0.2)
		end

		if v3 then
			Util.Sound:FadeOut(v3, 0.2)
		end

		for _, emitter in pairs(clone.Enable:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if clone2 then
			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		task.spawn(function()
			task.wait(0.086)
			emitAll(clone.EMIT3)
		end)
		task.wait(7)
		folder:Destroy()
		folder2:Destroy()
	elseif stage == 2 then
		local child = workspace._WorldOrigin:FindFirstChild("GravX_" .. data.Player.Name)

		if not child then
			return
		end

		local v2 = child:GetChildren()[1]

		if not v2 then
			return
		end

		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local random = Random.new()
		local _ = data.ProjectileSpeed
		local target = data.Target
		local cframe = CFrame.lookAt(v2.Position, target.Position)
		child:SetAttribute("FireRate", data.FireRate)
		v2:SetAttribute("Disconnected", true)
		v2.CFrame = cframe
		v2.Parent = folder
		enableShootingStarsProjectileTrailAfterDelay(v2) -- equivalent call inferred; original call site unknown
		child:SetAttribute("Amount", data.RocksAmount)
		local v3 = math.max(1, 1.5 / (1 + (data.FireRate - 0.05) * 1))
		Util.Sound:Play("GravFruit_X_Rock_Launch_0" .. tostring(math.random(1, 6)), cframe, nil, v3)
		local position = target.Position
		local v4 = math.clamp((position - v2.Position).Magnitude / 350, 0.3333333333333333, 1)
		local cframe2 = CFrame.lookAt(cframe.p, position)
		local position2 = v2.Position
		local position3 = v2.Position
		local v5 = position3 + (position - position3) * 0.25 + cframe2.UpVector * random:NextNumber(0, 90) * v4 + cframe2.RightVector * random:NextNumber(
			-120,
			120
		) * v4
		local position4 = v2.Position
		local v6 = position4 + (position - position4) * 0.5 + cframe2.UpVector * random:NextNumber(0, 30) * 1 + cframe2.RightVector * random:NextNumber(
			-30,
			30
		) * 1
		local position5 = v2.Position
		local v7 = position5 + (position - position5) * 0.75 + cframe2.UpVector * random:NextNumber(0, 30) + cframe2.RightVector * random:NextNumber(
			-30,
			30
		)
		local position6 = v2.Position
		local duration = data.Duration
		local lastTime = tick()
		local position7 = position

		while tick() - lastTime < duration do
			local v8 = (tick() - lastTime) / duration

			if target then
				position7 = target.Position
			end

			local v9 = position2 + (v5 - position2) * v8
			local v10 = v5 + (v6 - v5) * v8
			local v11 = v6 + (v7 - v6) * v8
			local v12 = v7 + (position7 - v7) * v8
			local v13 = v9 + (v10 - v9) * v8
			local v14 = v10 + (v11 - v10) * v8
			local v15 = v11 + (v12 - v11) * v8
			local v16 = v13 + (v14 - v13) * v8
			local v17 = v16 + (v14 + (v15 - v14) * v8 - v16) * v8

			if v8 ~= 0 then
				v2.CFrame = CFrame.lookAt(v17, position6) * CFrame.Angles(0, 3.141592653589793, 0)
			end

			task.wait()
			position6 = v17
		end

		v2.CFrame = CFrame.new(position, v2.Position + createVector(0, 0.012345, 0)) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		local position8 = v2.Position
		local clone = x_New.Impact:Clone()
		clone.Size = createVector(5, 5, 5)
		clone.Transparency = 1
		clone.Anchored = true
		clone.Position = position8
		Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
		Util.Debris:AddItem(clone, 3)
		emitAll(clone.vfx)
		local v8 = Util.Sound:Play("GravFruit_X_RockImpact_0" .. tostring(math.random(1, 9)), clone.Position)
		local player = data.Player
		local Players = game:GetService("Players")

		if player == Players.LocalPlayer then
			v8.RollOffMinDistance = 80
			v8.Volume = 1
		end

		v2.Transparency = 1
		v2.Enable:Destroy()
		local ray = Util.Ray
		local v9 = clone.Position + createVector(0, 2, 0)
		local v10 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
		local v11, v12, v13 = ray(v9, createVector(-0, -9, -0), v10, false)

		if v11 ~= nil then
			local cFrame = CFrame.new(v12, v12 + v13) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
			local clone2 = x_New.ImpactFloor:Clone()
			clone2.CFrame = cFrame
			Util.SetParentOverrideWithColor(clone2, folder, data.Player, "GravityFruitVFXColor")
			emitAll(clone2)
			clone2.Floor.Smoke.Color = ColorSequence.new(v11.Color)
			clone2.Floor.Smoke2.Color = ColorSequence.new(v11.Color)
		end
	elseif stage == 3 then
		local child = workspace._WorldOrigin:FindFirstChild("GravX_" .. data.Player.Name)

		if not (child and child:GetChildren()[1]) then
			return
		end

		child.Name = "DESTROYING"
		local folder = Instance.new("Folder")
		folder.Parent = workspace._WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local targetPos = data.targetPos
		local targetHrp = data.targetHrp
		local random = Random.new()
		local v2 = data.Root.CFrame * CFrame.new(0, 25, 0)
		local v3 = not (#child:GetChildren() > data.Amount) and 0 or #child:GetChildren() - data.Amount
		local children = {}

		for _, child2 in pairs(child:GetChildren()) do
			if v3 > 0 then
				v3 -= 1
				child2:SetAttribute("Disconnected", true)
				child2:Destroy()
			else
				child2:SetAttribute("Disconnected", true)
				table.insert(children, child2)
			end
		end

		local v4 = false

		for i = 1, data.Amount do
			local v5 = i
			task.spawn(function()
				local v6 = children[v5]

				if not v6 then
					return
				end

				local vector2 = Vector3.new(targetPos[v5][1], targetPos[v5][2], targetPos[v5][3])
				local position = v2.Position
				local v7

				if targetHrp then
					v7 = targetHrp.Position or vector2
				else
					v7 = vector2
				end

				local cframe = CFrame.lookAt(position, v7)
				v6:SetAttribute("Disconnected", true)
				v6.CFrame = cframe
				v6.Parent = folder
				Util.Debris:AddItem(v6, 10)
				enableShootingStarsProjectileTrailAfterDelay(v6) -- equivalent call inferred; original call site unknown
				Util.Sound:Play(
					"GravFruit_X_Rock_Launch_0" .. tostring(math.random(1, 6)),
					cframe,
					nil,
					nil,
					v4 and 0.35 or 1
				)
				v4 = true
				local v8

				if targetHrp and targetHrp[1] then
					if targetHrp[v5] then
						vector2 = targetHrp[v5].Position
						v8 = targetHrp[v5]
					else
						vector2 = targetHrp[1].Position
						v8 = targetHrp[1]
					end
				end

				local v9 = math.clamp((vector2 - v6.Position).Magnitude / 350, 0.3333333333333333, 1)
				local cframe2 = CFrame.lookAt(cframe.p, vector2)
				local position2 = v6.Position
				local position3 = v6.Position
				local v10 = position3 + (vector2 - position3) * 0.25 + cframe2.UpVector * random:NextNumber(0, 90) * v9 + cframe2.RightVector * random:NextNumber(
					-120,
					120
				) * v9
				local position4 = v6.Position
				local v11 = position4 + (vector2 - position4) * 0.5 + cframe2.UpVector * random:NextNumber(0, 30) * 1 + cframe2.RightVector * random:NextNumber(
					-30,
					30
				) * 1
				local position5 = v6.Position
				local v12 = position5 + (vector2 - position5) * 0.75 + cframe2.UpVector * random:NextNumber(0, 30) + cframe2.RightVector * random:NextNumber(
					-30,
					30
				)
				local position6 = v6.Position
				local v13 = data.duration[v5] and data.duration[v5] or data.duration[1]
				local lastTime = tick()
				local position7 = vector2

				while tick() - lastTime < v13 do
					local v14 = (tick() - lastTime) / v13

					if v8 then
						position7 = v8.Position
					end

					local v15 = position2 + (v10 - position2) * v14
					local v16 = v10 + (v11 - v10) * v14
					local v17 = v11 + (v12 - v11) * v14
					local v18 = v12 + (position7 - v12) * v14
					local v19 = v15 + (v16 - v15) * v14
					local v20 = v16 + (v17 - v16) * v14
					local v21 = v17 + (v18 - v17) * v14
					local v22 = v19 + (v20 - v19) * v14
					local v23 = v22 + (v20 + (v21 - v20) * v14 - v22) * v14

					if v14 ~= 0 then
						v6.CFrame = CFrame.lookAt(v23, position6) * CFrame.Angles(0, 3.141592653589793, 0)
					end

					task.wait()
					position6 = v23
				end

				v6.CFrame = CFrame.new(vector2, v6.Position + createVector(0, 0.012345, 0)) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
				local position8 = v6.Position
				local clone = x_New.Impact:Clone()
				clone.Size = createVector(5, 5, 5)
				clone.Transparency = 1
				clone.Anchored = true
				clone.Position = position8
				Util.SetParentOverrideWithColor(clone, folder, data.Player, "GravityFruitVFXColor")
				Util.Debris:AddItem(clone, 3)
				emitAll(clone.vfx)
				local v14 = Util.Sound:Play("GravFruit_X_RockImpact_0" .. tostring(math.random(1, 9)), clone.Position)
				local player = data.Player
				local Players = game:GetService("Players")

				if player == Players.LocalPlayer then
					v14.RollOffMinDistance = 80
					v14.Volume = 1
				end

				local ray = Util.Ray
				local v15 = clone.Position + createVector(0, 2, 0)
				local v16 = { workspace.Characters, workspace.Enemies, _WorldOrigin }
				local v17, v18, v19 = ray(v15, createVector(-0, -9, -0), v16, false)

				if v17 ~= nil then
					local cFrame = CFrame.new(v18, v18 + v19) * CFrame.Angles(-1.5707963267948966, 0.001, 0)
					local clone2 = x_New.ImpactFloor:Clone()
					clone2.CFrame = cFrame
					Util.SetParentOverrideWithColor(clone2, folder, data.Player, "GravityFruitVFXColor")
					emitAll(clone2)
					clone2.Floor.Smoke.Color = ColorSequence.new(v17.Color)
					clone2.Floor.Smoke2.Color = ColorSequence.new(v17.Color)
				end

				v6.Transparency = 1
				v6.Enable:Destroy()
			end)
		end
	end
end