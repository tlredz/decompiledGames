local createVector = vector.create
local currentCamera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pool = require(game.ReplicatedStorage:WaitForChild("Pool"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local doughMiscDripGeneric = Effect.new("Dough.Misc.Drip.Generic")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local FX = require(game.ReplicatedStorage.FX)
ReplicatedStorage:WaitForChild("Assets")
local dough = FX:WaitForChild("Dough")
local strand = dough.Models.Donuts:WaitForChild("Strand")
local donut = dough.Models.Donuts:WaitForChild("Donut")
local attachment = Instance.new("Attachment")
local attachment2 = Instance.new("Attachment")
CFrame.new(0, 999999, 0)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function Return(p, p2)
	v[p][p2] = true
	p2.Parent = nil
end

local function Grab(instance)
	v[instance] = v[instance] or {}
	local v2 = v[instance]
	local v3, _ = next(v2)

	if not v3 then
		return instance:Clone()
	end

	v2[v3] = nil
	return v3
end

local memoize = Util.Memoize(function(instance)
	local children = {}

	for _, child in pairs(instance:GetChildren()) do
		table.insert(children, child)
	end

	return children
end)
local memoize2 = Util.Memoize(function(data)
	return {
		Size = data.Size.Keypoints,
		Speed = data.Speed,
		Acceleration = data.Acceleration,
		Lifetime = data.Lifetime
	}
end)
local memoize3 = Util.Memoize(function(parent)
	local v2 = {
		{},
		{}
	}

	for _, v3 in pairs(memoize(dough.Misc.Donut.Particles.Ready)) do
		local clone = v3:Clone()
		clone.Enabled = false
		clone.Parent = parent
		table.insert(v2[1], clone)
		table.insert(v2[2], v3)
	end

	return v2
end)
local memoize4 = Util.Memoize(function(parent)
	local v2 = {
		{},
		{}
	}

	for _, v3 in pairs(memoize(dough.Misc.Donut.Particles.Charge)) do
		local clone = v3:Clone()
		clone.Enabled = true
		clone.Parent = parent
		table.insert(v2[1], clone)
		table.insert(v2[2], v3)
	end

	return v2
end)
local memoize5 = Util.Memoize(function(instance)
	local primaryPart = instance.PrimaryPart or instance:FindFirstChild("Center")
	local strip = instance:FindFirstChild("Strip")
	strip:FindFirstChildOfClass("Bone")
	local vector2 = nil
	local v2 = math.max(strip.Size.X, strip.Size.Y, strip.Size.Z)
	local v3

	if v2 == strip.Size.X then
		v3 = "X"
	elseif v2 == strip.Size.Y then
		v3 = "Y"
	elseif v2 == strip.Size.Z then
		v3 = "Z"
	else
		v3 = false
	end

	if v3 == "X" then
		vector2 = Vector3.new(v2, 0, 0)
	elseif v3 == "Y" then
		vector2 = Vector3.new(0, v2, 0)
	elseif v3 == "Z" then
		vector2 = Vector3.new(0, 0, v2)
	end

	local size = strip.Size
	local vector3 = v3 == "X" and Vector3.new(0, size.Y, size.Z) or v3 == "Y" and Vector3.new(size.X, 0, size.Z)

	if not vector3 then
		if v3 == "Z" then
			vector3 = Vector3.new(size.X, size.Y, 0)
		else
			vector3 = false
		end
	end

	local bones = {}
	local result = {}

	for _, bone in pairs(strip:GetDescendants()) do
		if not bone:IsA("Bone") then
			continue
		end

		table.insert(bones, bone)
		table.insert(result, { bone.Position.Unit, bone.Position.Magnitude })
	end

	return primaryPart, strip, vector2, vector3, result, bones
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function round(p, p2)
	local v2, v3 = math.modf(p / p2)
	return (tonumber(string.format("%.3f", p2 * (v2 + (v3 > 0.5 and 1 or 0)))))
end

local function popParticles(cFrame, value, value2)
	local v2 = typeof(cFrame) == "Instance"
	local v3 = round(value or 1, 0.01) -- equivalent call inferred; original call site unknown
	local fadeOut = round(value2 or 1, 0.01) -- equivalent call inferred; original call site unknown
	local modelCFrame

	if v2 or not cFrame then
		modelCFrame = cFrame:GetModelCFrame()
	else
		modelCFrame = cFrame
	end

	local v5 = 100 + 2.5 * v3
	local magnitude = (currentCamera.CFrame.p - modelCFrame.p).Magnitude

	if v5 < magnitude then
		if v5 * 2 < magnitude then
			return
		end
	else
		local v6 = magnitude / v5
		Effect.new("ShakeCam"):replicate({
			PosInfluence = createVector(0, 1, 1),
			RotInfluence = createVector(1, 0, 1),
			Magnitude = 2,
			Roughness = 3,
			FadeIn = 0,
			FadeOut = fadeOut,
			Power = 1 - v6 * 0.5
		})
	end

	local v6 = attachment
	v[v6] = v[v6] or {}
	local v7 = v[v6]
	local clone, _ = next(v7)

	if clone then
		v7[clone] = nil
	else
		clone = v6:Clone()
	end

	if v2 then
		clone.CFrame = CFrame.identity
	else
		clone.CFrame = cFrame
	end

	local v8 = memoize3(clone)
	local v9 = 0

	for k, v10 in pairs(v8[1]) do
		local v11 = memoize2(v8[2][k])
		v10.Lifetime = NumberRange.new(v11.Lifetime.Min * fadeOut, v11.Lifetime.Max * fadeOut)
		Util.Misc.ScaleParticle(v10, v3, v11)
		v9 = math.max(v9, v10.Lifetime.Max)
	end

	clone.Parent = not v2 and workspace.Terrain or cFrame.PrimaryPart

	for _, v10 in pairs(v8[1]) do
		local emitCount = v10:GetAttribute("EmitCount")
		local emitDelay = v10:GetAttribute("EmitDelay")
		-- equivalent calls inferred from this helper; original call sites unknown
		local v12 = v10

		local function fn()
			if emitCount then
				v12:Emit(emitCount)
			end
		end

		if emitDelay and emitDelay > 0 then
			task.delay(emitDelay, fn)
		else
			fn() -- equivalent call inferred; original call site unknown
		end
	end

	task.delay(v9 + 0.1, function()
		Return(attachment, clone) -- equivalent call inferred; original call site unknown
	end)
end

local function getCFrame(anchor, p, p2)
	local cframe = CFrame.new()

	if anchor and typeof(anchor) == "Instance" and anchor:IsDescendantOf(workspace) then
		if anchor:IsA("Attachment") then
			cframe = anchor.WorldCFrame
		elseif anchor:IsA("BasePart") then
			cframe = anchor.CFrame
		end
	else
		cframe = p
	end

	return cframe * p2, cframe
end

local function getSpawnOffset(side, value)
	local random = Random.new()
	local v2 = side == "Right" and 1 or -1
	local v3 = math.random(1, 2) == 1 and 1 or -1
	local v4 = math.rad((random:NextNumber(12.125, 45)))
	local v5 = Vector3.new(
		v2 * random:NextNumber(0.5, 3),
		v3 * random:NextNumber(0.5, 3),
		0.75 * random:NextNumber(0.5, 3)
	) * (value or 1) / 2
	return CFrame.new(v5, (Vector3.new())) * CFrame.Angles(0, v2 * v4, 0)
end

local function scaleStrand(model, p: number, p2: number, p3: number, p4, items)
	if not (model and model:IsA("Model") and model.PrimaryPart) then
		return
	end

	local primaryPart = model.PrimaryPart or model:FindFirstChild("Center")
	local strip = model:FindFirstChild("Strip")

	if not strip then
		return
	end

	local Y = p or Vector2.new(0.3, 1)
	local typeName = typeof(Y)
	local X

	if typeName:find("Vector") then
		X = Y.X or Y
	else
		X = Y
	end

	if typeName:find("Vector") then
		Y = Y.Y or Y
	end

	strip.Size = p2 * X + p3 * Y
	primaryPart.Size = createVector(1.5, 1.5, 0.75) * ((X + Y) / 2)
	primaryPart.CFrame = strip.CFrame * CFrame.new(0, -strip.Size.Y / 2, 0) * CFrame.new(
		-X / 2.75,
		Y / 10,
		-(X + Y) / 2 / 5
	)

	for k, item in pairs(items) do
		item.Position = p4[k][1] * p4[k][2] * Y
	end
end

local function scaleDonut(model, value, p, value2)
	if not (model and model:IsA("Model") and model.PrimaryPart) then
		return
	end

	local v2 = value or 1
	local v3 = p or createVector(1, 1, 1)
	model.PrimaryPart.Size = v3 * v2
	model.Outline.Size = v3 * v2 * (model.Outline:GetAttribute("Scale") or 1) * (value2 or 1)
end

local v2 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))
local now = 0
v2:setAction(function(object, p)
	local DISTANCE_EPSILON = 0.01
	local now2 = tick()
	local count = 0

	for _, _ in pairs(object.Pool) do
		count += 1
	end

	for _, v3 in pairs(object.Pool) do
		local posSpring = v3.posSpring
		local specialLifetime = v3.specialLifetime
		local lifetime = v3.lifetime
		v3.UpdateDelta = math.min(v3.UpdateDelta, p)

		if not (now2 - v3.LastUpdate >= math.clamp(v3.UpdateDelta * (count / 25), v3.UpdateDelta, 0.1)) then
			continue
		end

		if v3.Mode == "Appear" then
			local v4 = 1
			local flag = false

			if specialLifetime then
				if lifetime:GetAttribute("Holding") then
					if v3.canRestartTime then
						v3.AnimatedStart = now2
						v3.armExtended = false
						v3.timeStoppedGrowing = nil
						v3.canRestartTime = false
					end

					v3.lastHeld = now2
				else
					flag = true
					v4 = 0.25
				end
			end

			local v5 = now2 - v3.Start
			local v6 = now2 - v3.AnimatedStart
			local timeElapsed

			if flag then
				v3.timeElapsed = (v3.lastHeld or now2) - v3.AnimatedStart
				timeElapsed = v3.timeElapsed
			else
				timeElapsed = v6
			end

			local v7 = v4 * (v3.fadeIn or 1)
			local v8 = math.min(1, v5 / v7)
			local v9 = math.min(1, v6 / v7)
			local v10 = math.min(1, timeElapsed / v3.fadeIn)
			local back = Util.Tween.ease.out.back(v10, 0, 1, 1)
			local quad = Util.Tween.ease.out.quad(v8, 0, 1, 1)
			local quad2 = Util.Tween.ease["in"].quad(math.min(1, v9 * 0.5 / 0.5), 0, 1, 1)
			local v11 = 0
			local point = Util.Tween.point(
				v3.widths[1],
				specialLifetime and lifetime:GetAttribute("Scale") or v3.widths[2],
				(math.min(1, timeElapsed / v3.fadeIn))
			)

			if v9 == 1 then
				if specialLifetime then
					local flag2 = false

					if specialLifetime then
						if v3.armExtended ~= true then
							v3.armExtended = lifetime:GetAttribute("ArmActive")
							flag2 = true
						end

						if v3.armExtended == true and lifetime:GetAttribute("ArmActive") then
							flag2 = true
						elseif v3.armExtended == true and not v3.timeStoppedGrowing then
							v3.timeStoppedGrowing = now2
						end
					end

					if flag2 then
						v11 = point
					elseif v3.timeStoppedGrowing then
						local fadeOut = v3.fadeOut
						local v12 = math.min(1, (now2 - v3.timeStoppedGrowing) / fadeOut)
						local back2 = Util.Tween.ease.out.back(v12, 0, 1, 1)
						v11 = Util.Tween.point(point, v3.widths[1], back2)
					end
				else
					v11 = v3.widths[2]
				end
			else
				v11 = Util.Tween.point(
					Util.Tween.point(point, v3.widths[1], (math.min(1, quad2))),
					specialLifetime and lifetime:GetAttribute("Scale") or v3.widths[2],
					back
				)
			end

			local v12 = v11 * v3.widthMultiplier
			local cFrame, lastCF = getCFrame(v3.anchor, v3.lastCF, v3.offset)

			if lastCF then
				v3.lastCF = lastCF
			end

			if v3.mouse then
				if specialLifetime then
					if lifetime:GetAttribute("Holding") then
						cFrame = CFrame.new(cFrame.p, v3.mouse.Value)
					end
				else
					cFrame = CFrame.new(cFrame.p, v3.mouse.Value)
				end
			end

			if v3.specialLifetime then
				v3.position = lifetime:GetAttribute("Position")
				v3.goal = lifetime:GetAttribute("Goal")
				local disengage = lifetime:GetAttribute("Disengage")

				if v3.position and v3.goal and not disengage then
					posSpring.f = 7
					posSpring.d = 1
					cFrame = CFrame.new(v3.position, v3.goal)
				else
					if disengage then
						lifetime:SetAttribute("Disengage", nil)
						lifetime:SetAttribute("Position", nil)
						lifetime:SetAttribute("Goal", nil)
					end

					posSpring.f = 2.5
					posSpring.d = 0.75
				end

				if not (v3.position or v3.goal or lifetime:GetAttribute("Holding")) then
					v3.revolutionAngle = v3.revolutionAngle % 6.283185307179586 + 0.7853981633974483 * p
					local v14 = v3.side == "Right" and 1 or -1
					local v15 = 1.5 * v12 / 3 * Vector3.new(
						v14 * math.sin(v3.revolutionAngle),
						math.cos(v3.revolutionAngle) * 0.5,
						math.sin(v3.revolutionAngle) ^ 2 * 2
					)
					local v16 = math.acos((Vector3.new(v14, 0, 0):Dot(Vector3.new(
						-1.25 * v14 * math.sin(v3.revolutionAngle) ^ 2,
						0,
						-1.25
					).Unit)))
					cFrame *= CFrame.new(v15) * CFrame.Angles(0, -v14 * 3.141592653589793 / 2 + v14 * v16 * 0.65, 0)
				end
			end

			if v9 == 1 then
				if specialLifetime and not lifetime:GetAttribute("Holding") then
					v3.canRestartTime = true
				end

				v3.modelCF = cFrame
			else
				v3.modelCF = cFrame * v3.spawnOffset:Lerp(CFrame.new(), quad)
			end

			local v14 = v3.modelCF - v3.modelCF.p
			v3.lastRotation = v3.lastRotation:Lerp(v14, p * 24)
			local v15 = CFrame.new(posSpring:GetPosition()) * v3.lastRotation
			local _ = v3.side == "Right"
			local v18 = CFrame.Angles(0, 0 * 3.141592653589793, 0) * CFrame.Angles(0, 0, v3.rotationAngle)

			if v3.swapped then
				local model2 = v3.model2
				local v19 = 1.5 * v12

				if model2 and model2:IsA("Model") and model2.PrimaryPart then
					local v20 = v19 or 1
					model2.PrimaryPart.Size = createVector(1.4, 1.4, 0.5) * v20
					model2.Outline.Size = createVector(1.4, 1.4, 0.5) * v20 * (model2.Outline:GetAttribute("Scale") or 1) * 1
				end

				v3.model2:SetPrimaryPartCFrame(v15 * v18)
			end

			if v3.model and not v3.ReturnedModel and v3.model.PrimaryPart and v3.model.PrimaryPart:IsDescendantOf(workspace) then
				if not v3.swapping then
					scaleStrand(
						v3.model,
						Vector2.new(0.9, 1) * 1.5 * v12,
						v3.unitWidth,
						v3.unitLength,
						v3.unitArmature,
						v3.bones
					)
				end

				v3.model:SetPrimaryPartCFrame(v15 * v18)
			else
				v3.swapped = true
			end

			posSpring:SetGoal(v3.modelCF.p)
			v3.rotationAngle = v3.rotationAngle % 6.283185307179586 + 1.1780972450961724 * p

			if v3.swapped then
				local v19 = false

				if specialLifetime then
					if lifetime:GetAttribute("ArmActive") then
						if v3.popped then
							if now2 - v3.popped > 0.3 then
								v19 = true
							else
								v3.popped2 = true
							end
						end
					else
						v3.popped2 = false
					end
				else
					v19 = v3.popped and v3.fadeIn < v6 and now2 - v3.popped > 0.3 and true or false
				end

				if not v3.model2.Parent then
					v3.model2.Parent = v3.ModelCache
				end

				if v19 and not v3.popped2 then
					popParticles(v3.model2, v12, 0.5)
					v3.popped2 = true
				end

				for _, child in pairs(v3.model2:GetChildren()) do
					if child.Name == "Outline" then
					end

					child.Transparency = 0
				end

				if not v3.popped then
					if now2 - now > 0.1 then
						Util.Sound:Play("Dough.DoughAppear", v3.model2.PrimaryPart.Position, nil, 2.0942857142857143)
					end

					popParticles(v3.model2, v12 * 1.25, 0.5)
					v3.popped = now2
				end

				for k, boneParticle in pairs(v3.boneParticles) do
					for _, particle in pairs(boneParticle.Particles) do
						particle.Enabled = false
					end

					Return(attachment2, boneParticle.Attachment) -- equivalent call inferred; original call site unknown
					v3.boneParticles[k] = nil
				end
			else
				if v9 == 1 then
					v3.startedSwapping = true

					if v3.changedAnimation then
						if v3.swapping then
							local v19 = now2 - v3.changedAnimation
							local v20 = math.min(1, v19 / 0.125)
							local circ = Util.Tween.ease.out.circ(v20, 0, 1, 1)
							local back2 = Util.Tween.ease.out.back(v20, 0, 1, 1)
							Util.Tween.ease["in"].circ(v20, 0, 1, 1)
							local quad3 = Util.Tween.ease.out.quad(v20, 0, 1, 1)

							if v20 == 1 then
								local v21 = math.min(1, (v19 - 0.125) / 0.0625)
								local circ2 = Util.Tween.ease.out.circ(v21, 0, 1, 1)

								if v21 == 1 then
									v3.swapped = true
									v3.swapping = false
								else
									for _, child in pairs(v3.model2:GetChildren()) do
										if child.Name == "Outline" then
											child.Transparency = 0
										end
									end

									local model2 = v3.model2
									local v22 = 1.5 * v12 * (0.9 + back2 * 0.1)
									local v23 = 0.85 + 0.15 * circ2

									if model2 and model2:IsA("Model") and model2.PrimaryPart then
										local v24 = v22 or 1
										model2.PrimaryPart.Size = createVector(1.4, 1.4, 0.5) * v24
										model2.Outline.Size = createVector(1.4, 1.4, 0.5) * v24 * (model2.Outline:GetAttribute("Scale") or 1) * (v23 or 1)
									end

									v3.model2:SetPrimaryPartCFrame(v15 * v18)
								end

								if not v3.popped then
									Util.Sound:Play("Dough.DoughAppear", v3.donut.Position, nil, 2.0942857142857143)
									popParticles(v3.model2, v12 * 1.25, 0.375)
									v3.popped = now2
								end

								if not v3.ReturnedModel then
									for _, v22 in pairs(v3.model:FindFirstChild("AnimationController").Animator:GetPlayingAnimationTracks()) do
										v22:Stop(0)
									end

									v3.track:Stop(0)

									if v3.strandSound then
										Util.Sound:FadeOut(v3.strandSound, 0.25)
										v3.strandSound = nil
									end

									v3.donut.Transparency = 0
									v3.ReturnedModel = true
									Return(strand, v3.model) -- equivalent call inferred; original call site unknown
								end
							else
								scaleStrand(
									v3.model,
									Vector2.new(0.9, 1) * 1.5 * v12 * (1 - circ * 0.6),
									v3.unitWidth,
									v3.unitLength,
									v3.unitArmature,
									v3.bones
								)

								if v3.model and not v3.ReturnedModel and v3.model.PrimaryPart and v3.model.PrimaryPart:IsDescendantOf(workspace) then
									v3.model:SetPrimaryPartCFrame(v15 * v18)
								end

								local model2 = v3.model2
								local v21 = 1.5 * v12 * (0.9 + back2 * 0.1)

								if model2 and model2:IsA("Model") and model2.PrimaryPart then
									local v22 = v21 or 1
									model2.PrimaryPart.Size = createVector(1.4, 1.4, 0.5) * v22
									model2.Outline.Size = createVector(1.4, 1.4, 0.5) * v22 * (model2.Outline:GetAttribute("Scale") or 1) * 0.85
								end

								v3.model2:SetPrimaryPartCFrame(v15 * v18)
								v3.donut.Transparency = quad3

								for _, child in pairs(v3.model2:GetChildren()) do
									if child.Name == "Outline" then
										child.Transparency = 1
									else
										child.Transparency = Util.Tween.point(1, 0, quad3)
									end
								end

								for _, boneParticle in pairs(v3.boneParticles) do
									for _, particle in pairs(boneParticle.Particles) do
										particle.Enabled = false
									end
								end

								if not v3.model2.Parent then
									v3.model2.Parent = v3.ModelCache
								end
							end
						end
					else
						if v3.track then
							v3.track:AdjustSpeed(0)
						end

						local hold = v3.model:FindFirstChild("AnimationController") and v3.model.AnimationController:FindFirstChild("Hold")
						v3.track = v3.model:FindFirstChild("AnimationController") and v3.model.AnimationController.Animator:LoadAnimation(hold)

						if v3.track then
							v3.track:Play(nil, nil, 0)
						end

						v3.changedAnimation = now2
						v3.swapping = true
					end
				elseif v7 < v3.fadeIn and not v3.adjusted then
					local v19 = math.max(p, v7 - v6) / 4
					v3.track:AdjustSpeed(1 / v19)
					v3.adjusted = true
				else
					local v19 = v7 + 0.13333333333333333
					v3.track:AdjustSpeed(1 / v19)
				end

				if v3.ReturnedModel then
					for _, boneParticle in pairs(v3.boneParticles) do
						for _, particle in pairs(boneParticle.Particles) do
							particle.Enabled = false
						end
					end
				else
					for _, boneParticle in pairs(v3.boneParticles) do
						boneParticle.Attachment.CFrame = v3.bones[boneParticle.BoneIndex].TransformedWorldCFrame
					end
				end
			end

			if now2 - v3.LAST_DROP > 0.14285714285714285 then
				doughMiscDripGeneric:replicate({
					UpdateDelta = v3.FastMode and 0.041666666666666664,
					Type = "Donut",
					Model = v3.swapped and v3.model2 or v3.model,
					Thickness = 0.4,
					Gravity = Random.new():NextNumber(0.15, 0.75),
					DropLifetime = 2,
					MaxPastrySize = 2 * v12
				})
				v3.LAST_DROP = now2
			end

			if specialLifetime then
				if not lifetime or not lifetime:IsDescendantOf(workspace) or lifetime:GetAttribute("Destroy") then
					if not (lifetime and lifetime:IsDescendantOf(workspace) and lifetime:GetAttribute("Destroy")) then
						v3.s:Fire()
						continue
					end

					if v3.position and (posSpring:GetPosition() - v3.position).Magnitude < DISTANCE_EPSILON then
						v3.s:Fire()
						continue
					end

					for _, child in pairs(v3.model2:GetChildren()) do
						child.Transparency = 0
					end

					if not v3.ReturnedModel then
						v3.ReturnedModel = true
						Return(strand, v3.model) -- equivalent call inferred; original call site unknown
					end
				end
			elseif lifetime + v3.fadeIn < v6 and v3.swapped then
				v3.s:Fire()
				continue
			end
		elseif v3.Mode == "Disappear" then
			for k, boneParticle in pairs(v3.boneParticles) do
				for _, particle in pairs(boneParticle.Particles) do
					particle.Enabled = false
				end

				Return(attachment2, boneParticle.Attachment) -- equivalent call inferred; original call site unknown
				v3.boneParticles[k] = nil
			end

			local v4 = now2 - v3.Start
			v3.rotationAngle = v3.rotationAngle % 6.283185307179586 + 1.1780972450961724 * 1 * p
			posSpring:Update(p)
			local now3 = tick()
			local _ = v3.side == "Right"
			local v7 = CFrame.Angles(0, 0 * 3.141592653589793, 0) * CFrame.Angles(0, 0, v3.rotationAngle)

			if specialLifetime and lifetime:GetAttribute("ArmActive") then
				if not v3.timeStoppedSince then
					v3.timeStoppedSince = now3
				end

				v3.modelCF = CFrame.new(posSpring:GetPosition(), v3.goal)
				v3.model2:SetPrimaryPartCFrame(v3.modelCF * v7)
				continue
			else
				if v3.timeStoppedSince and not v3.timeDelay then
					v3.timeDelay = now3 - v3.timeStoppedSince
				end

				local v8 = v4 - (v3.timeDelay or 0)
				local _ = v8 > 0
				local v9 = math.clamp((v8 - v3.fdelay) / v3.fadeOut, 0, 1)
				local circ = Util.Tween.ease["in"].circ(v9, 0, 1, 1)
				local scale = specialLifetime and lifetime:GetAttribute("Scale") or v3.widths[2]
				local v10 = Util.Tween.point(v3.startWidth, 0, circ) * v3.widthMultiplier
				local v11 = v3.widthMultiplier * scale
				local velocity = Util.Misc.CalculateVelocity(v11, v3.fadeOut, 4)
				local v12 = v3.side == "Right" and 1 or -1
				local vector2 = -v3.modelCF.LookVector
				local unit = vector2:Cross(createVector(1, 0, 0)).Unit
				local unit2 = (unit.Magnitude < DISTANCE_EPSILON and createVector(0, 1, 0) or unit):Cross(vector2).Unit
				local unit3 = (vector2 + v12 * (unit2.Magnitude < DISTANCE_EPSILON and createVector(1, 0, 0) or unit2) * 0.5).Unit
				local position = Util.Misc.CalculatePosition(unit3.Unit * velocity, createVector(-0, -45, -0), 4, v8)
				local cframe = CFrame.new(v3.position + position, v3.position + Vector3.new(0, p, 0))
				local v13 = cframe - cframe.p
				v3.lastRotation = v3.lastRotation:Lerp(v13, p * 12)
				posSpring:SetGoal(cframe.p)
				local cFrame = CFrame.new(posSpring:GetPosition()) * v3.lastRotation
				local model2 = v3.model2
				local v15 = 1.5 * v10

				if model2 and model2:IsA("Model") and model2.PrimaryPart then
					local v16 = v15 or 1
					model2.PrimaryPart.Size = createVector(1.4, 1.4, 0.5) * v16
					model2.Outline.Size = createVector(1.4, 1.4, 0.5) * v16 * (model2.Outline:GetAttribute("Scale") or 1) * 1
				end

				v3.model2:SetPrimaryPartCFrame(cFrame * v7)

				if v9 == 1 then
					popParticles(cFrame, v3.startWidth * v3.widthMultiplier * 0.25, 1.5)
					Return(donut, v3.model2) -- equivalent call inferred; original call site unknown

					if #v3.ModelCache:GetChildren() == 0 then
						v3.ModelCache:Destroy()
					end

					object:remove(v3)
					continue
				elseif now3 - v3.LAST_DROP > 0.14285714285714285 then
					doughMiscDripGeneric:replicate({
						UpdateDelta = v3.FastMode and 0.041666666666666664,
						Type = "Donut",
						Model = v3.model2,
						Thickness = 0.3,
						Gravity = Random.new():NextNumber(0.3, 1),
						DropLifetime = 2,
						MaxPastrySize = 2 * v10
					})
					v3.LAST_DROP = now3
				end
			end
		end

		posSpring:Update(now2 - v3.LastUpdate)
		v3.LastUpdate = now2
	end
end)
local v3 = 0
return function(data)
	v3 = v3 % 100 + 1
	local mouse = data.Mouse
	local side = data.Side or math.random(2) == 1 and "Right" or "Left"
	local cFrame = data.CFrame or CFrame.new()
	local anchor = data.Anchor
	local scale = data.Scale or { 0, 1 }
	assert(typeof(scale) == "table", "Please make sure that the Scale you're setting is in table format")
	local scaleMultiplier = data.ScaleMultiplier or 1
	local fadeIn = data.FadeIn or 0.5
	local fadeOut = data.FadeOut or 0.5
	local lifetime = data.Lifetime or 1
	local specialLifetime = typeof(lifetime) == "Instance"
	local v5 = round(scale[1] * scaleMultiplier, 0.01) -- equivalent call inferred; original call site unknown
	local rotationAngle = Random.new():NextNumber(-1, 1) * 3.141592653589793
	local cframe = CFrame.new()
	local spawnOffset = getSpawnOffset(
		side,
		(specialLifetime and lifetime:GetAttribute("Scale") or scale[2]) * scaleMultiplier
	)
	local cFrame2, v7 = getCFrame(anchor, cframe, cFrame)
	local v8 = cFrame2 * spawnOffset
	local spring = Util.Spring.new(0.75, 2.5, v8.p)
	local v10 = strand
	v[v10] = v[v10] or {}
	local v11 = v[v10]
	local clone, _ = next(v11)

	if clone then
		v11[clone] = nil
	else
		clone = v10:Clone()
	end

	local v12, donut2, unitLength, unitWidth, unitArmature, bones = memoize5(clone)
	local boneParticles = {}
	local v19 = donut
	v[v19] = v[v19] or {}
	local v20 = v[v19]
	local clone2, _ = next(v20)

	if clone2 then
		v20[clone2] = nil
	else
		clone2 = v19:Clone()
	end

	scaleStrand(clone, Vector2.new(0.9, 1) * 1.5 * 1, unitWidth, unitLength, unitArmature, bones)
	donut2.Transparency = 0
	scaleStrand(clone, Vector2.new(0.9, 1) * 1.5 * v5, unitWidth, unitLength, unitArmature, bones)
	clone:SetPrimaryPartCFrame(v8)

	if clone2 and clone2:IsA("Model") and clone2.PrimaryPart then
		clone2.PrimaryPart.Size = createVector(0, 0, 0)
		clone2.Outline.Size = createVector(0, 0, 0) * (clone2.Outline:GetAttribute("Scale") or 1) * 1
	end

	clone2:SetPrimaryPartCFrame(v8)
	clone2.Name = "Donut" .. v3
	local name = string.format("Dough/%s/%s", script.Parent.Name, script.Name)
	local v22 = _WorldOrigin:FindFirstChild(name)

	if not v22 then
		v22 = Instance.new("Model")
		v22.Name = name
		v22.Parent = _WorldOrigin
	end

	local track = nil

	if data.FastMode then
		for _, child in pairs(clone2:GetChildren()) do
			child.Transparency = 0
		end

		donut2.Transparency = 1
	else
		for _, child in pairs(clone2:GetChildren()) do
			child.Transparency = 1
		end

		clone.Parent = v22
		local fold = clone:FindFirstChild("AnimationController") and clone.AnimationController:FindFirstChild("Fold")
		track = clone:FindFirstChild("AnimationController") and clone.AnimationController.Animator:LoadAnimation(fold)
		local v23 = 1 / fadeIn

		for _, v24 in pairs(clone:FindFirstChild("AnimationController").Animator:GetPlayingAnimationTracks()) do
			v24:Stop(0)
		end

		if track then
			track:Play(nil, nil, v23)
			local v24 = false

			for _, v26 in pairs(clone.AnimationController.Animator:GetPlayingAnimationTracks()) do
				if v26 ~= track then
					continue
				end

				v24 = true
				break
			end

			if not v24 then
				track = false
			end
		end
	end

	local signal = Util.Signal2.new()
	local swapped = false
	tick()
	local lastTime = tick()

	if track and track.IsPlaying and not data.FastMode then
		for i = 1, 5 do
			local v24 = attachment2
			v[v24] = v[v24] or {}
			local v25 = v[v24]
			local clone3, _ = next(v25)

			if clone3 then
				v25[clone3] = nil
			else
				clone3 = v24:Clone()
			end

			clone3.CFrame = v12.CFrame
			local v26 = memoize4(clone3)
			local v27 = 0

			for k, v28 in pairs(v26[1]) do
				local v29 = memoize2(v26[2][k])
				v27 = math.max(v27, v29.Lifetime.Max)
				Util.Misc.ScaleParticle(v28, v5 * 0.5, v29)
			end

			local particles = v26[1]

			for _, v29 in pairs(particles) do
				v29.Enabled = true
			end

			table.insert(boneParticles, {
				BoneIndex = math.floor(#bones * (i / 5)),
				Attachment = clone3,
				Particles = particles
			})
			clone3.Parent = workspace.Terrain
		end
	else
		Return(strand, clone) -- equivalent call inferred; original call site unknown
		clone2.Parent = v22
		swapped = true
	end

	local strandSound, v25

	if not (data.LimitSound and not (tick() - now > 0.1)) then
		strandSound = Util.Sound:Play(
			"Dough.DoughForm",
			clone:IsDescendantOf(workspace) and clone.PrimaryPart.Position or clone2.PrimaryPart.Position,
			nil,
			2.733 / math.max(1.5, fadeIn * 2)
		)
		v25 = Util.Sound:Play("Dough.DoughAmbienceLoop", clone2.PrimaryPart)
		now = tick()
	end

	local v26 = v2:add({
		FastMode = data.FastMode,
		LastUpdate = 0,
		UpdateDelta = data.UpdateDelta or 0.016666666666666666,
		Mode = "Appear",
		side = side,
		model = clone,
		donut = donut2,
		unitWidth = unitWidth,
		unitLength = unitLength,
		unitArmature = unitArmature,
		bones = bones,
		boneParticles = boneParticles,
		track = track,
		strandSound = strandSound,
		model2 = clone2,
		swapped = swapped,
		anchor = anchor,
		lastCF = v7 or cframe,
		offset = cFrame,
		spawnOffset = spawnOffset,
		rotationAngle = rotationAngle,
		revolutionAngle = 0,
		LAST_DROP = 0,
		lastRotation = CFrame.new(),
		lifetime = lifetime,
		specialLifetime = specialLifetime,
		fadeIn = fadeIn,
		fadeOut = fadeOut,
		widthMultiplier = scaleMultiplier,
		widths = scale,
		s = signal,
		ModelCache = v22,
		mouse = mouse,
		posSpring = spring,
		Start = tick(),
		AnimatedStart = tick()
	})
	signal:Wait()
	signal:Destroy()
	local fadeDelay = specialLifetime and lifetime:GetAttribute("FadeDelay")

	if not v26.position then
		v26.position = v26.model2.PrimaryPart.CFrame.p
	end

	if not v26.goal then
		v26.goal = v26.model2.PrimaryPart.CFrame * createVector(0, 0, -1)
	end

	local fdelay = fadeDelay or data.FadeDelay or 0
	spring.f = 7
	spring.d = 1
	spring:SetGoal(v26.position)
	v26.modelCF = clone2.PrimaryPart.CFrame

	for _, child in pairs(clone2:GetChildren()) do
		child.Transparency = 0
	end

	if not v26.ReturnedModel then
		v26.ReturnedModel = true
		Return(strand, clone) -- equivalent call inferred; original call site unknown
	end

	local point = Util.Tween.point(
		scale[1],
		specialLifetime and lifetime:GetAttribute("Scale") or scale[2],
		(math.min(1, (tick() - lastTime) / fadeIn))
	)

	if v25 then
		Util.Sound:FadeOut(v25, fdelay + fadeOut)
	end

	v26.fdelay = fdelay
	v26.startWidth = point
	v26.Start = tick()
	v26.Mode = "Disappear"
end