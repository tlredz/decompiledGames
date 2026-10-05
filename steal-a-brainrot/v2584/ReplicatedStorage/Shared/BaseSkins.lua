local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Index = require(ReplicatedStorage.Datas.Index)
local v = {
	Strawberry = true,
	Meowl = true,
	Skibidi = true,
	Headless = true,
	["John Pork"] = true,
	Spyder = true,
	["1 OF 1"] = true
}
local v2 = {
	Aquatic = "rbxassetid://100987404805977",
	["Bunny Basket"] = "rbxassetid://103854752453800",
	Candy = "rbxassetid://95295980395057",
	Christmas = "rbxassetid://82581266228221",
	Cursed = "rbxassetid://103442397385310",
	Cyber = "rbxassetid://70704569365791",
	Diamond = "rbxassetid://129081602059395",
	Divine = "rbxassetid://123619895457714",
	Easter = "rbxassetid://101004973484528",
	Galaxy = "rbxassetid://106862562813227",
	Gingerbread = "rbxassetid://85315107374050",
	Gold = "rbxassetid://80252148814852",
	Halloween = "rbxassetid://78069578479722",
	Headless = "rbxassetid://127794717088326",
	["John Pork"] = "rbxassetid://103526057900666",
	Lava = "rbxassetid://97577086368828",
	Lucky = "rbxassetid://99633507283702",
	Meowl = "rbxassetid://106055459107464",
	["Pot of Gold"] = "rbxassetid://104285709377050",
	Radioactive = "rbxassetid://102411245785930",
	Rainbow = "rbxassetid://131742943178952",
	Octo = "rbxassetid://117203223532989",
	Rose = "rbxassetid://87697470314885",
	Skibidi = "rbxassetid://115813831981880",
	Spyder = "rbxassetid://119443420474301",
	Strawberry = "rbxassetid://121254385285365",
	Summer = "rbxassetid://121389162032475",
	Taco = "rbxassetid://109613830616820",
	Valentines = "rbxassetid://72064872429166",
	YinYang = "rbxassetid://123280721293513",
	Tralalero = "rbxassetid://128119633310515",
	Crystal = "rbxassetid://126050130581507",
	Eclipse = "rbxassetid://115198805609753",
	["Bee Emperor"] = "rbxassetid://129074613556681",
	["Honey Bee"] = "rbxassetid://79282885156787"
}
local v3 = {
	["Bee Emperor"] = true
}
local v4 = {
	EventBaseSkins = {
		"Honey Bee",
		"Summer",
		"Valentines",
		"Lucky",
		"Taco",
		"Easter"
	},
	PaidBaseSkins = {
		"Gingerbread",
		"Rose",
		"Pot of Gold",
		"Bunny Basket",
		"Octo",
		"Bee Emperor"
	},
	OwnsInData = function(p, p2: string)
		if p2 == "1 OF 1" then
			return false
		end

		if typeof(p.UnlockedBaseSkins) == "table" and p.UnlockedBaseSkins[p2] == true then
			return true
		end

		if typeof(p.BaseSkinInventory) == "table" then
			for _, v5 in p.BaseSkinInventory do
				if typeof(v5) == "table" and v5.SkinName == p2 then
					return true
				end
			end
		end

		return false
	end,
	GetImage = function(p: string)
		local v5 = v2[p]

		if typeof(v5) == "string" and v5 ~= "" then
			return v5
		end

		return nil
	end,
	IsInventoryManaged = function(p: string)
		if p == "Normal" or v[p] then
			return false
		end

		local v5 = Index[p]
		return not (v5 and v5.IsMutation)
	end
}

function v4.IsTradable(p: string)
	return v4.IsInventoryManaged(p) and not v3[p]
end

function v4.GetOwnedEntries(object, p: string)
	local result = {}
	local baseSkinInventory = object:Get("BaseSkinInventory")

	if typeof(baseSkinInventory) ~= "table" then
		return result
	end

	for k, v5 in baseSkinInventory do
		if not (typeof(k) == "string" and typeof(v5) == "table" and v5.SkinName == p) then
			continue
		end

		result[k] = v5
	end

	return result
end

function v4.GetOwnedCount(object, p: string)
	if p == "1 OF 1" then
		return 0
	end

	local count = 0

	for _ in v4.GetOwnedEntries(object, p) do
		count += 1
	end

	if count > 0 then
		return count
	end

	if v4.IsInventoryManaged(p) then
		if object:Get("Migrations.BaseSkinInventory_v1") or not object:Get((`UnlockedBaseSkins.{p}`)) then
			return 0
		end

		return 1
	elseif object:Get((`UnlockedBaseSkins.{p}`)) then
		return 1
	else
		return 0
	end
end

function v4.Owns(p, p2: string)
	return p2 == "Normal" or v4.GetOwnedCount(p, p2) > 0
end

function v4.GetInventoryCount(object)
	local count = 0
	local baseSkinInventory = object:Get("BaseSkinInventory")

	if typeof(baseSkinInventory) ~= "table" then
		return count
	end

	for k, v5 in baseSkinInventory do
		if not (typeof(k) == "string" and typeof(v5) == "table") then
			continue
		end

		count += 1
	end

	return count
end

function v4.Grant(object, skinName: string, source: string?, flag: boolean?)
	if not v4.IsInventoryManaged(skinName) or not flag and next(v4.GetOwnedEntries(object, skinName)) ~= nil then
		return false, nil
	end

	if typeof(object:Get("BaseSkinInventory")) ~= "table" then
		object:Set("BaseSkinInventory", {})
	end

	local GUID = HttpService:GenerateGUID(false)

	while object:Get((`BaseSkinInventory.{GUID}`)) ~= nil do
		GUID = HttpService:GenerateGUID(false)
	end

	object:InsertOnDictionary("BaseSkinInventory", GUID, {
		SkinName = skinName,
		Source = source,
		CreatedAt = DateTime.now().UnixTimestamp
	})
	return true, GUID
end

return table.freeze(v4)