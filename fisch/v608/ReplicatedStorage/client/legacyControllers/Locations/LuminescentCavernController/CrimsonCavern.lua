local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)

local function onClearContentFound(instance)
	instance:Destroy()
end

local CrimsonCavern = {}
CrimsonCavern.Unlocked = false

function CrimsonCavern.Init(p)
	p.Unlocked = false
end

function CrimsonCavern.OnUnlocked(p)
	p.Unlocked = true
	local tagged = CollectionService:GetTagged(LuminescentCavern.Enums.CollectionService.DeleteForCrimsonCavern)

	for _, v in tagged do
		v:Destroy()
	end

	CollectionService:GetInstanceAddedSignal(LuminescentCavern.Enums.CollectionService.DeleteForCrimsonCavern):Connect(onClearContentFound)
end

return CrimsonCavern