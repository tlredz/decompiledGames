local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local color = Color3.fromRGB(56, 145, 255)
local localPlayer = Players.LocalPlayer
local data = Utility.GetData(localPlayer, true)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function show(state, alpha: number)
	state.Alpha = alpha

	for _, v2 in state.Fade do
		v2.Transparency = 1 - alpha
	end

	for _, light in state.Lights do
		light.Enabled = alpha > 0
	end
end

local function track(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Color = color
	part.Material = Enum.Material.Neon
	local v2 = {
		Fade = { part },
		Lights = {},
		Alpha = 0
	}

	for _, child in part:GetChildren() do
		if child:IsA("Decal") or child:IsA("Texture") then
			table.insert(v2.Fade, child)
			child.Color3 = color
		elseif child:IsA("Light") then
			table.insert(v2.Lights, child)
			child.Color = color
		end
	end

	v[part] = v2
	v2.Alpha = 0

	for _, v3 in v2.Fade do
		v3.Transparency = 1
	end

	for _, light in v2.Lights do
		light.Enabled = false
	end
end

for _, v2 in CollectionService:GetTagged("IceveilFootprint") do
	track(v2)
end

CollectionService:GetInstanceAddedSignal("IceveilFootprint"):Connect(track)
CollectionService:GetInstanceRemovedSignal("IceveilFootprint"):Connect(function(p)
	v[p] = nil
end)
local v2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshLit()
	v2 = false

	for _, v3 in Character_info_provider.getEquippedAccessoryStats(localPlayer) do
		if v3 ~= "Mushroom Lit Lantern" then
			continue
		end

		v2 = true
		break
	end
end

local stats = data.Inventory.Accessories.Stats

for _, child in stats:GetChildren() do
	child.Changed:Connect(refreshLit)
end

stats.ChildAdded:Connect(function(child)
	child.Changed:Connect(refreshLit)
	refreshLit() -- equivalent call inferred; original call site unknown
end)
v2 = false

for _, v3 in Character_info_provider.getEquippedAccessoryStats(localPlayer) do
	if v3 ~= "Mushroom Lit Lantern" then
		continue
	end

	v2 = true
	break
end

local humanoidRootPart = nil

local function onCharacter(instance)
	humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
end

localPlayer.CharacterAdded:Connect(onCharacter)
localPlayer.CharacterRemoving:Connect(function()
	humanoidRootPart = nil
end)

if localPlayer.Character ~= nil then
	task.spawn(onCharacter, localPlayer.Character)
end

local v3 = false
RunService.Heartbeat:Connect(function(dt: number)
	local position

	if v2 and humanoidRootPart ~= nil then
		position = humanoidRootPart.Position
	end

	if position == nil and not v3 then
		return
	end

	v3 = false
	local v4 = math.min(dt, 0.1) / 0.6

	for k, v5 in v do
		local v6 = 0

		if position == nil then
			if v5.Alpha == 0 then
				continue
			end
		else
			local vector = k.Position - position
			local dot = vector:Dot(vector)

			if dot >= 3600 then
				if v5.Alpha == 0 then
					continue
				end
			else
				v6 = 1 - math.clamp((math.sqrt(dot) - 40) / 20, 0, 1)
			end
		end

		local alpha = v5.Alpha + math.clamp(v6 - v5.Alpha, -v4, v4)

		if alpha ~= v5.Alpha then
			show(v5, alpha) -- equivalent call inferred; original call site unknown
		end

		if alpha > 0 then
			v3 = true
		end
	end
end)