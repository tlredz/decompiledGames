local createVector = vector.create
local VisualController = require(script.Parent.VisualController)
local MathUtil = require(script.Parent.MathUtil)
local color = Color3.fromRGB(117, 124, 255)
local color2 = Color3.fromRGB(108, 135, 255)
local color3 = Color3.fromRGB(42, 50, 126)

function getTeleporterRefs(instance)
	local meshs = instance:FindFirstChild("Meshs")
	assert(meshs, "bad meshs folder")
	local teleporterVFX = instance:FindFirstChild("TeleporterVFX")
	assert(teleporterVFX, "bad teleporter vfx")
	local charge = instance:FindFirstChild("Charge")
	assert(charge, "bad charge")
	local center = charge:FindFirstChild("Center")
	assert(center, "bad center")
	local center2 = center:FindFirstChild("Center")
	assert(center2, "bad inner center")
	local gyro = charge:FindFirstChild("Gyro")
	assert(gyro, "bad gyro")
	local sphere = charge:FindFirstChild("Sphere")
	assert(sphere, "bad sphere")
	local wave = center:FindFirstChild("Wave")
	assert(wave, "bad wave")
	local waveEnd = center:FindFirstChild("WaveEnd")
	assert(waveEnd, "bad wave end")
	local midBeam = center:FindFirstChild("MidBeam")
	assert(midBeam, "bad mid beam")
	local midBeamEnd = center:FindFirstChild("MidBeamEnd")
	assert(midBeamEnd, "bad mid beam end")
	local spiral0 = center2:FindFirstChild("Spiral0", true)
	assert(spiral0, "bad spiral0")
	local spiral1 = center2:FindFirstChild("Spiral1", true)
	assert(spiral1, "bad spiral1")
	return {
		Meshs = meshs:GetChildren(),
		Beams = teleporterVFX:QueryDescendants("Beam"),
		Particles = teleporterVFX:QueryDescendants("ParticleEmitter"),
		Charge = charge,
		InnerCenter = center2,
		Gyro = gyro,
		Sphere = sphere,
		Wave = wave,
		WaveEnd = waveEnd,
		MidBeams = midBeam:QueryDescendants("Beam"),
		MidBeamEnd = midBeamEnd,
		Spiral0 = spiral0,
		Spiral1 = spiral1
	}
end

function playChargeState(data, p: number)
	VisualController:DepthEmit(data.InnerCenter)
	VisualController:DepthEmit(data.Wave)
	VisualController:DepthToggle(data.InnerCenter, true)
	VisualController:DepthToggle(data.Gyro, true)
	data.Charge:ScaleTo(0.01)
	VisualController:TweenScale(data.Charge, TweenInfo.new(0.3, Enum.EasingStyle.Sine), 1)
	VisualController:Tween(data.Gyro, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Orientation = data.Gyro.Orientation + createVector(0, 360, 0)
	})

	for _, particle in data.Particles do
		particle:Clear()
		particle.Enabled = false
	end

	for _, beam in data.Beams do
		VisualController:AdjustBeamTransparency(beam, 1)
	end

	for _, mesh in data.Meshs do
		mesh.Transparency = 1
	end

	local result = {}

	for _, midBeam in data.MidBeams do
		midBeam.Enabled = true
		midBeam.Width0 = 0
		midBeam.Width1 = 0
		table.insert(
			result,
			VisualController:Tween(
				midBeam,
				TweenInfo.new(0.07, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true),
				{
					Width0 = midBeam:GetAttribute("Width0"),
					Width1 = midBeam:GetAttribute("Width1")
				}
			)
		)
	end

	data.MidBeamEnd.Position = createVector(0, 0, 0)
	VisualController:Tween(
		data.MidBeamEnd,
		TweenInfo.new(math.max(p, 0.015), Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Position = createVector(0, 75, 0)
		}
	)
	return result
end

