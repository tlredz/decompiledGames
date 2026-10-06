local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
game:GetService("RunService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local _ = workspace.CharacterWorkshop
local Utility = require(ReplicatedStorage.Chest.Modules.Utility)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PolyLib = require(ReplicatedStorage.Chest.Modules.PolyLib)
local localPlayer = game.Players.LocalPlayer
require(ReplicatedStorage.Chest.Modules.FastRenderer)
local Scheduler = require(ReplicatedStorage.Chest.Assets.Modules.Scheduler)
PeodizService.HeartbeatWait({
	Time = 60,
	WaitTime = 0.05
}, function()
	if localPlayer:FindFirstChild("PlayerStats") then
		return true
	end
end)
local CameraShaker = require(ReplicatedStorage.Chest.Modules:WaitForChild("CameraShaker"))
local currentCamera = workspace.CurrentCamera
_G.CameraShakerModule = CameraShaker
local cameraShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera.CFrame *= p
end)
_G.CameraShake = cameraShake
_G.CameraShake:Start()

function _G.BeckCameraShake(p)
	_G.CameraShake:Shake(p)
end

function AllosaurusTeleport(_, p, list, _)
	local v2, v3, _ = unpack(list)
	local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = CFrame.new(p.p) * CFrame.new(0, 5, 0)
	_G.PU:Dust(clone, 1.25)
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = createVector(50, 3, 50),
		Transparency = 1
	}):Play()
	local v4 = (v2.p - v3).magnitude / 20
	local total = 0

	for _ = 1, 20 do
		local clone2 = ReplicatedStorage.Chest.FruitEffect.BossEf.Ring:Clone()
		clone2.Parent = workspace.Effects
		clone2.Material = "Neon"
		clone2.Anchored = true
		clone2.CanCollide = false
		clone2.Size = createVector(48.366, 2.98, 45.726) + Vector3.new(total, 0.5, total)
		clone2.CFrame = v2 * CFrame.new(0, 0, -total) * CFrame.Angles(1.5707963267948966, 0, 0)
		total += v4
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone2, TweenInfo.new(0.25), {
			Size = createVector(1, 1, 1),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 0.3)
	end
end

function Gravity_Z(player, _, _, _)
	for _ = 1, 10 do
		wait(0.1)
		local clone = ReplicatedStorage.Chest.FruitEffect.Gravity.ShockwaveZ:Clone()
		_G.PU:Dust(clone, 1)
		clone.Parent = workspace.Effects
		clone.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position)
		TweenService:Create(clone, TweenInfo.new(0.7), {
			Size = createVector(157.5, 19.5, 157.5),
			Orientation = createVector(0, 1800, 0),
			Transparency = 1
		}):Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.hitbox:Clone()
		_G.PU:Dust(clone2, 1)
		clone2.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, -3.5, 0)
		clone2.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://4887370202",
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		TweenService:Create(clone2, TweenInfo.new(0.7), {
			Size = createVector(150, 1.5, 150)
		}):Play()
		TweenService:Create(clone2.Decal, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	end
end

function Gravity_X(_, cFrame, _, _)
	PeodizService.ForLoop({
		Step = 5,
		WaitTime = 0.2
	}, function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Gravity.hitbox:Clone()
		_G.PU:Dust(clone, 1)
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://4887370202",
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(clone, TweenInfo.new(0.7), {
			Size = createVector(150, 1.5, 150)
		}):Play()
		TweenService:Create(clone.Decal, TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()
	end)
end

function Gravity_X2(_, cFrame, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gravity.Smoke2:Clone()
	clone.Name = "FF"
	clone.Parent = workspace.Effects
	clone.CFrame = cFrame * CFrame.new(0, -5, 0)
	_G.PU:Dust(clone, 2)

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(5)
		end
	end

	local part = Instance.new("Part", workspace.Effects)
	part.Size = createVector(4, 4, 4)
	part.Material = "Neon"
	part.Color = Color3.fromRGB(240, 240, 240)
	part.Anchored = true
	part.CanCollide = false
	part.Shape = Enum.PartType.Ball
	part.CFrame = cFrame * CFrame.new(0, -5, 0)
	_G.PU:Dust(part, 2)
	TweenService:Create(part, TweenInfo.new(0.9), {
		Transparency = 1,
		Size = createVector(75, 75, 75),
		Color = Color3.fromRGB(230, 100, 7)
	}):Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.ShockwaveZ:Clone()
	_G.PU:Dust(clone2, 1)
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.CFrame = part.CFrame
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.5), {
		Size = createVector(90, 10.5, 90),
		Orientation = createVector(0, 1800, 0),
		Transparency = 1
	}):Play()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://165970126",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	spawn(function()
		local cFrame2 = cFrame
		local v3 = 0

		for _ = 1, 16 do
			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = createVector(0, 0, 0)
			part2.CFrame = cFrame2
			part2.Material = "Neon"
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local v4 = (cFrame2 * CFrame.Angles(0, math.rad(v3), 0) * CFrame.new(0, 0, -35.5) * CFrame.Angles(
				math.rad((math.random(-75, 75))),
				math.rad((math.random(-75, 75))),
				(math.rad((math.random(-75, 75))))
			)).p + createVector(0, 5, 0)
			local raycastResult = workspace:Raycast(v4, createVector(0, -150, 0), raycastParams)
			local position = v4 + createVector(0, -150, 0)
			local instance, material

			if raycastResult then
				position = raycastResult.Position
				instance = raycastResult.Instance
				local _ = raycastResult.Normal
				material = instance.Material
			end

			TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(cFrame2.X, position.Y, cFrame2.Z, select(4, cFrame2:components())) * CFrame.Angles(
					0,
					math.rad(v3),
					0
				) * CFrame.new(0, -1.5, -35.5) * CFrame.Angles(
					math.rad((math.random(-75, 75))),
					math.rad((math.random(-75, 75))),
					(math.rad((math.random(-75, 75))))
				),
				Size = createVector(7, 7, 7)
			}):Play()
			TweenService:Create(
				part2,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 2),
				{
					Transparency = 1
				}
			):Play()
			part2.Material = material or "SmoothPlastic"

			if instance then
				part2.BrickColor = instance.BrickColor
			end

			_G.PU:Dust(part2, 3)
			part2.Parent = workspace.Effects
			v3 = v3 + 22.5 + math.random(-23, 23)
		end
	end)
end

function Paw_Z(_, cFrame, _, _)
	spawn(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Paw.Ball:Clone()
		_G.PU:Dust(clone, 0.3)
		clone.Shape = "Ball"
		clone.Material = Enum.Material.ForceField
		clone.Transparency = -1
		clone.CFrame = cFrame
		clone.Size = Vector3.new()
		clone.Color = Color3.fromRGB(255, 255, 255)
		clone.CastShadow = false
		clone.Anchored = true
		clone.CanCollide = false
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
			Size = createVector(50, 50, 50),
			Transparency = 1
		}):Play()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7153349876",
			Volume = 0.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = clone:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
			Size = createVector(52.499996, 52.499996, 52.499996),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 0.3)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = workspace.Effects
		clone3.Attachment.Ball:Emit(15)
		_G.PU:Dust(clone3, 1)
		spawn(function()
			for _ = 1, 10 do
				local v2 = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone4 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone4.CastShadow = false
				clone4.Transparency = -1
				clone4.Size = Vector3.new(2, 2, math.random(25, 35))
				clone4.Color = Color3.fromRGB(255, 255, 255)
				clone4.CFrame = v2 * CFrame.Angles(0, 0, 15)
				clone4.Parent = workspace.Effects
				math.random(20, 30)
				local v3 = math.random(30, 50)
				TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0),
					CFrame = v2 * CFrame.new(0, 0, v3)
				}):Play()
				_G.PU:Dust(clone4, 0.3)
			end
		end)
	end)
end

function Paw_X(_, cFrame, _, _)
	spawn(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Paw.Ball:Clone()
		clone.Shape = "Ball"
		clone.Material = Enum.Material.ForceField
		clone.Transparency = -1
		clone.CFrame = cFrame
		clone.Size = createVector(0, 0, 0)
		clone.Color = Color3.fromRGB(255, 255, 255)
		clone.CastShadow = false
		clone.Anchored = true
		clone.CanCollide = false
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 0.3)
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
			Size = createVector(50, 50, 50),
			Transparency = 1
		}):Play()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7153349876",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = clone:Clone()
		clone2.CFrame = clone.CFrame
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
			Size = createVector(52.499996, 52.499996, 52.499996),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 0.3)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = workspace.Effects
		clone3.Attachment.Ball:Emit(10)
		_G.PU:Dust(clone3, 1)
	end)
end

function Paw_C(player, _, list, _)
	spawn(function()
		local v2 = unpack(list)
		tick()
		local clone = ReplicatedStorage.Chest.FruitEffect.Paw.Paw.AttachmentHand:Clone()
		clone.Shock.Lifetime = NumberRange.new(0.25)
		clone.Shock.Enabled = true
		clone.Parent = player.Character.RightHand
		_G.PU:Dust(clone, 3)
		PeodizService.HeartbeatWait({
			Time = 2,
			WaitTime = 0.125
		}, function()
			if not v2:IsDescendantOf(player.Character) or player.Character.Humanoid.Health <= 0 then
				return true
			end

			if clone:FindFirstChild("Shock") then
				clone.Shock:Emit(1)
			end

			local cFrame = player.Character.HumanoidRootPart.CFrame
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Paw.Paw2:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.CFrame = cFrame * CFrame.new(0, 5, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, -150)
			}):Play()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7154125081",
				Volume = 0.5,
				PlaybackSpeed = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			spawn(function()
				wait(0.25)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()

				for _, trail in pairs(clone2:GetChildren()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)
		end)
		_G.PU:Dust(clone, 1)
	end)
end

function Paw_V(_, p, _, _)
	local cframe = CFrame.new(p.p)
	local clone = game.ReplicatedStorage.Chest.FruitEffect.Paw.PawPawV:Clone()
	_G.PU:Dust(clone, 2)
	clone.CastShadow = false
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.Anchored = true
	clone.Size = Vector3.new()
	clone.Transparency = -1
	clone.CFrame = cframe * CFrame.new(0, 25, 0)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://4584097584",
		Volume = 2.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Size = createVector(150, 150, 100)
	}):Play()
	local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone2.Size = Vector3.new()
	clone2.Transparency = -1
	clone2.CFrame = cframe * CFrame.new(0, 85, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(200, 10, 200),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone2, 0.5)
	spawn(function()
		PeodizService.ForLoop({
			Step = 10,
			WaitTime = 0.1
		}, function(_)
			local clone3 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone3.Transparency = 0.02
			clone3.CFrame = cframe * CFrame.new(0, 5, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(312.5, 31.25, 312.5),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone3, 0.5)
		end)
	end)
	spawn(function()
		wait(0.5)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = clone.Size / 1.3,
			Transparency = 1
		}):Play()
	end)
end

function Sand_X(_, p, _, _)
	spawn(function()
		PeodizService.ForLoop({
			Step = 6
		}, function(p2)
			local v2 = math.floor(p2 * 6)
			local cframe = p * CFrame.new(0, 0, -v2 * v2 * 3)
			local _, v3, _ = cframe:ToOrientation()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(
				cframe.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams
			)
			local position = cframe.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if instance then
				local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Spike:Clone()
				clone.CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
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
					Size = clone.Size * v2,
					CFrame = clone.CFrame * CFrame.new(0, v2 * 24 / 2.2, 0)
				}):Play()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Floor:Clone()
				clone2.Smoke.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, v2 * 10)
				})
				clone2.Smoke.Enabled = true
				spawn(function()
					wait(0.5)
					clone2.Smoke.Enabled = false
				end)
				clone2.CFrame = CFrame.new(position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 3)
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					CFrame = clone2.CFrame * CFrame.new(0, v2 * 1 / 3, 0),
					Size = clone2.Size * v2
				}):Play()
				spawn(function()
					wait(1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone.Size / 1.5,
						CFrame = clone.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
						Transparency = 1
					}):Play()
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone2.Size / 1.5,
						Transparency = 1
					}):Play()
				end)
			elseif not instance and position.Y <= -3.35 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Spike:Clone()
				clone.CFrame = CFrame.new(position.X, -3.35, position.Z) * CFrame.fromOrientation(0, v3, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Size * v2,
					CFrame = clone.CFrame * CFrame.new(0, v2 * 24 / 2.2, 0)
				}):Play()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Floor:Clone()
				clone2.Smoke.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, v2 * 10)
				})
				clone2.Smoke.Enabled = true
				spawn(function()
					wait(0.5)
					clone2.Smoke.Enabled = false
				end)
				clone2.CFrame = CFrame.new(position.X, -3.35, position.Z) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 3)
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					CFrame = clone2.CFrame * CFrame.new(0, v2 * 1 / 2, 0),
					Size = clone2.Size * v2
				}):Play()
				spawn(function()
					wait(1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone.Size / 1.5,
						CFrame = clone.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
						Transparency = 1
					}):Play()
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone2.Size / 1.5,
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)
end

function Sand_C(character, p, list, _)
	local v2 = unpack(list)

	if character:IsA("Player") then
		character = character.Character
	end

	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.SandFloor:Clone()
	_G.PU:Dust(clone, 4)
	clone.CFrame = p * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6843742605",
		Volume = 3
	})
	_G.PU:Dust(sound, 4)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(0.25), {
		Size = createVector(1, 100, 100)
	}):Play()
	PeodizService.HeartbeatWait({
		Time = 5,
		WaitTime = 0.1
	}, function()
		if not v2:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
			return true
		end

		TweenService:Create(clone, TweenInfo.new(0.15), {
			CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		spawn(function()
			local v3 = CFrame.new(p.p) + createVector(0, 2, 0)

			for i = 1, 15 do
				local cframe = v3 * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(0, 0, -50)
				local _, v4, _ = cframe:ToOrientation()
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Thing:Clone()
				clone2.CanCollide = false
				clone2.CastShadow = false
				clone2.Anchored = true
				clone2.Size = createVector(1, 1, 1)
				clone2.Material = Enum.Material.Sand
				clone2.Color = Color3.fromRGB(199, 172, 120)
				clone2.CFrame = CFrame.new(v3.p) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
					0.7853981633974483,
					0,
					0
				)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.8)
				local v5 = math.random(35, 50) / 5
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(cframe.p) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
						0.7853981633974483,
						0,
						0
					),
					Size = Vector3.new(v5 * 3, v5, v5)
				}):Play()
				spawn(function()
					wait(0.3)
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)

	if clone:IsDescendantOf(workspace.Effects) then
		TweenService:Create(clone, TweenInfo.new(0.25), {
			Size = createVector(1, 50, 50),
			Transparency = 1
		}):Play()
	end
end

function Sand_V(_, p, _, _)
	spawn(function()
		local v2 = p

		if (v2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 200 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Sand.SandTornado:Clone()
		clone.Color = Color3.fromRGB(199, 172, 120)
		clone.Material = Enum.Material.Sand
		clone.CFrame = v2 * CFrame.new(0, 20, 0)
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://184474122",
			Volume = 1
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
			Size = createVector(50, 50, 50)
		}):Play()
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 2,
				WaitTime = 0.05
			}, function()
				if not clone:IsDescendantOf(workspace.Effects) then
					return true
				end

				TweenService:Create(clone, TweenInfo.new(0.1), {
					CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
				}):Play()
			end)
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.1
			}, function()
				if not clone:IsDescendantOf(workspace.Effects) then
					return true
				end

				spawn(function()
					for _ = 1, math.random(1, 3) do
						local v3 = math.random(50, 100)
						local clone2 = ReplicatedStorage.Chest.SwordEffect["Triple Katana"].Slash:Clone()
						clone2.Decal1.Color3 = Color3.fromRGB(199, 172, 120)
						clone2.Decal2.Color3 = Color3.fromRGB(199, 172, 120)
						clone2.Size = Vector3.new(v3, 0.05, v3)
						clone2.CFrame = clone.CFrame * CFrame.Angles(
							0.5235987755982988 * math.random(),
							6.283185307179586 * math.random(),
							0.5235987755982988 * math.random()
						) * CFrame.new(0, math.random(1, 25), 0)
						clone2.Parent = workspace.Effects
						TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
							CFrame = clone2.CFrame * CFrame.Angles(0, 31.41592653589793 * math.random(), 0)
						}):Play()
						TweenService:Create(clone2.Decal1, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
						TweenService:Create(clone2.Decal2, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
						_G.PU:Dust(clone2, 0.5)
					end
				end)
				spawn(function()
					local cframe = CFrame.new(p.p)

					for i = 1, 15 do
						local v3 = math.random(35, 50) / 5
						local cframe2 = cframe * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(0, 0, -50)
						local _, v4, _ = cframe2:ToOrientation()
						local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Thing:Clone()
						clone2.CanCollide = false
						clone2.CastShadow = false
						clone2.Anchored = true
						clone2.Size = Vector3.new(v3 * 3, v3, v3)
						clone2.Material = Enum.Material.Sand
						clone2.Color = Color3.fromRGB(199, 172, 120)
						clone2.CFrame = CFrame.new(cframe2.p) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
							0.7853981633974483,
							0,
							0
						)
						clone2.Parent = workspace.Effects
						_G.PU:Dust(clone2, 0.8)
						TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							CFrame = CFrame.new(cframe.p) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
								0.7853981633974483,
								0,
								0
							),
							Size = Vector3.new()
						}):Play()
						spawn(function()
							wait(0.3)
							TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Transparency = 1
							}):Play()
						end)
					end
				end)
			end)
		end)
		spawn(function()
			wait(1.25)
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
		end)
		_G.PU:Dust(clone, 1.5)
	end)
end

function Ice_Z_Awake(_, p, list, _)
	local v2, v3 = unpack(list)

	if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
		clone.Enabled = true
		clone.Parent = workspace.CurrentCamera
		clone.Size = 0
		_G.PU:Dust(clone, 0.5)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0), {
			Size = 10
		}):Play()
	end

	spawn(function()
		PeodizService.ForLoop({
			Step = 4,
			WaitTime = 0.05
		}, function(p2)
			math.floor(p2 * 4)

			for i = 1, 2 do
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
				clone.Color = Color3.fromRGB(255, 255, 255)
				clone.CFrame = i == 1 and p * CFrame.new(-15, 0, -5) * CFrame.Angles(0, -0.15707963267948966, 0) or p * CFrame.new(
					15,
					0,
					-5
				) * CFrame.Angles(0, 0.15707963267948966, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)

				if i == 1 then
				end

				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Transparency = 1,
					Size = clone.Size * math.random(10, 40) / 10,
					CFrame = clone.CFrame * CFrame.new(0, 0, clone.Size.Z)
				}):Play()
			end
		end)
	end)
	spawn(function()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.1
		}, function()
			if not v2:IsDescendantOf(workspace.Effects) then
				return true
			end

			local v4 = math.random(30, 50) / 10
			local clone = ReplicatedStorage.Chest.FruitEffect.Ice.Ring:Clone()
			clone.Size = Vector3.new()
			clone.Transparency = -1
			clone.Material = "Neon"
			clone.Color = Color3.fromRGB(103, 169, 255)
			clone.CFrame = v2.CFrame * CFrame.new(0, 2, 0)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.5)
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(20, 20, math.random(4, 8)) * v4,
				Transparency = 1,
				CFrame = clone.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
			}):Play()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(
				v2.Position + createVector(0, 5, 0),
				createVector(0, -50, 0),
				raycastParams
			)
			local position = v2.Position + createVector(0, 5, 0) + createVector(0, -50, 0)
			local instance, normal

			if raycastResult then
				instance = raycastResult.Instance
				normal = raycastResult.Normal
				position = raycastResult.Position
			end

			local v5 = math.random(12, 20) / 10

			if instance then
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Ice.IcePath:Clone()
				clone2.Color = Color3.fromRGB(103, 169, 255)
				clone2.Transparency = -1
				clone2.Material = "Neon"
				clone2.CFrame = CFrame.new(position + normal, position) * CFrame.new(0, 0, -0.75) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone2.Parent = workspace.Effects
				clone2.CollisionGroup = "Effect"
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(25, 1, 25) * v5
				}):Play()
				spawn(function()
					wait(0.5)
					TweenService:Create(clone2, TweenInfo.new(0.5), {
						Size = createVector(1, 1, 1),
						Transparency = 1
					}):Play()
				end)
			elseif not instance and position.Y <= -3.35 then
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Ice.IcePath:Clone()
				clone2.Color = Color3.fromRGB(103, 169, 255)
				clone2.Transparency = -1
				clone2.Material = "Neon"
				clone2.CanCollide = true
				clone2.CFrame = CFrame.new(position.X, -3.35, position.Z) * CFrame.new(0, 1.5, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone2.Parent = workspace.Effects
				clone2.CollisionGroup = "Effect"
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(25, 1, 25) * v5
				}):Play()
				spawn(function()
					wait(0.5)
					TweenService:Create(clone2, TweenInfo.new(0.5), {
						Size = createVector(1, 1, 1),
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)
	coroutine.wrap(function()
		PeodizService.HeartbeatWait({
			Time = 2,
			WaitTime = 0.05
		}, function()
			if not v3:IsDescendantOf(workspace.Effects) then
				return true
			end

			local v4 = math.random(5, 30) * 2
			local v5 = math.random(3, 10) / 10 * 2
			local part = Instance.new("Part")
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			part.Color = Color3.fromRGB(103, 169, 255)
			part.Material = "Neon"
			part.Size = Vector3.new(v5, v5, v4)
			part.Transparency = -1
			part.CFrame = v3["icE tIGER"].CFrame * CFrame.new(
				math.random(-10, 10),
				math.random(-10, 10),
				math.random(-10, 10)
			)
			part.Parent = workspace.Effects
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(0, 0, part.Size.Z)
			}):Play()
			_G.PU:Dust(part, 0.2)
		end)
	end)()
end

function Ice_Z_Awake_Ex(_, _, list, _)
	coroutine.wrap(function()
		local v2 = unpack(list)
		local cFrame = v2["icE tIGER"].CFrame
		spawn(function()
			PeodizService.ForLoop({
				Step = 5,
				WaitTime = 0.05
			}, function(_)
				local v3 = math.random(30, 50) / 10
				local v4 = cFrame * CFrame.new(0, -15, 0) * CFrame.Angles(
					math.rad((math.random(10, 75))),
					math.rad((math.random(-45, 45))),
					0
				)
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeModel:Clone()
				_G.PU:Dust(clone, 3)
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone:SetPrimaryPartCFrame(v4)
				clone.Parent = workspace.Effects
				TweenService:Create(clone.Ice, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(5.679, 5.186, 18.987) * v3,
					CFrame = clone.Ice.CFrame * CFrame.new(0, 0, -28.4805)
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(5.547, 5.06, 18.832) * v3,
					CFrame = clone.Neon.CFrame * CFrame.new(0, 0, -28.4805)
				}):Play()
				spawn(function()
					wait(1.5)
					TweenService:Create(clone.Ice, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Size = clone.Ice.Size / 2,
						CFrame = v4 * CFrame.new(0, 0, -15),
						Transparency = 1
					}):Play()
					TweenService:Create(clone.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
						Size = clone.Neon.Size / 2,
						CFrame = v4 * CFrame.new(0, 0, -15),
						Transparency = 1
					}):Play()
				end)
			end)
		end)
		local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
		_G.PU:Dust(clone, 2)
		clone.Attachment.Burst.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 90.125, 37.5)
		})
		clone.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 125)
		})
		clone.Attachment.Rocks.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 7.5, 3.75),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment.Rocks2.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 7.5, 3.75),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment.Sm.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.043, 100),
			NumberSequenceKeypoint.new(0.883, 100),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment.Rocks.Speed = NumberRange.new(50, 150)
		clone.Attachment.Rocks2.Speed = NumberRange.new(50, 150)
		clone.Attachment.Ring.Color = ColorSequence.new(Color3.fromRGB(120, 183, 255))
		clone.Attachment.Burst.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255))
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8798644218",
			Volume = 4
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		clone.Attachment.Burst:Emit(5)
		clone.Attachment.Ring:Emit(1)
		clone.Attachment.Rocks:Emit(10)
		clone.Attachment.Rocks2:Emit(10)
		clone.Attachment.Sm:Emit(5)
		v2:Destroy()
	end)()
end

function Ice_Z_Sea(_, _, list, _)
	local v2 = unpack(list)
	local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePath:Clone()
	clone.Transparency = -1
	clone.Material = "Neon"
	clone.CanCollide = true
	clone.CFrame = CFrame.new(v2.Position.X, -3.35, v2.Position.Z) * CFrame.new(0, 1, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)
	clone.Parent = workspace.Effects
	clone.CollisionGroup = "Effect"
	_G.PU:Dust(clone, 8)
	TweenService:Create(clone, TweenInfo.new(0.1), {
		Size = createVector(100, 5, 100)
	}):Play()
	task.delay(0.2, function()
		clone.Material = "Ice"
	end)
	spawn(function()
		wait(7.5)
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = clone.Size / 2,
			Transparency = 1
		}):Play()
	end)
	spawn(function()
		for _ = 1, 7 do
			local cFrame = CFrame.new(v2.Position) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				0
			)
			local v4 = math.random(10, 15)
			local v5 = math.random(35, 75)
			local clone2 = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(10, 10, math.random(20, 30))
			clone2.Color = Color3.fromRGB(110, 153, 202)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6831579596",
				Volume = 3
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v4),
				CFrame = cFrame * CFrame.new(0, 0, v5)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			_G.PU:Dust(clone2, 1)
		end
	end)
end

function Ice_Z_Awake_Sea(_, _, list, _)
	local v2 = unpack(list)
	local cFrame = CFrame.new(v2.Position.X, -3.35, v2.Position.Z) * CFrame.new(0, 1, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)
	local clone = ReplicatedStorage.Chest.FruitEffect.Ice.RingDecal:Clone()
	_G.PU:Dust(clone, 1)
	clone.Decal.Transparency = -1
	clone.Decal2.Transparency = -1
	clone.Decal.Color3 = Color3.fromRGB(170, 2555, 2555)
	clone.Decal2.Color3 = Color3.fromRGB(170, 2555, 2555)
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.AttachmentS.Sm.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.043, 100),
		NumberSequenceKeypoint.new(0.883, 100),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone2.AttachmentS.Sm.Speed = NumberRange.new(500, 1500)
	clone2.AttachmentS.Sm.Rate = 100
	clone2.AttachmentS.Sm.Enabled = true
	clone2.Attachment.Ring.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 500)
	})
	clone2.CFrame = cFrame
	clone2.Parent = workspace.Effects
	clone2.Attachment.Ring:Emit(1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8801269379",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	spawn(function()
		wait(1)
		clone2.AttachmentS.Sm.Enabled = false
	end)
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = createVector(500, 1, 500)
	}):Play()
	TweenService:Create(clone.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone.Decal2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Transparency = 1
	}):Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathAwake:Clone()
	clone3.IceFloor.CanCollide = true
	clone3.IceFloorNeon.CanCollide = true
	clone3:SetPrimaryPartCFrame(cFrame)
	clone3.Parent = workspace.Effects
	clone3.IceFloor.CollisionGroup = "TouchEffect"
	clone3.IceFloorNeon.CollisionGroup = "TouchEffect"
	_G.PU:Dust(clone3, 21)
	TweenService:Create(clone3.IceFloor, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(299.362, 4.265, 284.462)
	}):Play()
	TweenService:Create(clone3.IceFloorNeon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(298.527, 4.186, 283.592)
	}):Play()
	pcall(function()
		wait(19)

		if clone3:FindFirstChild("IceFloor") then
			TweenService:Create(clone3.IceFloor, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
		end

		if clone3:FindFirstChild("IceFloorNeon") then
			TweenService:Create(clone3.IceFloorNeon, TweenInfo.new(1, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
		end
	end)
end

function Ice_Z_Ex(_, p, _, _)
	spawn(function()
		for _ = 1, 7 do
			local cFrame = CFrame.new(p.p) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v3 = math.random(10, 15)
			local v4 = math.random(35, 75)
			local clone = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = Vector3.new(10, 10, math.random(20, 30))
			clone.Color = Color3.fromRGB(110, 153, 202)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6831579596",
				Volume = 3
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v3),
				CFrame = cFrame * CFrame.new(0, 0, v4)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
			_G.PU:Dust(clone, 1)
		end
	end)
end

function Ice_X_Awake(_, _, list, _)
	local v2, v3, v4, v5, _, v6 = unpack(list)
	local cFrame = v2.CFrame
	local step = v6 or 50
	math.random(-50, 50)
	math.random(1, 50)
	coroutine.wrap(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpike:Clone()
		clone.Sm.Enabled = true
		clone.Ice1.Enabled = true
		clone.Ice2.Enabled = true
		clone.Size *= 4
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6826837287",
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		_G.PU:Dust(clone, 2)
		PeodizService.ForLoop({
			Step = step
		}, function(p)
			local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * step, -(p * step) * v4)
			clone.CFrame = CFrame.new((v5 * cframe).p, clone.Position) * CFrame.Angles(0, 3.141592653589793, 0)
		end)

		if clone:FindFirstChild("Sm") then
			clone.Sm.Enabled = false
		end

		if clone:FindFirstChild("Ice1") then
			clone.Ice1.Enabled = false
		end

		if clone:FindFirstChild("Ice2") then
			clone.Ice2.Enabled = false
		end

		clone.Transparency = 1
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
		_G.PU:Dust(clone2, 2)
		clone2.Attachment.Burst.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 72.1, 30)
		})
		clone2.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 150)
		})
		clone2.Attachment.Sm.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.043, 50),
			NumberSequenceKeypoint.new(0.883, 50),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone2.AttachmentS.Spikes.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 13.12),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone2.Attachment.Sm.Speed = NumberRange.new(50, 400)
		clone2.CFrame = CFrame.new(v3.p)
		clone2.Parent = workspace.Effects
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8732492666",
			Volume = 2
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		clone2.Attachment.Burst:Emit(3)
		clone2.Attachment.Ring:Emit(1)
		clone2.Attachment.Sm:Emit(5)
		clone2.AttachmentS.Spikes:Emit(15)
	end)()
end

function Ice_C_Awake(_, p, _, _)
	if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
		clone.Enabled = true
		clone.Parent = workspace.CurrentCamera
		clone.Size = 0
		_G.PU:Dust(clone, 0.5)
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0), {
			Size = 10
		}):Play()
	end

	spawn(function()
		PeodizService.ForLoop({
			Step = 4,
			WaitTime = 0.05
		}, function(p2)
			math.floor(p2 * 4)

			for i = 1, 2 do
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
				clone.Color = Color3.fromRGB(255, 255, 255)
				clone.CFrame = i == 1 and p * CFrame.new(-15, 0, -5) * CFrame.Angles(0, -0.15707963267948966, 0) or p * CFrame.new(
					15,
					0,
					-5
				) * CFrame.Angles(0, 0.15707963267948966, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)

				if i == 1 then
				end

				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Transparency = 1,
					Size = clone.Size * math.random(30, 60) / 10,
					CFrame = clone.CFrame * CFrame.new(0, 0, clone.Size.Z)
				}):Play()
			end
		end)
	end)
	spawn(function()
		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
		PeodizService.ForceForLoop({
			Step = 6,
			WaitTime = 0.05
		}, function(p2)
			local v2 = math.floor(p2 * 6)
			local v3 = p * CFrame.new(0, 0, -v2 * v2 * 8)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(
				v3.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams
			)
			local position = v3.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance, normal

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
				normal = raycastResult.Normal
			end

			if instance then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathAwake:Clone()
				clone.IceFloor.Transparency = 0.25
				clone.IceFloorNeon.Transparency = -1
				clone:SetPrimaryPartCFrame(CFrame.new(position + normal, position) * CFrame.new(0, 0, -1) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0))
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 4)
				TweenService:Create(clone.IceFloor, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.IceFloor.Size * v2 * 1.8
				}):Play()
				TweenService:Create(clone.IceFloorNeon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.IceFloor.Size * v2 * 1.8
				}):Play()
				spawn(function()
					wait(1.15)

					if clone:FindFirstChild("IceFloor") then
						TweenService:Create(clone.IceFloor, tweenInfo, {
							Size = clone.IceFloor.Size / 2,
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("IceFloorNeon") then
						TweenService:Create(clone.IceFloorNeon, tweenInfo, {
							Size = clone.IceFloor.Size / 2,
							Transparency = 1
						}):Play()
					end
				end)
			elseif not instance and position.Y <= -3.35 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathAwake:Clone()
				clone.IceFloor.Transparency = 0.25
				clone.IceFloorNeon.Transparency = -1
				clone:SetPrimaryPartCFrame(CFrame.new(position.X, -3.35, position.Z) * CFrame.new(0, 1.5, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				))
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 4)
				TweenService:Create(clone.IceFloor, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.IceFloor.Size * v2 * 1.8
				}):Play()
				TweenService:Create(clone.IceFloorNeon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.IceFloor.Size * v2 * 1.8
				}):Play()
				spawn(function()
					wait(1.15)

					if clone:FindFirstChild("IceFloor") then
						TweenService:Create(clone.IceFloor, tweenInfo, {
							Size = clone.IceFloor.Size / 2,
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("IceFloorNeon") then
						TweenService:Create(clone.IceFloorNeon, tweenInfo, {
							Size = clone.IceFloor.Size / 2,
							Transparency = 1
						}):Play()
					end
				end)
			end

			local cframe = p * CFrame.new(0, 0, -v2 * v2 * 9)
			local _, v4, _ = cframe:ToOrientation()
			local raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Include
			raycastParams2.FilterDescendantsInstances = { workspace.Island }
			local raycastResult2 = workspace:Raycast(
				cframe.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams2
			)
			local position2 = cframe.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance2

			if raycastResult2 then
				instance2 = raycastResult2.Instance
				position2 = raycastResult2.Position
			end

			if instance2 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 * 50, v2 * 100)
				clone.Neon.Ice1.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice2.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Spikes.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 65.6, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Spikes.Speed = NumberRange.new(v2 * 100, v2 * 100 * 1.5)
				clone.Neon.Ice1.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone.Neon.Ice2.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone:SetPrimaryPartCFrame(CFrame.new(position2) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
					0,
					v4,
					0
				) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(-15, 15))), 0))
				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8798650782",
					Volume = 1.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone.Neon
				sound:Play()
				clone.Neon.Sm:Emit(5)
				clone.Neon.Ice1:Emit(5)
				clone.Neon.Ice2:Emit(5)
				clone.Neon.Spikes:Emit(10)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			elseif not instance2 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 * 50, v2 * 100)
				clone.Neon.Ice1.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice2.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Spikes.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 65.6, 0),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Spikes.Speed = NumberRange.new(v2 * 100, v2 * 100 * 1.5)
				clone.Neon.Ice1.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone.Neon.Ice2.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)

				if position2.Y <= -3.35 then
					clone:SetPrimaryPartCFrame(CFrame.new(position2.X, -3.35, position2.Z) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
						0,
						v4,
						0
					) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(-15, 15))), 0))
				else
					clone:SetPrimaryPartCFrame(cframe * CFrame.new(0, v2 * 10, 0) * CFrame.Angles(
						math.rad((math.random(35, 55))),
						math.rad((math.random(-15, 15))),
						0
					))
				end

				clone.Parent = workspace.Effects
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8798650782",
					Volume = 1.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone.Neon
				sound:Play()
				clone.Neon.Sm:Emit(5)
				clone.Neon.Ice1:Emit(5)
				clone.Neon.Ice2:Emit(5)
				clone.Neon.Spikes:Emit(10)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			end

			local v5 = p * CFrame.new(v2 * -4, 0, -v2 * v2 * 9)
			local raycastParams3 = RaycastParams.new()
			raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams3.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult3 = workspace:Raycast(
				v5.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams3
			)
			local position3 = v5.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance3

			if raycastResult3 then
				instance3 = raycastResult3.Instance
				position3 = raycastResult3.Position
			end

			if instance3 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 / 2 * 50, v2 / 2 * 100)
				clone.Neon.Ice1.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice2.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice1.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone.Neon.Ice2.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone:SetPrimaryPartCFrame(CFrame.new(position3) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
					0,
					v4,
					0
				) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(5, 15))), 0))
				clone.Parent = workspace.Effects
				clone.Neon.Sm:Emit(2)
				clone.Neon.Ice1:Emit(1)
				clone.Neon.Ice2:Emit(1)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			elseif not instance3 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 / 2 * 50, v2 / 2 * 100)

				if position3.Y <= -3.35 then
					clone:SetPrimaryPartCFrame(CFrame.new(position3.X, -3.35, position3.Z) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
						0,
						v4,
						0
					) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(5, 15))), 0))
				else
					clone:SetPrimaryPartCFrame(v5 * CFrame.new(0, v2 * 10, 0) * CFrame.Angles(
						math.rad((math.random(35, 55))),
						math.rad((math.random(5, 15))),
						0
					))
				end

				clone.Parent = workspace.Effects
				clone.Neon.Sm:Emit(2)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			end

			local v6 = p * CFrame.new(v2 * 4, 0, -v2 * v2 * 9)
			local raycastParams4 = RaycastParams.new()
			raycastParams4.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams4.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult4 = workspace:Raycast(
				v6.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams4
			)
			local position4 = v6.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance4

			if raycastResult4 then
				instance4 = raycastResult4.Instance
				position4 = raycastResult4.Position
			end

			if instance4 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 / 2 * 50, v2 / 2 * 100)
				clone.Neon.Ice1.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice2.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, v2 * 0.3, v2 * 0.3),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Ice1.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone.Neon.Ice2.Speed = NumberRange.new(v2 * 5 * 4, v2 * 15 * 4)
				clone:SetPrimaryPartCFrame(CFrame.new(position4) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
					0,
					v4,
					0
				) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(-15, -5))), 0))
				clone.Parent = workspace.Effects
				clone.Neon.Sm:Emit(2)
				clone.Neon.Ice1:Emit(1)
				clone.Neon.Ice2:Emit(1)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			elseif not instance4 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeLow:Clone()
				clone.Ice.Transparency = 0.25
				clone.Neon.Transparency = -1
				clone.Ice.Size = createVector(1.284, 1.172, 4.293)
				clone.Neon.Size = createVector(1.254, 1.144, 4.258)
				clone.Neon.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, v2 * 10 * 2),
					NumberSequenceKeypoint.new(0.883, v2 * 10 * 2),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.Neon.Sm.Speed = NumberRange.new(v2 / 2 * 50, v2 / 2 * 100)

				if position4.Y <= -3.35 then
					clone:SetPrimaryPartCFrame(CFrame.new(position4.X, -3.35, position4.Z) * CFrame.new(0, v2 * 10, 0) * CFrame.fromOrientation(
						0,
						v4,
						0
					) * CFrame.Angles(math.rad((math.random(35, 55))), math.rad((math.random(-15, -5))), 0))
				else
					clone:SetPrimaryPartCFrame(v6 * CFrame.new(0, v2 * 10, 0) * CFrame.Angles(
						math.rad((math.random(35, 55))),
						math.rad((math.random(-15, -5))),
						0
					))
				end

				clone.Parent = workspace.Effects
				clone.Neon.Sm:Emit(2)
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone.Ice, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Ice.Size * v2 * 12
				}):Play()
				TweenService:Create(clone.Neon, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Neon.Size * v2 * 12
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Ice") then
						TweenService:Create(clone.Ice, tweenInfo, {
							Size = clone.Ice.Size / 1.15,
							CFrame = clone.Ice.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end

					if clone:FindFirstChild("Neon") then
						TweenService:Create(clone.Neon, tweenInfo, {
							Size = clone.Neon.Size / 1.15,
							CFrame = clone.Neon.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
							Transparency = 1
						}):Play()
					end
				end)
			end
		end)
	end)
