local _ = game.Players.LocalPlayer
local assets = script.Assets
local _WorldOrigin = workspace._WorldOrigin
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function DeleteImpactAfterDuration(folder)
	task.spawn(function()
		local v = 0

		for _, emitter in pairs(folder:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				v = math.max(v, emitter.Lifetime.Max)
			end
		end

		task.wait(v)
		folder:Destroy()
	end)
end

local function hueShift(value, p, p2, p3)
	local HSV, v, v2 = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, p2 or v, p3 or v2)
end

return function(player)
	local character = player.Character

	if not character then
		return
	end

	local humanoidRootPart = character.HumanoidRootPart
	local cFrame = humanoidRootPart.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude > 700 or character:FindFirstChild("UpperTorso") and character.UpperTorso.Transparency > 1 then
		return
	end

	local color = player.Color or Color3.new()
	local color2 = player.Color2
	local rainbow = player.Rainbow
	local Z = humanoidRootPart.Size.Z
	Util.Sound:Play("Buso", humanoidRootPart.Position)
	local folder = Instance.new("Folder")
	folder.Parent = _WorldOrigin
	Util.Debris:AddItem(folder, 3)
	local clone = assets.Phase1.StartImpact:Clone()
	clone.CFrame = cFrame

	if Z < 0.95 or Z > 1.05 then
		Util.ResizeModel(clone, Z, cFrame.p)
	end

	clone.Weld.Part0 = humanoidRootPart
	clone.Parent = folder
	local v = 0
	local v2 = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local HSV, v3, v4 = color:ToHSV()
		local keypoints = emitter.Color.Keypoints
		local colorSequenceKeypoints = {}

		for _, keypoint in pairs(keypoints) do
			local v5 = HSV - ({ keypoint.Value:ToHSV() })[1]
			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v5, v3, v4))
			)
		end

		emitter.Color = ColorSequence.new(colorSequenceKeypoints)
		v = math.max(emitter.Lifetime.Max, v)

		if color2 or rainbow then
			table.insert(v2, { emitter, emitter.Lifetime.Max, math.random() })
		end

		local v5 = emitter
		task.defer(function()
			if v5:GetAttribute("EmitDelay") ~= 0 then
				task.wait(v5:GetAttribute("EmitDelay"))
			end

			v5:Emit(v5:GetAttribute("EmitCount"))
		end)
	end

	DeleteImpactAfterDuration(clone) -- equivalent call inferred; original call site unknown

	if color2 or rainbow then
		local lastTime = os.clock()

		if rainbow then
			while os.clock() - lastTime < v do
				for _, v3 in pairs(v2) do
					local v4 = v3[1]
					local v5 = v3[2]

					if v5 < os.clock() - lastTime then
						continue
					end

					local HSV, v6, v7 = Color3.fromHSV(v3[3] * 0.7 + 0.3 * ((os.clock() - lastTime) / v5), 1, 1):ToHSV()
					local keypoints = v4.Color.Keypoints
					local colorSequenceKeypoints = {}

					for _, keypoint in pairs(keypoints) do
						local v8 = HSV - ({ keypoint.Value:ToHSV() })[1]
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v8, v6, v7))
						)
					end

					v4.Color = ColorSequence.new(colorSequenceKeypoints)
					task.wait(0.03333333333333333)
				end
			end
		elseif color2 then
			while os.clock() - lastTime < v do
				for _, v3 in pairs(v2) do
					local v4 = v3[1]
					local v5 = v3[2]

					if v5 < os.clock() - lastTime then
						continue
					end

					local HSV, v6, v7 = color:Lerp(color2, (os.clock() - lastTime) / v5):ToHSV()
					local keypoints = v4.Color.Keypoints
					local colorSequenceKeypoints = {}

					for _, keypoint in pairs(keypoints) do
						local v8 = HSV - ({ keypoint.Value:ToHSV() })[1]
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v8, v6, v7))
						)
					end

					v4.Color = ColorSequence.new(colorSequenceKeypoints)
					task.wait(0.03333333333333333)
				end
			end
		end
	end
end