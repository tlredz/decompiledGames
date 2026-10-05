local createVector = vector.create
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local FX = require(game.ReplicatedStorage:WaitForChild("FX"))
local auraAssets = FX:WaitForChild("AuraAssets")

local function hueShift(value: Color3, p: number, p2: number, p3: number)
	local HSV, v, v2 = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, p2 or v, p3 or v2)
end

local function scaleParticle(effect, p: number)
	local keypoints = effect.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	effect.Size = NumberSequence.new(numberSequenceKeypoints)
	effect.Speed = NumberRange.new(effect.Speed.Min * p, effect.Speed.Max * p)
	effect.Acceleration *= p
end

local function getBoundingBox(items, cframe: CFrame?)
	local rotation

	if cframe then
		rotation = cframe.Rotation
	else
		rotation = CFrame.identity
	end

	assert(rotation, "bad orientation")
	local v = 1e999
	local v2 = 1e999
	local v3 = 1e999
	local v4 = -1e999
	local v5 = -1e999
	local v6 = -1e999

	local function adjust(item)
		local size = item.Size
		local X = size.X
		local Y = size.Y
		local Z = size.Z
		local components, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17 = rotation:ToObjectSpace(item.CFrame):GetComponents()
		local v18 = (math.abs(v9) * X + math.abs(v10) * Y + math.abs(v11) * Z) * 0.5
		local v19 = (math.abs(v12) * X + math.abs(v13) * Y + math.abs(v14) * Z) * 0.5
		local v20 = (math.abs(v15) * X + math.abs(v16) * Y + math.abs(v17) * Z) * 0.5
		local v21 = v
		local v22

		if components - v18 < v21 then
			v22 = components - v18
		else
			v22 = v
		end

		v = v22
		local v23 = v2
		local v24

		if v7 - v19 < v23 then
			v24 = v7 - v19
		else
			v24 = v2
		end

		v2 = v24
		local v25 = v3
		local v26

		if v8 - v20 < v25 then
			v26 = v8 - v20
		else
			v26 = v3
		end

		v3 = v26
		local v27

		if v4 < components + v18 then
			v27 = components + v18
		else
			v27 = v4
		end

		v4 = v27
		local v28

		if v5 < v7 + v19 then
			v28 = v7 + v19
		else
			v28 = v5
		end

		v5 = v28
		local v29

		if v6 < v8 + v20 then
			v29 = v8 + v20
		else
			v29 = v6
		end

		v6 = v29
	end

	for _, item in pairs(items) do
		adjust(item)
	end

	local vector2 = Vector3.new(v, v2, v3)
	local vector3 = Vector3.new(v4, v5, v6)
	return rotation + rotation:PointToWorldSpace((vector3 + vector2) * 0.5), vector3 - vector2
end

local function getHandleTrueOrientation(part)
	local attachment0 = part:FindFirstChild("Attachment0")
	local attachment1 = part:FindFirstChild("Attachment1")

	if not (attachment0 and attachment1) then
		return part.CFrame
	end

	local v = attachment1.Position - attachment0.Position
	local vector2 = Vector3.new(math.abs(v.X), math.abs(v.Y), (math.abs(v.Z)))
	local v2 = {
		X = { Enum.NormalId.Right, Enum.NormalId.Left },
		Y = { Enum.NormalId.Top, Enum.NormalId.Bottom },
		Z = { Enum.NormalId.Back, Enum.NormalId.Front }
	}
	local v3 = math.max(vector2.X, vector2.Y, vector2.Z)
	local X = nil

	if vector2.X == v3 then
		X = v2.X
	elseif vector2.Y == v3 then
		X = v2.Y
	elseif vector2.Z == v3 then
		X = v2.Z
	end

	local unit = v.Unit
	local v4 = -2
	local v5 = nil

	for _, v6 in ipairs(X) do
		local dot = (attachment1.WorldPosition - attachment0.WorldPosition).Unit:Dot(unit)

		if not (v4 < dot) then
			continue
		end

		v5 = v6
		v4 = dot
	end

	local vector3 = Vector3.FromNormalId(v5)
	return CFrame.new(part.Position, part.CFrame * vector3) * CFrame.Angles(-1.5707963267948966, 0, 0)
