local createVector = vector.create
local color = Color3.fromRGB(240, 242, 245)
local color2 = Color3.fromRGB(175, 180, 188)
local color3 = Color3.fromRGB(40, 42, 48)
local color4 = Color3.fromRGB(232, 176, 66)
local cframe = CFrame.Angles(0, -0.13962634015954636, 0)
local cframe2 = CFrame.Angles(0, 0.13962634015954636, 0)
local v = {
	createVector(0.7, 0.45, 2.2),
	createVector(0.45, 0.4, 0.55),
	createVector(0.12, 0.1, 0.35),
	createVector(0.55, 0.08, 0.7),
	createVector(1.5, 0.12, 1),
	createVector(1.4, 0.1, 0.85),
	createVector(0.55, 0.1, 0.7),
	createVector(1.5, 0.12, 1),
	createVector(1.4, 0.1, 0.85),
	createVector(0.55, 0.1, 0.7)
}
local Visuals = {}
local parent = nil

function Visuals.setContainer(p)
	parent = p
end

local function wingPose(cframe3: CFrame, p: number, p2: number, p3: number, scale: number)
	local cframe4 = CFrame.new(p * 0.3 * scale, scale * 0.1, scale * -0.3)
	local v3

	if p > 0 then
		v3 = cframe
	else
		v3 = cframe2
	end

	local v4 = cframe4 * CFrame.Angles(0, 0, p * p2)
	local v5 = v4 * CFrame.new(p * 1.5 * scale, 0, 0) * v3 * CFrame.Angles(0, 0, p * p3)
	return
		cframe3 * v4 * CFrame.new(p * 0.75 * scale, 0, 0),
		cframe3 * v5 * CFrame.new(p * 0.699999988079071 * scale, 0, 0),
		cframe3 * v5 * CFrame.new(p * 1.6749999821186066 * scale, 0, 0)
end

function Visuals:setScale(scale: number)
	if self.scale == scale then
		return
	end

	self.scale = scale

	for k, part in self.parts do
		part.Size = v[k] * scale
	end

	self.headOffset = CFrame.new(createVector(0, 0.18, -1.25) * scale)
	self.beakOffset = CFrame.new(createVector(0, 0.12, -1.68) * scale)
	self.tailOffset = CFrame.new(createVector(0, 0.06, 1.35) * scale)
	local glideLeftInner, glideLeftOuter, glideLeftTip = wingPose(
		CFrame.identity,
		-1,
		0.17453292519943295,
		-0.3141592653589793,
		scale
	)
	self.glideLeftInner = glideLeftInner
	self.glideLeftOuter = glideLeftOuter
	self.glideLeftTip = glideLeftTip
	local glideRightInner, glideRightOuter, glideRightTip = wingPose(
		CFrame.identity,
		1,
		0.17453292519943295,
		-0.3141592653589793,
		scale
	)
	self.glideRightInner = glideRightInner
	self.glideRightOuter = glideRightOuter
	self.glideRightTip = glideRightTip
end

function Visuals.setPalette(p, color5: Color3, color6: Color3, color7: Color3)
	local parts = p.parts
	parts[1].Color = color5
	parts[2].Color = color5
	parts[4].Color = color5
	parts[5].Color = color6
	parts[6].Color = color6
	parts[8].Color = color6
	parts[9].Color = color6
	parts[7].Color = color7
	parts[10].Color = color7
end

local function newPart(name: string, size: Vector3, color5: Color3)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color5
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = 1
	return part
end

