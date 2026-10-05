local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)
local _ = table.insert
local RunService = game:GetService("RunService")
local _ = table.remove
local _ = table.find
local Oklab = require(utilities.color.Oklab)
local Animator = require(utilities.Animator)
local CollectionService = game:GetService("CollectionService")
return function(instance, p, instance2, instance3, part, callback)
	local attribute = OuwmitUtility.GetAttribute(instance, "Duration", 1)
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(
		instance,
		"EffectDuration",
		NumberRange.new(attribute, attribute),
		NumberRange.new(0, 1e999)
	)
	local durationScale = OuwmitUtility.DurationScale(p)
	local randomNumberInRange = OuwmitUtility.GetRandomNumberInRange(rangeAttribute.Min, rangeAttribute.Max)
	local v = randomNumberInRange * durationScale
	local v2 = OuwmitUtility.GetAttribute(instance, "DestroyDelay", 0) * durationScale
	local v3

	if p == nil then
		v3 = false
	else
		v3 = p.Mesh ~= nil
	end

	if part:IsA("BasePart") then
		part.Anchored = true
	end

	local emitOnFinish = part:FindFirstChild("EmitOnFinish")

	if emitOnFinish ~= nil then
		emitOnFinish.Parent = nil
	end

	local estimateDurationCached = OuwmitUtility.EstimateDurationCached(instance2)
	local emitOnFinish2 = instance2:FindFirstChild("EmitOnFinish")
	local v4 = emitOnFinish2 == nil and 0 or OuwmitUtility.EstimateDurationCached(emitOnFinish2)
	local lastTime = os.clock()
	part.Transparency = (p == nil or not p.Mesh) and 1 or p.Mesh.Transparency or 1
	local v5 = OuwmitUtility.GetAttribute(instance, "MinInitRot") or createVector(0, 0, 0)
	local v6 = OuwmitUtility.GetAttribute(instance, "MaxInitRot") or createVector(0, 0, 0)
	local v7 = vector.create(
		OuwmitUtility.GetRandomNumberInRange(v5.x, v6.x),
		OuwmitUtility.GetRandomNumberInRange(v5.y, v6.y),
		OuwmitUtility.GetRandomNumberInRange(v5.z, v6.z)
	) * OuwmitUtility.DEG_TO_RAD
	local v8 = (OuwmitUtility.GetAttribute(instance, "Flipbook", false) or not instance2:FindFirstChildOfClass("Decal")) and "Mesh_" or "Decal_"
	local startTransparency = instance:GetAttribute("StartTransparency")

	if startTransparency ~= nil then
		instance:SetAttribute(v8 .. "StartTransparency", startTransparency)
		instance:SetAttribute("StartTransparency", nil)
	end

	local endTransparency = instance:GetAttribute("EndTransparency")

	if endTransparency ~= nil then
		instance:SetAttribute(v8 .. "EndTransparency", endTransparency)
		instance:SetAttribute("EndTransparency", nil)
	end

	local attribute2 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
	local attribute3 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function boundTween(p2: string, p3: number, fn, fn2)
		Tween.new(p2, p3, function(p4: number, p5: number)
			if part:IsDescendantOf(game) then
				return fn(p4, p5)
			end

			return p3
		end, fn2)
	end

	local originCFrame = OuwmitUtility.OriginCFrame

	local function fn()
		local transparency = instance2 ~= nil and instance2.Transparency or 0

		if v3 and p.Mesh.Transparency ~= nil then
			transparency = p.Mesh.Transparency
		end

		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance2
		local attribute4 = OuwmitUtility.GetAttribute(instance, "SpreadAngle", createVector(0, 0, 0))
		local attribute5 = OuwmitUtility.GetAttribute(instance, "RotAroundOrigin", false)
		local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(instance, "Part_RotSpeed_Start", NumberRange.new(0, 0))
		local rangeAttribute3 = OuwmitUtility.GetRangeAttribute(instance, "Part_RotSpeed_End", NumberRange.new(0, 0))
		local randomNumberInRange2 = OuwmitUtility.GetRandomNumberInRange(rangeAttribute2.Min, rangeAttribute2.Max)
		local randomNumberInRange3 = OuwmitUtility.GetRandomNumberInRange(rangeAttribute3.Min, rangeAttribute3.Max)
		local attribute6 = OuwmitUtility.GetAttribute(instance, "Flipbook", false)
		local attribute7 = OuwmitUtility.GetAttribute(instance, "FlipbookFadeOffset", 0)
		local attribute8 = OuwmitUtility.GetAttribute(instance, "Decal_StartTransparency", 0, true)
		local attribute9 = OuwmitUtility.GetAttribute(instance, "Decal_EndTransparency", 1, true)
		local v9 = nil

		if v3 and p.Mesh.CFrame ~= nil then
			v9 = originCFrame(attachment):Inverse() * p.Mesh.CFrame
		elseif v3 and p.Mesh.Position ~= nil then
			local cframe = originCFrame(attachment)
			v9 = cframe:Inverse() * CFrame.new(p.Mesh.Position) * cframe.Rotation
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getOrigin()
			if v9 == nil then
				return originCFrame(attachment)
			end

			return originCFrame(attachment) * v9
		end

		local origin = getOrigin() -- equivalent call inferred; original call site unknown
		local v10 = instance3 ~= nil and instance2.CFrame:Inverse() * instance3.CFrame or instance2:GetAttribute("CFrameDiff")
		local lerped = attribute2
		local lerped2 = randomNumberInRange2
		local v11 = false
		local fn2
		local cframe = CFrame.fromOrientation(v7.x, v7.y, v7.z)
		local identity = CFrame.identity
		local cframe2 = CFrame.fromOrientation(
			math.rad((OuwmitUtility.GetRandomNumberInRange(-attribute4.x, attribute4.x))),
			math.rad((OuwmitUtility.GetRandomNumberInRange(-attribute4.y, attribute4.y))),
			0
		)
		local v12

		if v10 == nil then
			v12 = false
		else
			v12 = v10 ~= CFrame.identity
		end

		if v12 then
			local attribute10 = OuwmitUtility.GetAttribute(instance, "Part_CFrame_Curve", OuwmitUtility.default_bezier)

			local function fn3(p2, p3)
				identity = CFrame.identity:Lerp(v10, p2)
				return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
			end

			boundTween(attribute10, v, fn3, nil) -- equivalent call inferred; original call site unknown
		end

		if attribute2 ~= attribute3 and not instance:GetAttribute("SpeedOverride") then
			v11 = true
			local attribute10 = OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier)
			local v13 = OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale

			local function fn3(p2, p3)
				lerped = OuwmitUtility.lerp(attribute2, attribute3, p2)
				return p3
			end

			local function fn4()
				v11 = false
			end

			boundTween(attribute10, v13, fn3, fn4) -- equivalent call inferred; original call site unknown
		end

		local attribute10 = OuwmitUtility.GetAttribute(instance, "Mesh_StartTransparency", transparency)
		local attribute11 = OuwmitUtility.GetAttribute(instance, "Mesh_EndTransparency", transparency)
		local attribute12 = OuwmitUtility.GetAttribute(instance, "Part_Transparency_Start", attribute10)
		local attribute13 = OuwmitUtility.GetAttribute(instance, "Part_Transparency_End", attribute11)

		if attribute12 == attribute13 then
			part.Transparency = attribute12
		else
			local attribute14 = OuwmitUtility.GetAttribute(
				instance,
				"Part_Transparency_Curve",
				OuwmitUtility.default_bezier
			)

			local function fn3(p2, p3)
				part.Transparency = OuwmitUtility.lerp(attribute12, attribute13, p2)
				return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
			end

			boundTween(attribute14, v, fn3, nil) -- equivalent call inferred; original call site unknown
		end

		local scale = v3 and p.Mesh.Scale or 1
		local size = instance3 ~= nil and instance3.Size or instance2:GetAttribute("EndPartSize")

		if size ~= nil then
			local size2 = instance2.Size * scale
			local v14 = size * scale

			if size2 == v14 then
				part.Size = size2
			else
				local attribute14 = OuwmitUtility.GetAttribute(
					instance,
					"Part_Size_Curve",
					OuwmitUtility.default_bezier
				)

				local function fn3(p2, p3)
					part.Size = size2:Lerp(v14, p2)
					return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
				end

				boundTween(attribute14, v, fn3, nil) -- equivalent call inferred; original call site unknown
			end
		end

		local specialMesh = instance2:FindFirstChildOfClass("SpecialMesh")
		local specialMesh2

		if instance3 ~= nil then
			specialMesh2 = instance3:FindFirstChildOfClass("SpecialMesh") or nil
		end

		local specialMesh3 = part:FindFirstChildOfClass("SpecialMesh")

		if specialMesh3 then
			local scale2 = specialMesh2 ~= nil and specialMesh2.Scale or instance2:GetAttribute("EndMeshScale")

			if specialMesh and scale2 then
				local v13 = specialMesh.Scale * scale
				local v14 = scale2 * scale

				if v13 ~= v14 then
					local attribute14 = OuwmitUtility.GetAttribute(
						instance,
						"Mesh_Scale_Curve",
						OuwmitUtility.default_bezier
					)

					local function fn3(p2, p3)
						specialMesh3.Scale = OuwmitUtility.lerp(v13, v14, p2)
						return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
					end

					boundTween(attribute14, v, fn3, nil) -- equivalent call inferred; original call site unknown
				end
			else
				specialMesh3.Parent = nil
				task.delay(v, function()
					if part ~= nil and part.Parent ~= nil then
						specialMesh3.Parent = part
					end
				end)
			end
		end

		if randomNumberInRange2 ~= randomNumberInRange3 then
			local attribute14 = OuwmitUtility.GetAttribute(
				instance,
				"Part_RotSpeed_Curve",
				OuwmitUtility.default_bezier
			)

			local function fn3(p2, p3)
				lerped2 = OuwmitUtility.lerp(randomNumberInRange2, randomNumberInRange3, p2)
				return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
			end

			boundTween(attribute14, v, fn3, nil) -- equivalent call inferred; original call site unknown
		end

		local attribute14 = OuwmitUtility.GetAttribute(instance, "SyncPosition", false)
		local v13 = v12 or randomNumberInRange2 ~= randomNumberInRange3 or randomNumberInRange2 ~= 0 or randomNumberInRange3 ~= 0 or attribute14

		if v13 or cframe2 ~= CFrame.identity or v7 ~= createVector(0, 0, 0) then
			local function updatePos(p2)
				local v14

				if attribute14 then
					if v9 == nil then
						v14 = originCFrame(attachment)
					else
						v14 = originCFrame(attachment) * v9
					end

					if not v14 then
						v14 = origin
					end
				else
					v14 = origin
				end

				local v15 = v7:Sign() * lerped2 * p2
				cframe *= CFrame.fromOrientation(v15.x, v15.y, v15.z)
				local v16

				if attribute5 then
					v16 = v14 * cframe2 * cframe * identity
				else
					v16 = v14 * cframe2 * identity * cframe
				end

				part.CFrame = v16 * cframe
			end

			updatePos(0)

			if v13 then
				fn2 = function(p2)
					if part:IsDescendantOf(game) then
						updatePos(p2)
					else
						Animator.Remove(fn2)
					end
				end

				Animator.Add(fn2)
			end
		end

		lastTime = os.clock()

		for _, child in ipairs(part:GetChildren()) do
			callback(child, p)
		end

		local meshDecals, v14, v15 = OuwmitUtility.GetMeshDecals(instance, part)
		local v16 = 0

		if attribute6 then
			table.sort(meshDecals, function(a, b)
				local v17 = a.Name:match("%d+") or 0
				local v18 = b.Name:match("%d+") or 0
				return tonumber(v17) < tonumber(v18)
			end)
			local decal = Instance.new("Decal")
			decal.Parent = part

			if attribute7 > 0 and attribute8 ~= attribute9 then
				local default_bezier = OuwmitUtility.default_bezier
				local v17 = v + attribute7

				local function fn3(p2, p3)
					decal.Transparency = OuwmitUtility.lerp(attribute8, attribute9, p2)
					return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
				end

				boundTween(default_bezier, v17, fn3, nil) -- equivalent call inferred; original call site unknown
			end

			local default_bezier = OuwmitUtility.default_bezier

			local function fn3(p2, p3)
				local meshDecal = meshDecals[math.max(math.round(#meshDecals * p2), 1)]
				decal.Texture = meshDecal.Texture
				decal.Color3 = meshDecal.Color3
				decal.ZIndex = meshDecal.ZIndex

				if attribute7 == 0 then
					decal.Transparency = OuwmitUtility.lerp(attribute8, attribute9, p2)
					decal.ZIndex = meshDecal.ZIndex
				end

				return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
			end

			boundTween(default_bezier, v, fn3, nil) -- equivalent call inferred; original call site unknown
		else
			for _, meshDecal in meshDecals do
				local v17 = v15[meshDecal]
				local attribute15 = OuwmitUtility.GetAttribute(meshDecal, "Transparency_Start", attribute8)
				local attribute16 = OuwmitUtility.GetAttribute(meshDecal, "Transparency_End", attribute9)

				if attribute15 == attribute16 then
					meshDecal.Transparency = attribute15
				else
					local attribute17 = OuwmitUtility.GetAttribute(
						meshDecal,
						"Transparency_Curve",
						OuwmitUtility.default_bezier
					)
					local v19 = meshDecal
					local transparency2 = attribute15
					local v21 = attribute16

					local function fn3(p2, p3)
						v19.Transparency = OuwmitUtility.lerp(transparency2, v21, p2)
						return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
					end

					boundTween(attribute17, v, fn3, nil) -- equivalent call inferred; original call site unknown
				end

				if meshDecal.Color3 ~= v17.Color3 then
					local attribute17 = OuwmitUtility.GetAttribute(
						meshDecal,
						"Color_Curve",
						OuwmitUtility.default_bezier
					)
					local v19 = meshDecal
					local v20 = v17
					local v21 = meshDecal

					local function fn3(p2, p3)
						local v22 = Oklab.fromSRGB(v19.Color3)
						local v23 = Oklab.fromSRGB(v20.Color3)
						v19.Color3 = Oklab.toSRGB(v22:Lerp(v23, p2), true)
						return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
					end

					boundTween(attribute17, v, fn3, nil) -- equivalent call inferred; original call site unknown
				end

				local v18 = v14[meshDecal]

				if not v18 then
					continue
				end

				local v19 = OuwmitUtility.GetAttribute(meshDecal, "Flipbook_Change_Duration", randomNumberInRange) * durationScale

				if OuwmitUtility.GetAttribute(meshDecal, "SyncDuration", false) then
					v19 = v
				end

				if v16 < v19 then
					v16 = v19
				end

				local v20 = false

				if RunService:IsStudio() then
					for _, v22 in CollectionService:GetTags(meshDecal) do
						if not v22:match("^_local_flipbook_") then
							continue
						end

						v20 = true
						break
					end
				end

				local attribute17 = OuwmitUtility.GetAttribute(
					meshDecal,
					"Flipbook_Change_Curve",
					OuwmitUtility.linear_bezier
				)
				local v21 = v18
				local v22 = meshDecal

				local function fn3(p2, p3)
					v22.Texture = `{v20 and "rbxtemp://" or "rbxassetid://"}{v21[math.max(math.round(#v21 * p2), 1)]}`
					return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
				end

				boundTween(attribute17, v19, fn3, nil) -- equivalent call inferred; original call site unknown
			end
		end

		local v17 = math.max(v, v16) + attribute7 + v2

		-- equivalent calls inferred from this helper; original call sites unknown
		local function destroyObject(value: number?)
			local v18 = math.max(value or 0, estimateDurationCached - (os.clock() - lastTime))

			if v18 > 0 then
				task.delay(v18, part.Destroy, part)
			else
				part:Destroy()
			end
		end

		local flag = false

		local function finish()
			if flag then
				return
			end

			flag = true

			if emitOnFinish ~= nil then
				local children = emitOnFinish:GetChildren()

				if #children > 0 and part.Parent ~= nil then
					for _, v18 in children do
						v18.Parent = part
					end

					callback(children, p)
					local v18 = math.max(
						OuwmitUtility.GetAttribute(instance, "EmitOnFinishLifetime", 0) * durationScale,
						v4
					)
					emitOnFinish:Destroy()
					destroyObject(v18) -- equivalent call inferred; original call site unknown
					return
				else
					emitOnFinish:Destroy()
				end
			end

			destroyObject() -- equivalent call inferred; original call site unknown
		end

		Tween.new(OuwmitUtility.linear_bezier, v17, function(_, p2)
			if not part:IsDescendantOf(game) then
				return v17
			end

			local speedOverride = instance:GetAttribute("SpeedOverride") or lerped

			if speedOverride <= 0 and not v11 then
				return v17
			end

			return p2 * speedOverride
		end, finish)
	end

	local attribute4 = OuwmitUtility.GetAttribute(instance, "EmitDelay")

	if attribute4 == nil then
		fn()
	else
		attribute4 *= durationScale
		task.delay(attribute4, fn)
	end

	local v9 = math.max(math.min(attribute2, attribute3), 0.05)
	local v10 = 0

	for _, decal in ipairs(instance2:GetChildren()) do
		if not decal:IsA("Decal") then
			continue
		end

		local v11 = OuwmitUtility.GetAttribute(decal, "Flipbook_Change_Duration", 0) * durationScale

		if v10 < v11 then
			v10 = v11
		end
	end

	local attribute5 = OuwmitUtility.GetAttribute(instance, "FlipbookFadeOffset", 0)
	local v11 = math.max(OuwmitUtility.GetAttribute(instance, "EmitOnFinishLifetime", 0) * durationScale, v4)
	return
		math.max((math.max(v, v10) + attribute5 + v2) / v9 + v11, estimateDurationCached) + (attribute4 or 0) + 1,
		part
end