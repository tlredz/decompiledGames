local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Swords = require(ReplicatedStorage.Shared.ReplicatedInstances.Swords)
local SwordAPI = require(ReplicatedStorage.Shared.SwordAPI)
require(ReplicatedStorage.Common.Utils)
local Trove = require(ReplicatedStorage.Packages.Trove)
return Observers.observeTag("GiveSwordNPC", function(instance)
	workspace:WaitForChild("Spawn", 1000000)
	local maid = Trove.new()
	local v = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function loadAnimation(animation)
		return (maid:Add(instance:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(animation)))
	end

	local function createSword(sword: string)
		local sword2 = Swords:GetSword(sword)

		if not sword2 then
			return
		end

		for _, v2 in SwordAPI:GetAnimations(instance, "Idle", sword2.AnimationType, sword2.SwordType) do
			local animation = loadAnimation(v2) -- equivalent call inferred; original call site unknown
			animation:Play()
			table.insert(v, animation)
		end

		local v2 = Swords:EquipSwordTo(instance, sword, instance:GetAttribute("ScaleSword"))

		if v2 then
			maid:Add(v2)
			v2.Name = "EquippedSword"
		end
	end

	local function cleanAnimations()
		for _, v2 in v do
			if v2.IsPlaying then
				v2:Stop()
			end

			v2:Destroy()
		end

		table.clear(v)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateSword()
		cleanAnimations()
		maid:Clean()
		local sword = instance:GetAttribute("Sword") or instance:GetAttribute("LobbySwordName")

		if sword then
			createSword(sword)
		end
	end

	updateSword() -- equivalent call inferred; original call site unknown
	instance:GetAttributeChangedSignal("Sword"):Connect(updateSword)
	instance:GetAttributeChangedSignal("LobbySwordName"):Connect(updateSword)
	return function()
		cleanAnimations()
		maid:Destroy()
	end
end, { workspace })