function playIdleState(data)
	local sphere = data.Sphere
	local tweenInfo = TweenInfo.new(0.85, Enum.EasingStyle.Cubic)
	sphere.Transparency = 0.11
	sphere.Size = createVector(20, 30, 20)
	VisualController:Tween(sphere, tweenInfo, {
		Size = createVector(70, 50, 70),
		Transparency = 1
	})
	local surfaceAppearance = sphere:FindFirstChildWhichIsA("SurfaceAppearance")

	if surfaceAppearance then
		if surfaceAppearance:GetAttribute("BaseColor") == nil then
			surfaceAppearance:SetAttribute("BaseColor", surfaceAppearance.Color)
		end

		surfaceAppearance.Color = surfaceAppearance:GetAttribute("BaseColor")
		VisualController:Tween(surfaceAppearance, tweenInfo, {
			Color = color3
		})
	end

	VisualController:DepthToggle(data.Charge, false)
	VisualController:DepthEmit(data.WaveEnd)
	local result = {}

	for _, midBeam in data.MidBeams do
		midBeam.Enabled = true
		table.insert(result, VisualController:Tween(midBeam, TweenInfo.new(0.07, Enum.EasingStyle.Sine), {
			Width0 = 0,
			Width1 = 0
		}))
	end

	data.Spiral0:Clear()
	data.Spiral1:Clear()
	local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Sine)

	for _, particle in data.Particles do
		particle.Enabled = true
		particle:Emit(1)
	end

	for _, mesh in data.Meshs do
		VisualController:Tween(mesh, tweenInfo2, {
			Transparency = mesh:GetAttribute("Transparency") or 1
		})
	end

	VisualController:TweenNumberValue(0, tweenInfo2, function(p)
		for _, beam in data.Beams do
			VisualController:AdjustBeamTransparency(beam, p)
		end
	end, 1)
	return result
end