end

local function auraify(folder, childName, color, _, _, p)
	local descendants = {}
	local v = {}
	local result = {}
	local v2 = nil

	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant.Name ~= "Hidden" and (not descendant.Parent or descendant.Parent.Name ~= "Hidden") and (not descendant.Parent or not descendant.Parent.Parent or descendant.Parent.Parent.Name ~= "Hidden")) then
			continue
		end

		if descendant.Name == "Handle" and descendant:IsA("BasePart") and descendant:FindFirstChild("Attachment0") then
			v2 = descendant
		elseif descendant:IsA("BasePart") and descendant.Transparency < 1 then
			table.insert(descendants, descendant)

			if descendant.Material == Enum.Material.Neon then
				local v3 = descendant
				local color2 = descendant.Color
				table.insert(v, function()
					v3.Color = color2
				end)

				if color then
					descendant.Color = color
				end

				local v5 = descendant
				table.insert(result, function(color3: Color3)
					v5.Color = color3
				end)
			end
		elseif descendant:IsA("Trail") then
			local color2 = descendant.Color
			local v3 = descendant
			local brightness = descendant.Brightness
			local transparency = descendant.Transparency
			local textureLength = descendant.TextureLength
			local lightEmission = descendant.LightEmission
			table.insert(v, function()
				v3.Color = color2
				v3.Texture = ""
				v3.Brightness = brightness
				v3.Transparency = transparency
				v3.TextureLength = textureLength
				v3.LightEmission = lightEmission
			end)
			descendant.LightEmission = 0
			descendant.TextureLength = 0.35
			descendant.Transparency = NumberSequence.new(0, 1)
			descendant.Brightness = descendant.Name == "TrailTop" and 0 or 5
			descendant.Texture = "rbxassetid://18771266258"

			if color then
				local HSV, v9, v10 = color:ToHSV()
				local keypoints = descendant.Color.Keypoints
				local colorSequenceKeypoints = {}

				for _, keypoint in pairs(keypoints) do
					local v11 = HSV - ({ keypoint.Value:ToHSV() })[1]
					table.insert(
						colorSequenceKeypoints,
						ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v11, v9, v10))
					)
				end

				descendant.Color = ColorSequence.new(colorSequenceKeypoints)
				local v11 = descendant
				local color3 = color2
				table.insert(v, function()
					v11.Color = color3
				end)
			end

			local v9 = descendant
			table.insert(result, function(p2)
				local HSV, v10, v11 = p2:ToHSV()
				local keypoints = v9.Color.Keypoints
				local colorSequenceKeypoints = {}

				for k, keypoint in pairs(keypoints) do
					local v12 = HSV - ({ keypoint.Value:ToHSV() })[1]
					table.insert(
						colorSequenceKeypoints,
						ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v12, v10, v11))
					)
				end

				v9.Color = ColorSequence.new(colorSequenceKeypoints)
			end)
		end
	end

	local v3 = nil

	local function createHl(outlineColor: Color3)
		local highlight = Instance.new("Highlight")
		highlight.Name = "AuraHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = outlineColor:Lerp(Color3.new(), 0.9)
		highlight.FillTransparency = 1
		highlight.OutlineColor = outlineColor
		highlight.OutlineTransparency = 1
		task.defer(function()
			highlight.Adornee = folder.Parent
			highlight.Parent = folder.Parent
		end)
		TweenService:Create(highlight, TweenInfo.new(0.5), {
			FillTransparency = 0.2,
			OutlineTransparency = 0.3
		}):Play()
		return highlight
	end

	if not (folder.Parent and folder.Parent:FindFirstChild("AuraHighlight")) then
		if color then
			v3 = createHl(color)
		end

		table.insert(result, function(outlineColor)
			if not v3 then
				v3 = createHl(outlineColor)
			end

			v3.FillColor = outlineColor:Lerp(Color3.new(), 0.9)
			v3.OutlineColor = outlineColor
		end)
	end

	local function setupAuraPart(p2: string)
		local part = v2 or folder:FindFirstChild("Handle", true)

		if part then
			local v4 = folder:GetAttribute("WeaponType") == "Gun"
			local v5 = {
				Ignore = true,
				BladeAura = true,
				HandleAura = true,
				FullAura = true,
				DESTROYING = true
			}
			local v6 = nil
			local v7 = false
			local v8

			if p2 == "Blade" then
				v6 = not v4 and {
					Blade = true
				} or v6
				v8 = createVector(0.879, 7.244, 0.23)
			elseif p2 == "Handle" then
				v5.Blade = true
				v8 = createVector(1.485, 3.692, 0.45)
			else
				v8 = createVector(1.485, 9.395, 0.45)
			end

			local v9 = {}

			for _, v10 in descendants do
				if v10:HasTag("Ignore") then
					continue
				end

				if v6 then
					if v6[v10.Name] then
						table.insert(v9, v10)
						v7 = true
					else
						for tag in v6 do
							if not CollectionService:HasTag(v10, tag) then
								continue
							end

							table.insert(v9, v10)
							v7 = true
							break
						end
					end
				elseif not (v5[v10.Name] or v5.Blade and CollectionService:HasTag(v10, "Blade")) then
					table.insert(v9, v10)
				end
			end

			if v6 and not v7 or #v9 == 0 then
				return
			end

			local boundingBox, size = getBoundingBox(v9, getHandleTrueOrientation(part))
			local child = auraAssets:FindFirstChild(childName)
			assert(child, (`bad aura asset "{childName}"`))
			local child2 = child:FindFirstChild(p2 .. "Aura")
			assert(child2, (`bad template at "{p2 .. "Aura"}"`))
			local clone = child2:Clone()
			clone.CFrame = boundingBox
			clone.Size = size
			local start = clone:FindFirstChild("Start")
			assert(start, "bad attachment")
			start.WorldPosition = clone.CFrame * Vector3.new(0, -clone.Size.Y / 2, 0)
			local firstChild = clone:FindFirstChild("End")
			assert(firstChild, "bad attachment")
			firstChild.WorldPosition = clone.CFrame * Vector3.new(0, clone.Size.Y / 2, 0)
			local v11 = { size.X, size.Y, size.Z }
			table.sort(v11)
			local v12 = { v8.X, v8.Y, v8.Z }
			table.sort(v12)
			local v13 = size.Magnitude / v8.Magnitude
			local v14 = v11[2] / v12[2]
			local v15 = v11[3] / v12[3]
			local v16 = v4 and 0.6666666666666666 or 1

			for _, effect in pairs(clone:GetDescendants()) do
				if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam")) then
					continue
				end

				if color then
					local HSV, v17, v18 = color:ToHSV()
					local keypoints = effect.Color.Keypoints
					local colorSequenceKeypoints = {}

					for _, keypoint in pairs(keypoints) do
						local v19 = HSV - ({ keypoint.Value:ToHSV() })[1]
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v19, v17, v18))
						)
					end

					if effect:IsA("ParticleEmitter") then
						effect.Color = ColorSequence.new(colorSequenceKeypoints)
					elseif effect:IsA("Beam") then
						effect.Color = ColorSequence.new(colorSequenceKeypoints)
					end
				end

				local effect2 = effect
				table.insert(result, function(p3)
					local HSV, v17, v18 = p3:ToHSV()
					local keypoints = effect2.Color.Keypoints
					local colorSequenceKeypoints = {}

					for k, keypoint in pairs(keypoints) do
						local v19 = HSV - ({ keypoint.Value:ToHSV() })[1]
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, v19, v17, v18))
						)
					end

					if effect2:IsA("ParticleEmitter") then
						effect2.Color = ColorSequence.new(colorSequenceKeypoints)
					elseif effect2:IsA("Beam") then
						effect2.Color = ColorSequence.new(colorSequenceKeypoints)
					end
				end)

				if effect:IsA("ParticleEmitter") then
					effect.Rate *= math.min(1, v15 * 0.5 + 0.5) * v16
					scaleParticle(effect, math.min(1, v14 * 0.7 + v13 * 0.3) * v16)
				elseif effect:IsA("Beam") then
					effect.ZOffset += math.sign(effect.ZOffset) * 0.1
					local width = effect.Width0 * math.min(1, v14 * 0.7 + v13 * 0.3)
					local width2 = effect.Width1 * math.min(1, v14 * 0.7 + v13 * 0.3)
					effect.Width0 = 0
					effect.Width1 = 0
					TweenService:Create(effect, TweenInfo.new(0.5), {
						Width0 = width,
						Width1 = width2
					}):Play()
				end
			end

			clone.Anchored = false
			clone.CanQuery = false
			clone.CanCollide = false
			clone.Massless = true
			local weldConstraint = Instance.new("WeldConstraint")

			if part and part:IsA("BasePart") then
				weldConstraint.Part0 = part
			end

			if clone and clone:IsA("BasePart") then
				weldConstraint.Part1 = clone
			end

			weldConstraint.Parent = clone
			clone.Parent = folder
			return clone
		else
			local Global = require(game.ReplicatedStorage.Global)
			Global.TestGamePrint("Handle not found!", p2)
		end
	end

	local v4 = {}

	if not p then
		for _, v5 in pairs({ setupAuraPart("Blade"), setupAuraPart("Handle"), setupAuraPart("Full") }) do
			if v5 then
				table.insert(v4, v5)
			end
		end
	end

	return function()
		for _, v5 in pairs(v) do
			v5()
		end

		if v3 then
			v3.Name = "DESTROYING"
			local tween = TweenService:Create(v3, TweenInfo.new(0.5), {
				FillTransparency = 1,
				OutlineTransparency = 1
			})
			tween.Completed:Once(function()
				v3:Destroy()
			end)
			tween:Play()
		end

		for _, folder2 in pairs(v4) do
			folder2.Name = "DESTROYING"

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					local tween = TweenService:Create(effect, TweenInfo.new(0.5), {
						Width0 = 0,
						Width1 = 0
					})
					local v5 = effect
					tween.Completed:Once(function()
						v5.Enabled = false
					end)
					tween:Play()
				end
			end

			local v5 = folder2
			task.delay(1.25, function()
				v5:Destroy()
			end)
		end

		result = nil
	end, result