end

function Ice_V_Awake(_, p, list, _)
	local cframe = p
	local v2, v3 = unpack(list)
	local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone.Color = Color3.fromRGB(128, 187, 219)
	clone.Transparency = -1
	clone.CFrame = v2.CFrame * CFrame.Angles(-0.2617993877991494, 0, 0) * CFrame.new(0, 10, 0)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 0.5)
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(51.861, 1.266, 51.861),
		Transparency = 1
	}):Play()
	PeodizService.ForceForLoop({
		Step = 7,
		WaitTime = 0.1
	}, function(p2)
		local v4 = math.floor(p2 * 7)
		local cFrame = v2.CFrame
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpike:Clone()
		_G.PU:Dust(clone2, 2)
		clone2.Size = createVector(2.738, 2.9, 25.045)
		clone2.Transparency = -1
		clone2.Ice1.Enabled = true
		clone2.Ice2.Enabled = true
		clone2.Sm.Enabled = true
		clone2.CFrame = cFrame * CFrame.Angles(1.3089969389957472, 0, 0)
		clone2.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6826837287",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone2
		sound:Play()
		TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			CFrame = clone2.CFrame * CFrame.new(0, 0, math.random(-250, -225))
		}):Play()
		spawn(function()
			wait(0.25)
			clone2.Transparency = 1
			clone2.Ice1.Enabled = false
			clone2.Ice2.Enabled = false
			clone2.Sm.Enabled = false
		end)
		spawn(function()
			wait(0.1)
			local cFrame2 = v3[v4]

			if (cFrame2.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				_G.CameraShake:ShakeOnce(2, 10, 0, 0.06)
				local clone3 = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone3.Enabled = true
				clone3.Parent = workspace.CurrentCamera
				clone3.Size = 0
				_G.PU:Dust(clone3, 0.5)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
					{
						Size = 10
					}
				):Play()
			end

			local clone3 = ReplicatedStorage.Chest.SwordEffect.NightBlade.Thing:Clone()
			clone3.Color = Color3.fromRGB(152, 232, 222)
			clone3.Size = createVector(0, 100, 0)
			clone3.CFrame = cFrame2 * CFrame.Angles(0.08726646259971647, 0, 0) * CFrame.new(0, 200, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Size = createVector(15, 150, 15),
				CFrame = clone3.CFrame * CFrame.new(0, -150, 0)
			}):Play()
			spawn(function()
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(0, 150, 0)
				}):Play()
			end)
			_G.PU:Dust(clone3, 0.25)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Ice.Shockwave:Clone()
			clone4.Color = Color3.fromRGB(152, 232, 222)
			clone4.Transparency = -1
			clone4.Size = Vector3.new()
			clone4.CFrame = cFrame2 * CFrame.Angles(1.6580627893946132, 0, 0)
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 1)
			TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(13.74, 13.74, 100),
				CFrame = clone4.CFrame * CFrame.new(0, 0, -33.333333333333336)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.2), {
				Transparency = 1
			}):Play()
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
			_G.PU:Dust(clone5, 2)
			clone5.Attachment.SparkWink.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 100),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone5.AttachmentS.Spikes.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 13.12),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone5.CFrame = cFrame2 * CFrame.new(0, 3, 0)
			clone5.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8732492666",
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone5
			sound2:Play()
			clone5.Attachment.SparkWink:Emit(1)
			clone5.Attachment.Rocks:Emit(5)
			clone5.Attachment.Rocks2:Emit(5)
			clone5.Attachment.Sm:Emit(5)
			clone5.AttachmentS.Spikes:Emit(15)
			local clone6 = ReplicatedStorage.Chest.FruitEffect.Ice.RingDecal:Clone()
			_G.PU:Dust(clone6, 0.5)
			clone6.Decal.Transparency = -1
			clone6.Decal2.Transparency = -1
			clone6.Decal.Color3 = Color3.fromRGB(170, 2555, 2555)
			clone6.Decal2.Color3 = Color3.fromRGB(170, 2555, 2555)
			clone6.CFrame = cFrame2
			clone6.Parent = workspace.Effects
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(100, 1, 100)
			}):Play()
			TweenService:Create(clone6.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone6.Decal2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
		end)
	end)
	wait(0.25)
	local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone2.Color = Color3.fromRGB(128, 187, 219)
	clone2.Transparency = -1
	clone2.CFrame = v2.CFrame * CFrame.Angles(-0.2617993877991494, 0, 0) * CFrame.new(0, 10, 0)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 0.5)
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(138.296, 8, 138.296),
		Transparency = 1
	}):Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpike:Clone()
	clone3.Size = createVector(10.952, 11.6, 100.18)
	clone3.Transparency = -1
	clone3.Ice1.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 6, 3),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone3.Ice2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 6, 3),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone3.Sm.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.043, 40),
		NumberSequenceKeypoint.new(0.883, 40),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone3.Ice1.Acceleration = createVector(0, -200, 0)
	clone3.Ice2.Acceleration = createVector(0, -200, 0)
	clone3.Ice1.Enabled = true
	clone3.Ice2.Enabled = true
	clone3.Sm.Enabled = true
	clone3.CFrame = v2.CFrame * CFrame.Angles(1.3089969389957472, 0, 0)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8823677867",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		CFrame = clone3.CFrame * CFrame.new(0, 0, -250)
	}):Play()
	local clone4 = ReplicatedStorage.Chest.FruitEffect.Ice.Shockwave:Clone()
	clone4.Size = createVector(22.671, 22.671, 75.657)
	clone4.CFrame = v2.CFrame * CFrame.Angles(-1.8325957145940461, 0, 0)
	clone4.Transparency = -1
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 0.25)
	TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		CFrame = clone4.CFrame * CFrame.new(0, 0, 270)
	}):Play()
	spawn(function()
		wait(0.25)
		clone3.Transparency = 1
		clone3.Ice1.Enabled = false
		clone3.Ice2.Enabled = false
		clone3.Sm.Enabled = false
	end)
	spawn(function()
		wait(0.3)

		if (cframe.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 300 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			local clone5 = ReplicatedStorage.Chest.Etc.Blur:Clone()
			clone5.Enabled = true
			clone5.Parent = workspace.CurrentCamera
			clone5.Size = 0
			_G.PU:Dust(clone5, 1)
			TweenService:Create(
				clone5,
				TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = 12
				}
			):Play()
		end

		local clone5 = ReplicatedStorage.Chest.SwordEffect.NightBlade.Thing:Clone()
		clone5.Color = Color3.fromRGB(152, 232, 222)
		clone5.Size = createVector(0, 100, 0)
		clone5.CFrame = cframe * CFrame.Angles(0.08726646259971647, 0, 0) * CFrame.new(0, 400, 0)
		clone5.Parent = workspace.Effects
		TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
			Size = createVector(60, 600, 60),
			CFrame = clone5.CFrame * CFrame.new(0, -350, 0)
		}):Play()
		spawn(function()
			TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(0, 150, 0)
			}):Play()
		end)
		_G.PU:Dust(clone5, 0.25)
		local clone6 = ReplicatedStorage.Chest.FruitEffect.Ice.Shockwave:Clone()
		clone6.Color = Color3.fromRGB(152, 232, 222)
		clone6.Transparency = -1
		clone6.Size = Vector3.new()
		clone6.CFrame = cframe * CFrame.Angles(1.6580627893946132, 0, 0)
		clone6.Parent = workspace.Effects
		_G.PU:Dust(clone6, 1)
		TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(54.96, 54.96, 400),
			CFrame = clone6.CFrame * CFrame.new(0, 0, -33.333333333333336)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.2), {
			Transparency = 1
		}):Play()
		local clone7 = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
		_G.PU:Dust(clone7, 2)
		clone7.Attachment.SparkWink.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 400)
		})
		clone7.Attachment.SparkWink.Texture = "rbxassetid://1084970835"
		clone7.Attachment.SparkWink.Lifetime = NumberRange.new(0.15)
		clone7.AttachmentS.Sm.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.043, 100),
			NumberSequenceKeypoint.new(0.883, 100),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone7.AttachmentS.Sm.Speed = NumberRange.new(500, 1500)
		clone7.AttachmentS.Sm.Rate = 100
		clone7.AttachmentS.Sm.Enabled = true
		clone7.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 500)
		})
		clone7.Attachment.Ring.Lifetime = NumberRange.new(0.5)
		clone7.AttachmentS.Spikes.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 196.79999999999998),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone7.AttachmentS.Spikes.Speed = NumberRange.new(750, 1000)
		clone7.AttachmentS.Spikes.Lifetime = NumberRange.new(0.15, 0.4)
		clone7.CFrame = cframe * CFrame.new(0, 3, 0)
		clone7.Parent = workspace.Effects
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8732492666",
			Volume = 2
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone7
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8732492666",
			Volume = 2
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone7
		sound3:Play()
		local sound4 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8798644218",
			Volume = 4
		})
		_G.PU:Dust(sound4, 3)
		sound4.Parent = clone7
		sound4:Play()
		local sound5 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8801269379",
			Volume = 3
		})
		_G.PU:Dust(sound5, 3)
		sound5.Parent = clone7
		sound5:Play()
		clone7.Attachment.Rocks:Emit(5)
		clone7.Attachment.Rocks2:Emit(5)
		clone7.Attachment.Sm:Emit(5)
		clone7.Attachment.Ring:Emit(1)
		clone7.AttachmentS.Spikes:Emit(15)
		spawn(function()
			wait(1)
			clone7.AttachmentS.Sm.Enabled = false
		end)
		local clone8 = ReplicatedStorage.Chest.FruitEffect.Ice.RingDecal:Clone()
		_G.PU:Dust(clone8, 0.5)
		clone8.Decal.Transparency = -1
		clone8.Decal2.Transparency = -1
		clone8.Decal.Color3 = Color3.fromRGB(170, 2555, 2555)
		clone8.Decal2.Color3 = Color3.fromRGB(170, 2555, 2555)
		clone8.CFrame = cframe
		clone8.Parent = workspace.Effects
		TweenService:Create(clone8, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(400, 4, 400)
		}):Play()
		TweenService:Create(clone8.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone8.Decal2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Transparency = 1
		}):Play()
		spawn(function()
			cframe = CFrame.new(cframe.Position)

			local function CreateIceFloor(p2)
				local CF = p2.CF
				local clone9 = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathAwake:Clone()
				clone9.IceFloor.Transparency = -1
				clone9.IceFloorNeon.Transparency = -1
				clone9:SetPrimaryPartCFrame(CF)
				clone9.Parent = workspace.Effects
				_G.PU:Dust(clone9, 5)
				TweenService:Create(clone9.IceFloor, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(270.55014, 7.70845, 257.08365)
				}):Play()
				TweenService:Create(clone9.IceFloorNeon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(269.7946, 7.567, 256.29706)
				}):Play()
				spawn(function()
					wait(1.5)

					if clone9:FindFirstChild("IceFloor") then
						TweenService:Create(clone9.IceFloor, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end

					if clone9:FindFirstChild("IceFloorNeon") then
						TweenService:Create(clone9.IceFloorNeon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end)
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -10, 0), raycastParams)
			local _ = cframe.Position + createVector(0, 10, 0) + createVector(0, -60, 0)

			if raycastResult then
				local _ = raycastResult.Instance
				local _ = raycastResult.Position
			end

			local CF2 = cframe * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
			CreateIceFloor({
				CF = CF2
			})
			spawn(function()
				for i = 1, 10 do
					local function CreateIceBox(p2)
						local cframe2 = CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local CF = p2.CF
						local clone9 = ReplicatedStorage.Chest.FruitEffect.Ice.IceCube:Clone()
						_G.PU:Dust(clone9, 3)
						clone9.Cube.Transparency = -1
						clone9.CubeNeon.Transparency = -1
						clone9.Cube.Size = createVector(66.48375, 66.48375, 66.48375)
						clone9.CubeNeon.Size = createVector(66.01625, 66.01625, 66.01625)
						clone9:SetPrimaryPartCFrame(CF)
						clone9.Parent = workspace.Effects
						TweenService:Create(clone9.Cube, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							CFrame = CF * CFrame.new(0, 0, -100) * cframe2
						}):Play()
						TweenService:Create(clone9.CubeNeon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							CFrame = CF * CFrame.new(0, 0, -100) * cframe2
						}):Play()
						spawn(function()
							wait(1.5)

							if clone9:FindFirstChild("Cube") then
								TweenService:Create(clone9.Cube, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
									Transparency = 1
								}):Play()
							end

							if clone9:FindFirstChild("CubeNeon") then
								TweenService:Create(clone9.CubeNeon, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
									Transparency = 1
								}):Play()
							end
						end)
					end

					CreateIceBox({
						CF = cframe * CFrame.Angles(0, 6.283185307179586 * i / 10, 0)
					})
				end
			end)
		end)
	end)
end

function Ice_Awake_Charge(player, _, list, _)
	spawn(function()
		local v2, v3 = unpack(list)
		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.05
		}, function()
			if not v3:IsDescendantOf(player.Character) then
				return true
			end

			local cFrame = CFrame.new(v2.Position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			math.random(8, 10)
			local v5 = math.random(5, 10) / 10
			local v6 = math.random(15, 35)
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = Vector3.new(v5, v5, math.random(8, 10))
			clone.Color = Color3.fromRGB(152, 232, 222)
			clone.CFrame = cFrame * CFrame.new(0, 0, v6)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = cFrame
			}):Play()
			_G.PU:Dust(clone, 0.14)
		end)
	end)
end

function Ice_E_Awake_Trans(_, cFrame, _, _)
	if (cFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
		clone.Enabled = true
		clone.Parent = workspace.CurrentCamera
		clone.Size = 0
		_G.PU:Dust(clone, 0.5)
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0), {
			Size = 10
		}):Play()
	end

	local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceSpikeImpact:Clone()
	_G.PU:Dust(clone, 3)
	clone.Attachment.Ring.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 150)
	})
	clone.Attachment.Ring.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.1, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	clone.AttachmentS.Spikes.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 91.83999999999999),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.AttachmentS.Spikes.Speed = NumberRange.new(500, 750)
	clone.AttachmentS.Spikes.SpreadAngle = Vector2.new(-360, 360)
	clone.AttachmentS.Sm.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.1, 90),
		NumberSequenceKeypoint.new(0.9, 90),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.AttachmentS.Sm.Lifetime = NumberRange.new(2, 3)
	clone.AttachmentS.Sm.Speed = NumberRange.new(100, 200)
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8732492666",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	clone.AttachmentS.Spikes:Emit(20)
	clone.AttachmentS.Sm:Emit(15)
	clone.Attachment.Ring:Emit(1)
	local part = Instance.new("Part")
	part.Shape = "Ball"
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Transparency = -1
	part.Size = Vector3.new()
	part.Color = Color3.fromRGB(128, 187, 219)
	part.CFrame = cFrame
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1)
	TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		Size = createVector(150, 150, 150),
		Transparency = 1
	}):Play()
end

function Freeze(_, _, list, _)
	local parent, v3 = unpack(list)
	pcall(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IceFrozen:Clone()
		clone.Material = "Neon"
		clone.CFrame = parent.HumanoidRootPart.CFrame
		clone.Size = createVector(6, 9, 6) * parent.HumanoidRootPart.Size.Y / 2
		local weld = Instance.new("Weld")
		weld.Part0 = parent.HumanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone
		clone.Parent = parent
		_G.PU:Dust(clone, v3)
	end)
end

function FreezeStone(_, _, list, _)
	local parent, v3 = unpack(list)
	local v4 = {
		LeftFoot = true,
		LeftHand = true,
		LeftLowerArm = true,
		LeftLowerLeg = true,
		LeftUpperArm = true,
		LeftUpperLeg = true,
		LowerTorso = true,
		RightFoot = true,
		RightHand = true,
		RightLowerArm = true,
		RightLowerLeg = true,
		RightUpperArm = true,
		RightUpperLeg = true,
		UpperTorso = true,
		Head = true
	}

	for _, child in pairs(parent:GetChildren()) do
		if not v4[tostring(child.Name)] then
			continue
		end

		local part = Instance.new("Part")
		part.Material = Enum.Material.Slate
		part.Color = Color3.fromRGB(81, 81, 81)
		part.CastShadow = false
		part.Anchored = false
		part.CanCollide = false
		part.Transparency = -1
		part.Size = child.Size * 1.2
		part.CFrame = child.CFrame
		local weld = Instance.new("Weld")
		weld.Part0 = child
		weld.Part1 = part
		weld.Parent = part
		part.Parent = parent
		_G.PU:Dust(part, v3)
	end
end

function Magma_Z(_, _, list, _)
	local v2 = unpack(list)
	PeodizService.HeartbeatWait({
		Time = 5,
		WaitTime = 0.15
	}, function()
		if not v2:IsDescendantOf(workspace.Effects) then
			return true
		end

		local cFrame = v2.CFrame
		local clone = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaBall:Clone()
		clone.Size = createVector(10, 10, 10)
		clone.CFrame = cFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5)) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1.65)
		TweenService:Create(clone, TweenInfo.new(0.75), {
			Size = createVector(25, 25, 25) * math.random(100, 150) / 100,
			CFrame = clone.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
		}):Play()
		spawn(function()
			wait(0.5)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = Vector3.new()
			}):Play()
		end)
	end)
end

function Magma_Z_Awake(_, _, list, _)
	local v2, v3, v4, v5, parent, step = unpack(list)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8982399639",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = parent
	sound:Play()
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.AMagmaFist:Clone()
	clone.Out.Size = clone.Out.Size * 1.25
	clone.Neon.Size = clone.Neon.Size * 1.25
	clone:SetPrimaryPartCFrame(v2.CFrame * CFrame.new(0, 0, -3))
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 2)
	spawn(function()
		local neon = clone.Neon
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.35
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone2.Transparency = -1
				clone2.Color = Color3.fromRGB(255, 255, 255)
				clone2.CFrame = neon.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Size = createVector(30, 2.5, 30) * math.random(10, 20) / 10,
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.5)
			end)
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.05
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local cFrame = neon.CFrame
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.DecalWind:Clone()
				clone2.Mesh.Scale = createVector(1, 0.6666667, 0.6666667)
				clone2.CFrame = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
					6.283185307179586 * math.random(),
					0,
					0
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2.Decal, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
					CFrame = clone2.CFrame * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
				}):Play()
				_G.PU:Dust(clone2, 0.2)
			end)
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local cFrame = neon.CFrame
				local cframe = CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local v8 = math.random(100, 200) / 200
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
				clone2.Lava.Size = createVector(10.158, 10.158, 10.158)
				clone2.Neon.Size = createVector(9.997, 9.997, 9.997)
				clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(
					math.random(-3.5, 3.5),
					math.random(-3.5, 3.5),
					math.random(-3.5, 0)
				) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				))
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2.Lava, TweenInfo.new(0.375), {
					Size = createVector(26.158, 26.158, 26.158) * v8,
					CFrame = clone2.Lava.CFrame * cframe
				}):Play()
				TweenService:Create(clone2.Neon, TweenInfo.new(0.375), {
					Size = createVector(25.742, 25.742, 25.742) * v8,
					CFrame = clone2.Neon.CFrame * cframe
				}):Play()
				spawn(function()
					wait(math.random(35, 50) / 200)

					if clone2:FindFirstChild("Lava") then
						TweenService:Create(clone2.Lava, TweenInfo.new(0.5), {
							Size = Vector3.new(),
							CFrame = clone2.Lava.CFrame * cframe
						}):Play()
					end

					if clone2:FindFirstChild("Neon") then
						TweenService:Create(clone2.Neon, TweenInfo.new(0.5), {
							Size = Vector3.new(),
							CFrame = clone2.Neon.CFrame * cframe
						}):Play()
					end
				end)
			end)
		end)
	end)
	spawn(function()
		PeodizService.ForLoop({
			Step = step
		}, function(p)
			local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * step, -(p * step) * v4)

			if clone:FindFirstChild("Neon") then
				clone.Neon.CFrame = CFrame.new((v5 * cframe).p, clone.Neon.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			end

			if clone:FindFirstChild("Out") then
				clone.Out.CFrame = CFrame.new((v5 * cframe).p, clone.Out.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
			end
		end)
		local cframe = CFrame.new(v3.p)
		clone:Destroy()

		if (cframe.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
			clone2.Parent = game.Lighting
			_G.PU:Dust(clone2, 3)
			TweenService:Create(
				clone2,
				TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
				{
					TintColor = Color3.fromRGB(170, 0, 0)
				}
			):Play()
		end

		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Material = "Neon"
		part.CastShadow = false
		part.Anchored = true
		part.CanCollide = false
		part.Color = Color3.fromRGB(255, 255, 0)
		part.Size = Vector3.new()
		part.CFrame = cframe
		part.Parent = workspace.Effects
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Size = createVector(100, 100, 100),
			Transparency = 1,
			Color = Color3.fromRGB(255, 88, 88)
		}):Play()
		_G.PU:Dust(part, 0.5)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
		clone2.CFrame = cframe
		clone2.Specs.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 5, 5),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone2.Specs.Speed = NumberRange.new(0, 200)
		clone2.Size = createVector(50, 1, 50)
		clone2.Parent = workspace.Effects
		clone2.Specs:Emit(15)
		_G.PU:Dust(clone2, 3)
		spawn(function()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
			clone3.Rock.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 12.72),
				NumberSequenceKeypoint.new(0.264, 14.656, 14.656),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone3.Rock.Speed = NumberRange.new(90, 130)
			clone3.Circle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 120)
			})
			clone3.CFrame = cframe
			clone3.Parent = workspace.Effects
			clone3.Rock:Emit(5)
			clone3.Circle:Emit(1)
			_G.PU:Dust(clone3, 5)
		end)

		for _ = 1, 2 do
			local cframe2 = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v8 = math.random(35, 50) / 25
			local v9 = math.random(100, 200) / 100
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid1:Clone()
			_G.PU:Dust(clone3, v8 + 1.5)
			clone3.Lava.Size = createVector(10.158, 10.158, 10.158)
			clone3.Neon.Size = createVector(9.997, 9.997, 9.997)
			clone3:SetPrimaryPartCFrame(cframe * CFrame.new(
				math.random(-15, 15),
				math.random(-15, 15),
				math.random(-15, 0)
			) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			))
			clone3.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8982470659",
				Volume = 3
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone3.Neon
			sound2:Play()
			TweenService:Create(clone3.Lava, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(26.158, 26.158, 26.158) * v9
			}):Play()
			TweenService:Create(clone3.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(25.742, 25.742, 25.742) * v9
			}):Play()
			TweenService:Create(clone3.Lava, TweenInfo.new(4), {
				CFrame = clone3.Lava.CFrame * cframe2
			}):Play()
			TweenService:Create(clone3.Neon, TweenInfo.new(4), {
				CFrame = clone3.Neon.CFrame * cframe2
			}):Play()
			spawn(function()
				wait(v8)

				if clone3:FindFirstChild("Lava") then
					TweenService:Create(clone3.Lava, TweenInfo.new(1.5), {
						Size = Vector3.new()
					}):Play()
				end

				if clone3:FindFirstChild("Neon") then
					TweenService:Create(clone3.Neon, TweenInfo.new(1.5), {
						Size = Vector3.new()
					}):Play()
				end
			end)
		end
	end)
end

function Magma_X_Awake(_, _, list, _)
	for i = 1, 2 do
		local v2, v3, v4, v5, parent, step = unpack(list)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8982399639",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = parent
		sound:Play()
		local clone = ReplicatedStorage.Chest.FruitEffect.Magma.Ring2:Clone()
		clone.Color = Color3.fromRGB(255, 0, 0)
		clone.Size = Vector3.new()
		clone.Transparency = -1
		clone.CFrame = parent.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 0.5)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(50, 10, 50),
			CFrame = clone.CFrame * CFrame.new(0, math.random(5, 15), 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			),
			Transparency = 1
		}):Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.AMagmaFist:Clone()
		clone2.Out.Size = clone2.Out.Size * 2
		clone2.Neon.Size = clone2.Neon.Size * 2
		clone2.Neon.Attachment0.Position = createVector(-8, 0, 0)
		clone2.Neon.Attachment1.Position = createVector(8, 0, 0)
		clone2.Neon.Trail.Enabled = true
		clone2:SetPrimaryPartCFrame(v2.CFrame * CFrame.new(0, 0, -3))
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 2)
		spawn(function()
			local neon = clone2.Neon
			spawn(function()
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.1
				}, function()
					if not (neon:IsDescendantOf(workspace.Effects) and clone2:IsDescendantOf(workspace.Effects)) then
						return true
					end

					local cFrame = neon.CFrame
					local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.DecalWind:Clone()
					clone3.Mesh.Scale = createVector(1.5, 1, 1)
					clone3.CFrame = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
						6.283185307179586 * math.random(),
						0,
						0
					)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
						CFrame = clone3.CFrame * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
					}):Play()
					_G.PU:Dust(clone3, 0.35)
				end)
			end)
			spawn(function()
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.25
				}, function()
					if not (neon:IsDescendantOf(workspace.Effects) and clone2:IsDescendantOf(workspace.Effects)) then
						return true
					end

					local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(255, 255, 255)
					clone3.CFrame = neon.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone3.Parent = workspace.Effects
					TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(30, 2, 30) * math.random(15, 30) / 10,
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone3, 0.5)
				end)
			end)
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.1
				}, function()
					if not (neon:IsDescendantOf(workspace.Effects) and clone2:IsDescendantOf(workspace.Effects)) then
						return true
					end

					local cFrame = neon.CFrame
					local cframe = CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local v9 = math.random(100, 200) / 75
					local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
					clone3.Lava.Size = createVector(10.158, 10.158, 10.158)
					clone3.Neon.Size = createVector(9.997, 9.997, 9.997)
					clone3:SetPrimaryPartCFrame(cFrame * CFrame.new(
						math.random(-5, 5),
						math.random(-5, 5),
						math.random(-5, 0)
					) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					))
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					TweenService:Create(clone3.Lava, TweenInfo.new(0.375), {
						Size = createVector(26.158, 26.158, 26.158) * v9,
						CFrame = clone3.Lava.CFrame * cframe
					}):Play()
					TweenService:Create(clone3.Neon, TweenInfo.new(0.375), {
						Size = createVector(25.742, 25.742, 25.742) * v9,
						CFrame = clone3.Neon.CFrame * cframe
					}):Play()
					spawn(function()
						wait(math.random(35, 50) / 200)

						if clone3:FindFirstChild("Lava") then
							TweenService:Create(clone3.Lava, TweenInfo.new(0.5), {
								Size = Vector3.new(),
								CFrame = clone3.Lava.CFrame * cframe
							}):Play()
						end

						if clone3:FindFirstChild("Neon") then
							TweenService:Create(clone3.Neon, TweenInfo.new(0.5), {
								Size = Vector3.new(),
								CFrame = clone3.Neon.CFrame * cframe
							}):Play()
						end
					end)
				end)
			end)
		end)
		local v10 = i
		local v12 = clone2
		spawn(function()
			local v15 = -step

			if v10 == 2 then
				v15 = step
			end

			PeodizService.ForLoop({
				Step = step
			}, function(p)
				local v16 = math.floor(step * p)
				local cframe = CFrame.new(
					math.sin(6.283185307179586 * p) * v15,
					math.sin(3.141592653589793 * p) * step,
					-v16 * v4
				)
				v12.Neon.CFrame = CFrame.new((v5 * cframe).p, v12.Neon.Position) * CFrame.Angles(
					0,
					3.141592653589793,
					0
				)
				v12.Out.CFrame = CFrame.new((v5 * cframe).p, v12.Out.Position) * CFrame.Angles(0, 3.141592653589793, 0)
			end)
			v12:Destroy()
			local cframe = CFrame.new(v3.p)

			if (cframe.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
				_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
				local clone3 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
				clone3.Parent = game.Lighting
				_G.PU:Dust(clone3, 3)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
					{
						TintColor = Color3.fromRGB(170, 0, 0)
					}
				):Play()
			end

			local part = Instance.new("Part")
			part.Shape = "Ball"
			part.Material = "Neon"
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			part.Color = Color3.fromRGB(255, 255, 0)
			part.Size = Vector3.new()
			part.CFrame = cframe
			part.Parent = workspace.Effects
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = createVector(150, 150, 150),
				Transparency = 1,
				Color = Color3.fromRGB(255, 88, 88)
			}):Play()
			_G.PU:Dust(part, 0.5)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
			clone3.CFrame = cframe
			clone3.Specs.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.2, 6.25, 6.25),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone3.Specs.Speed = NumberRange.new(0, 500)
			clone3.Size = createVector(50, 1, 50)
			clone3.Parent = workspace.Effects
			clone3.Specs:Emit(30)
			_G.PU:Dust(clone3, 3)
			spawn(function()
				for i2 = 1, 5 do
					local vector2 = Vector3.new(math.random(-90, 90), math.random(100, 200), math.random(-90, 90))
					local v16 = math.random(15, 50)
					math.random(100, 150)
					local v17 = cframe * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15)) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					local clone4 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
					clone4.Neon.Size = Vector3.new(v16, v16, v16)
					clone4.Lava.Size = Vector3.new(v16, v16, v16) * 1.05
					clone4.Lava.Anchored = false
					clone4.Neon.Anchored = false
					clone4.Lava.Velocity = vector2
					clone4.Neon.Velocity = vector2
					clone4:SetPrimaryPartCFrame(v17)
					clone4.Parent = workspace.Effects
					TweenService:Create(
						clone4.Lava,
						TweenInfo.new(2.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					TweenService:Create(
						clone4.Neon,
						TweenInfo.new(2.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					_G.PU:Dust(clone4, 2.3)
				end
			end)

			for i2 = 1, 2 do
				local cframe2 = CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local v16 = math.random(35, 50) / 25
				local v17 = math.random(100, 200) / 50
				local clone4 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid1:Clone()
				_G.PU:Dust(clone4, v16 + 1.5)
				clone4.Lava.Size = createVector(10.158, 10.158, 10.158)
				clone4.Neon.Size = createVector(9.997, 9.997, 9.997)
				clone4:SetPrimaryPartCFrame(cframe * CFrame.new(
					math.random(-15, 15),
					math.random(-15, 15),
					math.random(-15, 0)
				) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				))
				clone4.Parent = workspace.Effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8982470659",
					Volume = 3
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone4.Neon
				sound2:Play()
				TweenService:Create(clone4.Lava, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(26.158, 26.158, 26.158) * v17
				}):Play()
				TweenService:Create(clone4.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(25.742, 25.742, 25.742) * v17
				}):Play()
				TweenService:Create(clone4.Lava, TweenInfo.new(4), {
					CFrame = clone4.Lava.CFrame * cframe2
				}):Play()
				TweenService:Create(clone4.Neon, TweenInfo.new(4), {
					CFrame = clone4.Neon.CFrame * cframe2
				}):Play()
				spawn(function()
					wait(v16)

					if clone4:FindFirstChild("Lava") then
						TweenService:Create(clone4.Lava, TweenInfo.new(1.5), {
							Size = Vector3.new()
						}):Play()
					end

					if clone4:FindFirstChild("Neon") then
						TweenService:Create(clone4.Neon, TweenInfo.new(1.5), {
							Size = Vector3.new()
						}):Play()
					end
				end)
			end
		end)
	end
end

