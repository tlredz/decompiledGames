local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local target = p.target
	local freezetime = p.freezetime
	pcall(function()
		local size = createVector(6, 9, 6) * target.HumanoidRootPart.Size.Y / 2
		local clone = ReplicatedStorage.Chest.SwordEffect.SoulCane.IceFrozen:Clone()
		clone.Material = "Neon"
		clone.CFrame = target.HumanoidRootPart.CFrame
		clone.Size = Vector3.new()
		local localPlayer = game.Players.LocalPlayer
		local cFrame = clone.CFrame

		if (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude < 20 then
			_G.shake("SmallBump")
		end

		local weld = Instance.new("Weld")
		weld.Part0 = target.HumanoidRootPart
		weld.Part1 = clone
		weld.Parent = clone
		clone.Parent = target
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = size
		}):Play()
		_G.PU:Dust(clone, freezetime + 1)
		clone.Smoke:Emit(10)
		clone.Dots:Emit(10)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9970012738",
			PlaybackSpeed = 1.25,
			Volume = 1
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		task.spawn(function()
			wait(freezetime)
			clone.Embers:Emit(15)
			clone.Attachment.Ring:Emit(2)
			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
	end)
end