function playTeleportState(p, instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	assert(humanoidRootPart, "bad humanoid root part")
	local head = instance:FindFirstChild("Head")
	assert(head, "bad head")
	local teleportAura = script.Parent:FindFirstChild("TeleportAura")
	assert(teleportAura, "bad teleport aura template")
	local bodyTrail = script.Parent:FindFirstChild("BodyTrail")
	assert(bodyTrail, "bad body trail template")
	local v = humanoidRootPart.Position.Y - 3
	local v2 = math.max(head.Position.Y - v, 0.01)
	local threads = {}
	local clones = {}
	local transparenciesByDecal = {}
	local flag = false
	local clone = teleportAura:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Anchored = false
	VisualController:Weld(clone, humanoidRootPart)
	clone.Parent = workspace.Terrain
	VisualController:DepthToggle(clone, true)
	local v3 = 0
	VisualController:ForModelParts(instance, function(decal)
		transparenciesByDecal[decal] = decal.Transparency

		if decal:IsA("Decal") or decal.Transparency >= 1 then
			return
		end

		local clone2 = decal:Clone()
		clone2.Anchored = false
		clone2.CanCollide = false
		clone2.CanQuery = false
		clone2.CanTouch = false

		for _, child in clone2:GetChildren() do
			if child:IsA("DataModelMesh") then
				if child:IsA("SpecialMesh") then
					child.TextureId = ""
				end
			else
				child:Destroy()
			end
		end

		clone2.Material = Enum.Material.Neon
		clone2.Color = color

		if clone2:IsA("MeshPart") then
			clone2.TextureID = ""
		end

		local size = clone2.Size * 1.01
		clone2.Size = createVector(0, 0, 0)
		clone2.Transparency = 1
		clone2.Parent = workspace.Terrain
		table.insert(clones, clone2)
		local weld = Instance.new("Weld")
		weld.Part0 = clone2
		weld.Part1 = decal
		weld.Parent = clone2
		local v5 = (1 - math.clamp((clone2.Position.Y - v) / v2, 0, 1)) * 1
		v3 = math.max(v3, v5)
		table.insert(threads, task.delay(v5, function()
			clone2.Transparency = transparenciesByDecal[decal]
			VisualController:Tween(clone2, TweenInfo.new(0.55, Enum.EasingStyle.Sine), {
				Color = color2
			})
			VisualController:Tween(clone2, TweenInfo.new(0.075, Enum.EasingStyle.Back), {
				Size = size * createVector(1.75, 0.3, 1.75)
			})
			task.wait(0.075)
			VisualController:Tween(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
				Size = size
			})
			task.wait(0.15)
			VisualController:Tween(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
				Size = size * 1.35
			})
			task.wait(0.1)
			VisualController:Tween(clone2, TweenInfo.new(0.125, Enum.EasingStyle.Sine), {
				Size = size
			})
			task.wait(0.125)
			decal.Transparency = 1

			for _, decal2 in decal:GetChildren() do
				if decal2:IsA("Decal") and transparenciesByDecal[decal2] ~= nil then
					decal2.Transparency = 1
				end
			end

			weld:Destroy()
			clone2.Anchored = true
			local clone = bodyTrail:Clone()
			clone.Parent = clone2
			local position = clone2.Position
			local position2 = p.Charge:GetPivot().Position
			local magnitude = (position - position2).Magnitude
			local cframe = CFrame.lookAt(position, position2)
			local position3 = (cframe * CFrame.new(math.random(-55, 55), math.random(2, 55), -magnitude * 0.25)).Position
			local position4 = (cframe * CFrame.new(math.random(-55, 55), math.random(2, 55), -magnitude * 0.75)).Position
			VisualController:TweenNumberValue(
				1,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				function(p2)
					clone2.Position = MathUtil.cubicBezier(p2, position, position3, position4, position2)

					if p2 < 1 then
						return
					end

					clone2:Destroy()
				end
			)
		end))
	end, true, { "HumanoidRootPart" })
	local ground = clone:FindFirstChild("Ground")
	assert(ground, "bad aura ground")
	local beams = ground:FindFirstChild("Beams")
	assert(beams, "bad aura beams")

	for _, beam in beams:GetDescendants() do
		if beam:IsA("Beam") then
			VisualController:Tween(beam, TweenInfo.new(1, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end
	end

	local v4 = v3 + 0.45
	table.insert(threads, task.delay(v4, function()
		VisualController:DepthToggle(clone, false)
		VisualController:Debris(clone, 2)
	end))
	return v4 + 1, function()
		if flag then
			return
		end

		flag = true

		for _, v5 in threads do
			if coroutine.status(v5) == "suspended" then
				task.cancel(v5)
			end
		end

		for _, v5 in clones do
			v5:Destroy()
		end

		clone:Destroy()

		for part, transparency in transparenciesByDecal do
			if not part.Parent then
				continue
			end

			if part:IsA("BasePart") then
			end

			part.Transparency = transparency
		end
	end
end

return {
	play = function(p, p2, callback)
		local teleporterRefs = getTeleporterRefs(p)

		for _, midBeam in teleporterRefs.MidBeams do
			if midBeam:GetAttribute("Width0") == nil then
				midBeam:SetAttribute("OriginalWidth0", midBeam.Width0)
				midBeam:SetAttribute("Width0", midBeam.Width0 * 0.8)
			end

			if midBeam:GetAttribute("Width1") == nil then
				midBeam:SetAttribute("OriginalWidth1", midBeam.Width1)
				midBeam:SetAttribute("Width1", midBeam.Width1 * 0.8)
			end

			if midBeam:GetAttribute("OriginalEnabled") == nil then
				midBeam:SetAttribute("OriginalEnabled", midBeam.Enabled)
			end
		end

		local v = true
		local flag = true
		local v2 = {}
		local v3 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restore()
			if flag then
				return
			end

			flag = true

			for _, v4 in v2 do
				v4:Cancel()
			end

			if v3 then
				v3()
				v3 = nil
			end

			v2 = playIdleState(teleporterRefs)
		end

		local thread = task.spawn(function()
			while true do
				flag = false
				local v4, v5 = playTeleportState(teleporterRefs, p2)
				v3 = v5
				v2 = playChargeState(teleporterRefs, v4)
				task.wait(v4)

				if not v then
					break
				end

				if callback then
					task.spawn(callback)
				end

				restore() -- equivalent call inferred; original call site unknown
				task.wait(5)

				if not v then
					break
				end
			end
		end)
		return function()
			if not v then
				return
			end

			v = false

			if coroutine.status(thread) == "suspended" then
				task.cancel(thread)
			end

			restore() -- equivalent call inferred; original call site unknown

			for _, v4 in v2 do
				v4:Cancel()
			end

			for _, midBeam in teleporterRefs.MidBeams do
				midBeam.Width0 = midBeam:GetAttribute("OriginalWidth0")
				midBeam.Width1 = midBeam:GetAttribute("OriginalWidth1")
				midBeam.Enabled = midBeam:GetAttribute("OriginalEnabled") == true
			end
		end
	end
}