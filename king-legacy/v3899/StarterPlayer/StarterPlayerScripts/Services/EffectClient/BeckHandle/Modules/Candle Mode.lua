local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(list)
	local _, cFrame, v2, _ = unpack(list)
	local success, result = pcall(function()
		if type(v2) == "table" and v2.LoopDistance then
			return false
		end

		if cFrame then
			return (localPlayer.Character.HumanoidRootPart.Position - cFrame.p).Magnitude > 1000
		end

		return false
	end)

	if success then
		if result then
			return
		end

		local mode = v2.Mode

		if mode == "Z" then
			local clone = ReplicatedStorage.Chest.Etc.BallMan["Candle Mace"]:Clone()
			clone.Size = Vector3.new()
			clone.CFrame = cFrame * CFrame.new(0, 100, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
			clone.Parent = workspace.Effects
			_G.PU:Dust(clone, 3)
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
				Size = createVector(54.73, 10.703, 10.691)
			}):Play()
			local clone2 = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
			clone2.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.159, 27.75),
				NumberSequenceKeypoint.new(1, 39.449999999999996, 0)
			})
			clone2.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.165, 19.650000000000002, 3.585),
				NumberSequenceKeypoint.new(0.483, 6.72, 3.585),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone2.Attachment.Spark.Speed = NumberRange.new(187.5, 225)
			clone2.CFrame = cFrame * CFrame.new(0, 85, 0)
			clone2.Parent = workspace.Effects
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://9569992804",
				Volume = 5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 1)
			sound.Parent = clone2
			sound:Play()
			clone2.Attachment.Ring:Emit(1)
			clone2.Attachment.Spark:Emit(30)
			_G.PU:Dust(clone2, 1)
			wait(0.5)
			TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
				CFrame = cFrame * CFrame.new(0, 15, 0) * CFrame.Angles(0, 0, -1.5707963267948966)
			}):Play()
			wait(0.1)
			local clone3 = ReplicatedStorage.Chest.SwordEffect.TashiBlade.Ex:Clone()
			clone3.CFrame = cFrame
			local attachment = clone3.Attachment
			attachment.Burst.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 52.5, 27.150000000000002)
			})
			attachment.Burst.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			attachment.Burst2.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 51, 26.4)
			})
			attachment.Burst2.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			attachment.Lines.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 13.125, 13.125),
				NumberSequenceKeypoint.new(1, 0)
			})
			attachment.Lines.Speed = NumberRange.new(150, 300)
			attachment.Lines.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 68.39999999999999, 23.400000000000002)
			})
			attachment.Ring.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			clone3.Parent = workspace.Effects
			attachment.Burst:Emit(5)
			attachment.Burst2:Emit(3)
			attachment.Lines:Emit(30)
			attachment.Ring:Emit(2)
			_G.PU:Dust(clone3, 1.25)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9547580894",
				Volume = 2
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone3
			sound2:Play()
			TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
		elseif mode == "X" then
			local clone = ReplicatedStorage.Chest.Etc.AllMeshes.Rings:Clone()
			clone.Transparency = -1
			clone.Size = Vector3.new()
			clone.CFrame = CFrame.new(cFrame.p) * CFrame.new(0, 3, 0) * CFrame.Angles(0, 0, 3.141592653589793)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
				Size = createVector(120, 5, 120),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 0.5)
			local clone2 = ReplicatedStorage.Chest.Etc.BallMan.ParticlePart:Clone()
			clone2.Attachment.Ring.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.159, 37),
				NumberSequenceKeypoint.new(1, 52.599999999999994, 0)
			})
			clone2.Attachment.Spark.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.165, 26.200000000000003, 4.779999999999999),
				NumberSequenceKeypoint.new(0.483, 8.96, 4.779999999999999),
				NumberSequenceKeypoint.new(1, 0)
			})
			clone2.Attachment.Spark.Speed = NumberRange.new(250, 300)
			clone2.Attachment.Spark.SpreadAngle = Vector2.new(90, -90)
			clone2.CFrame = cFrame
			clone2.Parent = workspace.Effects
			local v3 = {
				RollOffMaxDistance = 300,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.Inverse,
				SoundId = "rbxassetid://9569992804",
				Volume = 5
			}
			local sound = PeoUtils.CreateSound(v3)
			_G.PU:Dust(sound, 1)
			sound.Parent = clone2
			sound:Play()
			clone2.Attachment.Ring:Emit(1)
			clone2.Attachment.Spark:Emit(20)
			_G.PU:Dust(clone2, 1)
			spawn(function()
				for _ = 1, 5 do
					local clone3 = ReplicatedStorage.Chest.Etc.MeshStorage.Thing:Clone()
					clone3.CastShadow = false
					clone3.Transparency = -1
					clone3.Size = createVector(0, 10, 0)
					clone3.Color = Color3.fromRGB(202, 203, 209)
					clone3.Material = Enum.Material.SmoothPlastic
					clone3.CFrame = cFrame
					clone3.Parent = workspace.Effects
					_G.PU:Dust(clone3, 1)
					game.TweenService:Create(clone3, TweenInfo.new(0.5), {
						Size = createVector(100, 1, 100)
					}):Play()
					spawn(function()
						wait(0.5)
						game.TweenService:Create(clone3, TweenInfo.new(0.25), {
							Transparency = 1
						}):Play()
					end)
					wait(0.05)
				end
			end)
		end
	end
end