local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(player)
	local character = player.Character
	local folder = player.Folder
	spawn(function()
		local lastTime = tick()
		local clone = ReplicatedStorage.Chest.FruitEffect.Paw.Paw.AttachmentHand:Clone()
		clone.Shock.Lifetime = NumberRange.new(0.25)
		clone.Shock.Enabled = true
		clone.Parent = character.RightHand
		_G.PU:Dust(clone, 2)

		while true do
			wait(0.125)

			if tick() - lastTime > 2 then
				break
			end

			clone.Shock:Emit(1)
			local cFrame = character.HumanoidRootPart.CFrame
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Paw.Paw2:Clone()
			_G.PU:Dust(clone2, 1)
			clone2.CFrame = cFrame * CFrame.new(0, 5, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, -150)
			}):Play()
			local sound = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://7154125081",
				Volume = 0.5,
				PlaybackSpeed = 2
			})
			_G.PU:Dust(sound, 3)
			sound.Parent = clone2
			sound:Play()
			spawn(function()
				wait(0.25)
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Transparency = 1
				}):Play()

				for i, trail in pairs(clone2:GetChildren()) do
					if trail:IsA("Trail") then
						trail.Enabled = false
					end
				end
			end)

			if not folder:IsDescendantOf(character) or character.Humanoid.Health <= 0 then
				break
			end
		end

		_G.PU:Dust(clone, 1)
	end)
end