function Magma_C_Awake(_, p, list, _)
	local v2, v3, v4 = unpack(list)
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.SlashAni:Clone()
	_G.PU:Dust(clone, 1)
	clone.CFrame = v2.CFrame * CFrame.new(0, 5, -5) * CFrame.Angles(0.17453292519943295, 0, 0)
	clone.Parent = workspace.Effects
	local Animate = require(clone.Animate)
	Animate()
	spawn(function()
		if v3 then
			wait(0.5)
			TweenService:Create(v3.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			TweenService:Create(v3.MagmaArm, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
		end
	end)

	if (p.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
		clone2.Parent = game.Lighting
		_G.PU:Dust(clone2, 3)
		TweenService:Create(
			clone2,
			TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
			{
				TintColor = Color3.fromRGB(170, 0, 0)
			}
		):Play()
	end

	PeodizService.ForLoop({
		Step = 5,
		WaitTime = 0.1
	}, function(p2)
		local cFrame = v4[math.floor(p2 * 5)]
		spawn(function()
			for _ = 1, 5 do
				local vector2 = Vector3.new(math.random(-45, 45), math.random(100, 200), math.random(-45, 45))
				local v7 = math.random(10, 30)
				local v8 = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
				clone2.Neon.Size = Vector3.new(v7, v7, v7)
				clone2.Lava.Size = Vector3.new(v7, v7, v7) * 1.05
				clone2.Lava.Anchored = false
				clone2.Neon.Anchored = false
				clone2.Lava.Velocity = vector2
				clone2.Neon.Velocity = vector2
				clone2:SetPrimaryPartCFrame(v8)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2.Lava, TweenInfo.new(1.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone2.Neon, TweenInfo.new(1.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				_G.PU:Dust(clone2, 1.3)
			end
		end)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.Ring:Clone()
		clone2.Size = createVector(0, 0, 0)
		clone2.Color = Color3.fromRGB(170, 0, 0)
		clone2.Transparency = -1
		clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random()),
			Transparency = 1,
			Size = createVector(150, 150, 30)
		}):Play()
		local cframe = CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		local v7 = math.random(35, 50) / 25
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Material = "Neon"
		part.CastShadow = false
		part.Anchored = true
		part.CanCollide = false
		part.Color = Color3.fromRGB(255, 255, 0)
		part.Size = Vector3.new()
		part.CFrame = cFrame
		part.Parent = workspace.Effects
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Size = createVector(112.5, 112.5, 112.5),
			Transparency = 1,
			Color = Color3.fromRGB(255, 88, 88)
		}):Play()
		_G.PU:Dust(part, 0.5)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid1:Clone()
		_G.PU:Dust(clone3, v7 + 1.5)
		clone3.Neon.Size = createVector(9.997, 9.997, 9.997) * math.random(8, 12) / 10
		clone3.Lava.Size = clone3.Neon.Size * 1.02
		clone3:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		))
		clone3.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8982470659",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone3.Neon
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://165970126",
			Volume = 0.1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3
		sound2:Play()
		TweenService:Create(clone3.Lava, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = clone3.Lava.Size * 5
		}):Play()
		TweenService:Create(clone3.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = clone3.Neon.Size * 5
		}):Play()
		TweenService:Create(clone3.Lava, TweenInfo.new(4), {
			CFrame = clone3.Lava.CFrame * cframe
		}):Play()
		TweenService:Create(clone3.Neon, TweenInfo.new(4), {
			CFrame = clone3.Neon.CFrame * cframe
		}):Play()
		spawn(function()
			wait(v7)

			if clone3:FindFirstChild("Lava") then
				TweenService:Create(clone3.Lava, TweenInfo.new(1.5), {
					Size = Vector3.new()
				}):Play()
			end

			if clone3:FindFirstChild("Neon") then
				TweenService:Create(clone3.Neon, TweenInfo.new(1.5), {
					Size = Vector3.new()
				}):Play()
			end
		end)
		local clone4 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
		clone4.CFrame = cFrame
		clone4.Specs.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 6.25, 6.25),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone4.Specs.Speed = NumberRange.new(0, 300)
		clone4.Size = createVector(50, 1, 50)
		clone4.Parent = workspace.Effects
		clone4.Specs:Emit(15)
		_G.PU:Dust(clone4, 3)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local raycastResult = workspace:Raycast(cFrame.p, createVector(0, -25, 0), raycastParams)
		local position = cFrame.p + createVector(0, -25, 0)
		local instance, normal

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
			normal = raycastResult.Normal
			local _ = instance.Material
		end

		if instance then
			local clone5 = ReplicatedStorage.Chest.FruitEffect.Magma.Crack:Clone()
			clone5.Dark.Transparency = 0
			clone5.Neon.Transparency = 0
			clone5.Specs.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.199, 5, 5),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone5.Attachment.shard.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.201, 35, 35),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone5.Attachment.shard.Speed = NumberRange.new(25, 400)
			clone5.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			) * CFrame.new(0, -1, 0)
			clone5.Parent = workspace.Effects
			clone5.Attachment.shard:Emit(10)
			_G.PU:Dust(clone5, 2.5)
			TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(100, 0, 100)
			}):Play()
			spawn(function()
				wait(v7)

				if clone5:FindFirstChild("Neon") then
					TweenService:Create(clone5.Neon, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end

				if clone5:FindFirstChild("Dark") then
					TweenService:Create(clone5.Dark, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end
			end)
		end
	end)
end

function Magma_V_Awake(_, p, list, _)
	local parent, v3 = unpack(list)
	local v4 = (parent.Position - p.p).Magnitude / 100
	local cframe = CFrame.new(parent.CFrame.p, p.p)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8982399639",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = parent
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7000629559",
		Volume = 0.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = parent
	sound2:Play()
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.AMagmaFist:Clone()
	clone.Out.Size = clone.Out.Size * 3
	clone.Neon.Size = clone.Neon.Size * 3
	clone.Neon.Attachment0.Position = createVector(-10, 0, 0)
	clone.Neon.Attachment1.Position = createVector(10, 0, 0)
	clone.Neon.Trail.Enabled = true
	clone:SetPrimaryPartCFrame(parent.CFrame * CFrame.new(0, 0, -3))
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 6)

	if (parent.CFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
		clone2.Parent = game.Lighting
		_G.PU:Dust(clone2, 3)
		TweenService:Create(
			clone2,
			TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
			{
				TintColor = Color3.fromRGB(170, 0, 0)
			}
		):Play()
	end

	spawn(function()
		local neon = clone.Neon
		spawn(function()
			local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = neon.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(0, 20, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(60, 4, 60),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.5)
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.35
			}, function() end)
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.35
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone3.Transparency = -1
				clone3.Color = Color3.fromRGB(255, 255, 255)
				clone3.CFrame = neon.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Size = createVector(30, 2.5, 30) * math.random(20, 30) / 5,
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 0.5)
			end)
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local cFrame = neon.CFrame
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.DecalWind:Clone()
				clone2.Mesh.Scale = createVector(2.25, 1.5, 1.5)
				clone2.CFrame = cFrame * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
					6.283185307179586 * math.random(),
					0,
					0
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2.Decal, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
					CFrame = clone2.CFrame * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
				}):Play()
				_G.PU:Dust(clone2, 0.15)
			end)
		end)
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.1
			}, function()
				if not (neon:IsDescendantOf(workspace.Effects) and clone:IsDescendantOf(workspace.Effects)) then
					return true
				end

				local cFrame = neon.CFrame
				local cframe2 = CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local v5 = math.random(100, 200) / 75
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
				clone2.Lava.Size = createVector(10.158, 10.158, 10.158)
				clone2.Neon.Size = createVector(9.997, 9.997, 9.997)
				clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(
					math.random(-5, 5),
					math.random(-5, 5),
					math.random(-5, 0)
				) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				))
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 1)
				TweenService:Create(clone2.Lava, TweenInfo.new(0.375), {
					Size = createVector(26.158, 26.158, 26.158) * v5,
					CFrame = clone2.Lava.CFrame * cframe2
				}):Play()
				TweenService:Create(clone2.Neon, TweenInfo.new(0.375), {
					Size = createVector(25.742, 25.742, 25.742) * v5,
					CFrame = clone2.Neon.CFrame * cframe2
				}):Play()
				spawn(function()
					wait(math.random(35, 50) / 200)

					if clone2:FindFirstChild("Lava") then
						TweenService:Create(clone2.Lava, TweenInfo.new(0.5), {
							Size = Vector3.new(),
							CFrame = clone2.Lava.CFrame * cframe2
						}):Play()
					end

					if clone2:FindFirstChild("Neon") then
						TweenService:Create(clone2.Neon, TweenInfo.new(0.5), {
							Size = Vector3.new(),
							CFrame = clone2.Neon.CFrame * cframe2
						}):Play()
					end
				end)
			end)
		end)
	end)
	spawn(function()
		local v5 = true
		local v6 = nil
		PeodizService.ForLoop({
			Step = 100
		}, function(p2)
			local v7 = math.floor(100 * p2)
			local cframe2 = CFrame.new(0, math.sin(3.141592653589793 * p2) * 300, -v7 * v4)
			clone.Neon.CFrame = CFrame.new((cframe * cframe2).p, clone.Neon.Position) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			clone.Out.CFrame = CFrame.new((cframe * cframe2).p, clone.Out.Position) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)

			if p2 >= 0.45 and not v6 then
				v6 = true
				coroutine.wrap(function()
					for i = 1, 10 do
						local cFrame = v3[i] * CFrame.new(0, 300, 70)
						local cframe3 = CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
						clone2.SparkWink.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.5, 10 * math.random(10, 20) * 2),
							NumberSequenceKeypoint.new(1, 0)
						})
						clone2.CFrame = cFrame
						clone2.Parent = workspace.Effects
						clone2.SparkWink:Emit(1)
						_G.PU:Dust(clone2, 0.5)
						local v9 = math.random(100, 200) / 100
						local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
						clone3.Neon.Sm.Size = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(0.043, 10 * v9),
							NumberSequenceKeypoint.new(0.883, 10 * v9),
							NumberSequenceKeypoint.new(1, 0)
						})
						clone3.Neon.Sm.Enabled = true
						clone3.Lava.Size = createVector(10.158, 10.158, 10.158)
						clone3.Neon.Size = createVector(9.997, 9.997, 9.997)
						clone3:SetPrimaryPartCFrame(cFrame * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						))
						clone3.Parent = workspace.Effects
						_G.PU:Dust(clone3, 5)
						TweenService:Create(clone3.Lava, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Size = createVector(26.158, 26.158, 26.158) * v9,
							CFrame = v3[i] * cframe3
						}):Play()
						TweenService:Create(clone3.Neon, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Size = createVector(25.742, 25.742, 25.742) * v9,
							CFrame = v3[i] * cframe3
						}):Play()
						local sound3 = PeoUtils.CreateSound({
							RollOffMaxDistance = 500,
							RollOffMinDistance = 10,
							RollOffMode = Enum.RollOffMode.InverseTapered,
							SoundId = "rbxassetid://7000629559",
							Volume = 0.5
						})
						_G.PU:Dust(sound3, 3)
						sound3.Parent = clone3.Neon
						sound3:Play()
						local v11 = i
						local v14 = math.random(35, 50) / 25
						spawn(function()
							coroutine.wrap(function()
								wait(0.95)

								if (v3[v11].p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 250 then
									_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
									local clone4 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
									clone4.Parent = game.Lighting
									_G.PU:Dust(clone4, 3)
									TweenService:Create(
										clone4,
										TweenInfo.new(
											0.15,
											Enum.EasingStyle.Linear,
											Enum.EasingDirection.InOut,
											0,
											true,
											0
										),
										{
											TintColor = Color3.fromRGB(170, 0, 0)
										}
									):Play()
								end

								local clone4 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
								clone4.Rock.Size = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 15.9),
									NumberSequenceKeypoint.new(0.264, 18.32, 18.32),
									NumberSequenceKeypoint.new(1, 0)
								})
								clone4.Rock.Speed = NumberRange.new(112.5, 162.5)
								clone4.Circle.Size = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(1, 150)
								})
								clone4.CFrame = v3[v11]
								clone4.Parent = workspace.Effects
								clone4.Rock:Emit(5)
								clone4.Circle:Emit(1)
								_G.PU:Dust(clone4, 5)
								local part = Instance.new("Part")
								part.Shape = "Ball"
								part.Material = "Neon"
								part.CastShadow = false
								part.Anchored = true
								part.CanCollide = false
								part.Color = Color3.fromRGB(255, 255, 0)
								part.Size = Vector3.new()
								part.CFrame = v3[v11]
								part.Parent = workspace.Effects
								TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
									Size = createVector(150, 150, 150),
									Transparency = 1,
									Color = Color3.fromRGB(255, 88, 88)
								}):Play()
								_G.PU:Dust(part, 0.5)
								local sound4 = PeoUtils.CreateSound({
									RollOffMaxDistance = 500,
									RollOffMinDistance = 10,
									RollOffMode = Enum.RollOffMode.InverseTapered,
									SoundId = "rbxassetid://8982470659",
									Volume = 2
								})
								_G.PU:Dust(sound4, 4)
								sound4.Parent = clone3.Neon
								sound4:Play()
								spawn(function()
									local cframe4 = CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									)
									TweenService:Create(clone3.Lava, TweenInfo.new(4, Enum.EasingStyle.Linear), {
										Size = createVector(26.158, 26.158, 26.158) * v9,
										CFrame = clone3.Lava.CFrame * cframe4
									}):Play()
									TweenService:Create(clone3.Neon, TweenInfo.new(4, Enum.EasingStyle.Linear), {
										Size = createVector(25.742, 25.742, 25.742) * v9,
										CFrame = clone3.Neon.CFrame * cframe4
									}):Play()
									local raycastParams = RaycastParams.new()
									raycastParams.FilterType = Enum.RaycastFilterType.Include
									raycastParams.FilterDescendantsInstances = { workspace.Island }
									local raycastResult = workspace:Raycast(v3[v11].p, createVector(0, -25, 0))
									local position = v3[v11].p + createVector(0, -25, 0)
									local instance, normal

									if raycastResult then
										instance = raycastResult.Instance
										position = raycastResult.Position
										normal = raycastResult.Normal
										local material = instance.Material
									end

									if instance then
										local clone5 = ReplicatedStorage.Chest.FruitEffect.Magma.Crack:Clone()
										clone5.Dark.Transparency = 0
										clone5.Neon.Transparency = 0
										clone5.Specs.Size = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(0.199, 5, 5),
											NumberSequenceKeypoint.new(1, 0)
										})
										clone5.Attachment.shard.Size = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(0.201, 35, 35),
											NumberSequenceKeypoint.new(1, 0)
										})
										clone5.Specs.Speed = NumberRange.new(0, 400)
										clone5.Attachment.shard.Speed = NumberRange.new(25, 400)
										clone5.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
											1.5707963267948966,
											0,
											0
										) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
											0,
											-1,
											0
										)
										clone5.Parent = workspace.Effects
										clone5.Attachment.shard:Emit(10)
										clone5.Specs:Emit(25)
										_G.PU:Dust(clone5, 2.5)
										TweenService:Create(clone5, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
											Size = createVector(100, 0, 100)
										}):Play()
										spawn(function()
											wait(v14)

											if clone5:FindFirstChild("Neon") then
												TweenService:Create(clone5.Neon, TweenInfo.new(0.25), {
													Transparency = 1
												}):Play()
											end

											if clone5:FindFirstChild("Dark") then
												TweenService:Create(clone5.Dark, TweenInfo.new(0.25), {
													Transparency = 1
												}):Play()
											end
										end)
									end
								end)
							end)()
							spawn(function()
								wait(2)
								clone3.Neon.Sm.Enabled = false
							end)
							spawn(function()
								wait(v14 + 1.5)

								if clone3 then
									if clone3:FindFirstChild("Lava") then
										TweenService:Create(clone3.Lava, TweenInfo.new(0.5), {
											Size = Vector3.new(),
											CFrame = clone3.Lava.CFrame * cframe3
										}):Play()
									end

									if clone3:FindFirstChild("Neon") then
										TweenService:Create(clone3.Neon, TweenInfo.new(0.5), {
											Size = Vector3.new(),
											CFrame = clone3.Neon.CFrame * cframe3
										}):Play()
									end
								end
							end)
						end)
						wait(0.05)
					end
				end)()
			end

			if v5 and clone.Neon.Position.Y < -2.35 and v7 >= 45 then
				v5 = false
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
				clone2.Aura.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.144, 7.5600000000000005),
					NumberSequenceKeypoint.new(0.352, 52.8, 16.05),
					NumberSequenceKeypoint.new(0.836, 3.7800000000000002),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone2.Aura.Speed = NumberRange.new(600, 1500)
				clone2.Aura.Acceleration = createVector(0, 14250, 0)
				clone2.CFrame = CFrame.new(clone.Neon.Position)
				clone2.Parent = workspace.Effects
				clone2.Aura:Emit(15)
				_G.PU:Dust(clone2, 1)
				local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid1:Clone()
				clone3:SetPrimaryPartCFrame(CFrame.new(clone.Neon.Position.X, -3.35, clone.Neon.Position.Z))
				clone3.Neon.CanCollide = true
				clone3.Lava.CanCollide = true
				clone3.Parent = workspace.Effects
				clone3.Neon.CollisionGroup = "TouchEffect"
				clone3.Lava.CollisionGroup = "TouchEffect"
				_G.PU:Dust(clone3, 10)
				TweenService:Create(clone3.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(141.246, 14.125, 141.246)
				}):Play()
				TweenService:Create(clone3.Lava, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(145.614, 14.561, 145.614)
				}):Play()
				TweenService:Create(clone3.Lava, TweenInfo.new(10, Enum.EasingStyle.Linear), {
					CFrame = clone3.Lava.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				}):Play()
				spawn(function()
					wait(9)

					if clone3:FindFirstChild("Neon") then
						TweenService:Create(clone3.Neon, TweenInfo.new(0.5), {
							Size = clone3.Neon.Size / 2,
							Transparency = 1
						}):Play()
					end

					if clone3:FindFirstChild("Lava") then
						TweenService:Create(clone3.Lava, TweenInfo.new(0.5), {
							Size = clone3.Lava.Size / 2,
							Transparency = 1
						}):Play()
					end
				end)
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8982470659",
					Volume = 2
				})
				_G.PU:Dust(sound3, 4)
				sound3.Parent = clone.Neon
				sound3:Play()
				clone.Neon.Transparency = 1
				clone.Out.Transparency = 1
			end
		end)
		clone:Destroy()
	end)
end

function Magma_E_Loop(player, _, list, _)
	local v2, v3 = unpack(list)
	local part = Instance.new("Part")
	part.Shape = "Ball"
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Size = createVector(75, 75, 75)
	part.Color = Color3.fromRGB(170, 0, 0)
	part.CFrame = v3.CFrame
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1)
	TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(0, 0, 0)
	}):Play()
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
	clone.Aura.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.144, 3.024),
		NumberSequenceKeypoint.new(0.352, 21.12, 6.42),
		NumberSequenceKeypoint.new(0.836, 1.512),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Aura.Speed = NumberRange.new(240, 600)
	clone.Aura.Acceleration = createVector(0, 5700, 0)
	clone.CFrame = CFrame.new(v3.Position)
	clone.Parent = workspace.Effects
	clone.Aura:Emit(15)
	_G.PU:Dust(clone, 1)
	spawn(function()
		if (v3.CFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
			clone2.Parent = game.Lighting
			_G.PU:Dust(clone2, 3)
			TweenService:Create(
				clone2,
				TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
				{
					TintColor = Color3.fromRGB(170, 0, 0),
					Brightness = 0.5,
					Contrast = 1
				}
			):Play()
		end
	end)
	spawn(function()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.075
		}, function()
			if not v2:IsDescendantOf(player.Character) then
				return true
			end

			local cFrame = v2.CFrame
			local cframe = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v4 = math.random(100, 200) / 150
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
			clone2.Lava.Size = createVector(10.158, 10.158, 10.158)
			clone2.Neon.Size = createVector(9.997, 9.997, 9.997)
			clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(math.random(-5, 5), math.random(-5, 5), math.random(-10, 0)) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			))
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2.Lava, TweenInfo.new(0.375), {
				Size = createVector(26.158, 26.158, 26.158) * v4,
				CFrame = clone2.Lava.CFrame * cframe
			}):Play()
			TweenService:Create(clone2.Neon, TweenInfo.new(0.375), {
				Size = createVector(25.742, 25.742, 25.742) * v4,
				CFrame = clone2.Neon.CFrame * cframe
			}):Play()
			spawn(function()
				wait(math.random(35, 50) / 200)

				if clone2:FindFirstChild("Lava") then
					TweenService:Create(clone2.Lava, TweenInfo.new(0.5), {
						Size = Vector3.new(),
						CFrame = clone2.Lava.CFrame * cframe
					}):Play()
				end

				if clone2:FindFirstChild("Neon") then
					TweenService:Create(clone2.Neon, TweenInfo.new(0.5), {
						Size = Vector3.new(),
						CFrame = clone2.Neon.CFrame * cframe
					}):Play()
				end
			end)
		end)
	end)
end

function Magma_E_Awake_Ex(_, cFrame, _, _)
	spawn(function()
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Material = "Neon"
		part.CastShadow = false
		part.Anchored = true
		part.CanCollide = false
		part.Color = Color3.fromRGB(255, 255, 0)
		part.Size = Vector3.new()
		part.CFrame = cFrame
		part.Parent = workspace.Effects
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
			Size = createVector(150, 150, 150),
			Transparency = 1,
			Color = Color3.fromRGB(255, 88, 88)
		}):Play()
		_G.PU:Dust(part, 0.5)
		local clone = ReplicatedStorage.Chest.FruitEffect.Magma.ParticleMag:Clone()
		clone.CFrame = cFrame
		clone.Specs.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.2, 6.25, 6.25),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Specs.Speed = NumberRange.new(0, 500)
		clone.Size = createVector(50, 1, 50)
		clone.Parent = workspace.Effects
		clone.Specs:Emit(30)
		_G.PU:Dust(clone, 3)
		spawn(function()
			PeodizService.ForLoop({
				Step = 5
			}, function(_)
				local vector2 = Vector3.new(math.random(-90, 90), math.random(100, 200), math.random(-90, 90))
				local v2 = math.random(15, 50)
				math.random(100, 150)
				local v3 = cFrame * CFrame.new(math.random(-15, 15), 0, math.random(-15, 15)) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid:Clone()
				clone2.Neon.Size = Vector3.new(v2, v2, v2)
				clone2.Lava.Size = Vector3.new(v2, v2, v2) * 1.05
				clone2.Lava.Anchored = false
				clone2.Neon.Anchored = false
				clone2.Lava.Velocity = vector2
				clone2.Neon.Velocity = vector2
				clone2:SetPrimaryPartCFrame(v3)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2.Lava, TweenInfo.new(2.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				TweenService:Create(clone2.Neon, TweenInfo.new(2.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
				_G.PU:Dust(clone2, 2.3)
			end)
		end)

		for i = 1, 2 do
			local v2 = i == 2 and 25 or 5
			local cframe = CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v3 = math.random(35, 50) / 25
			local v4 = math.random(100, 200) / 50
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaMid1:Clone()
			_G.PU:Dust(clone2, v3 + 1.5)
			clone2.Lava.Size = createVector(10.158, 10.158, 10.158)
			clone2.Neon.Size = createVector(9.997, 9.997, 9.997)
			clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(
				math.random(-v2, v2),
				math.random(-v2, v2),
				math.random(-v2, 0)
			) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			))
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8982470659",
				Volume = 3
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2.Neon
			sound:Play()
			TweenService:Create(clone2.Lava, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(26.158, 26.158, 26.158) * v4
			}):Play()
			TweenService:Create(clone2.Neon, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(25.742, 25.742, 25.742) * v4
			}):Play()
			TweenService:Create(clone2.Lava, TweenInfo.new(4), {
				CFrame = clone2.Lava.CFrame * cframe
			}):Play()
			TweenService:Create(clone2.Neon, TweenInfo.new(4), {
				CFrame = clone2.Neon.CFrame * cframe
			}):Play()
			spawn(function()
				wait(v3)

				if clone2:FindFirstChild("Lava") then
					TweenService:Create(clone2.Lava, TweenInfo.new(1.5), {
						Size = Vector3.new()
					}):Play()
				end

				if clone2:FindFirstChild("Neon") then
					TweenService:Create(clone2.Neon, TweenInfo.new(1.5), {
						Size = Vector3.new()
					}):Play()
				end
			end)
		end
	end)
end

function Magma_Z_Sea(_, _, list, _)
	local v2 = unpack(list)
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaFloor:Clone()
	_G.PU:Dust(clone, 8)
	clone.CanCollide = true
	clone.CFrame = CFrame.new(v2.Position.X, -3.35, v2.Position.Z) * CFrame.new(0, 1, 0) * CFrame.Angles(
		0,
		6.283185307179586 * math.random(),
		0
	)
	clone.Parent = workspace.Effects
	clone.CollisionGroup = "Effect"
	TweenService:Create(clone, TweenInfo.new(0.1), {
		Size = createVector(100, 5, 100)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(10), {
		CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	spawn(function()
		wait(7.5)
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = clone.Size / 2,
			Transparency = 1
		}):Play()
	end)
	spawn(function()
		for _ = 1, 7 do
			local cFrame = CFrame.new(clone.Position) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				0
			)
			local v4 = math.random(10, 15)
			local v5 = math.random(35, 75)
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(10, 10, math.random(20, 30))
			clone2.Color = Color3.fromRGB(255, 0, 0)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6831579596",
				Volume = 3
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v4),
				CFrame = cFrame * CFrame.new(0, 0, v5)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
end

function Magma_Z_Ex(_, p, _, _)
	spawn(function()
		for _ = 1, 7 do
			local cFrame = CFrame.new(p.p) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			local v3 = math.random(10, 15)
			local v4 = math.random(35, 75)
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			_G.PU:Dust(clone, 1)
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = Vector3.new(10, 10, math.random(20, 30))
			clone.Color = Color3.fromRGB(255, 0, 0)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6831579596",
				Volume = 3
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v3),
				CFrame = cFrame * CFrame.new(0, 0, v4)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end)
		end
	end)
end

function Magma_X(_, p, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.SandFloor:Clone()
	clone.BrickColor = BrickColor.new("Really red")
	clone.Material = "Neon"
	clone.CFrame = p * CFrame.new(0, -3, 0)
	clone.Parent = workspace.Effects
	clone.Orientation = createVector(0, 0, 90)
	_G.PU:Dust(clone, 3)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9115978218",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	spawn(function()
		for _ = 1, 3 do
			wait(0.1)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
			clone2.BrickColor = BrickColor.new("Really red")
			clone2.Material = "Neon"
			clone2.Parent = workspace.Effects
			clone2.CFrame = p * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(clone2, TweenInfo.new(0.5), {
				Size = createVector(250, 250, 20),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.6)
		end
	end)
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(1, 150, 150)
	}):Play()
	delay(0.5, function()
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = createVector(1, 75, 75),
			Transparency = 1
		}):Play()
	end)
end

function Magma_C(_, p, _, _)
	if (p.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
	end

	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaFloor:Clone()
	_G.PU:Dust(clone, 1.5)
	clone.CFrame = p * CFrame.new(0, 1, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6848931356",
		Volume = 5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	TweenService:Create(clone, TweenInfo.new(0.1), {
		Size = createVector(100, 5, 100)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(10), {
		CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	spawn(function()
		wait(1)
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = clone.Size / 2,
			Transparency = 1
		}):Play()
	end)
	spawn(function()
		for _ = 1, 7 do
			local cFrame = CFrame.new(clone.Position) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				0
			)
			local v3 = math.random(10, 15)
			local v4 = math.random(35, 75)
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(10, 10, math.random(20, 30))
			clone2.Color = Color3.fromRGB(255, 0, 0)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6831579596",
				Volume = 3
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, v3),
				CFrame = cFrame * CFrame.new(0, 0, v4)
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
end

function Magma_V(_, _, list, _)
	local _, v2, v3, v4, _, v5 = unpack(list)
	local clone = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaBall:Clone()
	_G.PU:Dust(clone, 2)
	clone.Size = createVector(15, 15, 15)
	clone.CFrame = v5 * CFrame.new(0, 0, -3)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://4991371601",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone2.CFrame = v5 * CFrame.new(0, -5, 0)
	clone2.Color = Color3.fromRGB(255, 0, 0)
	clone2.Parent = workspace.Effects
	local v6 = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.Inverse,
		SoundId = "rbxassetid://6848896213",
		Volume = 1
	}
	local sound2 = PeoUtils.CreateSound(v6)
	_G.PU:Dust(sound2, 1)
	sound2.Parent = clone2
	sound2:Play()
	_G.PU:Dust(clone2, 1)
	TweenService:Create(clone2, TweenInfo.new(0.5), {
		Size = createVector(50, 1, 50),
		Transparency = 1
	}):Play()
	spawn(function()
		wait(0.75)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Size = Vector3.new(15, 15, math.random(25, 35))
		}):Play()
	end)
	spawn(function()
		local v7 = true
		PeodizService.ForLoop({
			Step = 100
		}, function(p)
			local v8 = math.floor(100 * p)
			local cframe = CFrame.new(0, math.sin(3.141592653589793 * p) * 250, -v8 * v3)
			clone.CFrame = CFrame.new((v4 * cframe).p, clone.Position) * CFrame.Angles(0, 3.141592653589793, 0)

			if v7 and clone.Position.Y < -3.35 then
				v7 = false
				local clone3 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaBall:Clone()
				clone3.CanCollide = true
				clone3.CFrame = CFrame.new(clone.Position.X, -3.35, clone.Position.Z) * CFrame.new(0, 1, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone3.Parent = workspace.Effects
				clone3.CollisionGroup = "Effect"
				_G.PU:Dust(clone3, 8)
				TweenService:Create(clone3, TweenInfo.new(0.1), {
					Size = createVector(25, 3, 25) * math.random(20, 30) / 10
				}):Play()
				TweenService:Create(clone3, TweenInfo.new(10), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793 * math.random(), 0)
				}):Play()
				spawn(function()
					wait(7.5)
					TweenService:Create(clone3, TweenInfo.new(0.5), {
						Size = clone3.Size / 2,
						Transparency = 1
					}):Play()
				end)
				clone.Transparency = 1
			end
		end)
		clone.Transparency = 1
		local cframe = CFrame.new(v2.p)
		spawn(function()
			if (cframe.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
				_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			end

			local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone3.CFrame = CFrame.new(cframe.p) * CFrame.Angles(0, 0, 3.141592653589793)
			clone3.Color = Color3.fromRGB(255, 0, 0)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 0.25)
			TweenService:Create(clone3, TweenInfo.new(0.25), {
				Size = createVector(125, 5, 125),
				Transparency = 1
			}):Play()
			PeodizService.ForLoop({
				Step = 2
			}, function(_)
				local clone4 = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaBall:Clone()
				_G.PU:Dust(clone4, 1.65)
				clone4.Size = createVector(25, 25, 25)
				clone4.CFrame = cframe * CFrame.new(0, 0, math.random(1, 15)) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone4.Parent = workspace.Effects
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6848896213",
					Volume = 1
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = clone4
				sound3:Play()
				TweenService:Create(clone4, TweenInfo.new(0.75), {
					Size = createVector(35, 35, 35) * math.random(100, 150) / 100,
					CFrame = clone4.CFrame * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
				}):Play()
				spawn(function()
					wait(0.5)
					TweenService:Create(clone4, TweenInfo.new(0.5), {
						Size = Vector3.new()
					}):Play()
				end)
			end)
		end)
	end)
end

function Love_Z(character, cFrame, _, _)
	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		local cFrame2 = cFrame

		for i = 1, 12 do
			local v3 = i
			coroutine.wrap(function()
				local v4 = cFrame2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

				for i2 = 1, 5 do
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Pink")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = Vector3.new(v3 / 8 + 1 - i2 / 2.2, v3 / 8 + 1 - i2 / 2.2, v3 * 1.5 + 16)
					part.CFrame = v4 * CFrame.Angles(
						math.random() * 7,
						math.random() * 3.141592653589793 * 2,
						math.random() * 7
					) * CFrame.new(0, 0, -part.Size.z / 2)
					part.Parent = workspace.Effects
					v4 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
					_G.PU:Dust(part, 0.025)
					wait(0.025)
				end
			end)()
		end
	end)
	local model = Instance.new("Model")
	model.Parent = workspace.Effects
	_G.PU:Dust(model, 1)
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Heart:Clone()
	clone.Size = createVector(2, 2, 1)
	clone.CFrame = cFrame
	clone.Parent = model
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
		CFrame = clone.CFrame * CFrame.new(0, 0, -180)
	}):Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.Shockwave:Clone()
	clone2.Transparency = 0.7
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.Size = createVector(34, 0, 26)
	clone2.CFrame = cFrame * CFrame.new(0, 0, -90) * CFrame.Angles(
		1.5707963267948966,
		6.283185307179586 * math.random(),
		0
	)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 0.35)
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		Size = createVector(34, 180, 26),
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.5), {
		CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Love.LoveDecal:Clone()
	_G.PU:Dust(clone3, 0.5)
	clone3.Decal1.Texture = "rbxassetid://7268984406"
	clone3.Decal2.Texture = "rbxassetid://7268984406"
	clone3.Decal1.Transparency = -1
	clone3.Decal2.Transparency = -1
	clone3.CFrame = cFrame * CFrame.new(0, 0, -2.5)
	clone3.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7295442562",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(25, 25, 0)
	}):Play()
	TweenService:Create(clone3.Decal1, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	TweenService:Create(clone3.Decal2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Transparency = 1
	}):Play()
	spawn(function()
		for i = 1, 5 do
			wait(0.025)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Love.ShockwaveRing:Clone()
			clone4.Color = Color3.fromRGB(185, 110, 160)
			clone4.Size = Vector3.new()
			clone4.Transparency = -1
			clone4.CFrame = cFrame * CFrame.new(0, 0, i * -32.25806451612903) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				CFrame = clone4.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0),
				Size = createVector(12, 4, 12),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone4, 0.35)
		end
	end)
	spawn(function()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.25), {
			Transparency = 1
		}):Play()
		wait(0.1)

		if clone:FindFirstChild("Trail") then
			clone.Trail.Enabled = false
		end
	end)
	_G.PU:Dust(clone, 1)
	local clone4 = ReplicatedStorage.Chest.FruitEffect.Love.Hearts:Clone()
	_G.PU:Dust(clone4, 1)
	clone4.Parent = character.HumanoidRootPart
	clone4:Emit(15)
end

function Love_X(character, p, p2, _)
	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		local v2 = p
		PeodizService.ForLoop({
			Step = 12,
			WaitTime = 0.05
		}, function(p3)
			local v3 = math.floor(p3 * 12)
			coroutine.wrap(function()
				local v4 = v2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
				PeodizService.ForLoop({
					Step = 5,
					WaitTime = 0.025
				}, function(_)
					local v5 = math.floor(p3 * 5)
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Pink")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = Vector3.new(v3 / 8 + 1 - v5 / 2.2, v3 / 8 + 1 - v5 / 2.2, v3 * 1.5 + 16)
					part.CFrame = v4 * CFrame.Angles(
						math.random() * 7,
						math.random() * 3.141592653589793 * 2,
						math.random() * 7
					) * CFrame.new(0, 0, -part.Size.z / 2)
					part.Parent = workspace.Effects
					v4 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
					_G.PU:Dust(part, 0.025)
				end)
			end)()
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Hearts:Clone()
	_G.PU:Dust(clone, 2.5)
	clone.Parent = character.HumanoidRootPart
	clone:Emit(15)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7318780208",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = character.HumanoidRootPart
	sound:Play()
	PeodizService.ForLoop({
		Step = 10,
		WaitTime = 0.1
	}, function(_)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.LoveDecal:Clone()
		_G.PU:Dust(clone2, 0.5)
		clone2.Decal1.Texture = "rbxassetid://7268984406"
		clone2.Decal2.Texture = "rbxassetid://7268984406"
		clone2.CFrame = CFrame.new(character.HumanoidRootPart.Position, p2)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Size = createVector(70, 70, 0.05),
			CFrame = clone2.CFrame * CFrame.new(0, 0, -200)
		}):Play()
		TweenService:Create(clone2.Decal1, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone2.Decal2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Transparency = 1
		}):Play()
	end)
end

function Love_C(character, p, _, _)
	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		local v2 = p
		PeodizService.ForLoop({
			Step = 12
		}, function(p2)
			task.spawn(function()
				local v3 = v2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
				local v4 = p2 * 12

				for i = 1, 5 do
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Pink")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = Vector3.new(1 + v4 / 8 - i / 2.2, 1 + v4 / 8 - i / 2.2, 16 + v4 * 1.5)
					part.CFrame = v3 * CFrame.Angles(
						math.random() * 7,
						math.random() * 3.141592653589793 * 2,
						math.random() * 7
					) * CFrame.new(0, 0, -part.Size.z / 2)
					part.Parent = workspace.Effects
					v3 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
					_G.PU:Dust(part, 0.025)
					wait(0.025)
				end
			end)
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Hearts:Clone()
	_G.PU:Dust(clone, 2)
	clone.Parent = character.HumanoidRootPart
	clone:Emit(15)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7318741205",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = character.HumanoidRootPart
	sound:Play()
	local count = 0
	PeodizService.ForLoop({
		Step = 80
	}, function(_)
		count += 1
		local model = Instance.new("Model")
		model.Parent = workspace.Effects
		_G.PU:Dust(model, 2)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Love.HeartArrow:Clone()
		_G.PU:Dust(clone2, 2)
		clone2.Size = createVector(0.722, 10.672, 1.648)
		clone2.CFrame = p * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(
			math.random(-7, 7),
			math.random(-7, 7),
			2
		) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			6.283185307179586 * math.random(),
			(math.rad((math.random(-182, -177))))
		)
		clone2.Parent = model
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7318913665",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			CFrame = clone2.CFrame * CFrame.new(0, -185, 0)
		}):Play()
		spawn(function()
			wait(0.3)
			TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
				Transparency = 1
			}):Play()
			wait(0.4)

			if clone2:FindFirstChild("Trail") then
				clone2.Trail.Enabled = false
			end
		end)
	end)
end

function darklegv(player, _, _, _)
	PeodizService.ForLoop({
		Step = 20,
		WaitTime = 0.01
	}, function(p)
		local v2 = math.floor(p * 20)
		local clone = ReplicatedStorage.Chest.Etc.DarkLegSlash:Clone()
		clone.CFrame = player.Character.LowerTorso.CFrame * CFrame.new(0, math.random(-5, 5), -5)
		clone.Size = createVector(5, 5, 5)
		clone.BrickColor = BrickColor.new("Neon orange")
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = createVector(25, 25, 25),
			Transparency = 1
		}):Play()

		if v2 == 15 then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://528780907"
			sound.Volume = 3
			sound.MaxDistance = 300
			sound.Parent = player.Character.HumanoidRootPart
			sound:Play()
			_G.PU:Dust(sound, 1.5)
		end

		_G.PU:Dust(clone, 0.2)
	end)
end

