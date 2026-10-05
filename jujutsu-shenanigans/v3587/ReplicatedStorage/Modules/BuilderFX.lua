local createVector = vector.create
local builderFX = game.ReplicatedStorage.Utils.BuilderFX
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local BloodyZee = RunService:IsClient() and require(replicatedStorage.Modules.BloodyZee)
local v = RunService:IsServer() and {
	AddItem = function(self, instance, duration: number)
		task.delay(duration, function()
			if instance then
				instance:Destroy()
			end
		end)
	end
} or Debris

-- equivalent calls inferred from this helper; original call sites unknown
local function getVector(value)
	if value then
		return (Vector3.new(unpack(string.split(value))))
	end

	return createVector(0, 0, 0)
end

local function getPos(p, p2, p3)
	local vector2 = getVector(p2.POSITION) -- equivalent call inferred; original call site unknown
	local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
	local cFrame = p and p.CFrame or CFrame.new()

	if not p3 then
		return cFrame * cframe
	end

	local vector3 = getVector(p2["ALT POSITION"]) -- equivalent call inferred; original call site unknown
	local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
	return cFrame * cframe * cframe2
end

local function getSize2(p, p2)
	local vector2 = getVector(p["SIZE 2"]) -- equivalent call inferred; original call site unknown

	if not p2 then
		return vector2
	end

	local ALTSIZE2 = p["ALT SIZE 2"]

	if ALTSIZE2 then
		return (Vector3.new(unpack(string.split(ALTSIZE2))))
	end

	return createVector(0, 0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRot(_, p, p2)
	local ALTROTATION = p2 and p["ALT ROTATION"] or p.ROTATION
	local vector2 = getVector(ALTROTATION) -- equivalent call inferred; original call site unknown
	return CFrame.fromOrientation(math.rad(vector2.X), math.rad(vector2.Y), (math.rad(vector2.Z)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCF(p, data, p2)
	return getPos(p, data, p2) * getRot(nil, data, p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getColor(data)
	return Color3.fromRGB(unpack(string.split(data.COLOR)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getAltColor(data)
	return Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
end

local function getSize(p, p2)
	local SIZE = tonumber(p.SIZE)

	if p2 then
		return SIZE
	end

	if workspace:GetAttribute("CC1") then
		SIZE = math.clamp(SIZE, -1e999, 40)
	end

	return SIZE
end

local function getAltSize(p, p2)
	local SIZE = tonumber(p.SIZE)

	if workspace:GetAttribute("CC1") then
		SIZE = math.clamp(SIZE, -1e999, 40)
	end

	local v2 = SIZE * tonumber(p["ALT SIZE"] or 1)

	if p2 then
		return v2
	end

	if workspace:GetAttribute("CC1") then
		return (math.clamp(v2, -1e999, 40))
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTransparency(data)
	return (tonumber(data.OPACITY))
end

local function getAltTransparency(p)
	return (tonumber(p["ALT OPACITY"]))
end

local function getTime(p, p2)
	local TIME = tonumber(p.TIME)

	if p2 then
		return TIME
	end

	if workspace:GetAttribute("CC1") then
		TIME = math.clamp(TIME, -1e999, 10)
	end

	return TIME
end

local function getBodyPart(RELATIVE, p)
	if p.RELATIVE ~= nil then
		RELATIVE = p.RELATIVE
	end

	if RELATIVE:IsA("BasePart") then
		return RELATIVE
	end

	if RELATIVE:FindFirstChild(p["BODY PART"]) then
		return RELATIVE[p["BODY PART"]]
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEmit(p, p2)
	if p2 then
		return (tonumber(p.AMOUNT))
	end

	local AMOUNT = tonumber(p.AMOUNT)

	if workspace:GetAttribute("CC1") then
		AMOUNT = math.clamp(AMOUNT, -1e999, 20)
	end

	return AMOUNT
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTexture(data)
	return (tonumber(data.TEXTURE or 0))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEasingStyle(p)
	if p["EASING STYLE"] then
		return Enum.EasingStyle[p["EASING STYLE"]]
	end

	return Enum.EasingStyle.Linear
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getEasingDirection(p)
	if p["EASING DIRECTION"] then
		return Enum.EasingDirection[p["EASING DIRECTION"]]
	end

	return Enum.EasingDirection.In
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCollision(data)
	return data["CAN COLLIDE"] ~= nil and data["CAN COLLIDE"]
end

local function sizeSequence(keypoints, data)
	local SIZE = tonumber(data.SIZE)

	if workspace:GetAttribute("CC1") then
		SIZE = math.clamp(SIZE, -1e999, 40)
	end

	local v2 = SIZE or 1
	local SIZE2 = tonumber(data.SIZE)

	if workspace:GetAttribute("CC1") then
		SIZE2 = math.clamp(SIZE2, -1e999, 40)
	end

	local v3 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

	if workspace:GetAttribute("CC1") then
		v3 = math.clamp(v3, -1e999, 40)
	end

	local v4 = v3 or v2
	local numberSequenceKeypoints = {}

	for _, item in keypoints do
		local v5 = math.clamp(item.Time, 0, 1)
		local v6 = v2 + (v4 - v2) * v5
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(item.Time, item.Value * v6, item.Envelope * v6)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local Cleanup

Cleanup = function(list)
	if not list then
		return
	end

	for i = #list, 1, -1 do
		local animationTrack = list[i]

		if not animationTrack then
			continue
		end

		table.remove(list, i)

		if typeof(animationTrack) == "RBXScriptConnection" then
			animationTrack:Disconnect()
		elseif type(animationTrack) == "function" then
			pcall(animationTrack)
		elseif animationTrack:IsA("AnimationTrack") then
			animationTrack:Stop()
		else
			animationTrack:Destroy()
		end
	end

	task.defer(function()
		if #list <= 0 then
			list = nil
		else
			Cleanup(list)
		end
	end)
end

local v2 = {}

local function getCleanup(instance, data, p)
	local v3 = {}
	table.insert(v3, instance.Destroying:Once(function()
		Cleanup(v3, true)
		v2[instance] = nil
	end))

	if data["VISUAL TAG"] then
		local VISUALTAG = data["VISUAL TAG"]
		v2[instance] = v2[instance] or {}
		v2[instance][VISUALTAG] = v2[instance][VISUALTAG] or {}

		local function fn()
			Cleanup(v3)
		end

		table.insert(v2[instance][VISUALTAG], fn)
		table.insert(v3, function()
			for i = #v2[instance][VISUALTAG], 1, -1 do
				if v2[instance][VISUALTAG][i] ~= fn then
					continue
				end

				table.remove(v2[instance][VISUALTAG], i)
				break
			end

			if #v2[instance][VISUALTAG] <= 0 then
				v2[instance][VISUALTAG] = nil
			end
		end)
	end

	if p then
		return v3
	end

	local TIME = tonumber(data.TIME)

	if workspace:GetAttribute("CC1") then
		TIME = math.clamp(TIME, -1e999, 10)
	end

	task.delay(TIME + 4, function()
		if instance then
			Cleanup(v3)
		end
	end)
	return v3
end

return {
	Cancel = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local VISUALTAG = data["VISUAL TAG"]

		if not VISUALTAG then
			return
		end

		if v2[v3] and v2[v3][VISUALTAG] then
			for i = #v2[v3][VISUALTAG], 1, -1 do
				v2[v3][VISUALTAG][i]()
			end
		end
	end,
	Slash = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part3, data)
		local clone = builderFX.Slash:Clone()
		clone.Weld.Part0 = part3
		local weld = clone.Weld
		weld.C0 = CFrame.new(getVector(data.POSITION))
		local weld2 = clone.Weld
		weld2.C1 = getRot(nil, data, false) * CFrame.Angles(0, 3.141592653589793, 0)
		local mesh = clone.Part1.Mesh
		local scale = mesh.Scale
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		mesh.Scale = scale * SIZE
		local mesh2 = clone.Part2.Mesh
		local scale2 = mesh2.Scale
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		mesh2.Scale = scale2 * SIZE2

		for _, decal in pairs(clone.Part1:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			decal.Color3 = Color3.fromRGB(unpack(string.split(data.COLOR)))
			decal.Transparency = tonumber(data.OPACITY)
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(decal, TweenInfo.new(TIME, easingStyle, easingDirection), {
				Transparency = tonumber(data["ALT OPACITY"])
			}):Play()
		end

		for _, decal in pairs(clone.Part2:GetChildren()) do
			if not decal:IsA("Decal") then
				continue
			end

			decal.Color3 = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
			decal.Transparency = tonumber(data.OPACITY)
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(decal, TweenInfo.new(TIME, easingStyle, easingDirection), {
				Transparency = tonumber(data["ALT OPACITY"])
			}):Play()
		end

		local part1 = clone.Part1
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		part1.CanCollide = collision
		local part2 = clone.Part2
		local collision2 = getCollision(data) -- equivalent call inferred; original call site unknown
		part2.CanCollide = collision2
		clone.Parent = workspace.Effects
		local mesh3 = clone.Part1.Mesh
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
		local scale3 = clone.Part1.Mesh.Scale
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v6 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v6 = math.clamp(v6, -1e999, 40)
		end

		TweenService:Create(mesh3, tweenInfo, {
			Scale = scale3 * v6
		}):Play()
		local mesh4 = clone.Part2.Mesh
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo2 = TweenInfo.new(TIME2, easingStyle2, easingDirection2)
		local scale4 = clone.Part2.Mesh.Scale
		local SIZE4 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE4 = math.clamp(SIZE4, -1e999, 40)
		end

		local v9 = SIZE4 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v9 = math.clamp(v9, -1e999, 40)
		end

		TweenService:Create(mesh4, tweenInfo2, {
			Scale = scale4 * v9
		}):Play()
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		v:AddItem(clone, TIME3)
		local weld3 = clone.Weld
		local TIME4 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME4 = math.clamp(TIME4, -1e999, 10)
		end

		local easingStyle3 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection3 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(weld3, TweenInfo.new(TIME4, easingStyle3, easingDirection3), {
			C0 = CFrame.new(getVector(data["ALT POSITION"])),
			C1 = getRot(nil, data, true) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local part = Instance.new("Part")
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = true
			part.Size = createVector(0, 0, 0)
			part.CFrame = part3.CFrame
			part.Parent = clone
			clone.Weld.Part0 = part
		end

		table.insert(cleanup, clone)
	end,
	Sphere = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Ball:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Parent = workspace.Effects
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision

		if getVector(data["SIZE 2"]) ~= createVector(-1, -1, -1) then
			clone.Size = getVector(data["SIZE 2"])
		end

		local v6 = getVector(data["ALT POSITION"]) == createVector(0, 0, 0)

		if v6 then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			weld.C0 = CFrame.new() * cframe2 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v11 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v11 = math.clamp(v11, -1e999, 40)
		end

		local v9 = {
			Size = createVector(1, 1, 1) * v11,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"]),
			CFrame = 0
		}
		local cFrame

		if not v6 then
			cFrame = getCF(clone, data, true) or nil
		end

		v9.CFrame = cFrame
		TweenService:Create(clone, tweenInfo, v9):Play()
		local SIZE22 = data["SIZE 2"]

		if SIZE22 then
			Vector3.new(unpack(string.split(SIZE22)))
		end

		if getVector(data["ALT SIZE 2"]) ~= createVector(-1, -1, -1) then
			local TIME3 = tonumber(data.TIME)
			local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
			local SIZE23 = data["SIZE 2"]

			if SIZE23 then
				Vector3.new(unpack(string.split(SIZE23)))
			end

			TweenService:Create(clone, tweenInfo2, {
				Size = getVector(data["ALT SIZE 2"])
			}):Play()
		end

		table.insert(cleanup, clone)
	end,
	Mesh = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data, true)
		local clone = builderFX.Ball:Clone()
		local v4 = part
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (v4 and v4.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Shape = Enum.PartType.Block
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshId = "rbxassetid://" .. tonumber(data.AMOUNT)

		if tonumber(data.TEXTURE or 0) ~= 0 then
			specialMesh.TextureId = "rbxassetid://" .. tonumber(data.TEXTURE or 0)
		end

		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		specialMesh.Scale = createVector(1, 1, 1) * SIZE2
		specialMesh.Parent = clone
		clone.Parent = workspace.Effects

		if getVector(data["SIZE 2"]) ~= createVector(-1, -1, -1) then
			specialMesh.Scale = getVector(data["SIZE 2"])
		end

		local SIZE23 = data["SIZE 2"]

		if SIZE23 then
			Vector3.new(unpack(string.split(SIZE23)))
		end

		if getVector(data["ALT SIZE 2"]) == createVector(-1, -1, -1) then
			local TIME = tonumber(data.TIME)
			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
			local SIZE3 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE3 = math.clamp(SIZE3, -1e999, 40)
			end

			local v11 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v11 = math.clamp(v11, -1e999, 40)
			end

			TweenService:Create(specialMesh, tweenInfo, {
				Scale = createVector(1, 1, 1) * v11
			}):Play()
		else
			local TIME = tonumber(data.TIME)
			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
			local SIZE24 = data["SIZE 2"]

			if SIZE24 then
				Vector3.new(unpack(string.split(SIZE24)))
			end

			TweenService:Create(specialMesh, tweenInfo, {
				Scale = getVector(data["ALT SIZE 2"])
			}):Play()
		end

		local v8 = getVector(data["ALT POSITION"]) == createVector(0, 0, 0)

		if v8 then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			weld.C0 = CFrame.new() * cframe2 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME = tonumber(data.TIME)
		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v12 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v12 = math.clamp(v12, -1e999, 40)
		end

		local v10 = {
			Size = createVector(1, 1, 1) * v12,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"]),
			CFrame = 0
		}
		local cFrame

		if not v8 then
			cFrame = getCF(clone, data, true) or nil
		end

		v10.CFrame = cFrame
		TweenService:Create(clone, tweenInfo, v10):Play()
		table.insert(cleanup, clone)
		task.spawn(function()
			local v14 = tick() + tonumber(data.TIME)

			repeat
				task.wait()
			until v14 < tick() or not (clone.Parent and part.Parent)

			clone:Destroy()
		end)
	end,
	Block = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Ball:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Shape = Enum.PartType.Block
		clone.Parent = workspace.Effects
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision

		if getVector(data["SIZE 2"]) ~= createVector(-1, -1, -1) then
			clone.Size = getVector(data["SIZE 2"])
		end

		local v6 = getVector(data["ALT POSITION"]) == createVector(0, 0, 0)

		if v6 then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			weld.C0 = CFrame.new() * cframe2 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v11 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v11 = math.clamp(v11, -1e999, 40)
		end

		local v9 = {
			Size = createVector(1, 1, 1) * v11,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"]),
			CFrame = 0
		}
		local cFrame

		if not v6 then
			cFrame = getCF(clone, data, true) or nil
		end

		v9.CFrame = cFrame
		TweenService:Create(clone, tweenInfo, v9):Play()
		local SIZE22 = data["SIZE 2"]

		if SIZE22 then
			Vector3.new(unpack(string.split(SIZE22)))
		end

		if getVector(data["ALT SIZE 2"]) ~= createVector(-1, -1, -1) then
			local TIME3 = tonumber(data.TIME)
			local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
			local SIZE23 = data["SIZE 2"]

			if SIZE23 then
				Vector3.new(unpack(string.split(SIZE23)))
			end

			TweenService:Create(clone, tweenInfo2, {
				Size = getVector(data["ALT SIZE 2"])
			}):Play()
		end

		table.insert(cleanup, clone)
	end,
	Wedge = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Ball:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Shape = Enum.PartType.Wedge
		clone.Parent = workspace.Effects
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision

		if getVector(data["SIZE 2"]) ~= createVector(-1, -1, -1) then
			clone.Size = getVector(data["SIZE 2"])
		end

		local v6 = getVector(data["ALT POSITION"]) == createVector(0, 0, 0)

		if v6 then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			weld.C0 = CFrame.new() * cframe2 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v11 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v11 = math.clamp(v11, -1e999, 40)
		end

		local v9 = {
			Size = createVector(1, 1, 1) * v11,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"]),
			CFrame = 0
		}
		local cFrame

		if not v6 then
			cFrame = getCF(clone, data, true) or nil
		end

		v9.CFrame = cFrame
		TweenService:Create(clone, tweenInfo, v9):Play()
		local SIZE22 = data["SIZE 2"]

		if SIZE22 then
			Vector3.new(unpack(string.split(SIZE22)))
		end

		if getVector(data["ALT SIZE 2"]) ~= createVector(-1, -1, -1) then
			local TIME3 = tonumber(data.TIME)
			local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
			local SIZE23 = data["SIZE 2"]

			if SIZE23 then
				Vector3.new(unpack(string.split(SIZE23)))
			end

			TweenService:Create(clone, tweenInfo2, {
				Size = getVector(data["ALT SIZE 2"])
			}):Play()
		end

		table.insert(cleanup, clone)
	end,
	Cylinder = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Cylinder:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Parent = workspace.Effects
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision

		if getVector(data["SIZE 2"]) ~= createVector(-1, -1, -1) then
			clone.Size = getVector(data["SIZE 2"])
		end

		local v6 = getVector(data["ALT POSITION"]) == createVector(0, 0, 0)

		if v6 then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			weld.C0 = CFrame.new() * cframe2 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v11 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v11 = math.clamp(v11, -1e999, 40)
		end

		local v9 = {
			Size = createVector(1, 1, 1) * v11,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"]),
			CFrame = 0
		}
		local cFrame

		if not v6 then
			cFrame = getCF(clone, data, true) or nil
		end

		v9.CFrame = cFrame
		TweenService:Create(clone, tweenInfo, v9):Play()
		local SIZE22 = data["SIZE 2"]

		if SIZE22 then
			Vector3.new(unpack(string.split(SIZE22)))
		end

		if getVector(data["ALT SIZE 2"]) ~= createVector(-1, -1, -1) then
			local TIME3 = tonumber(data.TIME)
			local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
			local SIZE23 = data["SIZE 2"]

			if SIZE23 then
				Vector3.new(unpack(string.split(SIZE23)))
			end

			TweenService:Create(clone, tweenInfo2, {
				Size = getVector(data["ALT SIZE 2"])
			}):Play()
		end

		table.insert(cleanup, clone)
	end,
	Glow = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = instance
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = builderFX.Parent.Damage.HitGlow:Clone()
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone:ScaleTo(1.1 * SIZE)
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		for _, parent in clone:GetChildren() do
			local child = instance:FindFirstChild(parent.Name)

			if child then
				if getVector(data["ALT POSITION"]) == createVector(0, 0, 0) then
					local weld = Instance.new("Weld", parent)
					weld.Part0 = parent
					weld.Part1 = child
				else
					parent.Anchored = true
					parent.CFrame = child.CFrame * CFrame.new(getVector(data["ALT POSITION"]))
				end

				local collision = getCollision(data) -- equivalent call inferred; original call site unknown
				parent.CanCollide = collision
			end

			if v3.Name == "HumanoidRootPart" or parent.Name == v3.Name then
				parent.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
				parent.Transparency = tonumber(data.OPACITY)
				local TIME2 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME2 = math.clamp(TIME2, -1e999, 10)
				end

				local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
				local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
				TweenService:Create(parent, TweenInfo.new(TIME2, easingStyle, easingDirection), {
					Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
					Transparency = tonumber(data["ALT OPACITY"])
				}):Play()
			else
				parent.Transparency = 1
			end

			table.insert(cleanup, parent)
		end

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local cFrameValue = Instance.new("CFrameValue", clone)
			cFrameValue.Value = clone.PrimaryPart.CFrame
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(cFrameValue, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				Value = getCF(instance.HumanoidRootPart, data, true)
			}):Play()
			cFrameValue.Changed:Connect(function()
				clone:PivotTo(cFrameValue.Value)
			end)
		end

		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		local v6 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v6 = math.clamp(v6, -1e999, 40)
		end

		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		if v6 ~= SIZE3 then
			local numberValue = Instance.new("NumberValue", clone)
			local SIZE4 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE4 = math.clamp(SIZE4, -1e999, 40)
			end

			numberValue.Value = SIZE4
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
			local SIZE5 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE5 = math.clamp(SIZE5, -1e999, 40)
			end

			local v9 = SIZE5 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v9 = math.clamp(v9, -1e999, 40)
			end

			TweenService:Create(numberValue, tweenInfo, {
				Value = v9
			}):Play()
			numberValue.Changed:Connect(function()
				clone:ScaleTo(numberValue.Value)
			end)
		end
	end,
	Afterimage = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = instance
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = builderFX.Parent.Damage.HitGlow:Clone()
		local scale = instance:GetScale()
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone:ScaleTo(scale * SIZE)
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local flag = false

		for _, child in clone:GetChildren() do
			local child2 = instance:FindFirstChild(child.Name)

			if v3.Name ~= "HumanoidRootPart" then
				child2 = v3
				flag = true
			end

			child.Anchored = true
			child.CFrame = CFrame.new(child2.Position + v3.Parent.HumanoidRootPart.CFrame:VectorToWorldSpace(getVector(data.POSITION))) * (child2.CFrame - child2.Position)
			local collision = getCollision(data) -- equivalent call inferred; original call site unknown
			child.CanCollide = collision
			child.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
			child.Transparency = tonumber(data.OPACITY)
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(child, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				Position = child.Position + v3.Parent.HumanoidRootPart.CFrame:VectorToWorldSpace(getVector(data["ALT POSITION"])),
				Orientation = child.Orientation + getVector(data["ALT ROTATION"]),
				Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
				Transparency = tonumber(data["ALT OPACITY"])
			}):Play()
			local SIZE2 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE2 = math.clamp(SIZE2, -1e999, 40)
			end

			local v7 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v7 = math.clamp(v7, -1e999, 40)
			end

			local SIZE3 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE3 = math.clamp(SIZE3, -1e999, 40)
			end

			if v7 ~= SIZE3 then
				local numberValue = Instance.new("NumberValue", clone)
				local SIZE4 = tonumber(data.SIZE)

				if workspace:GetAttribute("CC1") then
					SIZE4 = math.clamp(SIZE4, -1e999, 40)
				end

				numberValue.Value = SIZE4
				local TIME3 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME3 = math.clamp(TIME3, -1e999, 10)
				end

				local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
				local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
				local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
				local SIZE5 = tonumber(data.SIZE)

				if workspace:GetAttribute("CC1") then
					SIZE5 = math.clamp(SIZE5, -1e999, 40)
				end

				local v10 = SIZE5 * tonumber(data["ALT SIZE"] or 1)

				if workspace:GetAttribute("CC1") then
					v10 = math.clamp(v10, -1e999, 40)
				end

				TweenService:Create(numberValue, tweenInfo2, {
					Value = v10
				}):Play()
				numberValue.Changed:Connect(function()
					clone:ScaleTo(numberValue.Value)
				end)
			end

			table.insert(cleanup, child)

			if flag then
				break
			end
		end
	end,
	["Melee Trail"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part2 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part2, data)
		local clone = builderFX.Parent.Damage.CombatTrail:Clone()
		local v4 = part2.Size * 1.1
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = v4 * SIZE
		local weld = clone.Weld
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		weld.C0 = CFrame.new() * cframe * getRot(nil, data, false)
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Trail.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Trail.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Trail.WidthScale = sizeSequence(clone.Trail.WidthScale.Keypoints, data)
		clone.Weld.Part0 = part2
		clone.Parent = workspace.Effects
		table.insert(cleanup, clone)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local part = Instance.new("Part")
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = true
			part.Size = createVector(0, 0, 0)
			part.CFrame = part2.CFrame
			part.Parent = clone
			clone.Weld.Part0 = part
		end

		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
		local v8 = part2.Size * 1.1
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		local v9 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v9 = math.clamp(v9, -1e999, 40)
		end

		TweenService:Create(clone, tweenInfo, {
			Size = v8 * v9,
			Transparency = tonumber(data["ALT OPACITY"]),
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
		}):Play()
		local weld2 = clone.Weld
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(weld2, TweenInfo.new(TIME2, easingStyle2, easingDirection2), {
			C0 = getCF(nil, data, true)
		}):Play()
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		task.delay(TIME3 or 0.2, function()
			clone.Trail.Enabled = false
			TweenService:Create(clone, TweenInfo.new(0.1), {
				Transparency = 1
			}):Play()
			v:AddItem(clone, 0.2)
		end)
	end,
	Flames = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = instance
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)

		if parent.Name == "HumanoidRootPart" then
			for _, part in instance:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local clone = builderFX.Parent.Damage.Flames:Clone()
				clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
				clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
				local SIZE = tonumber(data.SIZE)

				if workspace:GetAttribute("CC1") then
					SIZE = math.clamp(SIZE, -1e999, 40)
				end

				clone.Size = NumberSequence.new(SIZE)
				local rate = clone.Rate
				local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

				if workspace:GetAttribute("CC1") then
					emit = math.clamp(emit, -1e999, 20)
				end

				clone.Rate = rate * emit
				clone.Parent = part
				table.insert(cleanup, clone)
				local TIME = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME = math.clamp(TIME, -1e999, 10)
				end

				v:AddItem(clone, TIME + 2)
				local TIME2 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME2 = math.clamp(TIME2, -1e999, 10)
				end

				task.delay(TIME2, function()
					if clone.Parent then
						clone.Enabled = false
					end
				end)
			end
		else
			local clone = builderFX.Parent.Damage.Flames:Clone()
			clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
			clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
			local SIZE = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE = math.clamp(SIZE, -1e999, 40)
			end

			clone.Size = NumberSequence.new(SIZE)
			local rate = clone.Rate
			local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			clone.Rate = rate * emit
			clone.Parent = parent
			table.insert(cleanup, clone)
			parent.Destroying:Once(function()
				if clone.Enabled == false then
					return
				end

				local part = Instance.new("Part")
				part.Anchored = true
				part.CanCollide = false
				part.Transparency = 1
				part.Size = createVector(1, 1, 1)
				part.CFrame = parent.CFrame
				part.Parent = workspace.Effects
				clone.Parent = part
				clone.Enabled = false
				v:AddItem(part, 2)
			end)
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			v:AddItem(clone, TIME + 2)
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			task.delay(TIME2, function()
				if clone.Parent then
					clone.Enabled = false
				end
			end)
		end
	end,
	Visibility = function(folder, data)
		local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = folder
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local v4 = true

		for _, descendant in ipairs(folder:GetDescendants()) do
			if not descendant:GetAttribute("NoTransp") then
				continue
			end

			v4 = false
			break
		end

		local v6 = {
			HatAttachment = "Head",
			FaceCenterAttachment = "Head",
			FaceFrontAttachment = "Head",
			HairAttachment = "Head",
			NeckAttachment = "Torso",
			BodyFrontAttachment = "Torso",
			BodyBackAttachment = "Torso",
			BodyLeftAttachment = "Torso",
			BodyRightAttachment = "Torso",
			WaistFrontAttachment = "Torso",
			WaistBackAttachment = "Torso",
			LeftShoulderAttachment = "Left Arm",
			RightShoulderAttachment = "Right Arm"
		}

		if v3.Name == "HumanoidRootPart" then
			for _, descendant in folder:GetDescendants() do
				if not (descendant:IsA("BasePart") or descendant:IsA("Decal")) then
					continue
				end

				if v4 and descendant.Transparency == 1 then
					descendant:SetAttribute("NoTransp", true)
				end

				if descendant:GetAttribute("NoTransp") then
					continue
				end

				descendant.Transparency = tonumber(data.OPACITY)
				local TIME = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME = math.clamp(TIME, -1e999, 10)
				end

				local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
				local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
				TweenService:Create(descendant, TweenInfo.new(TIME, easingStyle, easingDirection), {
					Transparency = tonumber(data["ALT OPACITY"])
				}):Play()
			end
		else
			v3.Transparency = tonumber(data.OPACITY)

			for _, decal in pairs(folder:GetDescendants()) do
				if v6[decal] == v3.Name or decal:IsA("Decal") and decal.Parent == v3 then
					decal.Parent.Transparency = tonumber(data.OPACITY)
				end
			end

			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(v3, TweenInfo.new(TIME, easingStyle, easingDirection), {
				Transparency = tonumber(data["ALT OPACITY"])
			}):Play()

			for _, decal in pairs(folder:GetDescendants()) do
				if not (v6[decal.Name] and v6[decal.Name] == v3.Name or decal:IsA("Decal") and decal.Parent == v3) then
					continue
				end

				local parent = decal.Parent
				local TIME2 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME2 = math.clamp(TIME2, -1e999, 10)
				end

				local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
				local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
				TweenService:Create(parent, TweenInfo.new(TIME2, easingStyle2, easingDirection2), {
					Transparency = tonumber(data["ALT OPACITY"])
				}):Play()
			end
		end
	end,
	Distortion = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = builderFX.Distortion:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (v3 and v3.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = createVector(1, 1, 1) * SIZE
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency += tonumber(data.OPACITY)
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.Parent = clone
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		local v10 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v10 = math.clamp(v10, -1e999, 40)
		end

		TweenService:Create(clone, tweenInfo, {
			Size = createVector(1, 1, 1) * v10,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = 1 + tonumber(data["ALT OPACITY"]),
			CFrame = getPos(v3, data, true)
		}):Play()
		table.insert(cleanup, clone)
	end,
	Ring = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Itadori.CounterHit.Feint.Ring:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.LightEmission = 0
		clone.LightInfluence = 0
		clone.Brightness = 4
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	Sparks = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Itadori.CounterHit.Feint.Sparks:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.LightEmission = 0
		clone.LightInfluence = 0
		clone.Brightness = 4
		local min = clone.Speed.Min
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		local v6 = min * SIZE
		local max = clone.Speed.Max
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		clone.Speed = NumberRange.new(v6, max * SIZE2)
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	Star = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Itadori.CounterHit.Feint.Star:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.LightEmission = 0
		clone.LightInfluence = 0
		clone.Brightness = 4
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	["Energy Sparks"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.RoughHit.Sparks:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		local min = clone.Speed.Min
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		local v6 = min * SIZE
		local max = clone.Speed.Max
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		clone.Speed = NumberRange.new(v6, max * SIZE2)
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	Light = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = tonumber(data.OPACITY)
		pointLight.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		pointLight.Range = SIZE
		pointLight.Parent = attachment
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(pointLight, TweenInfo.new(TIME2, easingStyle, easingDirection), {
			Brightness = tonumber(data["ALT OPACITY"]),
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
		}):Play()
		table.insert(cleanup, attachment)
	end,
	["360 Wind"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.RoughHit.Wind:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	["Circle Glow"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.RoughHit.Glow:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	Beams = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.RoughHit.Wind2:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.LockedToPart = true
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	["Star Outline"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.Indicators.BallFire.Ring:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.LockedToPart = true
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	["Wind Ring"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local attachment = Instance.new("Attachment")
		attachment.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		attachment.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(attachment, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(attachment, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local clone = builderFX.Parent.Hakari.Indicators.BallFire.Wind:Clone()
		clone.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		clone.Lifetime = NumberRange.new(TIME2)
		clone.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Size = sizeSequence(clone.Size.Keypoints, data)
		clone.LockedToPart = true
		clone.Speed = NumberRange.new(0.01)
		clone.Parent = attachment
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		clone:Emit(emit)
		table.insert(cleanup, clone)
	end,
	["Wind Streak"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local clone = builderFX.Parent.Itadori.RushWind.Dash1:Clone()
		clone.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		local dash = clone.Dash
		dash.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		dash.Lifetime = NumberRange.new(TIME2)
		dash.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		dash.Size = sizeSequence(dash.Size.Keypoints, data)
		dash.Parent = clone
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		dash:Emit(emit)
		table.insert(cleanup, dash)
	end,
	["Black Flash"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = builderFX.Parent.Itadori.DivergentFist.BlackFlashHit:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (v3 and v3.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, 0.8 * TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				CFrame = getCF(v3, data, true)
			}):Play()
		end

		for _, emitter in clone:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				if emitter.Name ~= "Wind" then
					emitter.Color = ColorSequence.new(
						Color3.fromRGB(unpack(string.split(data.COLOR))),
						getAltColor(data)
					)
					emitter.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
				end

				local min = emitter.Lifetime.Min
				local TIME2 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME2 = math.clamp(TIME2, -1e999, 10)
				end

				local v7 = min * TIME2
				local max = emitter.Lifetime.Max
				local TIME3 = tonumber(data.TIME)

				if workspace:GetAttribute("CC1") then
					TIME3 = math.clamp(TIME3, -1e999, 10)
				end

				emitter.Lifetime = NumberRange.new(v7, max * TIME3)
				emitter.Size = sizeSequence(emitter.Size.Keypoints, data)
			else
				emitter.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
				local range = emitter.Range
				local SIZE = tonumber(data.SIZE)

				if workspace:GetAttribute("CC1") then
					SIZE = math.clamp(SIZE, -1e999, 40)
				end

				emitter.Range = range * SIZE
			end
		end

		local pointLight = clone.PointLight
		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(1, easingStyle, easingDirection)
		local v9 = {
			Brightness = 0,
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Range = 0
		}
		local range = clone.PointLight.Range
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		local v10 = SIZE * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v10 = math.clamp(v10, -1e999, 40)
		end

		v9.Range = range * v10
		TweenService:Create(pointLight, tweenInfo, v9):Play()
		local blast = clone.Blast
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		blast:Emit(8 * emit)
		local sparks = clone.Sparks
		local emit2 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit2 = math.clamp(emit2, -1e999, 20)
		end

		sparks:Emit(15 * emit2)
		local lightning = clone.Lightning
		local emit3 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit3 = math.clamp(emit3, -1e999, 20)
		end

		lightning:Emit(6 * emit3)
		local wind = clone.Wind
		local emit4 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit4 = math.clamp(emit4, -1e999, 20)
		end

		wind:Emit(7 * emit4)
		table.insert(cleanup, clone)
	end,
	["Wind Expand"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local clone = builderFX.Parent.Megumi.Mahoraga.RitualStart.Attachment:Clone()
		clone.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false) * CFrame.fromOrientation(
			0,
			0,
			1.5707963267948966
		)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		for _, child in clone:GetChildren() do
			child.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			child.Lifetime = NumberRange.new(TIME2)
			child.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
			child.Size = sizeSequence(child.Size.Keypoints, data)
		end

		local ring = clone.Ring
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		ring:Emit(emit)
		local dust = clone.Dust
		local emit2 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit2 = math.clamp(emit2, -1e999, 20)
		end

		dust:Emit(emit2)
		table.insert(cleanup, clone)
	end,
	Shine = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local clone = builderFX.Parent.Megumi.Mahoraga.Cursed.Shine:Clone()
		clone.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false) * CFrame.new(
			0,
			-2,
			0
		)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		clone.Shine.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local shine = clone.Shine
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		shine.Lifetime = NumberRange.new(TIME2)
		clone.Shine.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Shine.Size = sizeSequence(clone.Shine.Size.Keypoints, data)
		local shine2 = clone.Shine
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		shine2:Emit(emit)
		table.insert(cleanup, clone)
	end,
	Clash = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local parent = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(parent, data)
		local clone = builderFX.Parent.Misc.Items.Clash.Attachment:Clone()
		clone.Parent = parent
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.WorldCFrame = (parent and parent.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		clone.PointLight.Enabled = false
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		for _, emitter in pairs(clone:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			emitter.Lifetime = NumberRange.new(TIME2)
			emitter.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
			emitter.Size = sizeSequence(emitter.Size.Keypoints, data)
		end

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle, easingDirection), {
				WorldCFrame = getCF(parent, data, true)
			}):Play()
		end

		for _, light in clone:GetChildren() do
			if light:IsA("PointLight") then
				TweenService:Create(light, TweenInfo.new(light:GetAttribute("Duration")), {
					Brightness = 0
				}):Play()
			else
				local emitCount = light:GetAttribute("EmitCount")
				local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

				if workspace:GetAttribute("CC1") then
					emit = math.clamp(emit, -1e999, 20)
				end

				light:Emit(emitCount * emit)
			end
		end

		table.insert(cleanup, clone)
	end,
	["Weak Lightning"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Parent.Megumi.NueShock:Clone()
		clone.Massless = true
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		clone.Hit.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local hit = clone.Hit
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		hit.Lifetime = NumberRange.new(TIME2)
		clone.Hit.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Hit.Size = sizeSequence(clone.Hit.Size.Keypoints, data)
		clone.Electric.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local electric = clone.Electric
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		electric.Lifetime = NumberRange.new(TIME3)
		clone.Electric.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Electric.Size = sizeSequence(clone.Electric.Size.Keypoints, data)
		local electric2 = clone.Electric
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		electric2.Rate = 20 * emit

		if getVector(data["ALT POSITION"]) == createVector(0, 0, 0) then
			clone.Anchored = false
			local weldConstraint = Instance.new("WeldConstraint", clone)
			weldConstraint.Part0 = part
			weldConstraint.Part1 = clone
		else
			local TIME4 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME4 = math.clamp(TIME4, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME4, easingStyle, easingDirection), {
				CFrame = getCF(part, data, true)
			}):Play()
		end

		local electric3 = clone.Electric
		local TIME4 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME4 = math.clamp(TIME4, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(electric3, TweenInfo.new(TIME4, easingStyle, easingDirection), {
			Rate = 0
		}):Play()
		table.insert(cleanup, clone)
	end,
	Cleave = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = builderFX.Parent.Itadori.MalevolantShrine.Hit:Clone()
		clone.Anchored = true
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (v3 and v3.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		clone.Slash1.Enabled = false
		clone.Slash2.Enabled = false
		clone.Slash1.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local slash1 = clone.Slash1
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		slash1.Lifetime = NumberRange.new(TIME2)
		clone.Slash1.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Slash1.Size = sizeSequence(clone.Slash1.Size.Keypoints, data)
		clone.Slash2.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		local slash2 = clone.Slash2
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		slash2.Lifetime = NumberRange.new(TIME3)
		clone.Slash2.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Slash2.Size = sizeSequence(clone.Slash2.Size.Keypoints, data)

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			clone.Slash1.LockedToPart = true
			clone.Slash2.LockedToPart = true
			local TIME4 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME4 = math.clamp(TIME4, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME4, easingStyle, easingDirection), {
				CFrame = getCF(v3, data, true)
			}):Play()
		end

		local slash12 = clone.Slash1
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		slash12:Emit(emit)
		local slash22 = clone.Slash2
		local emit2 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit2 = math.clamp(emit2, -1e999, 20)
		end

		slash22:Emit(emit2)
		table.insert(cleanup, clone)
	end,
	Dismantle = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		local cFrame = CFrame.new(
			((v3 and v3.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)).Position,
			(getCF(v3, data, true)).Position
		) * getRot(nil, data, false)
		local CF = getCF(v3, data, true) -- equivalent call inferred; original call site unknown
		local clone = builderFX.Parent.Itadori.Dismantle.DismantleFly:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace.Effects
		local size = clone.Size
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone.Size = size * SIZE
		local A1 = clone.A1
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		A1.CFrame = CFrame.new(7.5 * SIZE2, 0, 1)
		local A2 = clone.A2
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		A2.CFrame = CFrame.new(-7.5 * SIZE3, 0, 1)
		local highlight = Instance.new("Highlight", clone)
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillTransparency = 0
		highlight.FillColor = Color3.fromRGB(unpack(string.split(data.COLOR)))
		highlight.OutlineColor = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
		clone.Trail1.Color = ColorSequence.new(
			Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			getAltColor(data)
		)
		clone.Trail2.Color = ColorSequence.new(
			Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			getAltColor(data)
		)
		clone.Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
		task.delay(0, function()
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo = TweenInfo.new(TIME, easingStyle, easingDirection)
			local v14 = data
			local SIZE4 = tonumber(v14.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE4 = math.clamp(SIZE4, -1e999, 40)
			end

			local v15 = SIZE4 * tonumber(v14["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v15 = math.clamp(v15, -1e999, 40)
			end

			TweenService:Create(clone, tweenInfo, {
				Size = createVector(15, 0, 0) * v15,
				CFrame = cFrame + (CF.Position - cFrame.Position)
			}):Play()
			local TIME2 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME2 = math.clamp(TIME2, -1e999, 10)
			end

			local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME2, easingStyle2, easingDirection2), {
				Transparency = tonumber(data["ALT OPACITY"])
			}):Play()
			local A12 = clone.A1
			local TIME3 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME3 = math.clamp(TIME3, -1e999, 10)
			end

			local easingStyle3 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection3 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo2 = TweenInfo.new(TIME3, easingStyle3, easingDirection3)
			local v25 = data
			local SIZE5 = tonumber(v25.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE5 = math.clamp(SIZE5, -1e999, 40)
			end

			local v26 = SIZE5 * tonumber(v25["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v26 = math.clamp(v26, -1e999, 40)
			end

			TweenService:Create(A12, tweenInfo2, {
				CFrame = CFrame.new(7.5 * v26, 0, 1)
			}):Play()
			local A22 = clone.A2
			local TIME4 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME4 = math.clamp(TIME4, -1e999, 10)
			end

			local easingStyle4 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection4 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			local tweenInfo3 = TweenInfo.new(TIME4, easingStyle4, easingDirection4)
			local v32 = data
			local SIZE6 = tonumber(v32.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE6 = math.clamp(SIZE6, -1e999, 40)
			end

			local v33 = SIZE6 * tonumber(v32["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v33 = math.clamp(v33, -1e999, 40)
			end

			TweenService:Create(A22, tweenInfo3, {
				CFrame = CFrame.new(-7.5 * v33, 0, 1)
			}):Play()
			local TIME5 = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME5 = math.clamp(TIME5, -1e999, 10)
			end

			task.wait(TIME5)
			highlight:Destroy()
			clone.Transparency = 1
			task.wait(0.05)
			clone:Destroy()
		end)
		table.insert(cleanup, clone)
	end,
	["Rough Energy"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Parent.Hakari.RoughEnergy:Clone()
		table.insert(cleanup, clone)
		clone.Weld.Part0 = part
		local weld = clone.Weld
		weld.C0 = CFrame.new(getVector(data.POSITION))
		clone.Core.Aura.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Core.Aura.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Core.Aura.Size = sizeSequence(clone.Core.Aura.Size.Keypoints, data)
		clone.Core.Sparks.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Core.Sparks.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Core.Sparks.Size = sizeSequence(clone.Core.Sparks.Size.Keypoints, data)
		clone.Trail.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Trail.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Trail.WidthScale = sizeSequence(clone.Trail.WidthScale.Keypoints, data)
		clone.PointLight.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		local pointLight = clone.PointLight
		local range = pointLight.Range
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		pointLight.Range = range * SIZE
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME + 2)
		local pointLight2 = clone.PointLight
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		TweenService:Create(pointLight2, TweenInfo.new(TIME2 * 0.2), {
			Brightness = 5
		}):Play()
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		task.wait(TIME3 * 0.8)
		clone.Core.Aura.Enabled = false
		clone.Core.Sparks.Enabled = false
		local TIME4 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME4 = math.clamp(TIME4, -1e999, 10)
		end

		task.delay(TIME4 * 0.05, function()
			clone.Trail.Enabled = false
		end)
		local pointLight3 = clone.PointLight
		local TIME5 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME5 = math.clamp(TIME5, -1e999, 10)
		end

		TweenService:Create(pointLight3, TweenInfo.new(TIME5 * 0.2), {
			Brightness = 0
		}):Play()
	end,
	["Cursed Energy"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Parent.Itadori.DivergentFist.DivergentFist:Clone()
		table.insert(cleanup, clone)
		clone.Weld.Part0 = part
		local weld = clone.Weld
		weld.C0 = CFrame.new(getVector(data.POSITION))
		clone.Core.Aura.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Core.Aura.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Core.Aura.Size = sizeSequence(clone.Core.Aura.Size.Keypoints, data)
		clone.Core.Sparks.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Core.Sparks.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Core.Sparks.Size = sizeSequence(clone.Core.Sparks.Size.Keypoints, data)
		clone.Trail.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
		clone.Trail.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
		clone.Trail.WidthScale = sizeSequence(clone.Trail.WidthScale.Keypoints, data)
		clone.PointLight.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		local pointLight = clone.PointLight
		local range = pointLight.Range
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		pointLight.Range = range * SIZE
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME + 2)
		local pointLight2 = clone.PointLight
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		TweenService:Create(pointLight2, TweenInfo.new(TIME2 * 0.2), {
			Brightness = 5
		}):Play()
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		task.wait(TIME3 * 0.8)
		clone.Core.Aura.Enabled = false
		clone.Core.Sparks.Enabled = false
		local TIME4 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME4 = math.clamp(TIME4, -1e999, 10)
		end

		task.delay(TIME4 * 0.05, function()
			clone.Trail.Enabled = false
		end)
		local pointLight3 = clone.PointLight
		local TIME5 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME5 = math.clamp(TIME5, -1e999, 10)
		end

		TweenService:Create(pointLight3, TweenInfo.new(TIME5 * 0.2), {
			Brightness = 0
		}):Play()
	end,
	Burst = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part, data)
		local clone = builderFX.Parent.DashCancel:Clone()
		local model = Instance.new("Model")
		clone.Parent = model
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		model:ScaleTo(SIZE)
		v:AddItem(model, 0.1)
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.CFrame = (part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)
		clone.Parent = workspace.Effects

		if getVector(data["ALT POSITION"]) == createVector(0, 0, 0) then
			clone.Anchored = false
			local motor6D = Instance.new("Motor6D", clone)
			motor6D.Part0 = part
			motor6D.Part1 = clone
			local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
			motor6D.C0 = CFrame.new() * cframe2
			motor6D.C1 = getRot(nil, data, false)
			motor6D.Parent = clone
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(motor6D, TweenInfo.new(TIME, easingStyle, easingDirection), {
				C0 = getPos(nil, data, true),
				C1 = getRot(nil, data, true)
			}):Play()
		else
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
			TweenService:Create(clone, TweenInfo.new(TIME, easingStyle, easingDirection), {
				CFrame = getCF(part, data, true)
			}):Play()
		end

		for _, emitter in pairs(clone:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			emitter.Lifetime = NumberRange.new(TIME)
			emitter.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
			emitter.Size = sizeSequence(emitter.Size.Keypoints, data)
			emitter.LockedToPart = true
		end

		table.insert(cleanup, clone)
		local burst = clone.Burst
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		burst:Emit(8 * emit)
		local sparks = clone.Sparks
		local emit2 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit2 = math.clamp(emit2, -1e999, 20)
		end

		sparks:Emit(20 * emit2)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
	end,
	["Mass Hit"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local clone = builderFX.Parent.Yuki.MassHit:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		local cframe2 = CFrame.lookAt(
			((v3 and v3.CFrame or CFrame.new()) * cframe).Position,
			getPos(v3, data, true).Position
		)

		if getPos(nil, data, true) == createVector(0, 0, 0) then
			cframe2 = v3.CFrame or cframe2
		end

		clone.CFrame = cframe2

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			emitter.Lifetime = NumberRange.new(TIME)
			emitter.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
			emitter.Size = sizeSequence(emitter.Size.Keypoints, data)
		end

		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		for _, emitter in clone:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitCount = emitter:GetAttribute("EmitCount")
			local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			emitter:Emit(emitCount * emit)
		end
	end,
	Beam = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part = RELATIVE or humanoidRootPart
		local clone = builderFX.Beam:Clone()
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		local magnitude = (((part and part.CFrame or CFrame.new()) * cframe * getRot(nil, data, false)).Position - (getCF(
			part,
			data,
			true
		)).Position).Magnitude
		local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
		clone.CFrame = CFrame.lookAt(
			((part and part.CFrame or CFrame.new()) * cframe2 * getRot(nil, data, false)).Position,
			(getCF(part, data, true)).Position
		) * CFrame.new(0, 0, -magnitude / 2)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		clone.Size = Vector3.new(SIZE, SIZE2, magnitude)
		clone.Color = Color3.fromRGB(unpack(string.split(data.COLOR)))
		clone.Transparency = tonumber(data.OPACITY)
		clone.Parent = workspace
		local collision = getCollision(data) -- equivalent call inferred; original call site unknown
		clone.CanCollide = collision
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)

		if getVector(data["ALT POSITION"]) == createVector(0, 0, 0) then
			clone.Massless = true
			clone.Anchored = false
			local weld = Instance.new("Weld")
			weld.Part0 = part
			weld.Part1 = clone
			local vector4 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe3 = CFrame.new(-vector4.X, vector4.Y, -vector4.Z)
			weld.C0 = CFrame.new() * cframe3 * getRot(nil, data, false)
			weld.Parent = clone
		end

		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v9 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v9 = math.clamp(v9, -1e999, 40)
		end

		local SIZE4 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE4 = math.clamp(SIZE4, -1e999, 40)
		end

		local v10 = SIZE4 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v10 = math.clamp(v10, -1e999, 40)
		end

		TweenService:Create(clone, tweenInfo, {
			Size = Vector3.new(v9, v10, magnitude),
			Color = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
			Transparency = tonumber(data["ALT OPACITY"])
		}):Play()
	end,
	["Shake Light"] = function(p, p2)
		if RunService:IsServer() then
			return
		end

		if localPlayer.Character == p then
			local emit = getEmit(p2, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			for _ = 1, math.clamp(emit, -1e999, 10000) do
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end
	end,
	["Shake Medium"] = function(p, p2)
		if RunService:IsServer() then
			return
		end

		if localPlayer.Character == p then
			local emit = getEmit(p2, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			for _ = 1, math.clamp(emit, -1e999, 10000) do
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
			end
		end
	end,
	["Shake Heavy"] = function(p, p2)
		if RunService:IsServer() then
			return
		end

		if localPlayer.Character == p then
			local emit = getEmit(p2, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			for _ = 1, math.clamp(emit, -1e999, 10000) do
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end
	end,
	Blood = function(RELATIVE, data)
		if RunService:IsServer() then
			return
		end

		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		for _ = 1, emit do
			local cFrame = v3.CFrame
			local SIZE = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE = math.clamp(SIZE, -1e999, 40)
			end

			local halfSIZE = SIZE / 2
			local SIZE2 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE2 = math.clamp(SIZE2, -1e999, 40)
			end

			BloodyZee:Blood(cFrame, math.random(halfSIZE, SIZE2), 360, 360)
		end
	end,
	Camera = function(instance, data)
		if RunService:IsServer() then
			return
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = instance
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)

		if localPlayer.Character == instance then
			local currentCamera = workspace.CurrentCamera
			local _ = currentCamera.CFrame
			local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
			local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
			local v5 = CFrame.new() * cframe * getRot(nil, data, false)
			local v6

			if getVector(data["ALT POSITION"]) == createVector(0, 0, 0) then
				v6 = nil
			else
				v6 = getCF(nil, data, true) or nil
			end

			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local lastTime = tick()
			currentCamera:SetAttribute("CameraStart", lastTime)
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = "Cutscene"
			numberValue.Parent = currentCamera
			table.insert(cleanup, numberValue)
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(_)
				if v3.Parent ~= nil then
					local v7 = tick() - lastTime
					local TIME2 = tonumber(data.TIME)

					if workspace:GetAttribute("CC1") then
						TIME2 = math.clamp(TIME2, -1e999, 10)
					end

					if not (TIME2 < v7) and numberValue.Parent ~= nil then
						if currentCamera:GetAttribute("CameraStart") ~= lastTime then
							return
						end

						local v8 = v5

						if v6 then
							local v10 = (tick() - lastTime) / TIME
							local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
							local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
							v8 = v5:Lerp(v6, (TweenService:GetValue(v10, easingStyle, easingDirection)))
						end

						currentCamera.CFrame = v3.CFrame * v8
						currentCamera.CameraType = Enum.CameraType.Scriptable
						return
					end
				end

				renderSteppedConnection:Disconnect()
				currentCamera.CameraType = Enum.CameraType.Custom
				currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
				numberValue:Destroy()
			end)
			numberValue.AncestryChanged:Connect(function()
				renderSteppedConnection:Disconnect()

				if numberValue.Parent == nil then
					currentCamera.CameraType = Enum.CameraType.Custom
					currentCamera.CameraSubject = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
				end
			end)
		end
	end,
	Billboard = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local cleanup = getCleanup(humanoidRootPart, data)
		local texture = getTexture(data) -- equivalent call inferred; original call site unknown
		local v3 = texture == 0 and 14978581240 or texture
		local clone = builderFX.Parent.Gojo.Dialogue:Clone()
		clone:ClearAllChildren()
		clone.Parent = humanoidRootPart
		local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit = math.clamp(emit, -1e999, 20)
		end

		local v5 = 15 * emit
		local emit2 = getEmit(data, true) -- equivalent call inferred; original call site unknown

		if workspace:GetAttribute("CC1") then
			emit2 = math.clamp(emit2, -1e999, 20)
		end

		clone.Size = UDim2.fromScale(v5, 15 * emit2)
		local vector2 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe = CFrame.new(-vector2.X, vector2.Y, -vector2.Z)
		clone.StudsOffset = Vector3.new(0, 0, (CFrame.new() * cframe).Z)
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://" .. v3
		imageLabel.ImageColor3 = Color3.fromRGB(unpack(string.split(data.COLOR)))
		imageLabel.ImageTransparency = tonumber(data.OPACITY)
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		local v9 = 0.15 * SIZE
		local SIZE2 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE2 = math.clamp(SIZE2, -1e999, 40)
		end

		imageLabel.Size = UDim2.fromScale(v9, 0.15 * SIZE2)
		local vector3 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe2 = CFrame.new(-vector3.X, vector3.Y, -vector3.Z)
		local v11 = (CFrame.new() * cframe2).X / 10 + 0.5
		local vector4 = getVector(data.POSITION) -- equivalent call inferred; original call site unknown
		local cframe3 = CFrame.new(-vector4.X, vector4.Y, -vector4.Z)
		imageLabel.Position = UDim2.fromScale(v11, -(CFrame.new() * cframe3).Y / 10 + 0.5)
		imageLabel.Parent = clone
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		local tweenInfo = TweenInfo.new(TIME2, easingStyle, easingDirection)
		local v13 = {
			ImageTransparency = tonumber(data["ALT OPACITY"]),
			Size = 0,
			Position = 0,
			ImageColor3 = 0
		}
		local SIZE3 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE3 = math.clamp(SIZE3, -1e999, 40)
		end

		local v15 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v15 = math.clamp(v15, -1e999, 40)
		end

		local v16 = 0.15 * v15
		local SIZE4 = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE4 = math.clamp(SIZE4, -1e999, 40)
		end

		local v18 = SIZE4 * tonumber(data["ALT SIZE"] or 1)

		if workspace:GetAttribute("CC1") then
			v18 = math.clamp(v18, -1e999, 40)
		end

		v13.Size = UDim2.fromScale(v16, 0.15 * v18)
		v13.Position = UDim2.fromScale(getPos(nil, data, true).X / 10 + 0.5, getPos(nil, data, true).Y / 10 + 0.5)
		v13.ImageColor3 = Color3.fromRGB(unpack(string.split(data["ALT COLOR"])))
		TweenService:Create(imageLabel, tweenInfo, v13):Play()
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(clone, TweenInfo.new(TIME3, easingStyle2, easingDirection2), {
			StudsOffset = Vector3.new(0, 0, getPos(nil, data, true).Z)
		}):Play()
		table.insert(cleanup, clone)
	end,
	["Screen Color"] = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if localPlayer.Character == instance then
			local cleanup = getCleanup(humanoidRootPart, data)
			local emit = getEmit(data, true) -- equivalent call inferred; original call site unknown

			if workspace:GetAttribute("CC1") then
				emit = math.clamp(emit, -1e999, 20)
			end

			local transparency = getTransparency(data) -- equivalent call inferred; original call site unknown
			local SIZE = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE = math.clamp(SIZE, -1e999, 40)
			end

			local color = getColor(data) -- equivalent call inferred; original call site unknown
			local altColor = getAltColor(data) -- equivalent call inferred; original call site unknown
			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = game.Lighting
			colorCorrectionEffect.Brightness = emit
			colorCorrectionEffect.Saturation = transparency
			colorCorrectionEffect.Contrast = SIZE
			colorCorrectionEffect.TintColor = color
			local tweenInfo = TweenInfo.new(TIME)
			local v4 = {
				Saturation = tonumber(data["ALT OPACITY"]),
				Contrast = 0,
				TintColor = 0
			}
			local SIZE2 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE2 = math.clamp(SIZE2, -1e999, 40)
			end

			local contrast = SIZE2 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				contrast = math.clamp(contrast, -1e999, 40)
			end

			v4.Contrast = contrast
			v4.TintColor = altColor
			TweenService:Create(colorCorrectionEffect, tweenInfo, v4):Play()
			v:AddItem(colorCorrectionEffect, TIME)
			table.insert(cleanup, colorCorrectionEffect)
		end
	end,
	Overlay = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if localPlayer.Character == instance then
			local cleanup = getCleanup(humanoidRootPart, data)
			local texture = getTexture(data) -- equivalent call inferred; original call site unknown

			if texture == 0 then
				return
			end

			local TIME = tonumber(data.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local clone = builderFX.Parent.Todo.Woah:Clone()
			table.insert(cleanup, clone)
			clone.ImageLabel.Image = "rbxassetid://" .. texture
			clone.ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			clone.ImageLabel.Position = UDim2.fromScale(0.5, 0.5)
			local imageLabel = clone.ImageLabel
			local SIZE = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE = math.clamp(SIZE, -1e999, 40)
			end

			local SIZE2 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE2 = math.clamp(SIZE2, -1e999, 40)
			end

			imageLabel.Size = UDim2.fromScale(SIZE, SIZE2)
			clone.ImageLabel.ImageTransparency = tonumber(data.OPACITY)
			clone.ImageLabel.ImageColor3 = Color3.fromRGB(unpack(string.split(data.COLOR)))
			clone.Parent = localPlayer.PlayerGui
			v:AddItem(clone, TIME)
			local imageLabel2 = clone.ImageLabel
			local tweenInfo = TweenInfo.new(TIME)
			local v4 = {
				ImageColor3 = Color3.fromRGB(unpack(string.split(data["ALT COLOR"]))),
				ImageTransparency = tonumber(data["ALT OPACITY"]),
				Size = 0
			}
			local SIZE3 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE3 = math.clamp(SIZE3, -1e999, 40)
			end

			local v5 = SIZE3 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v5 = math.clamp(v5, -1e999, 40)
			end

			local SIZE4 = tonumber(data.SIZE)

			if workspace:GetAttribute("CC1") then
				SIZE4 = math.clamp(SIZE4, -1e999, 40)
			end

			local v6 = SIZE4 * tonumber(data["ALT SIZE"] or 1)

			if workspace:GetAttribute("CC1") then
				v6 = math.clamp(v6, -1e999, 40)
			end

			v4.Size = UDim2.fromScale(v5, v6)
			TweenService:Create(imageLabel2, tweenInfo, v4):Play()
		end
	end,
	["Field of View"] = function(p, p2)
		if localPlayer.Character == p then
			local fieldOfView = 69 + tonumber(p2.AMOUNT)

			if workspace:GetAttribute("CC1") then
				fieldOfView = math.clamp(fieldOfView, 20, 120)
			end

			local currentCamera = workspace.CurrentCamera
			local TIME = tonumber(p2.TIME)

			if workspace:GetAttribute("CC1") then
				TIME = math.clamp(TIME, -1e999, 10)
			end

			local easingStyle = getEasingStyle(p2) -- equivalent call inferred; original call site unknown
			local easingDirection = getEasingDirection(p2) -- equivalent call inferred; original call site unknown
			TweenService:Create(currentCamera, TweenInfo.new(TIME, easingStyle, easingDirection), {
				FieldOfView = fieldOfView
			}):Play()
		end
	end,
	["Whirl Slash"] = function(RELATIVE, data)
		local humanoidRootPart = RELATIVE:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		if data.RELATIVE ~= nil then
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local part2 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(part2, data)
		local clone = builderFX.SlashWhirl:Clone()
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone:ScaleTo(SIZE)
		clone.Weld.Part0 = part2
		local weld = clone.Weld
		weld.C0 = CFrame.new(getVector(data.POSITION))
		local weld2 = clone.Weld
		weld2.C1 = getRot(nil, data, false) * CFrame.Angles(0, 3.141592653589793, 0)
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		local TIME2 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME2 = math.clamp(TIME2, -1e999, 10)
		end

		local timeScale = 1 / TIME2
		local TIME3 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME3 = math.clamp(TIME3, -1e999, 10)
		end

		local v6 = TIME3 * 0.2

		for _, effect in clone:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				effect.Color = ColorSequence.new(Color3.fromRGB(unpack(string.split(data.COLOR))), getAltColor(data))
				effect.Transparency = NumberSequence.new(tonumber(data.OPACITY), (tonumber(data["ALT OPACITY"])))
				effect.TimeScale = timeScale
				effect:Emit(effect:GetAttribute("EmitCount"))
			elseif effect:IsA("Beam") then
				effect.Color = ColorSequence.new(getColor(data))
				effect.Transparency = NumberSequence.new((tonumber(data.OPACITY)))
				TweenService:Create(effect, TweenInfo.new(v6), {
					Width0 = 0,
					Width1 = 0
				}):Play()
				local v7 = effect
				task.delay(v6, function()
					v7.Enabled = false
				end)
			end
		end

		local weld3 = clone.Weld
		local TIME4 = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME4 = math.clamp(TIME4, -1e999, 10)
		end

		local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
		local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
		TweenService:Create(weld3, TweenInfo.new(TIME4, easingStyle, easingDirection), {
			C0 = CFrame.new(getVector(data["ALT POSITION"])),
			C1 = getRot(nil, data, true) * CFrame.Angles(0, 3.141592653589793, 0)
		}):Play()

		if getVector(data["ALT POSITION"]) ~= createVector(0, 0, 0) then
			local part = Instance.new("Part")
			part.Transparency = 1
			part.CanCollide = false
			part.Anchored = true
			part.Size = createVector(0, 0, 0)
			part.CFrame = part2.CFrame
			part.Parent = clone
			clone.Weld.Part0 = part
		end

		table.insert(cleanup, clone)
	end,
	Afterimage2 = function(instance, data)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RELATIVE

		if data.RELATIVE == nil then
			RELATIVE = instance
		else
			RELATIVE = data.RELATIVE
		end

		if not RELATIVE:IsA("BasePart") then
			if RELATIVE:FindFirstChild(data["BODY PART"]) then
				RELATIVE = RELATIVE[data["BODY PART"]]
			else
				RELATIVE = nil
			end
		end

		local v3 = RELATIVE or humanoidRootPart
		local cleanup = getCleanup(v3, data)
		local clone = replicatedStorage.Utils.DomainWarn.Panel.Viewport.Display:Clone()
		pcall(function()
			local FXController = require(localPlayer.PlayerScripts.Controllers.FXController)
			FXController:ApplyCopyOutfit(instance, clone)
		end)
		local scale = instance:GetScale()
		local SIZE = tonumber(data.SIZE)

		if workspace:GetAttribute("CC1") then
			SIZE = math.clamp(SIZE, -1e999, 40)
		end

		clone:ScaleTo(scale * SIZE)
		clone["Left Arm"].FingersL:Destroy()
		clone["Right Arm"].FingersR:Destroy()
		clone.Parent = workspace.Effects
		local TIME = tonumber(data.TIME)

		if workspace:GetAttribute("CC1") then
			TIME = math.clamp(TIME, -1e999, 10)
		end

		v:AddItem(clone, TIME)
		table.insert(cleanup, clone)
		local cFrame = v3.Parent.HumanoidRootPart.CFrame

		for _, child in clone:GetChildren() do
			if child:IsA("Accessory") then
				local basePart = child:FindFirstChildWhichIsA("BasePart", true)

				if basePart then
					basePart.Transparency = tonumber(data.OPACITY)
					local TIME2 = tonumber(data.TIME)

					if workspace:GetAttribute("CC1") then
						TIME2 = math.clamp(TIME2, -1e999, 10)
					end

					local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
					local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
					TweenService:Create(basePart, TweenInfo.new(TIME2, easingStyle, easingDirection), {
						Position = basePart.Position + cFrame:VectorToWorldSpace(getVector(data["ALT POSITION"])),
						Orientation = basePart.Orientation + getVector(data["ALT ROTATION"]),
						Transparency = tonumber(data["ALT OPACITY"])
					}):Play()
				end
			elseif child:IsA("BasePart") and child.Transparency == 0 then
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.Anchored = true
					child.CFrame = CFrame.new(child2.Position + cFrame:VectorToWorldSpace(getVector(data.POSITION))) * (child2.CFrame - child2.Position)
					local collision = getCollision(data) -- equivalent call inferred; original call site unknown
					child.CanCollide = collision
					child.Transparency = tonumber(data.OPACITY)
					local decal = child.Name == "Head" and child:FindFirstChildWhichIsA("Decal")

					if decal then
						decal.Transparency = tonumber(data.OPACITY)
						local TIME2 = tonumber(data.TIME)

						if workspace:GetAttribute("CC1") then
							TIME2 = math.clamp(TIME2, -1e999, 10)
						end

						local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
						local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
						TweenService:Create(decal, TweenInfo.new(TIME2, easingStyle, easingDirection), {
							Transparency = tonumber(data["ALT OPACITY"])
						}):Play()
					end

					local TIME2 = tonumber(data.TIME)

					if workspace:GetAttribute("CC1") then
						TIME2 = math.clamp(TIME2, -1e999, 10)
					end

					local easingStyle = getEasingStyle(data) -- equivalent call inferred; original call site unknown
					local easingDirection = getEasingDirection(data) -- equivalent call inferred; original call site unknown
					TweenService:Create(child, TweenInfo.new(TIME2, easingStyle, easingDirection), {
						Position = child.Position + cFrame:VectorToWorldSpace(getVector(data["ALT POSITION"])),
						Orientation = child.Orientation + getVector(data["ALT ROTATION"]),
						Transparency = tonumber(data["ALT OPACITY"])
					}):Play()
					local SIZE2 = tonumber(data.SIZE)

					if workspace:GetAttribute("CC1") then
						SIZE2 = math.clamp(SIZE2, -1e999, 40)
					end

					local v7 = SIZE2 * tonumber(data["ALT SIZE"] or 1)

					if workspace:GetAttribute("CC1") then
						v7 = math.clamp(v7, -1e999, 40)
					end

					local SIZE3 = tonumber(data.SIZE)

					if workspace:GetAttribute("CC1") then
						SIZE3 = math.clamp(SIZE3, -1e999, 40)
					end

					if v7 ~= SIZE3 then
						local numberValue = Instance.new("NumberValue", clone)
						local SIZE4 = tonumber(data.SIZE)

						if workspace:GetAttribute("CC1") then
							SIZE4 = math.clamp(SIZE4, -1e999, 40)
						end

						numberValue.Value = SIZE4
						local TIME3 = tonumber(data.TIME)

						if workspace:GetAttribute("CC1") then
							TIME3 = math.clamp(TIME3, -1e999, 10)
						end

						local easingStyle2 = getEasingStyle(data) -- equivalent call inferred; original call site unknown
						local easingDirection2 = getEasingDirection(data) -- equivalent call inferred; original call site unknown
						local tweenInfo2 = TweenInfo.new(TIME3, easingStyle2, easingDirection2)
						local SIZE5 = tonumber(data.SIZE)

						if workspace:GetAttribute("CC1") then
							SIZE5 = math.clamp(SIZE5, -1e999, 40)
						end

						local v10 = SIZE5 * tonumber(data["ALT SIZE"] or 1)

						if workspace:GetAttribute("CC1") then
							v10 = math.clamp(v10, -1e999, 40)
						end

						TweenService:Create(numberValue, tweenInfo2, {
							Value = v10
						}):Play()
						numberValue.Changed:Connect(function()
							clone:ScaleTo(numberValue.Value)
						end)
					end

					table.insert(cleanup, child)
				end
			end
		end
	end
}