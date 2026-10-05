local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local FaceAnchor = require(ReplicatedStorage.Modules.FaceAnchor)
local SoulvesterGuardCinematic = require(script.Parent.SoulvesterGuardCinematic)
local success, result = pcall(function()
	return require(ReplicatedStorage.SharedUtils.HapticEffectsController)
end)
local v = success and result or nil

local function makeMask(data, p)
	local maskDisplayModels = ReplicatedStorage:FindFirstChild("MaskDisplayModels")

	if maskDisplayModels then
		if data then
			if type(data.toon) == "string" then
				maskDisplayModels = maskDisplayModels:FindFirstChild(data.toon)
			else
				maskDisplayModels = false
			end
		else
			maskDisplayModels = data
		end
	end

	local parent

	if maskDisplayModels and maskDisplayModels:IsA("BasePart") then
		parent = maskDisplayModels:Clone()
	else
		local v3 = not data and { 200, 200, 200 } or data.color or { 200, 200, 200 }
		parent = Instance.new("Part")
		parent.Size = createVector(1.2, 1.2, 0.1)
		parent.Color = Color3.fromRGB(v3[1], v3[2], v3[3])
		parent.Material = Enum.Material.SmoothPlastic

		if data and type(data.icon) == "string" and data.icon ~= "" then
			local decal = Instance.new("Decal")
			decal.Texture = data.icon
			decal.Face = Enum.NormalId.Front
			decal.Parent = parent
			local clone = decal:Clone()
			clone.Face = Enum.NormalId.Back
			clone.Parent = parent
		end
	end

	parent.Anchored = true
	parent.CanCollide = false
	parent.CanQuery = false
	parent.CanTouch = false
	parent.CastShadow = false

	if p then
		FaceAnchor.fitMask(p, parent)
	end

	return parent
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playTick(mask, playbackSpeed, value)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	sound.Volume = value or 0.35
	sound.PlaybackSpeed = playbackSpeed
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 6
	sound.RollOffMaxDistance = 70
	sound.Parent = mask
	sound:Play()
	Debris:AddItem(sound, 1)
end

local v2 = 0

local function beginFlinch(duration)
	v2 += 1

	if v2 > 1 then
		return
	end

	local v3 = Lighting:FindFirstChild("MaskCeremonyFlinch")

	if not v3 then
		v3 = Instance.new("ColorCorrectionEffect")
		v3.Name = "MaskCeremonyFlinch"
		v3.Parent = Lighting
	end

	v3.Enabled = true
	v3.Saturation = 0
	v3.Contrast = 0
	v3.TintColor = Color3.fromRGB(255, 255, 255)
	TweenService:Create(v3, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Saturation = -0.55,
		Contrast = 0.18,
		TintColor = Color3.fromRGB(196, 178, 255)
	}):Play()
end

local function endFlinch()
	v2 = math.max(v2 - 1, 0)

	if v2 > 0 then
		return
	end

	local maskCeremonyFlinch = Lighting:FindFirstChild("MaskCeremonyFlinch")

	if not maskCeremonyFlinch then
		return
	end

	local tween = TweenService:Create(
		maskCeremonyFlinch,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Saturation = 0,
			Contrast = 0,
			TintColor = Color3.fromRGB(255, 255, 255)
		}
	)
	tween.Completed:Connect(function()
		if v2 == 0 and maskCeremonyFlinch.Parent then
			maskCeremonyFlinch.Enabled = false
		end
	end)
	tween:Play()
end

local function punchCamera()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or SoulvesterGuardCinematic.isActive() then
		return
	end

	local fieldOfView = currentCamera.FieldOfView
	local v3 = os.clock() + 0.32
	TweenService:Create(currentCamera, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		FieldOfView = fieldOfView + 9
	}):Play()
	task.delay(0.1, function()
		if currentCamera.Parent then
			TweenService:Create(currentCamera, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = fieldOfView
			}):Play()
		end
	end)
	pcall(function()
		RunService:UnbindFromRenderStep("MaskCeremonyShake")
	end)
	RunService:BindToRenderStep("MaskCeremonyShake", Enum.RenderPriority.Camera.Value + 1, function()
		local v4 = v3 - os.clock()

		if v4 <= 0 or not currentCamera.Parent then
			pcall(function()
				RunService:UnbindFromRenderStep("MaskCeremonyShake")
			end)
			return
		end

		local v5 = (v4 / 0.32) ^ 2 * 0.55
		currentCamera.CFrame *= CFrame.new((math.random() - 0.5) * v5, (math.random() - 0.5) * v5, 0)
	end)