function Love_V(character, p, _, _)
	if character:IsA("Player") then
		character = character.Character
	end

	local humanoidRootPart = character.HumanoidRootPart
	spawn(function()
		local v2 = p
		PeodizService.ForLoop({
			Step = 12,
			WaitTime = 0.05
		}, function(p2)
			local v3 = math.floor(p2 * 12)
			coroutine.wrap(function()
				local v4 = v2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
				PeodizService.ForLoop({
					Step = 5,
					WaitTime = 0.025
				}, function(_)
					local v5 = math.floor(p2 * 5)
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Pink")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = Vector3.new(v3 / 8 + 1 - v5 / 2.2, v3 / 8 + 1 - v5 / 2.2, v3 * 1.5 + 16)
					part.CFrame = v4 * CFrame.Angles(
						math.random() * 7,
						math.random() * 3.141592653589793 * 2,
						math.random() * 7
					) * CFrame.new(0, 0, -part.Size.z / 2)
					part.Parent = workspace.Effects
					v4 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
					_G.PU:Dust(part, 0.025)
				end)
			end)()
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Love.Hearts:Clone()
	clone.Parent = character.HumanoidRootPart
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://4999700071",
		Volume = 0.3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = character.HumanoidRootPart
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 750,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5545158749",
		Volume = 1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = character.HumanoidRootPart
	sound2:Play()
	clone.Enabled = true
	delay(1.5, function()
		clone.Enabled = false
		_G.PU:Dust(clone, 1)
	end)
	PeodizService.ForLoop({
		Step = 60,
		WaitTime = 0.035
	}, function(_)
		local cFrame = humanoidRootPart.CFrame
		local v2 = math.random(25, 40)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.NightBlade.GreenSlash:Clone()
		clone2.Decal.Transparency = -1
		clone2.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(2550, 255, 2550) or Color3.fromRGB(
			2550,
			170,
			2550
		)
		clone2.Mesh.Scale = Vector3.new(v2, 0.125, v2)
		clone2.CFrame = cFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
			0,
			math.random(-1, v2 / 3),
			math.random(-v2 / 5, v2 / 5)
		)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 0.5)
	end)
end

function Buddha_Z(_, cFrame, _, _)
	spawn(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Buddha.ImpactParticle:Clone()
		clone.CFrame = cFrame
		clone.Attachment.Circle.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 159)
		})
		clone.Attachment.Impact.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 250)
		})
		clone.Attachment.Specs.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1.3575),
			NumberSequenceKeypoint.new(0.48, 20, 8.15),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment.Specs.Speed = NumberRange.new(200, 250)
		clone.Attachment.Burst.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 170, 88)
		})
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)
		clone.Attachment.Circle:Emit(1)
		clone.Attachment.Impact:Emit(1)
		clone.Attachment.Specs:Emit(25)
		clone.Attachment.Burst:Emit(5)
		spawn(function()
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Size = Vector3.new()
			part.Transparency = -1
			part.Material = Enum.Material.Neon
			part.CanCollide = false
			part.Anchored = true
			part.CastShadow = false
			part.Color = Color3.fromRGB(255, 255, 0)
			part.CFrame = cFrame
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			TweenService:Create(
				part,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
				{
					Size = createVector(150, 150, 150)
				}
			):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()
			end)
			local part2 = Instance.new("Part")
			part2.Shape = Enum.PartType.Ball
			part2.Size = Vector3.new()
			part2.Transparency = -1
			part2.Material = Enum.Material.ForceField
			part2.CanCollide = false
			part2.Anchored = true
			part2.CastShadow = false
			part2.Color = Color3.fromRGB(255, 255, 0)
			part2.CFrame = cFrame
			part2.Parent = workspace.Effects
			_G.PU:Dust(part2, 1)
			TweenService:Create(part2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(250, 250, 250),
				Transparency = 1
			}):Play()
		end)
		spawn(function()
			for _ = 1, 20 do
				local v2 = cFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone2.CastShadow = false
				clone2.Transparency = -1
				clone2.Size = Vector3.new(15, 15, math.random(25, 35))
				clone2.Color = Color3.fromRGB(255, 255, 0)
				clone2.CFrame = v2 * CFrame.Angles(0, 0, 15)
				clone2.Parent = workspace.Effects
				local v3 = math.random(150, 200)
				TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0, 0, clone2.Size.Z),
					CFrame = v2 * CFrame.new(0, 0, v3)
				}):Play()
				_G.PU:Dust(clone2, 0.3)
			end
		end)
		local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
		clone2.Transparency = 0.02
		clone2.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 10, 0)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(300, 25, 300),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		_G.PU:Dust(clone2, 0.5)
	end)
end

function Mammoth_Transform(player, cFrame, list, _)
	local v2, v3 = unpack(list)

	if v2 then
		local clone = v2:Clone()
		clone.Volume = 2
		clone.Parent = player.Character.HumanoidRootPart
		clone:Play()
		_G.PU:Dust(clone, 3)
	end

	if v3 then
		local clone = v3:Clone()
		clone.Parent = player.Character.HumanoidRootPart
		clone:Play()
		_G.PU:Dust(clone, 3)
	end

	PeodizService.ForLoop({
		Step = 20
	}, function(_)
		spawn(function()
			local v4 = math.random(5, 25)
			local cFrame2 = CFrame.new(cFrame.p) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				0
			)
			math.random(75, 125)
			local v6 = math.random(100, 150)
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Size = Vector3.new(v4, v4, v4)
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = cFrame2 * CFrame.new(0, 0, v6)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = cFrame2
			}):Play()
			spawn(function()
				wait(0.15)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = clone.Size * 3,
					Transparency = 1
				}):Play()
			end)
			_G.PU:Dust(clone, 1)
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
	clone.Attachment.Ball.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 11.899999999999999, 2.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Attachment.Ball.Speed = NumberRange.new(187.5, 250)
	clone.Attachment.Ball.Lifetime = NumberRange.new(0.5, 1.5)
	clone.Attachment.Ball.Texture = "rbxassetid://1084970835"
	clone.Attachment.Ball.LockedToPart = false
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	clone.Attachment.Ball:Emit(20)
	_G.PU:Dust(clone, 3)
end

function Mammoth_Z(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			spawn(function()
				local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone.Enabled = true
				clone.Parent = workspace.CurrentCamera
				clone.Size = 0
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(
					clone,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
					{
						Size = 10
					}
				):Play()
			end)
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
		clone.CFrame = cFrame2
		clone.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 100)
		})
		clone.Attachment2.Rocks.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 3.25, 1.79),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
		clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
		clone.Attachment2.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 75)
		})
		clone.Attachment2.Sm.Lifetime = NumberRange.new(2.5)
		clone.Parent = workspace.Effects
		clone.Attachment.Ring:Emit(1)
		clone.Attachment2.Rocks:Emit(15)
		clone.Attachment2.Sm:Emit(15)
		clone.Attachment2.Ring:Emit(3)
		_G.PU:Dust(clone, 3)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8032440223",
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Mammoth.Ring:Clone()
		clone2.Size = Vector3.new()
		clone2.Transparency = -1
		clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 5, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(130, 130, 25),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
		}):Play()
		local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
		clone3.Size = Vector3.new()
		clone3.Transparency = -1
		clone3.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, 0, 3.141592653589793)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1)
		TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Size = createVector(125, 5, 125),
			Transparency = 1,
			CFrame = clone3.CFrame * CFrame.new(0, -50, 0)
		}):Play()

		for _ = 1, 20 do
			local v3 = cFrame2 * CFrame.new(math.random(-35, 35), 0, math.random(-35, 35))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(
				v3.p + createVector(0, 10, 0),
				createVector(0, -50, 0),
				raycastParams
			)
			local position = v3.p + createVector(0, 10, 0) + createVector(0, -50, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if not instance then
				continue
			end

			local part = Instance.new("Part")
			part.CanCollide = false
			part.Anchored = true
			part.CastShadow = false
			part.Transparency = -1
			part.Size = Vector3.new()
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 2)
			TweenService:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(math.random(5, 15), math.random(5, 15), math.random(5, 15))
			}):Play()
			spawn(function()
				wait(1)
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					Position = part.Position + createVector(0, -1, 0),
					Transparency = 1
				}):Play()
			end)
		end
	end)
end

function Mammoth_Z_Full(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			spawn(function()
				local clone = ReplicatedStorage.Chest.Etc.Blur:Clone()
				clone.Enabled = true
				clone.Parent = workspace.CurrentCamera
				clone.Size = 0
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(
					clone,
					TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
					{
						Size = 10
					}
				):Play()
			end)
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
		clone.CFrame = cFrame2
		clone.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 150)
		})
		clone.Attachment2.Rocks.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 3.25, 1.79),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
		clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
		clone.Attachment2.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 75)
		})
		clone.Parent = workspace.Effects
		clone.Attachment.Ring:Emit(1)
		clone.Attachment2.Rocks:Emit(15)
		clone.Attachment2.Sm:Emit(15)
		clone.Attachment2.Ring:Emit(3)
		_G.PU:Dust(clone, 1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8032440223",
			Volume = 2
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Mammoth.Ring:Clone()
		clone2.Size = Vector3.new()
		clone2.Transparency = -1
		clone2.CFrame = CFrame.new(cFrame2.p) * CFrame.new(0, 5, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1)
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(162.5, 162.5, 31.25),
			Transparency = 1,
			CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
		}):Play()
		local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
		clone3.Size = Vector3.new()
		clone3.Transparency = -1
		clone3.CFrame = CFrame.new(cFrame2.p) * CFrame.Angles(0, 0, 3.141592653589793)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1)
		TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Size = createVector(156.25, 6.25, 156.25),
			Transparency = 1,
			CFrame = clone3.CFrame * CFrame.new(0, -62.5, 0)
		}):Play()

		for _ = 1, 20 do
			local v3 = cFrame2 * CFrame.new(math.random(-50, 50), 0, math.random(-50, 50))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(
				v3.p + createVector(0, 10, 0),
				createVector(0, -50, 0),
				raycastParams
			)
			local position = v3.p + createVector(0, 10, 0) + createVector(0, -50, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if not instance then
				continue
			end

			local part = Instance.new("Part")
			part.CanCollide = false
			part.Anchored = true
			part.CastShadow = false
			part.Transparency = -1
			part.Size = Vector3.new()
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.CFrame = CFrame.new(position) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 2)
			TweenService:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(math.random(10, 20), math.random(10, 20), math.random(10, 20))
			}):Play()
			spawn(function()
				wait(1)
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					Position = part.Position + createVector(0, -1, 0),
					Transparency = 1
				}):Play()
			end)
		end
	end)
end

function Mammoth_X_Rings(character, _, list, _)
	local v2, v3 = unpack(list)

	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		if (character.UpperTorso.Position - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 100 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local v4 = true
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not (v2:IsDescendantOf(character) and v4) then
					return true
				end

				if v2.Position.Y <= -3.35 then
					v4 = false
					local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
					clone.Orientation = Vector3.new()
					clone.CFrame = CFrame.new(v2.Position)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 2)
					clone.Splash:Emit(25)
				end
			end)
		end)
		tick()
		PeodizService.HeartbeatWait({
			Time = 10,
			WaitTime = 0.2
		}, function()
			if not v2:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
				return true
			end

			local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = CFrame.new(v2.Position, v3.p) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = createVector(60, 2, 60),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 0.5)
		end)
	end)
end

function Mammoth_X_Ex(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
		clone.CFrame = cFrame2
		clone.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 100)
		})
		clone.Attachment2.Rocks.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
		clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
		clone.Attachment2.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 75)
		})
		clone.Attachment2.Sm.Lifetime = NumberRange.new(3)
		clone.Attachment2.Rocks.Lifetime = NumberRange.new(1, 1.5)
		clone.Parent = workspace.Effects
		clone.Attachment.Ring:Emit(1)
		clone.Attachment2.Rocks:Emit(10)
		clone.Attachment2.Sm:Emit(15)
		_G.PU:Dust(clone, 4)
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Transparency = -1
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new()
		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(255, 255, 255)
		part.CastShadow = false
		part.CFrame = cFrame2
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(125, 125, 125),
			Transparency = 1
		}):Play()
		local clone2 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
		clone2.CFrame = cFrame2
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://165970126",
			Volume = 1
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone2
		sound:Play()
		spawn(function()
			for i = 1, 2 do
				local v4 = i
				local cFrame3 = cFrame2 * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
				spawn(function()
					local clone3 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
					clone3.Transparency = -1
					clone3.Color = Color3.fromRGB(75, 75, 75)

					if v4 == 2 then
						clone3.Color = Color3.fromRGB(70, 70, 70)
					end

					clone3.CFrame = cFrame3
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 2)
					TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = createVector(100, 100, 100)
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(2, Enum.EasingStyle.Quad), {
						CFrame = clone3.CFrame * CFrame.Angles(
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random()
						),
						Transparency = 1
					}):Play()
					wait(0.25)
					TweenService:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new()
					}):Play()
				end)
			end
		end)
	end)
end

function Mammoth_X_Full(_, p, _, _)
	spawn(function()
		local cFrame = p
		spawn(function()
			PeodizService.ForLoop({
				Step = 15
			}, function(p2)
				math.floor(p2 * 15)
				spawn(function()
					local v3 = math.random(5, 25)
					local cFrame2 = CFrame.new(cFrame.p) * CFrame.new(0, 100, 0) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(math.rad((math.random(-90, 90))), math.rad((math.random(-90, 90))), 0)
					math.random(75, 125)
					local v5 = math.random(150, 200)
					local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.MammothRock:Clone()
					clone.Anchored = true
					clone.CastShadow = false
					clone.Transparency = -1
					clone.Size = Vector3.new(v3, v3, v3)
					clone.CFrame = cFrame2 * CFrame.new(0, 0, v5)
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						CFrame = cFrame2,
						Transparency = 1
					}):Play()
					_G.PU:Dust(clone, 1)
				end)
			end)
		end)
		local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.MammothRock:Clone()
		clone.Anchored = true
		clone.Transparency = -1
		clone.Size = Vector3.new()
		clone.CFrame = cFrame * CFrame.new(0, 100, 0) * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		)
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
			Size = createVector(100, 100, 100)
		}):Play()
		_G.PU:Dust(clone, 3)
		local v3 = {
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://8436121409",
			Volume = 2.5
		}
		local sound = PeoUtils.CreateSound(v3)
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Bari.Barrier:Clone()
		clone2.Transparency = 1
		clone2.Decal1.Transparency = 1
		clone2.Decal2.Transparency = 1
		clone2.Particle.Texture = "rbxassetid://1084970835"
		clone2.Particle.Rate = 300
		clone2.Particle.Enabled = true
		clone2.Size = createVector(50, 50, 50)
		clone2.CFrame = clone.CFrame
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 3)
		spawn(function()
			wait(0.25)
			clone2.Particle.Enabled = false
		end)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Size = createVector(50, 50, 50)
		}):Play()
		wait(0.5)
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			CFrame = cFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
		}):Play()
		spawn(function()
			wait(0.05)
			spawn(function()
				local clone3 = ReplicatedStorage.Chest.FruitEffect.BossEf.Santa.SantaParticle:Clone()
				clone3.CFrame = cFrame
				clone3.Attachment.Ring.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 100)
				})
				clone3.Attachment2.Rocks.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
				clone3.Attachment2.Position = clone3.Attachment2.Position + createVector(0, 5, 0)
				clone3.Attachment2.Sm.Lifetime = NumberRange.new(3)
				clone3.Attachment2.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.043, 50),
					NumberSequenceKeypoint.new(0.883, 50),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment2.Rocks.Lifetime = NumberRange.new(1, 1.5)
				clone3.Attachment2.Rocks.LightEmission = 1
				clone3.Attachment2.Rocks.Texture = "rbxassetid://7216848960"
				clone3.Attachment2.Rocks1.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone3.Attachment2.Rocks1.Speed = NumberRange.new(100, 150)
				clone3.Attachment2.Rocks1.Lifetime = NumberRange.new(0.5, 1)
				clone3.Attachment2.Rocks1.LightEmission = 0
				clone3.Attachment2.Impact.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				clone3.Attachment2.Impact.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 150)
				})
				clone3.Attachment2.Burst.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				clone3.Attachment2.Burst.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 102, 52.8)
				})
				clone3.Attachment2.Circle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
				clone3.Attachment2.Circle.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 105)
				})
				clone3.Parent = workspace.Effects
				clone3.Attachment2.Circle:Emit(1)
				clone3.Attachment2.Burst:Emit(5)
				clone3.Attachment2.Rocks:Emit(10)
				clone3.Attachment2.Rocks1:Emit(15)
				clone3.Attachment2.Sm:Emit(15)
				local part = Instance.new("Part")
				part.Shape = Enum.PartType.Ball
				part.Transparency = -1
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Material = Enum.Material.ForceField
				part.Color = Color3.fromRGB(255, 255, 255)
				part.CastShadow = false
				part.CFrame = cFrame
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 1)
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(125, 125, 125),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 4)
				local clone4 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
				clone4.CFrame = cFrame
				clone4.Parent = workspace.Effects
				_G.PU:Dust(clone4, 5)
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://514867425",
					Volume = 3
				})
				_G.PU:Dust(sound2, 5)
				sound2.Parent = clone4
				sound2:Play()
			end)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			clone3.Size = Vector3.new()
			clone3.Transparency = 0.1
			clone3.CFrame = cFrame
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Size = createVector(300, 30, 300),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone3, 1)
			local v4 = cFrame + createVector(0, 2, 0)

			for i = 1, 20 do
				local cframe = v4 * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(0, 0, -25)
				local _, v5, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -25, 0), raycastParams)
				local position = cframe.Position + createVector(0, -25, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.CanCollide = false
				part.CastShadow = false
				part.Anchored = true
				part.Size = createVector(1, 1, 1)
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.CFrame = CFrame.new(v4.X, position.Y, v4.Z) * CFrame.fromOrientation(0, v5, 0) * CFrame.Angles(
					0.7853981633974483,
					0,
					0
				)
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 3)
				local v6 = math.random(35, 50) / 5
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					),
					Size = Vector3.new(v6, v6, v6)
				}):Play()
				spawn(function()
					wait(1)
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Position = part.Position + createVector(0, -2, 0),
						Transparency = 1
					}):Play()
				end)
			end
		end)
		spawn(function()
			for i = 1, 2 do
				local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone3.Transparency = -1
				clone3.Size = Vector3.new()
				clone3.CFrame = cFrame * CFrame.new(0, 100 - i * 40, 0) * CFrame.Angles(0, 0, 3.141592653589793)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(75, 3, 75),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 0.25)
				wait()
			end
		end)
		wait(1)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end)
end

function Mammoth_C(p, p2, list, _)
	local v2, v3 = unpack(list)
	local magnitude = (v2.Position - v3.p).Magnitude
	local v4 = (v2.Position - v3.p).Magnitude / 5
	local cframe = CFrame.new(v2.Position, v3.p)

	if localPlayer == p then
		PeoUtils.LerpCF(v2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), v3 * CFrame.new(0, 3, 0))
	end

	task.spawn(function()
		wait(0.5)
		v2.Velocity = createVector(0, 0, 0)
		v2.RotVelocity = createVector(0, 0, 0)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
	clone.CFrame = cframe
	clone.Attachment2.Sm.Enabled = true
	clone.Attachment2.Rocks.Enabled = true
	clone.Attachment2.Sm.Rate = 100
	clone.Attachment2.Rocks.Rate = 100
	clone.Attachment2.Sm.Speed = NumberRange.new(100, 150)
	clone.Attachment2.Sm.Lifetime = NumberRange.new(1.5, 2.5)
	clone.Attachment2.Rocks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 1.625, 0.895),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Attachment2.Rocks.Speed = NumberRange.new(50, 100)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		CFrame = v3 * CFrame.new(0, 3, 0)
	}):Play()
	_G.PU:Dust(clone, 3)
	delay(0.15, function()
		clone.Attachment2.Sm.Enabled = false
		clone.Attachment2.Rocks.Enabled = false
	end)
	spawn(function()
		for _ = 1, 7 do
			math.random(1, 2)
			local cFrame = p2 * CFrame.Angles(math.rad((math.random(-45, 0))), math.rad((math.random(-45, 45))), 0)
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(8, 8, math.random(10, 20))
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			math.random(8, 16)
			local v6 = math.random(25, 75)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, clone2.Size.Z / 2),
				CFrame = cFrame * CFrame.new(0, 0, v6)
			}):Play()
			_G.PU:Dust(clone2, 0.3)
		end
	end)
	spawn(function()
		for i = 1, 5 do
			wait()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			clone2.CFrame = cframe * CFrame.new(0, 0, -v4 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Transparency = 0.1
			clone2.Size = Vector3.new()
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 0.5)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(150, 15, 150)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(1), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Mammoth.SmashParticle:Clone()
			clone3.CFrame = cframe * CFrame.new(0, 3, -v4 * i)
			clone3.Attachment.Wave1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0698, 8.35, 3.3000000000000003),
				NumberSequenceKeypoint.new(0.194, 14.950000000000001, 5.2),
				NumberSequenceKeypoint.new(1, 22.1, 8.2)
			})
			clone3.Attachment.Wave2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0705, 9.1, 3.3000000000000003),
				NumberSequenceKeypoint.new(0.194, 14.350000000000001, 5.949999999999999),
				NumberSequenceKeypoint.new(1, 19.85, 9.1)
			})
			spawn(function()
				clone3.Attachment.Wave1:Emit(1)
				wait(0.1)
				clone3.Attachment.Wave2:Emit(1)
			end)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 5)
		end
	end)
	local clone2 = ReplicatedStorage.Chest.Etc.MeshStorage.Shockwave:Clone()
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.Size = createVector(25, 25, 25)
	clone2.CFrame = p2 * CFrame.new(0, 0, -10) * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Size = clone2.Size * 2,
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {
		CFrame = clone2.CFrame * CFrame.new(0, 0, magnitude) * CFrame.Angles(0, 0, 9.42477796076938)
	}):Play()
	_G.PU:Dust(clone2, 1)
end

function Mammoth_C_Full(p, p2, list, _)
	local v2, v3 = unpack(list)
	local magnitude = (v2.Position - v3.p).Magnitude
	local v4 = (v2.Position - v3.p).Magnitude / 5
	local cframe = CFrame.new(v2.Position, v3.p)

	if localPlayer == p then
		PeoUtils.LerpCF(v2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), v3 * CFrame.new(0, 3, 0))
	end

	task.spawn(function()
		wait(0.5)
		v2.Velocity = createVector(0, 0, 0)
		v2.RotVelocity = createVector(0, 0, 0)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
	clone.CFrame = cframe
	clone.Attachment2.Sm.Enabled = true
	clone.Attachment2.Rocks.Enabled = true
	clone.Attachment2.Sm.Rate = 100
	clone.Attachment2.Rocks.Rate = 100
	clone.Attachment2.Sm.Speed = NumberRange.new(150, 200)
	clone.Attachment2.Sm.Lifetime = NumberRange.new(1.5, 2.5)
	clone.Attachment2.Rocks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 4.0625, 2.2375),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Attachment2.Rocks.Speed = NumberRange.new(50, 100)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		CFrame = v3 * CFrame.new(0, 3, 0)
	}):Play()
	_G.PU:Dust(clone, 3)
	delay(0.15, function()
		clone.Attachment2.Sm.Enabled = false
		clone.Attachment2.Rocks.Enabled = false
	end)
	spawn(function()
		for _ = 1, 7 do
			math.random(1, 2)
			local cFrame = p2 * CFrame.Angles(math.rad((math.random(-45, 0))), math.rad((math.random(-45, 45))), 0)
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Size = Vector3.new(8, 8, math.random(10, 20))
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			math.random(8, 16)
			local v6 = math.random(25, 75)
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, clone2.Size.Z / 2),
				CFrame = cFrame * CFrame.new(0, 0, v6)
			}):Play()
			_G.PU:Dust(clone2, 0.3)
		end
	end)
	spawn(function()
		for i = 1, 5 do
			wait()
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			clone2.CFrame = cframe * CFrame.new(0, 0, -v4 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Transparency = 0.1
			clone2.Size = Vector3.new()
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 0.5)
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(150, 15, 150)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(1), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Mammoth.SmashParticle:Clone()
			clone3.CFrame = cframe * CFrame.new(0, 3, -v4 * i)
			clone3.Attachment.Wave1.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0698, 20.875, 8.25),
				NumberSequenceKeypoint.new(0.194, 37.375, 13),
				NumberSequenceKeypoint.new(1, 55.25, 20.5)
			})
			clone3.Attachment.Wave2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.0705, 22.75, 8.25),
				NumberSequenceKeypoint.new(0.194, 35.875, 14.875),
				NumberSequenceKeypoint.new(1, 49.625, 22.75)
			})
			spawn(function()
				clone3.Attachment.Wave1:Emit(1)
				wait(0.1)
				clone3.Attachment.Wave2:Emit(1)
			end)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 5)
		end
	end)
	local clone2 = ReplicatedStorage.Chest.Etc.MeshStorage.Shockwave:Clone()
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.Size = createVector(25, 25, 25)
	clone2.CFrame = p2 * CFrame.new(0, 0, -10) * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Size = clone2.Size * 4,
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {
		CFrame = clone2.CFrame * CFrame.new(0, 0, magnitude) * CFrame.Angles(0, 0, 9.42477796076938)
	}):Play()
	_G.PU:Dust(clone2, 1)
end

function Santa_Snow_Ex(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame
		local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
		clone.CFrame = cFrame2
		clone.Attachment.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 100)
		})
		clone.Attachment2.Rocks.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
		clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
		clone.Attachment2.Ring.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 75)
		})
		clone.Attachment2.Sm.LightEmission = 1
		clone.Attachment2.Sm.Lifetime = NumberRange.new(3)
		clone.Attachment2.Rocks.Lifetime = NumberRange.new(1, 1.5)
		clone.Attachment2.Rocks.LightEmission = 1
		clone.Attachment2.Rocks.Texture = "rbxassetid://7535304728"
		clone.Parent = workspace.Effects
		clone.Attachment.Ring:Emit(1)
		clone.Attachment2.Rocks:Emit(30)
		clone.Attachment2.Sm:Emit(15)
		_G.PU:Dust(clone, 4)
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Transparency = -1
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new()
		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(255, 255, 255)
		part.CastShadow = false
		part.CFrame = cFrame2
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(125, 125, 125),
			Transparency = 1
		}):Play()
		local clone2 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
		clone2.CFrame = cFrame2
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://8393349995",
			Volume = 2.5
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone2
		sound:Play()
	end)
end

function Op_Z(player, _, _, _)
	local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position)
	_G.PU:Dust(clone, 1)
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(500, 0, 500),
		Transparency = 1
	}):Play()
end

function Op_X(_, cFrame, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gravity.Smoke2:Clone()
	clone.Name = "FF"
	clone.Parent = workspace.Effects
	clone.CFrame = cFrame * CFrame.new(0, -5, 0)
	_G.PU:Dust(clone, 2)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
	clone2.Parent = workspace.Effects
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone2, TweenInfo.new(0.5), {
		Size = createVector(250, 250, 20),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone2, 0.6)

	for _, emitter in pairs(clone:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(5)
		end
	end

	local part = Instance.new("Part", workspace.Effects)
	part.Size = createVector(4, 4, 4)
	part.Material = "Neon"
	part.Color = Color3.fromRGB(240, 240, 240)
	part.Anchored = true
	part.CanCollide = false
	part.Shape = Enum.PartType.Ball
	part.CFrame = cFrame * CFrame.new(0, -5, 0)
	_G.PU:Dust(part, 2)
	TweenService:Create(part, TweenInfo.new(0.75), {
		Transparency = 1,
		Size = createVector(75, 75, 75),
		Color = Color3.fromRGB(230, 100, 7)
	}):Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Gravity.ShockwaveZ:Clone()
	_G.PU:Dust(clone3, 1)
	clone3.Color = Color3.fromRGB(255, 255, 255)
	clone3.CFrame = part.CFrame
	clone3.Parent = workspace.Effects
	TweenService:Create(clone3, TweenInfo.new(0.35), {
		Size = createVector(90, 10.5, 90),
		Orientation = createVector(0, 1800, 0),
		Transparency = 1
	}):Play()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://165970126",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	spawn(function()
		local cFrame2 = cFrame
		local v3 = 45

		for _ = 1, 12 do
			local part2 = Instance.new("Part")
			part2.Anchored = true
			part2.CanCollide = false
			part2.Size = createVector(0, 0, 0)
			part2.CFrame = cFrame2
			part2.Material = "Neon"
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local v4 = (cFrame2 * CFrame.Angles(0, math.rad(v3), 0) * CFrame.new(0, 0, -30) * CFrame.Angles(
				math.rad((math.random(-75, 75))),
				math.rad((math.random(-75, 75))),
				(math.rad((math.random(-75, 75))))
			)).p + createVector(0, 5, 0)
			local raycastResult = workspace:Raycast(v4, createVector(0, -150, 0), raycastParams)
			local position = v4 + createVector(0, -150, 0)
			local instance, material

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
				local _ = raycastResult.Normal
				material = instance.Material
			end

			local v5 = math.random(7, 14)
			TweenService:Create(part2, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(cFrame2.X, position.Y, cFrame2.Z, select(4, cFrame2:components())) * CFrame.Angles(
					0,
					math.rad(v3),
					0
				) * CFrame.new(0, -1.5, -35.5) * CFrame.Angles(
					math.rad((math.random(-75, 75))),
					math.rad((math.random(-75, 75))),
					(math.rad((math.random(-75, 75))))
				),
				Size = Vector3.new(v5, v5, v5)
			}):Play()
			TweenService:Create(
				part2,
				TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 2),
				{
					Transparency = 1
				}
			):Play()
			part2.Material = material or "SmoothPlastic"

			if instance then
				part2.BrickColor = instance.BrickColor
			end

			_G.PU:Dust(part2, 3)
			part2.Parent = workspace.Effects
			v3 = v3 + 30 + math.random(-23, 23)
		end
	end)
end

function Op_CTeleport(_, p, instance, _)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local p2 = humanoidRootPart.CFrame.p
	local p3 = p.p
	local sound = Instance.new("Sound", humanoidRootPart)
	sound.SoundId = "rbxassetid://5358352705"
	sound.Volume = 1
	sound.MaxDistance = 500
	sound:Play()
	_G.PU:Dust(sound, 2)
	local v2 = {}

	for i = 0, 5 do
		local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
		local v3 = p2 + (p3 - p2).Unit * i * (p3 - p2).magnitude / 5
		local v4 = (i == 0 or i == 5) and createVector(0, 0, 0) or vector2
		v2[#v2 + 1] = v3 + v4
	end

	PeodizService.ForLoop({
		Step = #v2
	}, function(p4)
		local v3 = math.floor(p4 * #v2)

		if v2[v3 + 1] ~= nil then
			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Material = "Neon"
			part.Color = Color3.fromRGB(94, 225, 94)
			part.Size = Vector3.new(0.75, 0.75, (v2[v3] - v2[v3 + 1]).magnitude)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new((v2[v3] + v2[v3 + 1]) / 2, v2[v3 + 1])
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
				Size = Vector3.new(0, 0, (v2[v3] - v2[v3 + 1]).magnitude)
			}):Play()
			_G.PU:Dust(part, 1)
		end
	end)
	task.delay(10, function()
		table.clear(v2)
	end)
end

function Op_CounterShock(_, p, instance, _)
	spawn(function()
		for _ = 1, 3 do
			local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
			clone.Material = Enum.Material.SmoothPlastic
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.Parent = workspace.Effects
			clone.Position = p.p
			clone.CFrame *= CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = createVector(125, 125, 10),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 0.6)
			wait(0.1)
		end
	end)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local p2 = humanoidRootPart.CFrame.p
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://621371444",
		PlaybackSpeed = 1.2,
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = humanoidRootPart
	sound:Play()
	local clones = {}

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.OpNew.CSParticle:Clone()
		clone.Parent = part
		clone.Enabled = true
		clones[#clones + 1] = clone
	end

	for _ = 1, 6 do
		wait()

		for _ = 1, 3 do
			local v2 = (humanoidRootPart.CFrame * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			) * CFrame.new(0, 0, math.random(15, 20))).p
			spawn(function()
				local v3 = {}

				for i = 0, 3 do
					local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					local v4 = p2 + (v2 - p2).Unit * i * (v2 - p2).magnitude / 3
					local v5 = (i == 0 or i == 3) and createVector(0, 0, 0) or vector2
					v3[#v3 + 1] = v4 + v5
				end

				PeodizService.ForLoop({
					Step = #v3
				}, function(p4)
					local v4 = math.floor(p4 * #v3)

					if v3[v4 + 1] ~= nil then
						local part = Instance.new("Part")
						part.Parent = workspace.Effects
						part.Material = "Neon"
						part.Color = Color3.fromRGB(94, 225, 94)
						part.Size = Vector3.new(0.35, 0.35, (v3[v4] - v3[v4 + 1]).magnitude)
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new((v3[v4] + v3[v4 + 1]) / 2, v3[v4 + 1])
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
							Size = Vector3.new(0, 0, (v3[v4] - v3[v4 + 1]).magnitude)
						}):Play()
						_G.PU:Dust(part, 1)
					end
				end)
				task.delay(10, function()
					table.clear(v3)
				end)
			end)
		end
	end

	for _, v2 in pairs(clones) do
		v2.Enabled = false
		_G.PU:Dust(v2, 1)
	end

	task.delay(10, function()
		table.clear(clones)
	end)
end

function Op_VTeleport(_, _, instance, _)
	local p = instance:WaitForChild("HumanoidRootPart").CFrame.p
	local p2 = instance.HumanoidRootPart.CFrame.p
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
			part.Parent = workspace.Effects
			part.Material = "Neon"
			part.Color = Color3.fromRGB(198, 56, 59)
			part.Size = Vector3.new(1, 1, (v2[v3] - v2[v3 + 1]).magnitude)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new((v2[v3] + v2[v3 + 1]) / 2, v2[v3 + 1])
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(part, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
				Size = Vector3.new(0, 0, (v2[v3] - v2[v3 + 1]).magnitude)
			}):Play()
			_G.PU:Dust(part, 1)
		end
	end)
	task.delay(10, function()
		table.clear(v2)
	end)
end

function Op_VMes(_, p, instance, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
	clone.Material = Enum.Material.Neon
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.Parent = workspace.Effects
	clone.Position = p.p
	clone.CFrame *= CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(200, 200, 16),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.6)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local p2 = humanoidRootPart.CFrame.p

	for _, part in pairs(instance:GetChildren()) do
		part:IsA("BasePart")
	end

	for _ = 1, 6 do
		wait()

		for _ = 1, 2 do
			local v2 = (humanoidRootPart.CFrame * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			) * CFrame.new(0, 0, math.random(22, 25))).p
			spawn(function()
				local v3 = {}

				for i = 0, 4 do
					local vector2 = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					local v4 = p2 + (v2 - p2).Unit * i * (v2 - p2).magnitude / 4
					local v5 = (i == 0 or i == 4) and createVector(0, 0, 0) or vector2
					v3[#v3 + 1] = v4 + v5
				end

				PeodizService.ForLoop({
					Step = #v3
				}, function(p4)
					local v4 = math.floor(p4 * #v3)

					if v3[v4 + 1] ~= nil then
						local part = Instance.new("Part")
						part.Parent = workspace.Effects
						part.Material = "Neon"
						part.Color = Color3.fromRGB(198, 56, 59)
						part.Size = Vector3.new(0.5, 0.5, (v3[v4] - v3[v4 + 1]).magnitude)
						part.Anchored = true
						part.CanCollide = false
						part.CFrame = CFrame.new((v3[v4] + v3[v4 + 1]) / 2, v3[v4 + 1])
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							Transparency = 1
						}):Play()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Size = Vector3.new(0, 0, (v3[v4] - v3[v4 + 1]).magnitude)
						}):Play()
						_G.PU:Dust(part, 1)
					end
				end)
				task.delay(10, function()
					table.clear(v3)
				end)
			end)
		end
	end
end

function Op_E(_, _, list, _)
	local v2, v3, v4 = unpack(list)
	local _ = v2:WaitForChild("HumanoidRootPart").CFrame
	local magnitude = (v3 - v4).magnitude
	spawn(function()
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(1, 1, magnitude)
		part.CFrame = CFrame.new(v3, v4) * CFrame.new(0, 0, -magnitude / 2)
		part.Parent = workspace.Effects
		part.Material = "Neon"
		part.Color = Color3.fromRGB(153, 49, 173)
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = Enum.MeshType.Sphere
		_G.PU:Dust(part, 1)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(part, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
			Size = Vector3.new(0, 0, magnitude)
		}):Play()
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(part, TweenInfo.new(0.65, Enum.EasingStyle.Quad), {
			Transparency = 1
		}):Play()
	end)
	spawn(function()
		local v5 = {}

		for i = 0, 7 do
			local vector2 = Vector3.new(math.random(-6, 4), math.random(-6, 4), math.random(-6, 4))
			local v6 = v3 + (v4 - v3).Unit * i * (v4 - v3).magnitude / 7
			local v7 = (i == 0 or i == 7) and createVector(0, 0, 0) or vector2
			v5[#v5 + 1] = v6 + v7
		end

		for i = 1, #v5 do
			if v5[i + 1] == nil then
				continue
			end

			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Material = "Neon"
			part.Color = Color3.fromRGB(153, 49, 173)
			part.Size = Vector3.new(1, 1, (v5[i] - v5[i + 1]).magnitude)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new((v5[i] + v5[i + 1]) / 2, v5[i + 1])
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Transparency = 1
			}):Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Size = Vector3.new(0, 0, (v5[i] - v5[i + 1]).magnitude)
			}):Play()
			_G.PU:Dust(part, 1)
		end

		task.delay(10, function()
			table.clear(v5)
		end)
	end)
end

