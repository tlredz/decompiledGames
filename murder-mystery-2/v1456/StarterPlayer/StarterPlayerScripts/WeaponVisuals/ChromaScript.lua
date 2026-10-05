local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local v = true
local v2 = {
	Red = Color3.fromRGB(255, 0, 0),
	Yellow = Color3.fromRGB(255, 255, 0),
	Green = Color3.fromRGB(0, 255, 0),
	Cyan = Color3.fromRGB(0, 255, 255),
	Blue = Color3.fromRGB(0, 0, 255),
	Purple = Color3.fromRGB(255, 0, 255)
}
local v3 = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 0, 255)
}
local v4 = {}

local function Lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function TimeLerp(p: number, p2: number, p3: number, p4: number)
	local v5 = math.min(p3 / p4, 1)
	return p + (p2 - p) * v5
end

local function disableChromaDecal(instance)
	instance:SetAttribute("ChromaLayer", instance.Texture)
	local staticLayer = instance:GetAttribute("StaticLayer")

	if staticLayer then
		instance.Color3 = Color3.fromRGB(255, 255, 255)
		instance.Texture = staticLayer
	else
		instance.Color3 = Color3.fromRGB(255, 255, 255)
		instance.Texture = "rbxassetid://18363392181"
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableChromaDecal(decal)
	local chromaLayer = decal:GetAttribute("ChromaLayer")

	if chromaLayer then
		decal.Color3 = Color3.fromRGB(255, 0, 0)
		decal.Texture = chromaLayer
	end
end

local function enableChromas()
	for decal, _ in v4 do
		if not decal:IsA("Decal") then
			continue
		end

		enableChromaDecal(decal) -- equivalent call inferred; original call site unknown
	end
end

local function disableChromas()
	for decal, _ in v4 do
		if decal:IsA("Decal") then
			disableChromaDecal(decal)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetColorData(color: Color3)
	return {
		R = color.R * 255,
		G = color.G * 255,
		B = color.B * 255
	}
end

function GetColorDistance(data, data2)
	local v5 = data.R - data2.R
	local v6 = data.G - data2.G
	local v7 = data.B - data2.B
	return (math.sqrt(v5 * v5 + v6 * v6 + v7 * v7))
end

local function LerpToColor(instance)
	local v5 = v4[instance]
	return {
		R = TimeLerp(v5.StartColor.R, v5.TargetColor.R, os.clock() - v5.StartTime, 1),
		G = TimeLerp(v5.StartColor.G, v5.TargetColor.G, os.clock() - v5.StartTime, 1),
		B = TimeLerp(v5.StartColor.B, v5.TargetColor.B, os.clock() - v5.StartTime, 1)
	}
end

local function SetColor(p, startColor, state: string)
	local v5 = v4[p]
	local v6 = v2[state]
	v5.StartColor = startColor
	v5.TargetColor = GetColorData(v6)
	v5.StartTime = os.clock()
	v5.State = state
end

local function toggleChromas()
	v = not v

	if v then
		enableChromas()
	else
		disableChromas()
	end
end

local function onChromaInstanceAdded(instance)
	if not (instance:IsA("Decal") or instance:IsA("Fire") or instance:IsA("Part")) or v4[instance] then
		return
	end

	if not v and instance:IsA("Decal") then
		disableChromaDecal(instance)
	end

	v4[instance] = {
		Index = 1,
		StartColor = {
			R = 255,
			G = 0,
			B = 0
		},
		TargetColor = {
			R = 255,
			G = 0,
			B = 0
		},
		StartTime = os.clock(),
		State = "Red"
	}
end

local function onChromaInstanceRemoved(instance)
	if instance:IsA("Decal") or instance:IsA("Fire") then
		v4[instance] = nil
	end
end

local lastTime = os.clock()

local function onUpdate(_: number)
	if not v or os.clock() - lastTime < 0.03333333333333333 then
		return
	end

	lastTime = os.clock()

	for instance, v5 in v4 do
		local startColor = LerpToColor(instance)

		if GetColorDistance(startColor, v5.TargetColor) <= 1 then
			v5.Index += 1

			if not v3[v5.Index] then
				v5.Index = 1
			end

			v5.StartColor = startColor
			v5.TargetColor = GetColorData(v3[v5.Index])
			v5.StartTime = os.clock()
		end

		if instance:IsA("Decal") then
			instance.Color3 = Color3.fromRGB(startColor.R, startColor.G, startColor.B)
		elseif instance:IsA("Fire") then
			instance.Color = Color3.fromRGB(startColor.R, startColor.G, startColor.B)
		elseif instance:IsA("Part") then
			instance.Color = Color3.fromRGB(startColor.R, startColor.G, startColor.B)
		end
	end
end

for _, v5 in CollectionService:GetTagged("ChromaDecal") do
	onChromaInstanceAdded(v5)
end

for _, v5 in CollectionService:GetTagged("ChromaFire") do
	onChromaInstanceAdded(v5)
end

for _, v5 in CollectionService:GetTagged("ChromaPart") do
	onChromaInstanceAdded(v5)
end

CollectionService:GetInstanceRemovedSignal("ChromaPart"):Connect(onChromaInstanceRemoved)
CollectionService:GetInstanceRemovedSignal("ChromaDecal"):Connect(onChromaInstanceRemoved)
CollectionService:GetInstanceRemovedSignal("ChromaFire"):Connect(onChromaInstanceRemoved)
CollectionService:GetInstanceAddedSignal("ChromaFire"):Connect(onChromaInstanceAdded)
CollectionService:GetInstanceAddedSignal("ChromaDecal"):Connect(onChromaInstanceAdded)
CollectionService:GetInstanceAddedSignal("ChromaPart"):Connect(onChromaInstanceAdded)
script:WaitForChild("ToggleChromas").Event:Connect(toggleChromas)
RunService.PostSimulation:Connect(onUpdate)