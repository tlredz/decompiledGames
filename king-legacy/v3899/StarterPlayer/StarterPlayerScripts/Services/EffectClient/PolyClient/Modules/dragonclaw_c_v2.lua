local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf

	if not char then
		return
	end

	tick()
	PeodizService.HeartbeatWait({
		Time = 4,
		WaitTime = 0.2
	}, function()
		if not char:IsDescendantOf(workspace) then
			return true
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and char:FindFirstChild("DragonClawHold")) then
			return true
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 30 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallestBump")
		end

		PeodizService.ForLoop({
			Step = 2,
			WaitTime = 0.1
		}, function(p)
			local v = math.floor(p * 6)
			local cFrame = humanoidRootPart.CFrame
			local v2 = v == 2 and -1 or 1
			local clone = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.slash1:Clone()
			clone.CFrame = cFrame * CFrame.Angles(0, 0, (math.rad(v2 * 45))) * CFrame.Angles(0, 0.5235987755982988, 0)
			clone.Mesh.Scale = clone.Mesh.Scale * 0.75
			clone.Parent = workspace.Effects
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://11869820506",
				PlaybackSpeed = 1.25,
				Volume = 1
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone
			sound:Play()
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://8748164748",
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone
			sound2:Play()
			local Animate = require(clone.Animate)
			Animate()
			clone.Attachment.wind:Emit(2)
			clone.Attachment.shards1:Emit(15)
			game.TweenService:Create(
				clone.Mesh,
				TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = clone.Mesh.Scale * 1.75
				}
			):Play()
			wait()
			local pointLight = Instance.new("PointLight")
			pointLight.Parent = humanoidRootPart
			pointLight.Color = Color3.fromRGB(213, 168, 137)
			pointLight.Brightness = 1.5
			pointLight.Range = 30
			TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Brightness = 0
			}):Play()
			local clone2 = replicatedStorage.Chest.Etc.DragonClaw.DragonClawV2.slashline:Clone()
			clone2.Parent = workspace.Effects
			clone2:SetPrimaryPartCFrame(cFrame * CFrame.Angles(0, 3.141592653589793, (math.rad(v2 * 25))) * CFrame.new(
				0,
				0,
				10
			))
			local Animate2 = require(clone2.slash2.Animate)
			Animate2()
			local Animate3 = require(clone2.slash1.Animate)
			Animate3()
			clone2.core.Attachment2.flame:Emit(5)
			clone2.core.Attachment3.flame:Emit(5)
			clone2.core.Attachment.Outline:Emit(1)
			clone2.core.Attachment.big.Rotation = NumberRange.new(v2 * 25)
			clone2.core.Attachment.big:Emit(1)
			game.TweenService:Create(
				clone2.slash1.Mesh,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(1, 0.25, 0)
				}
			):Play()
			game.TweenService:Create(
				clone2.slash2.Mesh,
				TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Scale = createVector(-1, -0.25, -0)
				}
			):Play()
			_G.PU:Dust(clone2, 1)
			game.TweenService:Create(
				clone,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
				}
			):Play()
			_G.PU:Dust(clone, 1)
		end)
	end)
end