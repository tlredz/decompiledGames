local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)

function Sand_V_Hold(ancestor, _, list, _)
	local v = unpack(list)

	repeat
		spawn(function()
			local cFrame = v.CFrame

			for _ = 1, math.random(1, 3) do
				local v2 = math.random(10, 40) / 10
				local clone = ReplicatedStorage.Chest.SwordEffect["Triple Katana"].Slash:Clone()
				clone.Decal1.Color3 = Color3.fromRGB(2550, 2550, 170)
				clone.Decal2.Color3 = Color3.fromRGB(2550, 2550, 170)
				clone.Size = Vector3.new(v2, 0.05, v2)
				clone.CFrame = cFrame * CFrame.Angles(
					0.5235987755982988 * math.random(),
					6.283185307179586 * math.random(),
					0.5235987755982988 * math.random()
				) * CFrame.new(0, math.random(-2, 2), 0)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					CFrame = clone.CFrame * CFrame.Angles(0, 31.41592653589793 * math.random(), 0)
				}):Play()
				TweenService:Create(clone.Decal1, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone.Decal2, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 0.5)
			end
		end)
		wait(0.05)
	until not v:IsDescendantOf(ancestor) or ancestor.Humanoid.Health <= 0
end

function New_Smoky(p, _, _, _)
	spawn(function()
		local humanoidRootPart = p.HumanoidRootPart
		local clone = ReplicatedStorage.Chest.FruitEffect.BossEf.Smoky.SmokeShockwave:Clone()
		clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		game.TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(154.678, 154.678, 10),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)

		for _ = 1, 5 do
			local v = math.random(50, 150)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.BossEf.Smoky.Smoke:Clone()
			clone2.Transparency = 0.8
			clone2.CFrame = humanoidRootPart.CFrame
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://4581230500",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			_G.PU:Dust(clone2, 2)
			game.TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(v, v, v),
				CFrame = clone2.CFrame * CFrame.Angles(
					3.141592653589793 * math.random(),
					3.141592653589793 * math.random(),
					3.141592653589793 * math.random()
				)
			}):Play()
			spawn(function()
				wait(0.3)
				game.TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					CFrame = clone2.CFrame * CFrame.Angles(
						3.141592653589793 * math.random(),
						3.141592653589793 * math.random(),
						3.141592653589793 * math.random()
					),
					Size = clone2.Size / 2,
					Transparency = 1
				}):Play()
			end)
			wait()
		end
	end)
end

function New_Captain(_, _, p, _)
	spawn(function()
		for _ = 1, 30 do
			wait(0.025)
			local magnitude = (p.cf1.p - p.cf2.p).magnitude
			local v = math.random(-8, 8)
			local v2 = math.random(0, 8)
			local clone = ReplicatedStorage.Chest.Etc.DragonClaw.Shockwave:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, 0) * CFrame.Angles(0, 3.141592653589793, 0)
			clone.Size = createVector(19.252, 19.252, 1.565)
			clone.Parent = workspace.Effects
			local clone2 = ReplicatedStorage.Chest.Etc.DragonClaw.Sphere:Clone()
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, -5)
			clone2.Size = createVector(8, 8, 5)
			clone2.Parent = workspace.Effects
			local clone3 = ReplicatedStorage.Chest.Etc.DragonClaw.WindRing:Clone()
			clone3.Color = Color3.fromRGB(255, 255, 255)
			clone3.CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, -10) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone3.Size = createVector(8.897, 0.658, 8.897)
			clone3.Parent = workspace.Effects
			local attachment = Instance.new("Attachment", clone)
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = clone
			pointLight.Color = Color3.fromRGB(255, 255, 255)
			pointLight.Brightness = 1.5
			pointLight.Range = 30
			local clone4 = ReplicatedStorage.Chest.Etc.DragonClaw.Flame2:Clone()
			clone4.Parent = attachment
			clone4.Enabled = false
			TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Brightness = 0
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(8.374, 8.374, 23.01),
				CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, -magnitude / 1.15) * CFrame.Angles(
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
				CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, 1) * CFrame.Angles(1.5707963267948966, 0, 0)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, magnitude - 5),
				CFrame = CFrame.new(p.cf1.p, p.cf2.p) * CFrame.new(v, v2, -magnitude / 2 + 5)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1.5)
			_G.PU:Dust(clone3, 1)
			_G.PU:Dust(clone2, 1)
		end
	end)
