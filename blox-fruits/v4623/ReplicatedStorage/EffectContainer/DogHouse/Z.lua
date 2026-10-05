local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return function(player)
	local DISTANCE_THRESHOLD = 0.05
	local character = player.Character

	if not character then
		return
	end

	local phase = player.Phase or 1
	local startCFrame = player.StartCFrame or character:GetPivot()
	local endCFrame = player.EndCFrame or startCFrame
	local lookAt = player.LookAt or player.Center or endCFrame.Position + endCFrame.LookVector
	local count = player.Count or 5
	local duration = player.Duration or 0.45
	local afterimageDuration = player.AfterimageDuration or 0.45
	local color = player.Color or Color3.fromRGB(255, 0, 0)
	local arcHeight = player.ArcHeight or 4
	local curveDepth = player.CurveDepth or 25
	local _ = player.Side or 1
	local root = player.Root
	local center = player.Center

	if root and root.Parent then
		center = root.Position
	end

	if phase == 1 then
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play("PortalDash", startCFrame.Position)
	end

	if phase == 2 and center then
		local position = startCFrame.Position
		local vector2 = Vector3.new(position.X - center.X, 0, position.Z - center.Z)

		if vector2.Magnitude < DISTANCE_THRESHOLD then
			if root and root.Parent then
				vector2 = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
			else
				vector2 = Vector3.new(startCFrame.LookVector.X, 0, startCFrame.LookVector.Z)
			end
		end

		local unit = (vector2.Magnitude < DISTANCE_THRESHOLD and createVector(0, 0, 1) or vector2).Unit
		local endDistance = player.EndDistance or player.BehindDistance or 24
		local sideDistance = player.SideDistance or 36
		local side = player.Side or 1
		local v = center - unit * endDistance + createVector(0, 3, 0)
		local cross = unit:Cross(createVector(0, 1, 0))
		local v2

		if cross.Magnitude < DISTANCE_THRESHOLD then
			v2 = startCFrame.RightVector
		else
			v2 = cross.Unit
		end

		local controlPoint2 = center + v2 * side * sideDistance + createVector(0, 1, 0) * arcHeight
		startCFrame = CFrame.lookAt(position, center)
		endCFrame = CFrame.lookAt(v, center)
		curveDepth = player.CurveDepth or sideDistance
		arcHeight = player.ArcHeight or 5
		player.ControlPoint = controlPoint2
		lookAt = center
	end

	if player.HideOriginal then
		local restoreDelay = player.RestoreDelay or duration + afterimageDuration + 0.05
		local indraAfterImageHideCount = character:GetAttribute("IndraAfterImageHideCount") or 0

		if indraAfterImageHideCount <= 0 then
			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
					descendant:SetAttribute("IndraOldLTM", descendant.LocalTransparencyModifier)
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
					descendant:SetAttribute("IndraOldEnabled", descendant.Enabled)
				elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
					descendant:SetAttribute("IndraOldEnabled", descendant.Enabled)
				end
			end
		end

		character:SetAttribute("IndraAfterImageHideCount", indraAfterImageHideCount + 1)

		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
				descendant.Enabled = false
			elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
				descendant.Enabled = false
			end
		end

		task.delay(restoreDelay, function()
			if not (character and character.Parent) then
				return
			end

			local v = (character:GetAttribute("IndraAfterImageHideCount") or 1) - 1

			if v > 0 then
				character:SetAttribute("IndraAfterImageHideCount", v)
				return
			end

			character:SetAttribute("IndraAfterImageHideCount", nil)

			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" then
					local indraOldLTM = descendant:GetAttribute("IndraOldLTM")
					descendant.LocalTransparencyModifier = indraOldLTM == nil and 0 or indraOldLTM
					descendant:SetAttribute("IndraOldLTM", nil)
				elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
					local indraOldEnabled = descendant:GetAttribute("IndraOldEnabled")
					descendant.Enabled = indraOldEnabled == nil or indraOldEnabled
					descendant:SetAttribute("IndraOldEnabled", nil)
				elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
					local indraOldEnabled = descendant:GetAttribute("IndraOldEnabled")
					descendant.Enabled = indraOldEnabled == nil or indraOldEnabled
					descendant:SetAttribute("IndraOldEnabled", nil)
				end
			end
		end)
	end

	local position = startCFrame.Position
	local position2 = endCFrame.Position
	local v = (position + position2) * 0.5
	local v2 = position2 - position
	local rightVector = startCFrame.RightVector

	if v2.Magnitude > 0.01 then
		local cross = v2.Unit:Cross(createVector(0, 1, 0))

		if cross.Magnitude > 0.01 then
			rightVector = cross.Unit
		else
			rightVector = startCFrame.RightVector
		end
	end

	local controlPoint = player.ControlPoint or v + rightVector * curveDepth + createVector(0, 1, 0) * arcHeight

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bezier(p)
		local v3 = 1 - p
		return position * v3 * v3 + controlPoint * 2 * v3 * p + position2 * p * p
	end

	local pivot = character:GetPivot()
	local v3 = {}

	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
			table.insert(v3, {
				Part = part,
				Offset = pivot:ToObjectSpace(part.CFrame),
				Size = part.Size
			})
		end
	end

	local function createAfterimage(cframe, p)
		local model = Instance.new("Model")
		model.Name = "IndraAfterimage"
		model.Parent = workspace._WorldOrigin

		for _, v4 in ipairs(v3) do
			local part = v4.Part

			if not (part and part.Parent) then
				continue
			end

			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanTouch = false
			clone.CanQuery = false
			clone.CastShadow = false
			clone.Massless = true
			clone.Material = Enum.Material.Neon
			clone.Color = color
			clone.Size = v4.Size
			clone.CFrame = cframe * v4.Offset
			clone.LocalTransparencyModifier = 0
			clone.Transparency = math.clamp(0.15 + p * 0.25, 0, 1)
			clone.Parent = model
			TweenService:Create(
				clone,
				TweenInfo.new(afterimageDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Transparency = 1
				}
			):Play()
		end

		Debris:AddItem(model, afterimageDuration + 0.15)
	end

	for i = 1, count do
		local v4 = count <= 1 and 1 or (i - 1) / (count - 1)
		task.delay(v4 * duration, function()
			if not (character and character.Parent) then
				return
			end

			local v7 = bezier(v4) -- equivalent call inferred; original call site unknown

			if phase == 2 and lookAt then
			end

			createAfterimage(CFrame.lookAt(v7, lookAt), v4)
		end)
	end
end