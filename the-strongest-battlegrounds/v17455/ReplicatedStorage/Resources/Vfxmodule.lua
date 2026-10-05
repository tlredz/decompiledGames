local createVector = vector.create
game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Vfxmodule = {
	worldpreload = function()
		local folder = Instance.new("Folder")
		folder.Name = "worldpreload"
		folder.Parent = game.Workspace
		local part = Instance.new("Part", folder)
		part.Position = createVector(0, -200, 0)
		part.Anchored = true
		local descendants = game.Workspace:GetDescendants()

		for _, emitter in descendants do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local decal = Instance.new("Decal", part)
			decal.Texture = emitter.Texture
		end
	end,
	Closebeam = function(folder, duration: number)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
		local descendants = folder:GetDescendants()

		for _, beam in descendants do
			if beam:IsA("Beam") then
				TweenService:Create(beam, tweenInfo, {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		task.wait(duration + 0.1)
		Debris:AddItem(folder, 0.01)
	end,
	CloseAndMovebeam = function(folder, duration: number, p: number)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
		local descendants = folder:GetDescendants()

		for _, beam in descendants do
			if beam:IsA("Beam") then
				TweenService:Create(beam, tweenInfo, {
					Width0 = 0,
					Width1 = 0
				}):Play()
			end
		end

		TweenService:Create(folder, tweenInfo, {
			CFrame = folder.CFrame * CFrame.new(0, p, 0)
		}):Play()
		task.wait(duration + 0.1)
		Debris:AddItem(folder, 0.01)
	end,
	tweenbeamtransparency = function(p, p2, p3)
		local keypoints = p.Transparency.Keypoints
		local v = {}

		for _, keypoint in ipairs(keypoints) do
			table.insert(v, {
				Time = keypoint.Time,
				Value = keypoint.Value
			})
		end

		local total = 0
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local numberSequenceKeypoints = {}

			for _, v2 in ipairs(v) do
				local value = v2.Value
				local v3 = p3
				local v4 = math.abs(v3 - value)
				local v5 = v4 == 0 and 0 or 1 / v4
				local v6 = math.clamp(total / p2 * v5 * v4, 0, 1)
				local v7 = value + (v3 - value) * v6
				table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(v2.Time, v7))
			end

			p.Transparency = NumberSequence.new(numberSequenceKeypoints)

			if p2 <= total then
				local numberSequenceKeypoints2 = {}

				for _, v2 in ipairs(v) do
					table.insert(numberSequenceKeypoints2, NumberSequenceKeypoint.new(v2.Time, p3))
				end

				p.Transparency = NumberSequence.new(numberSequenceKeypoints2)
				heartbeatConnection:Disconnect()
			end
		end)
	end,
	TweenTrailLifetime = function(p, p2, lifetime)
		local min

		if typeof(p.Lifetime) == "NumberRange" then
			min = p.Lifetime.Min
		else
			min = p.Lifetime
		end

		local total = 0
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
			total += dt
			local v = math.clamp(total / p2, 0, 1)
			p.Lifetime = min + (lifetime - min) * v

			if p2 <= total then
				p.Lifetime = lifetime
				heartbeatConnection:Disconnect()
			end
		end)
	end,
	EmitAttributes = function(folder)
		for _, emitter in pairs(folder:GetDescendants()) do
			if not (emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount")) then
				continue
			end

			local emitDelay = emitter:GetAttribute("EmitDelay")
			local emitCount = emitter:GetAttribute("EmitCount")
			local emitDuration = emitter:GetAttribute("EmitDuration")

			if emitDuration and emitDuration > 0 then
				if emitDelay and emitDelay > 0 then
					local v = emitter
					local v2 = emitDuration
					task.delay(emitDelay, function()
						v.Enabled = true
						task.delay(v2, function()
							v.Enabled = false
						end)
					end)
				else
					emitter.Enabled = true
					local v = emitter
					task.delay(emitDuration, function()
						v.Enabled = false
					end)
				end
			elseif emitDelay and emitDelay > 0 then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		end
	end,
	Crater = function(p, p2, p3, size, _, p4)
		local v = math.random(0, 360)
		local v2 = 360 / p2
		local total = 0

		for _ = 1, p2 do
			local part = Instance.new("Part")
			local v3 = math.random(900, 1100) * 0.001
			local tweenInfo = TweenInfo.new(1 * v3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
			part.Size = size
			part.Anchored = true
			part.Parent = workspace
			part.Material = p4.Material
			part.Color = p4.Color
			part.CFrame = p * CFrame.Angles(0, math.rad(v), 0) * CFrame.Angles(0, math.rad(total), 0) * CFrame.new(
				0,
				0,
				p3
			) * CFrame.Angles(0.7853981633974483, 0, 0)
			total += v2
			part.CFrame *= CFrame.new(0, -2, 0)
			local tween = TweenService:Create(part, tweenInfo, {
				CFrame = part.CFrame * CFrame.new(0, 1.7, 0)
			})
			tween:Play()
			tween.Completed:Connect(function()
				local v6 = math.random(2700, 3300) * 0.001
				task.spawn(function()
					task.wait(v6)
					local v7 = math.random(750, 1250) * 0.001
					TweenService:Create(
						part,
						TweenInfo.new(4 * v7, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							CFrame = part.CFrame * CFrame.new(0, 0, -5)
						}
					):Play()
					Debris:AddItem(part, 5)
				end)
			end)
		end
	end,
	textureflipbook = function(instance, list, p: number)
		if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
			warn("Flipbook only works with instances that have a 'Texture' property")
			return
		end

		if type(list) ~= "table" or #list == 0 then
			warn("Flipbook requires a non-empty texture table")
			return
		end

		if p <= 0 then
			warn("Flipbook requires duration > 0")
			return
		end

		local lastTime = os.clock()
		local count = #list
		local v = p / count
		task.spawn(function()
			while true do
				local v2 = os.clock() - lastTime

				if p <= v2 then
					break
				end

				instance.Texture = list[math.floor(v2 / v) + 1]
				task.wait(0.01)
			end

			instance.Texture = list[count]
		end)
	end,
	textureflipbookLoop = function(instance, list, p: number)
		if not (instance and (instance:IsA("Decal") or instance:IsA("Beam") or instance:IsA("ParticleEmitter"))) then
			warn("Flipbook only works with instances that have a 'Texture' property")
			return
		end

		if type(list) ~= "table" or #list == 0 then
			warn("Flipbook requires a non-empty texture table")
			return
		end

		if p <= 0 then
			warn("Flipbook requires duration > 0")
			return
		end

		local count = #list
		local v = count / p
		local v2 = {
			_running = true,
			Stop = function(p2)
				p2._running = false
			end
		}
		task.spawn(function()
			local v3 = 0
			local v4 = 1

			while v2._running do
				v3 += RunService.Heartbeat:Wait()
				local v5 = math.floor(v3 * v)

				if not (v5 > 0) then
					continue
				end

				v4 += v5
				v3 -= v5 / v

				if count < v4 then
					v4 = (v4 - 1) % count + 1
				end

				instance.Texture = list[v4]
			end
		end)
		return v2
	end,
	TexturePreload = function(list)
		local Workspace = game:GetService("Workspace")
		local folder = Instance.new("Folder")
		folder.Name = "TextureParts"
		folder.Parent = Workspace

		local function createPartWithDecal(texture, _)
			local part = Instance.new("Part")
			part.Name = "TexturePart_" .. tostring(texture):gsub("rbxassetid://", ""):gsub("rbxasset://textures/", "")
			part.Size = createVector(4, 4, 0.2)
			part.Position = createVector(0, -300, 0)
			part.Anchored = true
			part.BrickColor = BrickColor.new("Medium stone grey")
			part.Material = Enum.Material.SmoothPlastic
			part.Parent = folder
			local decal = Instance.new("Decal")
			decal.Name = "TextureDecal"
			decal.Texture = texture
			decal.Face = Enum.NormalId.Front
			decal.Parent = part
			return part
		end

		print("Generating " .. #list .. " texture parts...")

		for i, v in ipairs(list) do
			local v2 = math.floor((i - 1) / 5)
			createPartWithDecal(v, Vector3.new((i - 1) % 5 * 1, 5, -v2 * 1))
		end

		print("Finished creating all texture parts!")
		print("Parts are organized in the '" .. folder.Name .. "' folder in Workspace")
	end,
	RandomCFrame = function()
		local v = math.rad((math.random(-360, 360)))
		local v2 = math.rad((math.random(-360, 360)))
		local v3 = math.rad((math.random(-360, 360)))
		return (CFrame.Angles(v, v2, v3))
	end,
	beziertrailpart = function(instance, position: Vector3, p: number, p2: number)
		local Bezier = require(script.Bezier)
		local v = math.rad((math.random(-75, 75)))
		local v2 = math.rad((math.random(-360, 360)))
		local v3 = math.rad((math.random(-75, 75)))
		local v4 = math.rad((math.random(-70, 70)))
		local v5 = math.rad((math.random(-70, 70)))
		local v6 = math.rad((math.random(-70, 70)))
		local v7 = math.random(600, 800) / 1000
		local clone = instance:Clone()
		CFrame.new(position)
		clone.CFrame = CFrame.new(position) * CFrame.Angles(v, v2, v3) * CFrame.new(0, p2, 0)
		clone.CFrame = CFrame.lookAt(clone.Position, position)
		local v8 = clone.CFrame * CFrame.Angles(v4, v5, v6) * CFrame.new(
			math.random(-10, 10),
			math.random(-10, 10),
			p2 * -1 / v7
		)
		local v9 = Bezier.new(clone.Position, v8.Position, position)
		local v10 = p * (math.random(800, 1200) / 1000)
		local cFrameTween = v9:CreateCFrameTween(
			clone,
			{ "CFrame" },
			(TweenInfo.new(v10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0))
		)
		clone.Parent = workspace
		cFrameTween:Play()
	end,
	TimeScaleTween = function(p, duration: number, duration2: number, duration3: number)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
		local tweenInfo2 = TweenInfo.new(duration3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
		local tween = TweenService:Create(p, tweenInfo, {
			TimeScale = 0
		})
		local tween2 = TweenService:Create(p, tweenInfo2, {
			TimeScale = 1
		})
		tween:Play()
		tween.Completed:Connect(function()
			task.wait(duration2)
			tween2:Play()
		end)
	end,
	MakeFlyingDebrispart = function(instance, cFrame: CFrame, p: number, parent, p2: number)
		local clone = instance:Clone()
		clone.CFrame = cFrame
		clone.Parent = parent
		local v = math.random(p2 * -1, p2)
		local v2 = (cFrame * CFrame.Angles(math.rad(v), math.rad((math.random(-360, 360))), (math.rad(v)))).UpVector * 100
		clone.Anchored = false
		clone.AssemblyLinearVelocity = v2 * p
		Debris:AddItem(clone, 5)
	end,
	beamcrescent = function(folder, duration: number, p: number, p2: number, p3)
		folder.Parent = game.Workspace.Thrown
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
		local v = {
			CFrame = folder.CFrame * CFrame.Angles(0, math.rad(p2), 0) * CFrame.new(0, 0, p3)
		}
		local descendants = folder:GetDescendants()

		for i = 1, #descendants do
			local instance = descendants[i]

			if instance:IsA("Beam") then
				TweenService:Create(instance, tweenInfo, {
					Width0 = 0,
					Width1 = 0,
					CurveSize0 = instance.CurveSize0 * p,
					CurveSize1 = instance.CurveSize1 * p
				}):Play()
			elseif instance:IsA("Attachment") then
				local cFrame = instance.CFrame
				TweenService:Create(instance, tweenInfo, {
					CFrame = CFrame.new(cFrame.Position * p) * cFrame.Rotation
				}):Play()
			end
		end

		TweenService:Create(folder, tweenInfo, v):Play()
		Debris:AddItem(folder, 5)
	end,
	HighlightTween = function(parent, fillColor: Color3, outlineColor: Color3, color: Color3, color2: Color3, duration: number, p: number)
		local highlight = Instance.new("Highlight", parent)
		highlight.FillColor = fillColor
		highlight.OutlineColor = outlineColor
		highlight.FillTransparency = p
		highlight.OutlineTransparency = p
		TweenService:Create(
			highlight,
			TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0),
			{
				FillTransparency = 1,
				FillColor = color2,
				OutlineColor = color,
				OutlineTransparency = 1
			}
		):Play()
		Debris:AddItem(highlight, duration + 0.1)
	end,
	RaycastBelow = function(cframe: CFrame, filterDescendantsInstances)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		return (workspace:Raycast(cframe.Position, createVector(0, -10, 0), raycastParams))
	end,
	recolor = function(folder, color: Color3)
		for _, descendant in ipairs(folder:GetDescendants()) do
			local v = descendant
			local success, result = pcall(function()
				return v.Color
			end)

			if not success then
				continue
			end

			if typeof(result) == "Color3" then
				local v2 = descendant
				pcall(function()
					v2.Color = color
				end)
			elseif typeof(result) == "ColorSequence" then
				local colorSequenceKeypoints = {}

				for _, keypoint in ipairs(result.Keypoints) do
					table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, color))
				end

				local v2 = descendant
				pcall(function()
					v2.Color = ColorSequence.new(colorSequenceKeypoints)
				end)
			end
		end
	end
}