function bari_x(instance, p, _, _)
	local v2 = instance:WaitForChild("PlayerStats"):WaitForChild("DF").Value * 0.02
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
	clone.Parent = workspace.Effects
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.CFrame = p * CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = createVector(90, 90, 25),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.6)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Smoke3:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.Name = "FF"
	clone2.CFrame = p * CFrame.new(0, -7, 0)
	clone2.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://2011915907",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Effects,
		workspace.PlayerCharacters,
		workspace.CharacterWorkshop
	}
	local raycastResult = workspace:Raycast(p.p + createVector(0, 5, 0), createVector(0, -25, 0), raycastParams)
	local _ = p.p + createVector(0, 5, 0) + createVector(0, -25, 0)
	local instance2

	if raycastResult then
		instance2 = raycastResult.Instance
		local _ = raycastResult.Position
	end

	if instance2 then
		for _, emitter in pairs(clone2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(instance2.Color)
			emitter:Emit(5)
		end
	end

	spawn(function()
		local v3 = math.floor((math.min(60, 40 + v2))) + 1

		for i = 1, 4 do
			for i2 = 1, 4 do
				local v4 = v3 / 2 + i2 * v3 / 4 - v3
				local v5 = p * CFrame.Angles(0, math.rad(i * 90), 0) * CFrame.new(v3 / 2, 0, v4)
				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Size = createVector(0, 0, 0)
				part.CFrame = v5 * CFrame.Angles(math.random(0, 90), math.random(0, 90), math.random(0, 90))
				part.Position = part.CFrame.p - createVector(0, 2, 0)
				part.Material = "SmoothPlastic"
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				raycastParams2.FilterDescendantsInstances = { workspace.Island }
				local raycastResult2 = workspace:Raycast(
					part.Position + createVector(0, 10, 0),
					createVector(0, -30, 0),
					raycastParams2
				)
				local _ = part.Position + createVector(0, 10, 0) + createVector(0, -30, 0)
				local instance3, material

				if raycastResult2 then
					local _ = raycastResult2.Position
					instance3 = raycastResult2.Instance
					local _ = raycastResult2.Normal
					material = instance3.Material
				end

				local v6 = math.random(6, 7)
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = Vector3.new(v6, v6, v6)
				}):Play()
				TweenService:Create(
					part,
					TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 2),
					{
						Transparency = 1
					}
				):Play()
				part.Material = material or "SmoothPlastic"

				if instance3 then
					part.Parent = workspace.Effects
					part.BrickColor = instance3.BrickColor
				end

				_G.PU:Dust(part, 2)
			end
		end
	end)
end

function Barrier_Z(_, p, _, _)
	task.spawn(function()
		local cFrame = p
		local clone = ReplicatedStorage.Chest.FruitEffect.Bari.Barrier:Clone()
		clone.Particle.Texture = "rbxassetid://1084970835"
		clone.Particle.Rate = 100
		clone.Particle.Enabled = true
		clone.CFrame = cFrame * CFrame.new(0, 5, 0)
		clone.Size = createVector(15, 15, 0.5)
		clone.at1.Position = createVector(-25, 25, 0)
		clone.at2.Position = createVector(-25, -25, 0)
		clone.at3.Position = createVector(25, -25, 0)
		clone.at4.Position = createVector(25, 25, 0)
		clone.trail1.Enabled = false
		clone.trail2.Enabled = false
		clone.trail3.Enabled = false
		clone.trail4.Enabled = false
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)
		local v3 = {
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://7050365057",
			Volume = 2
		}
		local sound = PeoUtils.CreateSound(v3)
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		spawn(function()
			wait(0.25)
			clone.Particle.Enabled = false
		end)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Size = createVector(50, 50, 1),
			CFrame = cFrame * CFrame.new(0, 16.666666666666668, 0)
		}):Play()
		wait(0.15)
		spawn(function()
			local clone2 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 2)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://4891186740",
				Volume = 1
			})
			_G.PU:Dust(sound2, 5)
			sound2.Parent = clone2
			sound2:Play()
		end)
		clone.trail1.Enabled = true
		clone.trail2.Enabled = true
		clone.trail3.Enabled = true
		clone.trail4.Enabled = true
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			CFrame = cFrame * CFrame.new(0, 16.666666666666668, -100)
		}):Play()
		spawn(function()
			PeodizService.ForLoop({
				Step = 9
			}, function(p2)
				local v4 = math.floor(p2 * 9)
				spawn(function()
					local v5 = v4 / 1.5
					local part = Instance.new("Part")
					part.BrickColor = BrickColor.new("Dark stone grey")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Slate
					part.Size = createVector(7, 7, 7) * math.random(100, 125) / 100
					part.CFrame = cFrame * CFrame.new(0, 0, -v4 * v5 - 2)
					part.Parent = workspace.Effects
					local clone2 = part:Clone()
					clone2.CFrame = cFrame * CFrame.new(0, 0, -v4 * v5 - 2)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(part, 2)
					_G.PU:Dust(clone2, 2)
					local cframe = CFrame.new(25, 50, -v4 * 20 / 2)
					local cframe2 = CFrame.new(-25, 50, -v4 * 20 / 2)
					Ray.new(cFrame * cframe.p, createVector(0, -69, 0))
					Ray.new(cFrame * cframe2.p, createVector(0, -69, 0))
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Include
					raycastParams.FilterDescendantsInstances = { workspace.Island }
					local raycastResult = workspace:Raycast(cFrame * cframe.p, createVector(0, -69, 0), raycastParams)
					local raycastResult2 = workspace:Raycast(cFrame * cframe2.p, createVector(0, -69, 0), raycastParams)
					local position = cFrame * cframe.p + createVector(0, -69, 0)
					local instance = nil
					local position2 = cFrame * cframe2.p + createVector(0, -69, 0)
					local instance2

					if raycastResult then
						instance2 = raycastResult.Instance
						position = raycastResult.Position
					end

					if raycastResult2 then
						instance = raycastResult2.Instance
						position2 = raycastResult2.Position
					end

					if instance2 then
						part.CFrame = CFrame.new(position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						part.Material = instance2.Material
						part.BrickColor = instance2.BrickColor
					else
						part:Destroy()
					end

					if instance then
						clone2.CFrame = CFrame.new(position2) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						clone2.Material = instance.Material
						clone2.BrickColor = instance.BrickColor
					else
						clone2:Destroy()
					end

					spawn(function()
						wait(1)
						TweenService:Create(
							part,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								Size = part.Size / 2
							}
						):Play()
						TweenService:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								Size = clone2.Size / 2
							}
						):Play()
					end)
				end)
			end)
		end)
		wait(0.75)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone.Decal1, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone.Decal2, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end)
end

function Barrier_X(_, p, _, _)
	task.spawn(function()
		local cFrame = p
		local clone = ReplicatedStorage.Chest.FruitEffect.Bari.Barrier:Clone()
		clone.Decal1.Transparency = 1
		clone.Decal2.Transparency = 1
		clone.Transparency = 0.5
		clone.Material = Enum.Material.Glass
		clone.Shape = Enum.PartType.Ball
		clone.CFrame = cFrame * CFrame.new(0, 100, 0)
		clone.Size = Vector3.new()
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 3)
		local v3 = {
			RollOffMaxDistance = 300,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://7050365057",
			Volume = 2
		}
		local sound = PeoUtils.CreateSound(v3)
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Bari.Barrier:Clone()
		clone2.Transparency = 1
		clone2.Decal1.Transparency = 1
		clone2.Decal2.Transparency = 1
		clone2.Particle.Texture = "rbxassetid://1084970835"
		clone2.Particle.Rate = 300
		clone2.Particle.Enabled = true
		clone2.Size = createVector(50, 50, 50)
		clone2.CFrame = clone.CFrame
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 3)
		local sound2 = Instance.new("Sound")
		sound2.SoundId = "rbxassetid://7055163227"
		sound2.RollOffMaxDistance = 500
		sound2.Volume = 2.5
		sound2.Parent = clone
		sound2:Play()
		spawn(function()
			wait(0.25)
			clone2.Particle.Enabled = false
		end)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			Size = createVector(50, 50, 50)
		}):Play()
		wait(0.15)
		TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			CFrame = cFrame
		}):Play()
		task.spawn(function()
			task.wait(0.1)

			if (cFrame.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
				_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			end

			task.spawn(function()
				local v4 = Scheduler.Repeat(1, 10)
				v4:Instant()
				v4:OnStep(function(_)
					local v5 = p * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
						math.rad((math.random(-90, 90))),
						math.rad((math.random(-90, 90))),
						0
					)
					local v6 = math.random(10, 30) / 5
					local v7 = math.random(25, 35)
					local clone3 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
					clone3.CastShadow = false
					clone3.Transparency = -1
					clone3.Anchored = true
					clone3.CanCollide = false
					clone3.Size = Vector3.new(v6, v6, math.random(30, 50))
					clone3.CFrame = v5 * CFrame.new(0, 0, 25)
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 0.275)
					TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
						Size = Vector3.new(),
						CFrame = clone3.CFrame * CFrame.new(0, 0, v7)
					}):Play()
				end)
				v4:Execute()
			end)
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.Shockowave:Clone()
			clone3.Transparency = 0.1
			clone3.CFrame = cFrame
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
				Size = createVector(100, 10, 100),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone3, 0.3)
			local clone4 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
			clone4.CFrame = cFrame
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 2)
			local sound3 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7055186028",
				Volume = 5
			})
			_G.PU:Dust(sound3, 5)
			sound3.Parent = clone4
			sound3:Play()
			local v4 = cFrame + createVector(0, 2, 0)
			local v5 = Scheduler.Repeat(1, 15)
			v5:Instant()
			v5:OnStep(function(p2)
				local cframe = v4 * CFrame.Angles(0, 6.283185307179586 * p2 / 15, 0) * CFrame.new(0, 0, -25)
				local _, v6, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -25, 0), raycastParams)
				local position = cframe.Position + createVector(0, -25, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if instance then
					local part = Instance.new("Part")
					part.CanCollide = false
					part.CastShadow = false
					part.Anchored = true
					part.Size = createVector(1, 1, 1)
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Color = instance.Color
					part.CFrame = CFrame.new(v4.X, position.Y, v4.Z) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
						0.7853981633974483,
						0,
						0
					)
					part.Parent = workspace.Effects
					_G.PU:Dust(part, 3)
					local v7 = math.random(35, 50) / 10
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v6, 0) * CFrame.Angles(
							0.7853981633974483,
							0,
							0
						),
						Size = Vector3.new(v7 * 3, v7, v7)
					}):Play()
					spawn(function()
						wait(1)
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Position = part.Position + createVector(0, -2, 0),
							Transparency = 1
						}):Play()
					end)
				end
			end)
			v5:Execute()
		end)
		task.spawn(function()
			local v4 = Scheduler.Repeat(1, 2)
			v4:Instant()
			v4:Wait()
			v4:OnStep(function(p2)
				local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone3.Transparency = -1
				clone3.Size = Vector3.new()
				clone3.CFrame = cFrame * CFrame.new(0, 100 - p2 * 40, 0) * CFrame.Angles(0, 0, 3.141592653589793)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(75, 3, 75),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 0.25)
			end)
			v4:Execute()
		end)
		task.wait(1)
		TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone.Decal1, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
		TweenService:Create(clone.Decal2, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
			Transparency = 1
		}):Play()
	end)
end

function Barrier_V(_, p, _, _)
	spawn(function()
		PeodizService.ForLoop({
			Step = 6,
			WaitTime = 0.05
		}, function(p2)
			local v2 = math.floor(p2 * 6)
			local cframe = p * CFrame.new(0, 0, -v2 * v2 * 3)
			local _, v3, _ = cframe:ToOrientation()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {
				workspace.Effects,
				workspace.PlayerCharacters,
				workspace.CharacterWorkshop
			}
			local raycastResult = workspace:Raycast(
				cframe.p + createVector(0, 5, 0),
				createVector(0, -75, 0),
				raycastParams
			)
			local position = cframe.p + createVector(0, 5, 0) + createVector(0, -75, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if instance then
				local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Spike:Clone()
				clone.Size = createVector(7.5, 25, 7.5)
				clone.Transparency = 0.5
				clone.Color = Color3.fromRGB(31, 128, 29)
				clone.Material = Enum.Material.Glass
				clone.CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://7055163227",
					Volume = 3
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Size * v2,
					CFrame = clone.CFrame * CFrame.new(0, v2 * 24 / 2.2, 0)
				}):Play()
				spawn(function()
					wait(1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone.Size / 1.5,
						CFrame = clone.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
						Transparency = 1
					}):Play()
				end)
			elseif not instance and position.Y <= -3.35 then
				local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Spike:Clone()
				clone.Size = createVector(7.5, 25, 7.5)
				clone.Transparency = 0.5
				clone.Color = Color3.fromRGB(31, 128, 29)
				clone.Material = Enum.Material.Glass
				clone.CFrame = CFrame.new(position.X, -3.35, position.Z) * CFrame.fromOrientation(0, v3, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = clone.Size * v2,
					CFrame = clone.CFrame * CFrame.new(0, v2 * 24 / 2.2, 0)
				}):Play()
				spawn(function()
					wait(1.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = clone.Size / 1.5,
						CFrame = clone.CFrame * CFrame.new(0, -(v2 * 2.5 * 2) / 2, 0),
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)
end

function Barrier_E(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		spawn(function()
			local clone = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
			clone.Attachment.Ball.Texture = "rbxassetid://1084970835"
			clone.Attachment.Ball.LockedToPart = false
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone.Attachment.Ball:Emit(20)
			_G.PU:Dust(clone, 1)

			for _ = 1, 10 do
				local cFrame3 = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					math.rad((math.random(-90, 90))),
					0
				)
				local v4 = math.random(10, 30) / 5
				local v5 = math.random(25, 35) + 25
				local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone2.CastShadow = false
				clone2.Transparency = -1
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Size = Vector3.new(v4, v4, math.random(30, 50))
				clone2.CFrame = cFrame3
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 0.275)
				TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Size = Vector3.new(),
					CFrame = clone2.CFrame * CFrame.new(0, 0, v5)
				}):Play()
			end
		end)
		local clone = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
		clone.CastShadow = false
		clone.Transparency = 0.1
		clone.CFrame = cFrame2
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(100, 3, 100),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 0.5)
		local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockwave:Clone()
		clone2.CastShadow = false
		clone2.Size = Vector3.new()
		clone2.Color = Color3.fromRGB(255, 255, 255)
		clone2.Transparency = -1
		clone2.CFrame = cFrame2 * CFrame.Angles(1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793),
			Size = createVector(70, 70, 7),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone2, 0.25)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Bari.Shock:Clone()
		clone3.Transparency = -1
		clone3.Color = Color3.fromRGB(255, 255, 255)
		clone3.Size = createVector(0, 25, 0)
		clone3.CFrame = cFrame2
		clone3.Parent = workspace.Effects
		TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(100, 10, 100),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone3, 1)
		spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(cFrame2.p, createVector(0, -25, 0), raycastParams)
			local position = cFrame2.p + createVector(0, -25, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if instance then
				local cframe = CFrame.new(position)

				for _ = 1, 7 do
					local part = Instance.new("Part")
					local v3 = math.random(2, 6)
					part.CanCollide = false
					part.Anchored = false
					part.Velocity = Vector3.new(math.random(-45, 45), math.random(75, 125), math.random(-45, 45))
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.Color = instance.Color
					part.Massless = true
					part.Size = Vector3.new(v3, v3, v3)
					part.Parent = workspace.Effects
					part.CFrame = cframe * CFrame.new(math.rad(-30, 30), 0, (math.rad(-30, 30))) * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
					_G.PU:Dust(part, 3)
				end
			end
		end)
		spawn(function()
			local v3 = CFrame.new(cFrame2.p) * CFrame.new(0, 25, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(v3.p, createVector(0, -50, 0), raycastParams)
			local position = v3.p + createVector(0, -50, 0)
			local instance, normal

			if raycastResult then
				position = raycastResult.Position
				instance = raycastResult.Instance
				normal = raycastResult.Normal
				local _ = instance.Material
			else
				normal = createVector(0, -1, 0)
			end

			if instance then
				local clone4 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
				clone4.Decal.Transparency = 0.2
				clone4.Decal.Texture = "rbxassetid://7068839334"
				clone4.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				) * CFrame.new(0, -1, 0)
				clone4.Parent = workspace.Effects
				_G.PU:Dust(clone4, 1.5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://262562442",
					Volume = 1.5
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone4
				sound:Play()
				TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(60, 0, 60)
				}):Play()
				spawn(function()
					wait(1)

					if clone4:FindFirstChild("Decal") then
						TweenService:Create(clone4.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end
				end)
			end
		end)
		spawn(function()
			local v3 = CFrame.new(cFrame2.p) + createVector(0, 2, 0)

			for i = 1, 15 do
				local cframe = v3 * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(0, 0, -30)
				local _, _, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -25, 0), raycastParams)
				local position = cframe.Position + createVector(0, -25, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.CanCollide = false
				part.CastShadow = false
				part.Anchored = true
				part.Size = createVector(1, 1, 1)
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.CFrame = CFrame.new(v3.X, position.Y, v3.Z) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				local v4 = math.random(70, 100) / 10
				TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					),
					Size = Vector3.new(v4, v4, v4) * 1.15
				}):Play()
				spawn(function()
					wait(1)
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
						Position = part.Position + createVector(0, -1, 0),
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)
end

function Bari_Z(player, _, p, _)
	local function Gura1(list)
		local v2, v3, v4, v5 = unpack(list)
		local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

		if (v2.p - humanoidRootPart.CFrame.p).Magnitude > 500 then
			v4.Transparency = 1
			return
		end

		local v6 = (v2.p - v3.p).Magnitude / 20
		TweenService:Create(v4, TweenInfo.new(0.35), {
			Size = createVector(45, 45, 1)
		}):Play()
		TweenService:Create(v4.at1, TweenInfo.new(0.35), {
			Position = createVector(-22.5, 22.52, 0)
		}):Play()
		TweenService:Create(v4.at2, TweenInfo.new(0.35), {
			Position = createVector(-22.5, -22.165, 0)
		}):Play()
		TweenService:Create(v4.at3, TweenInfo.new(0.35), {
			Position = createVector(22.5, -22.165, 0)
		}):Play()
		TweenService:Create(v4.at4, TweenInfo.new(0.35), {
			Position = createVector(22.5, 22.52, 0)
		}):Play()
		PeodizService.ForLoop({
			Step = 20
		}, function(p2)
			local v7 = math.floor(p2 * 20)
			v4.CFrame = v2 * CFrame.new(0, 0, -math.sin(v7 / 20 * 3.141592653589793 / 2) * v5)

			if v7 % 2 == 0 then
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Dark stone grey")
				part.Anchored = true
				part.CanCollide = false
				part.Material = Enum.Material.Slate
				local v8 = 11 - v7 / 4
				part.Size = Vector3.new(v8, v8, v8)
				part.CFrame = v2 * CFrame.new(0, 0, -v7 * v6 - v8 / 3.5)
				part.Parent = workspace.Effects
				local clone = part:Clone()
				clone.CFrame = v2 * CFrame.new(0, 0, -v7 * v6 - v8 / 3.5)
				clone.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				_G.PU:Dust(clone, 2)
				local cframe = CFrame.new(34 - v7 / 1.75, 0, -v7 * v6 - v8 / 3.5)
				local cframe2 = CFrame.new(v7 / 1.75 + -34, 0, -v7 * v6 - v8 / 3.5)
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				raycastParams.FilterDescendantsInstances = { player.Character, workspace.Effects }
				local raycastResult = workspace:Raycast(v2 * cframe.p, createVector(0, -69, 0), raycastParams)
				local raycastResult2 = workspace:Raycast(v2 * cframe2.p, createVector(0, -69, 0), raycastParams)
				local position = v2 * cframe.p + createVector(0, -69, 0)
				local instance = nil
				local position2 = v2 * cframe2.p + createVector(0, -69, 0)
				local instance2

				if raycastResult then
					instance2 = raycastResult.Instance
					position = raycastResult.Position
				end

				if raycastResult2 then
					instance = raycastResult2.Instance
					position2 = raycastResult2.Position
				end

				if instance2 then
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					part.Material = instance2.Material
					part.BrickColor = instance2.BrickColor
				else
					part:Destroy()
				end

				if instance then
					TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(position2) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					clone.Material = instance.Material
					clone.BrickColor = instance.BrickColor
				else
					clone:Destroy()
				end
			end
		end)
		delay(1, function()
			TweenService:Create(v4, TweenInfo.new(0.35), {
				Transparency = 1
			}):Play()
			TweenService:Create(v4.Decal1, TweenInfo.new(0.35), {
				Transparency = 1
			}):Play()
			TweenService:Create(v4.Decal2, TweenInfo.new(0.35), {
				Transparency = 1
			}):Play()
		end)
	end

	Gura1(p)
end

function bari_e(_, cFrame, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
	clone.Parent = workspace.Effects
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = createVector(90, 90, 40),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.6)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Smoke3:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.Name = "FF"
	clone2.CFrame = cFrame * CFrame.new(0, -7, 0)
	clone2.Parent = workspace.Effects
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Effects,
		workspace.PlayerCharacters,
		workspace.CharacterWorkshop
	}
	local raycastResult = workspace:Raycast(cFrame.p + createVector(0, 5, 0), createVector(0, -25, 0), raycastParams)
	local _ = cFrame.p + createVector(0, 5, 0) + createVector(0, -25, 0)
	local instance

	if raycastResult then
		instance = raycastResult.Instance
		local _ = raycastResult.Position
	end

	if instance then
		for _, emitter in pairs(clone2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(instance.Color)
			emitter:Emit(5)
		end
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Bari.explosion:Clone()
	_G.PU:Dust(clone3, 2)
	clone3.CFrame = cFrame
	clone3.Parent = workspace.Effects
	clone3.Shock:Emit(1)
	local v2 = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.Inverse,
		SoundId = "rbxassetid://5863138657",
		Volume = 1
	}
	local sound = PeoUtils.CreateSound(v2)
	_G.PU:Dust(sound, 2)
	sound.Parent = clone3
	sound:Play()
	local part = Instance.new("Part", workspace.Effects)
	part.Transparency = 1
	part.CFrame = cFrame
	part.Anchored = true
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CanCollide = false
end

function KarateFishman2000(p, p2, _, _)
	local humanoidRootPart = p.HumanoidRootPart
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5034641773",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = humanoidRootPart
	sound:Play()

	for i = 1, 4 do
		local clone = ReplicatedStorage.Chest.FruitEffect.KarateShockwave:Clone()
		clone.Size = createVector(0, 0, 0)
		clone.Parent = workspace.Effects
		clone.CFrame = p2 * CFrame.new(0, 0, i * -3 * 2.5) * CFrame.Angles(1.5707963267948966, 0, 0)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(15, 2, 15) * i,
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end

function CombatFishman2050(p, p2, _, _)
	local humanoidRootPart = p.HumanoidRootPart
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5034641773",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = humanoidRootPart
	sound:Play()

	for i = 1, 8 do
		local clone = ReplicatedStorage.Chest.FruitEffect.KarateShockwave:Clone()
		clone.Size = createVector(0, 0, 0)
		clone.Parent = workspace.Effects
		clone.CFrame = p2 * CFrame.new(0, 0, i * -3 * 2.5) * CFrame.Angles(1.5707963267948966, 0, 0)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(60, 8, 60),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end

function SwordFishman2100(_, p, parent, _)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://1081841854"
	sound.MaxDistance = 250
	sound.Parent = parent
	sound.Volume = 0.5
	sound:Play()
	_G.PU:Dust(sound, 2.5)
	PeodizService.ForLoop({
		Step = 50
	}, function(_)
		local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.BlueSlash:Clone()
		clone.Parent = workspace.Effects
		clone.CFrame = p * CFrame.new(0, 0, -10) * CFrame.Angles(
			math.rad((math.random(-360, 360))),
			math.rad((math.random(-360, 360))),
			(math.rad((math.random(-360, 360))))
		) * CFrame.new(0, 0, -math.random(0, 5))
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1,
			CFrame = clone.CFrame * CFrame.new(0, 0, -5)
		}):Play()
		_G.PU:Dust(clone, 0.5)
	end)
end

function Fishman2200(_, cFrame, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
	clone.Color = Color3.fromRGB(0, 0, 127)
	clone.Parent = workspace.Effects
	clone.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
	TweenService:Create(clone, TweenInfo.new(0.3), {
		Size = createVector(90, 90, 40),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.6)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gravity.Smoke3:Clone()
	_G.PU:Dust(clone2, 2)
	clone2.Name = "FF"
	clone2.CFrame = cFrame * CFrame.new(0, -7, 0)
	clone2.Parent = workspace.Effects
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Effects,
		workspace.PlayerCharacters,
		workspace.CharacterWorkshop
	}
	local raycastResult = workspace:Raycast(cFrame.p + createVector(0, 5, 0), createVector(0, -25, 0), raycastParams)
	local _ = cFrame.p + createVector(0, 5, 0) + createVector(0, -25, 0)
	local instance

	if raycastResult then
		instance = raycastResult.Instance
		local _ = raycastResult.Position
	end

	if instance then
		for _, emitter in pairs(clone2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(instance.Color)
			emitter:Emit(5)
		end
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Bari.explosion:Clone()
	_G.PU:Dust(clone3, 2)
	clone3.CFrame = cFrame
	clone3.Shock.Color = ColorSequence.new(Color3.new(0, 0, 0.498039))
	clone3.Parent = workspace.Effects
	clone3.Shock:Emit(1)
	local v2 = {
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.Inverse,
		SoundId = "rbxassetid://5019516868",
		Volume = 1
	}
	local sound = PeoUtils.CreateSound(v2)
	_G.PU:Dust(sound, 2)
	sound.Parent = clone3
	sound:Play()
end

function WaterStyle_Z(player, p, _, _)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5899841039",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = player.Character.Head
	sound:Play()
	PeodizService.ForLoop({
		Step = 10
	}, function(p2)
		local v2 = math.floor(p2 * 10)
		local clone = ReplicatedStorage.Chest.FruitEffect.WaterShockwave:Clone()
		clone.Parent = workspace.Effects
		clone.particle:Emit(1)
		clone.CFrame = p * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, v2 * 7.5)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(60, 60, 10),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 2)
	end)
end

function WaterStyle_Z_Boss(p, p2, _, _)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5899841039",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = p.Head
	sound:Play()
	PeodizService.ForLoop({
		Step = 10
	}, function(p3)
		local v2 = math.floor(p3 * 10)
		local clone = ReplicatedStorage.Chest.FruitEffect.WaterShockwave:Clone()
		clone.Parent = workspace.Effects
		clone.particle:Emit(1)
		clone.CFrame = p2 * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.new(0, 0, v2 * 7.5)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(60, 60, 10),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 2)
	end)
end

function WaterStyle_X(_, cFrame, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Flame.waterexplosion:Clone()
	_G.PU:Dust(clone, 1)
	clone.CFrame = cFrame
	clone.particle:Emit(1)
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(50, 50, 50),
		Transparency = 1
	}):Play()
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5896883376",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 1)
	sound.Parent = clone
	sound:Play()
	local part = Instance.new("Part", workspace.Effects)
	part.Transparency = 1
	part.CFrame = cFrame
	part.Anchored = true
	part.Size = createVector(0.1, 0.1, 0.1)
	part.CanCollide = false
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Flame.Brick:Clone()
	clone2.Parent = part
	clone2.Enabled = true
	_G.PU:Dust(clone2, 2)
	_G.PU:Dust(part, 2)
	delay(0.23, function()
		wait(0.12)
		clone2.Enabled = false
	end)
end

function WaterStyle_C(p, p2, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.WaterBeam:Clone()
	clone.particle.Enabled = true
	clone.Name = "waterbeam" .. p.Name
	clone.Parent = workspace.Effects
	clone.CFrame = p2 * CFrame.new(0, 0, -10) * CFrame.Angles(0, 1.5707963267948966, 0)
	TweenService:Create(clone, TweenInfo.new(1), {
		Size = createVector(200, 15, 15),
		CFrame = clone.CFrame * CFrame.new(100, 0, 0)
	}):Play()
	_G.PU:Dust(clone, 2)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.WaterBall:Clone()
	_G.PU:Dust(clone2, 3)
	clone2.Name = "waterball1"
	clone2.CFrame = clone.CFrame
	clone2.Parent = clone
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5904365594",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	TweenService:Create(clone2, TweenInfo.new(1), {
		Size = createVector(15, 15, 15)
	}):Play()
	local clone3 = ReplicatedStorage.Chest.FruitEffect.WaterBall:Clone()
	clone3.Name = "waterball2"
	clone3.Parent = clone
	clone3.CFrame = clone.CFrame
	TweenService:Create(clone3, TweenInfo.new(1), {
		Size = createVector(15, 15, 15),
		CFrame = clone3.CFrame * CFrame.new(200, 0, 0)
	}):Play()
	_G.PU:Dust(clone3, 2)
	spawn(function()
		for _ = 1, 8 do
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
			clone4.BrickColor = BrickColor.new("Deep blue")
			clone4.Material = Enum.Material.Neon
			clone4.Parent = clone
			clone4.CFrame = p2 * CFrame.Angles(0, 3.141592653589793, 0)
			TweenService:Create(clone4, TweenInfo.new(0.5), {
				Size = createVector(55, 55, 10),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone4, 2)
			wait(0.1)
		end
	end)
	spawn(function()
		for _ = 1, 100 do
			for _, texture in pairs(clone2:GetChildren()) do
				if not texture:IsA("Texture") then
					continue
				end

				if texture.Name == "Texture1" then
					texture.OffsetStudsU -= 5
				else
					texture.OffsetStudsU += 5
				end
			end

			for _, texture in pairs(clone3:GetChildren()) do
				if not texture:IsA("Texture") then
					continue
				end

				if texture.Name == "Texture1" then
					texture.OffsetStudsU -= 5
				else
					texture.OffsetStudsU += 5
				end
			end

			wait(0.01)
		end
	end)
	delay(1, function()
		clone.particle.Enabled = false
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = createVector(200, 0, 0),
			Transparency = 1
		}):Play()
		TweenService:Create(clone2, TweenInfo.new(0.5), {
			Size = createVector(0, 0, 0),
			Transparency = 1
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.5), {
			Size = createVector(0, 0, 0),
			Transparency = 1
		}):Play()
		local folder = workspace.Effects:FindFirstChild(clone.Name)

		if folder then
			for _, texture in pairs(folder:GetDescendants()) do
				if texture:IsA("Texture") then
					TweenService:Create(texture, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end
			end

			wait(0.5)
			folder:Destroy()
		end
	end)
	PeodizService.HeartbeatWait({
		Time = 5,
		WaitTime = 0.01
	}, function()
		if not clone:IsDescendantOf(workspace.Effects) then
			return true
		end

		for _, texture in pairs(clone:GetChildren()) do
			if not texture:IsA("Texture") then
				continue
			end

			if texture.Name == "Texture1" then
				texture.OffsetStudsU -= 5
			else
				texture.OffsetStudsU += 5
			end
		end
	end)
end

function WaterStyle_V(_, p, _, _)
	local clone = ReplicatedStorage.Chest.FruitEffect.Sand.SandFloor:Clone()
	clone.Material = Enum.Material.Neon
	clone.BrickColor = BrickColor.new("Deep blue")
	clone.CFrame = p * CFrame.new(0, -3, 0)
	clone.water.Enabled = true
	clone.Parent = workspace.Effects
	clone.Orientation = createVector(0, 0, 90)
	_G.PU:Dust(clone, 3)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5896883376",
		Volume = 0.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	spawn(function()
		for _ = 1, 3 do
			wait(0.1)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Sand.Shockwave:Clone()
			clone2.Material = Enum.Material.Neon
			clone2.BrickColor = BrickColor.new("Deep blue")
			clone2.Parent = workspace.Effects
			clone2.CFrame = p * CFrame.Angles(1.5707963267948966, 0, 0)
			TweenService:Create(clone2, TweenInfo.new(0.5), {
				Size = createVector(500, 500, 40),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.6)
		end
	end)
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Size = createVector(1, 300, 300)
	}):Play()
	delay(0.5, function()
		TweenService:Create(clone, TweenInfo.new(0.5), {
			Size = createVector(1, 150, 150),
			Transparency = 1
		}):Play()
		clone.water.Enabled = false
	end)
end

function Soru(player, _, list, _)
	local v2, v3, v4 = unpack(list)
	local scale

	if player:IsA("Player") then
		scale = player.Character:GetScale()
		task.spawn(function()
			local highlight = Instance.new("Highlight")
			_G.PU:Dust(highlight, 2)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.FillColor = Color3.fromRGB(255, 255, 255)
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.Parent = player.Character
			TweenService:Create(
				highlight,
				TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0),
				{
					FillTransparency = 0.15,
					OutlineTransparency = 0
				}
			):Play()
		end)
	else
		scale = v4 or 1
	end

	task.spawn(function()
		for i = 1, 2 do
			local v5 = i == 1 and v2 or v3
			local clone = ReplicatedStorage.Chest.Etc.SpeedLineModel:Clone()
			_G.PU:Dust(clone, 1)
			clone:ScaleTo(scale)
			clone:PivotTo(CFrame.new(v5.Position))
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 250,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6821738045",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone.SpeedLine
			sound:Play()
			Utility.EmitParticles(clone)
			task.delay(0.2, function()
				Utility.ParticleHandler(clone, false)
			end)
		end
	end)
end

function Santa_Ex(_, _, list, _)
	local v2, _ = unpack(list)
	local cFrame = CFrame.new(v2.Position) * CFrame.new(0, -17.5, 0)
	local clone = ReplicatedStorage.Chest.FruitEffect.Mammoth.ImpactParticle:Clone()
	clone.CFrame = cFrame
	clone.Attachment.Ring.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 100)
	})
	clone.Attachment2.Rocks.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.12, 4.875, 2.685),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Attachment2.Rocks.Speed = NumberRange.new(100, 150)
	clone.Attachment2.Position = clone.Attachment2.Position + createVector(0, 5, 0)
	clone.Attachment2.Ring.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 75)
	})
	clone.Attachment2.Sm.LightEmission = 1
	clone.Attachment2.Sm.Lifetime = NumberRange.new(3)
	clone.Attachment2.Rocks.Lifetime = NumberRange.new(1, 1.5)
	clone.Attachment2.Rocks.LightEmission = 1
	clone.Attachment2.Rocks.Texture = "rbxassetid://7535304728"
	clone.Parent = workspace.Effects
	clone.Attachment.Ring:Emit(1)
	clone.Attachment2.Rocks:Emit(15)
	clone.Attachment2.Sm:Emit(10)
	_G.PU:Dust(clone, 4)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Transparency = -1
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new()
	part.Material = Enum.Material.ForceField
	part.Color = Color3.fromRGB(255, 255, 255)
	part.CastShadow = false
	part.CFrame = cFrame
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1)
	TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(125, 125, 125),
		Transparency = 1
	}):Play()
	local clone2 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
	clone2.CFrame = cFrame
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 5)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8393349995",
		Volume = 2.5
	})
	_G.PU:Dust(sound, 5)
	sound.Parent = clone2
	sound:Play()
end

