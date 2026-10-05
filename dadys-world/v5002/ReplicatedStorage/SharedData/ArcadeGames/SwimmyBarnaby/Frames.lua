local Frames = {
	Fish = {
		"rbxassetid://74394372033269",
		"rbxassetid://103134955060533",
		"rbxassetid://76236981916445",
		"rbxassetid://78214549528179"
	},
	FishFPS = 6,
	Seaweed = {
		"rbxassetid://103553879819953",
		"rbxassetid://78763775874335",
		"rbxassetid://125085665491930",
		"rbxassetid://78116442294169"
	},
	SeaweedFPS = 10,
	FarBackground = "rbxassetid://139280468522508",
	Hills = { "rbxassetid://100846291278652", "rbxassetid://83675713050758" },
	HillHeight = 30,
	Clouds = { "rbxassetid://86810896285710", "rbxassetid://82607055725974", "rbxassetid://81658187040137" },
	Shells = {
		"rbxassetid://79230258614165",
		"rbxassetid://136844605266376",
		"rbxassetid://90597528467334",
		"rbxassetid://71658001906888",
		"rbxassetid://113217264410655",
		"rbxassetid://89484350631907"
	},
	ShellSize = 4,
	FishScale = 4,
	SeaweedWidthScale = 2,
	SeaweedEdgeOvershoot = 6,
	CoinRotateAmp = 14,
	CoinRotateSpeed = 2.2,
	buildPlane = function(vector: Vector3, list)
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.Size = Vector3.new(vector.X, vector.Y, 0.05)
		local texture = list and list[1] or ""

		for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			local decal = Instance.new("Decal")
			decal.Face = face
			decal.Texture = texture
			decal.Parent = part
		end

		return part
	end
}
local class = {}
class.__index = class

function Frames.newAnimator(part, frames, value: number?)
	return (setmetatable({
		part = part,
		frames = frames,
		fps = value or 6,
		t = 0,
		i = 1
	}, class))
end

function class:Advance(p: number)
	local frames = self.frames

	if not frames or #frames <= 1 then
		return
	end

	self.t += p
	local v = 1 / self.fps

	while v <= self.t do
		self.t -= v
		self.i = self.i % #frames + 1
		local frame = frames[self.i]

		for _, decal in ipairs(self.part:GetChildren()) do
			if decal:IsA("Decal") then
				decal.Texture = frame
			end
		end
	end
end

local class2 = {}
class2.__index = class2

function Frames.newRocker(plane, body, value: number?, value2: number?)
	return (setmetatable({
		plane = plane,
		body = body,
		amp = math.rad(value or 14),
		speed = value2 or 2.2,
		t = 0
	}, class2))
end

function class2:Advance(p: number)
	self.t += p
	local v = math.sin(self.t * self.speed) * self.amp
	self.plane.CFrame = self.body.CFrame * CFrame.Angles(0, 0, v)
end

return Frames