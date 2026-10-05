local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local Signal = require(ReplicatedStorage.SharedUtils.Signal)
local CharacterVisibilityHandler = {}
local v = {}
local v2 = {}
local v3 = false
CharacterVisibilityHandler.VisibilityChanged = Signal.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function computeHidden(instance)
	return v3 or instance:GetAttribute("Hidden") == true
end

function CharacterVisibilityHandler.IsHidden(_, p)
	if p then
		return v[p] == true
	end

	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideInstance(descendant, transparenciesByInstance)
	if descendant:IsA("BasePart") then
		descendant.LocalTransparencyModifier = 1
	elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
		if transparenciesByInstance[descendant] == nil then
			transparenciesByInstance[descendant] = descendant.Transparency
		end

		descendant.Transparency = 1
	end
end

local function showInstance(instance, p)
	if instance:IsA("BasePart") then
		instance.LocalTransparencyModifier = 0
	elseif instance:IsA("Decal") or instance:IsA("Texture") then
		local transparency = p[instance]

		if transparency ~= nil then
			instance.Transparency = transparency
			p[instance] = nil
		end
	end
end

local function applyVisibility(folder, flag: boolean, p)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if flag then
			if descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 1
			elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
				if p[descendant] == nil then
					p[descendant] = descendant.Transparency
				end

				descendant.Transparency = 1
			end
		elseif descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = 0
		elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
			local transparency = p[descendant]

			if transparency ~= nil then
				descendant.Transparency = transparency
				p[descendant] = nil
			end
		end
	end
end

local function addCharacter(instance)
	if v[instance] ~= nil then
		return
	end

	local maid = Maid.new()
	local v4 = {}

	local function refresh()
		local hidden = computeHidden(instance) -- equivalent call inferred; original call site unknown

		if v[instance] == hidden then
			return
		end

		v[instance] = hidden
		applyVisibility(instance, hidden, v4)
		CharacterVisibilityHandler.VisibilityChanged:Fire(instance, hidden)
	end

	v2[instance] = refresh
	maid:GiveTask(instance.DescendantAdded:Connect(function(descendant)
		if v[instance] then
			hideInstance(descendant, v4) -- equivalent call inferred; original call site unknown
		end
	end))
	maid:GiveTask(instance:GetAttributeChangedSignal("Hidden"):Connect(refresh))
	maid:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			maid:Destroy()
		end
	end))
	maid:GiveTask(function()
		v[instance] = nil
		v2[instance] = nil
	end)
	v[instance] = false
	local hidden2 = computeHidden(instance) -- equivalent call inferred; original call site unknown

	if v[instance] == hidden2 then
		return
	end

	v[instance] = hidden2
	applyVisibility(instance, hidden2, v4)
	CharacterVisibilityHandler.VisibilityChanged:Fire(instance, hidden2)
end

function CharacterVisibilityHandler.SetSessionHidden(_, flag: boolean?)
	local v4 = flag == true

	if v3 == v4 then
		return
	end

	v3 = v4

	for _, v5 in pairs(v2) do
		v5()
	end
end

function CharacterVisibilityHandler.IsSessionHidden(_)
	return v3
end

function CharacterVisibilityHandler.Start(_)
	if RunService:IsServer() or script:GetAttribute("Started") then
		return
	end

	script:SetAttribute("Started", true)
	CollectionService:GetInstanceAddedSignal("Character"):Connect(addCharacter)

	for _, v4 in ipairs(CollectionService:GetTagged("Character")) do
		task.spawn(addCharacter, v4)
	end
end

return CharacterVisibilityHandler