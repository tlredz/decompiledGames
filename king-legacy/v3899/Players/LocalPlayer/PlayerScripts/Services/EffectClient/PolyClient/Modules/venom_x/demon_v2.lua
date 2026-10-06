local createVector = vector.create

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(data)
	local mouseFolder = data.MouseFolder
	local charge = data.Charge
	local char = data.Char
	local root = data.Root
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

	tick()
	local v = root.CFrame * CFrame.new(0, 4, -5)
	local cframe = CFrame.new(mouseFolder.Value)
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.ball2_Demon:Clone()
	clone.Size = createVector(0, 0, 0)
	clone.CanCollide = false
	clone.Anchored = false
	clone.Color = Color3.fromRGB(195, 51, 54)
	clone.Transparency = 1
	clone.Parent = workspace.Effects
	clone.Attachment.Blast.Enabled = true
	clone.Attachment.Blast2.Enabled = true
	TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(15, 15, 1.5)
	}):Play()
	local part = Instance.new("Part")
	part.CFrame = CFrame.new(v.p, cframe.p)
	part.Size = createVector(5, 5, 5)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Parent = workspace.Effects
	local weld = Instance.new("Weld")
	weld.Parent = part
	weld.Part0 = part
	weld.Part1 = clone

	for _, emitter in pairs(clone.Attachment:GetChildren()) do
		if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
		end
	end

	local v2 = 1
	PeodizService.HeartbeatWait({
		Time = 5,
		WaitTime = 0.075
	}, function()
		if not charge:IsDescendantOf(char) then
			return true
		end

		v2 += 1
		localshake("SmallestBump") -- equivalent call inferred; original call site unknown
		v = root.CFrame * CFrame.new(0, 4, -5)
		cframe = CFrame.new(mouseFolder.Value)
		TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = CFrame.new(v.p, cframe.p)
		}):Play()
		local magnitude = (v.p - cframe.p).magnitude
		local _ = CFrame.new(v.p, cframe.p) * CFrame.new(0, 0, -magnitude)
		task.spawn(function()
			local v3 = math.max(math.floor(magnitude / 12), 2) - 1
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Venom.New.head:Clone()
			clone2.CFrame = CFrame.new(v.p, cframe.p)
			clone2.Color = Color3.fromRGB(195, 51, 54)
			clone2.Size = createVector(9.272, 12.428, 17.553)
			clone2.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11633780899",
				Volume = 1.5
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			local v4 = 6.283185307179586 * math.random()
			local v5 = math.random(10, 60)
			local cframes = {}
			local magnitudes = {}

			for i = 0, v3 do
				local v6 = CFrame.new(v.p, cframe.p) * CFrame.new(0, 0, -magnitude / 2) * CFrame.Angles(0, 0, v4) * CFrame.new(
					0,
					v5,
					0
				)
				local v8 = bezier(i / v3, v.p, v6.p, cframe.p)
				local v10 = bezier((i + 1) / v3, v.p, v6.p, cframe.p)
				cframes[i] = CFrame.new((v8 + v10) / 2, v10)
				magnitudes[i] = (v8 - v10).magnitude
			end

			PeodizService.ForLoop({
				Step = v3 - 1
			}, function(p)
				if not charge:IsDescendantOf(char) then
					return true
				end

				local v6 = math.floor(p * (v3 - 1))
				local clone3 = ReplicatedStorage.Chest.FruitEffect.Venom.New.tail:Clone()
				clone3.CFrame = cframes[v6]
				clone3.Size = Vector3.new(0, 0, magnitudes[v6] * 0.75)
				clone3.Color = Color3.fromRGB(195, 51, 54)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = Vector3.new(3.25, 3.5, magnitudes[v6] + 2)
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cframes[v6] * CFrame.new(0, 0, -(magnitudes[v6] - 10))
				}):Play()
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
					}
				):Play()
				_G.PU:Dust(clone3, 0.5)
				task.spawn(function()
					wait(0.125)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Size = createVector(0, 0, 12),
							Transparency = 1
						}
					):Play()
				end)
			end)
			_G.PU:Dust(clone2, 0.5)
			task.spawn(function()
				wait(0.125)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 25),
						Transparency = 1
					}
				):Play()
			end)
		end)

		if v2 % 3 == 0 then
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(20, 20, 1.5)
			}):Play()
			task.spawn(function()
				wait(0.2)
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(15, 15, 1.5)
				}):Play()
			end)

			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 10)
				end
			end
		end
	end)
	clone.Attachment.Blast.Enabled = false
	clone.Attachment.Blast2.Enabled = false
	task.spawn(function()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Transparency = 1,
			Size = Vector3.new()
		}):Play()
	end)
	_G.PU:Dust(weld, 1)
	_G.PU:Dust(clone, 1)
	_G.PU:Dust(part, 1)
end