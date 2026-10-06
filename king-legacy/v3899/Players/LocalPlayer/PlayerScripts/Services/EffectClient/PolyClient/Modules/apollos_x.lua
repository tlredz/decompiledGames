local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("TweenService")
return function(p, _)
	local localPlayer = game.Players.LocalPlayer
	local char = p.char
	local cFrame = p.cf * CFrame.new(0, 0, -30)

	if not char then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rangeshake(p2, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - p.cf.p).Magnitude then
			_G.shake(p2)
		end
	end

	tick()
	local count = 0
	PeodizService.HeartbeatWait({
		Time = 2,
		WaitTime = 0.05
	}, function()
		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not (char:IsDescendantOf(workspace.PlayerCharacters) and char:FindFirstChild("ApollosXCharge") and humanoidRootPart) then
			return true
		end

		count += 1
		cFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -30)
		local clone = replicatedStorage.Chest.SwordEffect.Apollos.apollos_x.emit:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		clone.star:Emit(1)
		clone.flare:Emit(2.5)
		clone.flare2:Emit(2.5)
		_G.PU:Dust(clone, 1)

		if count % 3 == 0 then
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11048219005",
				Volume = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
		end

		local clone2 = replicatedStorage.Chest.SwordEffect.Apollos.apollos_x.slash2:Clone()
		clone2.CFrame = cFrame * CFrame.Angles(
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random(),
			6.283185307179586 * math.random()
		) * CFrame.new(0, 0, -5)
		clone2.Parent = workspace.Effects
		clone2.Mesh.Scale = createVector(1.2860501, 0.85595, 1.38635)
		local Animate = require(clone2.Animate)
		Animate()
		_G.PU:Dust(clone2, 0.25)
		game.TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()
		game.TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = createVector(1.513, 1.007, 1.631)
		}):Play()
		game.TweenService:Create(
			clone.PointLight,
			TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Range = 20,
				Brightness = 0
			}
		):Play()
		rangeshake("SmallerBump", 60) -- equivalent call inferred; original call site unknown
	end)
end