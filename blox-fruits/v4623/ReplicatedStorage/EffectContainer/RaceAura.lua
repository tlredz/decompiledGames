game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local raceAuras = ReplicatedStorage:WaitForChild("Storage"):WaitForChild("Sound"):WaitForChild("RaceAuras")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local raceV3Auras = FX:WaitForChild("RaceV3Auras")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function ParticleState(folder, enabled, p)
	for _, emitter in pairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if p and emitter:GetAttribute("Color") == true then
			emitter.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		else
			emitter.Enabled = enabled
		end
	end
end

for _, descendant in pairs(raceV3Auras:GetDescendants()) do
	if descendant:IsA("Beam") then
		descendant.Segments *= 2
	elseif descendant:IsA("ParticleEmitter") then
		descendant.Rate *= 4.1
		descendant.LockedToPart = true
	elseif descendant:IsA("Part") and descendant.Name == "Ready" then
		Util.ResizeModel(descendant, 2.5, descendant.Position)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function model(folder, clone, p)
	local model2 = Instance.new("Model")
	model2.Name = clone.Name .. "_Scaled"
	model2.Parent = folder
	clone.Parent = model2
	model2:ScaleTo(p)
end

return function(player)
	local position = player.Character.HumanoidRootPart.Position or player.HRP.Position or player.origin

	if (currentCamera.CFrame.p - position).Magnitude > 2000 then
		return
	end

	if player.Index == 1 then
		local character = player.Character
		local v = player.Duration - (Util.MasterClock:GetTime() - player.Timestamp)

		if v < 0 then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local head = character:FindFirstChild("Head")
		local upperTorso = character:FindFirstChild("UpperTorso")

		if not (humanoidRootPart and head and upperTorso) then
			warn("Character is missing bodyparts for Race Aura.")
			return
		end

		local v2 = humanoidRootPart.Size.Y / 2.02
		local child = raceAuras:FindFirstChild(player.Race .. "Aura")

		if not player.NoSound then
			Util.Sound:Play("Ability", humanoidRootPart.Position)
		end

		local folder = Instance.new("Folder")
		folder.Name = "RaceAuraEffect"
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, v + 5)
		local raceV3Aura = raceV3Auras[player.Race .. "V3"]
		local v3

		if child then
			v3 = sound:Play(player.Race .. "Aura", humanoidRootPart)
		end

		local clone = raceV3Aura.Body:Clone()
		clone.Weld.Part0 = upperTorso
		model(folder, clone, v2) -- equivalent call inferred; original call site unknown
		local clone2 = raceV3Aura.Head:Clone()
		clone2.Weld.Part0 = head
		model(folder, clone2, v2) -- equivalent call inferred; original call site unknown
		local clone3 = raceV3Aura.Activate:Clone()
		clone3.CFrame = humanoidRootPart.CFrame
		model(folder, clone3, v2) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone3:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local value = clone2.Circles:GetChildren()[1].Color.Keypoints[1].Value
		local value2

		if clone2.Circles:GetChildren()[2] then
			value2 = clone2.Circles:GetChildren()[2].Color.Keypoints[1].Value
		else
			value2 = value
		end

		local clone4 = script.Part.Attachment:Clone()
		local glow = clone4.Glow
		glow.Lifetime = NumberRange.new(0.4166666666666667)
		glow.Color = ColorSequence.new(value, value2)
		clone4.Parent = humanoidRootPart
		Util.Debris:AddItem(clone4, v + 5)
		local lastTime = os.clock()
		local v4 = 0

		while os.clock() - lastTime < v - 0.2 do
			if os.clock() - v4 > 0.5 then
				v4 = not (os.clock() - lastTime < v - 0.2 - 0.4166666666666667 - 0.016666666666666666) and 1e999 or os.clock()
				glow:Emit(1)
			end

			task.wait()
		end

		if humanoidRootPart and head and upperTorso then
			if v3 then
				sound:FadeOut(v3, 1)
			end

			for _, emitter in pairs(clone2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, beam in folder:GetDescendants() do
				if beam:IsA("Beam") then
					TweenService:Create(beam, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end
		elseif folder then
			folder:Destroy()
		end
	else
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart") or player.HRP

		if not humanoidRootPart then
			return
		end

		local v = humanoidRootPart.Size.Y / 2.02
		local folder = Instance.new("Folder")
		folder.Name = "RaceAuraCD"
		folder.Parent = _WorldOrigin
		Util.Debris:AddItem(folder, 5)
		local clone = raceV3Auras[player.Race .. "V3"].Ready:Clone()
		clone.CFrame = humanoidRootPart.CFrame
		clone.Weld.Part0 = humanoidRootPart
		model(folder, clone, v) -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		Util.Sound:Play("AbilityRefresh", humanoidRootPart.Position)
	end
end