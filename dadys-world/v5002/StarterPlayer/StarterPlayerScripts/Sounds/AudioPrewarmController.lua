local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function onTwistedAdded(p)
	if v[p] then
		return
	end

	local v2 = "Sounds.Twisted." .. p.Name:gsub("Monster$", "")
	v[p] = v2
	Audio:Prewarm(v2)
end

local function onTwistedRemoved(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	v[p] = nil
	Audio:Release(v2)
end

CollectionService:GetInstanceAddedSignal("Twisted"):Connect(onTwistedAdded)
CollectionService:GetInstanceRemovedSignal("Twisted"):Connect(onTwistedRemoved)

for _, v2 in ipairs(CollectionService:GetTagged("Twisted")) do
	onTwistedAdded(v2) -- equivalent call inferred; original call site unknown
end

local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function warmCharacter(instance)
	if v2[instance] then
		return
	end

	local toonName = instance:GetAttribute("ToonName")

	if not toonName or toonName == "" then
		return
	end

	v2[instance] = "Sounds.Toon." .. toonName
	Audio:Prewarm(v2[instance])
	local connection = v3[instance]

	if connection then
		connection:Disconnect()
		v3[instance] = nil
	end
end

local function onCharacterAdded(character)
	warmCharacter(character) -- equivalent call inferred; original call site unknown

	if v2[character] or v3[character] then
		return
	end

	v3[character] = character:GetAttributeChangedSignal("ToonName"):Connect(function()
		local v4 = character

		if v2[v4] then
			return
		end

		local toonName = v4:GetAttribute("ToonName")

		if toonName then
			if toonName == "" then
				return
			end

			v2[v4] = "Sounds.Toon." .. toonName
			Audio:Prewarm(v2[v4])
			local connection = v3[v4]

			if connection then
				connection:Disconnect()
				v3[v4] = nil
			end
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacterRemoving(character)
	local connection = v3[character]

	if connection then
		connection:Disconnect()
		v3[character] = nil
	end

	local v4 = v2[character]

	if not v4 then
		return
	end

	v2[character] = nil
	Audio:Release(v4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchPlayer(player)
	player.CharacterAdded:Connect(onCharacterAdded)
	player.CharacterRemoving:Connect(onCharacterRemoving)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(player)
	if player.Character then
		onCharacterRemoving(player.Character) -- equivalent call inferred; original call site unknown
	end
end)

for _, v4 in ipairs(Players:GetPlayers()) do
	watchPlayer(v4) -- equivalent call inferred; original call site unknown
end