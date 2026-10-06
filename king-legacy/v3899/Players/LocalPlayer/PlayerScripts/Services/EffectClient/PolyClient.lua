local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local fSEffect = replicatedStorage.Chest.Remotes.Events.FSEffect
local dFEffect = replicatedStorage.Chest.Remotes.Events.DFEffect
local swordEffect = replicatedStorage.Chest.Remotes.Events.SwordEffect
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local localPlayer = game.Players.LocalPlayer
PeodizService.HeartbeatWait({
	Time = 100,
	WaitTime = 0.05
}, function()
	if localPlayer:FindFirstChild("PlayerStats") then
		return true
	end
end)
local currentCamera = workspace.CurrentCamera
local CameraShaker = require(replicatedStorage.Chest.Modules:WaitForChild("CameraShaker"))
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera.CFrame *= p
end)
v:Start()

-- equivalent calls inferred from this helper; original call sites unknown
local function shake(list)
	if typeof(list) == "table" then
		v:ShakeOnce(unpack(list))
	else
		v:Shake(CameraShaker.Presets[list])
	end
end

function _G.checkskillsslot()
	PeodizService.HeartbeatWait({
		Time = 60,
		WaitTime = 0.05
	}, function()
		if localPlayer.Character and localPlayer.PlayerGui:FindFirstChild("SkillCooldown") then
			return true
		end
	end)
	local skillCooldown = localPlayer.PlayerGui.SkillCooldown
	local count = 0

	if skillCooldown.DFFrame.Visible == true then
		for _, frame in pairs(skillCooldown.DFFrame:GetChildren()) do
			if frame:IsA("Frame") and frame.Name ~= "Power" and frame.Visible == true then
				count += 1
			end
		end
	end

	return count
end

function _G.shake(list)
	shake(list) -- equivalent call inferred; original call site unknown
end

