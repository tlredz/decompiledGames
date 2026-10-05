local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CatchFlagsConstants = require(ReplicatedStorage.shared.modules.CatchFlagsConstants)
local Replion = require(ReplicatedStorage.packages.Replion)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local localPlayer = Players.LocalPlayer
local catchFlag = ReplicatedStorage.resources.replicated.instances.general.CatchFlag
local rotation = catchFlag:GetPivot().Rotation
local v = {}
local v2 = {}
local folder = nil
local v3 = 0

local function formatNumberWithCommas(p: number)
	local v4 = tostring((math.floor(p)))

	repeat
		local v5
		v4, v5 = string.gsub(v4, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v5 == 0

	return v4
end

local color = Color3.fromRGB(95, 255, 95)

local function resolveColor(sequence)
	if typeof(sequence) == "Color3" then
		return sequence
	end

	if typeof(sequence) == "ColorSequence" then
		local keypoints = sequence.Keypoints

		if keypoints and #keypoints > 0 then
			return keypoints[1].Value
		end
	end

	return nil
end

local function getRarityColor(p: string?)
	if not p then
		return nil
	end

	local rarity = rarities.Rarities[p]
	local colorGradient = rarity and (rarity.ColorGradient or rarity.Color)
	return colorGradient or nil
end

local function getMutationColor(p: string?)
	if not p then
		return nil
	end

	local v4 = mutations.Mutations and mutations.Mutations[p] or mutations[p]

	if not v4 then
		return nil
	end

	local colorGradient = v4.ColorGradient

	if typeof(colorGradient) ~= "Color3" then
		if typeof(colorGradient) == "ColorSequence" then
			local keypoints = colorGradient.Keypoints

			if keypoints and #keypoints > 0 then
				colorGradient = keypoints[1].Value
			else
				colorGradient = nil
			end
		else
			colorGradient = nil
		end
	end

	if colorGradient then
		return colorGradient
	end

	local color2 = v4.Color

	if typeof(color2) == "Color3" then
		return color2
	end

	if typeof(color2) == "ColorSequence" then
		local keypoints = color2.Keypoints

		if keypoints and #keypoints > 0 then
			return keypoints[1].Value
		end
	end

	colorGradient = nil
	return colorGradient
end

local function applyRarityColor(parent, p)
	local uIGradient = parent:FindFirstChildOfClass("UIGradient")

	if uIGradient then
		uIGradient:Destroy()
	end

	if typeof(p) == "ColorSequence" then
		parent.TextColor3 = Color3.fromRGB(255, 255, 255)
		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Color = p
		uIGradient2.Parent = parent
	elseif typeof(p) == "Color3" then
		parent.TextColor3 = p
	end
end

local function clearFlagGradient(instance)
	for _, surfaceGui in pairs(instance:GetChildren()) do
		if surfaceGui:IsA("SurfaceGui") and surfaceGui.Name == "FlagGradient" then
			surfaceGui:Destroy()
		end
	end
end

local function applyFlagGradient(cube, color2)
	clearFlagGradient(cube)
	cube.Color = Color3.fromRGB(255, 255, 255)

	for _, face in pairs({ Enum.NormalId.Left, Enum.NormalId.Right }) do
		local surfaceGui = Instance.new("SurfaceGui")
		surfaceGui.Name = "FlagGradient"
		surfaceGui.Face = face
		surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surfaceGui.PixelsPerStud = 50
		surfaceGui.LightInfluence = 0
		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BorderSizePixel = 0
		frame.Parent = surfaceGui
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = color2
		uIGradient.Parent = frame
		surfaceGui.Parent = cube
	end
end

local function applyFlagColor(instance, color2)
	local flag = instance:FindFirstChild("Flag")
	local cube = flag and flag:FindFirstChild("Cube")

	if not (cube and cube:IsA("BasePart")) then
		return
	end

	if typeof(color2) == "ColorSequence" then
		applyFlagGradient(cube, color2)
		return
	end

	if typeof(color2) ~= "Color3" then
		clearFlagGradient(cube)
		return
	end

	clearFlagGradient(cube)
	cube.Color = color2
end

local function color3ToRichTextRgb(color2: Color3)
	return string.format(
		"rgb(%d,%d,%d)",
		math.floor(color2.R * 255),
		math.floor(color2.G * 255),
		(math.floor(color2.B * 255))
	)
end

local function colorTag(color2: Color3?, p: string)
	if typeof(color2) == "Color3" then
		return string.format(
			"<font color=\"%s\">%s</font>",
			string.format(
				"rgb(%d,%d,%d)",
				math.floor(color2.R * 255),
				math.floor(color2.G * 255),
				(math.floor(color2.B * 255))
			),
			p
		)
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatChance(chance: number)
	local v4 = 1 / chance
	return string.format("1/%s", (formatNumberWithCommas(v4)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatUsername(p)
	return "@" .. (p.username or p.displayName)
end

local function formatMutations(data)
	local v4 = {}

	if data.shiny then
		table.insert(v4, "Shiny")
	end

	if data.sparkling then
		table.insert(v4, "Sparkling")
	end

	if data.mutation then
		local display = mutations.Mutations[data.mutation] and mutations.Mutations[data.mutation].Display or data.mutation
		local mutation = data.mutation
		local colorGradient

		if mutation then
			local v6 = mutations.Mutations and mutations.Mutations[mutation] or mutations[mutation]

			if v6 then
				colorGradient = v6.ColorGradient

				if typeof(colorGradient) ~= "Color3" then
					if typeof(colorGradient) == "ColorSequence" then
						local keypoints = colorGradient.Keypoints

						if keypoints and #keypoints > 0 then
							colorGradient = keypoints[1].Value
						else
							colorGradient = nil
						end
					else
						colorGradient = nil
					end
				end

				if not colorGradient then
					colorGradient = v6.Color

					if typeof(colorGradient) ~= "Color3" then
						if typeof(colorGradient) == "ColorSequence" then
							local keypoints = colorGradient.Keypoints

							if keypoints and #keypoints > 0 then
								colorGradient = keypoints[1].Value
							else
								colorGradient = nil
							end
						else
							colorGradient = nil
						end
					end
				end
			end
		end

		table.insert(v4, colorTag(colorGradient, display))
	end

	if data.weight then
		local v5

		if data.weight >= 1000 then
			v5 = string.format("%.1fT", data.weight / 1000)
		else
			local v6 = math.floor(data.weight * 10) / 10
			v5 = string.format("%gkg", v6)
		end

		table.insert(v4, colorTag(color, v5))
	end

	if #v4 == 0 then
		return ""
	end

	return string.format("[%s]", table.concat(v4, ", "))
end

local function deterministicRotation(id: string)
	local v4 = 0

	for i = 1, #id do
		v4 = (v4 * 31 + string.byte(id, i)) % 2147483647
	end

	return Random.new(v4):NextNumber(0, 6.283185307179586)
end

local function computeBaseCFrame(p)
	local vector = Vector3.new(p.position[1], p.position[2], p.position[3])
	local v4 = deterministicRotation(p.id)
	return CFrame.new(vector) * CFrame.Angles(0, v4, 0) * rotation
end

local function setBuoyVisible(instance, flag: boolean)
	local buoy = instance:FindFirstChild("Buoy")

	if not buoy then
		return
	end

	for _, descendant in pairs(buoy:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = flag and 0 or 1
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			descendant.Transparency = flag and 0 or 1
		end
	end
end

local function acquireModel()
	local v4 = table.remove(v2)

	if v4 then
		return v4
	end

	return catchFlag:Clone()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseModel(model)
	model.Parent = nil
	table.insert(v2, model)
end

local function applyEntry(instance, data, isGlobal: boolean)
	instance:PivotTo((computeBaseCFrame(data)))
	instance:SetAttribute("IsGlobal", isGlobal)
	instance:SetAttribute("IsSea", data.isSea == true)
	instance:SetAttribute("Chance", data.chance)
	instance:SetAttribute("FlagId", data.id)
	setBuoyVisible(instance, data.isSea == true)
	local info = instance:FindFirstChild("info")

	if not info then
		return
	end

	local v4 = fish[data.fishName]

	if v4 then
		local rarity = v4.Rarity
		local colorGradient

		if rarity then
			local rarity2 = rarities.Rarities[rarity]

			if rarity2 then
				colorGradient = rarity2.ColorGradient or rarity2.Color or nil
			end
		end

		applyFlagColor(instance, colorGradient)
	end

	local fishname = info:FindFirstChild("fishname")
	local mutations2 = info:FindFirstChild("mutations")
	local rarity = info:FindFirstChild("rarity")
	local chance = info:FindFirstChild("chance")
	local username = info:FindFirstChild("username")

	if fishname and fishname:IsA("TextLabel") then
		fishname.Text = data.fishName

		if v4 then
			local rarity2 = v4.Rarity
			local colorGradient

			if rarity2 then
				local rarity3 = rarities.Rarities[rarity2]

				if rarity3 then
					colorGradient = rarity3.ColorGradient or rarity3.Color or nil
				end
			end

			applyRarityColor(fishname, colorGradient)
		end
	end

	if username and username:IsA("TextLabel") then
		username.Text = formatUsername(data)
	end

	if chance and chance:IsA("TextLabel") then
		chance.Text = formatChance(data.chance)
	end

	if mutations2 and mutations2:IsA("TextLabel") then
		mutations2.RichText = true
		mutations2.Text = formatMutations(data)
	end

	if rarity and rarity:IsA("TextLabel") and v4 then
		local rarity2 = v4.Rarity
		rarity.Text = rarity2 or ""
		local colorGradient

		if rarity2 then
			local rarity3 = rarities.Rarities[rarity2]

			if rarity3 then
				colorGradient = rarity3.ColorGradient or rarity3.Color or nil
			end
		end

		applyRarityColor(rarity, colorGradient)
	end
end

local function spawnFlag(item, isGlobal: boolean)
	local model = table.remove(v2) or catchFlag:Clone()
	applyEntry(model, item, isGlobal)
	model.Parent = folder
	local baseCFrame = computeBaseCFrame(item)
	local position = baseCFrame.Position
	v[item.id] = {
		model = model,
		entry = item,
		isGlobal = isGlobal,
		baseCFrame = baseCFrame,
		timeOffset = (position.X + position.Z) * 0.75 / 2,
		vel = CFrame.identity,
		lastUpdate = tick()
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function despawnFlag(p: string)
	local v4 = v[p]

	if not v4 then
		return
	end

	releaseModel(v4.model) -- equivalent call inferred; original call site unknown
	v[p] = nil
end

local function processList(items, isGlobal: boolean, p, position: Vector3)
	local v4 = CatchFlagsConstants.RENDER_RADIUS * CatchFlagsConstants.RENDER_RADIUS

	for _, item in pairs(items) do
		p[item.id] = true

		if (Vector3.new(item.position[1], item.position[2], item.position[3]) - position).Magnitude ^ 2 <= v4 then
			if not v[item.id] then
				spawnFlag(item, isGlobal)
			end
		elseif v[item.id] then
			despawnFlag(item.id) -- equivalent call inferred; original call site unknown
		end
	end
end

local function updateLOD(object)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position
	local v4 = {}

	if SettingsController:GetSettingValue("showCatchFlags") ~= false then
		local serverFlags = object:Get("ServerFlags") or {}
		local globalFlags = object:Get("GlobalFlags") or {}
		processList(serverFlags, false, v4, position)
		processList(globalFlags, true, v4, position)
	end

	for k in pairs(v) do
		if v4[k] then
			continue
		end

		despawnFlag(k) -- equivalent call inferred; original call site unknown
	end
end

local function updateBobbing()
	if SettingsController:GetSettingValue("shownVfx") == "HideAll" then
		return
	end

	local now = tick()

	for _, v4 in pairs(v) do
		if not (v4.entry.isSea and v4.model and v4.model.Parent) then
			continue
		end

		local primaryPart = v4.model.PrimaryPart

		if not primaryPart then
			continue
		end

		local v5 = math.sin((now + v4.timeOffset) / 0.75) * 0.2
		local v6 = v4.baseCFrame + Vector3.new(0, v5, 0)
		local smoothDamp, vel = TweenService:SmoothDamp(
			primaryPart:GetPivot(),
			v6,
			v4.vel,
			0.25,
			nil,
			now - v4.lastUpdate
		)
		primaryPart:PivotTo(smoothDamp)
		v4.vel = vel
		v4.lastUpdate = now
	end
end

return {
	Start = function(_)
		if FischUtils.IsTradePlaza() then
			return
		end

		folder = Instance.new("Folder")
		folder.Name = "CatchFlags"
		folder.Parent = workspace
		task.spawn(function()
			local v4 = Replion.Client:WaitReplion(CatchFlagsConstants.REPLION_CHANNEL)
			RunService.Heartbeat:Connect(function()
				local now = os.clock()

				if now - v3 < CatchFlagsConstants.LOD_UPDATE_INTERVAL then
					return
				end

				v3 = now
				updateLOD(v4)
			end)
			RunService.RenderStepped:Connect(function()
				updateBobbing()
			end)
		end)
	end
}