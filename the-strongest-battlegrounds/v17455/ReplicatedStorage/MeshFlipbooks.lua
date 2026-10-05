local createVector = vector.create
local TweenService = game:GetService("TweenService")
local thrown = game.Workspace.Thrown
local RunService = game:GetService("RunService")
local class = {}

function class.new(flag: boolean)
	local self = setmetatable({}, class)
	local start

	if not flag then
		start = tick() or nil
	end

	self.start = start
	self.freezeStart = nil
	self.freezeTimeSubtract = 0
	return self
end

function class.GetTimePassed(p: number)
	return tick() - p
end

function class:Reset()
	self.start = tick()
	self.freezeStart = nil
	self.freezeTimeSubtract = 0
end

function class:UpdateFreezeTimeSub()
	local freezeStart = self.freezeStart

	if not freezeStart then
		return false
	end

	self.freezeTimeSubtract += class.GetTimePassed(freezeStart)
	self.freezeStart = tick()
	return true
end

function class:Freeze()
	if self:UpdateFreezeTimeSub() then
		return
	end

	self.freezeStart = tick()
end

function class:Unfreeze()
	self:UpdateFreezeTimeSub()
	self.freezeStart = nil
end

function class:HasPassedTime(p, p2)
	if self.start and not (p <= self()) then
		return false
	end

	if not p2 then
		self:Reset()
	end

	return true
end

function class:GetStopwatchTime()
	local now = tick()
	self.start = self.start or now
	self:UpdateFreezeTimeSub()
	return class.GetTimePassed(self.start) - self.freezeTimeSubtract
end

function class:GetAlpha(p: number, p2, value: number?)
	local v = (self() + (value or 0)) / p

	if p2 then
		return v
	end

	return (math.clamp(v, 0, 1))
end

function class.newTimer(p: number, callback, value: number?)
	local v = class.new()
	local v2 = class.new()
	local v3 = value or 0

	while not (v:HasPassedTime(p + v3, true) or callback(v:GetAlpha(p, nil, v3), v(), v2())) do
		v2:Reset()
		RunService.Heartbeat:Wait()
	end
end

class.__index = class

function class:__call()
	return self:GetStopwatchTime()
end

local v = {
	Random = function(value: number, value2: number)
		return Random.new():NextNumber(value or 0.8, value2 or 1.2)
	end,
	RandomReverseMutlipler = function()
		if math.random(0, 1) == 1 then
			return 1
		end

		return -1
	end
}

function v.RandomRotation()
	return v.Random(-6.283185307179586, 6.283185307179586)
end

function v.Round(p, value)
	local v2 = value or 0
	local v3 = math.round(p * 10 ^ v2) * 10 ^ (-v2)
	return (tonumber(string.format("%." .. v2 .. "f", v3)))
end

function v.NumberToVector3(p)
	return (Vector3.new(p, p, p))
end

function v.ScaleValue(p, sequence, p2)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function multiplyScaleValue(p3)
		return p2 * p3 / p
	end

	local v2 = {
		NumberSequence = function()
			local v3 = {}

			for k, keypoint in pairs(sequence.Keypoints) do
				local time = keypoint.Time
				local v4 = multiplyScaleValue(keypoint.Value) -- equivalent call inferred; original call site unknown
				v3[k] = NumberSequenceKeypoint.new(time, v4, p2 * keypoint.Envelope / p)
			end

			return NumberSequence.new(v3)
		end,
		NumberRange = function()
			local v3 = multiplyScaleValue(sequence.Min) -- equivalent call inferred; original call site unknown
			return NumberRange.new(v3, p2 * sequence.Max / p)
		end,
		Default = function()
			return p2 * sequence / p
		end
	}
	return (v2[typeof(sequence)] or v2.Default)()
end

function v.GetRootScaleValues(p)
	return (createVector(2, 2, 1)).Magnitude, p.Magnitude
end

