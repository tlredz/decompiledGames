local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local v = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}
local v2 = {
	ParticleEmitter = true,
	Beam = true,
	Trail = true,
	PointLight = true,
	SpotLight = true,
	SurfaceLight = true,
	Smoke = true,
	Fire = true,
	Sparkles = true
}

local function setEnabled(folder, enabled: boolean)
	if v2[folder.ClassName] then
		folder.Enabled = enabled
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if v2[descendant.ClassName] then
			descendant.Enabled = enabled
		end
	end
end

local function adornHighlights(highlight, adornee)
	if highlight:IsA("Highlight") then
		highlight.Adornee = adornee
	end

	for _, highlight2 in ipairs(highlight:GetDescendants()) do
		if highlight2:IsA("Highlight") then
			highlight2.Adornee = adornee
		end
	end
end

local function weaponPart(instance)
	local tool_Accessories = instance:FindFirstChild("Tool_Accessories")

	if tool_Accessories == nil then
		return nil
	end

	for _, child in ipairs(tool_Accessories:GetChildren()) do
		if child:IsA("BasePart") then
			return child
		end

		if not child:IsA("Model") then
			continue
		end

		local primaryPart = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")

		if primaryPart ~= nil then
			return primaryPart
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function delete(child)
	child.Name = "--"
	DebrisModule:AddItem(child, 3)

	if v2[child.ClassName] then
		setEnabled(child, false)
	else
		Ouwmit.Enable(child, false)
	end
end

local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function soundName(p: string)
	return p .. "Sound"
end

local function loopName(p: string)
	return p .. "SoundLoop"
end

local v3 = {
	["Heart Ablaze Mode"] = "FlameTick"
}

local function soundTemplateFor(p: string)
	local sound = script:FindFirstChild(p .. "Sound")

	if sound ~= nil and sound:IsA("Sound") then
		return sound
	end

	local v4 = v3[p]

	if v4 ~= nil then
		local sound2 = script:FindFirstChild(v4 .. "Sound")

		if sound2 ~= nil and sound2:IsA("Sound") then
			return sound2
		end
	end

	local generalTickSound = script:FindFirstChild("GeneralTickSound")

	if generalTickSound == nil or not generalTickSound:IsA("Sound") then
		return nil
	end

	return generalTickSound
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startSound(humanoidRootPart, name: string)
	local name2 = name .. "SoundLoop"

	if humanoidRootPart:FindFirstChild(name2) ~= nil then
		return
	end

	local v5 = soundTemplateFor(name)

	if v5 == nil then
		return
	end

	local clone = v5:Clone()
	clone.Name = name2
	clone.Parent = humanoidRootPart
	clone:Play()
end

local function stopSound(humanoidRootPart, name: string)
	local sound = humanoidRootPart:FindFirstChild(name .. "SoundLoop")

	if sound == nil or not sound:IsA("Sound") then
		return
	end

	sound.Name = "--"
	TweenService:Create(sound, tweenInfo, {
		Volume = 0
	}):Play()
	task.delay(0.6, function()
		if sound.Parent ~= nil then
			sound:Destroy()
		end
	end)
end

local function clearFrom(instance, name: string)
	if instance == nil then
		return
	end

	for _, child in ipairs(instance:GetChildren()) do
		if child.Name ~= name then
			continue
		end

		delete(child) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePart(instance, childName: string)
	if childName == "Weapon" then
		return (weaponPart(instance))
	end

	return (instance:FindFirstChild(childName))
end

local v4 = {
	Weapon = true,
	Body = true,
	HumanoidRootPart = true
}

for _, v5 in ipairs(v) do
	v4[v5] = true
end

local function groupParts(instance, name: string)
	if name == "Body" then
		local result = {}

		for _, childName in ipairs(v) do
			local child = instance:FindFirstChild(childName)

			if child ~= nil then
				table.insert(result, child)
			end
		end

		if #result == 0 then
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart ~= nil then
				table.insert(result, humanoidRootPart)
			end
		end

		return result
	else
		local part = resolvePart(instance, name) -- equivalent call inferred; original call site unknown

		if part == nil then
			return {}
		end

		return { part }
	end
end

