local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
return function(data)
	local cf = data.cf
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local clone

	if data.plr == localPlayer then
		clone = script.cc:Clone()
		clone.Parent = game.Lighting
		_G.PU:Dust(clone, 10)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 183, 170),
			Saturation = -0.5
		}):Play()
	end

	local clone2 = ReplicatedStorage.Chest.FruitEffect.Toy.airplane:Clone()
	clone2.Parent = workspace.Effects
	clone2:SetPrimaryPartCFrame(cf * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(0, 70, 80))
	_G.PU:Dust(clone2, 0.8)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://15314559876",
		Volume = 1
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2.core
	sound:Play()
	localshake("SmallBump") -- equivalent call inferred; original call site unknown

	for _, part in pairs(clone2:GetChildren()) do
		if not (part:IsA("BasePart") and part ~= clone2.PrimaryPart) then
			continue
		end

		local size = part.Size
		part.Transparency = 1
		part.Size = Vector3.new()
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()
		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
	end

	for _, emitter in pairs(clone2:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") * 1 or 1)
		end
	end

	local clone3 = ReplicatedStorage.Chest.FruitEffect.Toy.field:Clone()
	clone3:SetPrimaryPartCFrame(CFrame.new(cf.p))
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 2)
	task.spawn(function()
		local ModuleScript = require(clone3.field.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		PeodizService.new({
			Time = 5
		}, function()
			if not clone2:IsDescendantOf(workspace.Effects) then
				return true
			end

			clone2.PrimaryPart.blade.C0 = clone2.PrimaryPart.blade.C0 * CFrame.Angles(0, 0, 0.3141592653589793)
		end)
	end)
	task.spawn(function()
		local cFrame = clone2.PrimaryPart.CFrame
		local v = clone2.PrimaryPart.CFrame * CFrame.new(0, 0, -160)
		local magnitude = (cFrame.p - v.p).Magnitude
		PeodizService.ForLoop({
			Step = 6,
			WaitTime = 0.1
		}, function(p)
			local v2 = math.floor(p * 6)
			local v3 = CFrame.new(cFrame.p, v.p) * CFrame.new(0, 0, -magnitude / 6 * v2)
			local v4 = math.sin(3.1101767270538954 * v2 / 6) * 22.5
			local v5 = CFrame.new(cFrame.p, v.p) * CFrame.new(0, 0, -magnitude / 6 * (v2 + 1))
			local v6 = math.sin(3.1101767270538954 * (v2 + 1) / 6) * 22.5
			local v7 = v3 * CFrame.new(0, -v4, 0)
			local _ = v3 * CFrame.new(0, -v6, 0)
			TweenService:Create(
				clone2.PrimaryPart,
				TweenInfo.new(0.21666666666666667, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					CFrame = CFrame.new(v7.p, v5.p)
				}
			):Play()
		end)
	end)
	task.spawn(function()
		wait(0.5)

		if sound and sound.Parent then
			TweenService:Create(sound, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end

		for _, part in pairs(clone2:GetChildren()) do
			if part:IsA("BasePart") and part ~= clone2.PrimaryPart then
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
			end
		end
	end)
	wait(0.15)
	PeodizService.ForLoop({
		Step = 12,
		WaitTime = 0.1
	}, function(p)
		local v = math.floor(p * 12)
		task.spawn(function()
			local savecf = data.savecfs[v]
			task.spawn(function()
				PeodizService.ForLoop({
					Step = 3
				}, function(p2)
					math.floor(p2 * 3)
					local cFrame = cf * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
						0,
						0,
						math.random(10, 80)
					)
					local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.bullet2:Clone()
					clone4.Parent = workspace.Effects
					clone4.CFrame = cFrame * CFrame.new(0, math.random(80, 100), 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					) * CFrame.new(0, 0, math.random(10, 20) * math.random(15, 20) / 10)
					_G.PU:Dust(clone4, 0.35)
					wait()
					TweenService:Create(
						clone4,
						TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = cFrame
						}
					):Play()
				end)
			end)
			task.spawn(function()
				local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.rocket:Clone()
				_G.PU:Dust(clone4, 1)
				clone4.CFrame = savecf * CFrame.new(0, 100, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					0,
					math.random(10, 20)
				)
				clone4.Attachment.ToonPetal:Emit(3)
				clone4.Parent = workspace.Effects
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://15314554489",
					Volume = 0.66,
					PlaybackSpeed = 1.5
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone4
				sound2:Play()
				wait()
				TweenService:Create(
					clone4,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = savecf
					}
				):Play()
				wait(0.4)
				clone4.Trail.Enabled = false
			end)
			wait(0.15)
			local v2 = 60
			local p2 = savecf.p
			local v3 = "SmallerBump"
			task.spawn(function()
				v2 = v2 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v2 then
					_G.shake(v3)
				end
			end)
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Toy.exp:Clone()
			_G.PU:Dust(clone4, 2)
			clone4.CFrame = savecf
			clone4.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 500,
				RollOffMinDistance = 0,
				RollOffMode = Enum.RollOffMode.Linear,
				SoundId = "rbxassetid://14968313699",
				Volume = 0.75,
				PlaybackSpeed = 1.2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone4
			sound2:Play()
			task.spawn(function()
				local pointLight = Instance.new("PointLight")
				pointLight.Parent = clone4
				pointLight.Color = Color3.fromRGB(255, 110, 43)
				pointLight.Range = 50
				pointLight.Brightness = 1
				wait(0.25)
				TweenService:Create(
					pointLight,
					TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0.25,
						Range = 0
					}
				):Play()
				_G.PU:Dust(pointLight, 1)
			end)

			for _, emitter in pairs(clone4:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") * 1 or 1)
				end
			end

			spawn(function()
				local raycastParams = RaycastParams.new()
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				local raycastResult = workspace:Raycast(
					savecf.p + createVector(0, 5, 0),
					createVector(0, -10, 0),
					raycastParams
				)
				local position = savecf.p + createVector(0, -5, 0)
				local instance, normal

				if raycastResult then
					instance = raycastResult.Instance
					position = raycastResult.Position
					normal = raycastResult.Normal
					local _ = instance.Material
				end

				if instance then
					local clone5 = ReplicatedStorage.Chest.SwordEffect.AuthenticMace.Burn:Clone()
					clone5.Decal.Transparency = 0.25
					clone5.CFrame = CFrame.new(position + normal, position) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
						0,
						6.283185307179586 * math.random(),
						0
					)
					clone5.Parent = workspace.Effects
					_G.PU:Dust(clone5, 1.5)
					TweenService:Create(clone5, TweenInfo.new(0.25), {
						Size = createVector(100, 0, 100)
					}):Play()
					spawn(function()
						wait(0.75)

						if clone5:FindFirstChild("Decal") then
							TweenService:Create(clone5.Decal, TweenInfo.new(0.35), {
								Transparency = 1
							}):Play()
						end
					end)
				end
			end)
		end)
	end)

	if clone then
		wait(0.5)
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			TintColor = Color3.fromRGB(255, 255, 255),
			Saturation = 0
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end