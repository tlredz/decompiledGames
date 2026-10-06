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
		weld.Part1 = target.HumanoidRootPart
		weld.Part0 = clone
		weld.C0 = CFrame.new()
		weld.Parent = clone
		clone.Parent = workspace.Effects
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

			if clone.Parent then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://10071401094",
					PlaybackSpeed = 2,
					Volume = 1
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = clone
				sound2:Play()
				local sound3 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8798746484",
					PlaybackSpeed = 1.5,
					Volume = 1
				})
				_G.PU:Dust(sound3, 3)
				sound3.Parent = clone
				sound3:Play()
			end

			if clone:FindFirstChild("Attachment2") then
				for _, emitter in pairs(clone.Attachment2:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
					end
				end
			end

			TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
		end)
	end)
end