function v.GetLargestAxis(vector2: Vector3)
	local v2 = {
		size = vector2.X,
		name = "X"
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function checkLargest(name: string)
		local size = vector2[name]

		if v2.size <= size then
			v2.size = size
			v2.name = name
		end
	end

	checkLargest("Y") -- equivalent call inferred; original call site unknown
	checkLargest("Z") -- equivalent call inferred; original call site unknown
	return v2.size, v2.name
end

function v.SineBetween(p: number, p2: number, p3: number, p4: number, p5: number)
	return ((p2 - p3) * math.sin(p * p4 + p5) + p2 + p3) / 2
end

local class2 = {}
class2.__index = class2

function class2.new(imageObject, value: string?)
	local self = setmetatable({}, class2)
	self.ImageObject = imageObject
	self.TextureParamName = value or "Texture"
	return self
end

function class2:Play(p, p2: number, callback, flag: boolean?)
	local v2 = class.new()
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setNewTexture()
		local v3 = v2() / p2

		if callback then
			v3 = callback(v3)
		end

		self.ImageObject[self.TextureParamName] = class2.GetTextureFromAlpha(p, v3)
	end

	task.spawn(function()
		while not v2:HasPassedTime(p2) do
			local v3 = false
			local RunService2 = game:GetService("RunService")

			if not RunService2:IsServer() and shared.cull and shared.cull.work then
				local position = self.Part and self.Part.Parent and self.Part.Position

				if position and not shared.cull.work(position) then
					if not flag2 then
						flag2 = true
						warn("[MeshFlipbook cull] SKIPPING tick at", position)
					end

					v3 = true
				elseif flag2 then
					flag2 = false
					warn("[MeshFlipbook cull] resumed at", position)
				end
			end

			if not v3 then
				setNewTexture() -- equivalent call inferred; original call site unknown
			end

			task.wait()
		end

		if flag then
			self:Delete()
		end
	end)
end

function class2:Delete()
	for k, _ in self do
		self[k] = nil
	end
end

function class2.GetTextureFromAlpha(list, p: number)
	local count = #list
	return list[math.clamp(math.round(p * count), 1, count)]
end

function class2:SetTextureFromAlpha(p2, p3)
	self.ImageObject[self.TextureParamName] = class2.GetTextureFromAlpha(p2, p3)
end

local MeshFlipbooks = {
	Wind0 = {
		"rbxassetid://11461678568",
		"rbxassetid://11461678488",
		"rbxassetid://11461678409",
		"rbxassetid://11461678313",
		"rbxassetid://11461678244",
		"rbxassetid://11461675803",
		"rbxassetid://11461675738",
		"rbxassetid://11461675605",
		"rbxassetid://11461675546",
		"rbxassetid://11461675422",
		"rbxassetid://11461675356"
	},
	Wind1 = {
		"rbxassetid://12709087413",
		"rbxassetid://12709089414",
		"rbxassetid://12709091338",
		"rbxassetid://12709052082",
		"rbxassetid://12709051925",
		"rbxassetid://12709051840",
		"rbxassetid://12709046645",
		"rbxassetid://12709046514",
		"rbxassetid://12709046410",
		"rbxassetid://12709046344",
		"rbxassetid://12709046207",
		"rbxassetid://12709046012",
		"rbxassetid://12709041406",
		"rbxassetid://12709041294",
		"rbxassetid://12709041173",
		"rbxassetid://12709041095",
		"rbxassetid://12709040977",
		"rbxassetid://12709040841",
		"rbxassetid://12709035460",
		"rbxassetid://12709035361",
		"rbxassetid://12709035226",
		"rbxassetid://12709035099",
		"rbxassetid://12709034940",
		"rbxassetid://12709034804",
		"rbxassetid://12709029886",
		"rbxassetid://12709029739",
		"rbxassetid://12709029558",
		"rbxassetid://12709029448",
		"rbxassetid://12709029377",
		"rbxassetid://12709029200"
	},
	Wind2 = {
		"rbxassetid://13470338298",
		"rbxassetid://13470338205",
		"rbxassetid://13470338069",
		"rbxassetid://13470337936",
		"rbxassetid://13470337799",
		"rbxassetid://13470337705",
		"rbxassetid://13470337605",
		"rbxassetid://13470337504",
		"rbxassetid://13470337307",
		"rbxassetid://13470337065",
		"rbxassetid://13470336871",
		"rbxassetid://13470336729",
		"rbxassetid://13470336566",
		"rbxassetid://13470336437",
		"rbxassetid://13470336294",
		"rbxassetid://13470336113",
		"rbxassetid://13470336008",
		"rbxassetid://13470335851",
		"rbxassetid://13470335752",
		"rbxassetid://13470335638"
	},
	Wind3 = {
		"rbxassetid://15583581350",
		"rbxassetid://15583581268",
		"rbxassetid://15583581163",
		"rbxassetid://15583581073",
		"rbxassetid://15583580947",
		"rbxassetid://15583580830",
		"rbxassetid://15583580724",
		"rbxassetid://15583580608",
		"rbxassetid://15583580488",
		"rbxassetid://15583580288",
		"rbxassetid://15583580138",
		"rbxassetid://15583580039",
		"rbxassetid://15583579925",
		"rbxassetid://15583579776",
		"rbxassetid://15583579583",
		"rbxassetid://15583579386",
		"rbxassetid://15583579213",
		"rbxassetid://15583579007",
		"rbxassetid://15583578841",
		"rbxassetid://15583578616",
		"rbxassetid://15583578452",
		"rbxassetid://15583578183"
	},
	DiceyWind0 = {
		"rbxassetid://13769737333",
		"rbxassetid://13769737186",
		"rbxassetid://13769737005",
		"rbxassetid://13769736812",
		"rbxassetid://13769759577",
		"rbxassetid://13769736174",
		"rbxassetid://13769735915",
		"rbxassetid://13769735699",
		"rbxassetid://13769735432",
		"rbxassetid://13769735245",
		"rbxassetid://13769734982"
	},
	Slash0 = {
		"rbxassetid://13204898262",
		"rbxassetid://13204897736",
		"rbxassetid://13204897313",
		"rbxassetid://13204896833",
		"rbxassetid://13204896227",
		"rbxassetid://13204895744",
		"rbxassetid://13204895210",
		"rbxassetid://13204894750",
		"rbxassetid://13204894286",
		"rbxassetid://13204893811",
		"rbxassetid://13204893290",
		"rbxassetid://13204892795",
		"rbxassetid://13204892226",
		"rbxassetid://13204891702",
		"rbxassetid://13204891035",
		"rbxassetid://13204890584",
		"rbxassetid://13204890049",
		"rbxassetid://13204889468",
		"rbxassetid://13204888992"
	},
	SlashWind0 = {
		"rbxassetid://14127444698",
		"rbxassetid://14127393320",
		"rbxassetid://14127393204",
		"rbxassetid://14127393113",
		"rbxassetid://14127392987",
		"rbxassetid://14127392831",
		"rbxassetid://14127392695",
		"rbxassetid://14127392572",
		"rbxassetid://14127392433",
		"rbxassetid://14127392308",
		"rbxassetid://14127448226",
		"rbxassetid://14127392018",
		"rbxassetid://14127391892"
	},
	UpLines0 = {
		"rbxassetid://14334428426",
		"rbxassetid://14334428426",
		"rbxassetid://14334428243",
		"rbxassetid://14334428107",
		"rbxassetid://14334427908",
		"rbxassetid://14334427593",
		"rbxassetid://14334427593",
		"rbxassetid://14334427409",
		"rbxassetid://14334427313",
		"rbxassetid://14334427189",
		"rbxassetid://14334427002",
		"rbxassetid://14334427002",
		"rbxassetid://14334426739",
		"rbxassetid://14334426626"
	},
	UpLines1 = {
		"rbxassetid://16349253150",
		"rbxassetid://16349253003",
		"rbxassetid://16349252865",
		"rbxassetid://16349252630",
		"rbxassetid://16349252435",
		"rbxassetid://16349252319",
		"rbxassetid://16349252232",
		"rbxassetid://16349252127",
		"rbxassetid://16349251934",
		"rbxassetid://16349251721",
		"rbxassetid://16349251510",
		"rbxassetid://16349251398",
		"rbxassetid://16349251243",
		"rbxassetid://16349251093",
		"rbxassetid://16349250958"
	},
	DotDissolve = {
		"rbxassetid://15494257040",
		"rbxassetid://15494256947",
		"rbxassetid://15494256825",
		"rbxassetid://15494254516",
		"rbxassetid://15494254445",
		"rbxassetid://15494254370",
		"rbxassetid://15494254273",
		"rbxassetid://15494254222",
		"rbxassetid://15494254167",
		"rbxassetid://15494254118",
		"rbxassetid://15494254073",
		"rbxassetid://15494254030",
		"rbxassetid://15494253978",
		"rbxassetid://15494253921",
		"rbxassetid://15494253857",
		"rbxassetid://15494253812",
		"rbxassetid://15494253754",
		"rbxassetid://15494253685",
		"rbxassetid://15494253626",
		"rbxassetid://15494253569",
		"rbxassetid://15494253511",
		"rbxassetid://15494253430",
		"rbxassetid://15494253331",
		"rbxassetid://15494253331",
		"rbxassetid://15494253227",
		"rbxassetid://15494285181",
		"rbxassetid://15494289522",
		"rbxassetid://15494253021",
		"rbxassetid://15494252936"
	},
	SphereWind0 = {
		"rbxassetid://15117059121",
		"rbxassetid://15117060921",
		"rbxassetid://15117061899",
		"rbxassetid://15117062959",
		"rbxassetid://15117062959",
		"rbxassetid://15117065207",
		"rbxassetid://15117066547",
		"rbxassetid://15117067537"
	}
}
MeshFlipbooks.__index = MeshFlipbooks

function MeshFlipbooks.new(p: string, textures, weldPart, cframe: CFrame, vector2: Vector3, color: Color3)
	local object = setmetatable({}, MeshFlipbooks)
	local color2 = color or Color3.fromRGB(330, 510, 498)
	local clone = game.ReplicatedStorage.Resources.Claw.FlipbookMeshes[p]:Clone()
	local mesh = clone.Mesh
	local decal = clone.Decal
	local cFrameValue = Instance.new("CFrameValue")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateCF()
		local weldPart2 = object.WeldPart
		local cFrame = cFrameValue.Value

		if weldPart2 then
			cFrame = weldPart2.CFrame:ToWorldSpace(cFrame)
		end

		clone.CFrame = cFrame
	end

	local changedConnection = weldPart and weldPart.Changed:Connect(function(p2)
		if p2 ~= "CFrame" then
			return
		end

		updateCF() -- equivalent call inferred; original call site unknown
	end)
	cFrameValue.Changed:Connect(updateCF)
	local flipbook = class2.new(decal)
	object.Part = clone
	object.Mesh = mesh
	object.Decal = decal
	object.Flipbook = flipbook
	object.Textures = textures
	object.CFValue = cFrameValue
	object.WeldPart = weldPart
	object.WeldPartStartCF = weldPart and weldPart.CFrame
	object.WeldUpdate = changedConnection
	mesh.Scale = vector2 or createVector(0.5, 0, 0)
	decal.Color3 = color2
	cFrameValue.Value = object:ConvertCFrame(cframe)
	clone.Parent = thrown
	object:SetTextureFromAlpha(0)
	return object
end

function MeshFlipbooks:Tween(p2: string, p3, p4, flag: boolean)
	local tween = TweenService:Create(self[p2], p3, p4)

	if not flag then
		tween:Play()
	end

	return tween
end

function MeshFlipbooks:TweenDecal(p, p2, flag: boolean)
	return self:Tween("Decal", p, p2, flag)
end

function MeshFlipbooks:TweenPart(p, p2, flag: boolean)
	return self:Tween("Part", p, p2, flag)
end

function MeshFlipbooks:TweenMesh(p, p2, flag: boolean)
	return self:Tween("Mesh", p, p2, flag)
end

function MeshFlipbooks:TweenTransparency(transparency: number, p2, flag: boolean)
	return self:TweenDecal(p2, {
		Transparency = transparency
	}, flag)
end

function MeshFlipbooks:TweenCFrame(cframe: CFrame, p, flag: boolean)
	return self:Tween("CFValue", p, {
		Value = self:ConvertCFrame(cframe)
	}, flag)
end

function MeshFlipbooks:SetTransparency(transparency: number)
	self.Decal.Transparency = transparency
end

function MeshFlipbooks:SetCFrame(cframe: CFrame)
	local convertCFrame = self:ConvertCFrame(cframe)
	self.CFValue.Value = convertCFrame
end

function MeshFlipbooks:ConvertCFrame(cframe: CFrame)
	if self.WeldPart then
		return (self.WeldPartStartCF:ToObjectSpace(cframe))
	end

	return cframe
end

function MeshFlipbooks:TweenSize(vector2: Vector3, p, flag: boolean)
	return self:TweenMesh(p, {
		Scale = vector2
	}, flag)
end

function MeshFlipbooks:Play(duration: number, p, flag: boolean, p2)
	self.WeldPartStartCF = self.WeldPart and self.WeldPart.CFrame
	self.Flipbook:Play(self.Textures or p2, duration, p, true)

	if not flag then
		task.delay(duration, function()
			self:Destroy()
		end)
	end
end

function MeshFlipbooks:SetTextureFromAlpha(p2)
	self.Flipbook:SetTextureFromAlpha(self.Textures, p2)
end

function MeshFlipbooks:Destroy()
	self.CFValue:Destroy()
	self.Part:Destroy()

	if self.WeldUpdate then
		self.WeldUpdate:Disconnect()
	end

	for k, _ in self do
		self[k] = nil
	end
end

function MeshFlipbooks.LoadSphereFlipbook(...)
	return MeshFlipbooks.LoadFlipbook("Sphere", ...)
end

function MeshFlipbooks.CreateWind0Flipbook(...)
	return MeshFlipbooks.new("Cone", MeshFlipbooks.Wind0, ...)
end

function MeshFlipbooks.CreateWind1Flipbook(...)
	return MeshFlipbooks.new("Sphere", MeshFlipbooks.Wind1, ...)
end

function MeshFlipbooks.CreateWind2Flipbook(...)
	return MeshFlipbooks.new("Sphere", MeshFlipbooks.Wind2, ...)
end

function MeshFlipbooks.CreateWind3Flipbook(...)
	return MeshFlipbooks.new("Sphere", MeshFlipbooks.Wind3, ...)
end

function MeshFlipbooks.CreateDiceyWindFlipbook(...)
	return MeshFlipbooks.new("Sphere", MeshFlipbooks.DiceyWind0, ...)
end

function MeshFlipbooks.CreateSlashWind0Flippbok(...)
	return MeshFlipbooks.new("Sphere", MeshFlipbooks.SlashWind0, ...)
end

function MeshFlipbooks.CreateAnimatedWind(cframe: CFrame, vector2: Vector3, p: number, p2: number, duration: number, p3, value: number?)
	local v2 = cframe * CFrame.Angles(0, v.RandomRotation(), 0) * CFrame.new(0, p, 0)
	local v3 = (p3 or MeshFlipbooks.CreateWind2Flipbook)(nil, v2, Vector3.new(0, vector2.Y, 0), Color3.new(1, 1, 1))
	v3:Play(duration)
	v3:TweenSize(vector2, TweenInfo.new(duration, Enum.EasingStyle.Cubic))
	v3:SetTransparency(value or 0.95)
	v3:TweenCFrame(
		v2 * CFrame.Angles(0, 1.5707963267948966 * v.RandomReverseMutlipler(), 0) * CFrame.new(0, p2, 0),
		TweenInfo.new(duration)
	)
	return v3
end

return MeshFlipbooks