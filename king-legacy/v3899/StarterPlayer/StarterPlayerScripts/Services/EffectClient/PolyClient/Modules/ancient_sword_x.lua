local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(data, _)
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

	local char = data.char
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	localshake("SmallBump") -- equivalent call inferred; original call site unknown
	local clone = replicatedStorage.Chest.SwordEffect.AncientSword.Shield:Clone()
	_G.PU:Dust(clone, 6)
	clone.main.CFrame = humanoidRootPart.CFrame
	clone.Parent = char
	clone.main.Attachment.sw2:Emit(5)
	clone.main.Attachment.ring:Emit(1)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://13289072408",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone.main
	sound:Play()

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		part.shard:Emit(9)
		part.shards1:Emit(10)
		part.Size = Vector3.new()
		TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(5.297, 6.047, 1.418)
		}):Play()
	end

	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = humanoidRootPart
	weld.Part1 = clone.main
	weld.C0 = CFrame.new(0, 0, 0)
	_G.PU:Dust(weld, 6)
	task.spawn(function()
		wait(5)

		for _, part in pairs(clone:GetChildren()) do
			if part:IsA("MeshPart") then
				TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = createVector(0, 0, 0)
				}):Play()
			end
		end
	end)
	PeodizService.HeartbeatWait({
		Time = 25
	}, function()
		if not clone:IsDescendantOf(char) then
			return true
		end

		weld.C0 *= CFrame.Angles(0, 0.05235987755982989, 0)
	end)
end