dFEffect.OnClientEvent:Connect(function(player)
	local localPlayer2 = game.Players.LocalPlayer

	if player.Position ~= nil and (localPlayer2.Character.HumanoidRootPart.Position - player.Position).Magnitude > 500 then
		return
	end

	if type(player) == "table" then
		local player2 = player.Player

		if _G.ReturnEffects(localPlayer, player2) then
			return
		end
	end

	if player.fx == "teleport" then
		local model = Instance.new("Model")
		model.Name = "CharModel"
		model.Parent = workspace.Effects
		_G.PU:Dust(model, 2)

		local function clone(char)
			local clones = {}

			for _, part in pairs(char:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local clone2 = part:Clone()
				clone2:ClearAllChildren()
				clone2.Material = Enum.Material.Neon
				clone2.Color = Color3.fromRGB(126, 199, 129)
				clone2.Size = part.Size + createVector(0.05, 0.05, 0.05)
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Parent = model
				clones[#clones + 1] = clone2
			end

			task.delay(10, function()
				table.clear(clones)
			end)
			return clones
		end

		local char = player.char
		local v2 = clone(char)
		game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		local cFrame = char.HumanoidRootPart.CFrame

		if game.Players.LocalPlayer.Name == player.plrname then
			local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
			humanoidRootPart.CFrame = CFrame.new(player.pos) * CFrame.new(0, 2.45, 0) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)
		end

		local magnitude = (cFrame.p - player.pos).magnitude
		local clone2 = replicatedStorage.Chest.FruitEffect.Op.Sphere:Clone()
		clone2.CFrame = CFrame.new(cFrame.p, player.pos) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Size = Vector3.new(4, 4, magnitude)
		clone2.Parent = workspace.Effects
		local clone3 = replicatedStorage.Chest.FruitEffect.Op.Shockwave:Clone()
		clone3.Color = Color3.fromRGB(157, 199, 160)
		clone3.CFrame = CFrame.new(player.pos) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone3.Size = createVector(13.74, 13.74, 2.538)
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(17.658, 17.658, 3.262),
			CFrame = clone3.CFrame * CFrame.Angles(0, 0, 1.5707963267948966)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, clone2.Size.Z)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 1)
		_G.PU:Dust(clone2, 1)

		for _, v3 in pairs(v2) do
			TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(v3, 1)

			if player.char:FindFirstChild(v3.Name) then
				TweenService:Create(v3, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					CFrame = char[v3.Name].CFrame
				}):Play()
			end
		end
	elseif player.fx == "rock_explode" then
		local cFrame = player.cf * CFrame.new(0, -2.5, 0)
		local clone = replicatedStorage.Chest.FruitEffect.OpNew.Rings:Clone()
		clone.Anchored = true
		clone.Transparency = 0.2
		clone.CanCollide = false
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6533511567",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6814067199",
			Volume = 3,
			PlaybackSpeed = 0.8
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()
		local clone2 = replicatedStorage.Chest.FruitEffect.OpNew.smoke:Clone()
		clone2.Anchored = true
		clone2.CanCollide = false
		clone2.CFrame = cFrame
		clone2.sm2:Emit(100)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(93.943504, 0.231, 98.421)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 2)
		_G.PU:Dust(clone2, 2)

		for i = 1, 9 do
			local v3 = math.random(50, 100)
			local v4 = cFrame * CFrame.Angles(0, 0.6981317007977318 * i, 0) * CFrame.new(0, 0, -10)
			local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.bigsmoke:Clone()
			clone3.Anchored = true
			clone3.Color = Color3.fromRGB(v3, v3, v3)
			clone3.CanCollide = false
			clone3.Size = Vector3.new()
			clone3.CFrame = v4 * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 2.5)
			TweenService:Create(
				clone3,
				TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(20.436, 19.862, 21.254) * math.random(10, 15) / 10
				}
			):Play()
			TweenService:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame * CFrame.Angles(0, 0.6981317007977318 * i, 0) * CFrame.new(0, 0, -25) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
			}):Play()
		end

		for _ = 1, 12 do
			local v3 = math.random(50, 100)
			local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.bigsmoke:Clone()
			clone3.Anchored = true
			clone3.Color = Color3.fromRGB(v3, v3, v3)
			clone3.CanCollide = false
			clone3.Size = createVector(20.436, 19.862, 21.254) * math.random(80, 100) / 100
			clone3.CFrame = cFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1.5)
			TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -60)
			}):Play()
		end

		if (localPlayer2.Character.HumanoidRootPart.Position - player.Position).Magnitude < 150 or game.Players.LocalPlayer == player.plrname then
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.TintColor = Color3.fromRGB(255, 180, 155)
			colorCorrectionEffect.Parent = game.Lighting
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					TintColor = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			_G.PU:Dust(colorCorrectionEffect, 1)
			local blurEffect = Instance.new("BlurEffect")
			blurEffect.Size = 12
			blurEffect.Parent = game.Lighting
			TweenService:Create(blurEffect, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = 0
			}):Play()
			_G.PU:Dust(blurEffect, 1)
		end

		local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.spike:Clone()
		clone3.CFrame = cFrame * CFrame.new(0, 19, 0)
		clone3.Anchored = true
		clone3.CanCollide = false
		clone3.Size = createVector(0, 65, 0)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 2)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(255, 161, 107)
		pointLight.Brightness = 0
		pointLight.Range = 0
		pointLight.Parent = clone3
		TweenService:Create(
			pointLight,
			TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
			{
				Brightness = 2,
				Range = 40
			}
		):Play()
		TweenService:Create(
			clone3,
			TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
			{
				CFrame = cFrame * CFrame.new(0, 35, 0) * CFrame.Angles(0, 3.141592653589793, 0),
				Size = createVector(32.119, 70.273, 31.689)
			}
		):Play()
		TweenService:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = cFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		spawn(function()
			wait(1.6)
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	elseif player.fx == "counter_shock" then
		game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		local magnitude = (player.cf1.p - player.cf2.p).magnitude
		local clone = replicatedStorage.Chest.FruitEffect.Op.Wind:Clone()
		_G.PU:Dust(clone, 1)
		clone.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		clone.Size = Vector3.new(4, 0.05, magnitude)
		clone.Parent = workspace.Effects
		local clone2 = replicatedStorage.Chest.FruitEffect.Op.Sphere:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Size = Vector3.new(5.5, 5.5, magnitude)
		clone2.Parent = workspace.Effects
		local clone3 = replicatedStorage.Chest.FruitEffect.Op.Shockwave:Clone()
		_G.PU:Dust(clone3, 1)
		clone3.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		clone3.Size = createVector(24, 24, 5)
		clone3.Parent = workspace.Effects
		spawn(function()
			for i = 1, math.floor(magnitude / 20) do
				local clone4 = replicatedStorage.Chest.FruitEffect.Op.ShockwaveZ:Clone()
				clone4.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, i * -20 + 20) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone4.Parent = workspace.Effects
				wait()
				_G.PU:Dust(clone4, 1)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(8.473, 1.025, 8.431)
					}
				):Play()
				TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end
		end)
		local clone4 = replicatedStorage.Chest.FruitEffect.Op.WindRing:Clone()
		_G.PU:Dust(clone4, 1)
		clone4.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude - 2) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		clone4.Size = createVector(13.206, 0.977, 13.206)
		clone4.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(6, 8.5, clone.Size.Z)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(3, 3, 25),
			CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude + 12.5) * CFrame.Angles(
				0,
				3.141592653589793,
				3.141592653589793
			)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, clone2.Size.Z)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(24.166, 1.665, 24.166),
			CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude + 6) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		spawn(function()
			for i = 1, 8 do
				local p = (CFrame.new(player.cf2.p) * CFrame.Angles(0, 0.7853981633974483 * i, 0) * CFrame.new(
					0,
					0,
					-12
				)).p
				local ray = Ray.new(p + createVector(0, 2, 0), createVector(0, -12, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Massless = true
				part.CastShadow = true
				part.Color = instance.Color
				part.Material = instance.Material
				part.CFrame = CFrame.new(position + createVector(0, -0.325, 0)) * CFrame.Angles(
					math.random(-1, 1),
					math.random(-1, 1),
					math.random(-1, 1)
				)
				part.Parent = workspace.Effects

				if instance:FindFirstChild("Texture") then
					for _, texture in pairs(instance:GetChildren()) do
						if not texture:IsA("Texture") then
							continue
						end

						local clone = texture:Clone()
						clone.Parent = part
					end
				end

				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = createVector(2.4, 2.4, 2.4)
				}):Play()
				_G.PU:Dust(part, 4)
				spawn(function()
					wait(3)
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = createVector(1, 1, 1),
						Transparency = 1,
						Position = part.Position + createVector(0, -5, 0)
					}):Play()
				end)
			end
		end)
		spawn(function()
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.CastShadow = false
			part.Color = Color3.fromRGB(255, 2, 2)
			part.Size = createVector(0.1, 0.1, 0.1)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude)
			part.Parent = workspace.Effects

			for _ = 1, 4 do
				wait()
				local clone5 = replicatedStorage.Chest.FruitEffect.Op.ShockParticle:Clone()
				clone5.Enabled = false
				clone5.Parent = part
				clone5:Emit(1)
			end

			_G.PU:Dust(part, 1)
		end)
		spawn(function()
			math.random(5, 10)
			math.random(-10, -5)
			local _ = math.random(1, 2) == 1
			local _ = math.random(1, 2) == 1
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.CastShadow = false
			part.Color = Color3.fromRGB(255, 2, 2)
			part.Size = createVector(0.5, 0.5, 0.5)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = CFrame.new(player.cf1.p, player.cf2.p)
			part.Parent = workspace.Effects
			local part2 = Instance.new("Part")
			part2.Material = "Neon"
			part2.CastShadow = false
			part2.Color = Color3.fromRGB(255, 2, 2)
			part2.Size = createVector(0.5, 0.5, 0.5)
			part2.Anchored = true
			part2.CanCollide = false
			part2.Transparency = 1
			part2.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude)
			part2.Parent = workspace.Effects
			local pointLight = Instance.new("PointLight")
			pointLight.Range = 18
			pointLight.Brightness = 2
			pointLight.Color = Color3.fromRGB(162, 255, 165)
			pointLight.Parent = part2
			TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Bounce), {
				Brightness = 0
			}):Play()
			_G.PU:Dust(pointLight, 1)
			spawn(function()
				for _ = 1, 7 do
					local cFrame = part2.CFrame
					local part3 = Instance.new("Part")
					part3.Anchored = true
					part3.Transparency = 0.1
					part3.CastShadow = false
					part3.Size = Vector3.new(0.75, 0.75, math.random(1, 2))
					part3.Material = Enum.Material.Neon
					part3.Color = Color3.fromRGB(136, 214, 100)
					part3.CanCollide = false
					part3.CFrame = cFrame * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					part3.Parent = workspace.Effects
					TweenService:Create(
						part3,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0.15, 0.15, part3.Size.Z + 3),
							CFrame = part3.CFrame * CFrame.new(0, 0, -6)
						}
					):Play()
					TweenService:Create(part3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Parent = part3
					_G.PU:Dust(part3, 1)
				end
			end)
			spawn(function()
				for _ = 1, 3 do
					local clone5 = game.ReplicatedStorage.Chest.FruitEffect.Op.Wave:Clone()
					clone5.Material = Enum.Material.Neon
					clone5.Color = Color3.fromRGB(133, 255, 172)
					clone5.Size = Vector3.new()
					clone5.Transparency = 0.2
					clone5.CFrame = player.cf2 * CFrame.Angles(1.5707963267948966, 0, 0)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(41.666668, 41.666668, 3.3333333)
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone5, 0.6)
					wait()
				end
			end)
			spawn(function()
				for _ = 1, 7 do
					local cFrame = part2.CFrame
					local part3 = Instance.new("Part")
					part3.Anchored = true
					part3.Transparency = 0.1
					part3.CastShadow = false
					part3.Size = createVector(1, 1, 1)
					part3.Material = Enum.Material.Neon
					part3.Color = Color3.fromRGB(18, 129, 18)
					part3.CanCollide = false
					part3.CFrame = cFrame * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					part3.Parent = workspace.Effects
					TweenService:Create(
						part3,
						TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(),
							CFrame = part3.CFrame * CFrame.new(0, 0, -math.random(7, 12))
						}
					):Play()
					TweenService:Create(part3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Parent = part3
					_G.PU:Dust(part3, 1)
				end
			end)
			local v2 = {}
			local v3 = {}
			local v4 = {}
			local v5 = {}

			for i = 0, 4 do
				local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				local v6 = part.CFrame.p + (part2.CFrame.p - part.CFrame.p).Unit * i * (part2.CFrame.p - part.CFrame.p).magnitude / 4
				local v7 = (i == 0 or i == 4) and createVector(0, 0, 0) or vector2
				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.CastShadow = false
				part3.Color = Color3.fromRGB(255, 2, 2)
				part3.Size = createVector(0.5, 0.5, 0.5)
				part3.Anchored = true
				part3.CanCollide = false
				part3.Transparency = 1
				part3.Position = v6 + v7
				part3.Parent = workspace.Effects
				v2[#v2 + 1] = part3
				v3[#v3 + 1] = v6
				v4[#v4 + 1] = v7
			end

			for i = 1, #v3 do
				if v3[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.CastShadow = false
				part3.Color = Color3.fromRGB(126, 199, 129)
				part3.Size = Vector3.new(0.3, 0.3, (v3[i] + v4[i] - (v3[i + 1] + v4[i + 1])).magnitude)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CFrame = CFrame.new((v3[i] + v4[i] + (v3[i + 1] + v4[i + 1])) / 2, v3[i + 1] + v4[i + 1])
				part3.Parent = workspace.Effects
				local v6 = i
				spawn(function()
					wait(0.15)
					wait(v6 * 0.35 * wait())
					part3:Destroy()
				end)
				v5[#v5 + 1] = part3
				local v8 = part3
				spawn(function()
					local v9 = 5
					PeodizService.new({
						Time = 15
					}, function()
						if v8.Parent ~= workspace.Effects then
							return true
						end

						v9 -= 0.1

						for i2 = 1, #v3 do
							if i2 ~= 1 then
								v4[i2 + 1] = Vector3.new(
									math.random(-v9, v9),
									math.random(-v9, v9),
									math.random(-v9, v9)
								)
								v4[i2] = Vector3.new(math.random(-v9, v9), math.random(-v9, v9), math.random(-v9, v9))
							end

							if i2 == 1 then
								v3[1] = part.CFrame.p
							end

							if i2 == #v3 then
								v3[i2] = part2.CFrame.p
								v4[i2] = createVector(0, 0, 0)
							end

							v3[i2] = part.CFrame.p + (part2.CFrame.p - part.CFrame.p).Unit * (i2 - 1) * (part2.CFrame.p - part.CFrame.p).magnitude / 4
						end

						for i2 = 1, #v5 do
							v5[i2].CFrame:toObjectSpace(CFrame.new(
								(v3[i2] + v4[i2] + (v3[i2 + 1] + v4[i2 + 1])) / 2,
								v3[i2 + 1] + v4[i2 + 1]
							))
							v5[i2].CFrame = CFrame.new(
								(v3[i2] + v4[i2] + (v3[i2 + 1] + v4[i2 + 1])) / 2,
								v3[i2 + 1] + v4[i2 + 1]
							)
							v5[i2].Size = Vector3.new(
								0.15,
								0.15,
								(v3[i2] + v4[i2] - (v3[i2 + 1] + v4[i2 + 1])).magnitude
							)
						end
					end)
					part2:Destroy()
					part:Destroy()
				end)
			end

			task.delay(10, function()
				table.clear(v3)
				table.clear(v4)
				table.clear(v2)
				table.clear(v5)
			end)
		end)
		PeodizService.ForLoop({
			Step = 3
		}, function()
			for _ = 1, 2 do
				local v2 = player.cf2.p
				local v3 = (CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.new(
					math.random(-12, 12),
					math.random(-12, 12),
					math.random(15, 20)
				)).p
				spawn(function()
					local v4 = {}

					for i = 0, 5 do
						local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
						local v5 = v2 + (v3 - v2).Unit * i * (v3 - v2).magnitude / 5
						local v6 = (i == 0 or i == 5) and createVector(0, 0, 0) or vector2
						v4[#v4 + 1] = v5 + v6
					end

					for i = 1, #v4 do
						wait()

						if v4[i + 1] == nil then
							continue
						end

						local part = Instance.new("Part")
						part.Material = "Neon"
						part.Color = Color3.fromRGB(126, 199, 129)
						part.Size = Vector3.new(0.5, 0.5, (v4[i] - v4[i + 1]).magnitude)
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new((v4[i] + v4[i + 1]) / 2, v4[i + 1])
						part.Parent = workspace.Effects
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
							Transparency = 1
						}):Play()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(
							part,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(0, 0, (v4[i] - v4[i + 1]).magnitude)
							}
						):Play()
						_G.PU:Dust(part, 1)
					end

					task.delay(10, function()
						table.clear(v4)
					end)
				end)
			end
		end)
	elseif player.fx == "mes" then
		game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
		local magnitude = (player.cf1.p - player.cf2.p).magnitude
		local clone = replicatedStorage.Chest.FruitEffect.Op.Wind:Clone()
		clone.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		clone.Size = Vector3.new(4, 0.05, magnitude)
		clone.Parent = workspace.Effects
		local clone2 = replicatedStorage.Chest.FruitEffect.Op.Sphere:Clone()
		clone2.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Size = Vector3.new(5.5, 5.5, magnitude)
		clone2.Color = Color3.fromRGB(255, 111, 111)
		clone2.Parent = workspace.Effects
		local clone3 = replicatedStorage.Chest.FruitEffect.Op.Shockwave:Clone()
		clone3.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		clone3.Size = createVector(24, 24, 5)
		clone3.Color = Color3.fromRGB(255, 111, 111)
		clone3.Parent = workspace.Effects
		spawn(function()
			local step = math.floor(magnitude / 20)
			PeodizService.ForLoop({
				Step = step
			}, function(p)
				local v3 = math.floor(p * step)
				local clone4 = replicatedStorage.Chest.FruitEffect.Op.ShockwaveZ:Clone()
				clone4.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, v3 * -20 + 20) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.Color = Color3.fromRGB(255, 183, 183)
				clone4.Parent = workspace.Effects
				wait()
				_G.PU:Dust(clone4, 1)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(8.473, 1.025, 8.431)
					}
				):Play()
				TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		end)
		local clone4 = replicatedStorage.Chest.FruitEffect.Op.WindRing:Clone()
		clone4.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude - 2) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		clone4.Size = createVector(13.206, 0.977, 13.206)
		clone4.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(6, 8.5, clone.Size.Z)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(3, 3, 25),
			CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude + 12.5) * CFrame.Angles(
				0,
				3.141592653589793,
				3.141592653589793
			)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, clone2.Size.Z)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(24.166, 1.665, 24.166),
			CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude + 6) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
		_G.PU:Dust(clone4, 1)
		_G.PU:Dust(clone2, 1)
		_G.PU:Dust(clone3, 1)
		spawn(function()
			for i = 1, 8 do
				local p = (CFrame.new(player.cf2.p) * CFrame.Angles(0, 0.7853981633974483 * i, 0) * CFrame.new(
					0,
					0,
					-12
				)).p
				local ray = Ray.new(p + createVector(0, 2, 0), createVector(0, -12, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Massless = true
				part.CastShadow = true
				part.Color = instance.Color
				part.Material = instance.Material
				part.CFrame = CFrame.new(position + createVector(0, -0.325, 0)) * CFrame.Angles(
					math.random(-1, 1),
					math.random(-1, 1),
					math.random(-1, 1)
				)
				part.Parent = workspace.Effects

				if instance:FindFirstChild("Texture") then
					for _, texture in pairs(instance:GetChildren()) do
						if not texture:IsA("Texture") then
							continue
						end

						local clone = texture:Clone()
						clone.Parent = part
					end
				end

				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = createVector(2.4, 2.4, 2.4)
				}):Play()
				_G.PU:Dust(part, 4)
				spawn(function()
					wait(3)
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = createVector(1, 1, 1),
						Transparency = 1,
						Position = part.Position + createVector(0, -5, 0)
					}):Play()
				end)
			end
		end)
		spawn(function()
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.CastShadow = false
			part.Color = Color3.fromRGB(255, 2, 2)
			part.Size = createVector(0.1, 0.1, 0.1)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude)
			part.Parent = workspace.Effects
			PeodizService.ForLoop({
				Step = 4,
				WaitTime = 0.05
			}, function(_)
				local clone5 = replicatedStorage.Chest.FruitEffect.Op.ShockParticle:Clone()
				clone5.Enabled = false
				clone5.Parent = part
				clone5.Color = ColorSequence.new(Color3.fromRGB(255, 115, 115))
				clone5:Emit(1)
			end)
			_G.PU:Dust(part, 1)
		end)
		spawn(function()
			math.random(5, 10)
			math.random(-10, -5)
			local _ = math.random(1, 2) == 1
			local _ = math.random(1, 2) == 1
			local part = Instance.new("Part")
			part.Material = "Neon"
			part.CastShadow = false
			part.Color = Color3.fromRGB(255, 2, 2)
			part.Size = createVector(0.5, 0.5, 0.5)
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.CFrame = CFrame.new(player.cf1.p, player.cf2.p)
			part.Parent = workspace.Effects
			local part2 = Instance.new("Part")
			part2.Material = "Neon"
			part2.CastShadow = false
			part2.Color = Color3.fromRGB(255, 2, 2)
			part2.Size = createVector(0.5, 0.5, 0.5)
			part2.Anchored = true
			part2.CanCollide = false
			part2.Transparency = 1
			part2.CFrame = CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude)
			part2.Parent = workspace.Effects
			local pointLight = Instance.new("PointLight")
			pointLight.Range = 18
			pointLight.Brightness = 2
			pointLight.Color = Color3.fromRGB(255, 96, 96)
			pointLight.Parent = part2
			TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Bounce), {
				Brightness = 0
			}):Play()
			_G.PU:Dust(pointLight, 1)
			spawn(function()
				for _ = 1, 7 do
					local cFrame = part2.CFrame
					local part3 = Instance.new("Part")
					part3.Anchored = true
					part3.Transparency = 0.1
					part3.CastShadow = false
					part3.Size = Vector3.new(0.75, 0.75, math.random(1, 2))
					part3.Material = Enum.Material.Neon
					part3.Color = Color3.fromRGB(214, 149, 149)
					part3.CanCollide = false
					part3.CFrame = cFrame * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					part3.Parent = workspace.Effects
					TweenService:Create(
						part3,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0.15, 0.15, part3.Size.Z + 3),
							CFrame = part3.CFrame * CFrame.new(0, 0, -6)
						}
					):Play()
					TweenService:Create(part3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Parent = part3
					_G.PU:Dust(part3, 1)
				end
			end)
			spawn(function()
				PeodizService.ForLoop({
					Step = 4,
					WaitTime = 0.05
				}, function(_)
					local clone5 = game.ReplicatedStorage.Chest.FruitEffect.Op.Wave:Clone()
					clone5.Material = Enum.Material.Neon
					clone5.Color = Color3.fromRGB(133, 255, 172)
					clone5.Size = Vector3.new()
					clone5.Transparency = 0.2
					clone5.Color = Color3.fromRGB(255, 210, 210)
					clone5.CFrame = player.cf2 * CFrame.Angles(1.5707963267948966, 0, 0)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(41.666668, 41.666668, 3.3333333)
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone5, 0.6)
				end)
			end)
			spawn(function()
				for _ = 1, 7 do
					local cFrame = part2.CFrame
					local part3 = Instance.new("Part")
					part3.Anchored = true
					part3.Transparency = 0.1
					part3.CastShadow = false
					part3.Size = createVector(1, 1, 1)
					part3.Material = Enum.Material.Neon
					part3.Color = Color3.fromRGB(129, 27, 27)
					part3.CanCollide = false
					part3.CFrame = cFrame * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					part3.Parent = workspace.Effects
					TweenService:Create(
						part3,
						TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(),
							CFrame = part3.CFrame * CFrame.new(0, 0, -math.random(7, 12))
						}
					):Play()
					TweenService:Create(part3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Parent = part3
					_G.PU:Dust(part3, 1)
				end
			end)
			local v2 = {}
			local v3 = {}
			local v4 = {}
			local v5 = {}

			for i = 0, 4 do
				local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				local v6 = part.CFrame.p + (part2.CFrame.p - part.CFrame.p).Unit * i * (part2.CFrame.p - part.CFrame.p).magnitude / 4
				local v7 = (i == 0 or i == 4) and createVector(0, 0, 0) or vector2
				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.CastShadow = false
				part3.Color = Color3.fromRGB(255, 2, 2)
				part3.Size = createVector(0.5, 0.5, 0.5)
				part3.Anchored = true
				part3.CanCollide = false
				part3.Transparency = 1
				part3.Position = v6 + v7
				part3.Parent = workspace.Effects
				v2[#v2 + 1] = part3
				v3[#v3 + 1] = v6
				v4[#v4 + 1] = v7
			end

			for i = 1, #v3 do
				if v3[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.CastShadow = false
				part3.Color = Color3.fromRGB(214, 149, 149)
				part3.Size = Vector3.new(0.3, 0.3, (v3[i] + v4[i] - (v3[i + 1] + v4[i + 1])).magnitude)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CFrame = CFrame.new((v3[i] + v4[i] + (v3[i + 1] + v4[i + 1])) / 2, v3[i + 1] + v4[i + 1])
				part3.Parent = workspace.Effects
				local v6 = i
				spawn(function()
					wait(0.15)
					wait(v6 * 0.35 * wait())
					part3:Destroy()
				end)
				v5[#v5 + 1] = part3
				local v8 = part3
				spawn(function()
					local v9 = 5
					PeodizService.new({
						Time = 15
					}, function()
						if v8.Parent ~= workspace.Effects then
							return true
						end

						v9 -= 0.1

						for i2 = 1, #v3 do
							if i2 ~= 1 then
								v4[i2 + 1] = Vector3.new(
									math.random(-v9, v9),
									math.random(-v9, v9),
									math.random(-v9, v9)
								)
								v4[i2] = Vector3.new(math.random(-v9, v9), math.random(-v9, v9), math.random(-v9, v9))
							end

							if i2 == 1 then
								v3[1] = part.CFrame.p
							end

							if i2 == #v3 then
								v3[i2] = part2.CFrame.p
								v4[i2] = createVector(0, 0, 0)
							end

							v3[i2] = part.CFrame.p + (part2.CFrame.p - part.CFrame.p).Unit * (i2 - 1) * (part2.CFrame.p - part.CFrame.p).magnitude / 4
						end

						for i2 = 1, #v5 do
							v5[i2].CFrame:toObjectSpace(CFrame.new(
								(v3[i2] + v4[i2] + (v3[i2 + 1] + v4[i2 + 1])) / 2,
								v3[i2 + 1] + v4[i2 + 1]
							))
							v5[i2].CFrame = CFrame.new(
								(v3[i2] + v4[i2] + (v3[i2 + 1] + v4[i2 + 1])) / 2,
								v3[i2 + 1] + v4[i2 + 1]
							)
							v5[i2].Size = Vector3.new(
								0.15,
								0.15,
								(v3[i2] + v4[i2] - (v3[i2 + 1] + v4[i2 + 1])).magnitude
							)
						end
					end)
					part2:Destroy()
					part:Destroy()
				end)
			end

			task.delay(10, function()
				table.clear(v3)
				table.clear(v4)
				table.clear(v2)
				table.clear(v5)
			end)
		end)
		PeodizService.ForLoop({
			Step = 3
		}, function(_)
			PeodizService.ForLoop({
				Step = 2
			}, function(_)
				local p = player.cf2.p
				local p2 = (CFrame.new(player.cf1.p, player.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.new(
					math.random(-12, 12),
					math.random(-12, 12),
					math.random(15, 20)
				)).p
				spawn(function()
					local v2 = {}

					for i = 0, 5 do
						local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
						local v3 = p + (p2 - p).Unit * i * (p2 - p).magnitude / 5
						local v4 = (i == 0 or i == 5) and createVector(0, 0, 0) or vector2
						v2[#v2 + 1] = v3 + v4
					end

					PeodizService.ForLoop({
						Step = #v2
					}, function(p3)
						local v3 = math.floor(p3 * #v2)

						if v2[v3 + 1] ~= nil then
							local part = Instance.new("Part")
							part.Material = "Neon"
							part.Color = Color3.fromRGB(214, 149, 149)
							part.Size = Vector3.new(0.5, 0.5, (v2[v3] - v2[v3 + 1]).magnitude)
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = CFrame.new((v2[v3] + v2[v3 + 1]) / 2, v2[v3 + 1])
							part.Parent = workspace.Effects
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
								Transparency = 1
							}):Play()
							local TweenService3 = game:GetService("TweenService")
							TweenService3:Create(
								part,
								TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(0, 0, (v2[v3] - v2[v3 + 1]).magnitude)
								}
							):Play()
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v2)
					end)
				end)
			end)
		end)
	elseif player.fx == "demon_form_passive" then
		local char = player.char
		local demonForm = char:FindFirstChild("DemonForm")

		local function puddle()
			if (localPlayer2.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude < 500 then
				local clone = replicatedStorage.Chest.FruitEffect.Venom.puddle:Clone()
				_G.PU:Dust(clone, 2)
				clone.CanCollide = false
				clone.Color = Color3.fromRGB(166, 27, 27)
				clone.Material = Enum.Material.Glass
				clone.Transparency = 0.1
				clone.CFrame = CFrame.new(char.HumanoidRootPart.Position - createVector(0, 2.25, 0)) * CFrame.Angles(
					0,
					math.random() * 3.141592653589793 * 2,
					0
				)
				clone.Size = createVector(9.5, 0.653, 9.516)
				clone.Parent = workspace.Effects
				clone.smoke:Emit(math.random(30, 35))
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://5705064570",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				TweenService:Create(clone, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(58.417, 1.981, 58.518)
				}):Play()
				spawn(function()
					wait(1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1,
						Color = Color3.fromRGB(170, 28, 28)
					}):Play()
				end)
			end
		end

		PeodizService.HeartbeatWait({
			Time = 120,
			WaitTime = 0.75
		}, function()
			puddle()
			local humanoid = char:FindFirstChild("Humanoid")

			if demonForm and char:IsDescendantOf(workspace.PlayerCharacters) and humanoid and char:FindFirstChild("DemonForm") then
				return
			else
				return true
			end
		end)
	elseif player.fx == "demon_transform" then
		local position = player.Position

		if (localPlayer2.Character.HumanoidRootPart.Position - position).Magnitude < 65 then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		PeodizService.ForLoop({
			Step = 12
		}, function()
			local cFrame = CFrame.new(position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local clone = replicatedStorage.Chest.FruitEffect.Venom.Sphere:Clone()
			clone.Color = Color3.fromRGB(86, 36, 36)
			clone.CFrame = cFrame
			clone.Size = createVector(15, 3, 3)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)
			TweenService:Create(clone, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(71, 29, 29),
				Size = Vector3.new(0, 0, math.random(35, 40)),
				CFrame = cFrame * CFrame.new(0, 0, -math.random(75, 100))
			}):Play()
			spawn(function()
				wait(0.1)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		end)
		spawn(function()
			PeodizService.ForLoop({
				Step = 12,
				WaitTime = 0.05
			}, function()
				local clone = replicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
				clone.CFrame = CFrame.new(position) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(262.5, 18.75, 262.5)
				}):Play()
				spawn(function()
					wait()
					TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
			end)
		end)
		PeodizService.ForLoop({
			Step = 10
		}, function()
			local v2 = math.random(100, 150)
			local cFrame = CFrame.new(position) * CFrame.new(
				math.random(-25, 25),
				math.random(-25, 25),
				math.random(-25, 25)
			)
			local clone = replicatedStorage.Chest.Etc.AllMeshes.Smoke:Clone()
			clone.Color = Color3.fromRGB(139, 42, 42)
			clone.Material = Enum.Material.Neon
			clone.Size = createVector(40, 40, 40)
			clone.Parent = workspace.Effects
			clone.CFrame = cFrame
			TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
				Size = Vector3.new(v2, v2, v2)
			}):Play()
			_G.PU:Dust(clone, 2)
			delay(0.1, function()
				TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
					Size = createVector(0, 0, 0),
					Color = Color3.fromRGB(0, 0, 0),
					CFrame = clone.CFrame * CFrame.new(0, math.random(40, 90), 0) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
				}):Play()
			end)
		end)
	elseif player.fx == "demon_smash" then
		local position = player.Position

		if (localPlayer2.Character.HumanoidRootPart.Position - position).Magnitude < 45 then
			v:Shake(CameraShaker.Presets.Stand)
		end

		local part = Instance.new("Part")
		_G.PU:Dust(part, 2)
		part.Size = createVector(1, 1, 1)
		part.Anchored = true
		part.Transparency = 1
		part.CFrame = CFrame.new(position)
		part.CanCollide = false
		part.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://165970126",
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = part
		sound:Play()
		local color = Color3.fromRGB(86, 36, 36)
		local color2 = Color3.fromRGB(71, 29, 29)
		spawn(function()
			local position2 = player.Position

			if (localPlayer2.Character.HumanoidRootPart.Position - position2).Magnitude < 25 then
				v:Shake(CameraShaker.Presets.Bump)
			end

			spawn(function()
				for _ = 1, math.random(3, 4) do
					local part2 = Instance.new("Part")
					part2.Parent = workspace.Effects
					local v2 = math.random(2, 3)
					part2.Shape = Enum.PartType.Ball
					part2.Size = Vector3.new(v2, v2, v2)
					part2.CFrame = CFrame.new(position2) * CFrame.new(math.rad(-45, 45), 0, (math.rad(-45, 45))) * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					part2.Velocity = Vector3.new(math.random(-45, 45), math.random(70, 100), math.random(-45, 45))
					part2.Anchored = false
					part2.CanCollide = false
					part2.Material = Enum.Material.Neon
					part2.Color = color
					part2.Massless = true
					part2.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					_G.PU:Dust(part2, 5)
					TweenService:Create(part2, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Color = color2
					}):Play()
					local v3 = false
					spawn(function()
						wait(0.3)
						local touchedConnection = nil
						touchedConnection = part2.Touched:Connect(function(otherPart)
							if not otherPart or not otherPart.Anchored or not otherPart.CanCollide or v3 == true then
								return
							end

							if otherPart:IsDescendantOf(workspace.Effects) then
								return
							end

							if otherPart.Anchored and otherPart.CanCollide and v3 == false then
								v3 = true
								local part3 = Instance.new("Part")
								part3.Parent = workspace.Effects
								part3.CFrame = part2.CFrame
								local ray = Ray.new(part3.Position + createVector(0, 2, 0), createVector(0, -50, 0))
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {
									workspace.Effects,
									workspace.PlayerCharacters,
									workspace.CharacterWorkshop
								}
								raycastParams.FilterType = Enum.RaycastFilterType.Exclude
								local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
								local instance = raycastResult and raycastResult.Instance
								local position3 = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
								local normal = raycastResult and raycastResult.Normal or nil
								part3.CFrame = CFrame.new(position3, position3 + normal) * CFrame.Angles(
									0,
									1.5707963267948966,
									0
								)
								part3.Shape = "Cylinder"
								part3.Anchored = true
								part3.CanCollide = false
								part3.Size = Vector3.new(0.05, part2.Size.Z, part2.Size.Z)
								part3.Color = part2.Color
								part3.Material = Enum.Material.Neon
								_G.PU:Dust(part3, 1)
								local sound2 = PeoUtils.CreateSound({
									RollOffMaxDistance = 150,
									RollOffMinDistance = 10,
									RollOffMode = Enum.RollOffMode.InverseTapered,
									SoundId = "rbxassetid://4992388243",
									Volume = 0.5
								})
								_G.PU:Dust(sound2, 3)
								sound2.Parent = part3
								sound2:Play()
								local v5 = math.random(25, 35) / 10
								TweenService:Create(
									part3,
									TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Size = Vector3.new(0.05, part2.Size.Z * v5, part2.Size.Z * v5)
									}
								):Play()
								spawn(function()
									wait(0.45)
									TweenService:Create(
										part3,
										TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end)
								part2:Destroy()

								if touchedConnection and touchedConnection.Connected then
									touchedConnection:Disconnect()
								end
							end
						end)
					end)
				end

				for _ = 1, 8 do
					local cFrame = CFrame.new(position2) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					local clone = replicatedStorage.Chest.FruitEffect.Venom.Sphere:Clone()
					clone.Color = color
					clone.CFrame = cFrame
					clone.Size = createVector(12, 6, 6)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = color2,
							Size = Vector3.new(0, 0, math.random(25, 30)),
							CFrame = cFrame * CFrame.new(0, 0, -math.random(40, 45))
						}
					):Play()
					spawn(function()
						wait(0.2)
						TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			local clone = replicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			_G.PU:Dust(clone, 1)
			clone.CanCollide = false
			clone.Anchored = true
			clone.Size = createVector(28.003, 2.953, 28.003)
			clone.Material = Enum.Material.Neon
			clone.Transparency = 0.15
			clone.CFrame = CFrame.new(position2) * CFrame.new(0, 2, 0)
			clone.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://165970126",
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			spawn(function()
				PeodizService.ForLoop({
					Step = 5,
					WaitTime = 0.05
				}, function()
					local clone2 = replicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
					clone2.CFrame = CFrame.new(position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 1)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(66.986, 7.43, 66.987) * math.random(150, 200) / 100
						}
					):Play()
					spawn(function()
						wait()
						TweenService:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end)
			end)
			TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(87.96361, 9.273601, 87.96361),
				CFrame = CFrame.new(position2) * CFrame.new(0, 3.25, 0) * CFrame.Angles(0, 0.3490658503988659, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local ray = Ray.new(position2 + createVector(0, 5, 0), createVector(0, -12, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			if not (raycastResult and raycastResult.Position) then
				local _ = ray.Origin + ray.Direction
			end

			if instance then
				local clone2 = replicatedStorage.Chest.FruitEffect.Venom.spike:Clone()
				clone2.Size = createVector(1, 0, 1)
				clone2.Color = color
				clone2.CFrame = CFrame.new(position2) * CFrame.new(0, 18, 0)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(20.495, 44.842, 20.221)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
				}):Play()
				_G.PU:Dust(clone2, 1)
				spawn(function()
					wait(0.4)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 44, 0)
						}
					):Play()
					wait()
					TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				spawn(function()
					wait()
					TweenService:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
						Color = color2
					}):Play()
				end)

				for _ = 1, 2 do
					local size = Vector3.new(
						math.random(150, 180) / 10,
						math.random(150, 180) / 10,
						math.random(150, 180) / 10
					) * 1.2
					local clone3 = replicatedStorage.Chest.FruitEffect.Venom.cartoon_smoke:Clone()
					clone3.Material = Enum.Material.Neon
					clone3.CFrame = CFrame.new(position2) * CFrame.new(
						math.random(-8, 8),
						math.random(-3, 2),
						math.random(-8, 8)
					) * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					)
					clone3.Color = color
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 2)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = size
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone3.CFrame * CFrame.Angles(
							math.random() * 3.141592653589793 * 2,
							math.random() * 3.141592653589793 * 2,
							math.random() * 3.141592653589793 * 2
						) * CFrame.new(0, 0, math.random(-3, -1))
					}):Play()
					spawn(function()
						wait(0.5)
						TweenService:Create(
							clone3,
							TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
						wait()
						TweenService:Create(
							clone3,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					local v4 = clone3
					spawn(function()
						wait()
						TweenService:Create(v4, TweenInfo.new(1, Enum.EasingStyle.Quad), {
							Color = color2
						}):Play()
					end)
				end

				for _ = 1, 4 do
					local size = Vector3.new(
						math.random(190, 240) / 10,
						math.random(190, 240) / 10,
						math.random(190, 240) / 10
					) * 1.2
					local clone3 = replicatedStorage.Chest.FruitEffect.Venom.cartoon_smoke:Clone()
					clone3.CFrame = CFrame.new(position2) * CFrame.new(
						math.random(-10, 10),
						math.random(-3, 2),
						math.random(-10, 10)
					) * CFrame.Angles(
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2,
						math.random() * 3.141592653589793 * 2
					)
					clone3.Color = instance.Color
					clone3.Parent = workspace.Effects
					clone3.ParticleEmitter:Emit(math.random(4, 6))
					_G.PU:Dust(clone3, 2)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = size
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone3.CFrame * CFrame.Angles(
							math.random() * 3.141592653589793 * 2,
							math.random() * 3.141592653589793 * 2,
							math.random() * 3.141592653589793 * 2
						) * CFrame.new(0, 0, math.random(-3, -1))
					}):Play()
					spawn(function()
						wait(0.5)
						TweenService:Create(
							clone3,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
						wait(0.2)
						TweenService:Create(
							clone3,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end
			end
		end)
	elseif player.fx == "gasu_z" then
		if player.ty ~= "land" then
			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.35
			}, function(p)
				local v2 = math.floor(p * 3)
				spawn(function()
					local v3 = v2 == 1 and -45 or v2 == 3 and 0 or 45
					local v4 = CFrame.new(player.root.CFrame.p, player.mouse) * CFrame.Angles(0, 0, (math.rad(v3)))
					v:Shake(CameraShaker.Presets.Bump)
					local clone = replicatedStorage.Chest.FruitEffect.Gas.gas_slash:Clone()
					_G.PU:Dust(clone, 3)
					clone.CFrame = v4 * CFrame.new(0, 0, -5)
					clone.Anchored = true
					clone.Mesh.Scale = Vector3.new()
					clone.Parent = workspace.Effects

					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						emitter:Emit(math.random(2, 3))
					end

					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://6780412894",
						Volume = 1.5
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://6780413304",
						Volume = 1.5
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone
					sound2:Play()
					TweenService:Create(
						clone.Mesh,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Scale = createVector(25, 0.5, 25)
						}
					):Play()
					spawn(function()
						wait(0.35)

						if clone:FindFirstChild("decal") then
							TweenService:Create(
								clone.decal,
								TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
						end
					end)
					PeodizService.ForLoop({
						Step = 10,
						WaitTime = 0.05
					}, function(p2)
						if not clone then
							return true
						end

						math.floor(p2 * 10)

						for _, emitter in pairs(clone:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							emitter.Enabled = true
							emitter:Emit(1)
						end

						TweenService:Create(
							clone,
							TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.new(0, 0, -15)
							}
						):Play()
					end)
					local v5 = {}

					for _, emitter in pairs(clone:GetDescendants()) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end

					task.delay(10, function()
						table.clear(v5)
					end)
				end)
			end)
			return
		end

		local character = player.Character
		local root = player.root
		PeodizService.ForLoop({
			Step = 3,
			WaitTime = 0.35
		}, function(p)
			local v2 = math.floor(p * 3)

			if player.Player == game.Players.LocalPlayer then
				task.spawn(function()
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

					if not humanoidRootPart then
						return
					end

					local cframe = CFrame.new(humanoidRootPart.Position, player.mouse)
					local ray = Ray.new(cframe.p, humanoidRootPart.CFrame.LookVector * 25)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local _ = raycastResult and raycastResult.Instance
					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
					local v3 = CFrame.new(position) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p)
					PeoUtils.LerpCF(
						humanoidRootPart,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						v3
					)
				end)
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6795736413",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = root
			sound:Play()
			spawn(function()
				local v3 = v2 == 1 and -45 or v2 == 3 and 0 or 45
				local v4 = root.CFrame * CFrame.Angles(0, 0, (math.rad(v3)))

				if (localPlayer2.Character.HumanoidRootPart.Position - v4.p).Magnitude < 20 then
					v:Shake(CameraShaker.Presets.Bump)
				end

				local part = Instance.new("Part")
				_G.PU:Dust(part, 1)
				part.Transparency = 1
				part.Anchored = true
				part.Color = Color3.fromRGB(0, 255, 0)
				part.CanCollide = false
				part.Material = Enum.Material.Neon
				part.Size = createVector(1.5, 1.5, 1.5)
				part.CFrame = v4 * CFrame.Angles(0, -0.9250245035569946, 0) * CFrame.new(0, 0, -20)
				part.Parent = workspace.Effects
				local clone = replicatedStorage.Chest.FruitEffect.Gas.blueflame:Clone()
				clone.Parent = part
				clone.Enabled = true
				clone:Emit(math.random(8, 10))
				local clone2 = replicatedStorage.Chest.FruitEffect.Gas.gas_slash:Clone()
				_G.PU:Dust(clone2, 1)
				clone2.CFrame = v4 * CFrame.Angles(0, 0.3141592653589793, 0) * CFrame.Angles(0, -1.0471975511965976, 0) * CFrame.new(
					0,
					0,
					-5
				)
				clone2.Anchored = true
				clone2.Mesh.Scale = Vector3.new()
				clone2.Parent = workspace.Effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6780412894",
					Volume = 1.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone2
				sound2:Play()
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6780413304",
					Volume = 1.5
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = clone2
				sound3:Play()
				TweenService:Create(
					clone2.Mesh,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(25, 0.5, 25)
					}
				):Play()
				spawn(function()
					wait(0.3)

					if clone2:FindFirstChild("decal") then
						TweenService:Create(
							clone2.decal,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end)
				local v5 = {}
				PeodizService.ForLoop({
					Step = 10,
					WaitTime = 0.05
				}, function(p2)
					local v6 = math.floor(p2 * 10)
					local part2 = Instance.new("Part")
					part2.Transparency = 0.5
					part2.Anchored = true
					part2.Color = Color3.fromRGB(255, 255, 0)
					part2.CanCollide = false
					part2.Material = Enum.Material.Neon
					part2.Size = createVector(1, 1, 1)
					part2.CFrame = v4 * CFrame.Angles(0, v6 * 3.455751918948773 / 10 - 1.5707963267948966, 0) * CFrame.new(
						0,
						0,
						v6 / 10 * -5
					)
					part2.Parent = workspace.Effects
					_G.PU:Dust(part2, 1)
					clone:Emit(math.random(2, 3))
					local _ = CFrame.new(part2.CFrame.p) * (v4 - v4.p)
					TweenService:Create(
						clone2,
						TweenInfo.new(0.05714285714285715, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = v4 * CFrame.Angles(0, v6 * 3.455751918948773 / 10 - 1.5707963267948966, 0) * CFrame.Angles(
								0,
								-1.0471975511965976,
								0
							) * CFrame.new(0, 0, v6 / 10 * -8 + 2)
						}
					):Play()
					TweenService:Create(
						part,
						TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = part2.CFrame * CFrame.new(0, 0, -20)
						}
					):Play()
					part2.Transparency = 1
					v5[#v5 + 1] = (part2.CFrame * CFrame.new(0, 0, -21)).p

					if v5[v6 - 1] then
						local part3 = Instance.new("Part")
						part3.Material = "Neon"
						part3.CastShadow = false
						part3.Size = Vector3.new(0.5, 0.5, (v5[v6 - 1] - v5[v6]).magnitude)
						part3.Color = Color3.fromRGB(116, 188, 255)
						part3.Anchored = true
						part3.Transparency = 0
						part3.CanCollide = false
						part3.CFrame = CFrame.new((v5[v6 - 1] + v5[v6]) / 2, v5[v6 - 1])
						part3.Parent = workspace.Effects
						spawn(function()
							wait(0.2)
							TweenService:Create(
								part3,
								TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(0, 0, part3.Size.Z)
								}
							):Play()
							TweenService:Create(
								part3,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Transparency = 1
								}
							):Play()
							TweenService:Create(
								part3,
								TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Color = Color3.fromRGB(67, 96, 118)
								}
							):Play()
						end)
						_G.PU:Dust(part3, 1)
					end
				end)
				task.delay(10, function()
					table.clear(v5)
				end)
				clone.Enabled = false
				_G.PU:Dust(part, 2)
			end)
		end)
	elseif player.fx == "gasu_v" then
		local char = player.char
		local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
		local siz = player.siz
		local part = Instance.new("Part")
		part.Size = Vector3.new()
		part.Transparency = 1
		part.CastShadow = false
		part.Massless = true
		part.CanCollide = false
		part.Anchored = false
		part.Color = Color3.fromRGB(255, 124, 216)
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.ForceField
		part.Parent = workspace.Effects
		local weld = Instance.new("Weld")
		weld.Parent = humanoidRootPart
		weld.Part0 = humanoidRootPart
		weld.Part1 = part
		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 0.75,
			Size = createVector(1, 1, 1) * siz
		}):Play()
		PeodizService.HeartbeatWait({
			Time = 60,
			WaitTime = 0.05
		}, function()
			if char:FindFirstChild("GasZone") then
				return
			else
				return true
			end
		end)
		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = Vector3.new()
		}):Play()
		_G.PU:Dust(part, 1)
		_G.PU:Dust(weld, 1)
	elseif player.fx == "gasu_x" then
		tick()
		local beam = player.beam
		local mouse = game.Players.LocalPlayer:GetMouse()
		tick()
		PeodizService.new({
			Time = 60
		}, function()
			if not beam:IsDescendantOf(workspace.Effects) then
				return true
			end

			if game.Players.LocalPlayer == player.Player then
				mouse.TargetFilter = workspace.Effects
				beam.CFrame = CFrame.new(player.part.CFrame.p, mouse.Hit.p) * CFrame.new(0, 0, -beam.Size.X / 2) * CFrame.Angles(
					0,
					1.5707963267948966,
					0
				)
			end

			for _, texture in pairs(beam:GetChildren()) do
				if texture:IsA("Texture") then
					texture.OffsetStudsU += 1
				end
			end
		end)
	elseif player.fx == "gasu_c" then
		local cf = player.cf
		local _ = player.tocf
		local _ = player.mag
		local count = player.count

		if (localPlayer2.Character.HumanoidRootPart.Position - player.Position).Magnitude < 50 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		PeodizService.ForLoop({
			Step = count,
			WaitTime = 0.05
		}, function(p)
			local v2 = math.floor(p * count)
			local part = Instance.new("Part")
			part.Transparency = 1
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 255, 0)
			part.CanCollide = false
			part.Material = Enum.Material.Neon
			part.Size = createVector(1, 1, 1)
			part.CFrame = cf * CFrame.new(0, 0, -v2 * 50)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			local part2 = Instance.new("Part")
			_G.PU:Dust(part2, 3)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6814067199",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = part2
			sound:Play()
			part2.Shape = "Ball"
			part2.Material = "Neon"
			part2.Color = Color3.fromRGB(212, 154, 95)
			part2.CastShadow = false
			part2.Anchored = true
			part2.CanCollide = false
			part2.CFrame = cf * CFrame.new(0, 0, -v2 * 50)
			part2.Size = Vector3.new()
			part2.Parent = workspace.Effects
			TweenService:Create(part2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(50, 50, 50)
			}):Play()
			local clone = replicatedStorage.Chest.FruitEffect.Gas.Rings:Clone()
			clone.CFrame = cf * CFrame.new(0, 0, -v2 * 50) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Size = Vector3.new()
			clone.Transparency = -3
			clone.Color = Color3.fromRGB(212, 154, 95)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = createVector(84.72, 2.6750002, 84.72),
				Transparency = 1
			}):Play()
			spawn(function()
				wait(0.1)

				if clone then
					TweenService:Create(
						clone,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB()
						}
					):Play()
				end
			end)
			_G.PU:Dust(clone, 1)
			task.spawn(function()
				task.wait(0.2)

				if part2 then
					TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Color = Color3.fromRGB(),
						Size = Vector3.new()
					}):Play()
				end
			end)

			if (localPlayer2.Character.HumanoidRootPart.Position - part2.CFrame.p).Magnitude < 35 then
				v:Shake(CameraShaker.Presets.SmallestBump)
			end
		end)
	elseif player.fx == "gasu_exp" then
		local position = player.Position

		if (localPlayer2.Character.HumanoidRootPart.Position - position).Magnitude < 75 or game.Players.LocalPlayer == player.Player then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local clone = replicatedStorage.Chest.FruitEffect.Gas.explode_fx:Clone()
		_G.PU:Dust(clone, 1.5)
		clone.CFrame = CFrame.new(position)
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9167832679",
			Volume = 0.1
		})
		_G.PU:Dust(sound, 1.5)
		sound.Parent = clone
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1250,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5025347100",
			Volume = 0.1
		})
		_G.PU:Dust(sound2, 1.5)
		sound2.Parent = clone
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1250,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://165970126",
			Volume = 0.25
		})
		_G.PU:Dust(sound3, 1.5)
		sound3.Parent = clone
		sound3:Play()
		TweenService:Create(clone.PointLight, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Range = 10,
			Brightness = 0
		}):Play()

		local function fx()
			local beamcf = player.beamcf
			local range = player.range
			local step = math.floor((beamcf.p - (beamcf * CFrame.new(0, 0, range)).p).magnitude / 25) - 1
			PeodizService.ForLoop({
				Step = step
			}, function(p)
				local v3 = math.floor(p * step)
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Transparency = 0.65
				clone2.Size = Vector3.new()
				clone2.CFrame = beamcf * CFrame.new(0, 0, -v3 * 25) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-35, 35))),
					math.rad((math.random(-35, 35))),
					(math.rad((math.random(-35, 35))))
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(33.074997, 3.67, 33.074997)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 1)
				local clone3 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone3.Anchored = true
				clone3.Color = Color3.fromRGB(55, 95, 167)
				clone3.Size = Vector3.new()
				clone3.CanCollide = false
				clone3.Transparency = 0
				clone3.Size = Vector3.new()
				clone3.CFrame = beamcf * CFrame.new(0, 0, -v3 * 25) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-15, 15))),
					math.rad((math.random(-15, 15))),
					(math.rad((math.random(-15, 15))))
				)
				clone3.Parent = workspace.Effects
				local v4 = createVector(43.9668, 0.9117, 43.967518) * v3 / step
				TweenService:Create(
					clone3,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						Size = createVector(58.622402, 1.2156, 58.62336) - v4
					}
				):Play()
				_G.PU:Dust(clone3, 1)
			end)
		end

		fx()
		PeodizService.ForLoop({
			Step = 5
		}, function(p)
			math.floor(p * 5)
			local v2 = math.random(50, 75)
			local cFrame = CFrame.new(player.Position) * CFrame.new(
				math.random(-5, 5),
				math.random(-5, 5),
				math.random(-5, 5)
			)
			local clone2 = replicatedStorage.Chest.FruitEffect.Gas.cartoon_smoke:Clone():Clone()
			clone2.Color = Color3.fromRGB(55, 95, 167)
			clone2.Material = Enum.Material.Neon
			clone2.Size = createVector(10, 10, 10)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			clone2.blueflame:Emit(math.random(1, 3))
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone2, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(v2, v2, v2)
			}):Play()
			_G.PU:Dust(clone2, 1.5)
			delay(0.05, function()
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
					Color = Color3.fromRGB(),
					Size = createVector(0, 0, 0),
					CFrame = clone2.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, math.random(20, 25))
				}):Play()
			end)
			local clone3 = replicatedStorage.Chest.FruitEffect.Gas.Shockowave:Clone()
			clone3.Anchored = true
			clone3.CanCollide = false
			clone3.Transparency = 0.35
			clone3.Size = Vector3.new()
			clone3.CFrame = CFrame.new(player.Position) * CFrame.Angles(
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793
			)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(66.149994, 7.34, 66.149994)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone3, 1)
		end)
	elseif player.fx == "gate_of_babylon" then
		local _ = player.hit
		local pos = player.pos
		local cf = player.cf
		local dist = player.dist

		local function getsize(clone)
			local v2 = {}
			local Z = clone:GetExtentsSize().Z
			local Y = clone:GetExtentsSize().Y
			local X = clone:GetExtentsSize().X
			table.insert(v2, 1, Z)
			table.insert(v2, 2, Y)
			table.insert(v2, 3, X)
			table.sort(v2, function(a, b)
				return b < a
			end)
			task.delay(10, function()
				table.clear(v2)
			end)
			return v2
		end

		local clone = replicatedStorage.Chest.FruitEffect.Gilgamesh.gob:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = CFrame.new(cf.p, pos)
		local clone2 = replicatedStorage.Chest.FruitEffect.Gilgamesh.Swords:GetChildren()[math.random(
			1,
			#replicatedStorage.Chest.FruitEffect.Gilgamesh.Swords:GetChildren()
		)]:Clone()
		clone2.Parent = workspace.Effects
		clone2.PrimaryPart.Anchored = true
		clone2.PrimaryPart.CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
			0,
			getsize(clone2)[1] / 2 - 5,
			0
		)
		_G.PU:Dust(clone2, 0.75)
		_G.PU:Dust(clone, 1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6908134238",
			Volume = 0.65,
			PlaybackSpeed = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local attachment = Instance.new("Attachment", clone2.PrimaryPart)
		attachment.Position = createVector(0, -0.1, 0)
		local attachment2 = Instance.new("Attachment", clone2.PrimaryPart)
		attachment2.Position = createVector(0, 0.1, 0)
		local clone3 = replicatedStorage.Chest.FruitEffect.Gilgamesh.Trail:Clone()
		clone3.Parent = clone2
		clone3.Attachment0 = attachment
		clone3.Attachment1 = attachment2
		clone3.Enabled = true
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone2.PrimaryPart
		pointLight.Color = Color3.fromRGB(255, 231, 133)
		pointLight.Brightness = 2
		pointLight.Range = 20
		TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = 0
		}):Play()
		spawn(function()
			clone.Attachment.square.Enabled = true
			clone.Attachment.square:Emit(50)
			wait(0.3)
			clone.Attachment.square.Enabled = false
		end)

		for _, part in pairs(clone2:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			local transparency = part.Transparency

			if part.Transparency ~= 1 then
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = transparency
				}):Play()
			end

			part.Transparency = 1
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
					0,
					getsize(clone2)[1] / 2,
					0
				)
			}):Play()
			local parent = part
			spawn(function()
				wait(0.25)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6908055534",
					Volume = 0.65
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = parent
				sound2:Play()
				TweenService:Create(
					parent,
					TweenInfo.new(dist / 500, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, dist, 0)
					}
				):Play()
				wait(dist / 650)
				TweenService:Create(
					parent,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()

				for i = 1, math.random(3, 4) do
					local clone4 = replicatedStorage.Chest.FruitEffect.Gilgamesh.cartoon_ball:Clone()
					clone4.Parent = workspace.Effects
					clone4.CFrame = CFrame.new(pos) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone4.Anchored = true
					clone4.CanCollide = false
					clone4.Size = createVector(5.16, 5.16, 5.16)
					clone4.Color = Color3.fromRGB(212, 177, 95)
					TweenService:Create(
						clone4,
						TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(),
							Color = Color3.fromRGB(255, 255, 255)
						}
					):Play()
					TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone4.CFrame * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						) * CFrame.new(0, 0, math.random(8, 10))
					}):Play()
					_G.PU:Dust(clone4, 0.3)
				end
			end)
		end
	elseif player.fx == "exterminate" then
		local position = player.Position

		for i = 1, 7 do
			for i2 = 1, 7 do
				local v2 = CFrame.new(position) * CFrame.Angles(0, 0.8975979010256552 * i2, 0) * CFrame.Angles(
					0.8975979010256552 * i,
					0,
					0
				) * CFrame.new(0, 0, -30)

				local function getsize(clone)
					local v3 = {}
					local Z = clone:GetExtentsSize().Z
					local Y = clone:GetExtentsSize().Y
					local X = clone:GetExtentsSize().X
					table.insert(v3, 1, Z)
					table.insert(v3, 2, Y)
					table.insert(v3, 3, X)
					table.sort(v3, function(a, b)
						return b < a
					end)
					task.delay(10, function()
						table.clear(v3)
					end)
					return v3
				end

				local clone = replicatedStorage.Chest.FruitEffect.Gilgamesh.gob2:Clone()
				clone.Parent = workspace.Effects
				clone.CFrame = CFrame.new(v2.p, position)
				local clone2 = replicatedStorage.Chest.FruitEffect.Gilgamesh.Swords:GetChildren()[math.random(
					1,
					#replicatedStorage.Chest.FruitEffect.Gilgamesh.Swords:GetChildren()
				)]:Clone()
				clone2.Parent = workspace.Effects
				clone2.PrimaryPart.Anchored = true
				clone2.PrimaryPart.CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
					0,
					getsize(clone2)[1] / 2 - 5,
					0
				)
				_G.PU:Dust(clone2, 0.75)
				_G.PU:Dust(clone, 1)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6908134238",
					Volume = 0.35,
					PlaybackSpeed = 1.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local attachment = Instance.new("Attachment", clone2.PrimaryPart)
				attachment.Position = createVector(0, -0.1, 0)
				local attachment2 = Instance.new("Attachment", clone2.PrimaryPart)
				attachment2.Position = createVector(0, 0.1, 0)
				local clone3 = replicatedStorage.Chest.FruitEffect.Gilgamesh.Trail:Clone()
				clone3.Parent = clone2
				clone3.Attachment0 = attachment
				clone3.Attachment1 = attachment2
				clone3.Enabled = true
				local pointLight = Instance.new("PointLight")
				pointLight.Parent = clone2.PrimaryPart
				pointLight.Color = Color3.fromRGB(255, 231, 133)
				pointLight.Brightness = 2
				pointLight.Range = 20
				TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Brightness = 0,
					Range = 0
				}):Play()
				spawn(function()
					clone.Attachment.square.Enabled = true
					clone.Attachment.square:Emit(50)
					wait(0.3)
					clone.Attachment.square.Enabled = false
				end)

				for _, part in pairs(clone2:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.CanCollide = false
					local transparency = part.Transparency

					if part.Transparency ~= 1 then
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = transparency
							}
						):Play()
					end

					part.Transparency = 1
					TweenService:Create(
						part,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
								0,
								getsize(clone2)[1] / 2,
								0
							)
						}
					):Play()
					local parent = part
					local parent2 = clone
					spawn(function()
						wait(0.25)
						local sound2 = PeoUtils.CreateSound({
							RollOffMaxDistance = 1000,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://6908055534",
							Volume = 0.35
						})
						_G.PU:Dust(sound2, 3)
						sound2.Parent = parent
						sound2:Play()
						TweenService:Create(
							parent,
							TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								CFrame = parent2.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
									0,
									30,
									0
								)
							}
						):Play()
						wait(0.046153846153846156)
						TweenService:Create(
							parent,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end
			end
		end

		wait(0.29615384615384616)
		spawn(function()
			for i = 1, 10 do
				local clone = replicatedStorage.Chest.FruitEffect.Gilgamesh.Shockowave:Clone()
				clone.CFrame = CFrame.new(position) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)

				if i == 1 then
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://6533511567",
						Volume = 3
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://6814067199",
						Volume = 3,
						PlaybackSpeed = 0.8
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone
					sound2:Play()
				end

				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(189, 13.5, 189)
				}):Play()
				spawn(function()
					wait()
					TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
			end
		end)

		for _ = 1, 5 do
			local clone = replicatedStorage.Chest.FruitEffect.Gilgamesh.cartoon_ball:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(position) * CFrame.new(
				math.random(-10, 10),
				math.random(-10, 10),
				math.random(-10, 10)
			) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = Vector3.new()
			clone.Color = Color3.fromRGB(212, 190, 77)
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(70, 70, 70)
			}):Play()
			_G.PU:Dust(clone, 0.75)
			spawn(function()
				wait(0.1)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = clone.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, 50),
					Color = Color3.fromRGB(255, 255, 255),
					Size = Vector3.new()
				}):Play()
			end)
		end
	elseif player.fx == "gamma_new" then
		local tocf = player.tocf
		local cf = player.cf
		local sword = player.Sword

		if sword then
			TweenService:Create(sword, TweenInfo.new(0.5), {
				Transparency = 1
			}):Play()

			if sword:FindFirstChild("PointLight") then
				TweenService:Create(sword.PointLight, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
			end
		end

		if player.plrname == game.Players.LocalPlayer then
			TweenService:Create(
				localPlayer2.Character.HumanoidRootPart,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = tocf
				}
			):Play()
		end

		local clone = replicatedStorage.Chest.FruitEffect.OpNew.Shock:Clone()
		clone.CFrame = cf * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Transparency = 0.7
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2)
		local clone2 = replicatedStorage.Chest.FruitEffect.OpNew.Sphere:Clone()
		clone2.CFrame = cf
		clone2.Size = createVector(0, 0, 0)
		clone2.Transparency = 0
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 0.5)
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(20, 20, 250),
			CFrame = cf * CFrame.new(0, 0, -125)
		}):Play()
		spawn(function()
			wait(0.05)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 250)
			}):Play()
			wait(0.2)
			TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = createVector(135.729, 180.73, 141.865),
			CFrame = cf * CFrame.new(0, 0, -90) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
		}):Play()
		local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.Rings2:Clone()
		_G.PU:Dust(clone3, 2)
		clone3.CFrame = cf * CFrame.Angles(1.5707963267948966, 0, 0)
		clone3.Transparency = 0
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.new(0, 5, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(202.336, 2.701, 202.336)
		}):Play()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6913221705",
			Volume = 4
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone3
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6913223016",
			Volume = 4
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3
		sound2:Play()
		spawn(function()
			wait()
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local clone4 = replicatedStorage.Chest.FruitEffect.OpNew.slash2:Clone()
		_G.PU:Dust(clone4, 1.5)
		clone4.CFrame = cf * CFrame.Angles(0, 0, -0.7853981633974483)
		clone4.decal.Transparency = 0
		clone4.mesh.Scale = Vector3.new()
		clone4.Parent = workspace.Effects
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cf * CFrame.new(0, 0, -180) * CFrame.Angles(0, 0, -0.7853981633974483)
		}):Play()
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone4.mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = createVector(70.599, 6.205, 70.599)
		}):Play()
		spawn(function()
			wait(0.15)

			for _, child in pairs(clone4:GetChildren()) do
				if child.Name ~= "decal" then
					continue
				end

				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(
					child,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end

			PeodizService.ForLoop({
				Step = 6
			}, function(_)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.Angles(0, -0.2617993877991494, 0)
					}
				):Play()
			end)
		end)
		local clone5 = replicatedStorage.Chest.FruitEffect.OpNew.slash2:Clone()
		_G.PU:Dust(clone5, 1.5)
		clone5.CFrame = cf * CFrame.Angles(0, 0, 0.7853981633974483)
		clone5.decal.Transparency = 0
		clone5.mesh.Scale = Vector3.new()
		clone5.Parent = workspace.Effects
		local TweenService4 = game:GetService("TweenService")
		TweenService4:Create(clone5, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = cf * CFrame.new(0, 0, -180) * CFrame.Angles(0, 0, 0.7853981633974483)
		}):Play()
		local TweenService5 = game:GetService("TweenService")
		TweenService5:Create(clone5.mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Scale = createVector(70.599, 6.205, 70.599)
		}):Play()
		spawn(function()
			wait(0.15)

			for _, child in pairs(clone5:GetChildren()) do
				if child.Name ~= "decal" then
					continue
				end

				local TweenService6 = game:GetService("TweenService")
				TweenService6:Create(
					child,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end

			PeodizService.ForLoop({
				Step = 6
			}, function(_)
				TweenService:Create(
					clone5,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.Angles(0, 0.2617993877991494, 0)
					}
				):Play()
			end)
		end)
		local v2 = {}

		for i = 1, 10 do
			local v3 = 15 + i * 3.5
			v2[#v2 + 1] = (cf * CFrame.new(0, 0, -(250 - 25 * i)) * CFrame.new(
				math.random(-v3, v3),
				math.random(-5, v3),
				math.random(-v3, v3)
			)).p
		end

		if (player.Position - localPlayer2.Character.HumanoidRootPart.CFrame.p).magnitude < 50 then
			v:Shake(CameraShaker.Presets.Stand)
		end

		spawn(function()
			PeodizService.ForceForLoop({
				Step = #v2
			}, function(p)
				local v3 = math.floor(p * #v2)

				if v2[v3 - 1] then
					local v4 = math.random(125, 200) / 100
					local color = Color3.fromRGB(51, 85, 23)

					if math.random(1, 2) == 1 then
						color = Color3.fromRGB(202, 255, 151)
					end

					local part = Instance.new("Part")
					part.Parent = workspace.Effects
					part.Material = "Neon"
					part.CastShadow = false
					part.Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
					part.Color = Color3.fromRGB(120, 191, 132)
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
					}):Play()
					spawn(function()
						wait(0.05)
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Color = color,
							Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
						}):Play()
						wait()
						TweenService:Create(
							part,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(part, 1)
				end
			end)
			task.delay(10, function()
				table.clear(v2)
			end)
		end)
		PeodizService.ForLoop({
			Step = 4,
			WaitTime = 0.05
		}, function(p)
			local v3 = math.floor(p * 4)
			local clone6 = replicatedStorage.Chest.FruitEffect.OpNew.Shockwave:Clone()
			clone6.CFrame = cf * CFrame.new(12 - v3 * 3 + 15, 0, 112.5 - v3 * 62.5) * CFrame.Angles(
				0,
				1.658062789394613,
				0
			)
			clone6.Anchored = true
			clone6.Parent = workspace.Effects
			_G.PU:Dust(clone6, 1)
			local clone7 = replicatedStorage.Chest.FruitEffect.OpNew.Shockwave:Clone()
			clone7.CFrame = cf * CFrame.new(-(12 - v3 * 3 + 15), 0, 112.5 - v3 * 62.5) * CFrame.Angles(
				0,
				1.4835298641951802,
				0
			)
			clone7.Anchored = true
			clone7.Parent = workspace.Effects
			_G.PU:Dust(clone7, 1)
			clone6.Size = createVector(0, 0, 2)
			clone7.Size = createVector(0, 0, 2)
			local clone8 = replicatedStorage.Chest.FruitEffect.OpNew.Ring:Clone()
			clone8.CFrame = cf * CFrame.new(0, 0, 112.5 - v3 * 62.5) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				6.283185307179586 * math.random(),
				0,
				0
			)
			clone8.Transparency = 0
			clone8.Size = Vector3.new(3.062, (2 - v3 * 3 / 10) * 94.973, (2 - v3 * 3 / 10) * 96.049) / 2
			clone8.Parent = workspace.Effects
			local TweenService6 = game:GetService("TweenService")
			TweenService6:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone8.CFrame * CFrame.Angles(3.141592653589793, 0, 0),
				Size = Vector3.new(3.062, (2 - v3 * 3 / 10) * 94.973, (2 - v3 * 3 / 10) * 96.049)
			}):Play()
			spawn(function()
				wait(0.1)
				local TweenService7 = game:GetService("TweenService")
				TweenService7:Create(
					clone8,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			_G.PU:Dust(clone8, 1)
			local clone9 = replicatedStorage.Chest.FruitEffect.OpNew.shocksmoke:Clone()
			clone9.Parent = workspace.Effects
			clone9.CFrame = cf * CFrame.new(12 - v3 * 3 + 15, 0, 62.5 - v3 * 62.5) * CFrame.Angles(
				0,
				1.658062789394613,
				0
			)
			clone9.sm2:Emit(40)
			_G.PU:Dust(clone9, 1.5)
			local clone10 = replicatedStorage.Chest.FruitEffect.OpNew.shocksmoke:Clone()
			clone10.Parent = workspace.Effects
			clone10.CFrame = cf * CFrame.new(-(12 - v3 * 3 + 15), 0, 62.5 - v3 * 62.5) * CFrame.Angles(
				0,
				1.4835298641951802,
				0
			)
			clone10.sm2:Emit(40)
			clone10.sm2.EmissionDirection = "Front"
			_G.PU:Dust(clone10, 1.5)
			TweenService:Create(clone6, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(12 - v3 * 3 + 15, (70 - v3 * 5) / 2, 62.5 - v3 * 62.5) * CFrame.Angles(
					0,
					1.658062789394613,
					0
				)
			}):Play()
			TweenService:Create(clone7, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(-(12 - v3 * 3 + 15), (70 - v3 * 5) / 2, 62.5 - v3 * 62.5) * CFrame.Angles(
					0,
					1.4835298641951802,
					0
				)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(123.157, 70.877 - v3 * 5, 0.05)
			}):Play()
			TweenService:Create(clone7, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(123.157, 70.877 - v3 * 5, 0.05)
			}):Play()
			spawn(function()
				wait(0.2)
				wait(0.1)
				TweenService:Create(
					clone7,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				TweenService:Create(
					clone6,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end)
	elseif player.fx == "shock_fx" then
		local cf = player.cf
		local v2 = {}

		for _ = 1, 8 do
			local v3 = math.random(55, 70) / 10
			v2[#v2 + 1] = (cf * CFrame.new(math.random(-v3, v3), math.random(-5, v3), math.random(-v3, v3))).p
		end

		local color = Color3.fromRGB(255, 232, 116)

		if math.random(1, 2) == 1 then
			color = Color3.fromRGB(134, 217, 255)
		end

		spawn(function()
			PeodizService.ForceForLoop({
				Step = #v2
			}, function(p)
				local v3 = math.floor(p * #v2)

				if v2[v3 - 1] then
					local v4 = math.random(50, 120) / 300
					local color2

					if color == Color3.fromRGB(255, 232, 116) then
						color2 = Color3.fromRGB(85, 68, 28)

						if math.random(1, 2) == 1 then
							color2 = Color3.fromRGB(255, 240, 184)
						end
					else
						color2 = Color3.fromRGB(25, 52, 85)

						if math.random(1, 2) == 1 then
							color2 = Color3.fromRGB(194, 234, 255)
						end
					end

					local part = Instance.new("Part")
					part.Material = "Neon"
					part.CastShadow = false
					part.Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
					part.Color = color
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
					}):Play()
					spawn(function()
						wait(0.05)
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Color = color2,
							Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
						}):Play()
						wait()
						TweenService:Create(
							part,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(part, 1)
				end
			end)
			task.delay(10, function()
				table.clear(v2)
			end)
		end)
	elseif player.fx == "gamma_fx" then
		local cf = player.cf
		local v2 = {}

		for _ = 1, 8 do
			local v3 = math.random(55, 70) / 10
			v2[#v2 + 1] = (cf * CFrame.new(math.random(-v3, v3), math.random(-5, v3), math.random(-v3, v3))).p
		end

		spawn(function()
			PeodizService.ForceForLoop({
				Step = #v2
			}, function(p)
				local v3 = math.floor(p * #v2)

				if v2[v3 - 1] then
					local v4 = math.random(50, 120) / 300
					local color = Color3.fromRGB(51, 85, 23)

					if math.random(1, 2) == 1 then
						color = Color3.fromRGB(202, 255, 151)
					end

					local part = Instance.new("Part")
					part.Material = "Neon"
					part.CastShadow = false
					part.Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
					part.Color = Color3.fromRGB(120, 191, 132)
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
					}):Play()
					spawn(function()
						wait(0.05)
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Color = color,
							Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
						}):Play()
						wait()
						TweenService:Create(
							part,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(part, 1)
				end
			end)
			task.delay(10, function()
				table.clear(v2)
			end)
		end)
	elseif player.fx == "shock" then
		local cf = player.cf
		local root = player.root

		if (localPlayer2.Character.HumanoidRootPart.Position - player.Position).Magnitude < 30 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6948300574",
			Volume = 4
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = root
		sound:Play()
		spawn(function()
			local clone = replicatedStorage.Chest.FruitEffect.OpNew.CS.Rings:Clone()
			clone.CFrame = cf * CFrame.new(0, -5, 0)
			clone.Size = createVector(17.036, 0.957, 17.036)
			clone.Transparency = 0.5
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(90.321, 5, 90.321)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 12.5, 0)
			}):Play()
			wait(wait() * 3)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
		end)
		spawn(function()
			local clone = replicatedStorage.Chest.FruitEffect.OpNew.CS.shock3:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.new(cf.p) * CFrame.new(0, 25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = createVector(30, 30, 51.937)
			clone.Transparency = 0
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(0.05, 0.05, 65.836)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
			local clone2 = replicatedStorage.Chest.FruitEffect.OpNew.CS.shock3:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = CFrame.new(cf.p) * CFrame.new(0, 25, 0) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			clone2.Size = createVector(30, 30, 51.937)
			clone2.Color = Color3.fromRGB(234, 248, 140)
			clone2.Transparency = 0
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(0.05, 0.05, 65.836)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, 0, 3.141592653589793)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 1)
		end)
		spawn(function()
			local clone = replicatedStorage.Chest.FruitEffect.OpNew.CS.Shock2:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = cf
			clone.Size = createVector(11.034, 8.169, 10.983)
			clone.Transparency = 0.75
			TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(76.327, 42.455, 75.971)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			wait(wait())
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
		end)

		for _ = 1, 4 do
			local color = Color3.fromRGB(255, 232, 116)

			if math.random(1, 2) == 1 then
				color = Color3.fromRGB(134, 217, 255)
			end

			spawn(function()
				local pointLight = Instance.new("PointLight")
				pointLight.Range = 50
				pointLight.Brightness = 1
				pointLight.Color = color
				pointLight.Parent = root
				TweenService:Create(
					pointLight,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 0,
						Brightness = 0
					}
				):Play()
				_G.PU:Dust(pointLight, 1)
				local p = cf.p
				local p2 = (cf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -math.random(40, 50))).p
				local v2 = {}

				for i = 0, 4 do
					local v3 = math.random(60, 70) / 10
					Vector3.new(math.random(-v3, v3), math.random(-v3, v3), math.random(-v3, v3))
					local vector2 = Vector3.new(math.random(-v3, v3), math.random(-v3, v3), math.random(-v3, v3))
					local v4 = p + (p2 - p).Unit * i * (p2 - p).magnitude / 4
					local v5 = i == 0 and createVector(0, 0, 0) or vector2
					v2[#v2 + 1] = v4 + v5
				end

				task.spawn(function()
					PeodizService.ForceForLoop({
						Step = #v2
					}, function(p3)
						local v3 = math.floor(p3 * #v2)

						if v2[v3 - 1] then
							local v4 = math.random(100, 125) / 95

							if color == Color3.fromRGB(255, 232, 116) then
								Color3.fromRGB(85, 68, 28)

								if math.random(1, 2) == 1 then
									Color3.fromRGB(255, 240, 184)
								end
							else
								Color3.fromRGB(25, 52, 85)

								if math.random(1, 2) == 1 then
									Color3.fromRGB(194, 234, 255)
								end
							end

							local part = Instance.new("Part")
							part.Material = "Neon"
							part.CastShadow = false
							part.Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
							part.Color = color
							part.Anchored = true
							part.Transparency = 0
							part.CanCollide = false
							part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
							part.Parent = workspace.Effects
							spawn(function()
								wait(0.01 + math.random(0, 5) / 200)
								TweenService:Create(
									part,
									TweenInfo.new(
										math.random(15, 20) / 100,
										Enum.EasingStyle.Exponential,
										Enum.EasingDirection.Out
									),
									{
										Transparency = 1,
										Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
									}
								):Play()
								wait()
							end)
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v2)
					end)
				end)
				local clone = replicatedStorage.Chest.FruitEffect.OpNew.CS.Shockowave:Clone()
				clone.CFrame = cf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone.Transparency = 0.75
				clone.Size = createVector(10.716, 1.189, 10.716) * math.random(10, 15) / 10
				clone.Color = color
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(102.492, 8, 102.492),
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}
				):Play()
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 1)
			end)
		end

		PeodizService.ForLoop({
			Step = 3,
			WaitTime = 0.03
		}, function(_)
			local clone = replicatedStorage.Chest.FruitEffect.OpNew.CS.MeshPart:Clone()
			clone.CFrame = cf * CFrame.new(0, -7, 0)
			clone.Size = createVector(70, 6, 70)
			clone.Transparency = 0
			TweenService:Create(clone, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20, 0, 20)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone.CFrame * CFrame.new(0, 50, 0)
			}):Play()
			wait(0.001)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6965606009",
				Volume = 2.5,
				PlaybackSpeed = 1.25
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = root
			sound2:Play()

			for _ = 1, 4 do
				local color = Color3.fromRGB(255, 232, 116)

				if math.random(1, 2) == 1 then
					color = Color3.fromRGB(134, 217, 255)
				end

				spawn(function()
					local pointLight = Instance.new("PointLight")
					pointLight.Range = 50
					pointLight.Brightness = 1
					pointLight.Color = color
					pointLight.Parent = root
					TweenService:Create(
						pointLight,
						TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Range = 0,
							Brightness = 0
						}
					):Play()
					_G.PU:Dust(pointLight, 1)
					local p = cf.p
					local p2 = (CFrame.new(cf.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
						1.5707963267948966 + math.rad((math.random(-90, 90))),
						0,
						1.5707963267948966 + math.rad((math.random(-90, 90)))
					) * CFrame.new(0, 0, -math.random(40, 50))).p
					local v2 = {}

					for i = 0, 4 do
						local v3 = math.random(60, 70) / 10
						Vector3.new(math.random(-v3, v3), math.random(-v3, v3), math.random(-v3, v3))
						local vector2 = Vector3.new(math.random(-v3, v3), math.random(-v3, v3), math.random(-v3, v3))
						local v4 = p + (p2 - p).Unit * i * (p2 - p).magnitude / 4
						local v5 = i == 0 and createVector(0, 0, 0) or vector2
						v2[#v2 + 1] = v4 + v5
					end

					PeodizService.ForceForLoop({
						Step = #v2
					}, function(p3)
						local v3 = math.floor(p3 * #v2)

						if v2[v3 - 1] then
							local v4 = math.random(50, 125) / 200

							if color == Color3.fromRGB(255, 232, 116) then
								Color3.fromRGB(85, 68, 28)

								if math.random(1, 2) == 1 then
									Color3.fromRGB(255, 240, 184)
								end
							else
								Color3.fromRGB(25, 52, 85)

								if math.random(1, 2) == 1 then
									Color3.fromRGB(194, 234, 255)
								end
							end

							local part = Instance.new("Part")
							part.Material = "Neon"
							part.CastShadow = false
							part.Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
							part.Color = color
							part.Anchored = true
							part.Transparency = 0
							part.CanCollide = false
							part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
							part.Parent = workspace.Effects
							TweenService:Create(
								part,
								TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
								}
							):Play()
							spawn(function()
								wait(0.02 + math.random(0, 10) / 200)
								TweenService:Create(
									part,
									TweenInfo.new(
										math.random(15, 20) / 100,
										Enum.EasingStyle.Exponential,
										Enum.EasingDirection.Out
									),
									{
										Transparency = 1,
										Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
									}
								):Play()
								wait()
							end)
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v2)
					end)
					local clone2 = replicatedStorage.Chest.FruitEffect.OpNew.CS.Shockowave:Clone()
					clone2.CFrame = cf * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone2.Transparency = 0.75
					clone2.Size = createVector(10.716, 1.189, 10.716) * math.random(10, 15) / 10
					clone2.Color = color
					clone2.Parent = workspace.Effects
					TweenService:Create(
						clone2,
						TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(102.492, 8, 102.492),
							CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
						}
					):Play()
					TweenService:Create(
						clone2,
						TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					_G.PU:Dust(clone2, 1)
					wait(0.05)

					for _ = 1, 2 do
						local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.CS.Neon:Clone()
						clone3.CFrame = cf * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						clone3.Size = createVector(1, 1, 1) * math.random(10, 15) / 10
						clone3.Color = color
						clone3.Parent = workspace.Effects
						TweenService:Create(
							clone3,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								CFrame = cf * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								) * CFrame.new(0, 0, -math.random(45, 55))
							}
						):Play()
						spawn(function()
							wait(0.05)
							TweenService:Create(
								clone3,
								TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(),
									Transparency = 1
								}
							):Play()
						end)
						_G.PU:Dust(clone3, 1)
					end
				end)
			end
		end)
	elseif player.fx == "mes_new" then
		local cf = player.cf
		local tocf = player.tocf

		if player.plrname == localPlayer then
			localPlayer2.Character.HumanoidRootPart.CFrame = tocf
		end

		local clone = replicatedStorage.Chest.FruitEffect.OpNew.shock1:Clone()
		clone.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Transparency = 0.25
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = createVector(31.472, 57.032, 30.742),
			CFrame = cf * CFrame.new(0, 0, -25) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
		}):Play()
		_G.PU:Dust(clone, 2)
		local clone2 = replicatedStorage.Chest.FruitEffect.OpNew.Sphere:Clone()
		clone2.CFrame = cf
		clone2.Color = Color3.fromRGB(239, 66, 66)
		clone2.Size = createVector(0, 0, 0)
		clone2.Transparency = 0
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 0.5)
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(6, 6, 50),
			CFrame = cf * CFrame.new(0, 0, -25)
		}):Play()
		spawn(function()
			wait(0.05)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 50),
				Color = Color3.fromRGB(157, 69, 69)
			}):Play()
			wait(0.2)
			TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local clone3 = replicatedStorage.Chest.FruitEffect.OpNew.shocksmoke2:Clone()
		clone3.CFrame = cf * CFrame.Angles(0, 0.08726646259971647, 0) * CFrame.new(5, 0, -20)
		clone3.Parent = workspace.Effects
		clone3.sm2:Emit(15)
		_G.PU:Dust(clone3, 1.5)
		local clone4 = replicatedStorage.Chest.FruitEffect.OpNew.shocksmoke2:Clone()
		clone4.CFrame = cf * CFrame.Angles(0, -0.08726646259971647, 0) * CFrame.new(-5, 0, -20)
		clone4.Parent = workspace.Effects
		clone4.sm2:Emit(15)
		clone4.sm2.EmissionDirection = "Left"
		_G.PU:Dust(clone4, 1.5)

		for i = 1, 4 do
			for i2 = 1, math.random(2, 3) do
				local color = Color3.fromRGB(204, 119, 119)

				if math.random(1, 2) == 1 then
					color = Color3.fromRGB(255, 90, 84)
				end

				local clone5 = replicatedStorage.Chest.FruitEffect.OpNew.Windo:Clone()
				clone5.Transparency = 0.25
				clone5.Size = Vector3.new(1, 18 * (2 - i2 * 3 / 10), 18 * (2 - i2 * 3 / 10)) / 2
				clone5.Color = color
				clone5.CFrame = cf * CFrame.new(0, 0, 15 - 15 * i2) * CFrame.new(0, 0, math.random(-30, 30) / 10) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone5.CFrame = clone5.CFrame * CFrame.new(0, 0, math.random(4, 6)) * CFrame.Angles(
					0,
					-0.7853981633974483,
					0
				)
				clone5.Parent = workspace.Effects
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone5,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(12.174, 0.05, 10.988)
					}
				):Play()
				spawn(function()
					wait(0.2)
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(
						clone5,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				_G.PU:Dust(clone5, 1)
			end

			local clone5 = replicatedStorage.Chest.FruitEffect.OpNew.shock2:Clone()
			clone5.CFrame = cf * CFrame.new(0, 0, 15 - 15 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				6.283185307179586 * math.random(),
				0,
				0
			)
			clone5.Transparency = 0.8
			clone5.Size = Vector3.new(1, 18 * (2 - i * 3 / 10), 18 * (2 - i * 3 / 10)) / 2
			clone5.Parent = workspace.Effects
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone5, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.Angles(3.141592653589793, 0, 0),
				Size = Vector3.new(1, 18 * (2 - i * 3 / 10), 18 * (2 - i * 3 / 10))
			}):Play()
			spawn(function()
				wait(0.25)
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(
					clone5,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			_G.PU:Dust(clone5, 1)
		end
	elseif player.fx == "spike_z" then
		local fromcf = player.fromcf
		local cfs = player.cfs
		PeodizService.ForLoop({
			Step = 20,
			WaitTime = 0.05
		}, function(p)
			local v2 = math.floor(p * 20)
			task.spawn(function()
				local root = player.root
				fromcf = player.fromcf

				if root:IsDescendantOf(workspace) then
					fromcf = root.CFrame
				end

				local v3 = math.random(-10, 10)
				local clone = replicatedStorage.Chest.FruitEffect.Spike.Spike:Clone()
				_G.PU:Dust(clone, 1)
				clone.CFrame = fromcf * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://7755413059",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://7763544596",
					Volume = 0.5,
					PlaybackSpeed = 1.15
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone
				sound2:Play()
				local cf = cfs[v2]
				local cframe = CFrame.new(clone.CFrame.p, cf.p)
				local magnitude = (clone.CFrame.p - cf.p).magnitude
				local clone2 = replicatedStorage.Chest.FruitEffect.Spike.Rings:Clone()
				clone2.Transparency = -1
				clone2.Material = Enum.Material.Neon
				clone2.Color = Color3.fromRGB(183, 202, 219)
				clone2.CFrame = CFrame.new(clone.CFrame.p, (cframe * CFrame.new(0, 0, -magnitude)).p) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				)
				clone2.CFrame *= CFrame.new(0, 7, 0)
				clone2.Parent = workspace.Effects
				game.TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					Size = createVector(6, 0.3, 6) * math.random(10, 15) / 10,
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 1)
				local clone3 = replicatedStorage.Chest.FruitEffect.Spike.slash:Clone()
				_G.PU:Dust(clone3, 1)
				clone3.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone3.Mesh.Scale = Vector3.new()
				clone3.Parent = workspace.Effects
				game.TweenService:Create(
					clone3.Mesh,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(6.1140003, 0.03525, 6.1140003)
					}
				):Play()
				game.TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, -1)
				}):Play()
				task.spawn(function()
					wait(0.1)

					if clone3:FindFirstChild("Decal") then
						game.TweenService:Create(
							clone3.Decal,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end
				end)
				clone.Attachment.Spark2:Emit(3)
				PeodizService.ForLoop({
					Step = 10
				}, function(p2)
					local v4 = math.floor(p2 * 10)
					local cframe2 = CFrame.new(0, math.sin(3.141592653589793 * v4 / 10) * v3, -magnitude / 10 * v4)
					game.TweenService:Create(clone, TweenInfo.new(0.1), {
						CFrame = CFrame.new((cframe * cframe2).p, clone.CFrame.p) * CFrame.Angles(
							0,
							3.141592653589793,
							0
						) * CFrame.Angles(-1.5707963267948966, 0, 0)
					}):Play()
				end)

				if (localPlayer2.Character.HumanoidRootPart.CFrame.p - cf.p).magnitude < 60 then
					v:Shake(CameraShaker.Presets.SmallestBump)
				end

				local clone4 = replicatedStorage.Chest.FruitEffect.Spike.Impact:Clone()
				clone4.CFrame = cf
				clone4.Parent = workspace.Effects
				clone4.Attachment.Circle:Emit(1)
				clone4.Attachment.Spark:Emit(1)
				_G.PU:Dust(clone4, 1)
				clone.Transparency = 1
				_G.PU:Dust(clone, 1)
			end)
		end)
	elseif player.fx == "spike_x" then
		local fromcf = player.fromcf
		local char = player.char
		local root = player.root
		tick()
		PeodizService.HeartbeatWait({
			Time = 3,
			WaitTime = 0.05
		}, function()
			if char:FindFirstChild("SpikeCF") and char and root then
				task.spawn(function()
					local v2 = math.random(-10, 10) * 0.15
					local v3 = math.random(-10, 10) * 0.15
					local cFrame = root.CFrame or fromcf

					if (localPlayer2.Character.HumanoidRootPart.CFrame.p - cFrame.p).magnitude < 10 then
						v:Shake(CameraShaker.Presets.SmallestBump)
					end

					local clone = replicatedStorage.Chest.FruitEffect.Spike.whiteslash:Clone()
					_G.PU:Dust(clone, 1)
					clone.Anchored = true
					clone.Transparency = 0
					clone.CanCollide = false
					clone.Size = createVector(11.97, 0.175, 13.332)
					clone.CFrame = cFrame * CFrame.new(v2, v3, -math.random(80, 100) / 10) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://7763544596",
						Volume = 1
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					game.TweenService:Create(
						clone,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = createVector(14.962501, 0.32875, 16.664999)
						}
					):Play()
					game.TweenService:Create(
						clone,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0)
						}
					):Play()
					spawn(function()
						game.TweenService:Create(
							clone,
							TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					local clone2 = replicatedStorage.Chest.FruitEffect.Spike.Rings:Clone()
					clone2.Transparency = 0.95
					clone2.Material = Enum.Material.Neon
					clone2.Color = Color3.fromRGB(183, 202, 219)
					clone2.CFrame = cFrame * CFrame.new(v2, v3, -math.random(80, 100) / 10) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone2.Parent = workspace.Effects
					game.TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
						Size = createVector(48, 0.4, 48),
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone2, 1)
					local part = Instance.new("Part")
					_G.PU:Dust(part, 1)
					part.Anchored = true
					part.Transparency = 0
					part.CastShadow = false
					part.Size = createVector(2.58, 0.958, 0.7)
					part.Material = Enum.Material.Neon
					part.Color = Color3.fromRGB(200, 200, 200)
					part.CanCollide = false
					part.CFrame = cFrame * CFrame.new(-v2, -v3, -math.random(80, 100) / 10) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					part.Parent = workspace.Effects
					local specialMesh = Instance.new("SpecialMesh")
					specialMesh.MeshType = Enum.MeshType.Sphere
					specialMesh.Parent = part
					game.TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(25.25, 0.1, 0.25)
						}
					):Play()
					spawn(function()
						game.TweenService:Create(
							part,
							TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end)
			else
				return true
			end
		end)
	elseif player.fx == "spike_c" then
		local humanoidRootPart = localPlayer2.Character.HumanoidRootPart
		local angle = player.angle
		local cf = player.cf

		if (humanoidRootPart.CFrame.p - cf.p).magnitude < 15 then
			v:Shake(CameraShaker.Presets.SmallerBump)
		end

		local clone = replicatedStorage.Chest.FruitEffect.Spike.slashprojectile:Clone()
		_G.PU:Dust(clone, 2)
		clone.CFrame = cf * angle
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7763544596",
			Volume = 1.25,
			PlaybackSpeed = 0.95
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		game.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 0, -100)
		}):Play()
		wait(0.2)
		game.TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		local cFrame = cf * CFrame.new(0, 0, -100)
		local clone2 = replicatedStorage.Chest.FruitEffect.Spike.particles:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = workspace.Effects
		clone2.Attachment.big:Emit(1)
		clone2.Attachment.residue:Emit(15)
		clone2.Attachment.sm2:Emit(30)
		clone2.Attachment.spark:Emit(15)
		_G.PU:Dust(clone2, 2)
		local clone3 = replicatedStorage.Chest.FruitEffect.Spike.windshockwave2:Clone()
		clone3.Size = createVector(-5, -5, -5)
		clone3.Transparency = -2
		clone3.CFrame = cFrame
		clone3.CFrame = CFrame.new(clone3.CFrame.Position) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 2)
		game.TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		game.TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(30, 30, 30)
		}):Play()
		game.TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.Angles(0.7853981633974483, 0.7853981633974483, 0.7853981633974483)
		}):Play()
		local clone4 = replicatedStorage.Chest.FruitEffect.Spike.Ring:Clone()
		clone4.Size = Vector3.new()
		clone4.Transparency = -3
		clone4.CFrame = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone4.Parent = workspace.Effects
		_G.PU:Dust(clone4, 1)
		local clone5 = replicatedStorage.Chest.FruitEffect.Spike.Ball:Clone()
		_G.PU:Dust(clone5, 1.5)
		clone5.Size = Vector3.new()
		clone5.Transparency = -3
		clone5.CFrame = CFrame.new(cFrame.p)
		clone5.Parent = workspace.Effects
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 750,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://365002938",
			Volume = 1,
			TimePosition = 0.15
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone5
		sound2:Play()
		game.TweenService:Create(clone5, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(40, 40, 40)
		}):Play()
		game.TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		if (humanoidRootPart.CFrame.p - cFrame.p).magnitude < 40 then
			v:Shake(CameraShaker.Presets.Bump)
		end
	elseif player.fx == "spike_v" then
		local _ = player.plr

		if not player.char then
			return
		end

		local spike = player.spike
		local char = player.char
		spike.Anchored = false

		if not spike then
			return
		end

		local v2 = 1
		local v3 = {}
		local v4 = {}
		local v5 = 1
		local v6 = 1
		game.TweenService:Create(spike, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(21, 21, 21)
		}):Play()

		if (localPlayer2.Character.HumanoidRootPart.CFrame.p - player.Position).magnitude < 30 then
			shake({
				4,
				5,
				0,
				1
			}) -- equivalent call inferred; original call site unknown
		end

		task.spawn(function()
			if player.plr == game.Players.LocalPlayer then
				PeodizService.new({
					Time = 15
				}, function()
					if not (spike:IsDescendantOf(workspace.Effects) and char:IsDescendantOf(workspace.PlayerCharacters) and char:FindFirstChild("SpikeVBool")) then
						return true
					end

					v2 += 1
					spike.CFrame = char.HumanoidRootPart.CFrame
					spike.CFrame *= CFrame.Angles(math.rad(v2 * 50), 0, 0)
				end)
			end
		end)
		local lastTime = tick()
		local lastTime2 = tick()
		PeodizService.new({
			Time = 15
		}, function()
			if not (char:FindFirstChild("SpikeVBool") and char:IsDescendantOf(workspace.PlayerCharacters)) then
				return true
			end

			local cFrame = char.HumanoidRootPart.CFrame

			if tick() - lastTime2 > 0.25 then
				lastTime2 = tick()
				v:Shake(CameraShaker.Presets.SmallestBump)
			end

			if tick() - lastTime > 0.075 then
				lastTime = tick()
				local _, _, _ = cFrame:ToOrientation()
				local vector2 = Vector3.new(math.random(-50, 50) / 100, math.random(-50, 50) / 100, 0)
				local v7 = -math.random(50, 70)
				local v8 = math.random(10, 15) / 10
				task.spawn(function()
					local ray = Ray.new((cFrame * CFrame.new(-5.5, 0, -5)).p, createVector(0, -20, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

					if instance then
						v6 += 1
						v4[v6] = {
							position,
							instance.Color,
							instance.Material,
							instance
						}
					end

					if v4[v6] and v4[v6 - 1] then
						local part = Instance.new("Part")
						part.Material = v4[v6][3]
						pcall(function()
							part.MaterialVariant = v3[v5][4].MaterialVariant
						end)
						part.CastShadow = false
						part.Size = Vector3.new(0, 0, (v4[v6 - 1][1] - v4[v6][1]).magnitude)
						part.Color = v4[v6][2]
						part.Anchored = true
						part.Transparency = 0
						part.CanCollide = false
						part.CFrame = CFrame.new((v4[v6 - 1][1] + v4[v6][1]) / 2, v4[v6 - 1][1]) * CFrame.Angles(
							0,
							0,
							(math.rad(-v7))
						)
						part.Position += Vector3.new(0, -(v8 + 4), 0)
						part.Parent = workspace.Effects

						if v4[v6][4]:FindFirstChild("Texture") then
							local texture = v4[v6][4]:FindFirstChild("Texture")
							local clone = texture:Clone()
							clone.Parent = part
							clone.Face = "Top"
							local clone2 = texture:Clone()
							clone2.Parent = part
							clone2.Face = "Bottom"
							local clone3 = texture:Clone()
							clone3.Parent = part
							clone3.Face = "Back"
							local clone4 = texture:Clone()
							clone4.Parent = part
							clone4.Face = "Front"
							local clone5 = texture:Clone()
							clone5.Parent = part
							clone5.Face = "Right"
							local clone6 = texture:Clone()
							clone6.Parent = part
							clone6.Face = "Left"
						end

						game.TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(4, 4, (v4[v6 - 1][1] - v4[v6][1]).magnitude) + vector2,
								Position = part.Position + createVector(0, 4, 0)
							}
						):Play()
						task.spawn(function()
							wait(1)
							game.TweenService:Create(
								part,
								TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(0, 0, (v4[v6 - 1][1] - v4[v6][1]).magnitude)
								}
							):Play()
						end)
						_G.PU:Dust(part, 1.5)
					end
				end)
				task.spawn(function()
					local ray = Ray.new((cFrame * CFrame.new(5.5, 0, -5)).p, createVector(0, -20, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

					if instance then
						v5 += 1
						v3[v5] = {
							position,
							instance.Color,
							instance.Material,
							instance
						}
					end

					if v3[v5] and v3[v5 - 1] then
						local part = Instance.new("Part")
						part.Material = v3[v5][3]
						pcall(function()
							part.MaterialVariant = v3[v5][4].MaterialVariant
						end)
						part.CastShadow = false
						part.Size = Vector3.new(0, 0, (v3[v5 - 1][1] - v3[v5][1]).magnitude)
						part.Color = v3[v5][2]
						part.Anchored = true
						part.Transparency = 0
						part.CanCollide = false
						part.CFrame = CFrame.new((v3[v5 - 1][1] + v3[v5][1]) / 2, v3[v5 - 1][1]) * CFrame.Angles(
							0,
							0,
							(math.rad(v7))
						)
						part.Position += Vector3.new(0, -(v8 + 4), 0)
						part.Parent = workspace.Effects

						if v3[v5][4]:FindFirstChild("Texture") then
							local texture = v3[v5][4]:FindFirstChild("Texture")
							local clone = texture:Clone()
							clone.Parent = part
							clone.Face = "Top"
							local clone2 = texture:Clone()
							clone2.Parent = part
							clone2.Face = "Bottom"
							local clone3 = texture:Clone()
							clone3.Parent = part
							clone3.Face = "Back"
							local clone4 = texture:Clone()
							clone4.Parent = part
							clone4.Face = "Front"
							local clone5 = texture:Clone()
							clone5.Parent = part
							clone5.Face = "Right"
							local clone6 = texture:Clone()
							clone6.Parent = part
							clone6.Face = "Left"
						end

						game.TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(4, 4, (v3[v5 - 1][1] - v3[v5][1]).magnitude) + vector2,
								Position = part.Position + createVector(0, 4, 0)
							}
						):Play()
						task.spawn(function()
							wait(1)
							game.TweenService:Create(
								part,
								TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(0, 0, (v3[v5 - 1][1] - v3[v5][1]).magnitude)
								}
							):Play()
						end)
						_G.PU:Dust(part, 1.5)
					end
				end)
			end
		end)
		task.delay(10, function()
			table.clear(v3)
			table.clear(v4)
		end)
		game.TweenService:Create(spike, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
	elseif player.fx == "smoke_charge" then
		local char = player.char
		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.1
		}, function()
			if char:IsDescendantOf(workspace.PlayerCharacters) and char:FindFirstChild("SmokeCharge") then
				local smokecharge = require(script.smokecharge)
				smokecharge(char)
			else
				return true
			end
		end)
	elseif player.fx == "smoke_z" then
		local _ = player.char
		local cf = player.cf
		task.spawn(function()
			local clone = replicatedStorage.Chest.FruitEffect.Smoke.WindRing:Clone()
			clone.Transparency = -1
			clone.CFrame = cf * CFrame.new(0, 0, -25) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Size = Vector3.new()
			clone.Parent = workspace.Effects
			game.TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(36.0165, 2.66325, 36.0165),
					CFrame = clone.CFrame * CFrame.new(0, 35, 0)
				}
			):Play()
			game.TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1)
			local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.Shock:Clone()
			clone2.CFrame = cf * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Transparency = 0.7
			clone2.Size = Vector3.new()
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 2)
			game.TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = createVector(51.325, 45.835, 40.757),
				CFrame = cf * CFrame.new(0, 0, -15) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
			}):Play()
			local clone3 = replicatedStorage.Chest.FruitEffect.Smoke.Ring:Clone()
			clone3.CFrame = cf * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				6.283185307179586 * math.random(),
				0,
				0
			)
			clone3.Transparency = 0
			clone3.Size = createVector(0.589, 11.368, 11.496)
			clone3.Parent = workspace.Effects
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.Angles(3.141592653589793, 0, 0),
				Size = createVector(1.859, 35.854, 36.26)
			}):Play()
			_G.PU:Dust(clone3, 1)
			spawn(function()
				wait(0.1)
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(
					clone3,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			PeodizService.ForLoop({
				Step = 6
			}, function(p)
				local v2 = math.floor(p * 6)
				local part = Instance.new("Part")
				part.Size = createVector(1, 1, 1)
				part.Anchored = true
				part.CFrame = cf * CFrame.new(-v2 * -2 - 3.5 - 12, 0, v2 * -6.666666666666667)
				part.CanCollide = false
				local part2 = Instance.new("Part")
				part2.Size = createVector(1, 1, 1)
				part2.Anchored = true
				part2.CFrame = cf * CFrame.new(v2 * -2 + 3.5 + 12, 0, v2 * -6.666666666666667)
				part2.CanCollide = false
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)
				local raycastResult2 = workspace:Raycast(part2.CFrame.p, createVector(0, -10, 0), raycastParams)
				local size = createVector(5, 5, 5) * (6 - v2 + 1) * 0.25

				if raycastResult and raycastResult.Instance then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Size = Vector3.new()
					part.Color = instance.Color
					part.Parent = workspace.Effects
					game.TweenService:Create(
						part,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = size,
							CFrame = CFrame.new(position + createVector(0, -1.5, 0)) * CFrame.Angles(
								math.random(-2, 2),
								math.random(-2, 2),
								math.random(-2, 2)
							)
						}
					):Play()
					spawn(function()
						wait(1 + v2 * wait())
						game.TweenService:Create(
							part,
							TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Position = part.Position - Vector3.new(0, size.Y * 1.25, 0)
							}
						):Play()
					end)
					_G.PU:Dust(part, 2)
				end

				if raycastResult2 and raycastResult2.Instance then
					local instance = raycastResult2.Instance
					local position = raycastResult2.Position
					part2.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part2.Material = instance.Material
					part2.MaterialVariant = instance.MaterialVariant
					part2.Size = Vector3.new()
					part2.Color = instance.Color
					part2.Parent = workspace.Effects
					game.TweenService:Create(
						part2,
						TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{
							Size = size,
							CFrame = CFrame.new(position + createVector(0, -1.25, 0)) * CFrame.Angles(
								math.random(-2, 2),
								math.random(-2, 2),
								math.random(-2, 2)
							)
						}
					):Play()
					spawn(function()
						wait(1 + v2 * wait())
						game.TweenService:Create(
							part2,
							TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Position = part2.Position - Vector3.new(0, size.Y * 1.25, 0)
							}
						):Play()
					end)
					_G.PU:Dust(part2, 2)
				end
			end)
		end)
	elseif player.fx == "smoke_z_charge" then
		local char = player.char
		local cf = player.cf

		if not (char and char:FindFirstChild("UpperTorso")) then
			return
		end

		local clone = replicatedStorage.Chest.FruitEffect.Smoke.SmokeFist:Clone()
		_G.PU:Dust(clone, 15)
		clone.Parent = workspace.Effects
		local track = clone.AnimationController:LoadAnimation(clone.AnimationController.Charge)
		local track2 = clone.AnimationController:LoadAnimation(clone.AnimationController.Cast)
		local weld = Instance.new("Weld")
		weld.Parent = char.UpperTorso
		weld.Part0 = weld.Parent
		weld.Part1 = clone.Fist
		weld.C0 = CFrame.Angles(0, 1.5707963267948966, 0)
		local BoneRigScale = require(replicatedStorage.Chest.Modules.BoneRigScale)
		BoneRigScale(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 22)
		TweenService:Create(weld, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			C0 = CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, -20)
		}):Play()
		local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.particles.particles:Clone()
		clone2.Parent = char.HumanoidRootPart
		clone2.Ring:Emit(2)
		track:Play()
		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.05
		}, function()
			if char:IsDescendantOf(workspace.PlayerCharacters) and char:FindFirstChild("SmokeCharge") then
				cf = char.HumanoidRootPart.CFrame
			else
				return true
			end
		end)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5801257793",
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone.Fist
		sound:Play()
		_G.PU:Dust(clone2, 1)

		if (localPlayer2.Character.HumanoidRootPart.CFrame.p - cf.p).magnitude < 40 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		track:Stop()
		track2:Play()
		track2:AdjustSpeed(2)
		task.spawn(function()
			wait(0.5)
			local BoneRigScale2 = require(replicatedStorage.Chest.Modules.BoneRigScale)
			BoneRigScale2(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 0)
			TweenService:Create(weld, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				C0 = CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
		end)
		_G.PU:Dust(clone, 1)
		TweenService:Create(weld, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			C0 = CFrame.Angles(0, 2.443460952792061, 0) * CFrame.new(0, 0, -18)
		}):Play()
	elseif player.fx == "smoke_x" then
		local fromcf = player.fromcf
		local tocf = player.tocf

		if game.Players.LocalPlayer == player.plr then
			v:Shake(CameraShaker.Presets.SmallestBump)
		end

		local step = math.floor((fromcf.p - tocf.p).magnitude / 6) + 1
		local clone = replicatedStorage.Chest.FruitEffect.Smoke.SmokeMamba:Clone()
		clone["Body.001"].Size = createVector(2, 2, 11.34)
		clone["Body.001"].CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, -6) * CFrame.Angles(
			0.4363323129985824,
			0,
			0
		)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7956798871",
			Volume = 5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone["Body.001"]
		sound:Play()
		clone.Parent = workspace.Effects
		local track = clone.AnimationController:LoadAnimation(clone.AnimationController.Animation)
		track:Play()
		track:AdjustSpeed(2)

		for _, bone in pairs(clone:GetDescendants()) do
			bone:IsA("Bone")
		end

		TweenService:Create(clone["Body.001"], TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(11.1625, 13.190001, 14.175)
		}):Play()
		local v3 = nil
		task.spawn(function()
			wait(0.2)
			v3 = TweenService:Create(
				clone["Body.001"],
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true, 0),
				{
					Size = createVector(12.598751, 14.8875, 16)
				}
			)
			v3:Play()
		end)
		PeodizService.ForLoop({
			Step = step
		}, function(p)
			local v4 = math.floor(p * step)

			if v4 % 2 == 1 then
				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.shockwave:Clone()
				clone2.Size = Vector3.new()
				clone2.CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, v4 * -6 + 6) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(20, 2, 20)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.5)
			end

			local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
			clone2.Size = createVector(0, 0, 7.5)
			clone2.CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, v4 * -6 + 6) * CFrame.Angles(
				0,
				0,
				6.283185307179586 * math.random()
			)
			clone2.Parent = workspace.Effects
			clone2.spark:Emit(math.random(0, 2))
			local v5 = math.random(0, 10) / 10
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(9 + v5, 9 + v5, 8)
			}):Play()
			TweenService:Create(
				clone["Body.001"],
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(fromcf.p, tocf.p) * CFrame.new(0, 0, (v4 + 1) * -6 + 6) * CFrame.new(0, 0, -2.5) * CFrame.Angles(
						0.4363323129985824,
						0,
						0
					)
				}
			):Play()
			task.spawn(function()
				wait(0.1)
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, -3.5)
				}):Play()
				wait(0.05)
				TweenService:Create(
					clone2,
					TweenInfo.new(math.random(50, 75) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				_G.PU:Dust(clone2, 0.75)
			end)
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
			}):Play()
		end)
		task.spawn(function()
			wait(0.1 + wait(0.05))

			if v3 then
				v3:Pause()
			end

			TweenService:Create(
				clone["Body.001"],
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Transparency = 1,
					Size = Vector3.new()
				}
			):Play()
			_G.PU:Dust(clone, 1.5)
		end)
		PeodizService.ForLoop({
			Step = 5
		}, function(_)
			task.spawn(function()
				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
				clone2.Color = Color3.fromRGB(180, 180, 180)
				clone2.Size = Vector3.new()
				clone2.Transparency = 0
				clone2.CastShadow = false
				clone2.CFrame = tocf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(-5, 5))
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(25.562, 24.193, 28.606) * math.random(150, 200) / 100
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Quad), {
					CFrame = clone2.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, -math.random(5, 15))
				}):Play()
				wait(0.1)
				TweenService:Create(clone2, TweenInfo.new(math.random(75, 125) / 100, Enum.EasingStyle.Quad), {
					Color = Color3.fromRGB()
				}):Play()
				wait(0.1)
				wait(0.15)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			task.spawn(function()
				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
				clone2.Color = Color3.fromRGB(180, 180, 180)
				clone2.Size = createVector(11.1625, 13.190001, 14.175)
				clone2.Transparency = 0
				clone2.CastShadow = false
				clone2.CFrame = tocf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(-5, 5))
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, -math.random(20, 25))
				}):Play()
				wait(0.05)
				TweenService:Create(clone2, TweenInfo.new(math.random(75, 125) / 100, Enum.EasingStyle.Quad), {
					Color = Color3.fromRGB()
				}):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(math.random(75, 100) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
			end)
		end)

		if (localPlayer2.Character.HumanoidRootPart.CFrame.p - tocf.p).magnitude < 60 or game.Players.LocalPlayer == player.plr then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.Sphere:Clone()
		clone2.Size = createVector(0, 5, 0)
		clone2.CFrame = tocf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone2.Parent = workspace.Effects
		clone2.spark:Emit(6)
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, true, 0), {
			Size = createVector(5, 100, 5)
		}):Play()
		task.spawn(function()
			wait(0.35)
			TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local clone3 = replicatedStorage.Chest.FruitEffect.Smoke.swirl:Clone()
		_G.PU:Dust(clone3, 1)
		clone3.Transparency = 0.7
		clone3.Size = Vector3.new()
		clone3.CFrame = tocf
		clone3.Parent = workspace.Effects
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 750,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://365002938",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3
		sound2:Play()
		TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(70.2334, 70.2334, 70.2334)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
		}):Play()
		wait(0.1)
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	elseif player.fx == "smoke_c" then
		local cf = player.cf

		if (localPlayer2.Character.HumanoidRootPart.CFrame.p - cf.p).magnitude < 30 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		for i = 1, 3 do
			local v2 = i
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 7
				}, function(p)
					local v3 = math.floor(p * 7)
					local clone = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
					clone.Size = Vector3.new()
					clone.CFrame = cf * CFrame.Angles(0, math.rad(v2 * 15 + -15 - 15), 0) * CFrame.new(
						0,
						clone.Size.Y / 2.5,
						v3 * -1.95 * v3
					) * CFrame.new(0, 0, -2.5) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(6.25, 6.25, 6.25) * (v3 * 0.75)
					}):Play()
					TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = clone.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
					}):Play()
					_G.PU:Dust(clone, v3 / 20 + 0.75)
					task.spawn(function()
						wait(0.2)
						TweenService:Create(clone, TweenInfo.new(math.random(75, 125) / 100, Enum.EasingStyle.Quad), {
							Color = Color3.fromRGB()
						}):Play()
						wait(0.05)
						TweenService:Create(
							clone,
							TweenInfo.new(
								math.random(50, 75) / 100 + v3 / 20,
								Enum.EasingStyle.Exponential,
								Enum.EasingDirection.Out
							),
							{
								Size = createVector(0, 0, 0)
							}
						):Play()
						TweenService:Create(
							clone,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								CFrame = clone.CFrame * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								) * CFrame.new(0, 0, -math.random(10, 20))
							}
						):Play()
					end)
				end)
			end)
		end
	elseif player.fx == "smoke_v" then
		local TweenService2 = game:GetService("TweenService")
		local char = player.char
		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		local clone = replicatedStorage.Chest.FruitEffect.Smoke.SmokeMamba:Clone()
		clone["Body.001"].Anchored = false
		clone["Body.001"].CFrame = humanoidRootPart.CFrame
		clone["Body.001"].Massless = true
		clone["Body.001"].Size = Vector3.new()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 15)
		TweenService2:Create(clone["Body.001"], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(8.93, 10.552, 11.34)
		}):Play()
		local v2 = nil
		task.spawn(function()
			wait(0.325)
			v2 = TweenService2:Create(
				clone["Body.001"],
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 1e999, true, 0),
				{
					Size = createVector(10.079, 11.91, 12.8)
				}
			)
			v2:Play()
		end)

		if game.Players.LocalPlayer == player.plr then
			v:Shake(CameraShaker.Presets.Bump)
		end

		task.spawn(function()
			for _ = 1, math.random(4, 5) do
				pcall(function()
					local v3 = math.random(0, 30) / 10
					local body001 = clone["Body.001"]
					local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
					clone2.Size = (createVector(4.5, 4.5, 4.5) + Vector3.new(v3, v3, v3)) * 1.5
					clone2.CanCollide = false
					clone2.Massless = true
					clone2.Anchored = false
					clone2.Parent = workspace.Effects
					local weld = Instance.new("Weld")
					weld.Parent = body001
					weld.Part0 = body001
					weld.Part1 = clone2
					weld.C0 = CFrame.new() * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, -math.random(15, 30))
					TweenService2:Create(
						clone2,
						TweenInfo.new(
							math.random(65, 90) / 100,
							Enum.EasingStyle.Exponential,
							Enum.EasingDirection.Out,
							0,
							true,
							0
						),
						{
							Size = Vector3.new()
						}
					):Play()
					task.spawn(function()
						TweenService2:Create(
							weld,
							TweenInfo.new(math.random(25, 40) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								C0 = CFrame.new() * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								)
							}
						):Play()
						_G.PU:Dust(clone2, 1)
					end)
				end)
			end
		end)
		local track = clone.AnimationController:LoadAnimation(clone.AnimationController.Animation)
		track:Play()
		track:AdjustSpeed(2.5)
		local weld = Instance.new("Weld")
		weld.Parent = workspace.Effects
		weld.Part0 = humanoidRootPart
		weld.Part1 = clone["Body.001"]
		weld.C0 = CFrame.Angles(0.4363323129985824, 0, 0)
		clone["Body.001"].particles.Ring:Emit(2)
		local v3 = 1
		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.05
		}, function()
			if not (char:IsDescendantOf(workspace) and char:FindFirstChild("SmokeVBool") and humanoidRootPart) then
				return true
			end

			v3 += 1
			local ray = Ray.new(humanoidRootPart.CFrame.p, createVector(0, -20, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
			local _, v4, _ = humanoidRootPart.CFrame:ToOrientation()

			if instance then
				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeTrail:Clone()
				clone2.Parent = workspace.Effects
				clone2.Transparency = 1
				clone2.CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0)
				clone2.SmokeParticle:Emit(8)
				_G.PU:Dust(clone2, 1)
			elseif humanoidRootPart.CFrame.Y < 20 then
				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeTrail:Clone()
				clone2.Parent = workspace.Effects
				clone2.Transparency = 1
				clone2.CFrame = CFrame.new((Vector3.new(position.X, -2, position.Z))) * CFrame.fromOrientation(0, v4, 0)
				clone2.WaterFlow:Emit(4)
				_G.PU:Dust(clone2, 1)
			end

			if v3 % 2 == 1 then
				if game.Players.LocalPlayer == player.plr then
					v:Shake(CameraShaker.Presets.SmallestBump)
				end

				local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.shockwave:Clone()
				clone2.Size = Vector3.new()
				clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				TweenService2:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(20, 2, 20)
					}
				):Play()
				TweenService2:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.5)
			end

			local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
			clone2.Size = createVector(0, 0, 7.5)
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			clone2.spark:Emit(math.random(0, 2))
			local v5 = math.random(0, 10) / 10
			TweenService2:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new(8 + v5, 8 + v5, 7.5) * 1.1
			}):Play()
			task.spawn(function()
				wait(0.4)
				TweenService2:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CFrame = clone2.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, -3.5)
				}):Play()
				wait(0.1)
				TweenService2:Create(
					clone2,
					TweenInfo.new(math.random(50, 75) / 100, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0)
					}
				):Play()
				_G.PU:Dust(clone2, 0.75)
			end)
			TweenService2:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
			}):Play()
		end)

		if game.Players.LocalPlayer == player.plr then
			v:Shake(CameraShaker.Presets.Bump)
		end

		task.spawn(function()
			for _ = 1, math.random(5, 6) do
				pcall(function()
					local v4 = math.random(0, 30) / 10
					local body001 = clone["Body.001"]
					local clone2 = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
					clone2.Size = (createVector(4.5, 4.5, 4.5) + Vector3.new(v4, v4, v4)) * 1.5
					clone2.CanCollide = false
					clone2.Massless = true
					clone2.Anchored = false
					clone2.Parent = workspace.Effects
					local weld2 = Instance.new("Weld")
					weld2.Parent = body001
					weld2.Part0 = body001
					weld2.Part1 = clone2
					weld2.C0 = CFrame.new() * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					TweenService2:Create(
						clone2,
						TweenInfo.new(
							math.random(65, 90) / 100,
							Enum.EasingStyle.Exponential,
							Enum.EasingDirection.Out,
							0,
							true,
							0
						),
						{
							Size = Vector3.new()
						}
					):Play()
					task.spawn(function()
						TweenService2:Create(
							weld2,
							TweenInfo.new(math.random(25, 40) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{
								C0 = CFrame.new() * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								) * CFrame.new(0, 0, -math.random(10, 20))
							}
						):Play()
						_G.PU:Dust(clone2, 1)
					end)
				end)
			end
		end)
		TweenService2:Create(clone["Body.001"], TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new(),
			Transparency = 1
		}):Play()
		clone["Body.001"].Trail.Enabled = false
		clone["Body.001"].particles.Ring.Size = NumberSequence.new(0, 20)
		clone["Body.001"].particles.Ring:Emit(2)
		weld:Destroy()
		clone["Body.001"].Anchored = true
		_G.PU:Dust(clone, 1)
	end