end

local function auraifyGroup(parent, color, value, p2)
	local v = value or "Base"
	local v2, v3

	if color then
		local v4
		v4, v2, v3 = color:ToHSV()
	end

	local folders = {}
	local v4 = {}

	for _, folder in pairs(parent:GetChildren()) do
		if folder:IsA("Folder") then
			table.insert(folders, folder)
		end
	end

	local v5 = {}

	for _, v6 in pairs(folders) do
		local v7, v8 = auraify(v6, v, color, v2, v3, p2)

		if v7 then
			table.insert(v4, v7)
		end

		if v8 then
			table.insert(v5, v8)
		end
	end

	local color3Value = Instance.new("Color3Value")
	color3Value.Name = "RecolorValue"
	color3Value.Parent = parent
	color3Value:GetPropertyChangedSignal("Value"):Connect(function()
		local value2 = color3Value.Value

		for _, v6 in pairs(v5) do
			for _, v7 in pairs(v6) do
				v7(value2)
			end
		end
	end)
	color3Value.AncestryChanged:Connect(function(_, parent2)
		if parent2 == nil then
			color3Value:Destroy()
		end
	end)
	return function()
		for _, v6 in pairs(v4) do
			v6()
		end

		color3Value:Destroy()
	end, color3Value
end

return auraifyGroup