function Vfxmodule.WindBeams(folder, duration: number)
	local descendants = folder:GetDescendants()
	local tweenInfo = TweenInfo.new(duration * 0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0)
	local tweenInfo2 = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out, 0, false, 0)

	for _, attachment in descendants do
		if not attachment:IsA("Attachment") then
			continue
		end

		local cFrame = attachment.CFrame
		attachment.CFrame = CFrame.new(0, 0, 0)
		TweenService:Create(attachment, tweenInfo, {
			CFrame = cFrame
		}):Play()
	end

	for _, beam in descendants do
		if not beam:IsA("Beam") then
			continue
		end

		local curveSize0 = beam.CurveSize0
		local curveSize1 = beam.CurveSize1
		local textureSpeed = beam.TextureSpeed
		beam.TextureSpeed *= 2
		TweenService:Create(beam, tweenInfo2, {
			TextureSpeed = textureSpeed * 0.3,
			CurveSize0 = curveSize0,
			CurveSize1 = curveSize1
		}):Play()
		Vfxmodule.tweenbeamtransparency(beam, duration, 1)
	end
end

function Vfxmodule:Modelscale(p2)
	local model = Instance.new("Model")
	local parent = self.Parent
	self.Parent = model
	model:ScaleTo(p2)
	self.Parent = parent
	model:Destroy()
end

function Vfxmodule.BeamScaleTween(folder, p: number, duration: number)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local descendants = folder:GetDescendants()

	for _, beam in descendants do
		if beam:IsA("Beam") then
			TweenService:Create(beam, tweenInfo, {
				CurveSize0 = beam.CurveSize0 * p,
				CurveSize1 = beam.CurveSize1 * p,
				Width0 = beam.Width0 * p,
				Width1 = beam.Width1 * p
			}):Play()
		end
	end

	for _, attachment in descendants do
		if attachment:IsA("Attachment") then
			TweenService:Create(attachment, tweenInfo, {
				CFrame = CFrame.new(attachment.Position * p) * attachment.CFrame.Rotation
			}):Play()
		end
	end
end

return Vfxmodule