end)
fSEffect.OnClientEvent:Connect(function(data)
	local localPlayer2 = game.Players.LocalPlayer

	if data.Position ~= nil and (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude > 500 then
		return
	end

	if type(data) == "table" then
		local player = data.Player

		if _G.ReturnEffects(localPlayer, player) then
			return
		end
	end

	if data.fx == "dragon_claw_z" then
		local magnitude = (data.cf1.p - data.cf2.p).magnitude
		spawn(function()
			local step = math.floor(magnitude / 15)
			PeodizService.ForLoop({
				Step = step,
				WaitTime = 0.05
			}, function(p)
				local v3 = math.floor(p * step)
				local size = createVector(10.932, 0.808, 10.932) * (6 - v3) * 0.7
				local clone = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
				clone.Color = Color3.fromRGB(213, 115, 61)
				clone.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, v3 * -15 + 15) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone.Size = size
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				TweenService:Create(
					clone,
					TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = size * 1.5,
						CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, v3 * -15 + 10) * CFrame.Angles(
							1.5707963267948966,
							0,
							0
						)
					}
				):Play()
			end)
		end)
		local clone = replicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
		clone.Color = Color3.fromRGB(213, 115, 61)
		clone.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		clone.Size = createVector(12, 12, 5)
		_G.PU:Dust(clone, 1)
		clone.Parent = workspace.Effects
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.Dragon:Clone()
		clone2.Color = Color3.fromRGB(213, 115, 61)
		clone2.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, 5)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(26.235, 23.044, 46.114),
			CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, -25)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		local clone3 = replicatedStorage.Chest.Etc.DragonClaw.Circle:Clone()
		clone3.Color = Color3.fromRGB(185, 159, 137)
		clone3.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1)
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(62.783, 2.243, 62.783),
			CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, 15) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 1)
		local clone4 = replicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
		clone4.Color = Color3.fromRGB(213, 115, 61)
		clone4.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, 0) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		clone4.Size = createVector(42.017, 42.017, 3.415)
		clone4.Parent = workspace.Effects
		_G.PU:Dust(clone4, 1)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(213, 168, 137)
		pointLight.Brightness = 1.25
		pointLight.Range = 40
		pointLight.Parent = clone2
		local clone5 = replicatedStorage.Chest.Etc.DragonClaw.Flame:Clone()
		clone5.Parent = clone4
		clone5:Emit(20)
		spawn(function()
			wait(0.2)
			clone5.Enabled = false
		end)
		_G.PU:Dust(clone5, 2)

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 46 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		TweenService:Create(pointLight, TweenInfo.new(0.9, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(23.057, 23.057, 88.903),
			CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.Angles(
				0,
				3.141592653589793,
				3.839724354387525
			)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone4, 1.5)

		for i = 1, 6 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(0, 0, -magnitude / 6 * i)
			part.CanCollide = false
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.Anchored = false
			part.Size = createVector(1, 1, 1) * math.random(7, 11) / 10
			part.Parent = workspace.Effects
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Parent = part
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Velocity = CFrame.new(data.cf1.p, data.cf2.p).LookVector * -math.random(35, 70) + CFrame.new(
				data.cf1.p,
				data.cf2.p
			).RightVector * math.random(-45, 45) + Vector3.new(0, math.random(40, 75), 0)
			_G.PU:Dust(bodyVelocity, 0.2)
			_G.PU:Dust(part, 2)
		end

		for i = 1, 6 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(
				-magnitude / 20 * -i - 6.5 - magnitude / 20 * 6,
				0,
				-magnitude / 6 * i
			)
			part.CanCollide = false
			local part2 = Instance.new("Part")
			part2.Size = createVector(1, 1, 1)
			part2.Anchored = true
			part2.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(
				-magnitude / 20 * i + 6.5 + magnitude / 20 * 6,
				0,
				-magnitude / 6 * i
			)
			part2.CanCollide = false
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)
			local raycastResult2 = workspace:Raycast(part2.CFrame.p, createVector(0, -10, 0), raycastParams)

			if raycastResult and raycastResult.Instance then
				local instance = raycastResult.Instance
				local position = raycastResult.Position
				part.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
					math.random(-2, 2),
					math.random(-2, 2),
					math.random(-2, 2)
				)
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = Color3.fromRGB()
				part.Size = createVector(1, 1, 1)
				part.Parent = workspace.Effects
				replicatedStorage.Chest.Etc.DragonClaw.flame:Clone().Parent = part
				TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
					Size = createVector(6, 6, 6),
					CFrame = CFrame.new(position + createVector(0, -1.5, 0)) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
				}):Play()
				local parent = part
				spawn(function()
					wait()
					TweenService:Create(parent, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
						Color = instance.Color
					}):Play()
				end)
				_G.PU:Dust(part, 2)
			end

			if not (raycastResult2 and raycastResult2.Instance) then
				continue
			end

			local instance = raycastResult2.Instance
			local position = raycastResult2.Position
			part2.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			part2.Material = instance.Material
			part2.MaterialVariant = instance.MaterialVariant
			part2.Color = Color3.fromRGB()
			part2.Size = createVector(1, 1, 1)
			part2.Parent = workspace.Effects
			replicatedStorage.Chest.Etc.DragonClaw.flame:Clone().Parent = part2
			TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
				Size = createVector(6, 6, 6),
				CFrame = CFrame.new(position + createVector(0, -1.25, 0)) * CFrame.Angles(
					math.random(-2, 2),
					math.random(-2, 2),
					math.random(-2, 2)
				)
			}):Play()
			local parent2 = part2
			spawn(function()
				wait()
				TweenService:Create(parent2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Color = instance.Color
				}):Play()
			end)
			_G.PU:Dust(part2, 2)
		end
	elseif data.fx == "dragon_claw_c" then
		PeodizService.ForLoop({
			Step = 30,
			WaitTime = 0.025
		}, function(p)
			math.floor(p * 30)
			local magnitude = (data.cf1.p - data.cf2.p).magnitude
			local v2 = math.random(-8, 8)
			local v3 = math.random(0, 8)
			local clone = replicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(213, 115, 61)
			clone.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, 0) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			clone.Size = createVector(19.252, 19.252, 1.565)
			clone.Parent = workspace.Effects
			local clone2 = replicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Color = Color3.fromRGB(213, 115, 61)
			clone2.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, -5)
			clone2.Size = createVector(8, 8, 5)
			clone2.Parent = workspace.Effects
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
			clone3.Color = Color3.fromRGB(175, 128, 89)
			clone3.CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, -10) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone3.Size = createVector(8.897, 0.658, 8.897)
			clone3.Parent = workspace.Effects
			local attachment = Instance.new("Attachment", clone)
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone
			pointLight.Color = Color3.fromRGB(213, 168, 137)
			pointLight.Brightness = 1.5
			pointLight.Range = 30
			local clone4 = replicatedStorage.Chest.Etc.DragonClaw.Flame2:Clone()
			clone4.Parent = attachment
			clone4:Emit(math.random(3, 5))
			clone4.Enabled = false
			TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Brightness = 0
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(8.374, 8.374, 23.01),
				CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, -magnitude / 1.15) * CFrame.Angles(
					0,
					3.141592653589793,
					3.839724354387525
				)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(21.166, 1.565, 21.166),
				CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, 1) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, magnitude - 5),
				CFrame = CFrame.new(data.cf1.p, data.cf2.p) * CFrame.new(v2, v3, -magnitude / 2 + 5)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1.5)
			_G.PU:Dust(clone3, 1)
			_G.PU:Dust(clone2, 1)
		end)
	elseif data.fx == "dragon_claw_v" then
		local clone = replicatedStorage.Chest.Etc.DragonClaw.FlameWind:Clone()
		clone.Size = createVector(2, 84.6, 2)
		clone.Color = Color3.fromRGB(213, 115, 61)
		clone.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 10, 0)
		clone.Parent = workspace.Effects
		clone.Flame:Emit(70)
		clone.Flame.Enabled = true
		_G.PU:Dust(clone, 3)
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.Crack:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -3, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(55.969, 55.969, 0.279)
		}):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(213, 168, 137)
		pointLight.Brightness = 1.5
		pointLight.Range = 40
		pointLight.Parent = clone2
		_G.PU:Dust(clone2, 3)
		TweenService:Create(clone2.Decal, TweenInfo.new(2.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2.Decal2, TweenInfo.new(2.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		local v2 = true
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(46.523, 56.6, 46.523)
		}):Play()
		spawn(function()
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 15,
				WaitTime = 0.05
			}, function()
				if not clone:IsDescendantOf(workspace) then
					return true
				end

				if tick() - lastTime > 0.175 and v2 then
					lastTime = tick()

					if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 20 then
						v:Shake(CameraShaker.Presets.SmallBump)
					end

					local clone3 = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
					clone3.Color = Color3.fromRGB(156, 139, 111)
					clone3.Transparency = 0.15
					clone3.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 5, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					clone3.Size = createVector(63.869, 4.723, 63.869)
					clone3.Parent = workspace.Effects
					TweenService:Create(
						clone3,
						TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(56.518, 4.856, 56.518),
							CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 55, 0) * CFrame.Angles(
								3.141592653589793,
								0,
								0
							)
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone3, 1)
				end

				TweenService:Create(clone, TweenInfo.new(0.125, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.Angles(0, 2.6179938779914944, 0)
				}):Play()
			end)
		end)

		for i = 1, 14 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CanCollide = false
			local p = (CFrame.new(data.cf.p) * CFrame.Angles(0, 0.4487989505128276 * i, 0) * CFrame.new(0, 0, -30)).p
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.4487989505128276 * i,
				0
			)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.Size = createVector(1, 1, 1)
			part.Parent = workspace.Effects
			local clone3 = replicatedStorage.Chest.Etc.DragonClaw.flame:Clone()
			clone3.Parent = part
			local vector2 = Vector3.new(15, math.random(60, 80) / 10, math.random(6, 8))
			TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = vector2,
				CFrame = CFrame.new(position + Vector3.new(0, -0.85 - (10 - vector2.Y) / 2, 0)) * CFrame.Angles(
					0,
					0.4487989505128276 * i,
					0
				) * CFrame.Angles(-0.6108652381980153, 0, 0)
			}):Play()
			local parent = part
			local v6 = i
			spawn(function()
				wait(1.25)
				clone3.Enabled = false
				TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
					Transparency = 1,
					CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
						0,
						0.4487989505128276 * v6,
						0
					) * CFrame.Angles(-0.4188790204786391, 0, 0)
				}):Play()
			end)
			_G.PU:Dust(part, 2)
		end

		wait(1.5)
		v2 = false
		clone.Flame.Enabled = false
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(5, 84.6, 5)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	elseif data.fx == "dragon_claw_x" then
		local clone = replicatedStorage.Chest.Etc.DragonClaw.Crack:Clone()
		clone.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -3, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
			Size = createVector(55.969, 55.969, 0.279)
		}):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(213, 168, 137)
		pointLight.Brightness = 1.5
		pointLight.Range = 45
		pointLight.Parent = clone
		_G.PU:Dust(clone, 4)
		local clone2 = replicatedStorage.Chest.Etc.DragonClaw.flame_claw:Clone()
		clone2.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -3, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Flame.Enabled = true
		clone2.Parent = workspace.Effects
		clone2.Flame:Emit(75)
		clone2.Burning2:Emit(20)
		spawn(function()
			wait(0.3)
			clone2.Flame.Enabled = false
		end)
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		local clone3 = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
		clone3.Color = Color3.fromRGB(213, 115, 61)
		clone3.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 3, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		clone3.Size = createVector(45.947, 3.398, 45.947)
		clone3.Parent = workspace.Effects
		local clone4 = replicatedStorage.Chest.Etc.DragonClaw.Stone_Shockwave:Clone()
		clone4.CFrame = CFrame.new(data.cf.p) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone4.Color = Color3.fromRGB(213, 115, 61)
		clone4.Size = createVector(52.412, 52.412, 10.332)
		clone4.Parent = workspace.Effects
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Shape = Enum.PartType.Ball
		part.Color = Color3.fromRGB(213, 115, 61)
		part.Size = createVector(18.483, 18.483, 18.483)
		part.CFrame = CFrame.new(data.cf.p)
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(45.573, 45.573, 45.573),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 15, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(63.504, 63.504, 63.504)
		}):Play()
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(66.832, 4.942, 66.832),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 12, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 1)
		_G.PU:Dust(clone4, 1)
		_G.PU:Dust(clone2, 3)

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 60 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		task.spawn(function()
			PeodizService.ForLoop({
				Step = 7
			}, function(p)
				math.floor(p * 7)
				local part2 = Instance.new("Part")
				part2.Size = createVector(1, 1, 1)
				part2.Anchored = true
				part2.CFrame = CFrame.new(data.cf.p + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
				part2.CanCollide = false
				local part3 = Instance.new("Part")
				part3.Size = createVector(0.374, 5.971, 0.32)
				part3.Anchored = true
				part3.Color = Color3.fromRGB(213, 115, 61)
				part3.Massless = true
				part3.Material = Enum.Material.Neon
				part3.CastShadow = false
				part3.CFrame = CFrame.new(data.cf.p + Vector3.new(
					math.random(-14, 14),
					math.random(10, 15),
					math.random(-14, 14)
				))
				part3.CanCollide = false
				part3.Parent = workspace.Effects
				TweenService:Create(part3, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(0.324, 10.988, 0.277),
					CFrame = part3.CFrame * CFrame.new(0, -math.random(7, 10), 0)
				}):Play()
				TweenService:Create(part3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(part3, 1)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				local raycastResult = workspace:Raycast(part2.CFrame.p, createVector(0, -10, 0), raycastParams)

				if raycastResult and raycastResult.Instance then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part2.CFrame = CFrame.new(position) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part2.Material = instance.Material
					part2.MaterialVariant = instance.MaterialVariant
					part2.Color = instance.Color
					part2.Anchored = false
					part2.Size = createVector(1, 1, 1) * math.random(7, 11) / 10
					part2.Parent = workspace.Effects
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Parent = part2
					bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
					bodyVelocity.Velocity = Vector3.new(math.random(-30, 30), math.random(50, 85), math.random(-30, 30))
					_G.PU:Dust(bodyVelocity, 0.2)
					_G.PU:Dust(part2, 2)
				end
			end)
		end)
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 14
			}, function(p)
				local v2 = math.floor(p * 14)
				local part2 = Instance.new("Part")
				part2.Size = createVector(1, 1, 1)
				part2.Anchored = true
				part2.CanCollide = false
				local p2 = (CFrame.new(data.cf.p) * CFrame.Angles(0, 0.4487989505128276 * v2, 0) * CFrame.new(0, 0, -30)).p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				local raycastResult = workspace:Raycast(p2, createVector(0, -10, 0), raycastParams)

				if raycastResult and raycastResult.Instance then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part2.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
						0.3490658503988659,
						0.4487989505128276 * v2,
						0
					)
					part2.Material = instance.Material
					part2.MaterialVariant = instance.MaterialVariant
					part2.Color = instance.Color
					part2.Size = createVector(1, 1, 1)
					part2.Parent = workspace.Effects
					local clone5 = replicatedStorage.Chest.Etc.DragonClaw.flame:Clone()
					clone5.Parent = part2
					TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
						Size = createVector(14.5, 6, 6),
						CFrame = CFrame.new(position + createVector(0, -1.5, 0)) * CFrame.Angles(
							0,
							0.4487989505128276 * v2,
							0
						) * CFrame.Angles(-0.4188790204786391, 0, 0)
					}):Play()
					spawn(function()
						wait(1.5)
						clone5.Enabled = false
						TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
							Transparency = 1,
							CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
								0,
								0.4487989505128276 * v2,
								0
							) * CFrame.Angles(-0.4188790204786391, 0, 0)
						}):Play()
					end)
					_G.PU:Dust(part2, 2)
				end
			end)
		end)
		wait(0.25)

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 92 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local clone5 = replicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
		clone5.Color = Color3.fromRGB(175, 128, 89)
		clone5.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 3, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		clone5.Size = createVector(63.869, 4.723, 63.869)
		clone5.Parent = workspace.Effects
		TweenService:Create(clone5, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(88.988, 6.58, 88.988),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 20, 0) * CFrame.Angles(3.141592653589793, 0, 0)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone5, 1)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Back), {
			Size = createVector(91.154, 91.154, 0.453)
		}):Play()
		clone.Decal.Transparency = 0
		clone.Decal2.Transparency = 0
		pointLight.Brightness = 4
		pointLight.Range = 70
		TweenService:Create(pointLight, TweenInfo.new(1.5, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CastShadow = false
		part2.Material = Enum.Material.Neon
		part2.Shape = Enum.PartType.Ball
		part2.Color = Color3.fromRGB(175, 128, 89)
		part2.Size = createVector(45.573, 45.573, 45.573)
		part2.CFrame = CFrame.new(data.cf.p)
		part2.Parent = workspace.Effects
		_G.PU:Dust(part2, 1)
		TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(96.924, 96.924, 96.924)
		}):Play()
		TweenService:Create(part2, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		spawn(function()
			wait(0.5)
			TweenService:Create(clone.Decal, TweenInfo.new(2.5), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Decal2, TweenInfo.new(2.5), {
				Transparency = 1
			}):Play()
		end)
		clone2.Burning2:Emit(100)
		clone2.Flame2:Emit(50)
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 5
			}, function(p)
				math.floor(p * 5)
				local part3 = Instance.new("Part")
				part3.Size = createVector(1, 1, 1)
				part3.Anchored = true
				part3.CFrame = CFrame.new(data.cf.p + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
				part3.CanCollide = false
				local part4 = Instance.new("Part")
				part4.Parent = workspace.Effects
				part4.Size = createVector(0.374, 5.971, 0.32)
				part4.Anchored = true
				part4.Color = Color3.fromRGB(173, 134, 66)
				part4.Massless = true
				part4.Material = Enum.Material.Neon
				part4.CastShadow = false
				part4.CFrame = CFrame.new(data.cf.p + Vector3.new(
					math.random(-14, 14),
					math.random(10, 15),
					math.random(-14, 14)
				))
				part4.CanCollide = false
				TweenService:Create(part4, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(0.324, 10.988, 0.277),
					CFrame = part4.CFrame * CFrame.new(0, -math.random(7, 10), 0)
				}):Play()
				TweenService:Create(part4, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(part4, 1)
				_G.PU:Dust(part3, 1)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				local raycastResult = workspace:Raycast(part3.CFrame.p, createVector(0, -10, 0), raycastParams)

				if raycastResult and raycastResult.Instance then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part3.CFrame = CFrame.new(position) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part3.Material = instance.Material
					part3.MaterialVariant = instance.MaterialVariant
					part3.Color = instance.Color
					part3.Anchored = false
					part3.Size = createVector(1, 1, 1) * math.random(15, 25) / 10
					part3.Parent = workspace.Effects
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Parent = part3
					bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
					bodyVelocity.Velocity = Vector3.new(math.random(-40, 40), math.random(10, 20), math.random(-40, 40)) * math.random(
						19,
						25
					) / 10
					_G.PU:Dust(bodyVelocity, 0.2)
					_G.PU:Dust(part3, 2)
				end
			end)
		end)
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 16
			}, function(p)
				local v2 = math.floor(p * 16)
				local part3 = Instance.new("Part")
				part3.Size = createVector(1, 1, 1)
				part3.Anchored = true
				part3.CanCollide = false
				local p2 = (CFrame.new(data.cf.p) * CFrame.Angles(0, 0.39269908169872414 * v2, 0) * CFrame.new(
					0,
					0,
					-46.5
				)).p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				local raycastResult = workspace:Raycast(p2, createVector(0, -10, 0), raycastParams)

				if raycastResult and raycastResult.Instance then
					local instance = raycastResult.Instance
					local position = raycastResult.Position
					part3.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
						0.3490658503988659,
						0.39269908169872414 * v2,
						0
					)
					part3.Material = instance.Material
					part3.MaterialVariant = instance.MaterialVariant
					part3.Color = instance.Color
					part3.Size = createVector(1, 1, 1)
					part3.Parent = workspace.Effects
					local clone6 = replicatedStorage.Chest.Etc.DragonClaw.flame:Clone()
					clone6.Parent = part3
					clone6:Emit(100)
					clone6.Rate = 100
					spawn(function()
						wait(1.5)
						clone6.Enabled = false
						TweenService:Create(part3, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
							Transparency = 1,
							CFrame = CFrame.new(position + createVector(0, -15.75, 0)) * CFrame.Angles(
								0,
								0.4487989505128276 * v2,
								0
							) * CFrame.Angles(-0.4188790204786391, 0, 0)
						}):Play()
					end)
					TweenService:Create(part3, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
						Size = createVector(20.5, 13, 13),
						CFrame = CFrame.new(position + createVector(0, -2.75, 0)) * CFrame.Angles(
							0,
							0.39269908169872414 * v2,
							0
						) * CFrame.Angles(-0.5235987755982988, 0, 0)
					}):Play()
					_G.PU:Dust(part3, 2)
				end
			end)
		end)
	elseif data.fx == "electro_x" then
		tick()

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		local part = Instance.new("Part")
		part.Transparency = 1
		part.CanCollide = false
		part.Anchored = true
		part.CFrame = data.cf
		part.Size = createVector(1, 1, 1)
		part.Parent = workspace.Effects
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(131, 253, 255)
		pointLight.Brightness = 6
		pointLight.Range = 35
		pointLight.Parent = part
		local clone = replicatedStorage.Chest.Etc.Electro.Stone_Shockwave:Clone()
		clone.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 30, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Color = Color3.fromRGB(131, 197, 204)
		clone.Size = createVector(17.106, 17.106, 56.095)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(52.104, 52.104, 7.218),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 3, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Range = 0
		}):Play()
		_G.PU:Dust(clone, 1)
		_G.PU:Dust(part, 3)
		local pointLight2 = Instance.new("PointLight")
		pointLight2.Color = Color3.fromRGB(201, 248, 255)
		pointLight2.Brightness = math.random(1, 3)
		pointLight2.Range = math.random(10, 20)
		pointLight2.Parent = part
		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		part2.Size = createVector(80, 1, 1)
		part2.Material = Enum.Material.Neon
		part2.Shape = Enum.PartType.Cylinder
		part2.Color = Color3.fromRGB(131, 197, 204)
		part2.Parent = workspace.Effects
		_G.PU:Dust(part2, 1)
		TweenService:Create(part2, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(100, 35, 35),
			Transparency = 1,
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		}):Play()
		spawn(function()
			local lastTime = tick()

			local function ring()
				local clone2 = replicatedStorage.Chest.Etc.Electro.WindRing:Clone()
				clone2.Color = Color3.fromRGB(131, 197, 204)
				clone2.Transparency = 0.1
				clone2.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 5, 0) * CFrame.Angles(3.141592653589793, 0, 0)
				clone2.Size = createVector(48.022, 3.551, 48.022)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(23.893, 1.767, 23.893),
						CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 40, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 1)
				local clone3 = replicatedStorage.Chest.Etc.Electro.Shockowave:Clone()
				clone3.CanCollide = false
				clone3.Anchored = true
				clone3.Color = Color3.fromRGB(13, 8, 21)
				clone3.Size = createVector(28.003, 2.953, 28.003)
				clone3.Material = Enum.Material.Neon
				clone3.Transparency = 0.15
				clone3.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -2, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(
					clone3,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(73.303, 7.728, 73.303),
						CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -0.5, 0) * CFrame.Angles(
							0,
							2.0943951023931953,
							0
						)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 1)

				for _ = 1, 3 do
					local part3 = Instance.new("Part")
					part3.Transparency = 0
					part3.CFrame = data.cf * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3)) * CFrame.Angles(
						math.random(-2, 2),
						math.random(-2, 2),
						math.random(-2, 2)
					)
					part3.Anchored = true
					part3.CanCollide = false
					part3.Size = createVector(2.5, 2.5, 2.5)
					_G.PU:Dust(part3, 2)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local cframe = CFrame.new(math.random(-10, 10), 3, math.random(-10, 10))
					local raycastResult = workspace:Raycast(
						(data.cf * cframe).p,
						createVector(0, -10, 0),
						raycastParams
					)

					if not (raycastResult and raycastResult.Instance) then
						continue
					end

					local instance = raycastResult.Instance
					part3.Material = instance.Material
					part3.MaterialVariant = instance.MaterialVariant
					part3.Color = instance.Color
					part3.Parent = workspace.Effects
					local v2 = part3
					spawn(function()
						wait()
						TweenService:Create(v2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Transparency = 1,
							Size = createVector(1, 1, 1)
						}):Play()
					end)
					TweenService:Create(
						part3,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = data.cf * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3)) * CFrame.new(
								math.random(-25, 25),
								math.random(15, 40),
								math.random(-25, 25)
							) * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
						}
					):Play()
				end

				for _ = 1, 3 do
					local part3 = Instance.new("Part")
					part3.CFrame = data.cf * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3))
					part3.Material = Enum.Material.Neon
					part3.Color = Color3.fromRGB(131, 197, 204)
					part3.Shape = Enum.PartType.Ball
					part3.Anchored = true
					part3.CanCollide = false
					part3.Size = createVector(2, 2, 2)
					part3.Parent = workspace.Effects
					TweenService:Create(part3, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					TweenService:Create(
						part3,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = data.cf * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3)) * CFrame.new(
								math.random(-25, 25),
								math.random(5, 20),
								math.random(-25, 25)
							),
							Size = Vector3.new()
						}
					):Play()
					_G.PU:Dust(part3, 1)
					local clone4 = replicatedStorage.Chest.Etc.Electro.Sphere:Clone()
					clone4.Color = Color3.fromRGB(131, 197, 204)
					clone4.CFrame = data.cf * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					clone4.Size = createVector(1, 1, 5)
					clone4.Parent = workspace.Effects
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					TweenService:Create(
						clone4,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = clone4.CFrame * CFrame.new(0, 0, math.random(-50, 50)),
							Size = createVector(0.3, 0.3, 15)
						}
					):Play()
					_G.PU:Dust(clone4, 1)
				end
			end

			ring()
			PeodizService.HeartbeatWait({
				Time = 1.25,
				WaitTime = 0.05
			}, function()
				if tick() - lastTime > 0.1 then
					lastTime = tick()
					ring()
				end

				pointLight2.Parent = part
				pointLight2.Color = Color3.fromRGB(201, 248, 255)
				pointLight2.Brightness = math.random(1, 3)
				pointLight2.Range = math.random(20, 35)

				if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 35 then
					v:Shake(CameraShaker.Presets.SmallerBump)
				end
			end)
			TweenService:Create(
				pointLight2,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			):Play()
			TweenService:Create(pointLight2, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Range = 0
			}):Play()
		end)

		for i = 1, 10 do
			local part3 = Instance.new("Part")
			part3.Size = createVector(1, 1, 1)
			part3.Anchored = true
			part3.CanCollide = false
			local p = (CFrame.new(data.cf.p) * CFrame.Angles(0, 0.6283185307179586 * i, 0) * CFrame.new(0, 0, -15)).p
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local vector2 = Vector3.new(12, math.random(60, 90) / 10, math.random(60, 90) / 10)
			part3.CFrame = CFrame.new(position + createVector(0, -8, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.6283185307179586 * i,
				0
			)
			part3.Material = instance.Material
			part3.MaterialVariant = instance.MaterialVariant
			part3.Color = instance.Color
			part3.Size = createVector(0, 0, 0)
			part3.Parent = workspace.Effects
			local part4 = Instance.new("Part")
			part4.Size = createVector(1, 1, 1)
			part4.Anchored = true
			part4.CanCollide = false
			part4.CFrame = CFrame.new(position + createVector(0, -8, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.6283185307179586 * i,
				0
			)
			part4.Material = Enum.Material.Neon
			part4.Color = Color3.fromRGB(131, 197, 204)
			part4.Size = vector2
			part4.Parent = workspace.Effects
			TweenService:Create(part3, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = vector2,
				CFrame = CFrame.new(position + Vector3.new(0, -0.45 - (10 - vector2.Y) / 2, 0)) * CFrame.Angles(
					0,
					0.6283185307179586 * i,
					0
				) * CFrame.Angles(-0.6108652381980153, 0, 0)
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = vector2 + createVector(0.1, 0.1, 0.1),
				CFrame = CFrame.new(position + Vector3.new(0, -0.45 - (10 - vector2.Y) / 2, 0)) * CFrame.Angles(
					0,
					0.6283185307179586 * i,
					0
				) * CFrame.Angles(-0.6108652381980153, 0, 0)
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(part4, 1)
			local v2 = part3
			local v4 = i
			spawn(function()
				PeodizService.HeartbeatWait({
					Time = 1.25,
					WaitTime = 0.05
				}, function()
					local vector3 = Vector3.new(12, math.random(60, 90) / 10, math.random(60, 90) / 10)
					TweenService:Create(v2, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
						Size = vector3,
						CFrame = CFrame.new(position + Vector3.new(0, -0.75 - (10 - vector3.Y) / 2, 0)) * CFrame.Angles(
							0,
							0.6283185307179586 * v4,
							0
						) * CFrame.Angles(-0.6108652381980153, 0, 0)
					}):Play()
					TweenService:Create(part4, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
						Size = vector3 + createVector(0.1, 0.1, 0.1),
						CFrame = CFrame.new(position + Vector3.new(0, -0.75 - (10 - vector3.Y) / 2, 0)) * CFrame.Angles(
							0,
							0.6283185307179586 * v4,
							0
						) * CFrame.Angles(-0.6108652381980153, 0, 0)
					}):Play()
				end)
				TweenService:Create(v2, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
					Transparency = 1,
					CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
						0,
						0.6283185307179586 * v4,
						0
					) * CFrame.Angles(-0.4188790204786391, 0, 0)
				}):Play()
			end)
			_G.PU:Dust(part3, 2)
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 80
		local v2 = data.cf.p - createVector(0, 15, 0)
		local v3 = data.cf.p + Vector3.new(0, numberValue.Value, 0)
		local numberValue2 = Instance.new("NumberValue")
		_G.PU:Dust(numberValue2, 10)
		numberValue2.Value = 15
		TweenService:Create(numberValue2, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 1.25
		}):Play()
		TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Value = 60
		}):Play()
		spawn(function()
			local v4 = {}

			for i = 0, 7 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v5 = v2 + (v3 - v2).Unit * i * (v3 - v2).magnitude / 7
				local v6 = (i == 0 or i == 7) and createVector(0, 0, 0) or vector2
				v4[#v4 + 1] = v5 + v6
			end

			local v5 = {}

			for i = 1, #v4 do
				if v4[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.Color = Color3.fromRGB(131, 197, 204)
				part3.Size = Vector3.new(3, 3, (v4[i] - v4[i + 1]).magnitude + 1)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CastShadow = false
				part3.CFrame = CFrame.new((v4[i] + v4[i + 1]) / 2, v4[i + 1])
				part3.Parent = workspace.Effects
				v5[#v5 + 1] = part3
				_G.PU:Dust(part3, 2)
			end

			spawn(function()
				wait(1)

				for _, v6 in pairs(v5) do
					TweenService:Create(
						v6,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v5)
				end)
			end)
			PeodizService.new({
				Time = 2
			}, function()
				v3 = data.cf.p + Vector3.new(0, numberValue.Value, 0)

				for i = 1, #v4 do
					local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					v4[i] = v2 + (v3 - v2).Unit * i * (v3 - v2).magnitude / 7 + ((i == 1 or i == 7) and createVector(
						0,
						0,
						0
					) or vector2)
				end

				for i = 1, #v4 do
					if v4[i + 1] == nil then
						continue
					end

					local v6 = v5[i]
					v6.Size = Vector3.new(numberValue2.Value, numberValue2.Value, (v4[i] - v4[i + 1]).magnitude + 1)
					v6.CFrame = CFrame.new((v4[i] + v4[i + 1]) / 2, v4[i + 1])
				end
			end)
			task.delay(10, function()
				table.clear(v4)
			end)
		end)
		spawn(function()
			local v4 = data.cf.p - createVector(0, 15, 0)
			local v5 = data.cf.p + createVector(0, 50, 0)
			local v6 = {}

			for i = 0, 6 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v7 = v2 + (v3 - v2).Unit * i * (v3 - v2).magnitude / 6
				local v8 = (i == 0 or i == 6) and createVector(0, 0, 0) or vector2
				v6[#v6 + 1] = v7 + v8
			end

			local v7 = {}

			for i = 1, #v6 do
				if v6[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.Color = Color3.fromRGB(131, 197, 204)
				part3.Size = Vector3.new(3, 3, (v6[i] - v6[i + 1]).magnitude + 1)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CastShadow = false
				part3.CFrame = CFrame.new((v6[i] + v6[i + 1]) / 2, v6[i + 1])
				part3.Parent = workspace.Effects
				v7[#v7 + 1] = part3
				_G.PU:Dust(part3, 1.9)
			end

			spawn(function()
				wait(0.9)

				for _, v8 in pairs(v7) do
					TweenService:Create(
						v8,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v7)
				end)
			end)
			PeodizService.new({
				Time = 2
			}, function()
				local cframe = CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
				v4 = (data.cf * cframe).p - createVector(0, 15, 0)
				v5 = (data.cf * cframe).p + createVector(0, 50, 0)

				for i = 1, #v6 do
					local vector2 = Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					v6[i] = v4 + (v5 - v4).Unit * i * (v5 - v4).magnitude / 6 + ((i == 1 or i == 6) and createVector(
						0,
						0,
						0
					) or vector2)
				end

				for i = 1, #v6 do
					if v6[i + 1] == nil then
						continue
					end

					local v8 = v7[i]
					local v9 = math.random(15, 25) / 100
					v8.Size = Vector3.new(v9, v9, (v6[i] - v6[i + 1]).magnitude + 1)
					v8.CFrame = CFrame.new((v6[i] + v6[i + 1]) / 2, v6[i + 1])
				end
			end)
			task.delay(10, function()
				table.clear(v6)
			end)
		end)
		spawn(function()
			local v4 = data.cf.p - createVector(0, 15, 0)
			local v5 = data.cf.p + createVector(0, 50, 0)
			local v6 = {}

			for i = 0, 4 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v7 = v2 + (v3 - v2).Unit * i * (v3 - v2).magnitude / 4
				local v8 = (i == 0 or i == 4) and createVector(0, 0, 0) or vector2
				v6[#v6 + 1] = v7 + v8
			end

			local v7 = {}

			for i = 1, #v6 do
				if v6[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.Color = Color3.fromRGB(131, 197, 204)
				part3.Size = Vector3.new(3, 3, (v6[i] - v6[i + 1]).magnitude + 1)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CastShadow = false
				part3.CFrame = CFrame.new((v6[i] + v6[i + 1]) / 2, v6[i + 1])
				part3.Parent = workspace.Effects
				v7[#v7 + 1] = part3
				_G.PU:Dust(part3, 1.9)
			end

			spawn(function()
				wait(0.9)

				for _, v8 in pairs(v7) do
					TweenService:Create(
						v8,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v7)
				end)
			end)
			PeodizService.new({
				Time = 2
			}, function()
				local cframe = CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
				v4 = (data.cf * cframe).p - createVector(0, 15, 0)
				v5 = (data.cf * cframe).p + createVector(0, 70, 0)

				for i = 1, #v6 do
					local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					v6[i] = v4 + (v5 - v4).Unit * i * (v5 - v4).magnitude / 4 + ((i == 1 or i == 4) and createVector(
						0,
						0,
						0
					) or vector2)
				end

				for i = 1, #v6 do
					if v6[i + 1] == nil then
						continue
					end

					local v8 = v7[i]
					local v9 = math.random(15, 25) / 100
					v8.Size = Vector3.new(v9, v9, (v6[i] - v6[i + 1]).magnitude + 1)
					v8.CFrame = CFrame.new((v6[i] + v6[i + 1]) / 2, v6[i + 1])
				end
			end)
			task.delay(10, function()
				table.clear(v6)
			end)
		end)
	elseif data.fx == "electro_x_start" then
		local humanoidRootPart = data.Player.Character.HumanoidRootPart
		task.spawn(function()
			PeoUtils.LerpCF(
				humanoidRootPart,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
				CFrame.new(data.CFMouse.p) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p) * CFrame.new(
					0,
					50,
					0
				)
			)
			wait(0.3)
			PeoUtils.LerpCF(
				humanoidRootPart,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
				CFrame.new(data.CFMouse.p) * (humanoidRootPart.CFrame - humanoidRootPart.CFrame.p) * CFrame.new(
					0,
					3.5,
					0
				)
			)
		end)
		local clone = replicatedStorage.Chest.Etc.Electro.WindRing:Clone()
		clone.CFrame = data.cf * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Size = createVector(13.206, 0.977, 13.206)
		clone.Color = Color3.fromRGB(131, 197, 204)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(40.166, 1.925, 40.166),
			CFrame = clone.CFrame * CFrame.new(0, 0, -5)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
	elseif data.fx == "electro_c" then
		local cf = data.cf
		tick()
		local p = data.cf.p
		local p2 = data.cf2.p
		local magnitude = (p - p2).magnitude
		local numberValue = Instance.new("NumberValue")
		_G.PU:Dust(numberValue, 10)
		numberValue.Value = 2

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 55 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		if localPlayer == data.Player then
			PeoUtils.LerpCF(
				data.root,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				data.cf2
			)
		end

		TweenService:Create(numberValue, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 0.2
		}):Play()
		local v2 = cf.p - createVector(0, 15, 0)
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Value = 15
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(131, 253, 255)
		pointLight.Brightness = 2
		pointLight.Range = 15
		pointLight.Parent = data.root
		_G.PU:Dust(pointLight, 1)
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()
		TweenService:Create(numberValue2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 0.9
		}):Play()
		local clone = replicatedStorage.Chest.Etc.Electro.Sphere:Clone()
		clone.Color = Color3.fromRGB(131, 197, 204)
		clone.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, -2.75)
		clone.Size = createVector(6, 6, 5.5)
		clone.Parent = workspace.Effects
		local clone2 = replicatedStorage.Chest.Etc.Electro.Shockwave:Clone()
		clone2.Transparency = 0.2
		clone2.Color = Color3.fromRGB(131, 197, 204)
		clone2.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, -5) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
		clone2.Size = createVector(31.975, 31.975, 5.23)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(16.028, 16.028, 70.935),
			CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, -magnitude) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			),
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude),
			CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, -magnitude / 2)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()

		for i = 1, 4 do
			local part = Instance.new("Part")
			part.Size = Vector3.new()
			part.Anchored = true
			part.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(
				-magnitude / 25 * -i - 1.5 - magnitude / 25 * 4,
				0,
				-magnitude / 4 * i
			)
			part.CanCollide = false
			local part2 = Instance.new("Part")
			part2.Size = Vector3.new()
			part2.Anchored = true
			part2.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(
				-magnitude / 25 * i + 1.5 + magnitude / 25 * 4,
				0,
				-magnitude / 4 * i
			)
			part2.CanCollide = false
			local part3 = Instance.new("Part")
			part3.Size = Vector3.new()
			part3.Anchored = true
			part3.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(
				-magnitude / 25 * -i - 1.5 - magnitude / 25 * 4,
				0,
				-magnitude / 4 * i
			)
			part3.CanCollide = false
			local part4 = Instance.new("Part")
			part4.Size = Vector3.new()
			part4.Anchored = true
			part4.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(
				-magnitude / 25 * i + 1.5 + magnitude / 25 * 4,
				0,
				-magnitude / 4 * i
			)
			part4.CanCollide = false
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)
			local raycastResult2 = workspace:Raycast(part2.CFrame.p, createVector(0, -10, 0), raycastParams)

			if raycastResult and raycastResult.Instance then
				local instance = raycastResult.Instance
				local position = raycastResult.Position
				local cFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
					math.random(-2, 2),
					math.random(-2, 2),
					math.random(-2, 2)
				)
				local cFrame2 = CFrame.new(position + createVector(0, -1.5, 0)) * CFrame.Angles(
					math.random(-2, 2),
					math.random(-2, 2),
					math.random(-2, 2)
				)
				part.CFrame = cFrame
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.Size = createVector(1, 1, 1)
				part.Parent = workspace.Effects
				part3.CFrame = cFrame
				part3.Material = Enum.Material.Neon
				part3.Color = Color3.fromRGB(131, 197, 204)
				part3.Size = createVector(1.1, 1.1, 1.1)
				part3.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					Size = createVector(5, 5, 5),
					CFrame = cFrame2
				}):Play()
				TweenService:Create(part3, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					Size = createVector(5.1, 5.1, 5.1),
					CFrame = cFrame2
				}):Play()
				TweenService:Create(part3, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(part, 2)
				_G.PU:Dust(part3, 2)
				local v5 = part
				spawn(function()
					wait(0.35)
					TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end

			if not (raycastResult2 and raycastResult2.Instance) then
				continue
			end

			local instance = raycastResult2.Instance
			local position = raycastResult2.Position
			local cFrame3 = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			local cFrame4 = CFrame.new(position + createVector(0, -1.5, 0)) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			part2.CFrame = cFrame3
			part2.Material = instance.Material
			part2.MaterialVariant = instance.MaterialVariant
			part2.Color = instance.Color
			part2.Size = createVector(1, 1, 1)
			part2.Parent = workspace.Effects
			part4.CFrame = cFrame3
			part4.Material = Enum.Material.Neon
			part4.Color = Color3.fromRGB(131, 197, 204)
			part4.Size = createVector(1.1, 1.1, 1.1)
			part4.Parent = workspace.Effects
			TweenService:Create(part2, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = createVector(5, 5, 5),
				CFrame = cFrame4
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = createVector(5.1, 5.1, 5.1),
				CFrame = cFrame4
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(part2, 2)
			_G.PU:Dust(part4, 2)
			local v5 = part2
			spawn(function()
				wait(0.35)
				TweenService:Create(v5, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
					Size = createVector(0, 0, 0)
				}):Play()
			end)
		end

		spawn(function()
			local step = math.floor(magnitude / 50)
			PeodizService.ForLoop({
				Step = step
			}, function(p3)
				local v4 = math.floor(p3 * step)
				local clone3 = replicatedStorage.Chest.Etc.Electro.Rings:Clone()
				clone3.Size = Vector3.new()
				clone3.Color = Color3.fromRGB(131, 197, 204)
				clone3.CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, v4 * -50 + 50) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
					Transparency = 1,
					Size = createVector(23.812, 1.902, 23.812),
					CFrame = CFrame.new(data.cf.p, data.cf2.p) * CFrame.new(0, 0, v4 * -50 + 52) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
				}):Play()
				_G.PU:Dust(clone3, 1)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(36.876, 2.434, 36.876)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end)
		end)
		spawn(function()
			local v3 = {}

			for i = 0, 7 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v4 = v2 + (p2 - v2).Unit * i * (p2 - v2).magnitude / 7
				local v5 = (i == 0 or i == 7) and createVector(0, 0, 0) or vector2
				v3[#v3 + 1] = v4 + v5
			end

			local v4 = {}

			for i = 1, #v3 do
				if v3[i + 1] == nil then
					continue
				end

				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Color = Color3.fromRGB(131, 197, 204)
				part.Size = Vector3.new(3, 3, (v3[i] - v3[i + 1]).magnitude + 1)
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.CFrame = CFrame.new((v3[i] + v3[i + 1]) / 2, v3[i + 1])
				part.Parent = workspace.Effects
				v4[#v4 + 1] = part
				_G.PU:Dust(part, 2)
			end

			task.delay(10, function()
				table.clear(v3)
			end)
			spawn(function()
				wait(0.1)

				for _, v5 in pairs(v4) do
					TweenService:Create(
						v5,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v4)
				end)
			end)
		end)
		spawn(function()
			local v3 = {}

			for i = 0, 7 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v4 = v2 + (p2 - v2).Unit * i * (p2 - v2).magnitude / 7
				local v5 = (i == 0 or i == 7) and createVector(0, 0, 0) or vector2
				v3[#v3 + 1] = v4 + v5
			end

			local v4 = {}

			for i = 1, #v3 do
				if v3[i + 1] == nil then
					continue
				end

				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Color = Color3.fromRGB(131, 197, 204)
				part.Size = Vector3.new(3, 3, (v3[i] - v3[i + 1]).magnitude + 1)
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.CFrame = CFrame.new((v3[i] + v3[i + 1]) / 2, v3[i + 1])
				part.Parent = workspace.Effects
				v4[#v4 + 1] = part
				_G.PU:Dust(part, 2)
			end

			task.delay(10, function()
				table.clear(v3)
			end)
			spawn(function()
				wait(0.1)

				for _, v5 in pairs(v4) do
					TweenService:Create(
						v5,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v4)
				end)
			end)
		end)
		spawn(function()
			local v3 = {}

			for i = 0, 6 do
				local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				local v4 = v2 + (p2 - v2).Unit * i * (p2 - v2).magnitude / 6
				local v5 = (i == 0 or i == 6) and createVector(0, 0, 0) or vector2
				v3[#v3 + 1] = v4 + v5
			end

			local v4 = {}

			for i = 1, #v3 do
				if v3[i + 1] == nil then
					continue
				end

				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Color = Color3.fromRGB(131, 197, 204)
				part.Size = Vector3.new(3, 3, (v3[i] - v3[i + 1]).magnitude + 1)
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.CFrame = CFrame.new((v3[i] + v3[i + 1]) / 2, v3[i + 1])
				part.Parent = workspace.Effects
				v4[#v4 + 1] = part
				_G.PU:Dust(part, 2)
			end

			task.delay(10, function()
				table.clear(v3)
			end)
			spawn(function()
				wait(0.1)

				for _, v5 in pairs(v4) do
					TweenService:Create(
						v5,
						TweenInfo.new(0.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v4)
				end)
			end)
		end)
	elseif data.fx == "electro_v" then
		local cFrame = data.cf * CFrame.new(0, -1.25, 0)
		local _ = data.target
		local rootPart = data.RootPart

		if localPlayer == data.Player and rootPart then
			PeoUtils.LerpCF(
				rootPart,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
				CFrame.new(rootPart.CFrame.p) * CFrame.new(0, 50, 0) * (cFrame - cFrame.p)
			)
			task.delay(0.2, function()
				PeoUtils.LerpCF(rootPart, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), cFrame)
			end)
		end

		task.wait(0.2)
		tick()
		local numberValue = Instance.new("NumberValue")
		_G.PU:Dust(numberValue, 10)
		numberValue.Value = 2
		TweenService:Create(numberValue, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 0.3
		}):Play()
		local v3 = cFrame.p - createVector(0, 15, 0)
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Value = 12
		TweenService:Create(numberValue2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 1.25
		}):Play()
		local clone = replicatedStorage.Chest.Etc.Electro.Shockowave:Clone()
		clone.CanCollide = false
		clone.Anchored = true
		clone.Color = Color3.fromRGB(13, 8, 21)
		clone.Size = createVector(88.599, 88.599, 5.084)
		clone.Material = Enum.Material.Neon
		clone.CFrame = cFrame * CFrame.new(0, 2, 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(40.567, 40.567, 71.103),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 25, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 40 then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		spawn(function()
			local v4 = cFrame.p + createVector(0, 80, 0)
			local v5 = {}

			for i = 0, 4 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v6 = v3 + (v4 - v3).Unit * i * (v4 - v3).magnitude / 4
				local v7 = (i == 0 or i == 4) and createVector(0, 0, 0) or vector2
				v5[#v5 + 1] = v6 + v7
			end

			local v6 = {}

			for i = 1, #v5 do
				if v5[i + 1] == nil then
					continue
				end

				local part = Instance.new("Part")
				part.Material = "Neon"
				part.Color = Color3.fromRGB(131, 197, 204)
				part.Size = Vector3.new(3, 3, (v5[i] - v5[i + 1]).magnitude + 1)
				part.Anchored = true
				part.CanCollide = false
				part.CastShadow = false
				part.CFrame = CFrame.new((v5[i] + v5[i + 1]) / 2, v5[i + 1])
				part.Parent = workspace.Effects
				v6[#v6 + 1] = part
				_G.PU:Dust(part, 2)
			end

			spawn(function()
				wait(0.5)

				for _, v7 in pairs(v6) do
					TweenService:Create(
						v7,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v6)
				end)
			end)
			PeodizService.HeartbeatWait({
				Time = 0.75,
				WaitTime = 0.05
			}, function()
				for i = 1, #v5 do
					local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					v5[i] = v3 + (v4 - v3).Unit * i * (v4 - v3).magnitude / 4 + ((i == 1 or i == 4) and createVector(
						0,
						0,
						0
					) or vector2)
				end

				for i = 1, #v5 do
					if v5[i + 1] == nil then
						continue
					end

					local v7 = v6[i]
					v7.Size = Vector3.new(numberValue2.Value, numberValue2.Value, (v5[i] - v5[i + 1]).magnitude + 1)
					v7.CFrame = CFrame.new((v5[i] + v5[i + 1]) / 2, v5[i + 1])
				end
			end)
			task.delay(10, function()
				table.clear(v5)
			end)
		end)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Size = createVector(80, 1, 1)
		part.Material = Enum.Material.Neon
		part.Shape = Enum.PartType.Cylinder
		part.Color = Color3.fromRGB(131, 197, 204)
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(100, 35, 35),
			Transparency = 1,
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		}):Play()
		local part2 = Instance.new("Part")
		part2.Material = "Neon"
		part2.CastShadow = false
		part2.Color = Color3.fromRGB(255, 2, 2)
		part2.Size = createVector(0.5, 0.5, 0.5)
		part2.Anchored = true
		part2.CanCollide = false
		part2.Transparency = 1
		part2.CFrame = cFrame
		part2.Parent = workspace.Effects
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(201, 248, 255)
		pointLight.Brightness = math.random(1, 3)
		pointLight.Range = math.random(45, 50)
		pointLight.Parent = part2

		for i = 1, 14 do
			local part3 = Instance.new("Part")
			part3.Size = createVector(1, 1, 1)
			part3.Anchored = true
			part3.CanCollide = false
			local p = (CFrame.new(data.cf.p) * CFrame.Angles(0, 0.4487989505128276 * i, 0) * CFrame.new(0, 0, -55)).p
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part3.CFrame = CFrame.new(position + createVector(0, -8, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.4487989505128276 * i,
				0
			)
			part3.Material = instance.Material
			part3.MaterialVariant = instance.MaterialVariant
			part3.Color = instance.Color
			part3.Size = createVector(0, 0, 0)
			part3.Parent = workspace.Effects
			local part4 = Instance.new("Part")
			part4.Size = createVector(1, 1, 1)
			part4.Anchored = true
			part4.CanCollide = false
			part4.CFrame = CFrame.new(position + createVector(0, -8, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.4487989505128276 * i,
				0
			)
			part4.Material = Enum.Material.Neon
			part4.Color = Color3.fromRGB(131, 197, 204)
			part4.Size = createVector(25, 8, 8)
			part4.Parent = workspace.Effects
			TweenService:Create(part3, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = createVector(25, 8, 8),
				CFrame = CFrame.new(position + createVector(0, -1.75, 0)) * CFrame.Angles(0, 0.4487989505128276 * i, 0) * CFrame.Angles(
					-0.6108652381980153,
					0,
					0
				)
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
				Size = createVector(25.1, 8.1, 8.1),
				CFrame = CFrame.new(position + createVector(0, -1.75, 0)) * CFrame.Angles(0, 0.4487989505128276 * i, 0) * CFrame.Angles(
					-0.6108652381980153,
					0,
					0
				)
			}):Play()
			TweenService:Create(part4, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(part4, 1)
			local v4 = part3
			local v6 = i
			spawn(function()
				wait(0.75)
				TweenService:Create(v4, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
					Transparency = 1,
					CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
						0,
						0.4487989505128276 * v6,
						0
					) * CFrame.Angles(-0.4188790204786391, 0, 0)
				}):Play()
			end)
			_G.PU:Dust(part3, 2)
		end

		spawn(function()
			local v4 = cFrame.p + createVector(0, 80, 0)
			local v5 = {}

			for i = 0, 5 do
				local vector2 = Vector3.new(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3))
				local v6 = v3 + (v4 - v3).Unit * i * (v4 - v3).magnitude / 5
				local v7 = (i == 0 or i == 5) and createVector(0, 0, 0) or vector2
				v5[#v5 + 1] = v6 + v7
			end

			local v6 = {}

			for i = 1, #v5 do
				if v5[i + 1] == nil then
					continue
				end

				local part3 = Instance.new("Part")
				part3.Material = "Neon"
				part3.Color = Color3.fromRGB(131, 197, 204)
				part3.Size = Vector3.new(3, 3, (v5[i] - v5[i + 1]).magnitude + 1)
				part3.Anchored = true
				part3.CanCollide = false
				part3.CastShadow = false
				part3.CFrame = CFrame.new((v5[i] + v5[i + 1]) / 2, v5[i + 1])
				part3.Parent = workspace.Effects
				v6[#v6 + 1] = part3
				_G.PU:Dust(part3, 1.9)
			end

			spawn(function()
				wait(0.5)

				for _, v7 in pairs(v6) do
					TweenService:Create(
						v7,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end

				task.delay(10, function()
					table.clear(v6)
				end)
			end)
			PeodizService.HeartbeatWait({
				Time = 0.75,
				WaitTime = 0.05
			}, function()
				CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))

				for i = 1, #v5 do
					local vector2 = Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
					v5[i] = v3 + (v4 - v3).Unit * i * (v4 - v3).magnitude / 5 + ((i == 1 or i == 5) and createVector(
						0,
						0,
						0
					) or vector2)
				end

				for i = 1, #v5 do
					if v5[i + 1] == nil then
						continue
					end

					local v7 = v6[i]
					local v8 = math.random(15, 25) / 100
					v7.Size = Vector3.new(v8, v8, (v5[i] - v5[i + 1]).magnitude + 1)
					v7.CFrame = CFrame.new((v5[i] + v5[i + 1]) / 2, v5[i + 1])
				end
			end)
			task.delay(10, function()
				table.clear(v5)
			end)
			part2:Destroy()
		end)
		spawn(function()
			local function ring()
				local clone2 = replicatedStorage.Chest.Etc.Electro.WindRing:Clone()
				clone2.Color = Color3.fromRGB(131, 197, 204)
				clone2.Transparency = 0.1
				clone2.CFrame = cFrame * CFrame.new(0, 5, 0) * CFrame.Angles(3.141592653589793, 0, 0)
				clone2.Size = createVector(38.833, 1.178, 38.833)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(88.346, 2.68, 88.346),
						CFrame = cFrame * CFrame.new(0, 70, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 1)
			end

			local lastTime = tick()
			ring()
			PeodizService.HeartbeatWait({
				Time = 0.6,
				WaitTime = 0.05
			}, function()
				if not part2:IsDescendantOf(workspace.Effects) then
					return true
				end

				pointLight.Brightness = math.random(1, 2)
				pointLight.Range = math.random(50, 55)

				if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 35 then
					v:Shake(CameraShaker.Presets.SmallerBump)
				end

				if tick() - lastTime > 0.1 then
					lastTime = tick()
					local clone2 = replicatedStorage.Chest.Etc.Electro.Shockowave:Clone()
					clone2.CanCollide = false
					clone2.Anchored = true
					clone2.Color = Color3.fromRGB(13, 8, 21)
					clone2.Size = createVector(50.194, 5.568, 50.193)
					clone2.Material = Enum.Material.Neon
					clone2.Transparency = 0.15
					clone2.CFrame = cFrame * CFrame.new(0, 2, 0)
					clone2.Parent = workspace.Effects
					TweenService:Create(
						clone2,
						TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(165.909, 18.405, 165.909),
							CFrame = cFrame * CFrame.new(0, 6, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
						}
					):Play()
					TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone2, 1)
					local clone3 = replicatedStorage.Chest.Etc.Electro.Rings:Clone()
					clone3.Color = Color3.fromRGB(131, 197, 204)
					clone3.Transparency = 0.25
					clone3.CFrame = cFrame * CFrame.new(0, 5, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					clone3.Size = createVector(93.837, 0.5, 93.838)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(141.015, 0.5, 141.016),
							CFrame = cFrame * CFrame.new(0, 10, 0) * CFrame.Angles(3.141592653589793, 0, 0)
						}
					):Play()
					TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
				end
			end)
			TweenService:Create(pointLight, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Brightness = 0,
				Range = 0
			}):Play()
		end)
		task.spawn(function()
			local clone2 = replicatedStorage.Chest.MeleeEffect.Electro.ElectroShocker2:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)

			for _, beam in pairs(clone2:GetDescendants()) do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true

				if beam.Name == "Beam1" then
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 24,
						Width1 = 3
					}):Play()
				elseif beam.Name == "Beam2" then
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 24,
						Width1 = 1
					}):Play()
				elseif beam.Name == "Beam3" then
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 40,
						Width1 = 1
					}):Play()
				elseif beam.Name == "Beam4" then
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 8,
						Width1 = 1
					}):Play()
				end
			end

			wait(0.5)

			for _, beam in pairs(clone2:GetDescendants()) do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.25), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end
		end)
	elseif data.fx == "electro_z" then
		local v2 = data.cf * CFrame.new(0, -1.25, 0)
		local _ = data.target
		tick()
		local numberValue = Instance.new("NumberValue")
		_G.PU:Dust(numberValue, 10)
		numberValue.Value = 3
		TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 0.3
		}):Play()
		local _ = v2.p - createVector(0, 15, 0)
		local numberValue2 = Instance.new("NumberValue")
		numberValue2.Value = 12
		TweenService:Create(numberValue2, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 1.25
		}):Play()

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 40 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local p = (v2 * CFrame.new(0, 0, -3)).p

		for i = 1, 5 do
			local v3 = i
			spawn(function()
				math.random(5, 10)
				math.random(-10, -5)
				local v4 = math.random(1, 2) == 1
				local v5 = math.random(1, 2) == 1
				local p2 = (v2 * CFrame.Angles(0, math.rad(v3 * 100 / 5 + -50), 0) * CFrame.new(0, 0, -65)).p
				local v6 = {}
				local v7 = {}
				local v8 = {}
				local v9 = {}

				for i2 = 0, 3 do
					local vector2 = Vector3.new(math.random(-1.5, 1.5), math.random(-1.5, 1.5), math.random(-1.5, 1.5))
					local v10 = p + (p2 - p).Unit * i2 * (p2 - p).magnitude / 3
					local v11 = (i2 == 0 or i2 == 3) and createVector(0, 0, 0) or vector2
					v6[#v6 + 1] = v10
					v7[#v7 + 1] = v11
				end

				for i2 = 1, #v6 do
					if v6[i2 + 1] == nil then
						continue
					end

					local part = Instance.new("Part")
					part.Material = "Neon"
					part.CastShadow = false
					part.Color = Color3.fromRGB(131, 197, 204)
					part.Size = Vector3.new(0.2, 0.2, (v6[i2] + v7[i2] - (v6[i2 + 1] + v7[i2 + 1])).magnitude)
					part.Anchored = true
					part.CanCollide = false
					part.CFrame = CFrame.new((v6[i2] + v7[i2] + (v6[i2 + 1] + v7[i2 + 1])) / 2, v6[i2 + 1] + v7[i2 + 1])
					part.Parent = workspace.Effects
					local v10 = i2
					spawn(function()
						wait(0.5)
						wait(v10 * 0.35 * wait())
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(
							part,
							TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						_G.PU:Dust(part, 1)
					end)
					v8[#v8 + 1] = part
					local v12 = part
					spawn(function()
						PeodizService.new({
							Time = 15
						}, function()
							if v12.Parent ~= workspace.Effects then
								return true
							end

							for i3 = 1, #v6 do
								if i3 ~= 1 then
									v7[i3 + 1] = Vector3.new(math.random(-5, 5), math.random(-2, 2), math.random(-5, 5))
									v7[i3] = Vector3.new(math.random(-5, 5), math.random(-2, 2), math.random(-5, 5))
								end

								if i3 == 1 then
									v6[1] = p
								end

								if i3 == #v6 then
									v6[i3] = p2
									v7[i3] = Vector3.new(math.random(-3, 3), math.random(-1.5, 1.5), math.random(-3, 3))
								end

								v6[i3] = p + (p2 - p).Unit * (i3 - 1) * (p2 - p).magnitude / 3
							end

							for i3 = 1, #v8 do
								v8[i3].CFrame:toObjectSpace(CFrame.new(
									(v6[i3] + v7[i3] + (v6[i3 + 1] + v7[i3 + 1])) / 2,
									v6[i3 + 1] + v7[i3 + 1]
								))
								v8[i3].CFrame = CFrame.new(
									(v6[i3] + v7[i3] + (v6[i3 + 1] + v7[i3 + 1])) / 2,
									v6[i3 + 1] + v7[i3 + 1]
								)
								v8[i3].Size = Vector3.new(
									numberValue.Value,
									numberValue.Value,
									(v6[i3] + v7[i3] - (v6[i3 + 1] + v7[i3 + 1])).magnitude
								)
							end
						end)
					end)
				end

				task.delay(10, function()
					table.clear(v6)
					table.clear(v7)
					table.clear(v9)
					table.clear(v8)
				end)
			end)
		end
	elseif data.fx == "black_leg_z" then
		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function bezier(p, p2, p3, p4)
			return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
		end

		local numberValue = Instance.new("NumberValue")
		_G.PU:Dust(numberValue, 5)
		numberValue.Value = 0
		local TweenService2 = game:GetService("TweenService")
		local tween = TweenService2:Create(
			numberValue,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 100
			}
		)
		tween:Play()
		local color = Color3.fromRGB(180, 180, 180)

		if data.diable == true then
			color = Color3.fromRGB(190, 148, 97)
		end

		if game.Players.LocalPlayer.Name == data.plrname then
			local numberValue2 = Instance.new("NumberValue")
			_G.PU:Dust(numberValue2, 5)
			numberValue2.Value = 0
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(numberValue2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Value = 100
			}):Play()
			PeodizService.Heartbeat({
				Time = 0.3,
				WaitTime = 0.03
			}, function(p)
				local v2 = bezier(p, data.cf1.p, data.up.p, data.cf2.p)
				data.root.CFrame = CFrame.new(v2) * (data.root.CFrame - data.root.CFrame.p)
			end)

			if numberValue2 then
				numberValue2:Destroy()
			end
		end

		PeodizService.HeartbeatWait({
			Time = 1,
			WaitTime = 0.05
		}, function()
			if tween.Completed:Wait() then
				return true
			end
		end)

		if numberValue then
			numberValue:Destroy()
		end

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		spawn(function()
			PeodizService.ForLoop({
				Step = 3
			}, function(_)
				local clone = replicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
				clone.CanCollide = false
				clone.Anchored = true
				clone.Color = Color3.fromRGB(13, 8, 21)
				clone.Size = createVector(28.003, 2.953, 28.003)
				clone.Material = Enum.Material.Neon
				clone.Transparency = 0.1
				clone.CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, -2, 0)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(73.303, 7.728, 73.303),
					CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, -0.5, 0) * CFrame.Angles(0, 2.0943951023931953, 0)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 1)
			end)
		end)
		spawn(function()
			for i = 1, 8 do
				local p = (CFrame.new(data.cf2.p) * CFrame.Angles(0, 0.7853981633974483 * i, 0) * CFrame.new(0, 0, -15)).p
				local ray = Ray.new(p + createVector(0, 2, 0), createVector(0, -10, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if not instance then
					continue
				end

				local cframe = CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Massless = true
				part.CastShadow = true
				part.Color = instance.Color
				part.Material = instance.Material
				part.CFrame = CFrame.new(position + createVector(0, -0.4, 0)) * cframe
				part.Parent = workspace.Effects

				if instance:FindFirstChild("Texture") then
					for _, texture in pairs(instance:GetChildren()) do
						if not texture:IsA("Texture") then
							continue
						end

						local clone_2 = texture:Clone()
						clone_2.Parent = part
					end
				end

				spawn(function()
					if data.diable == true then
						local clone = replicatedStorage.Chest.Etc.DragonClaw.flame:Clone()
						clone.Parent = part
						clone.Enabled = true
						wait(0.75)
						clone.Enabled = false
					end
				end)
				TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					Size = createVector(3.5, 3.5, 3.5)
				}):Play()
				_G.PU:Dust(part, 3)
				local v3 = i
				local parent = part
				spawn(function()
					wait(1 + v3 * wait())
					TweenService:Create(
						parent,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Position = parent.Position + createVector(0, -4, 0)
						}
					):Play()
					wait(0.5)
					TweenService:Create(parent, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = createVector(1, 1, 1),
						Transparency = 1,
						Position = parent.Position + createVector(0, -5, 0)
					}):Play()
				end)
			end
		end)
		spawn(function()
			local ray = Ray.new(data.cf2.p + createVector(0, 2, 0), createVector(0, -14, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			if not (raycastResult and raycastResult.Position) then
				local _ = ray.Origin + ray.Direction
			end

			if instance then
				local part = Instance.new("Part")
				part.Material = "Neon"
				part.CastShadow = false
				part.Color = Color3.fromRGB(255, 2, 2)
				part.Size = createVector(0.1, 0.1, 0.1)
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 1
				part.CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, -10, 0)
				part.Parent = workspace.Effects
				local sound = Instance.new("Sound")
				sound.Parent = part
				sound.Volume = 1
				sound.RollOffMaxDistance = 750
				sound.SoundId = "rbxassetid://165970126"
				sound:Play()
				local clone = replicatedStorage.Chest.Etc.BlackLeg.bigsmoke:Clone()
				clone.Enabled = false
				clone.Color = ColorSequence.new(instance.Color)
				clone.Parent = part
				clone:Emit(20)
				local clone2 = replicatedStorage.Chest.Etc.BlackLeg.RockParticle:Clone()
				clone2.Enabled = false
				clone2.Color = ColorSequence.new(instance.Color)
				clone2.Parent = part
				clone2:Emit(2)
				_G.PU:Dust(part, 3)
			end
		end)
		local clone = replicatedStorage.Chest.Etc.BlackLeg.Stone_Shockwave:Clone()
		clone.CFrame = CFrame.new(data.cf2.p) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Color = color
		clone.Size = createVector(55, 55, 5)
		clone.Transparency = 0.1
		clone.Parent = workspace.Effects

		if data.diable == true then
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone
			pointLight.Color = Color3.fromRGB(213, 168, 137)
			pointLight.Brightness = 1
			pointLight.Range = 30
			spawn(function()
				wait(0.2)
				TweenService:Create(pointLight, TweenInfo.new(0.85, Enum.EasingStyle.Quad), {
					Brightness = 0
				}):Play()
			end)
		end

		TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(8, 8, 50),
			CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, 15, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				4.71238898038469
			)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
		local clone2 = replicatedStorage.Chest.Etc.BlackLeg.WindRing:Clone()
		clone2.CFrame = CFrame.new(data.cf2.p) * CFrame.Angles(0, 0, 3.141592653589793)
		clone2.Color = color
		clone2.Size = createVector(13.206, 0.977, 13.206)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(40.166, 1.925, 40.166),
			CFrame = clone2.CFrame * CFrame.new(0, -25, 0)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 1)

		for _ = 1, 5 do
			local clone3 = replicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
			clone3.Color = color
			clone3.CFrame = data.cf2 * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
			clone3.Size = createVector(1.312, 1.312, 3.922)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(0, 0, -15),
				Size = createVector(0.05, 0.05, 7)
			}):Play()
			_G.PU:Dust(clone3, 1)
		end

		local clone3 = replicatedStorage.Chest.Etc.BlackLeg.FlameWind:Clone()
		clone3.Size = createVector(15, 55, 15)
		clone3.Color = color
		clone3.CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, 10, 0)
		clone3.Parent = workspace.Effects

		if data.diable == true then
			clone3.Flame:Emit(4)
		end

		_G.PU:Dust(clone3, 3)
		local v2 = true

		for _ = 1, 5 do
			local part = Instance.new("Part")
			part.Transparency = 0
			part.CFrame = data.cf2 * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3)) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			part.Anchored = true
			part.CanCollide = false
			part.Size = createVector(2.5, 2.5, 2.5)
			_G.PU:Dust(part, 2)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local cframe = CFrame.new(math.random(-10, 10), 3, math.random(-10, 10))
			local raycastResult = workspace:Raycast((data.cf2 * cframe).p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.CastShadow = false
			part.Parent = workspace.Effects
			local v3 = part
			spawn(function()
				wait()
				TweenService:Create(v3, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Transparency = 1,
					Size = createVector(1.25, 1.25, 1.25)
				}):Play()
			end)
			TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = data.cf2 * CFrame.new(math.random(-3, 3), math.random(1, 3), math.random(-3, 3)) * CFrame.new(
					math.random(-20, 20),
					math.random(10, 30),
					math.random(-20, 20)
				) * CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
			}):Play()
		end

		spawn(function()
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(30, 40, 30)
			}):Play()
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 15,
				WaitTime = 0.15
			}, function()
				if not clone3:IsDescendantOf(workspace) then
					return true
				end

				if tick() - lastTime > 0.175 and v2 then
					lastTime = tick()
					local clone4 = replicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
					clone4.CanCollide = false
					clone4.Anchored = true
					clone4.Color = Color3.fromRGB(13, 8, 21)
					clone4.Size = createVector(28.003, 2.953, 28.003)
					clone4.Material = Enum.Material.Neon
					clone4.Transparency = 0.15
					clone4.CFrame = CFrame.new(data.cf2.p) * CFrame.new(0, 2, 0)
					clone4.Parent = workspace.Effects
					TweenService:Create(
						clone4,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(73.303, 7.728, 73.303),
							CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 2.5, 0) * CFrame.Angles(
								0,
								2.0943951023931953,
								0
							)
						}
					):Play()
					TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone4, 1)
				end

				TweenService:Create(clone3, TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 2.792526803190927, 0)
				}):Play()
			end)
		end)
		v2 = false
		wait(0.15)

		if data.diable == true then
			clone3.Flame.Enabled = false
		end

		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(2, 55, 2)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	elseif data.fx == "black_leg_x" then
		-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
		local function bezier(p, p2, p3, p4)
			return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
		end

		local numberValue = Instance.new("NumberValue")
		_G.PU:Dust(numberValue, 5)
		numberValue.Value = 0
		local TweenService2 = game:GetService("TweenService")
		local tween = TweenService2:Create(
			numberValue,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 100
			}
		)
		tween:Play()
		local color = Color3.fromRGB(180, 180, 180)

		if data.diable == true then
			color = Color3.fromRGB(190, 148, 97)
		end

		if game.Players.LocalPlayer.Name == data.plrname then
			local numberValue2 = Instance.new("NumberValue")
			_G.PU:Dust(numberValue2, 5)
			numberValue2.Value = 0
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(numberValue2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Value = 100
			}):Play()
			PeodizService.Heartbeat({
				Time = 0.2,
				WaitTime = 0.03
			}, function(p)
				local v2 = bezier(p, data.cf1.p, data.up.p, data.cf2.p)
				data.root.CFrame = CFrame.new(v2) * (data.root.CFrame - data.root.CFrame.p)
			end)

			if numberValue2 then
				numberValue2:Destroy()
			end
		end

		PeodizService.HeartbeatWait({
			Time = 1,
			WaitTime = 0.05
		}, function()
			if tween.Completed:Wait() then
				return true
			end
		end)

		if numberValue then
			numberValue:Destroy()
		end

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		local clone = replicatedStorage.Chest.Etc.BlackLeg.FlameWind:Clone()
		clone.Size = createVector(1, 70, 1)
		clone.Color = color
		clone.CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 25, 0)
		clone.Parent = workspace.Effects

		if data.diable == true then
			clone.Flame:Emit(15)
			clone.Flame.Enabled = false
		end

		_G.PU:Dust(clone, 3)
		local clone2 = replicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
		clone2.Color = color
		clone2.CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 25, 0)
		clone2.Size = createVector(10, 70, 10)
		clone2.Parent = workspace.Effects
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(209, 126, 78)
		pointLight.Brightness = 2
		pointLight.Range = 40

		if data.diable == true then
			pointLight.Parent = clone
		end

		local clone3 = replicatedStorage.Chest.Etc.BlackLeg.WindRing:Clone()
		clone3.CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 50, 0)
		clone3.Color = color
		clone3.Size = createVector(13.206, 0.977, 13.206)
		clone3.Parent = workspace.Effects
		local clone4 = replicatedStorage.Chest.Etc.BlackLeg.Stone_Shockwave:Clone()
		clone4.CFrame = CFrame.new(data.cf1.p) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone4.Color = color
		clone4.Size = createVector(52.412, 52.412, 10.332)
		clone4.Parent = workspace.Effects
		TweenService:Create(clone4, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(45.573, 45.573, 45.573),
			CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 15, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(40.166, 1.925, 40.166),
			CFrame = clone3.CFrame * CFrame.new(0, 5, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		local v2 = true
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(48.673, 52.5, 48.673)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(1, 50, 1)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 2)
		_G.PU:Dust(clone4, 2)
		_G.PU:Dust(clone3, 2)
		spawn(function()
			for i = 1, 8 do
				local p = (CFrame.new(data.cf1.p) * CFrame.Angles(0, 0.7853981633974483 * i, 0) * CFrame.new(0, 0, -22)).p
				local ray = Ray.new(p + createVector(0, 2, 0), createVector(0, -10, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if not instance then
					continue
				end

				local cframe = CFrame.Angles(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Massless = true
				part.CastShadow = true
				part.Color = instance.Color
				part.Material = instance.Material
				part.CFrame = CFrame.new(position + createVector(0, -0.4, 0)) * cframe
				part.Parent = workspace.Effects

				if instance:FindFirstChild("Texture") then
					for _, texture in pairs(instance:GetChildren()) do
						if not texture:IsA("Texture") then
							continue
						end

						local clone = texture:Clone()
						clone.Parent = part
					end
				end

				if data.diable == true then
					local part2 = Instance.new("Part")
					part2.Anchored = true
					part2.CanCollide = false
					part2.Size = Vector3.new()
					part2.Massless = true
					part2.CastShadow = true
					part2.Color = Color3.fromRGB(255, 147, 93)
					part2.Material = Enum.Material.Neon
					part2.CFrame = CFrame.new(position + createVector(0, -0.4, 0)) * cframe
					part2.Parent = workspace.Effects
					TweenService:Create(part2, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = createVector(5.1, 5.1, 5.1)
					}):Play()
					TweenService:Create(
						part2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					_G.PU:Dust(part2, 3)
					local clone5 = replicatedStorage.Chest.Etc.BlackLeg.flame:Clone()
					clone5.Parent = part
					local v3 = i
					spawn(function()
						wait(1 + v3 * wait())
						clone5.Enabled = false
					end)
				end

				TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					Size = createVector(5, 5, 5)
				}):Play()
				_G.PU:Dust(part, 3)
				local v3 = i
				spawn(function()
					wait(1 + v3 * wait())
					TweenService:Create(
						part,
						TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Position = part.Position + createVector(0, -4, 0)
						}
					):Play()
					wait(0.5)
					TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
						Size = createVector(1, 1, 1),
						Transparency = 1,
						Position = part.Position + createVector(0, -5, 0)
					}):Play()
				end)
			end
		end)
		spawn(function()
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 15,
				WaitTime = 0.05
			}, function()
				if not clone:IsDescendantOf(workspace) then
					return true
				end

				if tick() - lastTime > 0.175 and v2 then
					lastTime = tick()
					local clone5 = replicatedStorage.Chest.Etc.BlackLeg.WindRing:Clone()
					clone5.Color = Color3.fromRGB(156, 139, 111)
					clone5.Transparency = 0.15
					clone5.CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 5, 0) * CFrame.Angles(
						3.141592653589793,
						0,
						0
					)
					clone5.Size = createVector(63.869, 4.723, 63.869)
					TweenService:Create(
						clone5,
						TweenInfo.new(1.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(56.518, 4.856, 56.518),
							CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 55, 0) * CFrame.Angles(
								3.141592653589793,
								0,
								0
							)
						}
					):Play()
					TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone5, 1)
					local clone6 = replicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
					clone6.CanCollide = false
					clone6.Anchored = true
					clone6.Color = Color3.fromRGB(13, 8, 21)
					clone6.Size = createVector(28.003, 2.953, 28.003)
					clone6.Material = Enum.Material.Neon
					clone6.Transparency = 0.15
					clone6.CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 2, 0)
					clone6.Parent = workspace.Effects
					TweenService:Create(
						clone6,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(73.303, 7.728, 73.303),
							CFrame = CFrame.new(data.cf1.p) * CFrame.new(0, 2.5, 0) * CFrame.Angles(
								0,
								2.0943951023931953,
								0
							)
						}
					):Play()
					TweenService:Create(clone6, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone6, 1)
				end

				TweenService:Create(clone, TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad), {
					CFrame = clone.CFrame * CFrame.Angles(0, 2.792526803190927, 0)
				}):Play()
			end)
		end)
		wait(0.3)
		v2 = false
		clone.Flame.Enabled = false
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(5, 70, 5)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	elseif data.fx == "black_leg_c" then
		local cf = data.cf
		local color = Color3.fromRGB(180, 180, 180)

		if data.diable == true then
			color = Color3.fromRGB(190, 148, 97)
		end

		local model = Instance.new("Model")
		model.Name = "CharModel"
		model.Parent = workspace.Effects
		_G.PU:Dust(model, 2)

		local function clone(char)
			local clones = {}

			for _, part in pairs(char:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				local clone2 = part:Clone()
				clone2:ClearAllChildren()
				clone2.Material = Enum.Material.Neon
				clone2.Color = Color3.fromRGB(20, 14, 11)
				clone2.Size = part.Size + createVector(0.05, 0.05, 0.05)
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Parent = model
				clones[#clones + 1] = clone2
				_G.PU:Dust(clone2, 1)
			end

			task.delay(10, function()
				table.clear(clones)
			end)
			return clones
		end

		local char = data.char
		local v2 = clone(char)

		if game.Players.LocalPlayer.Name == data.plrname then
			localPlayer2.Character.HumanoidRootPart.CFrame = cf

			for _, v3 in pairs(v2) do
				TweenService:Create(v3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(v3, 1)

				if data.char:FindFirstChild(v3.Name) then
					TweenService:Create(v3, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
						CFrame = char[v3.Name].CFrame
					}):Play()
				end
			end
		end

		local magnitude = (data.lastcf.p - data.cf.p).magnitude
		local clone2 = replicatedStorage.Chest.FruitEffect.Op.Wind:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = CFrame.new(data.lastcf.p, data.cf.p) * CFrame.new(0, 0, -magnitude / 2)
		clone2.Size = Vector3.new(4, 0.05, magnitude)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(6, 8.5, clone2.Size.Z)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		for i = 1, 3 do
			local size = createVector(30.433, 0.965, 30.433) - createVector(30.433, 0.965, 30.433) * (i * 0.115)
			local clone3 = replicatedStorage.Chest.Etc.BlackLeg.Rings:Clone()
			clone3.Size = Vector3.new()
			clone3.Color = color
			clone3.CFrame = CFrame.new(cf.p) * CFrame.new(0, i * 17.5 + 2 - 5, 0)
			clone3.Size = size
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1)
			TweenService:Create(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(size.X * 2, size.Y * 1.1, size.Z * 2),
				CFrame = clone3.CFrame * CFrame.new(0, 10, 0)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end

		for _ = 1, 3 do
			local clone3 = replicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
			clone3.Color = color
			clone3.CFrame = CFrame.new(cf.p) * CFrame.new(
				math.random(-7, 7),
				12.5 + math.random(-2, 5),
				math.random(-7, 7)
			)
			clone3.Size = createVector(0.3, 22.936, 0.3)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1)
			TweenService:Create(clone3, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(0, math.random(15, 25), 0),
				Size = createVector(0.1, 33.816, 0.1)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Transparency = 1,
				Color = Color3.fromRGB(120, 120, 120)
			}):Play()
		end

		for _ = 1, 4 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CFrame = CFrame.new(data.cf.p + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
			part.CanCollide = false
			_G.PU:Dust(part, 2)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.Anchored = false
			part.Massless = true
			part.CastShadow = false
			part.Size = Vector3.new(math.random(1, 3), math.random(1, 3), math.random(1, 3)) * math.random(3, 6) / 10
			part.Parent = workspace.Effects
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Parent = part
			bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
			bodyVelocity.Velocity = Vector3.new(math.random(-20, 20), math.random(80, 95), math.random(-20, 20))
			_G.PU:Dust(bodyVelocity, 0.1)
		end

		for _ = 1, 7 do
			local cFrame = CFrame.new(data.cf.p) * CFrame.Angles(
				math.random(-2, 2),
				math.random(-2, 2),
				math.random(-2, 2)
			)
			local clone3 = replicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
			clone3.Color = color
			clone3.CFrame = cFrame
			clone3.Size = createVector(10, 1.5, 1.5)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1)
			TweenService:Create(clone3, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, math.random(15, 20)),
				CFrame = cFrame * CFrame.new(0, 0, -math.random(30, 35))
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
		end

		for i = 1, 10 do
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CanCollide = false
			local p = (CFrame.new(data.cf.p + createVector(0, 2, 0)) * CFrame.Angles(0, 0.6283185307179586 * i, 0) * CFrame.new(
				0,
				0,
				-24
			)).p
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(p, createVector(0, -10, 0), raycastParams)

			if not (raycastResult and raycastResult.Instance) then
				continue
			end

			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part.CFrame = CFrame.new(position + createVector(0, -6, 0)) * CFrame.Angles(
				0.3490658503988659,
				0.6283185307179586 * i,
				0
			)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.Size = createVector(1, 1, 1)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 2)
			local vector2 = Vector3.new(17.25, math.random(70, 80) / 10, math.random(6, 8))
			TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = vector2,
				CFrame = CFrame.new(position + Vector3.new(0, -0.85 - (10 - vector2.Y) / 2, 0)) * CFrame.Angles(
					0,
					0.6283185307179586 * i,
					0
				) * CFrame.Angles(-0.6108652381980153, 0, 0)
			}):Play()

			if data.diable == true then
				local clone3 = replicatedStorage.Chest.Etc.BlackLeg.flame:Clone()
				clone3.Parent = part
				spawn(function()
					wait(0.5)
					clone3.Enabled = false
				end)
			end

			local parent = part
			local v5 = i
			spawn(function()
				wait(0.5)
				TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
					Transparency = 1,
					CFrame = CFrame.new(position + createVector(0, -7.5, 0)) * CFrame.Angles(
						0,
						0.6283185307179586 * v5,
						0
					) * CFrame.Angles(-0.4188790204786391, 0, 0)
				}):Play()
			end)
		end

		local clone3 = replicatedStorage.Chest.Etc.BlackLeg.Sphere:Clone()
		clone3.Color = color
		clone3.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 27.5, 0)
		clone3.Size = createVector(10, 60, 10)
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0.1, 55, 0.1),
			Color = Color3.fromRGB(100, 100, 100)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 2)
		local clone4 = replicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
		clone4.CanCollide = false
		clone4.Anchored = true
		clone4.Color = Color3.fromRGB(13, 8, 21)
		clone4.Size = createVector(28.003, 2.953, 28.003)
		clone4.Material = Enum.Material.Neon
		clone4.Transparency = 0.15
		clone4.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 2, 0)
		clone4.Parent = workspace.Effects
		TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(73.303, 7.728, 73.303),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0.8726646259971648, 0)
		}):Play()
		TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone4, 1)
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.Stone_Shockwave:Clone()
		clone5.CFrame = CFrame.new(data.cf.p) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone5.Color = color
		clone5.Size = createVector(52.412, 52.412, 10.332)
		clone5.Parent = workspace.Effects
		TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(45.573, 45.573, 45.573),
			CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 15, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone5, 1)
		local clone6 = replicatedStorage.Chest.Etc.BlackLeg.FlameWind:Clone()
		clone6.Size = createVector(20, 25.794, 20)
		clone6.Transparency = 0.1
		clone6.Color = color
		clone6.CFrame = CFrame.new(data.cf.p) * CFrame.new(0, -12.5, 0)
		clone6.Parent = workspace.Effects
		_G.PU:Dust(clone6, 3)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(209, 126, 78)
		pointLight.Brightness = 2
		pointLight.Range = 40

		if data.diable == true then
			pointLight.Parent = clone6
		end

		spawn(function()
			TweenService:Create(clone6, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(35.06, 65.551, 35.06),
				CFrame = CFrame.new(data.cf.p) * CFrame.new(0, 50, 0)
			}):Play()
			tick()
			PeodizService.HeartbeatWait({
				Time = 15,
				WaitTime = 0.05
			}, function()
				if not clone6:IsDescendantOf(workspace) then
					return true
				end

				TweenService:Create(clone6, TweenInfo.new(0.06666666666666667, Enum.EasingStyle.Quad), {
					CFrame = clone6.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
				}):Play()
			end)
		end)
		wait(0.2)
		clone6.Flame.Enabled = false
		TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(1, 55, 1)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
	elseif data.fx == "black_leg_v" then
		local _ = data.cf
		local root = data.root
		local total = 0
		tick()
		local lastTime = tick()
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(209, 126, 78)
		pointLight.Brightness = 2
		pointLight.Range = 10
		_G.PU:Dust(pointLight, 4)

		if data.diable == true then
			pointLight.Parent = root
		end

		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6605151904",
			Volume = 2,
			TimePosition = 0.4,
			Looped = true
		})
		_G.PU:Dust(sound, 2.6)
		sound.Parent = root
		sound:Play()
		PeodizService.HeartbeatWait({
			Time = 2.6,
			WaitTime = 0.05
		}, function()
			if not root:IsDescendantOf(workspace) then
				return true
			end

			local color = Color3.fromRGB(190, 190, 190)

			if data.diable == true then
				color = Color3.fromRGB(190, 148, 97)
			end

			if math.random(1, 3) == 1 then
				color = Color3.fromRGB()
			end

			total += 45

			if tick() - lastTime > 0.5 then
				lastTime = tick()
				local clone = replicatedStorage.Chest.Etc.BlackLeg.Rings:Clone()
				clone.Size = Vector3.new()
				clone.Color = Color3.fromRGB(170, 170, 170)
				clone.CFrame = CFrame.new(root.CFrame.p) * CFrame.new(0, 2.25, 0)
				clone.Size = createVector(7.711, 0.05, 7.711)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(
					clone,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(21.27, 0.232, 21.27),
						CFrame = clone.CFrame * CFrame.new(0, 1.25, 0)
					}
				):Play()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Transparency = 1
				}):Play()
			end

			local clone = replicatedStorage.Chest.Etc.BlackLeg.party:Clone()
			clone.Color = color
			clone.Size = createVector(8.758, 0.192, 9.754)
			clone.CFrame = CFrame.new(root.CFrame.p) * CFrame.Angles(0, math.rad(total), 0)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 1)

			if data.diable then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://5169902349",
					PlaybackSpeed = 2.25,
					Volume = 0.15
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone
				sound2:Play()
				clone.smallflame:Emit(math.random(1, 3))
			end

			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(14.81, 0.325, 16.495),
				CFrame = clone.CFrame * CFrame.new(5, 3, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		TweenService:Create(pointLight, TweenInfo.new(0.75, Enum.EasingStyle.Quad), {
			Brightness = 0
		}):Play()
	elseif data.fx == "cyborg_x" then
		local cf = data.cf

		if (localPlayer2.Character.HumanoidRootPart.Position - cf.p).Magnitude < 30 then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.WindRing:Clone()
		clone.Transparency = 0.2
		clone.Color = Color3.fromRGB(160, 160, 160)
		clone.CFrame = cf * CFrame.new(0, 0, -3) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Size = createVector(20.626, 1.525, 20.626)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(49.713, 1.525, 49.713),
			CFrame = cf * CFrame.new(0, 0, 2) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave2:Clone()
		clone2.Transparency = 0.75
		clone2.CanCollide = false
		clone2.Size = Vector3.new()
		clone2.CFrame = cf * CFrame.new(0, 0, -3) * CFrame.Angles(3.141592653589793, 0, 1.5707963267948966)
		clone2.CFrame *= CFrame.Angles(0, 0, (math.rad(tick() * 5)))
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(86.174, 82.898, 24.278)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		local clone3 = replicatedStorage.Chest.MeleeEffect.Cyborg.air_canon:Clone()
		clone3.Size = createVector(1, 1, 33)
		clone3.Anchored = false
		clone3.CFrame = cf * CFrame.new(0, 0, -20) * CFrame.Angles(0, 3.141592653589793, 0)
		clone3.smoke.Enabled = true
		clone3.Attachment.Spark:Emit(20)
		clone3.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6756611379",
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone3
		sound:Play()
		local v2 = cf * CFrame.new(0, 0, -25) * CFrame.Angles(0, 3.141592653589793, 0) - (cf * CFrame.new(0, 0, -25) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)).p
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(18, 18, 60)
		}):Play()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Parent = clone3
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Velocity = cf.LookVector * 200
		local lastTime = tick()
		PeodizService.new({
			Time = 15
		}, function()
			if not workspace.Effects:FindFirstChild(data.name) then
				return true
			end

			if tick() - lastTime > 0.05 then
				lastTime = tick()

				for _ = 1, math.random(1, 3) do
					local v3 = math.random(100, 165)
					local clone4 = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
					clone4.CastShadow = false
					clone4.Size = createVector(0.5, 0.5, 0.5)
					clone4.Anchored = true
					clone4.CanCollide = false
					clone4.Color = Color3.fromRGB(v3, v3, v3)
					clone4.CFrame = CFrame.new(clone3.CFrame.p) * v2 * CFrame.new(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 5)
					)
					clone4.Parent = workspace.Effects
					_G.PU:Dust(clone4, 2)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(
						clone4,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0.35, 0.35, math.random(20, 25))
						}
					):Play()
					spawn(function()
						wait(0.1)
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(
							clone4,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
				end

				local clone4 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
				clone4.Transparency = 0.3
				clone4.Size = Vector3.new()
				clone4.CFrame = CFrame.new(clone3.CFrame.p) * v2 * CFrame.Angles(
					0,
					-1.5707963267948966,
					1.5707963267948966
				)
				clone4.CFrame *= CFrame.Angles(0, math.rad(tick() * 5), 0)
				clone4.Parent = clone3
				TweenService:Create(
					clone4,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.Angles(0, math.rad(tick() * 10), 0),
						Size = createVector(35.306, 3.917, 35.306)
					}
				):Play()
				_G.PU:Dust(clone4, 1)
				spawn(function()
					wait(0.05)
					TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				local clone5 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave2:Clone()
				clone5.Transparency = 0.9
				clone5.Size = Vector3.new()
				clone5.CFrame = CFrame.new(clone3.CFrame.p) * v2 * CFrame.Angles(0, 0, 1.5707963267948966)
				clone5.CFrame *= CFrame.Angles(0, 0, (math.rad(tick() * 5)))
				clone5.Parent = clone3
				TweenService:Create(
					clone5,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.Angles(0, 0, (math.rad(tick() * 10))),
						Size = createVector(36.964, 35.56, 12.407)
					}
				):Play()
				_G.PU:Dust(clone5, 1)
				spawn(function()
					wait(0.05)
					TweenService:Create(clone5, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				local clone6 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone6.Transparency = 0.2
				clone6.Color = Color3.fromRGB(160, 160, 160)
				clone6.CFrame = CFrame.new(clone3.CFrame.p) * v2 * CFrame.Angles(
					1.5707963267948966,
					-1.5707963267948966,
					0
				)
				clone6.Size = Vector3.new()
				clone6.Parent = workspace.Effects
				spawn(function()
					wait(0.05)
					TweenService:Create(clone6, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
					wait(0.1)
					TweenService:Create(clone6, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new()
					}):Play()
				end)
				TweenService:Create(
					clone6,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(26.994, 1.996, 26.994)
					}
				):Play()
				_G.PU:Dust(clone6, 1)
			end

			clone3.CFrame *= CFrame.Angles(0, 0, 0.08726646259971647)
		end)

		if (localPlayer2.Character.HumanoidRootPart.Position - clone3.CFrame.p).Magnitude < 30 then
			v:Shake(CameraShaker.Presets.Bump2)
		end

		PeodizService.ForLoop({
			Step = 10
		}, function()
			local v3 = math.random(20, 25)
			local cFrame = CFrame.new(clone3.CFrame.p) * CFrame.new(
				math.random(-5, 5),
				math.random(-5, 5),
				math.random(-5, 5)
			)
			local clone4 = replicatedStorage.Chest.MeleeEffect.Cyborg.cartoon_smoke:Clone():Clone()
			clone4.Color = Color3.fromRGB(160, 160, 160)
			clone4.Material = Enum.Material.Neon
			clone4.Size = createVector(40, 40, 40)
			clone4.CFrame = cFrame
			clone4.smoke:Emit(math.random(5, 10))
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(v3, v3, v3)
			}):Play()
			_G.PU:Dust(clone4, 2)
			local clone5 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
			clone5.Transparency = 0.2
			clone5.Color = Color3.fromRGB(160, 160, 160)
			clone5.CFrame = CFrame.new(clone3.CFrame.p) * CFrame.Angles(
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793
			)
			clone5.Size = Vector3.new()
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(53.635, 1.173, 53.635),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone5, 1)
			spawn(function()
				wait(0.1)
			end)
			local clone6 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
			clone6.Transparency = 0.75
			clone6.Size = Vector3.new()
			clone6.CFrame = CFrame.new(clone3.CFrame.p) * CFrame.Angles(
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793,
				math.random() * 2 * 3.141592653589793
			)
			clone6.Parent = clone3
			TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(78.553, 8.714, 78.554)
			}):Play()
			_G.PU:Dust(clone6, 1)
			spawn(function()
				wait(0.05)
				TweenService:Create(clone6, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
			delay(0.1, function()
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
					Size = createVector(0, 0, 0),
					Color = Color3.fromRGB(120, 120, 120),
					CFrame = clone4.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, math.random(15, 20), 0)
				}):Play()
			end)
		end)
		spawn(function()
			for _ = 1, math.random(5, 8) do
				local clone4 = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
				clone4.CastShadow = false
				clone4.Size = createVector(8, 8, 0.5)
				clone4.Anchored = true
				clone4.CanCollide = false
				clone4.Color = Color3.fromRGB(160, 160, 160)
				clone4.CFrame = clone3.CFrame * CFrame.Angles(
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793
				)
				clone4.Parent = workspace.Effects
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone4,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(0, 0, math.random(15, 18)),
						CFrame = clone4.CFrame * CFrame.new(0, 0, math.random(25, 30))
					}
				):Play()
				spawn(function()
					wait(0.1)
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(clone4, 1)
			end
		end)
		clone3.smoke.Enabled = false
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 60),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 0.35)
	elseif data.fx == "cyborg_e" then
		local target = data.target
		local chargeFolder = data.ChargeFolder
		local rootPart = data.RootPart
		local localPlayer3 = game.Players.LocalPlayer

		if (target.HumanoidRootPart.Position - localPlayer3.Character.HumanoidRootPart.Position).Magnitude > 100 then
			return
		end

		local function clear(clone)
			local children = clone:GetChildren()

			for i = 1, #children do
				if not (children[i]:IsA("Motor6D") or children[i]:IsA("Weld")) then
					continue
				end

				children[i]:Destroy()
			end
		end

		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.5
		}, function()
			if not chargeFolder:IsDescendantOf(target) then
				return true
			end

			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6735800916",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			local model = Instance.new("Model")
			model.Parent = workspace.Effects
			_G.PU:Dust(model, 1)
			local descendants = target:GetDescendants()

			for i = 1, #descendants do
				if not descendants[i]:IsA("BasePart") or descendants[i].Transparency == 1 or not (descendants[i].Size.magnitude <= 10) or _G.AntiMob() then
					continue
				end

				local clone = descendants[i]:clone()

				if clone.Name == "Head" then
					clone = script.head:Clone()
					clone.Name = target.Name
					local v2 = not target.Humanoid:findFirstChild("HeadScale") and 1 or target.Humanoid.HeadScale.Value
					clone.Size *= v2
				end

				clone.Name = target.Name
				clone.Massless = true
				clone.Anchored = false
				clone.CanCollide = false
				clone.Color = Color3.fromRGB(166, 140, 73)
				clone.Material = "Neon"
				clone.Size *= 1.01
				clone.Parent = model
				clone.Transparency = 0.5

				if clone:IsA("MeshPart") then
					clone.TextureID = ""
				end

				clear(clone)
				local weld = Instance.new("Weld", clone)
				weld.Part0 = descendants[i]
				weld.Part1 = clone

				if target.Humanoid.Health <= 0 then
					clone.Anchored = true
				end

				local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0)
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(clone, tweenInfo, {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 0.35)
			end
		end)
	elseif data.fx == "cyborg_e_full" then
		local target = data.target
		local localPlayer3 = game.Players.LocalPlayer

		if (target.HumanoidRootPart.Position - localPlayer3.Character.HumanoidRootPart.Position).Magnitude > 100 then
			return
		end

		local function clear(instance)
			local children = instance:GetChildren()

			for i = 1, #children do
				if not (children[i]:IsA("Motor6D") or children[i]:IsA("Weld")) then
					continue
				end

				children[i]:Destroy()
			end
		end
	elseif data.fx == "cyborg_v" then
		local char = data.char
		local lastTime = tick()
		local lastTime2 = tick()
		local humanoidRootPart = localPlayer2.Character.HumanoidRootPart
		local humanoidRootPart2 = char.HumanoidRootPart
		local cFrame = humanoidRootPart2.CFrame
		local position = humanoidRootPart2.Position
		local v2 = 0
		local highlight = Instance.new("Highlight")
		_G.PU:Dust(highlight, 15)
		highlight.FillColor = Color3.fromRGB(255, 85, 0)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = char
		local sound = Instance.new("Sound")
		sound.Parent = humanoidRootPart2
		sound.Volume = 2
		sound.TimePosition = 0.1
		sound.RollOffMaxDistance = 1250
		sound.SoundId = "rbxassetid://6738924941"
		sound:Play()
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")

		if (humanoidRootPart.CFrame.p - data.Position).magnitude < 100 then
			colorCorrectionEffect.Parent = game.Lighting
			_G.PU:Dust(colorCorrectionEffect, 6)
		end

		PeodizService.new({
			Time = 15
		}, function()
			if not (char:FindFirstChild("CyborgV") and char:IsDescendantOf(workspace) and data.CyborgFolder:IsDescendantOf(char)) then
				return true
			end

			v2 = math.clamp(v2, 0, 600)

			if tick() - lastTime2 > 0.4 then
				lastTime2 = tick()
				local v3 = (math.floor(v2 / 8.5) + 45) / 1.5
				local cFrame2 = humanoidRootPart2.CFrame
				local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
				clone.CastShadow = false
				clone.Size = Vector3.new()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Color = Color3.fromRGB(248, 95, 64)
				clone.CFrame = cFrame2
				clone.Transparency = 0.2
				clone.Material = Enum.Material.ForceField
				clone.Parent = workspace.Effects
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(v3, v3, v3)
					}
				):Play()
				spawn(function()
					wait(0.05)
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(clone, 1)
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Transparency = 0.75
				clone2.Color = Color3.fromRGB(150, 150, 150)
				clone2.CFrame = cFrame2 * CFrame.Angles(
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793
				)
				clone2.Size = Vector3.new()
				clone2.Parent = workspace.Effects
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(
					clone2,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(v3 * 1.5, 0.2, v3 * 1.5)
					}
				):Play()
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 1)
			end

			if tick() - lastTime > 0.1 then
				lastTime = tick()

				for _ = 1, math.random(2, 4) do
					local cFrame2 = humanoidRootPart2.CFrame
					CFrame.Angles(
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793
					)
					local v3 = math.random(30, 35)
					local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
					clone.CastShadow = false
					clone.Size = createVector(2.25, 2.25, 7.5)
					clone.Anchored = true
					clone.CanCollide = false
					clone.Color = Color3.fromRGB(248, 95, 64)
					clone.CFrame = cFrame2 * CFrame.Angles(
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793,
						math.random() * 2 * 3.141592653589793
					) * CFrame.new(0, 0, -v3)
					clone.Parent = workspace.Effects

					if math.random(1, 3) == 1 then
						clone.Color = Color3.fromRGB()
					end

					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = createVector(0.2, 0.2, 10.5),
						CFrame = clone.CFrame * CFrame.new(0, 0, v3)
					}):Play()
					spawn(function()
						wait(0.2)
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(
							clone,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(clone, 1)
				end
			end

			v2 += 4
			colorCorrectionEffect.Contrast = math.floor(v2 / 10) / 100
			colorCorrectionEffect.Saturation = -math.floor(v2 / 10) / 200

			if game.Players.LocalPlayer.Name == data.plrname then
				humanoidRootPart2.CFrame = CFrame.new(position) * (humanoidRootPart2.CFrame - humanoidRootPart2.CFrame.p) * CFrame.new(
					math.random(-1, 1) / 10,
					math.random(-1, 1) / 10,
					math.random(-1, 1) / 10
				)
			end

			if highlight and highlight.Parent then
				highlight.FillTransparency = (100 - math.floor(v2 / 10) + 10) / 100
			end
		end)
		sound:Destroy()
		colorCorrectionEffect:Destroy()

		if highlight and highlight.Parent then
			highlight:Destroy()
			highlight = nil
		end

		local v3 = math.floor(v2 / 100)
		local v4 = math.floor(v2 / 8.5) + 45

		if (localPlayer2.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < v4 / 2 + 10 then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		spawn(function()
			for i = 1, 3 do
				local v5 = i
				local cFrame2 = humanoidRootPart2.CFrame
				spawn(function()
					local clone = game.ReplicatedStorage.Chest.MeleeEffect.Cyborg.M:Clone()
					_G.PU:Dust(clone, 2)
					clone.Color = Color3.fromRGB(170, 85, 0)

					if v5 == 3 then
						clone.Color = Color3.fromRGB(255, 85, 0)
					elseif v5 == 2 then
						clone.Color = Color3.fromRGB(255, 110, 0)
					end

					clone.CFrame = cFrame2
					clone.Parent = workspace.Effects
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1250,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://165970126",
						Volume = 0.5
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone
					sound2:Play()
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = createVector(1, 1, 1) * v4
					}):Play()
					TweenService:Create(clone, TweenInfo.new(2, Enum.EasingStyle.Quad), {
						CFrame = clone.CFrame * CFrame.Angles(
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random()
						)
					}):Play()
					wait(0.25)
					TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new()
					})
					TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new(),
						Color = Color3.fromRGB()
					}):Play()
				end)
			end

			local step = math.random(6, 8)
			PeodizService.ForLoop({
				Step = step
			}, function(p)
				local v6 = math.floor(p * step)
				local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
				clone.Transparency = math.random(2, 3) / 10
				clone.Size = Vector3.new()
				clone.CFrame = CFrame.new(humanoidRootPart2.CFrame.p) * CFrame.Angles(
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793
				)
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(v4, v4 / 10, v4) * (v6 / 5 + 1)
					}
				):Play()
				_G.PU:Dust(clone, 1)
				spawn(function()
					wait(0.1)
					TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
			end)
		end)
		PeodizService.ForLoop({
			Step = 12 + v3
		}, function(p)
			local v5 = math.floor(p * (v3 + 12))
			local part = Instance.new("Part")
			part.Size = createVector(1, 1, 1)
			part.Anchored = true
			part.CanCollide = false
			local p2 = (CFrame.new(cFrame.p + createVector(0, 2, 0)) * CFrame.Angles(
				0,
				6.283185307179586 / (v3 + 12) * v5,
				0
			) * CFrame.new(0, 0, -v4 / 2 - 5)).p
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(p2, createVector(0, -15, 0), raycastParams)

			if raycastResult and raycastResult.Instance then
				local instance = raycastResult.Instance
				local position2 = raycastResult.Position
				local vector2 = Vector3.new(math.max(5, v4 * 0.09), math.max(5, v4 * 0.09), (math.max(5, v4 * 0.09)))
				part.CFrame = CFrame.new(position2 + createVector(0, -8, 0)) * CFrame.Angles(
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2,
					3.141592653589793 * math.random() * 2
				)
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.Size = Vector3.new()
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
					Size = vector2,
					CFrame = CFrame.new(position2 + Vector3.new(0, -(vector2.Y / 2) + vector2.Y / 3, 0)) * CFrame.Angles(
						3.141592653589793 * math.random() * 2,
						3.141592653589793 * math.random() * 2,
						3.141592653589793 * math.random() * 2
					)
				}):Play()
				spawn(function()
					wait(1 + v5 * wait())
					TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1,
						CFrame = CFrame.new(position2 + Vector3.new(0, -vector2.Y - 2, 0)) * (part.CFrame - part.CFrame.p)
					}):Play()
				end)
				_G.PU:Dust(part, 2.5)
			end
		end)
	elseif data.fx == "cyborg_z" then
		local char = data.char
		local humanoidRootPart = char.HumanoidRootPart
		local lastTime = tick()
		PeodizService.HeartbeatWait({
			Time = 5.1,
			WaitTime = 0.05
		}, function()
			if not (char:FindFirstChild("CyborgZ") and char:IsDescendantOf(workspace.PlayerCharacters)) then
				return true
			end

			if tick() - lastTime > 0.1 then
				lastTime = tick()
				local sound = Instance.new("Sound")
				sound.Parent = humanoidRootPart
				sound.Volume = 0.5
				sound.PlaybackSpeed = 1.25
				sound.RollOffMaxDistance = 750
				sound.SoundId = "rbxassetid://6747750655"
				sound:Play()
				_G.PU:Dust(sound, 1)
			end

			for _ = 1, math.random(1, 2) do
				local v2 = humanoidRootPart.CFrame * CFrame.new(0, 1, 0) * CFrame.new(0, 0, -math.random(18, 20))
				local cframe = CFrame.new(
					(humanoidRootPart.CFrame * CFrame.new(0, 1, 0) * CFrame.new(
						math.random(-6, 6),
						math.random(-4, 6),
						math.random(-3, 2)
					)).p,
					v2.p
				)
				local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Fist:Clone()
				clone.CFrame = cframe * CFrame.new(0, 0, 2.5)
				clone.Fist.Color = data.color
				clone.Parent = workspace.Effects
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
				clone2.Size = Vector3.new()
				clone2.Transparency = 0.5
				clone2.CFrame = cframe * CFrame.new(0, 0, -math.random(15, 17)) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone2.Parent = workspace.Effects
				local clone3 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone3.Size = Vector3.new()
				clone3.Transparency = 0.75
				clone3.CFrame = cframe * CFrame.new(0, 0, -2) * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(
					clone3,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						Size = createVector(6.402, 0.14, 6.402),
						CFrame = clone3.CFrame * CFrame.new(0, -1, 0)
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(6.558, 0.727, 6.558)
					}
				):Play()
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
					CFrame = cframe * CFrame.new(0, 0, -math.random(140, 155) / 10) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(1.963, 1.791, 2.336)
				}):Play()
				TweenService:Create(clone.Fist, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(1.845, 1.515, 1.269)
				}):Play()
				task.spawn(function()
					PeodizService.HeartbeatWait({
						Time = 0.25,
						Tween = {
							EasingStyle = Enum.EasingStyle.Exponential,
							EasingDirection = Enum.EasingDirection.Out
						}
					}, function(p)
						local v4 = math.floor(p * 100)

						if clone:FindFirstChild("Trail") then
							clone.Trail.Transparency = NumberSequence.new(v4 / 100, 1)
						end
					end)
				end)
				TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = clone.CFrame * CFrame.new(0, 0, -math.random(15, 18))
				}):Play()
				local v4 = clone
				spawn(function()
					wait(0.05)
					TweenService:Create(
						v4,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						v4.Fist,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				_G.PU:Dust(clone, 1)
				_G.PU:Dust(clone3, 1)
				_G.PU:Dust(clone2, 1)
			end
		end)
	elseif data.fx == "cyborg_c" then
		local cf = data.cf
		local root = data.root
		v:Shake(CameraShaker.Presets.Bump)

		local function explode()
			for i = 1, math.floor((cf.p - (cf * CFrame.new(0, 0, 200)).p).magnitude / 5) do
				local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
				clone.CFrame = cf * CFrame.new(0, 0, -i * 5 + 5) * CFrame.Angles(
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793,
					math.random() * 2 * 3.141592653589793
				)
				clone.Anchored = true
				clone.Color = Color3.fromRGB(255, 182, 108)
				clone.CanCollide = false
				clone.Size = createVector(5, 5, 5)
				clone.Transparency = 0
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone,
					TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(),
						CFrame = clone.CFrame * CFrame.new(0, 0, -math.random(14, 20))
					}
				):Play()
				spawn(function()
					wait(0.15)
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(clone, 1)
			end
		end

		local function fx()
			for i = 1, math.floor((cf.p - (cf * CFrame.new(0, 0, 200)).p).magnitude / 50) - 1 do
				local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Shockowave:Clone()
				clone.Anchored = true
				clone.CanCollide = false
				clone.Transparency = 0.15
				clone.Size = Vector3.new()
				clone.CFrame = cf * CFrame.new(0, 0, -i * 50) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-35, 35))),
					math.rad((math.random(-35, 35))),
					(math.rad((math.random(-35, 35))))
				)
				clone.Parent = workspace.Effects
				TweenService:Create(
					clone,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(39.69, 4.4040003, 39.69)
					}
				):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 1)
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Transparency = 0.75
				clone2.Size = Vector3.new()
				clone2.CFrame = cf * CFrame.new(0, 0, -i * 50) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-15, 15))),
					math.rad((math.random(-15, 15))),
					(math.rad((math.random(-15, 15))))
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1,
						Size = createVector(73.278, 1.5195, 73.2792)
					}
				):Play()
				_G.PU:Dust(clone2, 1)
			end
		end

		local function fx2()
			spawn(function()
				local _ = (cf.p - (cf * CFrame.new(0, 0, 200)).p).magnitude

				for _ = 1, math.random(10, 12) do
					local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
					clone.CFrame = cf * CFrame.Angles(
						math.rad((math.random(-45, 45))),
						math.rad((math.random(-45, 45))),
						0
					)
					clone.Anchored = true
					clone.Color = Color3.fromRGB(255, 182, 108)
					clone.CanCollide = false
					clone.Size = createVector(5, 5, 5)
					clone.Transparency = 0
					clone.Parent = workspace.Effects
					TweenService:Create(
						clone,
						TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(),
							CFrame = clone.CFrame * CFrame.new(0, 0, math.random(20, 25))
						}
					):Play()
					spawn(function()
						wait(0.175)
						TweenService:Create(
							clone,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(clone, 1)
				end

				for _ = 1, 4 do
					local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
					clone.Anchored = true
					clone.CanCollide = false
					clone.Transparency = 0
					clone.Size = Vector3.new()
					clone.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Color = Color3.fromRGB(255, 182, 108)
					clone.Parent = workspace.Effects
					TweenService:Create(
						clone,
						TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(73.278, 1.5195, 73.2792),
							Transparency = 1,
							CFrame = clone.CFrame * CFrame.new(0, 3, 0)
						}
					):Play()
					_G.PU:Dust(clone, 1)
					wait(wait())
				end
			end)
		end

		local clone = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
		clone.CFrame = cf * CFrame.new(0, 0, -100)
		clone.Anchored = true
		clone.Color = Color3.fromRGB(255, 182, 108)
		clone.CanCollide = false
		clone.Size = createVector(0, 0, 200)
		clone.Transparency = 0.5
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6756650529",
			Volume = 2,
			PlaybackSpeed = 0.95
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = root
		sound:Play()
		spawn(function()
			local _ = (cf.p - (cf * CFrame.new(0, 0, 200)).p).magnitude

			for _ = 1, math.random(10, 12) do
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Sphere:Clone()
				clone2.CFrame = cf * CFrame.Angles(
					math.rad((math.random(-45, 45))),
					math.rad((math.random(-45, 45))),
					0
				)
				clone2.Anchored = true
				clone2.Color = Color3.fromRGB(255, 182, 108)
				clone2.CanCollide = false
				clone2.Size = createVector(5, 5, 5)
				clone2.Transparency = 0
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(),
						CFrame = clone2.CFrame * CFrame.new(0, 0, math.random(20, 25))
					}
				):Play()
				spawn(function()
					wait(0.175)
					TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(clone2, 1)
			end

			for _ = 1, 4 do
				local clone2 = replicatedStorage.Chest.MeleeEffect.Cyborg.Rings:Clone()
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Transparency = 0
				clone2.Size = Vector3.new()
				clone2.CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Color = Color3.fromRGB(255, 182, 108)
				clone2.Parent = workspace.Effects
				TweenService:Create(
					clone2,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(73.278, 1.5195, 73.2792),
						Transparency = 1,
						CFrame = clone2.CFrame * CFrame.new(0, 3, 0)
					}
				):Play()
				_G.PU:Dust(clone2, 1)
				wait(wait())
			end
		end)
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(20, 20, 200),
			Transparency = 0
		}):Play()
		spawn(function()
			wait(0.2)
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.08333333333333334, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 3, true, 0),
				{
					Size = createVector(10, 10, 200)
				}
			)
			tween:Play()
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(25, 25, 200)
				}):Play()
				wait(0.15)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 200)
				}):Play()
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				completedConnection:Disconnect()
			end)
			local lastTime = tick()
			fx()
			PeodizService.HeartbeatWait({
				Time = 15,
				WaitTime = 0.05
			}, function()
				if not clone:IsDescendantOf(workspace.Effects) or clone.Transparency > 0.7 then
					return true
				end

				if tick() - lastTime > 0.2 then
					lastTime = tick()
					fx()
				end
			end)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6756633611",
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = root
			sound2:Play()
			explode()
		end)
	end
