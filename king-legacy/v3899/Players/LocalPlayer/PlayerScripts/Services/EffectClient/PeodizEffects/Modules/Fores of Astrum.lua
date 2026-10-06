local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local _ = {
	"http://www.roblox.com/asset/?id=9117661757",
	"http://www.roblox.com/asset/?id=9117662415",
	"http://www.roblox.com/asset/?id=9117663116",
	"http://www.roblox.com/asset/?id=9117664205",
	"http://www.roblox.com/asset/?id=9117664896"
}
local PeodizLightning = require(ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules").PeodizLightning)

function HideFores(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
		elseif descendant:IsA("SurfaceLight") or descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant:Destroy()
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end
	end
end

return function(data)
	local v = data.StartCFrame + createVector(0, 1.5, 0)
	local endCFrame = data.EndCFrame
	local v2 = v * CFrame.new(0, 0, -15) * CFrame.Angles(0, 3.141592653589793, 0) + createVector(0, 50, 0)
	local v3 = v * CFrame.new(0, 0, -15) * CFrame.Angles(0, 3.141592653589793, 0)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = v2
	local clone = ReplicatedStorage.Chest.SwordEffect.Longaevus.Fores2:Clone()
	clone:SetPrimaryPartCFrame(v2)
	clone.Parent = workspace.Effects
	TweenService:Create(cFrameValue, TweenInfo.new(0.5), {
		Value = v3
	}):Play()
	local connections = {}
	connections[#connections + 1] = cFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		clone:SetPrimaryPartCFrame(cFrameValue.Value)
	end)
	delay(0.4, function()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9203789480",
			Volume = 1.77
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone.Main
		sound:Play()
	end)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 1
	local transparenciesByDescendant = {}

	for _, descendant in pairs(clone:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Texture")) then
			continue
		end

		transparenciesByDescendant[descendant] = descendant.Transparency
		descendant.Transparency = 1
	end

	spawn(function()
		wait(0.2)
		TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 0
		}):Play()
	end)
	connections[#connections + 1] = numberValue:GetPropertyChangedSignal("Value"):Connect(function()
		for k, v4 in pairs(transparenciesByDescendant) do
			k.Transparency = math.max(numberValue.Value, v4)
		end
	end)
	task.delay(10, function()
		table.clear(transparenciesByDescendant)
	end)
	_G.PU:Dust(clone, 2)
	_G.PU:Dust(cFrameValue, 4)
	_G.PU:Dust(numberValue, 4)
	wait(0.3)
	local v4 = endCFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, 3.141592653589793, 0) + createVector(0, 50, 0)
	local v5 = endCFrame * CFrame.new(0, 0, 2) * CFrame.Angles(0, 3.141592653589793, 0)
	local cFrameValue2 = Instance.new("CFrameValue")
	cFrameValue2.Value = v4
	local clone2 = ReplicatedStorage.Chest.SwordEffect.Longaevus.Fores2:Clone()
	clone2:SetPrimaryPartCFrame(v4)
	clone2.Parent = workspace.Effects
	TweenService:Create(cFrameValue2, TweenInfo.new(0.5), {
		Value = v5
	}):Play()
	connections[#connections + 1] = cFrameValue2:GetPropertyChangedSignal("Value"):Connect(function()
		wait()
		clone2:SetPrimaryPartCFrame(cFrameValue2.Value)
	end)
	delay(0.4, function()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9203789480",
			Volume = 1.77
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone.Main
		sound:Play()
	end)
	local numberValue2 = Instance.new("NumberValue")
	numberValue2.Value = 1
	local transparenciesByDescendant2 = {}

	for _, descendant in pairs(clone2:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Texture")) then
			continue
		end

		transparenciesByDescendant2[descendant] = descendant.Transparency
		descendant.Transparency = 1
	end

	spawn(function()
		wait(0.2)
		TweenService:Create(numberValue2, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Value = 0
		}):Play()
	end)
	connections[#connections + 1] = numberValue2:GetPropertyChangedSignal("Value"):Connect(function()
		wait()

		for k, v6 in pairs(transparenciesByDescendant2) do
			k.Transparency = math.max(numberValue2.Value, v6)
		end
	end)
	_G.PU:Dust(clone2, 2)
	_G.PU:Dust(cFrameValue2, 4)
	_G.PU:Dust(numberValue2, 4)
	wait(0.35)
	local v6 = { data.Char.HumanoidRootPart.Position, v3.Position, v5.Position }

	for k, position in pairs(v6) do
		local v7 = position
		pcall(function()
			if game.Players.LocalPlayer.Name == data.Char.Name then
				local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
				PeoUtils.LerpCF(humanoidRootPart, TweenInfo.new(0.1), CFrame.new(v7))
			end
		end)

		if k == 2 then
			numberValue:Destroy()
			clone.Main.ParticleEmitter:Emit(math.random(10, 15))
			HideFores(clone)
		elseif k == 3 then
			numberValue2:Destroy()
			clone2.Main.ParticleEmitter:Emit(math.random(10, 15))
			HideFores(clone2)
		end

		wait(0.1)
		local clone3 = ReplicatedStorage.Chest.SwordEffect.Longaevus.SoundPart2:Clone()
		clone3.CFrame = CFrame.new(position)
		clone3.Parent = workspace.Effects
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9203313181",
			PlaybackSpeed = math.random(90, 110) / 100,
			Volume = 3
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone3
		sound:Play()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9185254682",
			PlaybackSpeed = math.random(150, 190) / 100,
			Volume = 3
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone3
		sound2:Play()
		_G.PU:Dust(clone3, 1.2)

		if not v6[k + 1] then
			continue
		end

		PeodizLightning.new(0.5, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position1 = position,
			Position2 = v6[k + 1],
			Step = 5
		}):Play()
		local clone4 = ReplicatedStorage.Chest.SwordEffect.Longaevus.Shock:Clone()
		clone4.CFrame = CFrame.new(position, v6[k + 1]) * CFrame.new(0, 0, -(position - v6[k + 1]).Magnitude / 2)
		clone4.Size = createVector(0.5, 0.5, 0)
		clone4.Parent = workspace.Effects
		clone4.ParticleEmitter2:Emit(math.random(2, 4))
		_G.PU:Dust(clone4, 1.55)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Exponential), {
			Size = Vector3.new(4.5, 4.5, (position - v6[k + 1]).Magnitude)
		}):Play()
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone4, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			CFrame = clone4.CFrame * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
		}):Play()
		spawn(function()
			wait(0.3)
			local TweenService4 = game:GetService("TweenService")
			TweenService4:Create(clone4, TweenInfo.new(0.77, Enum.EasingStyle.Quart), {
				Transparency = 1
			}):Play()
		end)
	end

	task.delay(10, function()
		table.clear(v6)
	end)
	wait(0.11)
	local cframe = CFrame.new((endCFrame + createVector(0, 2, 0)).p)
	local clone3 = ReplicatedStorage.Chest.SwordEffect.Longaevus.SoundPart:Clone()
	_G.PU:Dust(clone3, 9)
	clone3.CFrame = CFrame.new(cframe.Position)
	clone3.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9185525909",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone3
	sound:Play()
	local numberValue3 = Instance.new("NumberValue")
	numberValue3.Value = 1
	local v7 = {
		"http://www.roblox.com/asset/?id=9117661757",
		"http://www.roblox.com/asset/?id=9117662415",
		"http://www.roblox.com/asset/?id=9117663116",
		"http://www.roblox.com/asset/?id=9117664205",
		"http://www.roblox.com/asset/?id=9117664896"
	}
	local clones = {}
	local v8 = {}

	for i = 1, 5 do
		local v9 = 6.283185307179586 * (i / 5)
		local cFrameValue3 = Instance.new("CFrameValue")
		cFrameValue3.Value = cframe * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -44) + createVector(0, 50, 0)
		local TweenService2 = game:GetService("TweenService")
		local tween = TweenService2:Create(cFrameValue3, TweenInfo.new(0.38), {
			Value = cframe * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -44)
		})
		tween:Play()
		local valueChangedConnection = nil
		tween.Completed:Connect(function()
			cFrameValue3:Destroy()

			if valueChangedConnection then
				valueChangedConnection:Disconnect()
			end
		end)
		local clone4 = ReplicatedStorage.Chest.SwordEffect.Longaevus.Fores:Clone()
		local v12 = cFrameValue3
		valueChangedConnection = cFrameValue3:GetPropertyChangedSignal("Value"):Connect(function()
			clone4:SetPrimaryPartCFrame(v12.Value)
		end)

		for _, child in pairs(clone4.Main:GetChildren()) do
			if not child:IsA("Decal") or child:IsA("Texture") then
				continue
			end

			child.Transparency = 1
			child.Texture = v7[i]
		end

		clone4.Parent = workspace.Effects
		_G.PU:Dust(clone4, 6.5)
		clones[#clones + 1] = clone4
		v8[i] = cframe * CFrame.Angles(0, v9, 0) * CFrame.new(0, 0, -44)
	end

	local TweenService2 = game:GetService("TweenService")
	local tween = TweenService2:Create(numberValue3, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
		Value = 0
	})
	spawn(function()
		wait(0.35)
		tween:Play()
		pcall(function()
			if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude < 60 then
				_G.CamShake("Astrum")
			end
		end)
	end)
	tween.Completed:Connect(function()
		numberValue3:Destroy()
	end)
	connections[#connections + 1] = numberValue3:GetPropertyChangedSignal("Value"):Connect(function()
		for _, v9 in pairs(clones) do
			for _, part in pairs(v9:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "Effect" and v9.Name ~= "Decal" then
					part.Transparency = numberValue3.Value
				end
			end
		end
	end)
	spawn(function()
		wait(0.4)
		local clone4 = ReplicatedStorage.Chest.SwordEffect.Longaevus.WindCircle:Clone()
		clone4.CFrame = CFrame.new(cframe.Position) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone4.Parent = workspace.Effects
		_G.PU:Dust(clone4, 1.5)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
			Size = createVector(130, 5, 130)
		}):Play()
		local TweenService4 = game:GetService("TweenService")
		TweenService4:Create(clone4, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
			Transparency = 1
		}):Play()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.1
		}, function()
			local TweenService5 = game:GetService("TweenService")
			TweenService5:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				CFrame = clone4.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
			}):Play()

			if clone4:IsDescendantOf(workspace.Effects) then
				return
			else
				return true
			end
		end)
	end)
	wait(0.15)
	spawn(function()
		local lastTime = tick()
		PeodizService.HeartbeatWait({
			Time = 5,
			WaitTime = 0.05
		}, function()
			for _, v9 in pairs(clones) do
				if not v9:IsDescendantOf(workspace.Effects) then
					continue
				end

				for _, texture in pairs(v9.Main:GetChildren()) do
					if texture:IsA("Texture") then
						texture.OffsetStudsV -= (tick() - lastTime) * 0.5
					end
				end
			end
		end)
	end)
	local v9 = {
		{ 1, 4 },
		{ 4, 2 },
		{ 2, 5 },
		{ 5, 3 },
		{ 3, 1 }
	}

	for i = 1, 7 do
		local v10 = 0.25 / (i + 1)

		for _, v11 in pairs(clones) do
			if not v11:FindFirstChild("Main") then
				continue
			end

			for _, child in pairs(v11.Main:GetChildren()) do
				if not child:IsA("Decal") or child:IsA("Texture") then
					continue
				end

				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(child, TweenInfo.new(0.8), {
					Transparency = 1 - (i - 1) / 6
				}):Play()
			end
		end

		for k, v11 in pairs(v9) do
			local v12 = v8[v11[1]]
			local v13 = v8[v11[2]]
			local magnitude = (v12.Position - v13.Position).Magnitude
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(v12.Position, v13.Position)
			part.Size = createVector(1.7, 1.7, 0)
			part.Material = "Neon"
			part.Color = Color3.fromRGB(255, 255, 255):Lerp(Color3.fromRGB(255, 0, 0), i / 7)
			part.Parent = workspace.Effects
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://9185254682",
				PlaybackSpeed = 2 - i / 5,
				Volume = 0.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = part
			sound2:Play()
			local TweenService3 = game:GetService("TweenService")
			TweenService3:Create(part, TweenInfo.new(v10, Enum.EasingStyle.Sine), {
				Size = Vector3.new(1.7, 1.7, magnitude),
				CFrame = CFrame.new(v12.Position, v13.Position) * CFrame.new(0, 0, -magnitude / 2)
			}):Play()
			local v14 = v10
			spawn(function()
				wait(v14)
				local TweenService4 = game:GetService("TweenService")
				TweenService4:Create(part, TweenInfo.new(v14, Enum.EasingStyle.Sine), {
					Size = Vector3.new(0.1, 0.1, magnitude),
					CFrame = CFrame.new(v12.Position, v13.Position) * CFrame.new(0, 0, -magnitude / 2)
				}):Play()
				local TweenService5 = game:GetService("TweenService")
				TweenService5:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					Transparency = 1
				}):Play()
			end)

			if i <= 1 then
				local v19 = CFrame.new(v12.Position, v13.Position) * CFrame.new(0, 0, -magnitude)

				if k == #v9 then
					v19 = cframe
				end

				pcall(function()
					if game.Players.LocalPlayer.Name == data.Char.Name then
						local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
						PeoUtils.LerpCF(humanoidRootPart, TweenInfo.new(0.1), v19)
					end
				end)
			end

			_G.PU:Dust(part, v10 + 1.25)
			wait(v10)
		end

		wait(0.05)
	end

	wait(0.1)

	for _, v10 in pairs(clones) do
		v10.Main.ParticleEmitter:Emit(math.random(10, 20))
		HideFores(v10)
	end

	task.delay(15, function()
		table.clear(clones)
		table.clear(v9)
		table.clear(v8)
		table.clear(clones)
		table.clear(v7)
		table.clear(transparenciesByDescendant2)

		for _, connection in pairs(connections) do
			if connection.Connected then
				connection:Disconnect()
			end
		end

		table.clear(connections)
	end)
end