local function partMap(folder)
	if folder == nil or not folder:IsA("Folder") then
		return nil
	end

	local children = {}

	for _, child in ipairs(folder:GetChildren()) do
		if v4[child.Name] then
			table.insert(children, child)
		end
	end

	if #children > 0 then
		return children
	end

	return nil
end

local v5 = {
	["Poison Generation"] = true
}
local clans = script.Parent.Parent:FindFirstChild("Clans")
local activationVFX

if clans ~= nil then
	activationVFX = clans:FindFirstChild("ActivationVFX") or nil
end

local v6

if activationVFX == nil then
	v6 = nil
else
	v6 = activationVFX:FindFirstChild("Effects") or nil
end

local function templateFor(childName: string)
	local child = script:FindFirstChild(childName)

	if child ~= nil then
		return child
	end

	if v5[childName] then
		return v6 ~= nil and v6:FindFirstChild(childName) or nil
	end

	return nil
end

return function(instance, name: string, flag: boolean?, list)
	if instance == nil or name == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local child = script:FindFirstChild(name)

	if child == nil then
		if v5[name] and v6 ~= nil then
			child = v6:FindFirstChild(name) or nil
		else
			child = nil
		end
	end

	local v8 = partMap(child)

	if v8 == nil then
		if list then
			if typeof(list) ~= "table" then
				list = v
			end

			local v9 = {}

			for _, v10 in ipairs(list) do
				local part = resolvePart(instance, v10) -- equivalent call inferred; original call site unknown

				if part ~= nil then
					table.insert(v9, part)
				end
			end

			clearFrom(humanoidRootPart, name)

			for _, v10 in ipairs(v9) do
				clearFrom(v10, name)
			end

			if not flag then
				stopSound(humanoidRootPart, name)
				return
			end

			startSound(humanoidRootPart, name) -- equivalent call inferred; original call site unknown
			local child2 = script:FindFirstChild(name)

			if child2 == nil then
				if v5[name] and v6 ~= nil then
					child2 = v6:FindFirstChild(name) or nil
				else
					child2 = nil
				end
			end

			if child2 == nil then
				warn("[TickEnabled] no aura template for " .. tostring(name))
				return
			end

			if #v9 == 0 then
				table.insert(v9, humanoidRootPart)
			end

			local children = child2:GetChildren()

			for _, parent in ipairs(v9) do
				for _, v11 in ipairs(children) do
					local clone = v11:Clone()
					clone.Name = name
					clone.Parent = parent
					adornHighlights(clone, instance)
					setEnabled(clone, true)
				end
			end
		else
			local child2 = humanoidRootPart:FindFirstChild(name)

			if child2 then
				delete(child2) -- equivalent call inferred; original call site unknown
			end

			if not flag then
				stopSound(humanoidRootPart, name)
				return
			end

			startSound(humanoidRootPart, name) -- equivalent call inferred; original call site unknown
			local child3 = script:FindFirstChild(name)

			if child3 == nil then
				if v5[name] and v6 ~= nil then
					child3 = v6:FindFirstChild(name) or nil
				else
					child3 = nil
				end
			end

			if child3 == nil then
				warn("[TickEnabled] no aura template for " .. tostring(name))
				return
			end

			local clone = child3:Clone()
			clone.Parent = humanoidRootPart
			adornHighlights(clone, instance)
			Ouwmit.Enable(clone, true, Ouwmit.Owned(instance))
		end
	else
		for _, v9 in ipairs(v8) do
			for _, v10 in ipairs((groupParts(instance, v9.Name))) do
				clearFrom(v10, name)
			end
		end

		if not flag then
			stopSound(humanoidRootPart, name)
			return
		end

		startSound(humanoidRootPart, name) -- equivalent call inferred; original call site unknown

		for _, folder in ipairs(v8) do
			local v9 = not folder:IsA("Folder") and { folder } or folder:GetChildren()

			for _, parent in ipairs((groupParts(instance, folder.Name))) do
				for _, v11 in ipairs(v9) do
					local clone = v11:Clone()
					clone.Name = name
					clone.Parent = parent
					adornHighlights(clone, instance)
					setEnabled(clone, true)
				end
			end
		end
	end
end