end)
swordEffect.OnClientEvent:Connect(function(data)
	local DISTANCE_THRESHOLD = 50
	local localPlayer2 = game.Players.LocalPlayer

	if data.Position ~= nil and (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude > 500 then
		return
	end

	if type(data) == "table" then
		local player = data.Player

		if _G.ReturnEffects(localPlayer, player) then
			return
		end
	end

	if data.fx == "kioru_z" then
		local function clear(instance)
			local children = instance:GetChildren()

			for i = 1, #children do
				if not (children[i]:IsA("Motor6D") or children[i]:IsA("Weld") or children[i]:IsA("WeldConstraint") or children[i]:IsA("ManualWeld")) then
					continue
				end

				children[i]:Destroy()
			end
		end

		local function neon(_) end

		local function neoncf(_, _) end

		local function neontocf(_, _) end

		local cFrames = {}
		local v2 = {}
		local cf = data.cf
		local clone = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.sparko.Attachment:Clone()
		clone.Parent = data.part
		clone.Spark:Emit(2)
		_G.PU:Dust(clone, 1)
		spawn(function()
			local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Sphere:Clone()
			clone2.Size = createVector(10, 10, 10)
			clone2.Transparency = 0
			clone2.Color = Color3.fromRGB(237, 133, 255)
			clone2.CFrame = cf * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			clone2.Parent = workspace.Effects
			clone2.Spark:Emit(10)
			wait()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(30.053, 0, 0)
			}):Play()
			wait()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 1)
		end)
		spawn(function()
			local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Wave:Clone()
			clone2.Size = createVector(11.55, 2.864, 11.55)
			clone2.Transparency = 0
			clone2.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.Angles(-1.5707963267948966, 0, 0)
			}):Play()
			wait(0.05)
			TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(41.366, 1.813, 41.366)
			}):Play()
			_G.PU:Dust(clone2, 1)
		end)
		spawn(function()
			local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.wind:Clone()
			clone2.Size = createVector(26.619, 2.8005, 26.619)
			clone2.Transparency = 0.89
			clone2.Material = Enum.Material.Neon
			clone2.CFrame = cf * CFrame.new(0, 0, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(0, 0, 5) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			}):Play()
			TweenService:Create(
				clone2,
				TweenInfo.new(0.6499999999999999, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone2,
				TweenInfo.new(0.44999999999999996, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(50.568, 13.41, 50.568)
				}
			):Play()
			_G.PU:Dust(clone2, 1)
		end)
		spawn(function()
			local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.shocksmoke:Clone()
			clone2.CFrame = cf * CFrame.new(0, 0, -15)
			clone2.Parent = workspace.Effects
			clone2.sm1:Emit(25)
			clone2.sm2:Emit(25)
			_G.PU:Dust(clone2, 2)
			local clone3 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Shock:Clone()
			clone3.Size = createVector(8.24, 1.22125, 7.90375)
			clone3.Transparency = -1
			clone3.Material = Enum.Material.Neon
			clone3.Color = Color3.fromRGB(188, 143, 255)
			clone3.CFrame = cf * CFrame.new(0, 0, -5) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 1)
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(0, 0, -6.5) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(41.145, 8.177, 39.466)
			}):Play()
			wait(0.05)
			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone3, 1)
		end)
		spawn(function()
			for i = 1, 2 do
				local v3 = {}

				for i2 = 1, 5 do
					local v4 = math.random(50, 80) / 10
					v3[#v3 + 1] = (cf * CFrame.new(math.random(-v4, v4), math.random(-1, v4), i2 * -8 + 8)).p
				end

				local v5 = i
				spawn(function()
					PeodizService.ForceForLoop({
						Step = #v3,
						WaitTime = 0.05
					}, function(p)
						local v6 = math.floor(p * #v3)

						if v3[v6 - 1] then
							local color = Color3.fromRGB(165, 121, 191)
							local color2 = Color3.fromRGB(169, 99, 255)
							local v7 = math.random(50, 120) / 100

							if v5 == 2 then
								color = Color3.fromRGB(255, 255, 255)
								color2 = Color3.fromRGB(255, 255, 255)
							end

							local part = Instance.new("Part")
							part.Material = "Neon"
							part.CastShadow = false
							part.Size = Vector3.new(0, 0, (v3[v6 - 1] - v3[v6]).magnitude)
							part.Color = color
							part.Anchored = true
							part.Transparency = 0
							part.CanCollide = false
							part.CFrame = CFrame.new((v3[v6 - 1] + v3[v6]) / 2, v3[v6 - 1])
							part.Parent = workspace.Effects
							TweenService:Create(
								part,
								TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									Size = Vector3.new(v7, v7, (v3[v6 - 1] - v3[v6]).magnitude)
								}
							):Play()
							spawn(function()
								wait(0.05)
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
									{
										Color = color2,
										Size = Vector3.new(0, 0, (v3[v6 - 1] - v3[v6]).magnitude)
									}
								):Play()
								wait()
								TweenService:Create(
									part,
									TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
									{
										Transparency = 1
									}
								):Play()
							end)
							_G.PU:Dust(part, 1)
						end
					end)
					task.delay(10, function()
						table.clear(v3)
					end)
				end)
			end
		end)
		local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Sphere:Clone()
		clone2.Color = Color3.fromRGB(237, 133, 255)
		clone2.Size = createVector(20, 20, 5)
		clone2.Transparency = 0
		clone2.CFrame = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone2.Size = Vector3.new(20, 20, math.random(0, clone2.Size.Z))
		clone2.Parent = workspace.Effects
		TweenService:Create(
			clone2,
			TweenInfo.new(0.13333333333333333, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Size = createVector(0, 0, 50)
			}
		):Play()
		_G.PU:Dust(clone2, 1)
		spawn(function()
			wait(0.05)
			TweenService:Create(
				clone2,
				TweenInfo.new(0.16666666666666666, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 0, 40)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone2
		pointLight.Range = 60
		pointLight.Color = Color3.fromRGB(206, 107, 255)
		pointLight.Brightness = 1
		TweenService:Create(pointLight, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 1.5,
			Range = 0
		}):Play()
		wait()
		local _ = data.char
		tick()
		v2[#v2 + 1] = (cf * CFrame.new(0, 5, -25)).p

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < DISTANCE_THRESHOLD then
			v:Shake(CameraShaker.Presets.Flash)
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Brightness = 0.1
			colorCorrectionEffect.TintColor = Color3.fromRGB(237, 192, 255)
			colorCorrectionEffect.Parent = game.Lighting
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			_G.PU:Dust(colorCorrectionEffect, 1)
		end

		local v3 = 1
		PeodizService.HeartbeatWait({
			Time = 1.25,
			WaitTime = 0.05
		}, function()
			v3 += 1

			if math.random(1, 2) == 1 then
				local v4 = CFrame.new(
					(cf * CFrame.new(0, 5, -25) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, 15)).p,
					(cf * CFrame.new(0, 5, -25)).p
				) * CFrame.Angles(0, 3.141592653589793, 0)
				local _ = data.char
				v2[#v2 + 1] = v4.p

				if v2[#v2 - 1] and v2[#v2] then
					local part = Instance.new("Part")
					part.Material = "Neon"
					part.CastShadow = false
					part.Size = Vector3.new(0.5, 0.5, (v2[#v2 - 1] - v2[#v2]).magnitude)
					part.Color = Color3.fromRGB(174, 102, 255)
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new((v2[#v2 - 1] + v2[#v2]) / 2, v2[#v2 - 1])
					part.Parent = workspace.Effects
					spawn(function()
						wait(0.1)
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new(0, 0, part.Size.Z)
							}
						):Play()
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							part,
							TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Color = Color3.fromRGB(128, 75, 188)
							}
						):Play()
					end)
					_G.PU:Dust(part, 1)
				end
			end

			if math.random(1, 3) == 1 then
				local clone3 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.slash2:Clone()
				clone3.CFrame = cf * CFrame.new(0, 5, -25) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, math.random(0, 12.5)) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone3.Size = Vector3.new()
				clone3.Parent = workspace.Effects
				TweenService:Create(
					clone3,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}
				):Play()
				TweenService:Create(
					clone3.mesh,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(15.532, 1.604, 15.532)
					}
				):Play()
				_G.PU:Dust(clone3, 1)
				spawn(function()
					wait()
					TweenService:Create(
						clone3.decal,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					TweenService:Create(
						clone3.decal2,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end

			local clone3 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Sphere:Clone()
			clone3.Color = Color3.fromRGB(237, 133, 255)
			clone3.Size = createVector(4, 4, 50)
			clone3.Transparency = 0
			clone3.CFrame = cf * CFrame.new(0, 5, -25) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			) * CFrame.new(0, 0, math.random(0, clone3.Size.Z / 4)) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone3.Size = Vector3.new(5, 5, math.random(0, clone3.Size.Z))
			clone3.Parent = workspace.Effects
			cFrames[#cFrames + 1] = clone3.CFrame

			if v3 == 4 then
				v3 = 1
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://7104937177",
					Volume = 0.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone3
				sound:Play()
			end

			TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0.5, 0.5, 50)
			}):Play()
			_G.PU:Dust(clone3, 1)
			spawn(function()
				wait(0.1)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 50)
					}
				):Play()
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
			local pointLight2 = Instance.new("PointLight")
			pointLight2.Range = 40
			pointLight2.Color = Color3.fromRGB(206, 107, 255)
			pointLight2.Brightness = 1
			pointLight2.Parent = clone3
			TweenService:Create(
				pointLight2,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 1.5,
					Range = 0
				}
			):Play()

			if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
				v:Shake(CameraShaker.Presets.SmallestBump)
			end
		end)

		for _ = 1, 3 do
			local _ = CFrame.new(
				(cf * CFrame.new(0, 5, -25) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, 15)).p,
				(cf * CFrame.new(0, 5, -25)).p
			) * CFrame.Angles(0, 3.141592653589793, 0)
			local _ = data.char
		end

		local clone3 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.sparko.Attachment:Clone()
		clone3.Spark.Lifetime = NumberRange.new(0.3)
		clone3.Spark:Emit(1)
		_G.PU:Dust(clone3, 1)
		wait(0.25)
		local clone4 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Spark2:Clone()
		clone4:Emit(10)
		_G.PU:Dust(clone4, 1)
		local clone5 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.explode:Clone()
		clone5.CFrame = cf * CFrame.new(0, 0, -30)
		clone5.Parent = workspace.Effects
		clone5.sm1:Emit(50)
		_G.PU:Dust(clone5, 2)

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < DISTANCE_THRESHOLD then
			v:Shake(CameraShaker.Presets.Explosion)
		end

		spawn(function()
			local clone6 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.wind:Clone()
			clone6.Size = createVector(26.619, 2.8005, 26.619)
			clone6.Transparency = 0.89
			clone6.Material = Enum.Material.Neon
			clone6.CFrame = cf * CFrame.new(0, 0, -25)
			clone6.Parent = workspace.Effects
			_G.PU:Dust(clone6, 1)
			TweenService:Create(clone6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(0, 0, -25) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(50.568, 13.41, 50.568)
			}):Play()
			_G.PU:Dust(clone6, 1)
		end)

		for k, cFrame in pairs(cFrames) do
			if not (k < 8) then
				continue
			end

			local clone6 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.Sphere:Clone()
			clone6.Color = Color3.fromRGB(237, 133, 255)
			clone6.Transparency = 0
			clone6.CFrame = cFrame
			clone6.Size = createVector(10, 10, 0)
			clone6.Parent = workspace.Effects
			clone6.Spark:Emit(5)
			TweenService:Create(clone6, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(0.25, 0.25, 50)
			}):Play()
			_G.PU:Dust(clone6, 1.5)
			spawn(function()
				wait(0.5)
				TweenService:Create(
					clone6,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				TweenService:Create(clone6, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
			local pointLight2 = Instance.new("PointLight")
			pointLight2.Range = 60
			pointLight2.Color = Color3.fromRGB(206, 107, 255)
			pointLight2.Brightness = 1
			pointLight2.Parent = clone6
			TweenService:Create(
				pointLight2,
				TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 1.5,
					Range = 0
				}
			):Play()
		end

		for _ = 1, 12 do
			local ray = Ray.new(
				(cf * CFrame.new(0, 0, -25) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					0,
					-math.random(0, 25)
				)).p,
				createVector(0, -10, 0)
			)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

			if not instance then
				continue
			end

			local part = Instance.new("Part")
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.CastShadow = false
			part.Size = createVector(2, 2, 2)
			part.Color = instance.Color
			part.Anchored = true
			part.Transparency = 0
			part.CanCollide = false
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(position) * CFrame.new(math.random(-5, 5), math.random(10, 20), math.random(-5, 5)) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
			}):Play()
		end

		local v4 = 1
		PeodizService.ForLoop({
			Step = 5
		}, function(p)
			math.floor(p * 5)
			v4 += 1
			local clone6 = replicatedStorage.Chest.SwordEffect.Kioru.RadioSlash.sword_line:Clone()
			clone6.Color = Color3.fromRGB(96, 54, 104)
			clone6.CFrame = cf * CFrame.new(0, 0, -30) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
				0,
				0,
				math.random(0, clone6.Size.Y / 4)
			) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
				1.5707963267948966,
				1.5707963267948966,
				0
			)
			clone6.Size = Vector3.new(0.05, math.random(0, clone6.Size.Y), 0.05)
			clone6.Parent = workspace
			TweenService:Create(clone6, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(0.05, 56.588, 0.716)
			}):Play()
			_G.PU:Dust(clone6, 2)
			TweenService:Create(clone6, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(),
				Transparency = 1
			}):Play()
			spawn(function()
				wait(0.3)
				wait(0.5)
				TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new()
				}):Play()
			end)
		end)
		task.delay(10, function()
			table.clear(cFrames)
			table.clear(v2)
		end)
	elseif data.fx == "kioru_x" then
		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < DISTANCE_THRESHOLD then
			v:Shake(CameraShaker.Presets.Bump)
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Brightness = 0.1
			colorCorrectionEffect.TintColor = Color3.fromRGB(135, 199, 255)
			colorCorrectionEffect.Parent = game.Lighting
			TweenService:Create(
				colorCorrectionEffect,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}
			):Play()
			_G.PU:Dust(colorCorrectionEffect, 1)
		end

		local cf = data.cf
		local v2 = {}

		for i = 1, 11 do
			v2[#v2 + 1] = (cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 10 - i * 100 / 10)).p + Vector3.new(
				math.random(-7, 7),
				math.random(-7, 7),
				math.random(-7, 7)
			)
		end

		local clone = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.Sphere:Clone()
		clone.Size = Vector3.new()
		clone.Transparency = -1
		clone.Color = Color3.fromRGB(162, 195, 255)
		clone.CFrame = cf * CFrame.new(0, 0, -15)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(10, 10, 100),
			CFrame = clone.CFrame * CFrame.new(0, 0, -50)
		}):Play()
		local clone2 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.Shockowave:Clone()
		clone2.Transparency = 0.35
		clone2.CFrame = cf * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(49.474, 5.488, 49.474)
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 1)
		local clone3 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.IShot:Clone()
		clone3.Transparency = -1
		clone3.Size = createVector(24.624, 0.171, 16.212)
		clone3.Color = Color3.fromRGB(131, 226, 255)
		clone3.CFrame = cf * CFrame.new(0, 0, -3) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 1)
		local clone4 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.Shock2:Clone()
		clone4.CFrame = cf * CFrame.Angles(1.5707963267948966, 0, 0)
		clone4.Transparency = 0.85
		clone4.Color = Color3.fromRGB(163, 162, 165)
		clone4.Size = Vector3.new()
		clone4.Parent = workspace.Effects
		TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = createVector(58.582, 104.095, 61.23),
			CFrame = cf * CFrame.new(0, 0, -50) * CFrame.Angles(1.5707963267948966, 1.5707963267948966, 0)
		}):Play()
		_G.PU:Dust(clone4, 2)
		spawn(function()
			PeodizService.ForceForLoop({
				Step = #v2
			}, function(p)
				local v3 = math.floor(p * #v2)

				if v2[v3 - 1] then
					local v4 = math.random(50, 120) / 100
					local part = Instance.new("Part")
					part.Material = "Neon"
					part.CastShadow = false
					part.Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
					part.Color = Color3.fromRGB(117, 195, 255)
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new((v2[v3 - 1] + v2[v3]) / 2, v2[v3 - 1])
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(v4, v4, (v2[v3 - 1] - v2[v3]).magnitude)
					}):Play()
					spawn(function()
						wait(0.05)
						TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = Vector3.new(0, 0, (v2[v3 - 1] - v2[v3]).magnitude)
						}):Play()
						wait()
						TweenService:Create(
							part,
							TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
					end)
					_G.PU:Dust(part, 1)
				end
			end)
			task.delay(10, function()
				table.clear(v2)
			end)
		end)
		spawn(function()
			PeodizService.ForLoop({
				Step = 4,
				WaitTime = 0.05
			}, function(p)
				local v3 = math.floor(p * 4)
				local clone5 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.Shockowave:Clone()
				clone5.Transparency = 0.25
				clone5.Size = Vector3.new()
				clone5.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 33.333333333333336 - v3 * 100 / 3) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				) * CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-10, 10))),
					(math.rad((math.random(-10, 10))))
				)
				clone5.Parent = workspace.Effects
				TweenService:Create(
					clone5,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(24.737, 2.744, 24.737)
					}
				):Play()
				TweenService:Create(
					clone5,
					TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				_G.PU:Dust(clone5, 1)
			end)
		end)
		spawn(function()
			PeodizService.ForLoop({
				Step = 3,
				WaitTime = 0.05
			}, function(p)
				local v3 = math.floor(p * 3)
				local clone5 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.Wave:Clone()
				clone5.Transparency = -2
				clone5.CastShadow = false
				clone5.Size = createVector(20.185, 1.229, 20.185) * (1 - v3 / 4)
				clone5.Color = Color3.fromRGB(117, 195, 255)
				clone5.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 50 - v3 * 100 / 2) * CFrame.Angles(
					-1.5707963267948966,
					0,
					0
				) * CFrame.Angles(
					math.rad((math.random(-10, 10))),
					math.rad((math.random(-10, 10))),
					(math.rad((math.random(-10, 10))))
				)
				clone5.Parent = workspace.Effects
				TweenService:Create(
					clone5,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(65.185, 1.943, 65.185) * (1 - v3 / 4)
					}
				):Play()
				TweenService:Create(
					clone5,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
				_G.PU:Dust(clone5, 1)
			end)
		end)
		spawn(function()
			if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < 50 then
				v:Shake(CameraShaker.Presets.SmallestBump)
			end

			local v3 = 1

			for i = 1, 11 do
				v3 += 1
				local v4 = i
				spawn(function()
					local ray = Ray.new(
						(cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 10 - v4 * 100 / 10) * CFrame.new(
							6 - v4 / 11 * 5,
							0,
							0
						)).p,
						createVector(0, -15, 0)
					)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

					if instance then
						local cFrame = CFrame.new(position - createVector(0, 3, 0)) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local cFrame2 = CFrame.new(position) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local part = Instance.new("Part")
						part.Anchored = true
						part.CanCollide = false
						part.Material = instance.Material
						part.MaterialVariant = instance.MaterialVariant
						part.Color = instance.Color
						part.CFrame = cFrame
						part.Size = Vector3.new()
						part.Parent = workspace.Effects
						_G.PU:Dust(part, 2)
						local part2 = Instance.new("Part")
						part2.Anchored = true
						part2.CanCollide = false
						part2.Material = Enum.Material.Neon
						part2.Color = Color3.fromRGB(135, 203, 255)
						part2.CFrame = cFrame
						part2.Size = Vector3.new()
						part2.Parent = workspace.Effects
						_G.PU:Dust(part2, 2)
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame2,
								Size = createVector(2, 2, 2)
							}
						):Play()
						spawn(function()
							wait(0.25 + v4 * wait())
							TweenService:Create(
								part,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = cFrame,
									Size = Vector3.new()
								}
							):Play()
						end)
						TweenService:Create(
							part2,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							part2,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame2,
								Size = createVector(2.05, 2.05, 2.05)
							}
						):Play()
						spawn(function()
							wait(0.25 + v4 * wait())
							TweenService:Create(
								part2,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = cFrame,
									Size = Vector3.new()
								}
							):Play()
						end)
					end
				end)
				local v5 = i
				spawn(function()
					local ray = Ray.new(
						(cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 10 - v5 * 100 / 10) * CFrame.new(
							v5 / 11 * 5 + -6,
							0,
							0
						)).p,
						createVector(0, -15, 0)
					)
					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {
						workspace.Effects,
						workspace.PlayerCharacters,
						workspace.CharacterWorkshop
					}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
					local instance

					if raycastResult then
						instance = raycastResult.Instance or nil
					end

					local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

					if instance then
						local cFrame = CFrame.new(position - createVector(0, 3, 0)) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local cFrame2 = CFrame.new(position) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local part = Instance.new("Part")
						part.Anchored = true
						part.CanCollide = false
						part.Material = instance.Material
						part.MaterialVariant = instance.MaterialVariant
						part.Color = instance.Color
						part.CFrame = cFrame
						part.Size = Vector3.new()
						part.Parent = workspace.Effects
						_G.PU:Dust(part, 2)
						local part2 = Instance.new("Part")
						part2.Anchored = true
						part2.CanCollide = false
						part2.Material = Enum.Material.Neon
						part2.Color = Color3.fromRGB(135, 203, 255)
						part2.CFrame = cFrame
						part2.Size = Vector3.new()
						part2.Parent = workspace.Effects
						_G.PU:Dust(part2, 2)
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame2,
								Size = createVector(2, 2, 2)
							}
						):Play()
						spawn(function()
							wait(0.25 + v5 * wait())
							TweenService:Create(
								part,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = cFrame,
									Size = Vector3.new()
								}
							):Play()
						end)
						TweenService:Create(
							part2,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						TweenService:Create(
							part2,
							TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								CFrame = cFrame2,
								Size = createVector(2.05, 2.05, 2.05)
							}
						):Play()
						spawn(function()
							wait(0.25 + v5 * wait())
							TweenService:Create(
								part2,
								TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = cFrame,
									Size = Vector3.new()
								}
							):Play()
						end)
					end
				end)
				local clone5 = replicatedStorage.Chest.SwordEffect.Kioru.InjectionShot.pulse:Clone()
				clone5.Transparency = -2
				clone5.CastShadow = false
				clone5.Size = createVector(25, 25, 4)
				clone5.Color = Color3.fromRGB(117, 195, 255)
				clone5.CFrame = cf * CFrame.new(0, 0, -15) * CFrame.new(0, 0, 10 - i * 100 / 10) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
				clone5.Parent = workspace.Effects
				clone5.residue:Emit(5)
				clone5.sm2:Emit(5)
				TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0.8, 0.8, 10)
				}):Play()
				spawn(function()
					TweenService:Create(
						clone5,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				_G.PU:Dust(clone5, 1)

				if v3 ~= 3 then
					continue
				end

				wait()
				v3 = 1
			end
		end)
		wait(wait())
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 100)
		}):Play()
		wait()
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 0.5)
	elseif data.fx == "phoenix_blade_z" then
		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < DISTANCE_THRESHOLD then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local clone = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Rings:Clone()
		clone.Color = Color3.fromRGB(219, 122, 93)
		clone.Material = Enum.Material.Neon
		clone.Transparency = -1
		clone.CFrame = data.cf * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(46.104, 1, 46.104),
			CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
		}):Play()
		spawn(function()
			wait()
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7191039540",
			Volume = 0.5,
			TimePosition = 0.35
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		spawn(function()
			for _ = 1, 7 do
				local clone2 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Shock:Clone()
				clone2.CastShadow = false
				clone2.CFrame = data.cf * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone2.Size = Vector3.new()
				clone2.Transparency = -1
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Size = createVector(24.397, 2.44, 24.397) * math.random(10, 15) / 10,
					CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.35)
			end
		end)
		local clone2 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.movement_smoke2:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = data.cf * CFrame.new(0, -3, 0)
		clone2.sm2:Emit(30)
		clone2.FlameFlame:Emit(5)
		_G.PU:Dust(clone2, 1)
		local clone3 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Phoenix:Clone()
		_G.PU:Dust(clone3, 10)
		clone3.Parent = workspace.Effects
		clone3:SetPrimaryPartCFrame(data.cf)
		clone3.AnimationController:LoadAnimation(clone3.fly):Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7197475696",
			Volume = 3,
			TimePosition = 0.25
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3.RootPart
		sound2:Play()
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Velocity = data.BV.Velocity
		bodyVelocity.Parent = clone3.PrimaryPart
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Parent = clone3.PrimaryPart
		bodyGyro.MaxTorque = createVector(1, 200000, 1)
		bodyGyro.CFrame = data.BG.CFrame
		bodyGyro.P = 5000
		bodyGyro.D = 100
		local pointLight = Instance.new("PointLight")
		pointLight.Range = 0
		pointLight.Brightness = 1
		pointLight.Color = Color3.fromRGB(255, 129, 87)
		pointLight.Parent = clone3.PrimaryPart
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 2,
			Range = 20
		}):Play()
		tick()
		local v2 = {}
		local v3 = {}
		local cFrames = {}
		local lastTime = tick()
		local lastTime2 = tick()
		task.delay(5, function()
			table.clear(v2)
		end)
		PeodizService.HeartbeatWait({
			Time = 1,
			WaitTime = 0.05
		}, function()
			if not clone3:IsDescendantOf(workspace.Effects) then
				return true
			end

			v2[#v2 + 1] = clone3.PrimaryPart.CFrame * CFrame.new(-math.random(20, 30) / 10, 0, 0)
			v2[#v2 + 1] = clone3.PrimaryPart.CFrame * CFrame.new(math.random(20, 30) / 10, 0, 0)

			if tick() - lastTime2 > 0.2 then
				lastTime2 = tick()
				local clone4 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Shockowave:Clone()
				clone4.CanCollide = false
				clone4.Anchored = true
				clone4.Size = Vector3.new()
				clone4.CFrame = clone3.PrimaryPart.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone4.Parent = workspace.Effects
				TweenService:Create(
					clone4,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(24.442501, 2.712, 24.442501),
						Transparency = 1
					}
				):Play()
				local clone5 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Rings:Clone()
				clone5.CanCollide = false
				clone5.Anchored = true
				clone5.Size = Vector3.new()
				clone5.Transparency = 0.5
				clone5.CFrame = clone3.PrimaryPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone5.Parent = workspace.Effects
				TweenService:Create(
					clone5,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(27.037498, 1.0155, 27.037498),
						Transparency = 1
					}
				):Play()
				_G.PU:Dust(clone4, 1)
				_G.PU:Dust(clone5, 1)
			end

			if tick() - lastTime > wait() * 0.6 then
				cFrames[#cFrames + 1] = clone3.PrimaryPart.CFrame
				local ray = Ray.new(clone3.PrimaryPart.CFrame.p, createVector(0, -15, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if instance then
					v3[#v3 + 1] = CFrame.new(position) * (clone3.PrimaryPart.CFrame - clone3.PrimaryPart.CFrame.p)
					local clone4 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.movement_smoke:Clone()
					clone4.CFrame = CFrame.new(position) * (clone3.PrimaryPart.CFrame - clone3.PrimaryPart.CFrame.p)
					clone4.Parent = workspace.Effects
					clone4.sm2:Emit(2)
					clone4.FlameFlame:Emit(2)
					_G.PU:Dust(clone4, 1)
				end

				lastTime = tick()
			end

			bodyVelocity.Velocity = data.BV.Velocity
			bodyGyro.CFrame = data.BG.CFrame
		end)
		_G.PU:Dust(clone3, 1)
		pointLight:Destroy()

		if (localPlayer2.Character.HumanoidRootPart.Position - data.Position).Magnitude < DISTANCE_THRESHOLD then
			v:Shake(CameraShaker.Presets.Bump)
		end

		local pointLight2 = Instance.new("PointLight")
		pointLight2.Range = 30
		pointLight2.Brightness = 4
		pointLight2.Color = Color3.fromRGB(255, 129, 87)
		pointLight2.Parent = clone3.PrimaryPart
		TweenService:Create(pointLight2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = 10
		}):Play()
		_G.PU:Dust(pointLight2, 1)
		clone3.Body.parti.FlameFlame:Emit(25)
		clone3.Body.parti.residue:Emit(25)
		spawn(function()
			local v4 = 1

			for _, v5 in pairs(v2) do
				local ray = Ray.new(v5.p, createVector(0, -15, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if instance then
					local cframe = CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v6 = math.random(20, 35) / 10
					local part = Instance.new("Part")
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.CastShadow = false
					part.Size = Vector3.new()
					part.Color = instance.Color
					part.Anchored = true
					part.Transparency = 0
					part.CanCollide = false
					part.CFrame = CFrame.new(position) * cframe
					part.Parent = workspace.Effects
					local part2 = Instance.new("Part")
					part2.Material = Enum.Material.Neon
					part2.CastShadow = false
					part2.Size = Vector3.new()
					part2.Color = Color3.fromRGB(255, 189, 114)
					part2.Anchored = true
					part2.Transparency = 0
					part2.CanCollide = false
					part2.CFrame = CFrame.new(position) * cframe
					part2.Parent = workspace.Effects
					_G.PU:Dust(part, 2)
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(1, 1, 1) * v6
					}):Play()
					_G.PU:Dust(part2, 2)
					TweenService:Create(part2, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = createVector(1, 1, 1) * v6
					}):Play()
					TweenService:Create(
						part2,
						TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Color = Color3.fromRGB(),
							Transparency = 1
						}
					):Play()
					spawn(function()
						wait(1)
						TweenService:Create(
							part,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
						TweenService:Create(
							part2,
							TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = Vector3.new()
							}
						):Play()
					end)
				end

				v4 += 1

				if v4 ~= 3 then
					continue
				end

				local RunService = game:GetService("RunService")
				RunService.RenderStepped:Wait()
				v4 = 1
			end
		end)

		for _, descendant in pairs(clone3:GetDescendants()) do
			if descendant:IsA("BasePart") then
				TweenService:Create(
					descendant,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end

			if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
				descendant.Enabled = false
			end
		end

		local v4 = false
		spawn(function()
			PeodizService.ForLoop({
				Step = #v3
			}, function(p)
				local v6 = v3[math.floor(p * #v3)]
				local p2 = v6.p or nil

				if p2 then
					local clone4 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.flame:Clone()
					clone4.CFrame = CFrame.new(p2) * (v6 - v6.p)
					clone4.Parent = workspace.Effects
					clone4.FlameFlame:Emit(25)
					clone4.residue:Emit(5)
					_G.PU:Dust(clone4, 3)

					if not v4 then
						local sound3 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://7197477305",
							Volume = 3
						})
						_G.PU:Dust(sound3, 3)
						sound3.Parent = clone4
						sound3:Play()
					end

					local pointLight3 = Instance.new("PointLight")
					pointLight3.Range = 0
					pointLight3.Brightness = 1
					pointLight3.Color = Color3.fromRGB(255, 129, 87)
					pointLight3.Parent = clone4
					TweenService:Create(
						pointLight3,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
						{
							Brightness = 2,
							Range = 20
						}
					):Play()
					_G.PU:Dust(pointLight3, 1)
					v4 = true
					spawn(function()
						PeodizService.ForLoop({
							Step = #v3
						}, function(p3)
							local v7 = math.floor(p3 * #v3)

							if v3[v7 - 1] then
								local v8 = {
									[2] = 0.1,
									[3] = 0.25,
									[4] = 0.4,
									[#v3] = 0.1,
									[#v3 - 1] = 0.25,
									[#v3 - 2] = 0.4
								}
								local v9 = not v8[v7] and 0.5 or v8[v7]
								local part = Instance.new("Part")
								part.Material = "Neon"
								part.CastShadow = false
								part.Size = Vector3.new(v9, v9, (v3[v7 - 1].p - v3[v7].p).magnitude)
								part.Color = Color3.fromRGB(255, 174, 103)
								part.Anchored = true
								part.Transparency = 0
								part.CanCollide = false
								part.CFrame = CFrame.new((v3[v7 - 1].p + v3[v7].p) / 2, v3[v7 - 1].p)
								part.Parent = workspace.Effects
								TweenService:Create(
									part,
									TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										Color = Color3.fromRGB()
									}
								):Play()
								spawn(function()
									wait(1)
									TweenService:Create(
										part,
										TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
										{
											Size = Vector3.new(0, 0, (v3[v7 - 1].p - v3[v7].p).magnitude)
										}
									):Play()
									wait(0.2)
									TweenService:Create(
										part,
										TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
										{
											Transparency = 1
										}
									):Play()
								end)
								_G.PU:Dust(part, 3)
							end
						end)
					end)
				end
			end)
		end)
		spawn(function()
			PeodizService.ForLoop({
				Step = #cFrames
			}, function(p)
				local p2 = cFrames[math.floor(p * #cFrames)].p
				local clone4 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.slash4:Clone()
				clone4.mesh.Scale = Vector3.new()
				clone4.decal.Color3 = Color3.fromRGB(2555, 305, 105)
				clone4.CFrame = CFrame.new(p2) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone4.Parent = workspace.Effects
				local fx = require(clone4.decal.fx)
				fx.start()
				_G.PU:Dust(clone4, 1)
				TweenService:Create(
					clone4,
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone4.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
					}
				):Play()
				TweenService:Create(
					clone4.mesh,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Scale = createVector(16.57415, 1.7119, 16.57415)
					}
				):Play()
			end)
		end)
		local clone4 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.explosion2:Clone()
		clone4.Parent = workspace.Effects
		clone4.CFrame = clone3.PrimaryPart.CFrame
		clone4.Attachment.flash:Emit(15)
		clone4.Attachment.residue:Emit(20)
		clone4.Attachment.sparks:Emit(15)
		_G.PU:Dust(clone4, 1)
		local clone5 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.Ball:Clone()
		clone5.Transparency = -1
		clone5.CFrame = clone3.PrimaryPart.CFrame
		clone5.Size = createVector(50, 50, 50)
		clone5.Color = Color3.fromRGB(255, 174, 74)
		clone5.Parent = workspace.Effects
		_G.PU:Dust(clone5, 0.5)
		TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(),
			Transparency = 1
		}):Play()
		local pointLight3 = Instance.new("PointLight")
		pointLight3.Color = Color3.fromRGB(255, 184, 96)
		pointLight3.Brightness = 1
		pointLight3.Range = 50
		pointLight3.Parent = clone4
		TweenService:Create(pointLight3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 2,
			Range = 0
		}):Play()
		local ray = Ray.new(clone3.PrimaryPart.CFrame.p, createVector(0, -10, 0))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {
			workspace.Effects,
			workspace.PlayerCharacters,
			workspace.CharacterWorkshop
		}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance then
			local clone6 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.bigsmoke:Clone()
			clone6.Parent = workspace.Effects
			clone6.CFrame = CFrame.new(position)
			clone6.sm2:Emit(math.random(8, 10))
			clone6.FlameFlame:Emit(math.random(12, 15))
			_G.PU:Dust(clone6, 2)
		end

		for _ = 1, 5 do
			local clone6 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.slash4:Clone()
			clone6.mesh.Scale = Vector3.new()
			clone6.decal.Color3 = Color3.fromRGB(2555, 305, 105)
			clone6.CFrame = clone3.PrimaryPart.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			clone6.Parent = workspace.Effects
			local fx = require(clone6.decal.fx)
			fx.start()
			_G.PU:Dust(clone6, 1)
			TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			TweenService:Create(
				clone6.mesh,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(19.499, 2.014, 19.499)
				}
			):Play()
		end

		task.delay(10, function()
			table.clear(v3)
			table.clear(cFrames)
		end)
	elseif data.fx == "flame_arrow" then
		local arrow = data.arrow

		if not arrow then
			return
		end

		if data.player == game.Players.LocalPlayer then
			v:Shake(CameraShaker.Presets.SmallestBump2)
		end

		local clone = replicatedStorage.Chest.SwordEffect.PhoenixBlade.flamearrow:Clone()
		clone.CFrame = data.cf
		clone.Anchored = false
		clone.CanCollide = false
		clone.Parent = workspace.Effects
		clone.Attachment.fired:Emit(3)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1, 1, 1) / 0
		bodyVelocity.Velocity = data.cf.LookVector * data.speed
		bodyVelocity.Parent = clone

		if data.mode and not data.mode:FindFirstChild("phoenix_mode") then
			local clone2 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.gob:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.Parent = workspace.Effects
			clone2.CFrame = data.cf
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6908055534",
				PlaybackSpeed = 1.5,
				Volume = 0.65
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			spawn(function()
				clone2.Attachment.square.Enabled = true
				clone2.Attachment.square:Emit(15)
				wait(0.05)
				clone2.Attachment.square.Enabled = false
			end)
		end

		PeodizService.HeartbeatWait({
			Time = 60,
			WaitTime = 0.05
		}, function()
			if arrow:IsDescendantOf(workspace.Effects) then
				return
			else
				return true
			end
		end)
		_G.PU:Dust(clone, 1)
		clone.Anchored = true
		clone.Transparency = 1

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local clone2 = replicatedStorage.Chest.SwordEffect.PhoenixBlade.ball:Clone()
		clone2.Parent = workspace.Effects
		clone2.CFrame = clone.CFrame
		clone2.FlameFlame:Emit(15)
		clone2.Size = Vector3.new()
		clone2.Transparency = -1
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(4, 4, 4),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 1)
	elseif data.fx == "phoenix_mode" then
		local mode1 = data.mode1
		local mode2 = data.mode2
		local mode3 = data.mode3
		local char = data.char

		if not (char and mode1 and mode2 and mode3) then
			return
		end

		mode1.Anchored = false
		mode2.Anchored = false
		mode3.Anchored = false
		local humanoidRootPart = localPlayer2.Character:WaitForChild("HumanoidRootPart")
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1
		_G.PU:Dust(numberValue, 10)
		TweenService:Create(numberValue, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 0.5
		}):Play()
		local hit = localPlayer2:GetMouse().hit
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.Parent = mode1
		bodyPosition.P = 7500
		bodyPosition.D = 500
		bodyPosition.Position = (humanoidRootPart.CFrame * CFrame.new(10, 0, 0)).p
		local bodyPosition2 = Instance.new("BodyPosition")
		bodyPosition2.Parent = mode2
		bodyPosition2.P = 7500
		bodyPosition2.D = 500
		bodyPosition2.Position = (humanoidRootPart.CFrame * CFrame.new(-10, 0, 0)).p
		local bodyPosition3 = Instance.new("BodyPosition")
		bodyPosition3.Parent = mode3
		bodyPosition3.P = 7500
		bodyPosition3.D = 500
		bodyPosition3.Position = (humanoidRootPart.CFrame * CFrame.new(0, 10, 0)).p
		local bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Parent = mode1
		bodyGyro.MaxTorque = createVector(100000, 100000, 100000)
		bodyGyro.P = 10000
		bodyGyro.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit.p)
		local bodyGyro2 = Instance.new("BodyGyro")
		bodyGyro2.Parent = mode2
		bodyGyro2.MaxTorque = createVector(100000, 100000, 100000)
		bodyGyro2.P = 10000
		bodyGyro2.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit.p)
		local bodyGyro3 = Instance.new("BodyGyro")
		bodyGyro3.Parent = mode3
		bodyGyro3.MaxTorque = createVector(100000, 100000, 100000)
		bodyGyro3.P = 10000
		bodyGyro3.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit.p)
		tick()
		numberValue.Changed:Connect(function()
			for _, beam in pairs(mode1.beam:GetChildren()) do
				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.5, numberValue.Value),
						NumberSequenceKeypoint.new(1, 1)
					})
				end
			end

			for _, beam in pairs(mode2.beam:GetChildren()) do
				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.5, numberValue.Value),
						NumberSequenceKeypoint.new(1, 1)
					})
				end
			end

			for _, beam in pairs(mode3.beam:GetChildren()) do
				if beam:IsA("Beam") then
					beam.Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.5, numberValue.Value),
						NumberSequenceKeypoint.new(1, 1)
					})
				end
			end
		end)

		for _, emitter in pairs(mode1.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, emitter in pairs(mode2.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		for _, emitter in pairs(mode3.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.05
		}, function()
			if not (char:FindFirstChild("phoenix_mode") and char) then
				return true
			end

			local hit2 = localPlayer2:GetMouse().hit
			bodyGyro.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit2.p)
			bodyGyro2.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit2.p)
			bodyGyro3.CFrame = CFrame.new(humanoidRootPart.CFrame.p, hit2.p)
			bodyPosition.Position = (humanoidRootPart.CFrame * CFrame.new(10, 0, 0)).p
			bodyPosition2.Position = (humanoidRootPart.CFrame * CFrame.new(-10, 0, 0)).p
			bodyPosition3.Position = (humanoidRootPart.CFrame * CFrame.new(0, 10, 0)).p
		end)
		_G.PU:Dust(mode1, 1)
		_G.PU:Dust(mode2, 1)
		_G.PU:Dust(mode3, 1)

		for _, emitter in pairs(mode1.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(mode2.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(mode3.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		TweenService:Create(numberValue, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Value = 1
		}):Play()
	end
end)
local polyClient = replicatedStorage.Chest.Remotes.Events.PolyClient
local polyEvent = replicatedStorage.Chest.Remotes.Bindables.PolyEvent
polyClient.OnClientEvent:Connect(function(childName, p, position, p2)
	local localPlayer2 = game.Players.LocalPlayer

	if not script.Modules:FindFirstChild(childName) then
		return
	end

	if position then
		if typeof(position) == "CFrame" then
			position = position.Position
		end

		if localPlayer2 or localPlayer2.Character or localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
			if (localPlayer2.Character.HumanoidRootPart.Position - position).Magnitude > 500 then
				return
			end
		else
			return
		end
	end

	if type(p) == "table" and _G.ReturnEffects(localPlayer, p2) then
		return
	end

	local module = require(script.Modules[childName])
	module(p, "Event")
end)
polyEvent.Event:Connect(function(childName, p, position)
	local localPlayer2 = game.Players.LocalPlayer

	if not script.Modules:FindFirstChild(childName) then
		return
	end

	if position then
		if typeof(position) == "CFrame" then
			position = position.Position
		end

		if (localPlayer2.Character.HumanoidRootPart.Position - position).Magnitude > 500 then
			return
		end
	end

	local module = require(script.Modules[childName])
	module(p, "Bindable")
end)