local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local color = Color3.fromRGB(235, 235, 255)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p)
	table.insert(v, p)
end

local function splashAt(x: number, y: number, z: number, radius: number)
	local part = Instance.new("Part")
	part.Name = "MaskedManInkRainSplashFx"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.35
	part.Size = createVector(0.6, 0.15, 0.6)
	part.CFrame = CFrame.new(x, y + 0.15, z)
	part.Parent = ClientDebris()
	track(part) -- equivalent call inferred; original call site unknown
	TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(radius * 1.6, 0.15, radius * 1.6)
	}):Play()
	task.delay(0.3, function()
		pcall(function()
			part:Destroy()
		end)
	end)
end

local InkRain = {}

function InkRain.InkRainDrop(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local fallHeight = data.fallHeight or 45
	local fallTime = data.fallTime or 0.6
	local radius = data.radius or 6
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local maskedManColorMania = adminAbuse and adminAbuse:FindFirstChild("MaskedManColorMania")
	local inkRainModel = maskedManColorMania and maskedManColorMania.Assets:FindFirstChild("InkRainModel")

	if not inkRainModel then
		warn("[MaskedManColorMania] InkRain: InkRainModel not found in RS.AdminAbuse.MaskedManColorMania.Assets")
		return
	end

	local success, result = pcall(function()
		return inkRainModel:Clone()
	end)

	if not (success and result) then
		return
	end

	result.Anchored = true
	result.CanCollide = false
	result.CanQuery = false
	result.CastShadow = false
	result.CFrame = CFrame.new(x, y + fallHeight, z)
	result.Parent = ClientDebris()
	track(result) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(result, TweenInfo.new(fallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		CFrame = CFrame.new(x, y, z)
	})
	tween:Play()
	tween.Completed:Once(function()
		pcall(function()
			result:Destroy()
		end)
		splashAt(x, y, z, radius)
	end)
end

function InkRain.cleanup()
	for _, v2 in v do
		local v3 = v2
		pcall(function()
			v3:Destroy()
		end)
	end

	table.clear(v)
end

return InkRain