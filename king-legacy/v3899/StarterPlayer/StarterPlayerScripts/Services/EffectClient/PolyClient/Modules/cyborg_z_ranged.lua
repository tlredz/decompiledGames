local createVector = vector.create

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
	local _ = data.Root
	local localPlayer = game.Players.LocalPlayer

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
	local clone = ReplicatedStorage.Chest.Etc.Cyborg.accel_ray:Clone()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 6)
	local v = 1

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.05
	}, function()
		if not charge:IsDescendantOf(char) then
			return true
		end

		v += 1

		local function shoot(cFrame)
			if v % 4 == 0 then
				local v2 = 50
				local p = cFrame.p
				local v3 = "SmallestBump"
				task.spawn(function()
					v2 = v2 or 100

					if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p).Magnitude < v2 then
						_G.shake(v3)
					end
				end)
			end

			local _ = v % 2 == 0
			local clone2 = ReplicatedStorage.Chest.Etc.Cyborg.round:Clone()
			clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			local clone3 = ReplicatedStorage.Chest.Etc.Cyborg.square:Clone()
			clone3.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone3.Parent = workspace.Effects
			local clone4 = ReplicatedStorage.Chest.Etc.Cyborg.fx:Clone()
			clone4.CFrame = cFrame
			clone4.Parent = workspace.Effects
			_G.PU:Dust(clone2, 1)
			_G.PU:Dust(clone3, 1)
			_G.PU:Dust(clone4, 1)
			clone2.Size = Vector3.new()
			clone3.Size = Vector3.new()
			clone4.Attachment.dot:Emit(10)
			clone4.Attachment.ring:Emit(2)
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(14.06125, 0.29500002, 14.06125)
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(9.99875, 0.5625, 9.99875)
			}):Play()
			task.spawn(function()
				wait()
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color = Color3.fromRGB(225, 116, 255)
					}
				):Play()
				TweenService:Create(
					clone3,
					TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
					}
				):Play()
				wait()
				local sound = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://11970727712",
					Volume = 1
				})
				_G.PU:Dust(sound, 3)
				sound.Parent = clone4
				sound:Play()
				clone4.Attachment.shards1:Emit(8)
				clone4.Attachment.dot2:Emit(10)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color = Color3.fromRGB(101, 162, 199)
					}
				):Play()
				TweenService:Create(
					clone2,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone2.CFrame * CFrame.Angles(0, -3.141592653589793, 0)
					}
				):Play()
				wait(0.3)
				clone4.Blast1:Emit(5)
				clone4.Blast2:Emit(5)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				wait()
				TweenService:Create(
					clone3,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				clone4.Attachment.ring2:Emit(1)
			end)
			task.spawn(function()
				wait()
				local clone5 = ReplicatedStorage.Chest.Etc.Cyborg.spike:Clone()
				clone5.CFrame = cFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone5.Parent = workspace.Effects
				clone5.Size = Vector3.new()
				_G.PU:Dust(clone5, 0.5)
				TweenService:Create(clone5, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(3, 45, 3),
					CFrame = clone5.CFrame * CFrame.new(0, 25, 0)
				}):Play()
				wait()
				TweenService:Create(
					clone5,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Color = Color3.fromRGB(225, 116, 255)
					}
				):Play()
				wait(0.1)
				TweenService:Create(clone5, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(0, 45, 0)
				}):Play()
			end)
		end

		local v2 = CFrame.new(mouseFolder.Value) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.Angles(
			3.141592653589793 * math.random(),
			0,
			0
		) * CFrame.new(0, 0, -40)
		shoot(CFrame.new(v2.p, mouseFolder.Value))
		clone.CFrame = CFrame.new(mouseFolder.Value)
	end)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	_G.PU:Dust(clone, 1)
end