local function buildTemplate(p: number)
	local model = Instance.new("Model")
	model.Name = `Seagull{p}`
	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = createVector(0.7, 0.45, 2.2)
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Transparency = 1
	local part2 = Instance.new("Part")
	part2.Name = "Head"
	part2.Size = createVector(0.45, 0.4, 0.55)
	part2.Color = color
	part2.Material = Enum.Material.SmoothPlastic
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.TopSurface = Enum.SurfaceType.Smooth
	part2.BottomSurface = Enum.SurfaceType.Smooth
	part2.Transparency = 1
	local part3 = Instance.new("Part")
	part3.Name = "Beak"
	part3.Size = createVector(0.12, 0.1, 0.35)
	part3.Color = color4
	part3.Material = Enum.Material.SmoothPlastic
	part3.Anchored = true
	part3.CanCollide = false
	part3.CanQuery = false
	part3.CanTouch = false
	part3.CastShadow = false
	part3.TopSurface = Enum.SurfaceType.Smooth
	part3.BottomSurface = Enum.SurfaceType.Smooth
	part3.Transparency = 1
	local part4 = Instance.new("Part")
	part4.Name = "Tail"
	part4.Size = createVector(0.55, 0.08, 0.7)
	part4.Color = color
	part4.Material = Enum.Material.SmoothPlastic
	part4.Anchored = true
	part4.CanCollide = false
	part4.CanQuery = false
	part4.CanTouch = false
	part4.CastShadow = false
	part4.TopSurface = Enum.SurfaceType.Smooth
	part4.BottomSurface = Enum.SurfaceType.Smooth
	part4.Transparency = 1
	local part5 = Instance.new("Part")
	part5.Name = "LeftInnerWing"
	part5.Size = createVector(1.5, 0.12, 1)
	part5.Color = color2
	part5.Material = Enum.Material.SmoothPlastic
	part5.Anchored = true
	part5.CanCollide = false
	part5.CanQuery = false
	part5.CanTouch = false
	part5.CastShadow = false
	part5.TopSurface = Enum.SurfaceType.Smooth
	part5.BottomSurface = Enum.SurfaceType.Smooth
	part5.Transparency = 1
	local part6 = Instance.new("Part")
	part6.Name = "LeftOuterWing"
	part6.Size = createVector(1.4, 0.1, 0.85)
	part6.Color = color2
	part6.Material = Enum.Material.SmoothPlastic
	part6.Anchored = true
	part6.CanCollide = false
	part6.CanQuery = false
	part6.CanTouch = false
	part6.CastShadow = false
	part6.TopSurface = Enum.SurfaceType.Smooth
	part6.BottomSurface = Enum.SurfaceType.Smooth
	part6.Transparency = 1
	local part7 = Instance.new("Part")
	part7.Name = "LeftWingtip"
	part7.Size = createVector(0.55, 0.1, 0.7)
	part7.Color = color3
	part7.Material = Enum.Material.SmoothPlastic
	part7.Anchored = true
	part7.CanCollide = false
	part7.CanQuery = false
	part7.CanTouch = false
	part7.CastShadow = false
	part7.TopSurface = Enum.SurfaceType.Smooth
	part7.BottomSurface = Enum.SurfaceType.Smooth
	part7.Transparency = 1
	local part8 = Instance.new("Part")
	part8.Name = "RightInnerWing"
	part8.Size = createVector(1.5, 0.12, 1)
	part8.Color = color2
	part8.Material = Enum.Material.SmoothPlastic
	part8.Anchored = true
	part8.CanCollide = false
	part8.CanQuery = false
	part8.CanTouch = false
	part8.CastShadow = false
	part8.TopSurface = Enum.SurfaceType.Smooth
	part8.BottomSurface = Enum.SurfaceType.Smooth
	part8.Transparency = 1
	local part9 = Instance.new("Part")
	part9.Name = "RightOuterWing"
	part9.Size = createVector(1.4, 0.1, 0.85)
	part9.Color = color2
	part9.Material = Enum.Material.SmoothPlastic
	part9.Anchored = true
	part9.CanCollide = false
	part9.CanQuery = false
	part9.CanTouch = false
	part9.CastShadow = false
	part9.TopSurface = Enum.SurfaceType.Smooth
	part9.BottomSurface = Enum.SurfaceType.Smooth
	part9.Transparency = 1
	local part10 = Instance.new("Part")
	part10.Name = "RightWingtip"
	part10.Size = createVector(0.55, 0.1, 0.7)
	part10.Color = color3
	part10.Material = Enum.Material.SmoothPlastic
	part10.Anchored = true
	part10.CanCollide = false
	part10.CanQuery = false
	part10.CanTouch = false
	part10.CastShadow = false
	part10.TopSurface = Enum.SurfaceType.Smooth
	part10.BottomSurface = Enum.SurfaceType.Smooth
	part10.Transparency = 1
	local v13 = {
		part,
		part2,
		part3,
		part4,
		part5,
		part6,
		part7,
		part8,
		part9,
		part10
	}

	for _, v14 in v13 do
		v14.Parent = model
	end

	model.PrimaryPart = v13[1]
	model.Parent = parent
	return model, v13
end

function Visuals.create(p: number)
	local template, parts = buildTemplate(p)
	local v4 = {
		model = template,
		parts = parts,
		cframes = table.create(10, CFrame.identity),
		transparency = 1,
		scale = 0,
		headOffset = CFrame.identity,
		beakOffset = CFrame.identity,
		tailOffset = CFrame.identity,
		glideLeftInner = CFrame.identity,
		glideLeftOuter = CFrame.identity,
		glideLeftTip = CFrame.identity,
		glideRightInner = CFrame.identity,
		glideRightOuter = CFrame.identity,
		glideRightTip = CFrame.identity
	}
	Visuals.setScale(v4, 1)
	return v4
end

function Visuals:update(cframe3: CFrame, p: number, p2: number, p3: number)
	local cframes = self.cframes
	local scale = self.scale
	cframes[1] = cframe3
	cframes[2] = cframe3 * self.headOffset
	cframes[3] = cframe3 * self.beakOffset
	cframes[4] = cframe3 * self.tailOffset
	local currentCamera = workspace.CurrentCamera
	local v3

	if currentCamera == nil then
		v3 = false
	else
		local magnitude = (currentCamera.CFrame.Position - cframe3.Position).Magnitude
		v3 = scale * 350 < magnitude
	end

	if v3 then
		cframes[5] = cframe3 * self.glideLeftInner
		cframes[6] = cframe3 * self.glideLeftOuter
		cframes[7] = cframe3 * self.glideLeftTip
		cframes[8] = cframe3 * self.glideRightInner
		cframes[9] = cframe3 * self.glideRightOuter
		cframes[10] = cframe3 * self.glideRightTip
	else
		local v4 = math.sin(p) * 0.6108652381980153 * p2 + (1 - p2) * 0.17453292519943295
		local v5 = math.sin(p - 0.7) * 0.4886921905584123 * p2 + (1 - p2) * -0.3141592653589793
		local v6, v7, v8 = wingPose(cframe3, -1, v4, v5, scale)
		cframes[5] = v6
		cframes[6] = v7
		cframes[7] = v8
		local v9, v10, v11 = wingPose(cframe3, 1, v4, v5, scale)
		cframes[8] = v9
		cframes[9] = v10
		cframes[10] = v11
	end

	local transparency = p3 >= 1 and 0 or p3 <= 0 and 1 or 1 - p3 * 1

	if transparency ~= self.transparency and (transparency == 0 or transparency == 1 or math.abs(transparency - self.transparency) > 0.01) then
		self.transparency = transparency

		for _, part in self.parts do
			part.Transparency = transparency
		end
	end
end

function Visuals.collectMoves(p, list, p2)
	local count = #list
	local parts = p.parts
	local cframes = p.cframes

	for i = 1, 10 do
		list[count + i] = parts[i]
		p2[count + i] = cframes[i]
	end
end

function Visuals.destroy(p)
	p.model:Destroy()
end

return Visuals