function Geppo(_, _, data, _)
	local rootPart = data.RootPart
	local parent = rootPart.Parent
	local v2 = rootPart.CFrame * CFrame.new(0, -3, 0)
	local debris = data.Debris or 1
	local special = data.Special

	if special == "toytrex" then
		if not parent:FindFirstChild("ToyTrex") then
			return
		end

		local rootPart2 = parent.ToyTrex:FindFirstChild("RootPart")

		if not rootPart2 then
			return
		end

		local cFrame = rootPart2.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(1.5707963267948966, 0, 0)
		local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_trail:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2)
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_trail:Clone()
		clone2.CFrame = cFrame
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 2)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.geppo_fx:Clone()
		clone3.CFrame = cFrame
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 2)
		local v4 = {
			RollOffMaxDistance = 10000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://15881360529",
			Volume = 7
		}
		local sound = PeoUtils.CreateSound(v4)
		_G.PU:Dust(sound, 2)
		sound.Parent = clone3
		sound:Play()
		task.spawn(function()
			PeodizService.HeartbeatWait({
				Time = 0.35,
				Tween = {
					EasingStyle = Enum.EasingStyle.Quad,
					EasingDirection = Enum.EasingDirection.Out
				}
			}, function(p)
				local v5 = math.floor(p * 75)
				local v6 = 30 - v5 * 0.25
				clone.CFrame = cFrame * CFrame.new(
					math.sin(9.42477796076938 * p) * v6,
					math.cos(9.42477796076938 * p) * v6,
					-v5 / 2.5
				)
				clone2.CFrame = cFrame * CFrame.new(
					-math.sin(9.42477796076938 * p + 5) * v6,
					-math.cos(9.42477796076938 * p + 5) * v6,
					-v5 / 2.5 + 5
				)
			end)
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone3
		pointLight.Range = 40
		pointLight.Brightness = 1
		pointLight.Color = Color3.fromRGB(255, 0, 4)
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	elseif special == "Spinosaurus" then
		local clone = ReplicatedStorage.Chest.FruitEffect.Spino.Geppo:Clone()
		clone.CFrame = rootPart.CFrame * CFrame.new(0, -25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		PolyLib:ParticleHandler(clone)
		_G.PU:Dust(clone, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://130927262749268",
			Volume = 0.7
		})
		_G.PU:Dust(sound, 2)
		sound.Parent = rootPart
		sound:Play()
		local v3 = {}
		PeodizService.HeartbeatWait({
			Time = 0.35
		}, function(p)
			local cFrame = clone.CFrame
			local v4 = math.floor(p)
			local v5 = p - v4
			v3[v4] = v3[v4] or {}
			local clones = v3[v4]

			local function getTrail(p2)
				local clone2 = clones[p2]

				if clone2 then
					return clone2
				end

				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Parent = workspace.Effects
				clones[p2] = clone2
				_G.PU:Dust(clone2, 3)
				return clone2
			end

			local clone2 = clones[1]

			if not clone2 then
				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false
				clone2.Parent = workspace.Effects
				clones[1] = clone2
				_G.PU:Dust(clone2, 3)
			end

			local clone3 = clones[2]

			if not clone3 then
				clone3 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone3.CFrame = cFrame
				clone3.Anchored = true
				clone3.CanCollide = false
				clone3.Parent = workspace.Effects
				clones[2] = clone3
				_G.PU:Dust(clone3, 3)
			end

			local lookVector = clone.CFrame.LookVector
			local v6 = createVector(0, 1, 0)
			local unit = lookVector:Cross(math.abs((lookVector:Dot(v6))) > 0.999 and createVector(1, 0, 0) or v6).Unit
			local unit2 = unit:Cross(lookVector).Unit
			local v7 = 40 + -10 * v5
			local v8 = 6.283185307179586 * v5
			local v9 = 2.399963159042158 * v4
			local v10 = 15 * v5
			local v11 = { 0, 3.141592653589793 }

			for i = 1, 2 do
				local v12 = v8 + v9 + v11[i]
				local v13 = v7 * math.sin(v12)
				local v14 = v7 * math.cos(v12)
				local v15 = cFrame.p + unit * v13 + unit2 * v14 + lookVector * v10;
				(i == 1 and clone2 or clone3).CFrame = CFrame.new(v15, v15 + lookVector)
			end
		end)
	elseif special == "Allosaurus" then
		local clone = ReplicatedStorage.Chest.FruitEffect.Allo.Geppo:Clone()
		clone.CFrame = rootPart.CFrame * CFrame.new(0, -25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		PolyLib:ParticleHandler(clone)
		_G.PU:Dust(clone, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://130927262749268",
			Volume = 0.7
		})
		_G.PU:Dust(sound, 2)
		sound.Parent = rootPart
		sound:Play()
		local v3 = {}
		PeodizService.HeartbeatWait({
			Time = 0.35
		}, function(p)
			local cFrame = clone.CFrame
			local v4 = math.floor(p)
			local v5 = p - v4
			v3[v4] = v3[v4] or {}
			local clones = v3[v4]

			local function getTrail(p2)
				local clone2 = clones[p2]

				if clone2 then
					return clone2
				end

				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false

				if clone2:FindFirstChild("neon") then
					clone2.neon.Color = ColorSequence.new(Color3.fromRGB(255, 47, 47))
				end

				clone2.Parent = workspace.Effects
				clones[p2] = clone2
				_G.PU:Dust(clone2, 3)
				return clone2
			end

			local trail = getTrail(1)
			local trail2 = getTrail(2)
			local lookVector = clone.CFrame.LookVector
			local v6 = createVector(0, 1, 0)
			local unit = lookVector:Cross(math.abs((lookVector:Dot(v6))) > 0.999 and createVector(1, 0, 0) or v6).Unit
			local unit2 = unit:Cross(lookVector).Unit
			local v7 = 40 + -10 * v5
			local v8 = 6.283185307179586 * v5
			local v9 = 2.399963159042158 * v4
			local v10 = 15 * v5
			local v11 = { 0, 3.141592653589793 }

			for i = 1, 2 do
				local v12 = v8 + v9 + v11[i]
				local v13 = v7 * math.sin(v12)
				local v14 = v7 * math.cos(v12)
				local v15 = cFrame.p + unit * v13 + unit2 * v14 + lookVector * v10;
				(i == 1 and trail or trail2).CFrame = CFrame.new(v15, v15 + lookVector)
			end
		end)
	elseif special == "Demon_KL" then
		local clone = ReplicatedStorage.Chest.FruitEffect.Demon.Geppo:Clone()
		clone.CFrame = rootPart.CFrame * CFrame.new(0, -25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		PolyLib:ParticleHandler(clone)
		_G.PU:Dust(clone, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://76670974907942",
			Volume = 0.15
		})
		_G.PU:Dust(sound, 2)
		sound.Parent = rootPart
		sound:Play()
		local v3 = {}
		PeodizService.HeartbeatWait({
			Time = 0.35
		}, function(p)
			local cFrame = clone.CFrame
			local v4 = math.floor(p)
			local v5 = p - v4
			v3[v4] = v3[v4] or {}
			local clones = v3[v4]

			local function getTrail(p2)
				local clone2 = clones[p2]

				if clone2 then
					return clone2
				end

				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false

				if clone2:FindFirstChild("neon") then
					clone2.neon.Color = ColorSequence.new(Color3.fromRGB(255, 63, 24))
				end

				clone2.Parent = workspace.Effects
				clones[p2] = clone2
				_G.PU:Dust(clone2, 3)
				return clone2
			end

			local trail = getTrail(1)
			local trail2 = getTrail(2)
			local lookVector = clone.CFrame.LookVector
			local v6 = createVector(0, 1, 0)
			local unit = lookVector:Cross(math.abs((lookVector:Dot(v6))) > 0.999 and createVector(1, 0, 0) or v6).Unit
			local unit2 = unit:Cross(lookVector).Unit
			local v7 = 40 + -10 * v5
			local v8 = 6.283185307179586 * v5
			local v9 = 2.399963159042158 * v4
			local v10 = 15 * v5
			local v11 = { 0, 3.141592653589793 }

			for i = 1, 2 do
				local v12 = v8 + v9 + v11[i]
				local v13 = v7 * math.sin(v12)
				local v14 = v7 * math.cos(v12)
				local v15 = cFrame.p + unit * v13 + unit2 * v14 + lookVector * v10;
				(i == 1 and trail or trail2).CFrame = CFrame.new(v15, v15 + lookVector)
			end
		end)
	elseif special == "Tree_KL" then
		local clone = ReplicatedStorage.Chest.FruitEffect.Tree.Geppo:Clone()
		clone.CFrame = rootPart.CFrame * CFrame.new(0, -35, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		PolyLib:ParticleHandler(clone)
		_G.PU:Dust(clone, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://130927262749268",
			Volume = 0.7
		})
		_G.PU:Dust(sound, 2)
		sound.Parent = rootPart
		sound:Play()
		local v3 = {}
		PeodizService.HeartbeatWait({
			Time = 0.35
		}, function(p)
			local cFrame = clone.CFrame
			local v4 = math.floor(p)
			local v5 = p - v4
			v3[v4] = v3[v4] or {}
			local clones = v3[v4]

			local function getTrail(p2)
				local clone2 = clones[p2]

				if clone2 then
					return clone2
				end

				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false

				if clone2:FindFirstChild("neon") then
					clone2.neon.Color = ColorSequence.new(Color3.fromRGB(128, 168, 67))
				end

				clone2.Parent = workspace.Effects
				clones[p2] = clone2
				_G.PU:Dust(clone2, 3)
				return clone2
			end

			local trail = getTrail(1)
			local trail2 = getTrail(2)
			local lookVector = clone.CFrame.LookVector
			local v6 = createVector(0, 1, 0)
			local unit = lookVector:Cross(math.abs((lookVector:Dot(v6))) > 0.999 and createVector(1, 0, 0) or v6).Unit
			local unit2 = unit:Cross(lookVector).Unit
			local v7 = 40 + -10 * v5
			local v8 = 6.283185307179586 * v5
			local v9 = 2.399963159042158 * v4
			local v10 = 15 * v5
			local v11 = { 0, 3.141592653589793 }

			for i = 1, 2 do
				local v12 = v8 + v9 + v11[i]
				local v13 = v7 * math.sin(v12)
				local v14 = v7 * math.cos(v12)
				local v15 = cFrame.p + unit * v13 + unit2 * v14 + lookVector * v10;
				(i == 1 and trail or trail2).CFrame = CFrame.new(v15, v15 + lookVector)
			end
		end)
	elseif special == "Brachiosaurus" then
		local clone = ReplicatedStorage.Chest.FruitEffect.Brachio.Geppo:Clone()
		clone.CFrame = rootPart.CFrame * CFrame.new(0, -25, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone.Parent = workspace.Effects
		PolyLib:ParticleHandler(clone)
		_G.PU:Dust(clone, 2)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 50,
			RollOffMode = Enum.RollOffMode.Inverse,
			SoundId = "rbxassetid://130927262749268",
			Volume = 0.7
		})
		_G.PU:Dust(sound, 2)
		sound.Parent = rootPart
		sound:Play()
		local v3 = {}
		PeodizService.HeartbeatWait({
			Time = 0.35
		}, function(p)
			local cFrame = clone.CFrame
			local v4 = math.floor(p)
			local v5 = p - v4
			v3[v4] = v3[v4] or {}
			local clones = v3[v4]

			local function getTrail(p2)
				local clone2 = clones[p2]

				if clone2 then
					return clone2
				end

				clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
				clone2.CFrame = cFrame
				clone2.Anchored = true
				clone2.CanCollide = false

				if clone2:FindFirstChild("neon") then
					clone2.neon.Color = ColorSequence.new(Color3.fromRGB(73, 100, 255))
				end

				clone2.Parent = workspace.Effects
				clones[p2] = clone2
				_G.PU:Dust(clone2, 3)
				return clone2
			end

			local trail = getTrail(1)
			local trail2 = getTrail(2)
			local lookVector = clone.CFrame.LookVector
			local v6 = createVector(0, 1, 0)
			local unit = lookVector:Cross(math.abs((lookVector:Dot(v6))) > 0.999 and createVector(1, 0, 0) or v6).Unit
			local unit2 = unit:Cross(lookVector).Unit
			local v7 = 40 + -10 * v5
			local v8 = 6.283185307179586 * v5
			local v9 = 2.399963159042158 * v4
			local v10 = 15 * v5
			local v11 = { 0, 3.141592653589793 }

			for i = 1, 2 do
				local v12 = v8 + v9 + v11[i]
				local v13 = v7 * math.sin(v12)
				local v14 = v7 * math.cos(v12)
				local v15 = cFrame.p + unit * v13 + unit2 * v14 + lookVector * v10;
				(i == 1 and trail or trail2).CFrame = CFrame.new(v15, v15 + lookVector)
			end
		end)
	else
		task.spawn(function()
			local clone = ReplicatedStorage.Chest.Etc.Part56:Clone()
			_G.PU:Dust(clone, debris)
			clone.CFrame = CFrame.new(rootPart.Position, rootPart.Position + rootPart.Velocity) * CFrame.new(0, 0, 4)
			clone.Parent = workspace.Effects
			local step = math.floor(debris * 5)
			PeodizService.ForLoop({
				Step = step,
				WaitTime = 0.05
			}, function(_)
				clone.CFrame = CFrame.new(rootPart.Position, rootPart.Position + rootPart.Velocity) * CFrame.new(
					0,
					0,
					4
				)

				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		end)
		local clone = ReplicatedStorage.Chest.FruitEffect.SkyJump.Rings:Clone()
		_G.PU:Dust(clone, 0.6)
		clone.Size = createVector(4, 2, 4)
		clone.Transparency = 0
		clone.CFrame = CFrame.new(v2.Position, v2.Position + rootPart.Velocity) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
			Size = createVector(15, 0, 15),
			CFrame = clone.CFrame * CFrame.new(0, -3, 0),
			Transparency = 1
		}):Play()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 250,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://15425594935",
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		PeodizService.ForLoop({
			Step = 6
		}, function(_)
			local v3 = math.random(1, 5)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.SkyJump.Smoke:Clone()
			clone2.Size = Vector3.new(v3, v3, v3)
			clone2.CFrame = CFrame.new(v2.Position, v2.Position + rootPart.Velocity)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
				Size = createVector(0, 0, 0),
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
			}):Play()
		end)
	end
end

function Dash(_, _, data, _)
	task.spawn(function()
		local rootPart = data.RootPart
		local debris = data.Debris or 1
		local special = data.Special

		if special == "toytrex" then
			local velocity = rootPart.Velocity

			if velocity.Magnitude <= 0 then
				velocity = rootPart.CFrame.LookVector
			end

			local cFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, -5, 0)
			local clone = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_trail:Clone()
			_G.PU:Dust(clone, 2)
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_trail:Clone()
			_G.PU:Dust(clone2, 2)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_trail2:Clone()
			_G.PU:Dust(clone3, 2)
			clone3.CFrame = cFrame
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame * CFrame.new(0, 0, -50)
			}):Play()
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_fx:Clone()
			_G.PU:Dust(clone4, 2)
			clone4.CFrame = cFrame
			clone4.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://15881362881",
				Volume = 7
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone4
			sound:Play()
			task.spawn(function()
				PeodizService.HeartbeatWait({
					Time = 0.35,
					Tween = {
						EasingStyle = Enum.EasingStyle.Quad,
						EasingDirection = Enum.EasingDirection.Out
					}
				}, function(p)
					clone.CFrame = cFrame * CFrame.new(
						math.sin(9.42477796076938 * p) * 15,
						math.cos(9.42477796076938 * p) * 15,
						-p * 50
					)
					clone2.CFrame = cFrame * CFrame.new(
						-math.sin(9.42477796076938 * p) * 15,
						-math.cos(9.42477796076938 * p) * 15,
						-p * 50
					)
				end)
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end

			PeodizService.ForceForLoop({
				Step = 3,
				WaitTime = 0.03
			}, function(p)
				local v3 = math.floor(p * 3)
				local velocity2 = rootPart.Velocity

				if velocity2.Magnitude <= 0 then
					velocity2 = rootPart.CFrame.LookVector
				end

				cFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity2) * CFrame.new(0, -5, 0)
				local clone5 = ReplicatedStorage.Chest.FruitEffect.Toy.dino_assets.dash_fx2:Clone()
				clone5.Parent = workspace.Effects
				clone5.CFrame = cFrame * CFrame.new(0, 0, 16.666666666666668) * CFrame.new(0, 0, -v3 * 50 / 3)
				_G.PU:Dust(clone5, 1)
				clone5.Ring:Emit(1)
				local pointLight = Instance.new("PointLight")
				pointLight.Parent = clone5
				pointLight.Range = 30
				pointLight.Brightness = 0.75
				pointLight.Color = Color3.fromRGB(255, 0, 4)
				TweenService:Create(
					pointLight,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				):Play()
			end)
		elseif special == "Spinosaurus" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://87334254290797",
					Volume = 0.15
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName
				local velocity = rootPart.Velocity

				if velocity.Magnitude <= 0 then
					velocity = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "AnimationF1" or animName == "AnimationF2" then
						v2 = 3.141592653589793
					elseif animName == "AnimationB" then
						v2 = 0
					elseif animName == "AnimationL" then
						v2 = -1.5707963267948966
					elseif animName == "AnimationR" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local cFrame2 = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, -5, 0) * CFrame.Angles(
					0,
					v2,
					0
				)
				local clone = ReplicatedStorage.Chest.FruitEffect.Spino.Dash:Clone()
				clone.CFrame = cFrame2
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v4 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v5 = math.floor(p)
					local v6 = p - v5
					v4[v5] = v4[v5] or {}
					local clones = v4[v5]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local clone2 = clones[1]

					if not clone2 then
						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[1] = clone2
						_G.PU:Dust(clone2, 3)
					end

					local clone3 = clones[2]

					if not clone3 then
						clone3 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone3.CFrame = cFrame
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Parent = workspace.Effects
						clones[2] = clone3
						_G.PU:Dust(clone3, 3)
					end

					local lookVector = clone.CFrame.LookVector
					local v7 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v7))) > 0.999 and createVector(1, 0, 0) or v7).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v8 = 20 + -12 * v6
					local v9 = 6.283185307179586 * v6
					local v10 = 2.399963159042158 * v5
					local v11 = 70 * v6
					local v12 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v13 = v9 + v10 + v12[i]
						local v14 = v8 * math.sin(v13)
						local v15 = v8 * math.cos(v13)
						local v16 = cFrame.p + unit * v14 + unit2 * v15 + lookVector * v11;
						(i == 1 and clone2 or clone3).CFrame = CFrame.new(v16, v16 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Allosaurus" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://109127807565680",
					Volume = 0.15
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName
				local velocity = rootPart.Velocity

				if velocity.Magnitude <= 0 then
					velocity = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "AnimationF1" or animName == "AnimationF2" then
						v2 = 3.141592653589793
					elseif animName == "AnimationB" then
						v2 = 0
					elseif animName == "AnimationL" then
						v2 = -1.5707963267948966
					elseif animName == "AnimationR" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local cFrame2 = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, -5, 0) * CFrame.Angles(
					0,
					v2,
					0
				)
				local clone = ReplicatedStorage.Chest.FruitEffect.Allo.Dash:Clone()
				clone.CFrame = cFrame2
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v4 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v5 = math.floor(p)
					local v6 = p - v5
					v4[v5] = v4[v5] or {}
					local clones = v4[v5]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false

						if clone2:FindFirstChild("neon") then
							clone2.neon.Color = ColorSequence.new(Color3.fromRGB(255, 47, 47))
						end

						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local trail = getTrail(1)
					local trail2 = getTrail(2)
					local lookVector = clone.CFrame.LookVector
					local v7 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v7))) > 0.999 and createVector(1, 0, 0) or v7).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v8 = 20 + -12 * v6
					local v9 = 6.283185307179586 * v6
					local v10 = 2.399963159042158 * v5
					local v11 = 70 * v6
					local v12 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v13 = v9 + v10 + v12[i]
						local v14 = v8 * math.sin(v13)
						local v15 = v8 * math.cos(v13)
						local v16 = cFrame.p + unit * v14 + unit2 * v15 + lookVector * v11;
						(i == 1 and trail or trail2).CFrame = CFrame.new(v16, v16 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Tree_KL" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://107565071286615",
					Volume = 0.4
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName
				local velocity = rootPart.Velocity

				if velocity.Magnitude <= 0 then
					velocity = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "AnimationF1" or animName == "AnimationF2" then
						v2 = 3.141592653589793
					elseif animName == "AnimationB" then
						v2 = 0
					elseif animName == "AnimationL" then
						v2 = -1.5707963267948966
					elseif animName == "AnimationR" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local cFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, -5, 0) * CFrame.Angles(
					0,
					v2,
					0
				)
				local clone = ReplicatedStorage.Chest.FruitEffect.Tree.Dash:Clone()
				clone:PivotTo(cFrame)
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v4 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame2 = cFrame
					local v6 = math.floor(p)
					local v7 = p - v6
					v4[v6] = v4[v6] or {}
					local clones = v4[v6]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame2
						clone2.Anchored = true
						clone2.CanCollide = false

						if clone2:FindFirstChild("neon") then
							clone2.neon.Color = ColorSequence.new(Color3.fromRGB(128, 168, 67))
						end

						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local trail = getTrail(1)
					local trail2 = getTrail(2)
					local lookVector = cFrame.LookVector
					local v8 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v8))) > 0.999 and createVector(1, 0, 0) or v8).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v9 = 20 + -12 * v7
					local v10 = 6.283185307179586 * v7
					local v11 = 2.399963159042158 * v6
					local v12 = 70 * v7
					local v13 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v14 = v10 + v11 + v13[i]
						local v15 = v9 * math.sin(v14)
						local v16 = v9 * math.cos(v14)
						local v17 = cFrame2.p + unit * v15 + unit2 * v16 + lookVector * v12;
						(i == 1 and trail or trail2).CFrame = CFrame.new(v17, v17 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Brachiosaurus" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://107565071286615",
					Volume = 0.4
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName
				local velocity = rootPart.Velocity

				if velocity.Magnitude <= 0 then
					velocity = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "AnimationF1" or animName == "AnimationF2" then
						v2 = 3.141592653589793
					elseif animName == "AnimationB" then
						v2 = 0
					elseif animName == "AnimationL" then
						v2 = -1.5707963267948966
					elseif animName == "AnimationR" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local cFrame2 = CFrame.new(rootPart.Position, rootPart.Position + velocity) * CFrame.new(0, -5, 0) * CFrame.Angles(
					0,
					v2,
					0
				)
				local clone = ReplicatedStorage.Chest.FruitEffect.Brachio.Dash:Clone()
				clone.CFrame = cFrame2
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v4 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v5 = math.floor(p)
					local v6 = p - v5
					v4[v5] = v4[v5] or {}
					local clones = v4[v5]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false

						if clone2:FindFirstChild("neon") then
							clone2.neon.Color = ColorSequence.new(Color3.fromRGB(73, 100, 255))
						end

						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local trail = getTrail(1)
					local trail2 = getTrail(2)
					local lookVector = clone.CFrame.LookVector
					local v7 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v7))) > 0.999 and createVector(1, 0, 0) or v7).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v8 = 20 + -12 * v6
					local v9 = 6.283185307179586 * v6
					local v10 = 2.399963159042158 * v5
					local v11 = 70 * v6
					local v12 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v13 = v9 + v10 + v12[i]
						local v14 = v8 * math.sin(v13)
						local v15 = v8 * math.cos(v13)
						local v16 = cFrame.p + unit * v14 + unit2 * v15 + lookVector * v11;
						(i == 1 and trail or trail2).CFrame = CFrame.new(v16, v16 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Demon_KL" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://76670974907942",
					Volume = 0.15
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName

				if rootPart.Velocity.Magnitude <= 0 then
					local _ = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "AnimationF1" or animName == "AnimationF2" then
						v2 = 3.141592653589793
					elseif animName == "AnimationB" then
						v2 = 0
					elseif animName == "AnimationL" then
						v2 = -1.5707963267948966
					elseif animName == "AnimationR" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local _, v3, _ = (rootPart.CFrame * CFrame.Angles(0, v2, 0)):ToOrientation()
				local v4 = CFrame.fromOrientation(0, v3, 0) + rootPart.Position
				local clone = ReplicatedStorage.Chest.FruitEffect.Demon.Dash:Clone()
				clone.CFrame = v4 * CFrame.new(0, 0, 20)
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v5 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v6 = math.floor(p)
					local v7 = p - v6
					v5[v6] = v5[v6] or {}
					local clones = v5[v6]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Spino.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false

						if clone2:FindFirstChild("neon") then
							clone2.neon.Color = ColorSequence.new(Color3.fromRGB(255, 63, 24))
						end

						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local trail = getTrail(1)
					local trail2 = getTrail(2)
					local lookVector = clone.CFrame.LookVector
					local v8 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v8))) > 0.999 and createVector(1, 0, 0) or v8).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v9 = 20 + -12 * v7
					local v10 = 6.283185307179586 * v7
					local v11 = 2.399963159042158 * v6
					local v12 = 70 * v7
					local v13 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v14 = v10 + v11 + v13[i]
						local v15 = v9 * math.sin(v14)
						local v16 = v9 * math.cos(v14)
						local v17 = cFrame.p + unit * v15 + unit2 * v16 + lookVector * v12;
						(i == 1 and trail or trail2).CFrame = CFrame.new(v17, v17 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Pteranodon_KL" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://76670974907942",
					Volume = 0.15
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName

				if rootPart.Velocity.Magnitude <= 0 then
					local _ = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "DashFront" then
						v2 = 3.141592653589793
					elseif animName == "DashBack" then
						v2 = 0
					elseif animName == "DashLeft" then
						v2 = -1.5707963267948966
					elseif animName == "DashRight" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local _, v3, _ = (rootPart.CFrame * CFrame.Angles(0, v2, 0)):ToOrientation()
				local v4 = CFrame.fromOrientation(0, v3, 0) + rootPart.Position
				local clone = ReplicatedStorage.Chest.FruitEffect.Pter.Dash:Clone()
				clone.CFrame = v4 * CFrame.new(0, 0, 20)
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v5 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v6 = math.floor(p)
					local v7 = p - v6
					v5[v6] = v5[v6] or {}
					local clones = v5[v6]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Pter.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local clone2 = clones[1]

					if not clone2 then
						clone2 = ReplicatedStorage.Chest.FruitEffect.Pter.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[1] = clone2
						_G.PU:Dust(clone2, 3)
					end

					local clone3 = clones[2]

					if not clone3 then
						clone3 = ReplicatedStorage.Chest.FruitEffect.Pter.dash_trail:Clone()
						clone3.CFrame = cFrame
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Parent = workspace.Effects
						clones[2] = clone3
						_G.PU:Dust(clone3, 3)
					end

					local lookVector = clone.CFrame.LookVector
					local v8 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v8))) > 0.999 and createVector(1, 0, 0) or v8).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v9 = 20 + -12 * v7
					local v10 = 6.283185307179586 * v7
					local v11 = 2.399963159042158 * v6
					local v12 = 70 * v7
					local v13 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v14 = v10 + v11 + v13[i]
						local v15 = v9 * math.sin(v14)
						local v16 = v9 * math.cos(v14)
						local v17 = cFrame.p + unit * v15 + unit2 * v16 + lookVector * v12;
						(i == 1 and clone2 or clone3).CFrame = CFrame.new(v17, v17 + lookVector)
					end
				end)
			end

			DashFX()
		elseif special == "Phoenix_Model" then
			local function DashFX()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 500,
					RollOffMinDistance = 50,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://78047908065664",
					Volume = 0.15
				})
				_G.PU:Dust(sound, 2)
				sound.Parent = rootPart
				sound:Play()
				local animName = data.AnimName

				if rootPart.Velocity.Magnitude <= 0 then
					local _ = rootPart.CFrame.LookVector
				end

				local v2 = 0

				if animName then
					if animName == "DashFront" then
						v2 = 3.141592653589793
					elseif animName == "DashBack" then
						v2 = 0
					elseif animName == "DashLeft" then
						v2 = -1.5707963267948966
					elseif animName == "DashRight" then
						v2 = 1.5707963267948966
					else
						v2 = v2
					end
				end

				local _, v3, _ = (rootPart.CFrame * CFrame.Angles(0, v2, 0)):ToOrientation()
				local v4 = CFrame.fromOrientation(0, v3, 0) + rootPart.Position
				local clone = ReplicatedStorage.Chest.FruitEffect.Phoenix.Awake.Dash:Clone()
				clone.CFrame = v4 * CFrame.new(0, 0, 20)
				clone.Parent = workspace.Effects
				PolyLib:ParticleHandler(clone)
				_G.PU:Dust(clone, 2)
				local v5 = {}
				PeodizService.HeartbeatWait({
					Time = 0.3
				}, function(p)
					local cFrame = clone.CFrame
					local v6 = math.floor(p)
					local v7 = p - v6
					v5[v6] = v5[v6] or {}
					local clones = v5[v6]

					local function getTrail(p2)
						local clone2 = clones[p2]

						if clone2 then
							return clone2
						end

						clone2 = ReplicatedStorage.Chest.FruitEffect.Phoenix.Awake.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[p2] = clone2
						_G.PU:Dust(clone2, 3)
						return clone2
					end

					local clone2 = clones[1]

					if not clone2 then
						clone2 = ReplicatedStorage.Chest.FruitEffect.Phoenix.Awake.dash_trail:Clone()
						clone2.CFrame = cFrame
						clone2.Anchored = true
						clone2.CanCollide = false
						clone2.Parent = workspace.Effects
						clones[1] = clone2
						_G.PU:Dust(clone2, 3)
					end

					local clone3 = clones[2]

					if not clone3 then
						clone3 = ReplicatedStorage.Chest.FruitEffect.Phoenix.Awake.dash_trail:Clone()
						clone3.CFrame = cFrame
						clone3.Anchored = true
						clone3.CanCollide = false
						clone3.Parent = workspace.Effects
						clones[2] = clone3
						_G.PU:Dust(clone3, 3)
					end

					local lookVector = clone.CFrame.LookVector
					local v8 = createVector(0, 1, 0)
					local unit = lookVector:Cross(math.abs((lookVector:Dot(v8))) > 0.999 and createVector(1, 0, 0) or v8).Unit
					local unit2 = unit:Cross(lookVector).Unit
					local v9 = 20 + -12 * v7
					local v10 = 6.283185307179586 * v7
					local v11 = 2.399963159042158 * v6
					local v12 = 70 * v7
					local v13 = { 0, 3.141592653589793 }

					for i = 1, 2 do
						local v14 = v10 + v11 + v13[i]
						local v15 = v9 * math.sin(v14)
						local v16 = v9 * math.cos(v14)
						local v17 = cFrame.p + unit * v15 + unit2 * v16 + lookVector * v12;
						(i == 1 and clone2 or clone3).CFrame = CFrame.new(v17, v17 + lookVector)
					end
				end)
			end

			DashFX()
		else
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 250,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://3084314259",
				PlaybackSpeed = 1.35,
				Volume = 0.2
			})
			_G.PU:Dust(sound, 1)
			sound.Parent = rootPart
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 250,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://10897057140",
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 1)
			sound2.Parent = rootPart
			sound2:Play()
			task.spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(rootPart.Position, createVector(0, -10, 0), raycastParams)
				local position = rootPart.Position + createVector(0, -10, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if instance then
					local clone = ReplicatedStorage.Chest.Etc.DashGroup:Clone()
					_G.PU:Dust(clone, 1)
					local upperTorso = rootPart.Parent:FindFirstChild("UpperTorso")

					if upperTorso then
						clone.DashSoru.dash.Color = ColorSequence.new(upperTorso.Color)
					end

					clone.Parent = workspace.Effects
					clone:PivotTo(rootPart.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0))
					Utility.EmitParticles(clone)
					local clone2 = ReplicatedStorage.Chest.Etc["Rush Trail"].Part:Clone()
					clone2.Dust.Rate = 200
					clone2.Dust.Color = ColorSequence.new(instance.Color)
					clone2.CFrame = CFrame.new(position)
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, debris)
					tick()
					clone2.Dust.Enabled = true

					if not data.Num then
						math.floor(debris * 4)
					end

					local velocity = rootPart.Velocity

					if velocity.Magnitude <= 0 then
						velocity = rootPart.CFrame.LookVector
					end

					local clone3 = ReplicatedStorage.Chest.Etc["Rush Trail"].Dash:Clone()
					_G.PU:Dust(clone3, 3)
					clone3.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity)
					clone3.Parent = workspace.Effects

					for _, emitter in pairs(clone3:GetChildren()) do
						if emitter:IsA("ParticleEmitter") then
							emitter:Destroy()
						end
					end

					local lastTime = tick()
					PeodizService.HeartbeatWait({
						Time = debris / 2.5
					}, function()
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterType = Enum.RaycastFilterType.Include
						raycastParams2.FilterDescendantsInstances = { workspace.Island }
						local raycastResult2 = workspace:Raycast(
							rootPart.Position,
							createVector(0, -15, 0),
							raycastParams
						)
						local position2 = rootPart.Position + createVector(0, -10, 0)
						local instance2

						if raycastResult2 then
							instance2 = raycastResult2.Instance
							position2 = raycastResult2.Position
						end

						if instance2 then
							clone2.CFrame = CFrame.new(position2)
						else
							clone2.CFrame = rootPart.CFrame * CFrame.new(0, -3.5, 0)
						end

						if tick() - lastTime > 0.05 then
							lastTime = tick()
							local velocity2 = rootPart.Velocity

							if velocity2.Magnitude <= 0 then
								velocity2 = rootPart.CFrame.LookVector
							end

							clone3.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity2)
							Utility.EmitParticles(clone3)
						end
					end)

					if clone2 and clone2:FindFirstChild("Dust") then
						clone2.Dust.Enabled = false
					end
				else
					local clone = ReplicatedStorage.Chest.Etc["Rush Trail"].Part1:Clone()
					_G.PU:Dust(clone, 3)
					clone.CFrame = rootPart.CFrame * CFrame.new(0, 0, 2)
					clone.Parent = workspace.Effects

					for _, effect in pairs(clone:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = true
					end

					local num = data.Num or math.floor(debris * 4)
					local velocity = rootPart.Velocity

					if velocity.Magnitude <= 0 then
						velocity = rootPart.CFrame.LookVector
					end

					local clone2 = ReplicatedStorage.Chest.Etc["Rush Trail"].Dash:Clone()
					_G.PU:Dust(clone2, 3)
					clone2.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity)
					clone2.Parent = workspace.Effects
					PeodizService.ForLoop({
						Step = num,
						WaitTime = 0.05
					}, function(_)
						local velocity2 = rootPart.Velocity

						if velocity2.Magnitude <= 0 then
							velocity2 = rootPart.CFrame.LookVector
						end

						clone.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity2) * CFrame.new(
							0,
							0,
							4
						)
						clone2.CFrame = CFrame.new(rootPart.Position, rootPart.Position + velocity2)
						Utility.EmitParticles(clone2)
					end)

					for _, effect in pairs(clone:GetDescendants()) do
						if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
							continue
						end

						effect.Enabled = false
					end
				end
			end)
		end
	end)
end

function MonsterSmasher(character, _, _, _)
	if character:FindFirstChild("Character") then
		character = character.Character
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Effects,
		workspace.PlayerCharacters,
		workspace.CharacterWorkshop
	}
	local raycastResult = workspace:Raycast(
		character.HumanoidRootPart.Position,
		character.HumanoidRootPart.CFrame.upVector * -(character.Humanoid.HipHeight * 4),
		raycastParams
	)
	local position = character.HumanoidRootPart.Position + character.HumanoidRootPart.CFrame.upVector * -(character.Humanoid.HipHeight * 4)
	local instance

	if raycastResult then
		instance = raycastResult.Instance
		position = raycastResult.Position
	end

	if instance then
		local cframe = CFrame.new(position)

		for i = 1, 20 do
			local part = Instance.new("Part")
			part.CanCollide = false
			part.Anchored = true
			part.Size = createVector(35, 35, 35)
			part.CFrame = cframe * CFrame.Angles(0, i * 18, 0)
			part.CFrame *= CFrame.new(0, -5, 0)
			part.Material = instance.Material
			part.Color = instance.Color
			part.Parent = workspace.Effects
			local _ = part.CFrame * CFrame.new(0, 2, -10)
			local cFrame = part.CFrame * CFrame.new(0, 2, -150) * CFrame.Angles(
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
						CFrame = CFrame.new(part.Position) * CFrame.new(0, -17.5, 0)
					}
				):Play()
				_G.PU:Dust(part, 0.5)
			end)
		end
	end
end

function RockFall(_, _, list, _)
	local v2, v3, v4, v5 = unpack(list)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Effects,
		workspace.PlayerCharacters,
		workspace.CharacterWorkshop
	}
	local raycastResult = workspace:Raycast(
		v2.HumanoidRootPart.Position,
		v2.HumanoidRootPart.CFrame.upVector * -(v2.Humanoid.HipHeight * 4),
		raycastParams
	)
	local _ = v2.HumanoidRootPart.Position + v2.HumanoidRootPart.CFrame.upVector * -(v2.Humanoid.HipHeight * 4)
	local instance

	if raycastResult then
		instance = raycastResult.Instance
		local _ = raycastResult.Position
	end

	if instance then
		for _ = 1, 3 do
			local clone = script.Part:Clone()
			clone.Parent = workspace.Effects
			local v6 = math.random(v4, v5)
			clone.Size = Vector3.new(v6, v6, v6)
			clone.CFrame = v3 * CFrame.new(math.rad(-45, 45), 0, (math.rad(-45, 45))) * CFrame.Angles(
				math.rad((math.random(-360, 360))),
				math.rad((math.random(-360, 360))),
				(math.rad((math.random(-360, 360))))
			)
			clone.Velocity = Vector3.new(math.random(-45, 45), math.random(125, 150), math.random(-45, 45))
			clone.Anchored = false
			clone.Material = instance.Material
			clone.Color = instance.Color
			clone.Massless = true
			clone.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
			_G.PU:Dust(clone, 3)
		end
	end
end

