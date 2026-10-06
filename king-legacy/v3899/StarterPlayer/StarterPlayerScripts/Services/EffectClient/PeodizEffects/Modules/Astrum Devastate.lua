local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local longaevus = ReplicatedStorage.Chest.SwordEffect.Longaevus
return function(p)
	local v = (p.StartCFrame + createVector(0, 1.5, 0)) * CFrame.new(0, 0, -60)
	local clone = ReplicatedStorage.Chest.SwordEffect.Longaevus.SoundPart:Clone()
	clone.CFrame = CFrame.new(v.Position)
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 9)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9185525909",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	local v2 = {
		"http://www.roblox.com/asset/?id=9117661757",
		"http://www.roblox.com/asset/?id=9117662415",
		"http://www.roblox.com/asset/?id=9117663116",
		"http://www.roblox.com/asset/?id=9117664205",
		"http://www.roblox.com/asset/?id=9117664896"
	}
	local clones = {}
	local v3 = {}

	for i = 1, 5 do
		local v4 = 6.283185307179586 * (i / 5)
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = v * CFrame.Angles(0, v4, 0) * CFrame.new(0, 0, -50) + createVector(0, 50, 0)
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(cFrameValue, TweenInfo.new(0.38), {
			Value = v * CFrame.Angles(0, v4, 0) * CFrame.new(0, 0, -50)
		})
		tween:Play()
		local valueChangedConnection = nil
		tween.Completed:Connect(function()
			cFrameValue:Destroy()

			if valueChangedConnection then
				valueChangedConnection:Disconnect()
			end
		end)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.Longaevus.Fores:Clone()
		local v7 = cFrameValue
		valueChangedConnection = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			clone2:SetPrimaryPartCFrame(v7.Value)
		end)

		for _, child in pairs(clone2.Main:GetChildren()) do
			if not child:IsA("Decal") or child:IsA("Texture") then
				continue
			end

			child.Transparency = 1
			child.Texture = v2[i]
		end

		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 10)
		clones[#clones + 1] = clone2
		v3[i] = v * CFrame.Angles(0, v4, 0) * CFrame.new(0, 0, -50)
	end

	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(numberValue, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
		Value = 0
	})
	spawn(function()
		wait(0.35)
		tween:Play()
		pcall(function()
			if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude < 120 then
				_G.CamShake("Astrum")
			end
		end)
	end)
	tween.Completed:Connect(function()
		numberValue:Destroy()
	end)
	local connections = {}
	connections[#connections + 1] = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		for _, v4 in pairs(clones) do
			for _, part in pairs(v4:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "Effect" and v4.Name ~= "Decal" then
					part.Transparency = numberValue.Value
				end
			end
		end
	end)
	spawn(function()
		wait(0.4)
		local clone2 = ReplicatedStorage.Chest.SwordEffect.Longaevus.WindCircle:Clone()
		clone2.CFrame = CFrame.new(v.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone2.Parent = workspace.Effects
		_G.PU:Dust(clone2, 1.5)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Size = createVector(170, 5, 170)
		}):Play()
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone2, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		PeodizService.HeartbeatWait({
			Time = 10,
			WaitTime = 0.1
		}, function()
			if not clone2:IsDescendantOf(workspace.Effects) then
				return true
			end

			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(clone2, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				CFrame = clone2.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()
		end)
	end)
	wait(0.5)
	spawn(function()
		local lastTime = tick()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.05
		}, function()
			for _, v4 in pairs(clones) do
				if not v4:IsDescendantOf(workspace.Effects) then
					continue
				end

				for _, texture in pairs(v4.Main:GetChildren()) do
					if texture:IsA("Texture") then
						texture.OffsetStudsV -= (tick() - lastTime) * 0.5
					end
				end
			end
		end)
	end)
	PeodizService.ForLoop({
		Step = 7,
		WaitTime = 0.05
	}, function(p2)
		math.floor(p2 * 7)
	end)
	local v4 = {
		{ 1, 4 },
		{ 4, 2 },
		{ 2, 5 },
		{ 5, 3 },
		{ 3, 1 }
	}

	for i = 1, 7 do
		local v5 = 0.4 / (i + 1)

		for _, v6 in pairs(clones) do
			for _, child in pairs(v6.Main:GetChildren()) do
				if not child:IsA("Decal") or child:IsA("Texture") then
					continue
				end

				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(child, TweenInfo.new(0.8), {
					Transparency = 1 - (i - 1) / 6
				}):Play()
			end
		end

		for _, v6 in pairs(v4) do
			local v7 = v3[v6[1]]
			local v8 = v3[v6[2]]
			local magnitude = (v7.Position - v8.Position).Magnitude
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(v7.Position, v8.Position)
			part.Size = createVector(3, 3, 0)
			part.Material = "Neon"
			part.Color = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(51, 88, 130), i / 7)
			part.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9185254682",
				PlaybackSpeed = i / 5 + 1,
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = part
			sound2:Play()
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(part, TweenInfo.new(v5, Enum.EasingStyle.Sine), {
				Size = Vector3.new(3, 3, magnitude),
				CFrame = CFrame.new(v7.Position, v8.Position) * CFrame.new(0, 0, -magnitude / 2)
			}):Play()
			local v9 = v5
			spawn(function()
				wait(v9)
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(part, TweenInfo.new(v9, Enum.EasingStyle.Sine), {
					Size = Vector3.new(0.1, 0.1, magnitude),
					CFrame = CFrame.new(v7.Position, v8.Position) * CFrame.new(0, 0, -magnitude / 2)
				}):Play()
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end)
			_G.PU:Dust(part, v5 + 1.25)
			wait(v5)
		end

		wait(0.05)
	end

	for _, v5 in pairs(clones) do
		local primaryPartCFrame = v5:GetPrimaryPartCFrame()
		local cFrameValue = Instance.new("CFrameValue")
		cFrameValue.Value = primaryPartCFrame
		local v6 = v5
		connections[#connections + 1] = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			if not v6:IsDescendantOf(workspace.Effects) then
				return
			end

			v6:SetPrimaryPartCFrame(cFrameValue.Value * CFrame.new(
				math.random() / 1.2,
				math.random() / 1.2,
				math.random() / 1.2
			))
		end)
		local TweenService2 = game:GetService("TweenService")
		local tween2 = TweenService2:Create(
			cFrameValue,
			TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
			{
				Value = cFrameValue.Value * CFrame.new(0, 0, 25)
			}
		)
		tween2:Play()
		local v8 = cFrameValue
		tween2.Completed:Connect(function()
			v8:Destroy()
		end)
	end

	wait(0.5)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9191516410",
		Volume = 4.5
	})
	_G.PU:Dust(sound2, 5)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9191515635",
		Volume = 2
	})
	_G.PU:Dust(sound3, 5)
	sound3.Parent = clone
	sound3:Play()
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9191514652",
		Volume = 3
	})
	_G.PU:Dust(sound4, 5)
	sound4.Parent = clone
	sound4:Play()
	spawn(function()
		wait(0.7)
		local sound5 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9193557847",
			Volume = 0.75
		})
		_G.PU:Dust(sound5, 5)
		sound5.Parent = clone
		sound5:Play()
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(sound5, TweenInfo.new(2), {
			Volume = 0
		}):Play()
	end)

	for _, v5 in pairs(clones) do
		v5:Destroy()
	end

	local clone2 = longaevus.Shockwave:Clone()
	clone2.CFrame = CFrame.new(v.Position)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 1)
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Size = createVector(340, 15, 340)
	}):Play()
	local TweenService3 = game:GetService("TweenService")
	TweenService3:Create(clone2, TweenInfo.new(1.3, Enum.EasingStyle.Exponential), {
		Transparency = 1
	}):Play()
	local clone3 = longaevus.Wind:Clone()
	clone3.CFrame = CFrame.new(v.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	clone3.Parent = workspace.Effects
	_G.PU:Dust(clone3, 2)
	local TweenService4 = game:GetService("TweenService")
	TweenService4:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Exponential), {
		Size = createVector(240, 38.589, 240)
	}):Play()
	spawn(function()
		wait(0.3)
		local TweenService5 = game:GetService("TweenService")
		TweenService5:Create(clone3, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
	end)
	coroutine.wrap(function()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.05
		}, function()
			local TweenService5 = game:GetService("TweenService")
			TweenService5:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
				CFrame = clone3.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()

			if clone3.Transparency >= 1 or not clone3:IsDescendantOf(workspace.Effects) then
				return true
			end
		end)
	end)()

	for i = 1, 2 do
		local clone4 = longaevus.Wave:Clone()
		clone4.CFrame = CFrame.new(v.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0) + createVector(
			0,
			2.5,
			0
		)

		if i == 2 then
			clone4.BrickColor = BrickColor.new("Steel blue")
		end

		clone4.Parent = workspace.Effects
		_G.PU:Dust(clone4, 1.5)
		local TweenService5 = game:GetService("TweenService")
		TweenService5:Create(clone4, TweenInfo.new(0.8333333333333334, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(math.random(100, 150) * 1.5, math.random(15, 25), math.random(100, 150) * 1.5),
			CFrame = clone4.CFrame + createVector(0, 7.5, 0)
		}):Play()
		spawn(function()
			wait(0.2)
			local TweenService6 = game:GetService("TweenService")
			TweenService6:Create(clone4, TweenInfo.new(0.4666666666666666, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
		end)
	end

	local clone4 = longaevus.PartNeon:Clone()
	clone4.CFrame = CFrame.new(v.Position)
	clone4.PartForceField.CFrame = CFrame.new(v.Position)
	clone4.Parent = workspace.Effects
	spawn(function()
		wait(0.75)
		local TweenService5 = game:GetService("TweenService")
		TweenService5:Create(clone4.PointLight, TweenInfo.new(1), {
			Brightness = 0
		}):Play()
	end)
	_G.PU:Dust(clone4, 3.2)
	local TweenService5 = game:GetService("TweenService")
	TweenService5:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = clone4.Size * 25
	}):Play()
	local TweenService6 = game:GetService("TweenService")
	TweenService6:Create(clone4.PartForceField, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = clone4.PartForceField.Size * 25
	}):Play()
	spawn(function()
		wait(0.1)
		local TweenService7 = game:GetService("TweenService")
		TweenService7:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		local TweenService8 = game:GetService("TweenService")
		TweenService8:Create(clone4.PartForceField, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
	end)
	clone4.Attachment.ParticleEmitter2:Emit(math.random(7, 12))
	clone4.Attachment.ParticleEmitter:Emit(math.random(7, 15))
	clone4.Attachment.Fire:Emit(math.random(15, 25))
	clone4.Attachment.Slash:Emit(math.random(5, 8))
	spawn(function()
		wait(0.35)
		local TweenService7 = game:GetService("TweenService")
		TweenService7:Create(clone4.Attachment.ParticleEmitter, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Acceleration = createVector(0, -500, 0)
		}):Play()
	end)
	local clone5 = longaevus.Ring:Clone()
	clone5.CFrame = CFrame.new(v.Position)
	clone5.Parent = workspace.Effects
	_G.PU:Dust(clone5, 1)
	spawn(function()
		wait(0.15)
		local TweenService7 = game:GetService("TweenService")
		TweenService7:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
	end)
	local TweenService7 = game:GetService("TweenService")
	TweenService7:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		Size = createVector(225, 2, 225),
		CFrame = CFrame.new(v.Position) + createVector(0, 50, 0)
	}):Play()
	pcall(function()
		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude < 160 then
			_G.CamShake("Devastate")
		end
	end)
	task.delay(10, function()
		table.clear(v3)
		table.clear(clones)

		for _, connection in pairs(connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(connections)
	end)
end