end

function New_AxeHand(p, _, _, _)
	spawn(function()
		local v = p
		local humanoidRootPart = v.HumanoidRootPart
		local position = humanoidRootPart.Position
		local v2 = humanoidRootPart.CFrame.upVector * -(v.Humanoid.HipHeight * 4)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(position, v2, raycastParams)

		if raycastResult then
			local position2 = raycastResult.Position
			local cframe = CFrame.new(position2)

			for i = 1, 20 do
				local part = Instance.new("Part")
				part.CanCollide = false
				part.Anchored = true
				part.Size = createVector(11, 11, 11)
				part.CFrame = cframe * CFrame.Angles(0, i * 18, 0)
				part.CFrame *= CFrame.new(0, -5, 0)
				part.Material = raycastResult.Material
				part.Color = raycastResult.Instance.Color
				part.Parent = workspace.Effects
				local _ = part.CFrame * CFrame.new(0, 2, -10)
				local cFrame = part.CFrame * CFrame.new(0, 2, -50) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				_G.PU:Dust(part, 3)
				TweenService:Create(
					part,
					TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0),
					{
						CFrame = cFrame
					}
				):Play()
				spawn(function()
					wait(1)
					TweenService:Create(
						part,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
						{
							Transparency = 1,
							CFrame = CFrame.new(part.Position) * CFrame.new(0, -5.5, 0)
						}
					):Play()
					_G.PU:Dust(part, 0.5)
				end)
			end

			for _ = 1, 10 do
				local part = Instance.new("Part")
				local v3 = math.random(2, 6)
				part.CanCollide = false
				part.Anchored = false
				part.Velocity = Vector3.new(math.random(-45, 45), math.random(125, 150), math.random(-45, 45))
				part.Material = raycastResult.Material
				part.Color = raycastResult.Instance.Color
				part.Massless = true
				part.Size = Vector3.new(v3, v3, v3)
				part.Parent = workspace.Effects
				part.CFrame = cframe * CFrame.new(math.rad(-50, 50), 0, (math.rad(-50, 50))) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				_G.PU:Dust(part, 3)
			end
		end
	end)
end