function Bomb_Z_Awake(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 100 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local clone = ReplicatedStorage.Chest.Etc.PartSound:Clone()
		clone.CFrame = cFrame2
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6986308351",
			Volume = 1.5
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Transparency = -1
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new()
		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(213, 115, 0)
		part.CastShadow = false
		part.CFrame = cFrame2
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(75, 75, 75),
			Transparency = 1
		}):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 2.5
		pointLight.Color = Color3.fromRGB(255, 85, 0)
		pointLight.Range = 8
		pointLight.Parent = part
		_G.PU:Dust(pointLight, 1)
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 50
		}):Play()
		spawn(function()
			for i = 1, 3 do
				local v4 = i
				local cFrame3 = cFrame2 * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
				spawn(function()
					local clone2 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
					clone2.Color = Color3.fromRGB(170, 85, 0)

					if v4 == 3 then
						clone2.Color = Color3.fromRGB(255, 85, 0)
					elseif v4 == 2 then
						clone2.Color = Color3.fromRGB(255, 110, 0)
					end

					clone2.CFrame = cFrame3
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 2)
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = createVector(50, 50, 50)
					}):Play()
					TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad), {
						CFrame = clone2.CFrame * CFrame.Angles(
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random()
						)
					}):Play()
					wait(0.25)
					TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new()
					})
					TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new(),
						Color = Color3.fromRGB()
					}):Play()
				end)
			end
		end)
		spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(
				cFrame2.p + createVector(0, 5, 0),
				createVector(0, -15, 0),
				raycastParams
			)
			local position = cFrame2.p + createVector(0, 5, 0) + createVector(0, -15, 0)
			local instance, normal

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
				normal = raycastResult.Normal
			else
				normal = createVector(0, -1, 0)
			end

			if instance then
				local clone2 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
				clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 5)

				for _ = 1, 3 do
					clone2.Attachment.Smoke:Emit(10)
					wait()
				end
			elseif not instance then
				local clone2 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
				clone2.CFrame = CFrame.new(cFrame2.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 5)

				for _ = 1, 3 do
					clone2.Attachment.Smoke:Emit(10)
					wait()
				end
			end
		end)
	end)
end

function Bomb_Z_Rings(_, _, list, _)
	local v2 = unpack(list)
	spawn(function()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.25
		}, function()
			if not v2:IsDescendantOf(workspace.Effects) then
				return true
			end

			local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CFrame = v2.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = createVector(15, 0.5, 15),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 0.5)
		end)
	end)
end

function Bomb_X_Rings(character, _, list, _)
	local v2, v3 = unpack(list)

	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		if (character.UpperTorso.Position - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 50 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Wind.Attachment:Clone()
		clone.Slash.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 75) })
		clone.Parent = character.UpperTorso
		spawn(function()
			for _ = 1, 3 do
				clone.Slash:Emit(2)
				wait()
			end
		end)
		_G.PU:Dust(clone, 1)
		tick()
		PeodizService.HeartbeatWait({
			Time = 10,
			WaitTime = 0.2
		}, function()
			if not v2:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
				return true
			end

			local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.CFrame = CFrame.new(v2.Position, v3.p) * CFrame.Angles(-1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Size = createVector(30, 1, 30),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.5)
		end)
	end)
end

function Bomb_X_Awake(_, cFrame, _, _)
	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Transparency = -1
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new()
		part.Material = Enum.Material.ForceField
		part.Color = Color3.fromRGB(255, 85, 0)
		part.CastShadow = false
		part.CFrame = cFrame2
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(125, 125, 125),
			Transparency = 1
		}):Play()
		local clone = ReplicatedStorage.Chest.Etc.PartSound:Clone()
		clone.CFrame = cFrame2
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6986308351",
			Volume = 1
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 2.5
		pointLight.Color = Color3.fromRGB(255, 85, 0)
		pointLight.Range = 8
		pointLight.Parent = part
		_G.PU:Dust(pointLight, 1)
		TweenService:Create(pointLight, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0
		}):Play()
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Range = 150
		}):Play()
		spawn(function()
			for i = 1, 3 do
				local v4 = i
				local cFrame3 = cFrame2 * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
				spawn(function()
					local clone2 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
					clone2.Color = Color3.fromRGB(170, 85, 0)

					if v4 == 3 then
						clone2.Color = Color3.fromRGB(255, 85, 0)
					elseif v4 == 2 then
						clone2.Color = Color3.fromRGB(255, 110, 0)
					end

					clone2.CFrame = cFrame3
					clone2.Parent = workspace.Effects
					_G.PU:Dust(clone2, 2)
					TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = createVector(100, 100, 100)
					}):Play()
					TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad), {
						CFrame = clone2.CFrame * CFrame.Angles(
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random(),
							3.141592653589793 * math.random()
						)
					}):Play()
					wait(0.25)
					TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Size = Vector3.new(),
						Color = Color3.fromRGB()
					}):Play()
				end)
			end
		end)
		spawn(function()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(
				cFrame2.p + createVector(0, 5, 0),
				createVector(0, -15, 0),
				raycastParams
			)
			local position = cFrame2.p + createVector(0, 5, 0) + createVector(0, -15, 0)
			local instance, normal

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
				normal = raycastResult.Normal
			else
				normal = createVector(0, -1, 0)
			end

			local clone2 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
			clone2.Attachment.Smoke.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 20),
				NumberSequenceKeypoint.new(0.4, 20),
				NumberSequenceKeypoint.new(0.7, 5, 2.1),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone2.Attachment.Smoke.Acceleration = createVector(0, 100, 0)
			clone2.Attachment.Smoke.Speed = NumberRange.new(225)
			clone2.CFrame = CFrame.new(cFrame2.p)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 5)

			if instance then
				clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0)

				for _ = 1, 3 do
					clone2.Attachment.Smoke:Emit(10)
					wait()
				end
			elseif not instance then
				clone2.CFrame = CFrame.new(cFrame2.p)

				for _ = 1, 3 do
					clone2.Attachment.Smoke:Emit(10)
					wait()
				end
			end
		end)
	end)
end

function Bomb_C_Awake(character, cFrame, _, _)
	if character:IsA("Player") then
		character = character.Character
	end

	spawn(function()
		local cFrame2 = cFrame

		if (cFrame2.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		end

		spawn(function()
			local v3 = CFrame.new(character.HumanoidRootPart.CFrame.p) + createVector(0, 25, 0)

			for i = 1, 14 do
				local cframe = v3 * CFrame.Angles(0, 6.283185307179586 * i / 14, 0) * CFrame.new(0, 0, -3)
				local _, v4, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -50, 0), raycastParams)
				local position = cframe.Position + createVector(0, -50, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.CanCollide = false
				part.CastShadow = false
				part.Anchored = true
				part.Size = Vector3.new()
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.CFrame = CFrame.new(v3.X, position.Y, v3.Z) * CFrame.fromOrientation(0, v4, 0)
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				local v5 = math.random(80, 120) / 20
				TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					),
					Size = Vector3.new(v5 / 4, v5 / 4, v5 / 4)
				}):Play()
				spawn(function()
					wait(1)
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Position = part.Position + createVector(0, -1, 0),
						Transparency = 1
					}):Play()
				end)
			end
		end)
		local clone = ReplicatedStorage.Chest.Etc.PartSound:Clone()
		clone.CFrame = cFrame2
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6986308351",
			Volume = 2
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = clone
		sound:Play()

		for i = 1, 5 do
			local cFrame3 = cFrame2 * CFrame.new(0, 0, -i * i * 5)
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Transparency = -1
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new()
			part.Material = Enum.Material.ForceField
			part.Color = Color3.fromRGB(255, 85, 0)
			part.CastShadow = false
			part.CFrame = cFrame3
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(20, 20, 20) * i,
				Transparency = 1
			}):Play()
			local pointLight = Instance.new("PointLight")
			pointLight.Brightness = 2.5
			pointLight.Color = Color3.fromRGB(255, 85, 0)
			pointLight.Range = 8
			pointLight.Parent = part
			_G.PU:Dust(pointLight, 1)
			TweenService:Create(
				pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			):Play()
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Range = i * 25 * i
			}):Play()
			local v5 = i
			spawn(function()
				for i2 = 1, 3 do
					local v6 = i2
					spawn(function()
						local clone2 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
						clone2.Color = Color3.fromRGB(170, 85, 0)

						if v6 == 3 then
							clone2.Color = Color3.fromRGB(255, 85, 0)
						elseif v6 == 2 then
							clone2.Color = Color3.fromRGB(255, 110, 0)
						end

						clone2.CFrame = cFrame3
						clone2.Parent = workspace.Effects
						_G.PU:Dust(clone2, 2)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = createVector(15, 15, 15) * v5
							}
						):Play()
						TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad), {
							CFrame = clone2.CFrame * CFrame.Angles(
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random()
							)
						}):Play()
						wait(0.25)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new()
							}
						)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new(),
								Color = Color3.fromRGB()
							}
						):Play()
					end)
				end
			end)
			local v6 = i
			local cFrame4 = cFrame3
			spawn(function()
				local clone2 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
				clone2.Attachment.Smoke.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, v6 / 1.5 * 5),
					NumberSequenceKeypoint.new(0.4, v6 / 1.5 * 5),
					NumberSequenceKeypoint.new(0.7, v6 * 2, v6 / 1.5 * 1),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone2.Attachment.Smoke.EmissionDirection = "Bottom"
				clone2.Attachment.Smoke.Acceleration = Vector3.new(0, v6 * 15, 0)
				clone2.Attachment.Smoke.Speed = NumberRange.new(v6 * 40)
				clone2.CFrame = cFrame4
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 5)

				for i2 = 1, 3 do
					clone2.Attachment.Smoke:Emit(10)
					wait()
				end
			end)
			wait()
		end
	end)
end

function Bomb_V_Awake(_, _, p, _)
	local cFTbl = p.CFTbl
	spawn(function()
		PeodizService.ForceForLoop({
			Step = 15,
			WaitTime = 0.15
		}, function(p2)
			local cFrame = cFTbl[math.floor(p2 * 15)]

			if (cFrame.p - localPlayer.Character.HumanoidRootPart.CFrame.p).Magnitude <= 150 then
				_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			end

			local clone = ReplicatedStorage.Chest.Etc.PartSound:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 5)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://165970126",
				Volume = 1
			})
			_G.PU:Dust(sound, 5)
			sound.Parent = clone
			sound:Play()
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.Transparency = -1
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new()
			part.Material = Enum.Material.ForceField
			part.Color = Color3.fromRGB(213, 115, 0)
			part.CastShadow = false
			part.CFrame = cFrame
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(100, 100, 100),
				Transparency = 1
			}):Play()
			local pointLight = Instance.new("PointLight")
			pointLight.Brightness = 2.5
			pointLight.Color = Color3.fromRGB(255, 85, 0)
			pointLight.Range = 8
			pointLight.Parent = part
			_G.PU:Dust(pointLight, 1)
			TweenService:Create(
				pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			):Play()
			TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Range = 50
			}):Play()
			spawn(function()
				for i = 1, 3 do
					local v5 = i
					local cFrame2 = cFrame * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
					spawn(function()
						local clone2 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
						clone2.Color = Color3.fromRGB(170, 85, 0)

						if v5 == 3 then
							clone2.Color = Color3.fromRGB(255, 85, 0)
						elseif v5 == 2 then
							clone2.Color = Color3.fromRGB(255, 110, 0)
						end

						clone2.CFrame = cFrame2
						clone2.Parent = workspace.Effects
						_G.PU:Dust(clone2, 2)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{
								Size = createVector(80, 80, 80)
							}
						):Play()
						TweenService:Create(clone2, TweenInfo.new(2, Enum.EasingStyle.Quad), {
							CFrame = clone2.CFrame * CFrame.Angles(
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random(),
								3.141592653589793 * math.random()
							)
						}):Play()
						wait(0.25)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new()
							}
						)
						TweenService:Create(
							clone2,
							TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
							{
								Size = Vector3.new(),
								Color = Color3.fromRGB()
							}
						):Play()
					end)
				end
			end)
			spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(
					cFrame.p + createVector(0, 5, 0),
					createVector(0, -30, 0),
					raycastParams
				)
				local position = cFrame.p + createVector(0, 5, 0) + createVector(0, -30, 0)
				local instance, normal

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
					normal = raycastResult.Normal
				else
					normal = createVector(0, -1, 0)
				end

				local clone2 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
				clone2.Attachment.Smoke.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 10),
					NumberSequenceKeypoint.new(0.4, 10),
					NumberSequenceKeypoint.new(0.7, 5, 2.1),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone2.Attachment.Smoke.Acceleration = createVector(0, 100, 0)
				clone2.Attachment.Smoke.Speed = NumberRange.new(175)
				clone2.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
				clone2.CFrame = CFrame.new(cFrame.p)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(clone2, 5)

				if instance then
					clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0)

					for _ = 1, 3 do
						clone2.Attachment.Smoke:Emit(5)
						wait()
					end
				elseif not instance then
					clone2.CFrame = CFrame.new(cFrame.p)

					for _ = 1, 3 do
						clone2.Attachment.Smoke:Emit(5)
						wait()
					end
				end
			end)
		end)
	end)
end

function Bomb_E_Awake(player, _, list, _)
	local v2 = unpack(list)
	local humanoidRootPart = player.Character.HumanoidRootPart
	spawn(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Bomb.Part.Attachment:Clone()
		clone.Parent = player.Character.RightHand
		_G.PU:Dust(clone, 10)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		local clone2 = ReplicatedStorage.Chest.FruitEffect.Bomb.Part.Attachment:Clone()
		clone2.Parent = player.Character.LeftHand
		_G.PU:Dust(clone2, 10)

		for _, emitter in pairs(clone2:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		PeodizService.HeartbeatWait({
			Time = 15,
			WaitTime = 0.3
		}, function()
			if not v2:IsDescendantOf(player.Character) or player.Character.Humanoid.Health <= 0 then
				return true
			end

			for i = 1, 2 do
				local cFrame = humanoidRootPart.CFrame * CFrame.new(-2, 0, 0)

				if i == 2 then
					cFrame = humanoidRootPart.CFrame * CFrame.new(2, 0, 0)
				end

				local part = Instance.new("Part")
				part.Shape = Enum.PartType.Ball
				part.Transparency = -1
				part.Anchored = true
				part.CanCollide = false
				part.Size = Vector3.new()
				part.Material = Enum.Material.ForceField
				part.Color = Color3.fromRGB(213, 115, 0)
				part.CastShadow = false
				part.CFrame = cFrame
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 1)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(10, 10, 10),
					Transparency = 1
				}):Play()
				local clone3 = ReplicatedStorage.Chest.Etc.PartSound:Clone()
				clone3.CFrame = cFrame
				clone3.Parent = workspace.Effects
				_G.PU:Dust(clone3, 5)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://6986308351",
					Volume = 0.05
				})
				_G.PU:Dust(sound, 5)
				sound.Parent = clone3
				sound:Play()
				local pointLight = Instance.new("PointLight")
				pointLight.Brightness = 2.5
				pointLight.Color = Color3.fromRGB(255, 85, 0)
				pointLight.Range = 8
				pointLight.Parent = part
				_G.PU:Dust(pointLight, 1)
				TweenService:Create(
					pointLight,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0
					}
				):Play()
				TweenService:Create(
					pointLight,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Range = 30
					}
				):Play()
				spawn(function()
					for i2 = 1, 3 do
						local v5 = i2
						local cFrame2 = cFrame * CFrame.new(math.random(-0, 0), math.random(-0, 0), math.random(-0, 0))
						spawn(function()
							local clone4 = ReplicatedStorage.Chest.FruitEffect.Bomb.M:Clone()
							clone4.Color = Color3.fromRGB(170, 85, 0)

							if v5 == 3 then
								clone4.Color = Color3.fromRGB(255, 85, 0)
							elseif v5 == 2 then
								clone4.Color = Color3.fromRGB(255, 110, 0)
							end

							clone4.CFrame = cFrame2
							clone4.Parent = workspace.Effects
							_G.PU:Dust(clone4, 2)
							TweenService:Create(
								clone4,
								TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
								{
									Size = createVector(6.6666665, 6.6666665, 6.6666665)
								}
							):Play()
							TweenService:Create(clone4, TweenInfo.new(2, Enum.EasingStyle.Quad), {
								CFrame = clone4.CFrame * CFrame.Angles(
									3.141592653589793 * math.random(),
									3.141592653589793 * math.random(),
									3.141592653589793 * math.random()
								)
							}):Play()
							wait(0.25)
							TweenService:Create(
								clone4,
								TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
								{
									Size = Vector3.new()
								}
							)
							TweenService:Create(
								clone4,
								TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
								{
									Size = Vector3.new(),
									Color = Color3.fromRGB()
								}
							):Play()
						end)
					end
				end)
				spawn(function()
					local clone4 = ReplicatedStorage.Chest.Etc.PartPar:Clone()
					clone4.Attachment.Smoke.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.4, 1),
						NumberSequenceKeypoint.new(0.7, 1, 0.5),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone4.Attachment.Smoke.EmissionDirection = "Bottom"
					clone4.Attachment.Smoke.Acceleration = createVector(0, 0, 0)
					clone4.Attachment.Smoke.Speed = NumberRange.new(15)
					clone4.Attachment.Smoke.Color = ColorSequence.new(Color3.fromRGB(49, 49, 49))
					clone4.CFrame = cFrame
					clone4.Parent = workspace.Effects
					_G.PU:Dust(clone4, 5)

					for _ = 1, 3 do
						clone4.Attachment.Smoke:Emit(10)
						wait()
					end
				end)
			end
		end)

		for _, emitter in pairs(clone:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, emitter in pairs(clone2:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		_G.PU:Dust(clone, 2)
		_G.PU:Dust(clone2, 2)
	end)
end

function MetalTrident_Z(p, cFrame, list, _)
	local v2, v3 = unpack(list)
	local magnitude = (v2.Position - v3.p).Magnitude
	local v4 = (v2.Position - v3.p).Magnitude / 5
	local cframe = CFrame.new(v2.Position, v3.p)

	if localPlayer == p then
		PeoUtils.LerpCF(v2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), v3 * CFrame.new(0, 3, 0))
	end

	task.spawn(function()
		wait(0.5)
		v2.Velocity = createVector(0, 0, 0)
		v2.RotVelocity = createVector(0, 0, 0)
	end)
	local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Cyborgc:Clone()
	clone.Transparency = -1
	clone.Color = Color3.fromRGB(255, 255, 255)
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = Vector3.new(magnitude / 10, magnitude / 10, magnitude),
		CFrame = clone.CFrame * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	delay(0.1, function()
		TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude),
			Transparency = 1
		}):Play()
	end)
	_G.PU:Dust(clone, 1)
	local clone2 = ReplicatedStorage.Chest.Etc.MeshStorage.Shockwave:Clone()
	clone2.Transparency = -1
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.Size = createVector(25, 25, 40)
	clone2.CFrame = cFrame * CFrame.new(0, 0, -10) * CFrame.Angles(0, 3.141592653589793, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
		Size = clone2.Size * 2,
		Transparency = 1
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.6, Enum.EasingStyle.Exponential), {
		CFrame = clone2.CFrame * CFrame.new(0, 0, magnitude) * CFrame.Angles(0, 0, 9.42477796076938)
	}):Play()
	_G.PU:Dust(clone2, 3)
	spawn(function()
		for _ = 1, 7 do
			math.random(1, 2)
			local cFrame2 = cFrame * CFrame.Angles(
				math.rad((math.random(-45, 45))),
				math.rad((math.random(-45, 45))),
				0
			)
			local clone3 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone3.CastShadow = false
			clone3.Transparency = -1
			clone3.Size = Vector3.new(8, 8, math.random(40, 60))
			clone3.Color = Color3.fromRGB(255, 255, 255)
			clone3.CFrame = cFrame2
			clone3.Parent = workspace.Effects
			local v6 = math.random(25, 75)
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(),
				CFrame = cFrame2 * CFrame.new(0, 0, v6)
			}):Play()
			_G.PU:Dust(clone3, 0.3)
		end
	end)
	spawn(function()
		for i = 1, 5 do
			wait()
			local clone3 = ReplicatedStorage.Chest.Etc.MeshStorage.Tornado:Clone()
			clone3.Transparency = -1
			clone3.Color = Color3.fromRGB(255, 255, 255)
			clone3.CFrame = cframe * CFrame.new(0, 0, -v4 * i) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Size = createVector(40, 40, 40)
			clone3.Parent = workspace.Effects
			_G.PU:Dust(clone3, 0.3)
			TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			spawn(function()
				PeodizService.HeartbeatWait({
					Time = 5,
					WaitTime = 0.05
				}, function()
					if not clone3:IsDescendantOf(workspace.Effects) then
						return true
					end

					TweenService:Create(clone3, TweenInfo.new(0.05, Enum.EasingStyle.Sine), {
						CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}):Play()
				end)
			end)
		end
	end)
end

function MetalTrident_X(_, _, data, _)
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
	Color3.fromRGB(180, 180, 180)

	if localPlayer.Name == data.PlayerName then
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
		}, function(_)
			local v3 = bezier(numberValue2.Value / 100, data.CF1.p, data.Up.p, data.CF2.p)
			data.RootPart.CFrame = CFrame.new(v3) * (data.RootPart.CFrame - data.RootPart.CFrame.p)
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

	if (localPlayer.Character.HumanoidRootPart.Position - data.Position).Magnitude < 150 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
	end

	local cframe = CFrame.new(data.CF2.p)
	spawn(function()
		local clone = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
		clone.Attachment.Ball.Texture = "rbxassetid://1084970835"
		clone.CFrame = cframe
		clone.Parent = workspace.Effects
		clone.Attachment.Ball:Emit(20)
		_G.PU:Dust(clone, 1)

		for _ = 1, 13 do
			local cFrame = cframe * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
				math.rad((math.random(-90, 90))),
				math.rad((math.random(-90, 90))),
				0
			)
			local v3 = math.random(10, 30) / 5
			local v4 = math.random(25, 35) + 25
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Size = Vector3.new(v3, v3, math.random(30, 50))
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 0.275)
			TweenService:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				Size = Vector3.new(),
				CFrame = clone2.CFrame * CFrame.new(0, 0, v4)
			}):Play()
		end
	end)
	local clone = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
	clone.CastShadow = false
	clone.Transparency = 0.1
	clone.CFrame = cframe
	clone.Parent = workspace.Effects
	TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(100, 3, 100),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone, 0.5)
	local clone2 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockwave:Clone()
	clone2.CastShadow = false
	clone2.Size = Vector3.new()
	clone2.Color = Color3.fromRGB(255, 255, 255)
	clone2.Transparency = -1
	clone2.CFrame = cframe * CFrame.Angles(1.5707963267948966, 0, 0)
	clone2.Parent = workspace.Effects
	TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
		CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793),
		Size = createVector(70, 70, 7),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone2, 0.25)
	local clone3 = ReplicatedStorage.Chest.FruitEffect.Bari.Shock:Clone()
	clone3.Transparency = -1
	clone3.Color = Color3.fromRGB(255, 255, 255)
	clone3.Size = createVector(0, 25, 0)
	clone3.CFrame = cframe
	clone3.Parent = workspace.Effects
	TweenService:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = createVector(100, 10, 100),
		Transparency = 1
	}):Play()
	_G.PU:Dust(clone3, 1)
	spawn(function()
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local raycastResult = workspace:Raycast(cframe.p, createVector(0, -25, 0), raycastParams)
		local position = cframe.p + createVector(0, -25, 0)
		local instance

		if raycastResult then
			instance = raycastResult.Instance
			position = raycastResult.Position
		end

		if instance then
			local cframe2 = CFrame.new(position)

			for _ = 1, 7 do
				local part = Instance.new("Part")
				local v2 = math.random(2, 6)
				part.CanCollide = false
				part.Anchored = false
				part.Velocity = Vector3.new(math.random(-45, 45), math.random(75, 125), math.random(-45, 45))
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.Massless = true
				part.Size = Vector3.new(v2, v2, v2)
				part.Parent = workspace.Effects
				part.CFrame = cframe2 * CFrame.new(math.rad(-30, 30), 0, (math.rad(-30, 30))) * CFrame.Angles(
					math.rad((math.random(-360, 360))),
					math.rad((math.random(-360, 360))),
					(math.rad((math.random(-360, 360))))
				)
				part.RotVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
				_G.PU:Dust(part, 3)
			end
		end
	end)
	spawn(function()
		local v2 = CFrame.new(cframe.p) * CFrame.new(0, 25, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local raycastResult = workspace:Raycast(v2.p, createVector(0, -50, 0), raycastParams)
		local position = v2.p + createVector(0, -50, 0)
		local instance, normal

		if raycastResult then
			position = raycastResult.Position
			instance = raycastResult.Instance
			normal = raycastResult.Normal
			local _ = instance.Material
		else
			normal = createVector(0, -1, 0)
		end

		if instance then
			local clone4 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
			clone4.Decal.Transparency = 0.2
			clone4.Decal.Texture = "rbxassetid://7068839334"
			clone4.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			) * CFrame.new(0, -1, 0)
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone4, 1.5)
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://262562442",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone4
			sound:Play()
			TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Size = createVector(60, 0, 60)
			}):Play()
			spawn(function()
				wait(1)

				if clone4:FindFirstChild("Decal") then
					TweenService:Create(clone4.Decal, TweenInfo.new(0.25), {
						Transparency = 1
					}):Play()
				end
			end)
		end
	end)
	spawn(function()
		local v2 = CFrame.new(cframe.p) + createVector(0, 2, 0)

		for i = 1, 15 do
			local cframe2 = v2 * CFrame.Angles(0, 6.283185307179586 * i / 15, 0) * CFrame.new(0, 0, -30)
			local _, v3, _ = cframe2:ToOrientation()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(cframe2.Position, createVector(0, -25, 0), raycastParams)
			local position = cframe2.Position + createVector(0, -25, 0)
			local instance

			if raycastResult then
				instance = raycastResult.Instance
				position = raycastResult.Position
			end

			if not instance then
				continue
			end

			local part = Instance.new("Part")
			part.CanCollide = false
			part.CastShadow = false
			part.Anchored = true
			part.Size = createVector(1, 1, 1)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Color = instance.Color
			part.CFrame = CFrame.new(v2.X, position.Y, v2.Z) * CFrame.fromOrientation(0, v3, 0)
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 2)
			local v4 = math.random(70, 100) / 13
			TweenService:Create(part, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
				CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
					0,
					math.random(-20, 20) / 10,
					0
				) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
				Size = Vector3.new(v4 * 2.1, v4, v4)
			}):Play()
			spawn(function()
				wait(1)
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
					Position = part.Position + createVector(0, -1, 0),
					Transparency = 1
				}):Play()
			end)
		end
	end)
end

function Spirit_X(_, _, list, _)
	local v2, v3, v4, v5 = unpack(list)

	if v2 then
		local BoneRigScale = require(ReplicatedStorage.Chest.Modules.BoneRigScale)
		BoneRigScale(v2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), 10)
		v2.AnimationController:LoadAnimation(v4):Play(0.1, 1, 3)
	end

	wait(0.25)

	local function Lightning(p)
		local v6 = p * CFrame.new(0, 150, 0)
		local cFrame = v6 * CFrame.new(0, -150, 0)
		local unit = (cFrame.p - v6.p).Unit
		local v8 = (cFrame.p - v6.p).Magnitude / 3
		local v9 = math.random(1, 3) * 3
		local v10 = {}

		for i = 0, 3 do
			local vector2 = Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))

			if i == 0 or i == 3 then
				vector2 = Vector3.new()
			end

			local v11 = i
			spawn(function()
				if v11 == 3 then
					local cFrame2 = cFrame
					local clone = ReplicatedStorage.Chest.FruitEffect.Paw.ParticlePart:Clone()
					clone.Attachment.Ball.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 8.5, 1.5),
						NumberSequenceKeypoint.new(1, 0)
					})
					clone.Attachment.Ball.Color = ColorSequence.new(Color3.fromRGB(255, 85, 255))
					clone.Attachment.Ball.Texture = "rbxassetid://1084970835"
					clone.Attachment.Ball.LockedToPart = false
					clone.CFrame = cFrame2
					clone.Parent = workspace.Effects
					clone.Attachment.Ball:Emit(10)
					_G.PU:Dust(clone, 1)
					local part = Instance.new("Part")
					part.Transparency = -1
					part.CanCollide = false
					part.Anchored = true
					part.CastShadow = false
					part.Color = Color3.fromRGB(255, 85, 255)
					part.Size = Vector3.new()
					part.Material = Enum.Material.ForceField
					part.Shape = Enum.PartType.Ball
					part.CFrame = cFrame2
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
						Size = createVector(60, 60, 60),
						Transparency = 1
					}):Play()
					_G.PU:Dust(part, 1.5)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://7510006957",
						Volume = 3
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = part
					sound:Play()
					spawn(function()
						local v13 = CFrame.new(cFrame2.p) * CFrame.new(0, 25, 0)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterType = Enum.RaycastFilterType.Include
						raycastParams.FilterDescendantsInstances = { workspace.Island }
						local raycastResult = workspace:Raycast(v13.p, createVector(0, -50, 0), raycastParams)
						local position = v13.p + createVector(0, -50, 0)
						local instance, normal

						if raycastResult then
							position = raycastResult.Position
							instance = raycastResult.Instance
							normal = raycastResult.Normal
							local material = instance.Material
						else
							normal = createVector(0, -1, 0)
						end

						if instance then
							local clone2 = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
							clone2.Decal.Transparency = 0.2
							clone2.Decal.Texture = "rbxassetid://7068839334"
							clone2.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(
								1.5707963267948966,
								0,
								0
							) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
							clone2.Parent = workspace.Effects
							_G.PU:Dust(clone2, 1.5)
							local sound2 = PeoUtils.CreateSound({
								RollOffMaxDistance = 1000,
								RollOffMinDistance = 10,
								RollOffMode = Enum.RollOffMode.InverseTapered,
								SoundId = "rbxassetid://262562442",
								Volume = 1.5
							})
							_G.PU:Dust(sound2, 3)
							sound2.Parent = clone2
							sound2:Play()
							TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
								Size = createVector(50, 0, 50)
							}):Play()
							spawn(function()
								wait(0.25)

								if clone2:FindFirstChild("Decal") then
									TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
										Transparency = 1
									}):Play()
								end
							end)
						end
					end)
				end
			end)
			v10[#v10 + 1] = v6.p + unit * v8 * i + vector2
		end

		spawn(function()
			PeodizService.ForLoop({
				Step = #v10
			}, function(p2)
				local v11 = math.floor(p2 * #v10)
				local v12 = v10[v11]
				local v13 = v10[v11 + 1]

				if v13 then
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.Anchored = true
					part.Color = Color3.fromRGB(255, 100, 255)
					part.Material = "Neon"
					part.Size = Vector3.new(v9, v9, (v12 - v13).Magnitude)
					part.CFrame = CFrame.new(v12, v13) * CFrame.new(0, 0, -(v12 - v13).Magnitude / 2)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.4)
				end
			end)
			task.delay(10, function()
				table.clear(v10)
			end)
		end)
	end

	spawn(function()
		PeodizService.ForLoop({
			Step = #v5,
			WaitTime = 0.03
		}, function(p)
			local v6 = math.floor(p * #v5)
			Lightning(v5[v6])

			if (localPlayer.Character.HumanoidRootPart.Position - v5[v6].p).Magnitude < 100 then
				_G.CameraShake:Shake(CameraShaker.Presets.SmallBump)
			end
		end)
		wait(0.35)

		if v2 and v2:FindFirstChild("RootPart") and v2.RootPart:FindFirstChild("BodyPosition") and v2.RootPart:FindFirstChild("BodyGyro") then
			v2.RootPart.BodyPosition.Position = (v3.CFrame * CFrame.new(7, 3, 2)).Position
			v2.RootPart.BodyGyro.CFrame = v3.CFrame
			local BoneRigScale = require(ReplicatedStorage.Chest.Modules.BoneRigScale)
			BoneRigScale(v2, TweenInfo.new(0.5, Enum.EasingStyle.Linear), 0.1)
		end
	end)
end

function Spirit_C(_, _, list, _)
	local v2 = unpack(list)
	v2.Sun.Attachment.Par.Enabled = true
	PeodizService.ForLoop({
		Step = 30,
		WaitTime = 0.05
	}, function(_)
		if not v2 or v2 and not v2.Parent or not v2:FindFirstChild("Sun") then
			return true
		end

		local cFrame = v2.Sun.CFrame
		local clone = ReplicatedStorage.Chest.Etc.MeshStorage.Rings2:Clone()
		clone.Transparency = -1
		clone.Color = math.random(1, 2) == 1 and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(255, 255, 0)
		clone.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Size = createVector(10, 1, 10)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 1)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			CFrame = clone.CFrame * CFrame.new(0, 50, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0),
			Size = createVector(50, 10, 50),
			Transparency = 1
		}):Play()
	end)
	v2.Sun.Attachment.Par.Enabled = false
end

function Spirit_V(_, _, list, _)
	local _, _, _, cFrame = unpack(list)
	wait(0.1)
	local clone = game.ReplicatedStorage.Chest.Etc.PartSound:Clone()
	_G.PU:Dust(clone, 3)
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7510200104",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()

	if (cFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 then
		_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
		local clone2 = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
		clone2.Parent = game.Lighting
		_G.PU:Dust(clone2, 3)
		TweenService:Create(
			clone2,
			TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
			{
				TintColor = Color3.fromRGB(170, 0, 255)
			}
		):Play()
	end

	local function Lightning(p, data)
		local v3 = p * CFrame.new(0, 150, 0)
		local v4 = v3 * CFrame.new(0, -150, 0)
		local unit = (v4.p - v3.p).Unit
		local v5 = (v4.p - v3.p).Magnitude / 3
		local v6 = math.random(1, 3) * 3
		local v7 = {}

		for i = 0, 3 do
			local far = data.Far
			local vector2 = Vector3.new(math.random(-far, far), math.random(-far, far), math.random(-far, far))

			if i == 0 or i == 3 then
				vector2 = Vector3.new()
			end

			v7[#v7 + 1] = v3.p + unit * v5 * i + vector2
		end

		spawn(function()
			PeodizService.ForLoop({
				Step = #v7
			}, function(p2)
				local v8 = math.floor(p2 * #v7)
				local v9 = v7[v8]
				local v10 = v7[v8 + 1]

				if v10 then
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.Anchored = true
					part.Color = data.Color
					part.Material = "Neon"
					part.Size = Vector3.new(v6, v6, (v9 - v10).Magnitude)
					part.CFrame = CFrame.new(v9, v10) * CFrame.new(0, 0, -(v9 - v10).Magnitude / 2)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.15), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, data.Debris)
				end
			end)
			task.delay(10, function()
				table.clear(v7)
			end)
		end)
	end

	spawn(function()
		PeodizService.ForLoop({
			Step = 10,
			WaitTime = 0.05
		}, function(_)
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Flame.Shockwave:Clone()
			clone2.Color = Color3.fromRGB(255, 100, 255)
			clone2.Transparency = -1
			clone2.CFrame = cFrame * CFrame.new(0, 5, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1,
				CFrame = clone2.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random()),
				Size = createVector(220, 220, 40)
			}):Play()
			_G.PU:Dust(clone2, 2)
		end)
	end)
	local v3 = Scheduler.Repeat(1, 8)
	v3:Wait(0.05)
	v3:Instant()
	v3:Ignore()
	v3:OnStep(function(_)
		Lightning(cFrame, {
			Debris = 0.4,
			Color = Color3.fromRGB(255, 100, 255),
			Far = 25
		})
	end)
	v3:Execute()
	local v4 = Scheduler.Repeat(1, 8)
	v4:Wait(0.05)
	v4:Instant()
	v4:Ignore()
	v4:OnStep(function(_)
		Lightning(cFrame, {
			Debris = 0.1,
			Color = Color3.fromRGB(255, 170, 255),
			Far = 45
		})
	end)
	v4:Execute()
end

