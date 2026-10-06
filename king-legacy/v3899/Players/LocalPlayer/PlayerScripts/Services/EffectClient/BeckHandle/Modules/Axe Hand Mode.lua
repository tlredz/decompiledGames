local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local localPlayer = game.Players.LocalPlayer
return function(list)
	local DISTANCE_THRESHOLD = 150
	local _, cFrame, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if cFrame then
			return (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9558550820",
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()
			spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.CFrame = i == 1 and cFrame * CFrame.new(-15, 0, -5) * CFrame.Angles(
						0,
						-0.15707963267948966,
						0
					) or cFrame * CFrame.new(15, 0, -5) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = clone.Size * 2
					}):Play()
				end

				for i = 1, 3 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Rings:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(255, 255, 255)
					clone.CFrame = cFrame * CFrame.new(0, 0, -i * 27) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(50, 2, 50),
							Transparency = 1
						}
					):Play()
					wait(0.07)
				end
			end)
			PeodizService.ForLoop({
				Step = 15
			}, function(p)
				local v3 = math.floor(p * 15)
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Thing:Clone()
				clone.Color = Color3.fromRGB(255, 255, 255)
				clone.Size = createVector(13, 50, 13)
				clone.CFrame = cFrame * CFrame.new(0, clone.Size.Y / 2, -v3 * (clone.Size.X / 2))
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0.5, 0.5, 13),
					CFrame = clone.CFrame * CFrame.new(0, -clone.Size.Y / 2, 0)
				}):Play()
				spawn(function()
					wait(0.4)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 13),
						Transparency = 1
					}):Play()
				end)
				local v4 = v3 / 2.25
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Dark stone grey")
				part.Anchored = true
				part.CanCollide = false
				part.Material = Enum.Material.Slate
				part.Size = createVector(4.6666665, 4.6666665, 4.6666665)
				part.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				part.Parent = workspace.Effects
				local clone2 = part:Clone()
				clone2.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				_G.PU:Dust(clone2, 2)
				local p2 = (cFrame * CFrame.new(14 - v3 / 1.75, 0, -v3 * v4)).p
				local p3 = (cFrame * CFrame.new(-(14 - v3 / 1.75), 0, -v3 * v4)).p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = { workspace.Island }
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(p2, createVector(0, -30, 0), raycastParams)
				local raycastResult2 = workspace:Raycast(p3, createVector(0, -30, 0), raycastParams2)

				if raycastResult then
					clone.Par.Smoke.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Rock.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Position = clone.Par.Position + createVector(0, -10, 0)
					clone.Par.Smoke.Enabled = true
					clone.Par.Rock.Enabled = true
					spawn(function()
						wait(0.1)
						clone.Par.Smoke.Enabled = false
						clone.Par.Rock.Enabled = false
					end)
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(raycastResult.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					part.Material = raycastResult.Material
					part.Color = raycastResult.Instance.Color
				else
					part:Destroy()
				end

				if not raycastResult2 then
					clone2:Destroy()
					return
				end

				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(raycastResult2.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
						math.random() * 2,
						math.random() * 2,
						math.random() * 2
					)
				}):Play()
				clone2.Material = raycastResult2.Material
				clone2.Color = raycastResult2.Instance.Color
			end)
		elseif mode == "X" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump2)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://165970126",
				Volume = 0.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = rootPart
			sound:Play()

			for i = 1, 20 do
				local cframe = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(
					0,
					0,
					-25
				)
				Ray.new(cframe.p, createVector(0, -30, 0))
				local _, v3, _ = cframe:ToOrientation()
				local p = cframe.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if not raycastResult then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(cFrame.p) * CFrame.fromOrientation(0, v3, 0)
				part.Size = Vector3.new()
				part.Material = raycastResult.Material or "SmoothPlastic"
				part.Color = raycastResult.Instance.Color
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
						0,
						math.random(-20, 20) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
					Size = createVector(8.75, 3.5, 3.5)
				}):Play()
				spawn(function()
					wait(2)
					TweenService:Create(part, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(part, 3)
				local v5 = part
				spawn(function()
					local lastTime = tick()
					local v6 = math.random(10, 30) / 100

					repeat
						wait()
						local cframe2 = CFrame.Angles(
							math.rad(math.random(-45, 45) / 10),
							math.rad(math.random(-45, 45) / 10),
							(math.rad(math.random(-45, 45) / 10))
						)
						v5.CFrame *= cframe2
					until v6 < tick() - lastTime
				end)
			end

			spawn(function()
				local p = cFrame.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if raycastResult then
					local position = raycastResult.Position
					local clone = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone.Decal.Transparency = -0.2
					clone.Decal.Texture = "rbxassetid://7068839334"
					clone.CFrame = CFrame.new(position + raycastResult.Normal, position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 3)
					local sound2 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://262562442",
						Volume = 4
					})
					_G.PU:Dust(sound2, 3)
					sound2.Parent = clone
					sound2:Play()
					TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
						Size = createVector(45, 0, 45)
					}):Play()
					spawn(function()
						wait(2)
						TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = createVector(50, 50, 50)
			clone.CFrame = CFrame.new(cFrame.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.15)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 75, 0),
				CFrame = clone.CFrame * CFrame.new(0, 37.5, 0)
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone2.Transparency = -1
			clone2.Size = createVector(0, 37.5, 0)
			clone2.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, 3.141592653589793)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(65, 0, 65),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.5)
			local clone3 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone3.CastShadow = false
			clone3.Transparency = 0.1
			clone3.CFrame = CFrame.new(cFrame.p)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(100, 10, 100),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone3, 0.5)
			spawn(function()
				local clone4 = ReplicatedStorage.Chest.SwordEffect.AxeHand.ParticleAxe:Clone()
				clone4.Size = createVector(25, 0, 25)
				clone4.Attachment.Circle.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 60)
				})
				clone4.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.1, 20, 12),
					NumberSequenceKeypoint.new(0.9, 20, 12),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone4.Sm.Speed = NumberRange.new(40, 100)
				clone4.CFrame = cFrame
				clone4.Parent = workspace.Effects
				clone4.Attachment.Circle:Emit(1)
				clone4.Sm:Emit(10)
				_G.PU:Dust(clone4, 5)
			end)
		elseif mode == "C" then
			for i = 1, 20 do
				local cframe = CFrame.new(cFrame.p) * CFrame.Angles(0, 6.283185307179586 * i / 20, 0) * CFrame.new(
					0,
					0,
					-12.5
				)
				Ray.new(cframe.p, createVector(0, -30, 0))
				local _, v3, _ = cframe:ToOrientation()
				local p = cframe.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if not raycastResult then
					continue
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.CFrame = CFrame.new(cFrame.p) * CFrame.fromOrientation(0, v3, 0)
				part.Size = Vector3.new()
				part.Material = raycastResult.Material or "SmoothPlastic"
				part.Color = raycastResult.Instance.Color
				part.Parent = workspace.Effects
				TweenService:Create(part, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), {
					CFrame = CFrame.new(raycastResult.Position) * CFrame.fromOrientation(0, v3, 0) * CFrame.new(
						0,
						math.random(-5, 5) / 10,
						0
					) * CFrame.Angles(math.rad((math.random(30, 60))), 0, 0),
					Size = createVector(4.375, 1.75, 1.75)
				}):Play()
				spawn(function()
					wait(2)
					TweenService:Create(part, TweenInfo.new(0.5), {
						Transparency = 1
					}):Play()
				end)
				_G.PU:Dust(part, 3)
				local v5 = part
				spawn(function()
					local lastTime = tick()
					local v6 = math.random(10, 30) / 100

					repeat
						wait()
						local cframe2 = CFrame.Angles(
							math.rad(math.random(-45, 45) / 10),
							math.rad(math.random(-45, 45) / 10),
							(math.rad(math.random(-45, 45) / 10))
						)
						v5.CFrame *= cframe2
					until v6 < tick() - lastTime
				end)
			end

			spawn(function()
				local p = cFrame.p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					workspace.Effects,
					workspace.PlayerCharacters,
					workspace.CharacterWorkshop
				}
				raycastParams.FilterType = Enum.RaycastFilterType.Exclude
				local raycastResult = workspace:Raycast(p, createVector(0, -30, 0), raycastParams)

				if raycastResult then
					local position = raycastResult.Position
					local clone = ReplicatedStorage.Chest.SwordEffect.MiniMace.Crack:Clone()
					clone.Decal.Transparency = -0.2
					clone.Decal.Texture = "rbxassetid://7068839334"
					clone.CFrame = CFrame.new(position + raycastResult.Normal, position) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, -1, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 3)
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://262562442",
						Volume = 4
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential), {
						Size = createVector(45, 0, 45)
					}):Play()
					spawn(function()
						wait(2)
						TweenService:Create(clone.Decal, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
				end
			end)
			local clone = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
			clone.Color = Color3.fromRGB(255, 255, 255)
			clone.CastShadow = false
			clone.Transparency = -1
			clone.Anchored = true
			clone.CanCollide = false
			clone.Size = createVector(25, 25, 25)
			clone.CFrame = CFrame.new(cFrame.p)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 0.15)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				Size = createVector(0, 37.5, 0),
				CFrame = clone.CFrame * CFrame.new(0, 18.75, 0)
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone2.Transparency = -1
			clone2.Size = createVector(0, 18.75, 0)
			clone2.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, 3.141592653589793)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = createVector(32.5, 0, 32.5),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 0.5)
			local clone3 = ReplicatedStorage.Chest.Etc.BlackLeg.Shockowave:Clone()
			clone3.CastShadow = false
			clone3.Transparency = 0.1
			clone3.CFrame = CFrame.new(cFrame.p)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(50, 5, 50),
				Transparency = 1,
				CFrame = clone3.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			_G.PU:Dust(clone3, 0.5)
			spawn(function()
				local clone4 = ReplicatedStorage.Chest.SwordEffect.AxeHand.ParticleAxe:Clone()
				clone4.Size = createVector(12.5, 0, 12.5)
				clone4.Attachment.Circle.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 30)
				})
				clone4.Sm.Size = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.1, 10, 6),
					NumberSequenceKeypoint.new(0.9, 10, 6),
					NumberSequenceKeypoint.new(1, 0)
				})
				clone4.Sm.Speed = NumberRange.new(20, 50)
				clone4.CFrame = cFrame
				clone4.Parent = workspace.Effects
				clone4.Attachment.Circle:Emit(1)
				clone4.Sm:Emit(10)
				_G.PU:Dust(clone4, 5)
			end)
		elseif mode == "Violet Samurai Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6731434108",
				Volume = 1
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = rootPart
			sound:Play()
			spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Color = Color3.fromRGB(170, 0, 255)
					clone.CFrame = i == 1 and cFrame * CFrame.new(-15, 0, -5) * CFrame.Angles(
						0,
						-0.15707963267948966,
						0
					) or cFrame * CFrame.new(15, 0, -5) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = clone.Size * 2
					}):Play()
				end

				for i = 1, 3 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Rings:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(170, 0, 255)
					clone.CFrame = cFrame * CFrame.new(0, 0, -i * 27) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(50, 2, 50),
							Transparency = 1
						}
					):Play()
					wait(0.07)
				end
			end)
			PeodizService.ForLoop({
				Step = 15
			}, function(p)
				local v3 = math.floor(p * 15)
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Thing:Clone()
				clone.Color = Color3.fromRGB(170, 0, 255)
				clone.Size = createVector(3, 50, 13)
				clone.CFrame = cFrame * CFrame.new(0, clone.Size.Y / 2, -v3 * (clone.Size.Z / 2))
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0.5, 0.5, 13),
					CFrame = clone.CFrame * CFrame.new(0, -clone.Size.Y / 2, 0)
				}):Play()
				spawn(function()
					wait(0.4)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 13),
						Transparency = 1
					}):Play()
				end)
				local v4 = v3 / 2.25
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Dark stone grey")
				part.Anchored = true
				part.CanCollide = false
				part.Material = Enum.Material.Slate
				part.Size = createVector(4.6666665, 4.6666665, 4.6666665)
				part.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				part.Parent = workspace.Effects
				local clone2 = part:Clone()
				clone2.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				_G.PU:Dust(clone2, 2)
				local p2 = (cFrame * CFrame.new(14 - v3 / 1.75, 0, -v3 * v4)).p
				local p3 = (cFrame * CFrame.new(-(14 - v3 / 1.75), 0, -v3 * v4)).p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = { workspace.Island }
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(p2, createVector(0, -30, 0), raycastParams)
				local raycastResult2 = workspace:Raycast(p3, createVector(0, -30, 0), raycastParams2)

				if raycastResult then
					clone.Par.Smoke.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Rock.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Position = clone.Par.Position + createVector(0, -10, 0)
					clone.Par.Smoke.Enabled = true
					clone.Par.Rock.Enabled = true
					spawn(function()
						wait(0.1)
						clone.Par.Smoke.Enabled = false
						clone.Par.Rock.Enabled = false
					end)
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(raycastResult.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					part.Material = raycastResult.Material
					part.Color = raycastResult.Instance.Color
				else
					part:Destroy()
				end

				if not raycastResult2 then
					clone2:Destroy()
					return
				end

				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(raycastResult2.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
						math.random() * 2,
						math.random() * 2,
						math.random() * 2
					)
				}):Play()
				clone2.Material = raycastResult2.Material
				clone2.Color = raycastResult2.Instance.Color
			end)
		elseif mode == "Elite Skeleton Z" then
			if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < DISTANCE_THRESHOLD then
				_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
			end

			local rootPart = v2.RootPart
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://6731434108",
				Volume = 1
			})
			_G.PU:Dust(sound, 2)
			sound.Parent = rootPart
			sound:Play()
			spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Color = Color3.fromRGB(255, 0, 0)
					clone.CFrame = i == 1 and cFrame * CFrame.new(-15, 0, -5) * CFrame.Angles(
						0,
						-0.15707963267948966,
						0
					) or cFrame * CFrame.new(15, 0, -5) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = clone.Size * 2
					}):Play()
				end

				for i = 1, 3 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Rings:Clone()
					clone.Transparency = -1
					clone.Color = Color3.fromRGB(255, 0, 0)
					clone.CFrame = cFrame * CFrame.new(0, 0, -i * 27) * CFrame.Angles(-1.5707963267948966, 0, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(50, 2, 50),
							Transparency = 1
						}
					):Play()
					wait(0.07)
				end
			end)
			PeodizService.ForLoop({
				Step = 15
			}, function(p)
				local v3 = math.floor(p * 15)
				local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Thing:Clone()
				clone.Color = Color3.fromRGB(255, 0, 0)
				clone.Size = createVector(3, 50, 13)
				clone.CFrame = cFrame * CFrame.new(0, clone.Size.Y / 2, -v3 * (clone.Size.Z / 2))
				clone.Parent = workspace.Effects
				_G.PU:Dust(clone, 1)
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(0.5, 0.5, 13),
					CFrame = clone.CFrame * CFrame.new(0, -clone.Size.Y / 2, 0)
				}):Play()
				spawn(function()
					wait(0.4)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = createVector(0, 0, 13),
						Transparency = 1
					}):Play()
				end)
				local v4 = v3 / 2.25
				local part = Instance.new("Part")
				part.BrickColor = BrickColor.new("Dark stone grey")
				part.Anchored = true
				part.CanCollide = false
				part.Material = Enum.Material.Slate
				part.Size = createVector(4.6666665, 4.6666665, 4.6666665)
				part.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				part.Parent = workspace.Effects
				local clone2 = part:Clone()
				clone2.CFrame = cFrame * CFrame.new(0, 0, -v3 * v4 - 2)
				clone2.Parent = workspace.Effects
				_G.PU:Dust(part, 2)
				_G.PU:Dust(clone2, 2)
				local p2 = (cFrame * CFrame.new(14 - v3 / 1.75, 0, -v3 * v4)).p
				local p3 = (cFrame * CFrame.new(-(14 - v3 / 1.75), 0, -v3 * v4)).p
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastParams2 = RaycastParams.new()
				raycastParams2.FilterDescendantsInstances = { workspace.Island }
				raycastParams2.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(p2, createVector(0, -30, 0), raycastParams)
				local raycastResult2 = workspace:Raycast(p3, createVector(0, -30, 0), raycastParams2)

				if raycastResult then
					clone.Par.Smoke.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Rock.Color = ColorSequence.new(raycastResult.Instance.Color)
					clone.Par.Position = clone.Par.Position + createVector(0, -10, 0)
					clone.Par.Smoke.Enabled = true
					clone.Par.Rock.Enabled = true
					spawn(function()
						wait(0.1)
						clone.Par.Smoke.Enabled = false
						clone.Par.Rock.Enabled = false
					end)
					TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						CFrame = CFrame.new(raycastResult.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
							math.random() * 2,
							math.random() * 2,
							math.random() * 2
						)
					}):Play()
					part.Material = raycastResult.Material
					part.Color = raycastResult.Instance.Color
				else
					part:Destroy()
				end

				if not raycastResult2 then
					clone2:Destroy()
					return
				end

				TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(raycastResult2.Position) * CFrame.new(0, -1.55, 0) * CFrame.Angles(
						math.random() * 2,
						math.random() * 2,
						math.random() * 2
					)
				}):Play()
				clone2.Material = raycastResult2.Material
				clone2.Color = raycastResult2.Instance.Color
			end)
		elseif mode == "Elite Skeleton X" then
			local nightBladeFolder = v2.NightBladeFolder
			local rootPart = v2.RootPart
			local character = v2.Character
			local lastTime = tick()
			PeodizService.HeartbeatWait({
				Time = 5
			}, function(_)
				if not nightBladeFolder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
					return true
				end

				spawn(function()
					local v3 = math.min((tick() - lastTime) * 20, 25)
					local v4 = rootPart.CFrame * CFrame.new(0, 0, -30)
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.GreenSlash:Clone()
					_G.PU:Dust(clone, 0.5)
					clone.Decal.Color3 = math.random(1, 2) == 1 and Color3.fromRGB(2550, 0, 0) or Color3.fromRGB(
						0,
						0,
						0
					)
					clone.Mesh.Scale = Vector3.new(5 + v3, 0.125, 5 + v3)
					clone.CFrame = v4 * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) * CFrame.new(0, 0, math.random(1, 10))
					clone.Parent = workspace.Effects
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 500,
						RollOffMinDistance = 50,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://6344307698",
						Volume = 0.1
					})
					_G.PU:Dust(sound, 3)
					sound.Parent = clone
					sound:Play()
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
					}):Play()
					TweenService:Create(clone.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1
					}):Play()

					if math.random(1, 3) == 1 then
						local v5 = math.random(1, 2)
						local v6 = v4 * CFrame.Angles(
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random(),
							6.283185307179586 * math.random()
						)
						local clone2 = ReplicatedStorage.Chest.MeleeEffect.Cyborg.Thing:Clone()
						clone2.CastShadow = false
						clone2.Transparency = -1
						clone2.Size = Vector3.new(3, 3, math.random(50, 100))
						clone2.Color = v5 == 1 and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 0, 0)
						clone2.CFrame = v6 * CFrame.new(
							math.random(-15, 15),
							math.random(-15, 15),
							math.random(-15, 15)
						)
						clone2.Parent = workspace.Effects
						TweenService:Create(
							clone2,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1,
								Size = Vector3.new(0, 0, clone2.Size.Z)
							}
						):Play()
						_G.PU:Dust(clone2, 0.35)
					end
				end)
			end)
		end
	end
end