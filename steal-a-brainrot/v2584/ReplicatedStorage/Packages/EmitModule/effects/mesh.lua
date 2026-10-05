local createVector = vector.create
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local module = require("../mod/tween")
local module2 = require("../mod/utility")
local module3 = require("../mod/color/Oklab")
local module4 = require("../pkg/Promise")
local random = Random.new()
return {
	emit = function(instance, instance2, list, p: number, flag: boolean?)
		local start = instance:FindFirstChild("Start")
		local part = instance:FindFirstChild("End")

		if not start or not part or not start:IsA("BasePart") or not part:IsA("BasePart") or instance:GetAttribute("Enabled") and not flag then
			return
		end

		local attribute = module2.getAttribute(instance, "Duration", 1, true)
		local rangeAttribute = module2.getRangeAttribute(
			instance,
			"EffectDuration",
			NumberRange.new(attribute, attribute),
			NumberRange.new(0, 1e999)
		)
		local number = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
		local attribute2 = module2.getAttribute(instance, "EmitDelay", 0)
		local attribute3 = module2.getAttribute(instance, "EmitDuration", 0, true)
		local attribute4 = module2.getAttribute(instance, "Flipbook", false, true)
		local attribute5 = module2.getAttribute(instance, "FlipbookFadeOffset", 0, true)
		local v = (attribute4 or not start:FindFirstChildOfClass("Decal")) and "Mesh_" or "Decal_"
		local startTransparency = instance:GetAttribute("StartTransparency")

		if startTransparency ~= nil then
			instance:SetAttribute(v .. "StartTransparency", startTransparency)
			instance:SetAttribute("StartTransparency", nil)
		end

		local endTransparency = instance:GetAttribute("EndTransparency")

		if endTransparency ~= nil then
			instance:SetAttribute(v .. "EndTransparency", endTransparency)
			instance:SetAttribute("EndTransparency", nil)
		end

		local v2

		if instance:GetAttribute("Enabled") == nil then
			v2 = false
		else
			v2 = instance:HasTag(module2.ENABLED_VFX_TAG) and number > 0
		end

		local attribute6 = module2.getAttribute(instance, "Decal_StartTransparency", 0, true)
		local attribute7 = module2.getAttribute(instance, "Decal_EndTransparency", 1, true)
		local v3 = start and start:FindFirstChildOfClass("Decal") and 1 or 0
		local attribute8 = module2.getAttribute(instance, "Mesh_StartTransparency", v3, true)
		local attribute9 = module2.getAttribute(instance, "Mesh_EndTransparency", v3, true)
		local attribute10 = module2.getAttribute(instance, "SyncPosition", false)
		local attribute11 = module2.getAttribute(instance, "Speed_Start", 1)
		local attribute12 = module2.getAttribute(instance, "Speed_End", 1)
		local attribute13 = module2.getAttribute(instance, "Part_Transparency_Start", attribute8)
		local attribute14 = module2.getAttribute(instance, "Part_Transparency_End", attribute9)
		local attribute15 = module2.getAttribute(instance, "SpreadAngle", createVector(0, 0, 0))
		local rangeAttribute2 = module2.getRangeAttribute(instance, "Part_RotSpeed_Start", NumberRange.new(0, 0))
		local rangeAttribute3 = module2.getRangeAttribute(instance, "Part_RotSpeed_End", NumberRange.new(0, 0))
		local attribute16 = module2.getAttribute(instance, "RotAroundOrigin", false)
		local attribute17 = module2.getAttribute(instance, "MinInitRot", createVector(0, 0, 0))
		local attribute18 = module2.getAttribute(instance, "MaxInitRot", createVector(0, 0, 0))
		local number2 = random:NextNumber(rangeAttribute2.Min, rangeAttribute2.Max)
		local number3 = random:NextNumber(rangeAttribute3.Min, rangeAttribute3.Max)
		local v4 = vector.create(
			random:NextNumber(attribute17.x, attribute18.x),
			random:NextNumber(attribute17.y, attribute18.y),
			random:NextNumber(attribute17.z, attribute18.z)
		) * module2.DEG_TO_RAD
		task.wait(attribute2)

		if v2 and not flag then
			instance:SetAttribute("Enabled", true)

			if attribute11 ~= attribute12 then
				instance:SetAttribute("SpeedTweening", true)
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Speed_Curve", module2.default_bezier),
						module2.getAttribute(instance, "Speed_Duration", 0.1),
						function(p2, p3)
							instance:SetAttribute("SpeedOverride", module2.lerp(attribute11, attribute12, p2))
							return p3
						end,
						nil,
						function()
							instance:SetAttribute("SpeedTweening", nil)
						end
					)
				)
			end

			task.wait(attribute3)
			instance:SetAttribute("Enabled", false)
			instance:SetAttribute("SpeedOverride", nil)
		else
			local attachment = instance:FindFirstAncestorOfClass("Attachment") or start
			local parent

			if typeof(instance2) == "table" then
				parent = instance2._getReal() or instance2
			else
				parent = instance2
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function getOrigin()
				return attachment:IsA("Attachment") and attachment.WorldCFrame or attachment.CFrame
			end

			local origin = getOrigin() -- equivalent call inferred; original call site unknown
			local objectSpace = start.CFrame:ToObjectSpace(part.CFrame)
			local lerped = attribute11
			local lerped2 = number2
			local cframe = CFrame.fromOrientation(v4.x, v4.y, v4.z)
			local identity = CFrame.identity
			local cframe2 = CFrame.fromOrientation(
				math.rad((random:NextNumber(-attribute15.x, attribute15.x))),
				math.rad((random:NextNumber(-attribute15.y, attribute15.y))),
				0
			)

			local function updatePos(p2: number)
				local worldCFrame = attribute10 and getOrigin() or origin
				local v6 = v4:Sign() * lerped2 * p2
				cframe *= CFrame.fromOrientation(v6.x, v6.y, v6.z)
				local v7

				if attribute16 then
					v7 = worldCFrame * cframe2 * cframe * identity
				else
					v7 = worldCFrame * cframe2 * identity * cframe
				end

				instance2.CFrame = v7 * cframe
			end

			updatePos(0)
			local ranomId = module2.getRanomId()
			RunService:BindToRenderStep(ranomId, module2.RENDER_PRIORITY + list.depth, updatePos)
			table.insert(list, function()
				RunService:UnbindFromRenderStep(ranomId)
			end)
			local finisheds = {}
			local emitOnFinish = instance2:FindFirstChild("EmitOnFinish")

			if emitOnFinish then
				emitOnFinish.Parent = nil
				table.insert(list, emitOnFinish)
			end

			if shared.vfx and #instance2:GetChildren() ~= 0 then
				table.insert(finisheds, shared.vfx.emit(instance2).Finished)
			end

			local v6

			if attribute11 == attribute12 or instance:GetAttribute("SpeedOverride") then
				v6 = nil
			else
				v6 = module.fromParams(
					module2.getAttribute(instance, "Speed_Curve", module2.default_bezier),
					module2.getAttribute(instance, "Speed_Duration", 0.1),
					function(p2, p3)
						lerped = module2.lerp(attribute11, attribute12, p2)
						return p3
					end
				)
				table.insert(list, v6)
			end

			if objectSpace ~= CFrame.identity then
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Part_CFrame_Curve", module2.default_bezier),
						number,
						function(p2, p3)
							identity = CFrame.identity:Lerp(objectSpace, p2)
							return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
						end,
						v6
					)
				)
			end

			if number2 ~= number3 then
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Part_RotSpeed_Curve", module2.default_bezier),
						number,
						function(p2, p3)
							lerped2 = module2.lerp(number2, number3, p2)
							return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
						end,
						v6
					)
				)
			end

			if attribute13 == attribute14 then
				instance2.Transparency = attribute13
			else
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Part_Transparency_Curve", module2.default_bezier),
						number,
						function(p2, p3)
							instance2.Transparency = module2.lerp(attribute13, attribute14, p2)
							return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
						end,
						v6
					)
				)
			end

			local size = start.Size * p
			local v8 = part.Size * p

			if size == v8 then
				instance2.Size = size
			else
				table.insert(
					list,
					module.fromParams(
						module2.getAttribute(instance, "Part_Size_Curve", module2.default_bezier),
						number,
						function(p2, p3)
							instance2.Size = size:Lerp(v8, p2)
							return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
						end,
						v6
					)
				)
			end

			local specialMesh = start:FindFirstChildOfClass("SpecialMesh")
			local specialMesh2 = part:FindFirstChildOfClass("SpecialMesh")
			local specialMesh3 = instance2:FindFirstChildOfClass("SpecialMesh")

			if specialMesh3 then
				if specialMesh and specialMesh2 then
					local v9 = specialMesh.Scale * p
					local v10 = specialMesh2.Scale * p

					if v9 ~= v10 then
						table.insert(
							list,
							module.fromParams(
								module2.getAttribute(instance, "Mesh_Scale_Curve", module2.default_bezier),
								number,
								function(p2, p3)
									specialMesh3.Scale = module2.lerp(v9, v10, p2)
									return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
								end,
								v6
							)
						)
					end
				else
					specialMesh3.Parent = nil
					table.insert(list, function()
						specialMesh3.Parent = parent
					end)
				end
			end

			local meshDecals, v9, v10 = module2.getMeshDecals(instance, instance2)
			local v11 = 0

			if attribute4 then
				table.sort(meshDecals, function(a, b)
					local v12 = a.Name:match("%d+") or 0
					local v13 = b.Name:match("%d+") or 0
					return tonumber(v12) < tonumber(v13)
				end)
				local decal = Instance.new("Decal")
				decal.Parent = parent
				table.insert(list, decal)

				if attribute5 > 0 and attribute6 ~= attribute7 then
					table.insert(list, module.fromParams(module2.default_bezier, number + attribute5, function(p2, p3)
						decal.Transparency = module2.lerp(attribute6, attribute7, p2)
						return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
					end, v6))
				end

				table.insert(list, module.fromParams(module2.default_bezier, number, function(p2, p3)
					local meshDecal = meshDecals[math.max(math.round(#meshDecals * p2), 1)]
					decal.Texture = meshDecal.Texture
					decal.Color3 = meshDecal.Color3
					decal.ZIndex = meshDecal.ZIndex

					if attribute5 == 0 then
						decal.Transparency = module2.lerp(attribute6, attribute7, p2)
						decal.ZIndex = meshDecal.ZIndex
					end

					return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
				end, v6))
			else
				for _, meshDecal in meshDecals do
					local v12 = v10[meshDecal]
					local attribute19 = module2.getAttribute(meshDecal, "Transparency_Start", attribute6)
					local attribute20 = module2.getAttribute(meshDecal, "Transparency_End", attribute7)

					if attribute19 == attribute20 then
						meshDecal.Transparency = attribute19
					else
						local v13 = meshDecal
						local transparency = attribute19
						local v15 = attribute20
						table.insert(
							list,
							module.fromParams(
								module2.getAttribute(meshDecal, "Transparency_Curve", module2.default_bezier),
								number,
								function(p2, p3)
									v13.Transparency = module2.lerp(transparency, v15, p2)
									return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
								end,
								v6
							)
						)
					end

					if meshDecal.Color3 ~= v12.Color3 then
						local v13 = meshDecal
						local v14 = v12
						local v15 = meshDecal
						table.insert(
							list,
							module.fromParams(
								module2.getAttribute(meshDecal, "Color_Curve", module2.default_bezier),
								number,
								function(p2, p3)
									local v16 = module3.fromSRGB(v13.Color3)
									local v17 = module3.fromSRGB(v14.Color3)
									v13.Color3 = module3.toSRGB(v16:Lerp(v17, p2), true)
									return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
								end,
								v6
							)
						)
					end

					local v13 = v9[meshDecal]

					if not v13 then
						continue
					end

					local attribute21 = module2.getAttribute(meshDecal, "Flipbook_Change_Duration", number)

					if module2.getAttribute(meshDecal, "SyncDuration", false) then
						attribute21 = number
					end

					if v11 < attribute21 then
						v11 = attribute21
					end

					local v14 = false

					if RunService:IsStudio() then
						for _, v16 in CollectionService:GetTags(meshDecal) do
							if not v16:match("^_local_flipbook_") then
								continue
							end

							v14 = true
							break
						end
					end

					local v15 = v13
					local v16 = meshDecal
					table.insert(
						list,
						module.fromParams(
							module2.getAttribute(meshDecal, "Flipbook_Change_Curve", module2.linear_bezier),
							attribute21,
							function(p2, p3)
								v16.Texture = `{v14 and "rbxtemp://" or "rbxassetid://"}{v15[math.max(math.round(#v15 * p2), 1)]}`
								return p3 * (instance:GetAttribute("SpeedOverride") or lerped)
							end,
							v6
						)
					)
				end
			end

			module.timer(math.max(number, v11) + attribute5, function(p2, p3)
				local speedOverride = instance:GetAttribute("SpeedOverride") or lerped
				lerped = speedOverride

				if speedOverride > 0 then
					return p2 * speedOverride
				end

				if p3 > 0 then
					local v12

					if v6 then
						v12 = v6.Connected
					else
						v12 = instance:GetAttribute("SpeedTweening")
					end

					if v12 then
						return p2 * speedOverride
					end
				end

				return nil
			end, v6, list)
			module4.all(finisheds):await()
			local children = emitOnFinish and emitOnFinish:GetChildren()

			if children and #children ~= 0 then
				for _, v12 in children do
					v12.Parent = parent
				end

				shared.vfx.emit(table.unpack(children)).Finished:await()
			end
		end
	end
}