end

local function isLocalWearer(p)
	local localPlayer = Players.LocalPlayer
	return localPlayer ~= nil and p ~= nil and p.Name == localPlayer.Name
end

local function ringForViewer(p, _)
	return p, true
end

return {
	RenderObject = function(data)
		local mode = data.mode
		local character = data.character

		if not (character and character.Parent) then
			return
		end

		local parent = FaceAnchor.find(character)

		if not parent then
			return
		end

		if mode == "doff" then
			local mask = makeMask(data.winner or {}, parent)
			mask.CFrame = FaceAnchor.maskCFrame(parent, mask)
			mask.Parent = workspace
			playTick(mask, 0.6) -- equivalent call inferred; original call site unknown
			local cFrame = mask.CFrame * CFrame.new(1.5, 3.5, 1) * CFrame.Angles(
				3.490658503988659,
				2.0943951023931953,
				1.2217304763960306
			)
			TweenService:Create(mask, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Transparency = 1
			}):Play()
			Debris:AddItem(mask, 0.8)
		else
			local duration = tonumber(data.duration) or 2.4
			local localPlayer = Players.LocalPlayer
			local v4

			if localPlayer == nil or character == nil then
				v4 = false
			else
				v4 = character.Name == localPlayer.Name
			end

			local decoys = data.decoys or {}
			local decoys2 = { data.winner }
			local v5 = true

			for _, decoy in ipairs(decoys) do
				table.insert(decoys2, decoy)
			end

			local masks = {}

			for _, v6 in ipairs(decoys2) do
				local mask = makeMask(v6, parent)
				mask.Parent = workspace
				Debris:AddItem(mask, duration + 2)
				table.insert(masks, mask)
			end

			local v6 = masks[1]
			local v7 = math.max(parent.Size.X, parent.Size.Y)
			beginFlinch(math.min(duration * 0.5, 1.2))
			local v8 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function releaseFlinch()
				if not v8 then
					v8 = true
					endFlinch()
				end
			end

			local part = Instance.new("Part")
			part.Size = createVector(0.2, 0.2, 0.2)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Parent = workspace
			local pointLight = Instance.new("PointLight")
			pointLight.Color = Color3.fromRGB(190, 140, 255)
			pointLight.Range = 14
			pointLight.Brightness = 0
			pointLight.Parent = part
			local v9 = math.max(duration - 0.65, 0.8)
			local v10 = v7 * 2.6
			local v11 = v7 * 0.9
			local v12 = v7 * 3.4
			local v13 = v7 * 0.8
			local total = 0
			local v14 = 0
			local v15 = 0
			local renderSteppedConnection = nil

			-- equivalent calls inferred from this helper; original call sites unknown
			local function cleanup()
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
				end

				part:Destroy()
			end

			task.delay(duration + 2, function()
				cleanup() -- equivalent call inferred; original call site unknown
				releaseFlinch() -- equivalent call inferred; original call site unknown
			end)
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += dt

				if character.Parent and parent.Parent then
					local v16 = math.min(total / v9, 1)
					local v17 = total * 2.5 + total * 6 * total
					local v18 = v10 + (v11 - v10) * (v16 * v16)
					local v19 = v12 * (1 - v16) + v13 * v16
					local v20 = math.sin(total * 0.9) * 0.12217304763960307
					local v21 = total * 0.25
					local v22 = FaceAnchor.centre(parent) + Vector3.new(0, v19, 0)
					local cframe = CFrame.new(v22) * CFrame.Angles(0, v21, v20)
					local currentCamera = workspace.CurrentCamera
					local position

					if currentCamera then
						position = currentCamera.CFrame.Position
					else
						position = v22
					end

					for i, v23 in ipairs(masks) do
						local v24 = v17 + (i - 1) * (6.283185307179586 / #masks)
						local pointToWorldSpace = cframe:PointToWorldSpace((Vector3.new(
							math.cos(v24) * v18,
							0,
							math.sin(v24) * v18
						)))
						v23.CFrame = CFrame.lookAt(pointToWorldSpace, position) * CFrame.Angles(
							0,
							0,
							math.sin(total * 1.6 + i) * 0.18
						)
						v23.Transparency = math.clamp((math.sin(total * 4 + i * 2.1) * 0.5 + 0.5) * 0.12 + 0.05, 0, 0.5)
					end

					part.CFrame = CFrame.new(v22)
					pointLight.Brightness = (math.sin(total * 11) * 0.5 + 0.5) * 1.4 * v16 + 1.6
					local v23 = 0.22 - v16 * 0.13

					if v5 and v23 <= total - v14 then
						v14 = total
						v15 = v15 % #masks + 1
						local v24 = masks[v15]
						local parent2 = v24.Parent and v24 or parent
						local playbackSpeed = v16 * 0.8 + 0.9
						local sound = Instance.new("Sound")
						sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
						sound.Volume = 0.3
						sound.PlaybackSpeed = playbackSpeed
						sound.RollOffMode = Enum.RollOffMode.InverseTapered
						sound.RollOffMinDistance = 6
						sound.RollOffMaxDistance = 70
						sound.Parent = parent2
						sound:Play()
						Debris:AddItem(sound, 1)
					end

					if v9 <= total then
						cleanup() -- equivalent call inferred; original call site unknown

						for i = 2, #masks do
							local v24 = masks[i]
							local unit = (v24.Position - FaceAnchor.centre(parent)).Unit
							local cFrame = CFrame.new(v24.Position + unit * 11 + createVector(0, 3, 0)) * CFrame.Angles(
								3.141592653589793,
								3.839724354387525,
								2.0943951023931953
							)
							TweenService:Create(
								v24,
								TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									CFrame = cFrame,
									Transparency = 1
								}
							):Play()
							Debris:AddItem(v24, 0.6)
						end

						local objectSpace = FaceAnchor.maskCFrame(parent, v6):ToObjectSpace(v6.CFrame)
						local cframe2 = CFrame.new(0, v7 * 0.6, -v7 * 0.9)
						local total2 = 0
						v6.Transparency = 0
						local renderSteppedConnection2 = nil
						renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt2)
							total2 += dt2

							if not (v6.Parent and parent.Parent) then
								renderSteppedConnection2:Disconnect()
								return
							end

							local v24

							if total2 < 0.22 then
								v24 = objectSpace:Lerp(
									cframe2,
									(TweenService:GetValue(
										total2 / 0.22,
										Enum.EasingStyle.Quad,
										Enum.EasingDirection.Out
									))
								)
							elseif total2 < 0.4 then
								v24 = cframe2
							else
								local value = TweenService:GetValue(
									math.min((total2 - 0.4) / 0.2, 1),
									Enum.EasingStyle.Back,
									Enum.EasingDirection.In
								)
								v24 = cframe2:Lerp(CFrame.identity, value)
							end

							v6.CFrame = FaceAnchor.maskCFrame(parent, v6) * v24
						end)
						task.delay(0.62, function()
							renderSteppedConnection2:Disconnect()

							if parent.Parent then
								local sound = Instance.new("Sound")
								sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
								sound.Volume = 0.5
								sound.PlaybackSpeed = 0.45
								sound.RollOffMode = Enum.RollOffMode.InverseTapered
								sound.RollOffMinDistance = 6
								sound.RollOffMaxDistance = 70
								sound.Parent = parent
								sound:Play()
								Debris:AddItem(sound, 1)
							end

							releaseFlinch() -- equivalent call inferred; original call site unknown

							if v4 then
								punchCamera()

								if v then
									pcall(function()
										v:Play("ImpactPunch")
									end)
								end
							end

							v6:Destroy()
						end)
					end
				else
					cleanup() -- equivalent call inferred; original call site unknown
					releaseFlinch() -- equivalent call inferred; original call site unknown

					for _, v16 in ipairs(masks) do
						v16:Destroy()
					end
				end
			end)
		end
	end
}