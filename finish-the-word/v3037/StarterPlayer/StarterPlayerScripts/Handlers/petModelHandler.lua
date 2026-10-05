local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local import = _G.import("signalUtil")
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cacheAttribute(instance, attributeName, p)
	if instance:GetAttribute(attributeName) ~= nil then
		return
	end

	instance:SetAttribute(attributeName, p)
end

local function restoreAttribute(instance, attributeName, p)
	local attribute = instance:GetAttribute(attributeName)
	return attribute == nil and p or attribute
end

local function applyVisibility(descendant, enabled)
	if descendant:IsA("BasePart") then
		if enabled then
			local originalLocalTransparencyModifier = descendant:GetAttribute("OriginalLocalTransparencyModifier")
			descendant.LocalTransparencyModifier = originalLocalTransparencyModifier == nil and 0 or originalLocalTransparencyModifier
		else
			cacheAttribute(descendant, "OriginalLocalTransparencyModifier", descendant.LocalTransparencyModifier) -- equivalent call inferred; original call site unknown
			descendant.LocalTransparencyModifier = 1
		end
	elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
		descendant.Enabled = enabled
	elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
		if enabled then
			local originalTransparency = descendant:GetAttribute("OriginalTransparency")
			descendant.Transparency = originalTransparency == nil and 0 or originalTransparency
		else
			cacheAttribute(descendant, "OriginalTransparency", descendant.Transparency) -- equivalent call inferred; original call site unknown
			descendant.Transparency = 1
		end
	end
end

local function setFolderVisible(folder, visibilityState)
	if folder:GetAttribute("VisibilityState") == visibilityState then
		return
	end

	folder:SetAttribute("VisibilityState", visibilityState)

	for _, descendant in ipairs(folder:GetDescendants()) do
		applyVisibility(descendant, visibilityState)
	end
end

local function hideFolder(instance)
	if v[instance] then
		return
	end

	setFolderVisible(instance, false)
	v[instance] = instance.DescendantAdded:Connect(function(descendant)
		applyVisibility(descendant, false)
	end)
end

local function showFolder(p)
	local connection = v[p]

	if connection then
		connection:Disconnect()
		v[p] = nil
	end

	if p.Parent then
		setFolderVisible(p, true)
	end
end

local function petBob()
	for _, v2 in ipairs(CollectionService:GetTagged("bob")) do
		if v2:GetAttribute("PausePetBob") then
			continue
		end

		local name = tonumber(v2.Name) or 1
		local v3 = math.sin(os.clock() * 2.5 + name * 0.6) * 0.35
		local petWeld = v2:FindFirstChild("PetWeld")

		if petWeld then
			petWeld.C0 = v2:GetAttribute("BaseCF") * CFrame.new(0, v3, 0)
		end
	end
end

return {
	Priority = 1,
	Run = function()
		import.onTag("HideRealPets", hideFolder)
		CollectionService:GetInstanceRemovedSignal("HideRealPets"):Connect(showFolder)
		RunService.RenderStepped:Connect(petBob)
	end
}