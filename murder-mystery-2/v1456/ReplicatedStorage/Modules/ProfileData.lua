local ReplicatedStorage = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Inventory")
local v

repeat
	v = inventory:WaitForChild("GetProfileData"):InvokeServer()
	task.wait(0.1)
until v ~= nil

local profileDataChanged = inventory:WaitForChild("ProfileDataChanged")
local inventoryDataChanged = inventory:WaitForChild("InventoryDataChanged")
local updateDataClient = ReplicatedStorage:WaitForChild("UpdateDataClient")
local v2 = {
	Weapons = true,
	Pets = true,
	Materials = true
}

local function LegacyConvertToysToEmotes()
	for _, v3 in v.Toys.Owned do
		if not table.find(v.Emotes.Owned, v3) then
			table.insert(v.Emotes.Owned, v3)
		end
	end
end

local function LegacyUpdate()
	LegacyConvertToysToEmotes()
end

local function onProfileDataChanged(p: string, p2)
	v[p] = p2
	profileDataChanged:Fire(p, p2)
end

local function onInventoryItemChanged(p: string, p2: string, p3: number)
	if v2[p] then
		v[p].Owned[p2] = p3
	elseif p3 ~= nil and p3 > 0 then
		table.insert(v[p].Owned, p2)
	end

	LegacyConvertToysToEmotes()
	inventoryDataChanged:Fire(p, p2, p3)
	updateDataClient:Fire(false, v)
end

LegacyConvertToysToEmotes()
inventory:WaitForChild("ChangeProfileData").OnClientEvent:Connect(onProfileDataChanged)
inventory:WaitForChild("ChangeInventoryItem").OnClientEvent:Connect(onInventoryItemChanged)
_G.UpdateEmotes = LegacyConvertToysToEmotes
return v