local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
return function(list)
	local _, v, v2, _ = unpack(list)
	local success, result = pcall(function()
		return (localPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude > 1000
	end)

	if success then
		if result then
			return
		end

		if (localPlayer.Character.HumanoidRootPart.Position - v.p).Magnitude < 150 then
			_G.BeckCameraShake(_G.CameraShakerModule.Presets.Bump)
		end

		spawn(function()
			local v3 = unpack(v2)
			spawn(function()
				for i = 1, 2 do
					local clone = ReplicatedStorage.Chest.SwordEffect.NightBlade.Wind:Clone()
					clone.Size /= 2
					clone.Color = Color3.fromRGB(170, 255, 255)
					clone.CFrame = i == 1 and v * CFrame.new(-15, 0, -5) * CFrame.Angles(0, -0.15707963267948966, 0) or v * CFrame.new(
						15,
						0,
						-5
					) * CFrame.Angles(0, 0.15707963267948966, 0)
					clone.Parent = workspace.Effects
					_G.PU:Dust(clone, 0.5)
					TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
						Transparency = 1,
						Size = clone.Size * 2
					}):Play()
				end
			end)
			tick()

			repeat
				local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
				clone.CFrame = v3.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0)
				clone.Parent = workspace.Effects
				TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(25, 1.5, 25) * (math.random(6, 10) / 10),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone, 0.5)
				wait(0.2)
			until not v3:IsDescendantOf(workspace.Effects)
		end)
	end
end