function New_CandleMan(p, _, _, _)
	local humanoidRootPart = p.HumanoidRootPart
	spawn(function()
		for _ = 1, 5 do
			local clone = ReplicatedStorage.Chest.FruitEffect.BossEf.Smoky.SmokeShockwave:Clone()
			clone.Material = Enum.Material.SmoothPlastic
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.new(0, 2.5, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone.Parent = workspace.Effects
			game.TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(386.69498, 386.69498, 25),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 2)
			wait(0.1)
		end
	end)
	local clone = game.ReplicatedStorage.Chest.FruitEffect.BossEf.CandleFloor:Clone()
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://4481108439",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	_G.PU:Dust(clone, 1.5)
	game.TweenService:Create(clone, TweenInfo.new(0.25), {
		Size = createVector(5, 150, 150)
	}):Play()
	delay(1, function()
		game.TweenService:Create(clone, TweenInfo.new(0.25), {
			Size = createVector(5, 0, 0)
		}):Play()
	end)
	spawn(function()
		wait(1)
		game.TweenService:Create(clone, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	end)
end

function New_KingOfSand(p, _, _, _)
	local humanoidRootPart = p.HumanoidRootPart
	spawn(function()
		for _ = 1, 5 do
			local clone = ReplicatedStorage.Chest.FruitEffect.BossEf.Smoky.SmokeShockwave:Clone()
			clone.Material = Enum.Material.Sand
			clone.Color = Color3.fromRGB(255, 205, 135)
			clone.CFrame = CFrame.new(humanoidRootPart.Position) * CFrame.new(0, 2.5, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone.Parent = workspace.Effects
			game.TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(386.69498, 386.69498, 25),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 2)
			wait(0.1)
		end
	end)
	local clone = game.ReplicatedStorage.Chest.FruitEffect.BossEf.CandleFloor:Clone()
	clone.Material = Enum.Material.Sand
	clone.Color = Color3.fromRGB(255, 205, 135)
	clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://4481108439",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	_G.PU:Dust(clone, 1.5)
	game.TweenService:Create(clone, TweenInfo.new(0.25), {
		Size = createVector(5, 150, 150)
	}):Play()
	delay(1, function()
		game.TweenService:Create(clone, TweenInfo.new(0.25), {
			Size = createVector(5, 0, 0)
		}):Play()
	end)
	spawn(function()
		wait(1)
		game.TweenService:Create(clone, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	end)
end

function Sand_X(_, p, _, _)
	spawn(function()
		for i = 1, 6 do
			local cframe = p * CFrame.new(0, 0, -i * i * 3)
			local _, v, _ = cframe:ToOrientation()
			local v2 = cframe.p + createVector(0, 5, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.Monster,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local raycastResult = workspace:Raycast(v2, createVector(0, -75, 0), raycastParams)

			if raycastResult then
				local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Spike:Clone()
				_G.PU:Dust(clone, 3)
				clone.CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(0, v, 0)
				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6843735539",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Size * i,
					CFrame = clone.CFrame * CFrame.new(0, i * 24 / 2.2, 0)
				}):Play()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Floor:Clone()
				clone2.Smoke.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, i * 10)
				})
				clone2.Smoke.Enabled = true
				spawn(function()
					wait(0.5)
					clone2.Smoke.Enabled = false
				end)
				clone2.CFrame = CFrame.new(raycastResult.Position) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 3)
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					CFrame = clone2.CFrame * CFrame.new(0, i * 1 / 3, 0),
					Size = clone2.Size * i
				}):Play()
				local v5 = i
				local v6 = clone2
				spawn(function()
					wait(1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone.Size / 1.5,
						CFrame = clone.CFrame * CFrame.new(0, -(v5 * 2.5 * 2) / 2, 0),
						Transparency = 1
					}):Play()
					TweenService:Create(v6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = v6.Size / 1.5,
						Transparency = 1
					}):Play()
				end)
			end

			wait()
		end
	end)
end

ReplicatedStorage.Chest.Remotes.Events.NPCSkill_Effect.OnClientEvent:Connect(function(p, p2, p3, p4)
	local localPlayer = game.Players.LocalPlayer

	if p2 ~= nil and (p2.p - localPlayer.Character:waitForChild("HumanoidRootPart").Position).Magnitude > 500 then
		return
	end

	if p4 == "New_Smoky" then
		New_Smoky(p, p2, p3, "New_Smoky")
		return
	elseif p4 == "New_Captain" then
		New_Captain(p, p2, p3, "New_Captain")
		return
	elseif p4 == "New_AxeHand" then
		New_AxeHand(p, p2, p3, "New_AxeHand")
		return
	elseif p4 == "New_CandleMan" then
		New_CandleMan(p, p2, p3, "New_CandleMan")
		return
	elseif p4 == "New_KingOfSand" then
		New_KingOfSand(p, p2, p3, "New_KingOfSand")
		return
	elseif p4 == "Sand_V_Hold" then
		Sand_V_Hold(p, p2, p3, "Sand_V_Hold")
		return
	end

	if p4 ~= "Sand_X" then
		return
	end

	Sand_X(p, p2, p3, p4)
end)