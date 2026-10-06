local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../mod/common/flipbook")
local module5 = require("../mod/color/Oklab")
local module6 = require("../pkg/Promise")
local random = Random.new()
return {
	emit = function(instance, instance2, list, p: number, flag: boolean?)
		local start = instance:FindFirstChild("Start")
		local part = instance:FindFirstChild("End")

		if not start or not part or not start:IsA("BasePart") or not part:IsA("BasePart") or module.get(
			instance,
			"Enabled",
			false
		) and not flag then
			return
		end

		local duration = module.get(instance, "Duration", 1, true)
		local range = module.getRange(
			instance,
			"EffectDuration",
			NumberRange.new(duration, duration),
			NumberRange.new(0, 1e999)
		)
		local number = random:NextNumber(range.Min, range.Max)
		local emitDelay = module.get(instance, "EmitDelay", 0)
		local destroyDelay = module.get(instance, "DestroyDelay", 0)
		local emitDuration = module.get(instance, "EmitDuration", 0)
		local flipbook = module.get(instance, "Flipbook", false, true)
		local flipbookFadeOffset = module.get(instance, "FlipbookFadeOffset", 0, true)
		local v = (flipbook or not start:FindFirstChildOfClass("Decal")) and "Mesh_" or "Decal_"
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

		local v2 = instance:HasTag(module3.ENABLED_VFX_TAG) and emitDuration > 0
		local decalStartTransparency = module.get(instance, "Decal_StartTransparency", 0, true)
		local decalEndTransparency = module.get(instance, "Decal_EndTransparency", 1, true)
		local v3 = start and start:FindFirstChildOfClass("Decal") and 1 or 0
		local meshStartTransparency = module.get(instance, "Mesh_StartTransparency", v3, true)
		local meshEndTransparency = module.get(instance, "Mesh_EndTransparency", v3, true)
		local syncPosition = module.get(instance, "SyncPosition", false)
		local speedStart = module.get(instance, "Speed_Start", 1)
		local speedEnd = module.get(instance, "Speed_End", 1)
		local partTransparencyStart = module.get(instance, "Part_Transparency_Start", meshStartTransparency)
		local partTransparencyEnd = module.get(instance, "Part_Transparency_End", meshEndTransparency)
		local spreadAngle = module.get(instance, "SpreadAngle", createVector(0, 0, 0))
		local range2 = module.getRange(instance, "Part_RotSpeed_Start", NumberRange.new(0, 0))
		local range3 = module.getRange(instance, "Part_RotSpeed_End", NumberRange.new(0, 0))
		local rotAroundOrigin = module.get(instance, "RotAroundOrigin", false)
		local minInitRot = module.get(instance, "MinInitRot", createVector(0, 0, 0))
		local maxInitRot = module.get(instance, "MaxInitRot", createVector(0, 0, 0))
		local number2 = random:NextNumber(range2.Min, range2.Max)
		local number3 = random:NextNumber(range3.Min, range3.Max)
		local v4 = vector.create(
			random:NextNumber(minInitRot.x, maxInitRot.x),
			random:NextNumber(minInitRot.y, maxInitRot.y),
			random:NextNumber(minInitRot.z, maxInitRot.z)
		) * module3.DEG_TO_RAD
		task.wait(emitDelay)

		if v2 and not flag then
			module3.forceEmit(instance, true)
			module.trigger(instance, "Enabled", true)
			module3.onCancel(list, function()
				local v5 = module3.stopEmitDuration(instance)

				if v5 then
					module3.cancelToken(v5)
				end
			end)

			if speedStart ~= speedEnd then
				module.setState(instance, "SpeedTweening", true)
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Speed_Curve", module3.default_bezier),
						module.get(instance, "Speed_Duration", 0.1),
						function(p2, p3)
							module.setState(instance, "SpeedOverride", module3.lerp(speedStart, speedEnd, p2))
							return p3
						end,
						nil,
						function()
							module.setState(instance, "SpeedTweening", nil)
						end
					)
				)
			end

			task.wait(emitDuration)
			module3.awaitEmitDuration(module3.stopEmitDuration(instance))
		else
			local attachment = instance:FindFirstAncestorOfClass("Attachment") or start
			local parent

			if typeof(instance2) == "table" then
				parent = instance2._getReal() or instance2
			else
				parent = instance2
			end

			local transformedOriginExtents = module3.getTransformedOriginExtents(attachment)
			local objectSpace = start.CFrame:ToObjectSpace(part.CFrame)
			local lerped = speedStart
			local lerped2 = number2
			local cframe = CFrame.fromOrientation(v4.x, v4.y, v4.z)
			local identity = CFrame.identity
			local cframe2 = CFrame.fromOrientation(
				math.rad((random:NextNumber(-spreadAngle.x, spreadAngle.x))),
				math.rad((random:NextNumber(-spreadAngle.y, spreadAngle.y))),
				0
			)

			local function updatePos(p2: number)
				local v6 = syncPosition and module3.getTransformedOriginExtents(attachment) or transformedOriginExtents
				local v7 = v4:Sign() * lerped2 * p2
				cframe *= CFrame.fromOrientation(v7.x, v7.y, v7.z)
				local v8

				if rotAroundOrigin then
					v8 = v6 * cframe2 * cframe * identity
				else
					v8 = v6 * cframe2 * identity * cframe
				end

				instance2.CFrame = v8 * cframe
			end

			updatePos(0)
			local randomId = module3.getRandomId()
			RunService:BindToRenderStep(randomId, module3.RENDER_PRIORITY + list.depth, updatePos)
			table.insert(list, function()
				RunService:UnbindFromRenderStep(randomId)
			end)
			local finisheds = {}
			local v6 = list.effects.prepareEmitOnFinish(instance2, list)
			table.insert(finisheds, list.effects.emitNested(instance2, list.depth + 1, list).Finished)
			local speedTween

			if speedStart == speedEnd or module.getState(instance, "SpeedOverride", nil) then
				speedTween = nil
			else
				speedTween = module2.fromParams(
					module.get(instance, "Speed_Curve", module3.default_bezier),
					module.get(instance, "Speed_Duration", 0.1),
					function(p2, p3)
						lerped = module3.lerp(speedStart, speedEnd, p2)
						return p3
					end
				)
				table.insert(list, speedTween)
			end

			if objectSpace ~= CFrame.identity then
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Part_CFrame_Curve", module3.default_bezier),
						number,
						function(p2, p3)
							identity = CFrame.identity:Lerp(objectSpace, p2)
							return p3 * module.getState(instance, "SpeedOverride", lerped)
						end,
						speedTween
					)
				)
			end

			if number2 ~= number3 then
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Part_RotSpeed_Curve", module3.default_bezier),
						number,
						function(p2, p3)
							lerped2 = module3.lerp(number2, number3, p2)
							return p3 * module.getState(instance, "SpeedOverride", lerped)
						end,
						speedTween
					)
				)
			end

			if partTransparencyStart == partTransparencyEnd then
				instance2.Transparency = partTransparencyStart
			else
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Part_Transparency_Curve", module3.default_bezier),
						number,
						function(p2, p3)
							instance2.Transparency = module3.lerp(partTransparencyStart, partTransparencyEnd, p2)
							return p3 * module.getState(instance, "SpeedOverride", lerped)
						end,
						speedTween
					)
				)
			end

			local size = start.Size * p
			local v9 = part.Size * p

			if size == v9 then
				instance2.Size = size
			else
				local v10 = -1
				table.insert(
					list,
					module2.fromParams(
						module.get(instance, "Part_Size_Curve", module3.default_bezier),
						number,
						function(p2, p3)
							local state = module.getState(instance, "SpeedOverride", lerped)

							if math.abs(p2 - v10) < 0.005 then
								return p3 * state
							end

							v10 = p2
							instance2.Size = size:Lerp(v9, p2)
							return p3 * state
						end,
						speedTween
					)
				)
			end

			local specialMesh = start:FindFirstChildOfClass("SpecialMesh")
			local specialMesh2 = part:FindFirstChildOfClass("SpecialMesh")
			local specialMesh3 = instance2:FindFirstChildOfClass("SpecialMesh")

			if specialMesh3 then
				if specialMesh and specialMesh2 then
					local v10 = specialMesh.Scale * p
					local v11 = specialMesh2.Scale * p

					if v10 ~= v11 then
						table.insert(
							list,
							module2.fromParams(
								module.get(instance, "Mesh_Scale_Curve", module3.default_bezier),
								number,
								function(p2, p3)
									specialMesh3.Scale = module3.lerp(v10, v11, p2)
									return p3 * module.getState(instance, "SpeedOverride", lerped)
								end,
								speedTween
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

			local meshDecals, v10, v11 = module3.getMeshDecals(instance, instance2)
			local v12 = 0

			if flipbook then
				table.sort(meshDecals, function(a, b)
					local v13 = a.Name:match("%d+") or 0
					local v14 = b.Name:match("%d+") or 0
					return tonumber(v13) < tonumber(v14)
				end)
				local decal = Instance.new("Decal")
				decal.Parent = parent
				table.insert(list, decal)

				if flipbookFadeOffset > 0 and decalStartTransparency ~= decalEndTransparency then
					table.insert(
						list,
						module2.fromParams(module3.default_bezier, number + flipbookFadeOffset, function(p2, p3)
							decal.Transparency = module3.lerp(decalStartTransparency, decalEndTransparency, p2)
							return p3 * module.getState(instance, "SpeedOverride", lerped)
						end, speedTween)
					)
				end

				table.insert(list, module2.fromParams(module3.default_bezier, number, function(p2, p3)
					local meshDecal = meshDecals[math.max(math.round(#meshDecals * p2), 1)]
					decal.Texture = meshDecal.Texture
					decal.Color3 = meshDecal.Color3
					decal.ZIndex = meshDecal.ZIndex

					if flipbookFadeOffset == 0 then
						decal.Transparency = module3.lerp(decalStartTransparency, decalEndTransparency, p2)
						decal.ZIndex = meshDecal.ZIndex
					end

					return p3 * module.getState(instance, "SpeedOverride", lerped)
				end, speedTween))
			else
				for _, meshDecal in meshDecals do
					local v13 = v11[meshDecal]
					local transparencyStart = module.get(meshDecal, "Transparency_Start", decalStartTransparency)
					local transparencyEnd = module.get(meshDecal, "Transparency_End", decalEndTransparency)

					if transparencyStart == transparencyEnd then
						meshDecal.Transparency = transparencyStart
					else
						local v14 = meshDecal
						local transparency = transparencyStart
						local v16 = transparencyEnd
						table.insert(
							list,
							module2.fromParams(
								module.get(meshDecal, "Transparency_Curve", module3.default_bezier),
								number,
								function(p2, p3)
									v14.Transparency = module3.lerp(transparency, v16, p2)
									return p3 * module.getState(instance, "SpeedOverride", lerped)
								end,
								speedTween
							)
						)
					end

					if meshDecal.Color3 ~= v13.Color3 then
						local v14 = meshDecal
						local v15 = v13
						local v16 = meshDecal
						table.insert(
							list,
							module2.fromParams(
								module.get(meshDecal, "Color_Curve", module3.default_bezier),
								number,
								function(p2, p3)
									local v17 = module5.fromSRGB(v14.Color3)
									local v18 = module5.fromSRGB(v15.Color3)
									v14.Color3 = module5.toSRGB(v17:Lerp(v18, p2), true)
									return p3 * module.getState(instance, "SpeedOverride", lerped)
								end,
								speedTween
							)
						)
					end

					local frames = v10[meshDecal]

					if not frames then
						continue
					end

					local v15 = meshDecal
					local v16 = {
						ref = meshDecal,
						frames = frames,
						speedTween = speedTween,
						effectDuration = number,
						curve = module.get(meshDecal, "Flipbook_Change_Curve", module3.linear_bezier),
						duration = module.get(meshDecal, "Flipbook_Change_Duration", number),
						getSpeed = function()
							return module.getState(instance, "SpeedOverride", lerped)
						end,
						setTexture = function(texture)
							v15.Texture = texture
						end
					}
					local changeDuration = module4.getChangeDuration(v16)

					if v12 < changeDuration then
						v12 = changeDuration
					end

					table.insert(
						list,
						module2.fromParams(v16.curve, changeDuration, module4.createUpdateCallback(v16), speedTween)
					)
				end
			end

			module2.timer(math.max(number, v12) + flipbookFadeOffset + destroyDelay, function(p2, p3)
				local state = module.getState(instance, "SpeedOverride", lerped)
				lerped = state

				if state > 0 then
					return p2 * state
				end

				if p3 > 0 then
					local v13

					if speedTween then
						v13 = speedTween.Connected
					else
						v13 = module.getState(instance, "SpeedTweening", false)
					end

					if v13 then
						return p2 * state
					end
				end

				return nil
			end, speedTween, list)
			module6.all(finisheds):await()
			list.effects.emitOnFinish(v6, parent, list.depth + 1, list).Finished:await()
		end
	end
}