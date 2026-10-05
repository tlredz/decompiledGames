local createVector = vector.create
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Util = require(game.ReplicatedStorage.Util)
local Effect = require(game.ReplicatedStorage.Effect)
local FX = require(game.ReplicatedStorage.FX)
local ultimate = FX:WaitForChild("DogHouse").Ultimate
return function(player)
	local phase = player.Phase or 2
	local character = player.Character

	if not character then
		return
	end

	local root = player.Root or character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	local name = "IndraUltimateRoarStartImpact_" .. tostring(player.ID or character.Name)
	local screenRange = player.ScreenRange or player.Range or player.Radius or 650

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isLocalPlayerNearRoar()
		local localPlayer = Players.LocalPlayer

		if not localPlayer then
			return true
		end

		local character2 = localPlayer.Character
		local humanoidRootPart = character2 and character2:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			return (humanoidRootPart.Position - root.Position).Magnitude <= screenRange
		end

		return false
	end

	local function muteBackgroundMusic(duration: number, flag: boolean?)
		local volumesBySound = {}

		local function tryMute(sound)
			if not sound:IsA("Sound") or not sound.Playing or sound.Volume <= 0 or not sound.Looped and sound.TimeLength < 8 then
				return
			end

			if sound:GetAttribute("IndraUltimateMuted") then
				return
			end

			sound:SetAttribute("IndraUltimateMuted", true)
			sound:SetAttribute("IndraUltimateOldVolume", sound.Volume)
			volumesBySound[sound] = sound.Volume
			TweenService:Create(sound, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end

		for _, descendant in ipairs(SoundService:GetDescendants()) do
			tryMute(descendant)
		end

		for _, descendant in ipairs(workspace:GetDescendants()) do
			tryMute(descendant)
		end

		if flag then
			return
		end

		task.delay(duration, function()
			for k, volume in pairs(volumesBySound) do
				if not (k and k.Parent) then
					continue
				end

				local indraUltimateOldVolume = k:GetAttribute("IndraUltimateOldVolume")

				if typeof(indraUltimateOldVolume) == "number" then
					volume = indraUltimateOldVolume
				end

				TweenService:Create(k, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Volume = volume
				}):Play()
				local v3 = k
				task.delay(0.65, function()
					if v3 and v3.Parent then
						v3:SetAttribute("IndraUltimateMuted", nil)
						v3:SetAttribute("IndraUltimateOldVolume", nil)
					end
				end)
			end
		end)
	end

	local function screenImpact()
		local duration = player.Duration or 2
		pcall(function()
			Effect.new("ShakeCam"):play({
				7,
				30,
				0.15,
				duration
			})
		end)
		local v2 = Lighting:FindFirstChild("IndraGetOutUltimate")

		if not v2 then
			v2 = Instance.new("ColorCorrectionEffect")
			v2.Name = "IndraGetOutUltimate"
			v2.Parent = Lighting
		end

		v2.Enabled = true
		v2.Saturation = 0
		v2.Contrast = 0
		v2.Brightness = 0
		v2.TintColor = Color3.fromRGB(255, 255, 255)
		TweenService:Create(v2, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Saturation = -1,
			Contrast = 0.35,
			Brightness = -0.08
		}):Play()
		task.delay(0.18, function()
			if v2 and v2.Parent then
				TweenService:Create(v2, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Saturation = -1,
					Contrast = 0.75,
					Brightness = -0.85,
					TintColor = Color3.fromRGB(35, 35, 35)
				}):Play()
			end
		end)
		task.delay(duration, function()
			if not (v2 and v2.Parent) then
				return
			end

			local tween = TweenService:Create(
				v2,
				TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Saturation = 0,
					Contrast = 0,
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255)
				}
			)
			tween:Play()
			tween.Completed:Once(function()
				if v2 and v2.Parent then
					v2:Destroy()
				end
			end)
		end)
	end

	local function getOrCreateRoarStartImpact()
		local child = workspace._WorldOrigin:FindFirstChild(name)

		if child then
			return child
		end

		local cframe = CFrame.new(0, 3, 0)
		local cFrame = root.CFrame * cframe
		local clone = ultimate.RoarStartImpact:Clone()
		clone.Name = name
		clone.CFrame = cFrame
		clone.Parent = workspace._WorldOrigin
		clone.Main.Part0 = root
		clone.Main.C0 = cframe
		Util.Debris:AddItem(clone, 8)
		return clone
	end

	if phase == 1 then
		local roarStartImpact = getOrCreateRoarStartImpact()
		local attachment1 = roarStartImpact:FindFirstChild("Attachment1")
		Util.Sound:Play("HydraHiss2", root)

		if attachment1 then
			for _, emitter in pairs(attachment1:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = true
				end
			end
		end

		task.delay(player.Duration or 1, function()
			if not (roarStartImpact and roarStartImpact.Parent) then
				return
			end

			local attachment12 = roarStartImpact:FindFirstChild("Attachment1")

			if attachment12 then
				for _, emitter in pairs(attachment12:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end)
	else
		local duration = player.Duration or 2
		local cframe = CFrame.new(0, 3, 0)
		local cFrame = root.CFrame * cframe
		local roarStartImpact = getOrCreateRoarStartImpact()
		local attachment1 = roarStartImpact:FindFirstChild("Attachment1")
		local attachment2 = roarStartImpact:FindFirstChild("Attachment2")

		if attachment1 then
			for _, emitter in pairs(attachment1:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		-- equivalent call inferred; original call site unknown
		if isLocalPlayerNearRoar() then
			screenImpact()
			muteBackgroundMusic(duration + 0.5, false)
		end

		Util.Sound:Play("Dinosaur Roar", root, nil, 1.4, 1)
		local clone = ultimate.RoarStart:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace._WorldOrigin
		clone.Main.Part0 = root
		clone.Main.C0 = cframe

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		if attachment2 then
			for _, emitter in pairs(attachment2:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end

		local clone2 = ultimate.RoarGround:Clone()
		clone2.CFrame = CFrame.new(cFrame.Position)
		clone2.Parent = workspace._WorldOrigin
		local descendants = clone2:GetDescendants()
		local v3 = false
		task.spawn(function()
			for _, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			local flag = false
			local v4 = false

			while v3 == false and root and root.Parent do
				local v5 = root.CFrame * cframe
				local ray = Util.Ray
				local position = v5.Position
				local v6 = { workspace.Characters, workspace.Enemies }
				local v7, v8, v9 = ray(position, createVector(-0, -20, -0), v6)

				if v7 then
					clone2.CFrame = CFrame.new(v8, v8 + v9) * CFrame.Angles(-1.5707963267948966, 0, 0)

					if not flag then
						flag = true

						for _, emitter in pairs(descendants) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							if v4 == false and emitter:GetAttribute("Color") then
								emitter.Color = ColorSequence.new(v7.Color, v7.Color)
							end

							emitter.Enabled = true
						end

						if not v4 then
							v4 = true
						end
					end
				elseif flag then
					flag = false

					for _, emitter in pairs(descendants) do
						if emitter:IsA("ParticleEmitter") then
							emitter.Enabled = false
						end
					end
				end

				task.wait(0.1)
			end

			for _, emitter in pairs(descendants) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		task.wait(duration)
		v3 = true

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if roarStartImpact and roarStartImpact.Parent then
			for _, emitter in pairs(roarStartImpact:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end

		Util.Debris:AddItem(clone, 3)
		Util.Debris:AddItem(clone2, 3)
	end
end