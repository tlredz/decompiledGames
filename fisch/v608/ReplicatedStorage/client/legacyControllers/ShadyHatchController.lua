local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Trove = require(ReplicatedStorage.packages.Trove)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local flag = false
local maid = Trove.new()

local function setModelTransparency(folder, transparency: number)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture")) then
			continue
		end

		descendant.Transparency = transparency

		if descendant:IsA("BasePart") then
			descendant.CanCollide = transparency == 0
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyOpenState(instance)
	local shadyHatch = instance:WaitForChild("ShadyHatch", 10)
	local shadyHatchOpen = instance:WaitForChild("ShadyHatchOpen", 10)

	if not (shadyHatch and shadyHatchOpen) then
		return
	end

	flag = true
	setModelTransparency(shadyHatch, 1)
	setModelTransparency(shadyHatchOpen, 0)
end

local function openHatch()
	if flag then
		return
	end

	maid:Clean()
	local v = CollectionService:GetTagged("LighthouseHatch")[1]

	if v then
		applyOpenState(v) -- equivalent call inferred; original call site unknown
	end

	maid:Add(CollectionService:GetInstanceAddedSignal("LighthouseHatch"):Connect(function(instance)
		local shadyHatch = instance:WaitForChild("ShadyHatch", 10)
		local shadyHatchOpen = instance:WaitForChild("ShadyHatchOpen", 10)

		if shadyHatch then
			if not shadyHatchOpen then
				return
			end

			flag = true
			setModelTransparency(shadyHatch, 1)
			setModelTransparency(shadyHatchOpen, 0)
		end
	end))
end

return {
	Start = function(_)
		local fetched = legacyLocalPlayerData.fetch()

		if not fetched then
			return
		end

		local cache = fetched:WaitForChild("Cache")

		while not cache:FindFirstChild("Bazaar_LighthousePassed") do
			task.wait()
		end

		local bazaar_LighthousePassed = cache:FindFirstChild("Bazaar_LighthousePassed")

		if bazaar_LighthousePassed.Value then
			openHatch()
		end

		bazaar_LighthousePassed:GetPropertyChangedSignal("Value"):Connect(function()
			if bazaar_LighthousePassed.Value then
				openHatch()
			end
		end)
	end
}