function Spirit_B(_, p, _, _)
	spawn(function()
		local v2 = p
		wait(0.1)

		if (v2.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			local clone = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
			clone.Parent = game.Lighting
			_G.PU:Dust(clone, 3)
			TweenService:Create(
				clone,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
				{
					TintColor = Color3.fromRGB(255, 85, 0)
				}
			):Play()
		end

		local clone = ReplicatedStorage.Chest.FruitEffect.Flame.FlamePillar:Clone()
		_G.PU:Dust(clone, 2)
		clone.CastShadow = false
		clone.Color = Color3.fromRGB(255, 85, 0)
		clone.CFrame = v2 * CFrame.Angles(0, 0, 1.5707963267948966)
		clone.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6812440702",
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://7510214841",
			Volume = 3
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone
		sound2:Play()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(200, 50, 50),
			CFrame = clone.CFrame * CFrame.new(100, 0, 0)
		}):Play()
		local clone2 = ReplicatedStorage.Chest.FruitEffect.Flame.Wind:Clone()
		clone2.CFrame = v2 * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone2.Parent = workspace.Effects
		TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(58, 58, 200),
			Position = clone2.Position + createVector(0, 100, 0)
		}):Play()
		_G.PU:Dust(clone2, 1)
		local clone3 = ReplicatedStorage.Chest.FruitEffect.Flame.Shockwave:Clone()
		clone3.Color = Color3.fromRGB(255, 85, 0)
		clone3.CFrame = v2 * CFrame.new(0, 5, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone3.Parent = workspace.Effects
		clone3.Burning.Enabled = true
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Position = clone3.Position + createVector(0, 180, 0),
			Size = createVector(220, 220, 40)
		}):Play()
		_G.PU:Dust(clone3, 2)
		local clone4 = ReplicatedStorage.Chest.FruitEffect.Flame.Shockwave:Clone()
		clone4.Color = Color3.fromRGB(255, 85, 0)
		clone4.CFrame = v2 * CFrame.new(0, 5, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		clone4.Parent = workspace.Effects
		clone4.Burning.Enabled = true
		TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(220, 220, 40)
		}):Play()
		_G.PU:Dust(clone4, 2)
		spawn(function()
			wait(1)
			clone3.Burning.Enabled = false
			clone4.Burning.Enabled = false
			TweenService:Create(clone3, TweenInfo.new(0.25), {
				Transparency = 1
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.25), {
				Transparency = 1
			}):Play()
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not clone3:IsDescendantOf(workspace.Effects) then
					return true
				end

				TweenService:Create(clone3, TweenInfo.new(0.1), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.1), {
					CFrame = clone4.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
				}):Play()
			end)
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 5,
				WaitTime = 0.05
			}, function()
				if not clone2:IsDescendantOf(workspace.Effects) then
					return true
				end

				TweenService:Create(clone2, TweenInfo.new(0.1), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 0, 3.141592653589793)
				}):Play()
			end)
		end)
		delay(1, function()
			TweenService:Create(clone, TweenInfo.new(0.5), {
				Size = createVector(200, 0, 0),
				Transparency = 1
			}):Play()
			local folder = workspace.Effects:FindFirstChild(clone.Name)

			if folder then
				for _, texture in pairs(folder:GetDescendants()) do
					if texture:IsA("Texture") then
						TweenService:Create(texture, TweenInfo.new(0.5), {
							Transparency = 1
						}):Play()
					end
				end

				wait(1)
				folder:Destroy()
			end
		end)
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.01
		}, function()
			if not clone:IsDescendantOf(workspace.Effects) then
				return true
			end

			for _, texture in pairs(clone:GetChildren()) do
				if not texture:IsA("Texture") then
					continue
				end

				if texture.Name == "Texture1" then
					texture.OffsetStudsU -= 5
				else
					texture.OffsetStudsU += 5
				end
			end
		end)
	end)
end

function PumpkinSmasher_Z(_, _, list, _)
	spawn(function()
		local v2 = unpack(list)
		spawn(function()
			local cFrame = v2.CFrame
			local clone = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.particles:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 5)

			for i = 1, 15 do
				local cFrame2 = v2.CFrame
				clone.Attachment.sm2:Emit(2)
				clone.CFrame = cFrame2
				local v3 = math.random(15, 20)
				local clone2 = ReplicatedStorage.Chest.SwordEffect.NightBlade.GreenSlash:Clone()
				clone2.Decal.Transparency = -1
				clone2.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(2550, 255, 0) or Color3.fromRGB()
				clone2.Mesh.Scale = Vector3.new(v3, v3 / 15, v3)
				clone2.CFrame = cFrame2 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					math.random(-1, v3 / 3),
					math.random(-v3 / 5, v3 / 5)
				)
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone2.Decal, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone2, 0.5)
				local clone3 = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.SlashReal:Clone()
				clone3.Decal.Transparency = -1
				clone3.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(2550, 255, 0) or Color3.fromRGB()
				clone3.Mesh.Scale = Vector3.new(v3, v3 / 15, v3)
				clone3.CFrame = cFrame2 * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					math.random(-1, v3 / 3),
					math.random(-v3 / 5, v3 / 5)
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
					CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone3.Decal, TweenInfo.new(0.25), {
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone3, 0.5)
				local size

				if i >= 10 then
					TweenService:Create(clone2.Mesh, TweenInfo.new(0.25), {
						Scale = clone2.Mesh.Scale * 2
					}):Play()
					TweenService:Create(clone3.Mesh, TweenInfo.new(0.25), {
						Scale = clone3.Mesh.Scale * 2
					}):Play()
					size = createVector(85, 3, 85)
				else
					size = createVector(56.666668, 2, 56.666668)
				end

				local clone4 = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Slashes:Clone()
				clone4.CFrame = cFrame2 * CFrame.new(0, 0, -math.sin(3.141592653589793 * i / 15)) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone4.Transparency = 0.7
				clone4.Parent = workspace.Effects
				TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = size,
					Transparency = 1
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					CFrame = clone4.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0),
					Color = Color3.fromRGB(255, 0, 0)
				}):Play()
				_G.PU:Dust(clone4, 1)
				wait(0.02)
			end
		end)
	end)
end

function PumpkinSmasher_X(_, p, list, _)
	spawn(function()
		local cFrame = p
		spawn(function()
			local v3 = unpack(list)

			for _ = 1, 7 do
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.GreenSlash:Clone()
				clone.Mesh.Scale = createVector(37.5, 1, 37.5)
				clone.Decal.Color3 = Color3.fromRGB(2550, 170, 0)
				clone.Decal.Transparency = -1
				clone.CFrame = v3.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}):Play()
				TweenService:Create(clone.Mesh, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
					Scale = createVector(0, 0.125, 0)
				}):Play()
				_G.PU:Dust(clone, 0.35)
				wait()
			end
		end)
		wait(0.3)

		if (cFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 then
			_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
			local clone = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
			clone.Parent = game.Lighting
			_G.PU:Dust(clone, 3)
			TweenService:Create(
				clone,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
				{
					TintColor = Color3.fromRGB(79, 26, 0)
				}
			):Play()
		end

		spawn(function()
			local clone = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.particles:Clone()
			clone.CFrame = cFrame
			clone.Parent = workspace.Effects
			clone.Attachment.bat:Emit(25)
			clone.Attachment.dark:Emit(25)
			clone.Attachment.spark:Emit(10)
			clone.Attachment.big:Emit(1)
			_G.PU:Dust(clone, 7)

			if list[2] then
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 0,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://15157093707",
					Volume = 1
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 7)
				sound.Parent = clone
				sound:Play()
			else
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://7600233878",
					Volume = 1
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 3)
				sound.Parent = clone
				sound:Play()
			end

			local v3 = {
				RollOffMaxDistance = 500,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://7597503556",
				Volume = 4
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.Color = Color3.fromRGB(213, 100, 0)
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Size = createVector(150, 150, 150)
			clone2.CFrame = CFrame.new(cFrame.p)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 0.15)
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 200, 0),
				CFrame = clone2.CFrame * CFrame.new(0, 100, 0)
			}):Play()
			local part = Instance.new("Part")
			part.Shape = Enum.PartType.Ball
			part.CastShadow = false
			part.Anchored = true
			part.CanCollide = false
			part.Color = Color3.fromRGB(255, 170, 0)
			part.Material = Enum.Material.ForceField
			part.Size = Vector3.new()
			part.Transparency = -1
			part.CFrame = CFrame.new(cFrame.p)
			part.Parent = workspace.Effects
			TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential), {
				Size = createVector(150, 150, 150),
				Transparency = 1
			}):Play()
			_G.PU:Dust(part, 0.35)
			local clone3 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone3.Transparency = -1
			clone3.Size = createVector(0, 50, 0)
			clone3.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 5, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(200, 0, 200),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone3, 0.5)
			local clone4 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone4.CastShadow = false
			clone4.Transparency = 0.1
			clone4.CFrame = CFrame.new(cFrame.p)
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(250, 20, 250),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone4, 0.5)
			delay(0.1, function()
				local clone5 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone5.Transparency = -1
				clone5.Size = createVector(0, 25, 0)
				clone5.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 180, 0)
				clone5.Parent = workspace.Effects
				TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(100, 1, 100),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone5, 0.5)
			end)
			local clone5 = ReplicatedStorage.Chest.SwordEffect.PumpkinSmasher.SHOCKK:Clone()
			clone5.Transparency = -1
			clone5.Size = createVector(200, 10, 200)
			clone5.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 5, 0)
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
				CFrame = clone3.CFrame * CFrame.new(0, 100, 0),
				Size = createVector(25, 200, 25),
				Orientation = createVector(0, 720, 0),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone5, 0.5)

			for _ = 1, 10 do
				local cFrame2 = CFrame.new(cFrame.p) * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.Angles(
					math.rad((math.random(-90, 90))),
					math.rad((math.random(-90, 90))),
					0
				)
				local v5 = math.random(10, 30) / 2
				local v6 = math.random(75, 125)
				local clone6 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone6.Color = Color3.fromRGB(255, 85, 0)
				clone6.CastShadow = false
				clone6.Transparency = -1
				clone6.Anchored = true
				clone6.CanCollide = false
				clone6.Size = Vector3.new(v5, v5, math.random(100, 150))
				clone6.CFrame = cFrame2
				clone6.Parent = workspace.Effects
				_G.PU:Dust(clone6, 0.275)
				TweenService:Create(clone6, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
					Size = Vector3.new(),
					CFrame = clone6.CFrame * CFrame.new(0, 0, v6)
				}):Play()
			end
		end)
		spawn(function()
			local v3 = CFrame.new(cFrame.p) * CFrame.new(0, 25, 0)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			local raycastResult = workspace:Raycast(v3.p, createVector(0, -50, 0), raycastParams)
			local position = v3.p + createVector(0, -50, 0)
			local instance, normal

			if raycastResult then
				position = raycastResult.Position
				instance = raycastResult.Instance
				normal = raycastResult.Normal
				local _ = instance.Material
			else
				normal = createVector(0, -1, 0)
			end

			if instance then
				local clone = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
				clone.Decal.Transparency = 0
				clone.Decal.Texture = "rbxassetid://7615931204"
				clone.Decal.Color3 = Color3.fromRGB(255, 255, 255)
				clone.rocks.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 15, 5),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone.rocks.Color = ColorSequence.new(instance.Color)
				clone.rocks.Lifetime = NumberRange.new(0.5, 1)
				clone.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				) * CFrame.new(0, -1, 0)
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 3)
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
					Size = createVector(150, 0, 150)
				}):Play()
				spawn(function()
					wait(1)

					if clone:FindFirstChild("Decal") then
						TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end
				end)
			end
		end)
		spawn(function()
			local v3 = CFrame.new(cFrame.p) + createVector(0, 2, 0)

			for i = 1, 20 do
				local cframe = v3 * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(0, 0, -75)
				local _, v4, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.Position, createVector(0, -25, 0), raycastParams)
				local position = cframe.Position + createVector(0, -25, 0)
				local instance

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
				end

				if not instance then
					continue
				end

				local v5 = math.random(45, 65)
				local part = Instance.new("Part")
				part.CanCollide = false
				part.CastShadow = false
				part.Anchored = true
				part.Size = createVector(1, 1, 1)
				part.Material = instance.Material
				part.MaterialVariant = instance.MaterialVariant
				part.Color = instance.Color
				part.CFrame = CFrame.new(v3.X, position.Y, v3.Z) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(
					math.rad(v5),
					0,
					0
				)
				part.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				local v6 = math.random(70, 100) / 7
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v4, 0) * CFrame.Angles(math.rad(v5), 0, 0),
					Size = Vector3.new(v6 * 2.25, v6, v6)
				}):Play()
				spawn(function()
					wait(1)
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
						Position = part.Position + createVector(0, -1, 0),
						Transparency = 1
					}):Play()
				end)
			end
		end)
	end)
end

function PumpkinSmasher_Attack(_, p, _, _, p2)
	spawn(function()
		local v2 = p
		task.spawn(function()
			local clone = ReplicatedStorage.Chest.Etc.PumpkinImpact:Clone()
			clone.CFrame = CFrame.new(v2.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)

			if p2 then
				local v3 = {
					RollOffMaxDistance = 500,
					RollOffMinDistance = 0,
					RollOffMode = Enum.RollOffMode.Linear,
					SoundId = "rbxassetid://15157092406",
					Volume = 4
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			else
				local v3 = {
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.Inverse,
					SoundId = "rbxassetid://11597587557",
					Volume = 1.5
				}
				local sound = PeoUtils.CreateSound(v3)
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			end

			task.spawn(function()
				for _, emitter in pairs(clone:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)

			if (localPlayer.Character.HumanoidRootPart.Position - v2.p).Magnitude < 150 then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.FastExplosion)
			end

			local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone2.Color = Color3.fromRGB(255, 85, 0)
			clone2.CastShadow = false
			clone2.Transparency = -1
			clone2.Anchored = true
			clone2.CanCollide = false
			clone2.Size = createVector(50, 50, 50)
			clone2.CFrame = CFrame.new(v2.p)
			clone2.Parent = workspace.Effects
			_G.PU:Dust(clone2, 0.15)
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 75, 0),
				CFrame = clone2.CFrame * CFrame.new(0, 37.5, 0)
			}):Play()
		end)
		task.spawn(function()
			for i = 1, 14 do
				local cframe = CFrame.new(v2.p) * CFrame.Angles(0, 6.283185307179586 * i / 14, 0) * CFrame.new(
					0,
					0,
					-10
				)
				Ray.new(cframe.p, createVector(0, -5, 0))
				local _, v3, _ = cframe:ToOrientation()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(cframe.p, createVector(0, -5, 0), raycastParams)
				local position = cframe.p + createVector(0, -5, 0)
				local instance, material

				if raycastResult then
					position = raycastResult.Position
					instance = raycastResult.Instance
					local _ = raycastResult.Normal
					material = instance.Material
				end

				if not instance then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(v2.p) * CFrame.fromOrientation(0, v3, 0)
				part.Size = createVector(0, 0, 0)
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
						0,
						math.random(-10, 1) / 20,
						0
					) * CFrame.Angles(math.rad((math.random(30, 90))), 0, 0),
					Size = createVector(4.8, 2, 2)
				}):Play()
				TweenService:Create(
					part,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 1),
					{
						Transparency = 1
					}
				):Play()
				part.Material = material or "SmoothPlastic"
				part.BrickColor = instance.BrickColor
				_G.PU:Dust(part, 2)
			end
		end)
	end)
end

function LevelUp_Par(player, _, _, _)
	local humanoidRootPart = player.Character.HumanoidRootPart
	local cFrame = humanoidRootPart.CFrame
	local clone = ReplicatedStorage.Chest.Etc.Part25:Clone()
	clone.Anchored = false
	clone.CFrame = cFrame
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 1.8)
	local weld = Instance.new("Weld")
	weld.Part0 = humanoidRootPart
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, -2, 0)
	weld.Parent = clone
	_G.PU:Dust(weld, 3)

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 127))
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end

function BubbleEx(_, _, list, _)
	local parent = unpack(list)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.Linear,
		SoundId = "rbxassetid://9273153409",
		Volume = 4
	})
	_G.PU:Dust(sound, 1)
	sound.Parent = parent
	sound:Play()
	local clone = ReplicatedStorage.Chest.Etc.BubbleEx.Attachment:Clone()
	clone.Wind.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 7.5, 7.5), NumberSequenceKeypoint.new(1, 0) })
	clone.Wind.Speed = NumberRange.new(50, 60)
	clone.Shards.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 8.6),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Shards.Speed = NumberRange.new(60, 100)
	clone.Spark.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 20),
		NumberSequenceKeypoint.new(0.63, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Bubble.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1086),
		NumberSequenceKeypoint.new(0.48, 1.6, 0.652),
		NumberSequenceKeypoint.new(1, 0)
	})
	clone.Parent = parent
	_G.PU:Dust(clone, 1.25)
	clone.Wind:Emit(25)
	clone.Shards:Emit(15)
	clone.Spark:Emit(1)
	clone.Bubble:Emit(25)
end

ReplicatedStorage.Chest.Remotes.Events.Skill_Effect.OnClientEvent:Connect(function(p, p2, p3, childName)
	local localPlayer2 = game.Players.LocalPlayer

	if not localPlayer2.Character then
		warn("No Character")
		return
	end

	if not localPlayer2.Character:FindFirstChild("HumanoidRootPart") then
		warn("No RootPart")
		return
	end

	local loopDistance, forceFX

	if type(p3) == "table" then
		loopDistance = p3.LoopDistance or nil
		forceFX = p3.ForceFX or nil
	end

	if p2 and not (loopDistance or forceFX) then
		local p4 = p2.p
		local humanoidRootPart = localPlayer2.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (p4 - humanoidRootPart.Position).Magnitude > 1500 then
			return
		end
	end

	if type(p3) == "table" and _G.ReturnEffects(localPlayer2, p) then
		return
	end

	local child = ReplicatedStorage.Chest.XModules:FindFirstChild(childName)

	if child then
		local module = require(child)
		module({
			p,
			p2,
			p3,
			childName
		})
	else
		local child2 = script.Modules:FindFirstChild(childName)

		if child2 then
			local module = require(child2)
			module({
				p,
				p2,
				p3,
				childName
			})
		elseif childName == "BubbleEx" then
			BubbleEx(p, p2, p3, childName)
		elseif childName == "LevelUp_Par" then
			LevelUp_Par(p, p2, p3, childName)
		elseif childName == "PumpkinSmasher_Z" then
			PumpkinSmasher_Z(p, p2, p3, childName)
		elseif childName == "PumpkinSmasher_X" then
			PumpkinSmasher_X(p, p2, p3, childName)
		elseif childName == "PumpkinSmasher_Attack" then
			PumpkinSmasher_Attack(p, p2, p3, childName)
		else
			pcall(function()
				if childName == "Spirit_X" then
					Spirit_X(p, p2, p3, childName)
					return
				elseif childName == "Spirit_C" then
					Spirit_C(p, p2, p3, childName)
					return
				elseif childName == "Spirit_V" then
					Spirit_V(p, p2, p3, childName)
					return
				elseif childName == "Spirit_B" then
					Spirit_B(p, p2, p3, childName)
					return
				elseif childName == "MetalTrident_Z" then
					MetalTrident_Z(p, p2, p3, childName)
					return
				elseif childName == "MetalTrident_X" then
					MetalTrident_X(p, p2, p3, childName)
					return
				elseif childName == "Bomb_Z_Awake" then
					Bomb_Z_Awake(p, p2, p3, childName)
					return
				elseif childName == "Bomb_Z_Rings" then
					Bomb_Z_Rings(p, p2, p3, childName)
					return
				elseif childName == "Bomb_X_Rings" then
					Bomb_X_Rings(p, p2, p3, childName)
					return
				elseif childName == "Bomb_X_Awake" then
					Bomb_X_Awake(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_X_Rings" then
					Mammoth_X_Rings(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_X_Ex" then
					Mammoth_X_Ex(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_X_Full" then
					Mammoth_X_Full(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_C" then
					Mammoth_C(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_C_Full" then
					Mammoth_C_Full(p, p2, p3, childName)
					return
				elseif childName == "Santa_Snow_Ex" then
					Santa_Snow_Ex(p, p2, p3, childName)
					return
				elseif childName == "Bomb_C_Awake" then
					Bomb_C_Awake(p, p2, p3, childName)
					return
				elseif childName == "Bomb_V_Awake" then
					Bomb_V_Awake(p, p2, p3, childName)
					return
				elseif childName == "Bomb_E_Awake" then
					Bomb_E_Awake(p, p2, p3, childName)
					return
				elseif childName == "AllosaurusTeleport" then
					AllosaurusTeleport(p, p2, p3, childName)
					return
				elseif childName == "Gravity_Z" then
					Gravity_Z(p, p2, p3, childName)
					return
				elseif childName == "Gravity_X" then
					Gravity_X(p, p2, p3, childName)
					return
				elseif childName == "Gravity_X2" then
					Gravity_X2(p, p2, p3, childName)
					return
				elseif childName == "Paw_Z" then
					Paw_Z(p, p2, p3, childName)
					return
				elseif childName == "Paw_X" then
					Paw_X(p, p2, p3, childName)
					return
				elseif childName == "Paw_C" then
					Paw_C(p, p2, p3, childName)
					return
				elseif childName == "Paw_V" then
					Paw_V(p, p2, p3, childName)
					return
				elseif childName == "Sand_X" then
					Sand_X(p, p2, p3, childName)
					return
				elseif childName == "Sand_C" then
					Sand_C(p, p2, p3, childName)
					return
				elseif childName == "Sand_V" then
					Sand_V(p, p2, p3, childName)
					return
				elseif childName == "Ice_Z_Awake" then
					Ice_Z_Awake(p, p2, p3, childName)
					return
				elseif childName == "Ice_Z_Awake_Ex" then
					Ice_Z_Awake_Ex(p, p2, p3, childName)
					return
				elseif childName == "Ice_Z_Sea" then
					Ice_Z_Sea(p, p2, p3, childName)
					return
				elseif childName == "Ice_Z_Awake_Sea" then
					Ice_Z_Awake_Sea(p, p2, p3, childName)
					return
				elseif childName == "Ice_Z_Ex" then
					Ice_Z_Ex(p, p2, p3, childName)
					return
				elseif childName == "Ice_X_Awake" then
					Ice_X_Awake(p, p2, p3, childName)
					return
				elseif childName == "Ice_C_Awake" then
					Ice_C_Awake(p, p2, p3, childName)
					return
				elseif childName == "Ice_V_Awake" then
					Ice_V_Awake(p, p2, p3, childName)
					return
				elseif childName == "Ice_Awake_Charge" then
					Ice_Awake_Charge(p, p2, p3, childName)
					return
				elseif childName == "Ice_E_Awake_Trans" then
					Ice_E_Awake_Trans(p, p2, p3, childName)
					return
				elseif childName == "Freeze" then
					Freeze(p, p2, p3, childName)
					return
				elseif childName == "FreezeStone" then
					FreezeStone(p, p2, p3, childName)
					return
				elseif childName == "Magma_Z" then
					Magma_Z(p, p2, p3, childName)
					return
				elseif childName == "Magma_Z_Awake" then
					Magma_Z_Awake(p, p2, p3, childName)
					return
				elseif childName == "Magma_X_Awake" then
					Magma_X_Awake(p, p2, p3, childName)
					return
				elseif childName == "Magma_C_Awake" then
					Magma_C_Awake(p, p2, p3, childName)
					return
				elseif childName == "Magma_V_Awake" then
					Magma_V_Awake(p, p2, p3, childName)
					return
				elseif childName == "Magma_E_Awake_Ex" then
					Magma_E_Awake_Ex(p, p2, p3, childName)
					return
				elseif childName == "Magma_Z_Sea" then
					Magma_Z_Sea(p, p2, p3, childName)
					return
				elseif childName == "Magma_Z_Ex" then
					Magma_Z_Ex(p, p2, p3, childName)
					return
				elseif childName == "Magma_X" then
					Magma_X(p, p2, p3, childName)
					return
				elseif childName == "Magma_C" then
					Magma_C(p, p2, p3, childName)
					return
				elseif childName == "Magma_V" then
					Magma_V(p, p2, p3, childName)
					return
				elseif childName == "Love_Z" then
					Love_Z(p, p2, p3, childName)
					return
				elseif childName == "Love_X" then
					Love_X(p, p2, p3, childName)
					return
				elseif childName == "Love_C" then
					Love_C(p, p2, p3, childName)
					return
				elseif childName == "darklegv" then
					darklegv(p, p2, p3, childName)
					return
				elseif childName == "Love_V" then
					Love_V(p, p2, p3, childName)
					return
				elseif childName == "Buddha_Z" then
					Buddha_Z(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_Z" then
					Mammoth_Z(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_Transform" then
					Mammoth_Transform(p, p2, p3, childName)
					return
				elseif childName == "Mammoth_Z_Full" then
					Mammoth_Z_Full(p, p2, p3, childName)
					return
				elseif childName == "Op_Z" then
					Op_Z(p, p2, p3, childName)
					return
				elseif childName == "Op_X" then
					Op_X(p, p2, p3, childName)
					return
				elseif childName == "Op_CTeleport" then
					Op_CTeleport(p, p2, p3, childName)
					return
				elseif childName == "Op_CounterShock" then
					Op_CounterShock(p, p2, p3, childName)
					return
				elseif childName == "Op_VTeleport" then
					Op_VTeleport(p, p2, p3, childName)
					return
				elseif childName == "Op_VMes" then
					Op_VMes(p, p2, p3, childName)
					return
				elseif childName == "Op_E" then
					Op_E(p, p2, p3, childName)
					return
				elseif childName == "Bari_Z" then
					Bari_Z(p, p2, p3, childName)
					return
				elseif childName == "Barrier_Z" then
					Barrier_Z(p, p2, p3, childName)
					return
				elseif childName == "Barrier_X" then
					Barrier_X(p, p2, p3, childName)
					return
				elseif childName == "Barrier_V" then
					Barrier_V(p, p2, p3, childName)
					return
				elseif childName == "Barrier_E" then
					Barrier_E(p, p2, p3, childName)
					return
				elseif childName == "bari_x" then
					bari_x(p, p2, p3, childName)
					return
				elseif childName == "bari_e" then
					bari_e(p, p2, p3, childName)
					return
				elseif childName == "KarateFishman2000" then
					KarateFishman2000(p, p2, p3, childName)
					return
				elseif childName == "CombatFishman2050" then
					CombatFishman2050(p, p2, p3, childName)
					return
				elseif childName == "SwordFishman2100" then
					SwordFishman2100(p, p2, p3, childName)
					return
				elseif childName == "Fishman2200" then
					Fishman2200(p, p2, p3, childName)
					return
				elseif childName == "WaterStyle_Z" then
					WaterStyle_Z(p, p2, p3, childName)
					return
				elseif childName == "WaterStyle_Z_Boss" then
					WaterStyle_Z_Boss(p, p2, p3, childName)
					return
				elseif childName == "WaterStyle_X" then
					WaterStyle_X(p, p2, p3, childName)
					return
				elseif childName == "WaterStyle_C" then
					WaterStyle_C(p, p2, p3, childName)
					return
				elseif childName == "WaterStyle_V" then
					WaterStyle_V(p, p2, p3, childName)
					return
				elseif childName == "Soru" then
					Soru(p, p2, p3, childName)
					return
				elseif childName == "Santa_Ex" then
					Santa_Ex(p, p2, p3, childName)
					return
				elseif childName == "Geppo" then
					Geppo(p, p2, p3, childName)
					return
				elseif childName == "Dash" then
					Dash(p, p2, p3, childName)
					return
				elseif childName == "MonsterSmasher" then
					MonsterSmasher(p, p2, p3, childName)
					return
				end

				if childName ~= "RockFall" then
					return
				end

				RockFall(p, p2, p3, childName)
			end)
		end
	end
end)
ReplicatedStorage.Chest.Remotes.Bindables.RemoteEvent.Event:Connect(function(p, p2, p3, p4)
	if (localPlayer.Character.HumanoidRootPart.Position - p2.p).Magnitude > 500 then
		return
	end

	if p4 == "Dash" then
		Dash(p, p2, p3, "Dash")
	elseif p4 == "Geppo" then
		Geppo(p, p2, p3, "Geppo")
	end
end)
ReplicatedStorage.Chest.Remotes.Events.DevilFruitPassive.OnClientEvent:Connect(function(player, p, list, p2)
	if p2 == "Magma_E_Loop" then
		Magma_E_Loop(player, p, list, "Magma_E_Loop")
	elseif p2 == "Ice_Path" then
		task.spawn(function()
			local playerStats = player:FindFirstChild("PlayerStats")
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.05
			}, function()
				playerStats = player:FindFirstChild("PlayerStats")

				if playerStats then
					return true
				end
			end)
			local lastTime = tick()

			while wait(0.05) do
				local character = player.Character

				if not character or playerStats.DFName.Value ~= "IceIce" then
					break
				end

				if not character then
					continue
				end

				local humanoid = player.Character:FindFirstChild("Humanoid")

				if not humanoid or humanoid.Health <= 0 then
					break
				end

				if not humanoid then
					continue
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					break
				end

				if not (humanoidRootPart and humanoid.FloorMaterial == Enum.Material.Air and humanoidRootPart.Position.Y <= 12.5 and humanoidRootPart.Position.Y >= -3.35) then
					continue
				end

				if humanoid.Sit or character:FindFirstChild("Bullitus") or character:FindFirstChild("IceCrane") or playerStats.Accessory.Value == "Bullitus" then
					continue
				end

				if not (tick() - lastTime > 0.1) then
					continue
				end

				lastTime = tick()
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathPc:Clone()
				clone.Transparency = -1
				clone.Material = "Neon"
				clone.CanCollide = true
				clone.Size = createVector(15, 1, 15)
				clone.CFrame = CFrame.new(humanoidRootPart.Position.X, -3.35, humanoidRootPart.Position.Z) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone.Parent = workspace.Effects
				clone.CollisionGroup = "TouchEffect"
				_G.PU:Dust(clone, 1.5)
				spawn(function()
					wait(0.25)
					TweenService:Create(clone, TweenInfo.new(1.25), {
						Size = Vector3.new()
					}):Play()
				end)
			end
		end)
	elseif p2 == "Ice_Awake" then
		task.spawn(function()
			local playerStats = player:FindFirstChild("PlayerStats")
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.05
			}, function()
				playerStats = player:FindFirstChild("PlayerStats")

				if playerStats then
					return true
				end
			end)
			local lastTime = tick()

			while wait(0.05) do
				local character = player.Character

				if not character or playerStats.DFName.Value ~= "IceIce" then
					break
				end

				if not character then
					continue
				end

				local humanoid = character:FindFirstChild("Humanoid")

				if not humanoid or humanoid.Health <= 0 then
					break
				end

				if not humanoid then
					continue
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					break
				end

				if not (humanoidRootPart and humanoid.FloorMaterial == Enum.Material.Air and humanoidRootPart.Position.Y <= 12.5 and humanoidRootPart.Position.Y >= -3.35) then
					continue
				end

				if humanoid.Sit or character:FindFirstChild("Bullitus") or character:FindFirstChild("IceCrane") or playerStats.Accessory.Value == "Bullitus" then
					continue
				end

				if not (tick() - lastTime > 0.1) then
					continue
				end

				lastTime = tick()
				local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathPc:Clone()
				clone.Transparency = -1
				clone.Material = "Neon"
				clone.CanCollide = true
				clone.Size = createVector(15, 1, 15)
				clone.CFrame = CFrame.new(humanoidRootPart.Position.X, -3.35, humanoidRootPart.Position.Z) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone.CollisionGroup = "TouchEffect"
				clone.Parent = workspace.Effects
				clone.Sm:Emit(4)
				_G.PU:Dust(clone, 1.5)
				spawn(function()
					wait(0.25)
					TweenService:Create(clone, TweenInfo.new(1.25), {
						Size = Vector3.new()
					}):Play()
				end)
			end
		end)
	elseif p2 == "Ice_Surf" then
		local v2 = unpack(list)
		local humanoidRootPart = player.Character.HumanoidRootPart
		PeodizService.HeartbeatWait({
			Time = 60,
			WaitTime = 0.05
		}, function()
			if not v2:IsDescendantOf(player.Character) or player.Character.Humanoid.Health <= 0 then
				return true
			end

			spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				raycastParams2.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(
					humanoidRootPart.Position,
					createVector(0, -10, 0),
					raycastParams2
				)
				local position = humanoidRootPart.Position + createVector(0, -10, 0)
				local instance, normal

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
					normal = raycastResult.Normal
				else
					normal = createVector(0, -1, 0)
				end

				if instance then
					local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePathPc:Clone()
					clone.Transparency = -1
					clone.Material = "Neon"
					clone.Size = createVector(15, 1, 15)
					clone.CFrame = CFrame.new(position + normal, position) * CFrame.new(0, 0, -0.75) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
					clone.Parent = workspace.Effects
					clone.CollisionGroup = "TouchEffect"
					_G.PU:Dust(clone, 2)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(20, 1, 20)
					}):Play()
					spawn(function()
						wait(0.25)
						TweenService:Create(clone, TweenInfo.new(1.25), {
							Size = createVector(1, 1, 1),
							Transparency = 1
						}):Play()
					end)
				end
			end)
		end)
	elseif p2 == "Ice_E_Awake" then
		local v2, v3 = unpack(list)
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Size = createVector(75, 75, 75)
		part.Color = Color3.fromRGB(110, 153, 202)
		part.CFrame = v2.CFrame
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1)
		TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(0, 0, 0)
		}):Play()
		spawn(function()
			for _ = 1, 10 do
				math.random(1, 2)
				local cFrame = v2.CFrame * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				)
				local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
				clone.Transparency = -1
				clone.CastShadow = false
				clone.Size = Vector3.new(4, 4, math.random(30, 50))
				clone.Color = Color3.fromRGB(110, 153, 202)
				clone.CFrame = cFrame
				clone.Parent = workspace.Effects
				math.random(20, 30)
				local v5 = math.random(30, 50)
				TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(),
					CFrame = cFrame * CFrame.new(0, 0, v5)
				}):Play()
				_G.PU:Dust(clone, 0.3)
			end

			if (v2.CFrame.p - localPlayer.Character.HumanoidRootPart.Position).Magnitude <= 150 then
				_G.CameraShake:Shake(CameraShaker.Presets.FastExplosion)
				local clone = ReplicatedStorage.Chest.Etc.ColorCorrection:Clone()
				clone.Parent = game.Lighting
				_G.PU:Dust(clone, 3)
				TweenService:Create(
					clone,
					TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
					{
						TintColor = Color3.fromRGB(0, 170, 255),
						Brightness = 0.5,
						Contrast = 1
					}
				):Play()
			end
		end)
		spawn(function()
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.15
			}, function()
				if not v2:IsDescendantOf(v3) then
					return true
				end

				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(
					v2.Position + createVector(0, 5, 0),
					createVector(0, -25, 0),
					raycastParams
				)
				local position = v2.Position + createVector(0, 5, 0) + createVector(0, -25, 0)
				local instance, normal

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
					normal = raycastResult.Normal
				else
					normal = createVector(0, -1, 0)
				end

				local v4 = math.random(12, 20) / 10

				if instance then
					local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePath:Clone()
					clone.Color = Color3.fromRGB(103, 169, 255)
					clone.Transparency = -1
					clone.Material = "Neon"
					clone.CFrame = CFrame.new(position + normal, position) * CFrame.new(0, 0, -0.75) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
					clone.Parent = workspace.Effects
					clone.CollisionGroup = "Effect"
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = createVector(25, 1, 25) * v4
					}):Play()
					spawn(function()
						wait(0.5)
						TweenService:Create(clone, TweenInfo.new(0.5), {
							Size = createVector(1, 1, 1),
							Transparency = 1
						}):Play()
					end)
				elseif not instance and position.Y <= -3.35 then
					local clone = ReplicatedStorage.Chest.FruitEffect.Ice.IcePath:Clone()
					clone.Color = Color3.fromRGB(103, 169, 255)
					clone.Transparency = -1
					clone.Material = "Neon"
					clone.CFrame = CFrame.new(position.X, -3.35, position.Z) * CFrame.new(0, 1.5, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone.Parent = workspace.Effects
					clone.CollisionGroup = "Effect"
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Size = createVector(25, 1, 25) * v4
					}):Play()
					spawn(function()
						wait(0.5)
						TweenService:Create(clone, TweenInfo.new(0.5), {
							Size = createVector(1, 1, 1),
							Transparency = 1
						}):Play()
					end)
				end
			end)
		end)
	elseif p2 == "Magma_Path" then
		task.spawn(function()
			local playerStats = player:FindFirstChild("PlayerStats")
			PeodizService.HeartbeatWait({
				Time = 60,
				WaitTime = 0.05
			}, function()
				playerStats = player:FindFirstChild("PlayerStats")

				if playerStats then
					return true
				end
			end)
			local lastTime = tick()

			while true do
				local character = wait(0.05) and player.Character

				if not character then
					break
				end

				if not character then
					continue
				end

				local humanoid = player.Character:FindFirstChild("Humanoid")

				if not humanoid or humanoid.Health <= 0 or playerStats.DFName.Value ~= "MagmaMagma" then
					break
				end

				if not humanoid then
					continue
				end

				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart then
					break
				end

				if not (humanoidRootPart and humanoid.FloorMaterial == Enum.Material.Air and humanoidRootPart.Position.Y <= 12.5 and humanoidRootPart.Position.Y >= -3.35) then
					continue
				end

				if humanoid.Sit or character:FindFirstChild("Bullitus") or character:FindFirstChild("MagmaGriffin") or playerStats.Accessory.Value == "Bullitus" then
					continue
				end

				if character:FindFirstChild("MagmaFlying") or not (tick() - lastTime > 0.1) then
					continue
				end

				lastTime = tick()
				local clone = ReplicatedStorage.Chest.FruitEffect.Magma.MagmaPath:Clone()
				_G.PU:Dust(clone, 1.5)
				clone.Size = createVector(15, 1, 15)
				clone.Transparency = -1
				clone.CanCollide = true
				clone.CFrame = CFrame.new(humanoidRootPart.Position.X, -3.35, humanoidRootPart.Position.Z) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone.Parent = workspace.Effects
				clone.Sm:Emit(4)
				clone.CollisionGroup = "TouchEffect"
				spawn(function()
					local cFrame = clone.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
					TweenService:Create(clone, TweenInfo.new(1.25), {
						CFrame = cFrame
					}):Play()
					wait(0.25)
					TweenService:Create(clone, TweenInfo.new(1.25), {
						Size = clone.Size / 25
					}):Play()
				end)
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 300,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9115978218",
					Volume = 0.25
				})
				_G.PU:Dust(sound, 1)
				sound.Parent = clone
				sound:Play()
			end
		end)
	end
end)