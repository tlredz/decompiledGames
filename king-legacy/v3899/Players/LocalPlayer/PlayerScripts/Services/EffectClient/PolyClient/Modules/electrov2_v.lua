local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local fromcf = data.fromcf

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 70 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	task.spawn(function()
		if game.Players.LocalPlayer == data.plr then
			local cameraSubject = workspace.CurrentCamera.CameraSubject
			localPlayer.Character.HumanoidRootPart.CFrame = cf * CFrame.new(0, 2.45, 0)
			local part = Instance.new("Part")
			part.CFrame = fromcf
			part.Size = createVector(5, 5, 5)
			part.CanCollide = false
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Transparency = 1
			part.Name = "Cam"
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			workspace.CurrentCamera.CameraSubject = part
			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf
			}):Play()
			wait(0.3)
			workspace.CurrentCamera.CameraSubject = cameraSubject
		end
	end)

	local function Lightning2(data2)
		local beginCF = data2.BeginCF
		local endCF = data2.EndCF
		local color = data2.Color
		local _ = data2.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = (endCF.p - beginCF.p).Magnitude / 8
		local v2 = math.random(15, 40) / 10
		local v3 = {}

		for i = 0, 8 do
			local vector2 = Vector3.new(math.random(-4, 4), math.random(-4, 4), math.random(-4, 4))

			if i == 0 or i == 8 then
				vector2 = Vector3.new()
			end

			v3[#v3 + 1] = beginCF.p + unit * v * i + vector2
		end

		task.spawn(function()
			PeodizService.ForceForLoop({
				Step = #v3
			}, function(p)
				local v4 = math.floor(p * #v3)
				local v5 = v3[v4]
				local v6 = v3[v4 + 1]

				if v6 then
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.Anchored = true
					part.Color = color or Color3.fromRGB(43, 117, 255)
					part.Material = "Neon"
					part.Size = Vector3.new(v2, v2, (v5 - v6).Magnitude)
					part.CFrame = CFrame.new(v5, v6) * CFrame.new(0, 0, -(v5 - v6).Magnitude / 2)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.3)
				end
			end)
			task.delay(10, function()
				table.clear(v3)
			end)
		end)
	end

	local function Lightning(data2)
		local beginCF = data2.BeginCF
		local endCF = data2.EndCF
		local color = data2.Color
		local _ = data2.Ex or false
		local unit = (endCF.p - beginCF.p).Unit
		local v = {}
		local v2 = (endCF.p - beginCF.p).Magnitude / 8
		local v3 = math.random(10, 30) / 10

		if color then
			v3 = math.random(10, 30) / 10 * 0.45
		end

		for i = 0, 8 do
			local v4 = math.random(40, 50) / 10
			local vector2 = Vector3.new(math.random(-v4, v4), math.random(-v4, v4), math.random(-v4, v4))

			if i == 0 or i == 8 then
				vector2 = Vector3.new()
			end

			v[#v + 1] = beginCF.p + unit * v2 * i + vector2
		end

		task.spawn(function()
			PeodizService.ForLoop({
				Step = #v
			}, function(p)
				local v4 = math.floor(p * #v)
				local v5 = v[v4]
				local v6 = v[v4 + 1]

				if v6 then
					local part = Instance.new("Part")
					part.CastShadow = false
					part.CanCollide = false
					part.Anchored = true
					part.Color = color or Color3.fromRGB(43, 117, 255)
					part.Material = "Neon"
					part.Size = Vector3.new(v3, v3, (v5 - v6).Magnitude)
					part.CFrame = CFrame.new(v5, v6) * CFrame.new(0, 0, -(v5 - v6).Magnitude / 2)
					part.Parent = workspace.Effects
					TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = Vector3.new(0, 0, part.Size.Z)
					}):Play()
					_G.PU:Dust(part, 0.2)
				end
			end)
			task.delay(10, function()
				table.clear(v)
			end)
		end)
	end

	task.spawn(function()
		Lightning2({
			BeginCF = fromcf,
			EndCF = cf
		})
	end)
	local clone = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.fx:Clone()
	_G.PU:Dust(clone, 2)
	clone.CFrame = CFrame.new(cf.p)
	clone.Parent = workspace.Effects
	PeodizService.ForceForLoop({
		Step = 15,
		WaitTime = 0.03
	}, function(p)
		math.floor(p * 15)

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 70 or game.Players.LocalPlayer == data.plr then
			_G.shake("SmallerBump")
		end

		local _ = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, math.random(0, 40) / 10)
		local v = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -65)
		local endCF = v * CFrame.new(0, 0, 130)
		task.spawn(function()
			Lightning({
				BeginCF = v,
				EndCF = endCF
			})
			wait()
			Lightning({
				BeginCF = v,
				EndCF = endCF,
				Color = Color3.fromRGB(94, 167, 255)
			})
		end)
		local pointLight = Instance.new("PointLight")
		pointLight.Parent = clone
		pointLight.Color = Color3.fromRGB(82, 122, 255)
		pointLight.Range = 60
		pointLight.Brightness = 1.5
		game.TweenService:Create(
			pointLight,
			TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Brightness = 0.25,
				Range = 0
			}
		):Play()
		_G.PU:Dust(pointLight, 0.3)
		local cframe = CFrame.new(v.p, endCF.p)
		local clone2 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.starfx:Clone()
		clone2.CFrame = v
		clone2.Parent = workspace.Effects
		clone2.Attachment.Crescents:Emit(1)
		clone2.Attachment.Cubes:Emit(15)
		clone2.Attachment.star:Emit(2)
		local clone3 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.particles:Clone()
		clone3.CFrame = cframe
		clone3.Parent = workspace.Effects
		clone3.shard2:Emit(10)
		local clone4 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.MeshPart:Clone()
		clone4.CFrame = cframe * CFrame.new(0, 0, -10)
		clone4.Size = createVector(5, 5, 1)
		clone4.Parent = workspace.Effects
		local clone5 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.black:Clone()
		clone5.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
		clone5.Parent = workspace.Effects
		local clone6 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.blue:Clone()
		clone6.CFrame = cframe * CFrame.Angles(0, -1.5707963267948966, 0)
		clone5.Mesh.Scale = createVector(2.878, 0.368, 0.378)
		clone6.Mesh.Scale = createVector(1.288, 0.198, 0.218)
		clone6.Parent = workspace.Effects
		_G.PU:Dust(clone4, 0.5)
		_G.PU:Dust(clone6, 0.5)
		_G.PU:Dust(clone5, 0.5)
		_G.PU:Dust(clone3, 0.5)
		_G.PU:Dust(clone2, 0.5)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6402472864",
			Volume = 5.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(clone4, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(1, 1, 25)
		}):Play()
		TweenService:Create(clone6, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone6.CFrame * CFrame.new(-65, 0, 0)
		}):Play()
		TweenService:Create(clone5, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone5.CFrame * CFrame.new(-57.5, 0, 0) * CFrame.Angles(1.5707963267948966, 0, 0)
		}):Play()
		task.spawn(function()
			TweenService:Create(
				clone5.Mesh,
				TweenInfo.new(0.175, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(1.839, 0.054, 0.044)
				}
			):Play()
			TweenService:Create(
				clone6.Mesh,
				TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(0.644, 0.039, 0.048)
				}
			):Play()
			wait()

			if clone6:FindFirstChild("Texture") then
				TweenService:Create(
					clone6.Texture,
					TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end

			if clone5:FindFirstChild("Texture") then
				TweenService:Create(
					clone5.Texture,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end

			TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone4.CFrame * CFrame.new(0, 0, -65)
			}):Play()
		end)
		task.spawn(function()
			wait(0.1)
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 65)
			}):Play()
			local clone7 = replicatedStorage.Chest.Etc.Electro.ElectroV2.godspeed.Part2:Clone()
			clone7.CFrame = cframe * CFrame.new(0, 0, -65)
			clone7.Parent = workspace.Effects
			clone7.lightning1:Emit(5)
			_G.PU:Dust(clone7, 0.35)
		end)
	end)
	wait()

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 70 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	if clone:FindFirstChild("Attachment") then
		for _, emitter in pairs(clone.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end

	if clone.Parent then
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://11283070964",
			Volume = 1.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
	end

	local clone2 = script.bw:Clone()
	clone2.Parent = game.Lighting
	_G.PU:Dust(clone2, 0.1)

	for _ = 1, 4 do
		local endCF = cf * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -70)
		Lightning2({
			BeginCF = cf,
			EndCF = endCF
		})
		Lightning2({
			BeginCF = cf,
			EndCF = endCF * CFrame.new(0, 0, 140),
			Color = Color3.fromRGB(102, 184, 255)
		})
		wait()
	end
end