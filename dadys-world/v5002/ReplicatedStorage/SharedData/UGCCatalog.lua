local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UGCCatalog = {
	ATTRIBUTE_NAME = "UGCCatalog",
	Default = {
		{
			Name = "AstroHead",
			AssetId = 79022563341016
		},
		{
			Name = "AstroMic",
			AssetId = 18773732657
		},
		{
			Name = "BassiesHead",
			AssetId = 125081022884422
		},
		{
			Name = "Blots_Head",
			AssetId = 71866982666309
		},
		{
			Name = "Bobette_Eve_Sleepers_Head",
			AssetId = 118503121969065
		},
		{
			Name = "Bobettes_Head",
			AssetId = 102051202569720
		},
		{
			Name = "BoxtenHead",
			AssetId = 98943136927429
		},
		{
			Name = "BoxtenKey",
			AssetId = 82943341925852
		},
		{
			Name = "Brightneys_Head",
			AssetId = 111613249756619
		},
		{
			Name = "Brushas_Head",
			AssetId = 73704651081711
		},
		{
			Name = "Coal_Head_Buddy",
			AssetId = 138183486499319
		},
		{
			Name = "Coal_Pretty_Present_Head_Buddy",
			AssetId = 123349463986622
		},
		{
			Name = "CocoasHead",
			AssetId = 137108153070890
		},
		{
			Name = "Connies_Head",
			AssetId = 76498044241214
		},
		{
			Name = "Cosmos_Head",
			AssetId = 123800521140962
		},
		{
			Name = "DandyPetals",
			AssetId = 18266863515
		},
		{
			Name = "Dandys_Head",
			AssetId = 138838310374993
		},
		{
			Name = "Dyles_Head",
			AssetId = 81479287085231
		},
		{
			Name = "Eclipse",
			AssetId = 87002359768549
		},
		{
			Name = "EggsonsHead",
			AssetId = 114893518054820
		},
		{
			Name = "FinnHead",
			AssetId = 77827963534718
		},
		{
			Name = "FlutterAntennae",
			AssetId = 93441112484198
		},
		{
			Name = "FluttersWings",
			AssetId = 89300337943261
		},
		{
			Name = "Flutters_Head",
			AssetId = 133988754936916
		},
		{
			Name = "FlytesAntenna",
			AssetId = 75757642633685
		},
		{
			Name = "FlytesHead",
			AssetId = 79850218626956
		},
		{
			Name = "FlytesWings",
			AssetId = 104162870259735
		},
		{
			Name = "Gigis_Head",
			AssetId = 108020428421447
		},
		{
			Name = "Gingers_HeadMask",
			AssetId = 136880554073398
		},
		{
			Name = "Gingers_Minty_Pine_HeadMask",
			AssetId = 114678762905784
		},
		{
			Name = "GlistenMask",
			AssetId = 130215487554928
		},
		{
			Name = "GoobHead",
			AssetId = 85080406893582
		},
		{
			Name = "GourdyHead",
			AssetId = 81560798801688
		},
		{
			Name = "Looey",
			AssetId = 73036742728156
		},
		{
			Name = "Looeys_Head",
			AssetId = 71806432311115
		},
		{
			Name = "Pebble_1",
			AssetId = 113500829187507
		},
		{
			Name = "Pebble_2",
			AssetId = 73812117463294
		},
		{
			Name = "Pebble_3",
			AssetId = 131047009332283
		},
		{
			Name = "Pebble_Hat_Buddy",
			AssetId = 104085649799842
		},
		{
			Name = "PoppyBow",
			AssetId = 123232839320052
		},
		{
			Name = "Poppys_Head",
			AssetId = 84522490047255
		},
		{
			Name = "RazzleDazzles_Scarf",
			AssetId = 79723100681162
		},
		{
			Name = "Ribecca",
			AssetId = 79925201724414
		},
		{
			Name = "Rodgers_HeadMask",
			AssetId = 85463610644116
		},
		{
			Name = "Rudie_Bluebells_Head",
			AssetId = 126444833694274
		},
		{
			Name = "Rudies_Head",
			AssetId = 136942167297205
		},
		{
			Name = "Scraps_Head",
			AssetId = 138359582278765
		},
		{
			Name = "Shellys_Head",
			AssetId = 137967093713860
		},
		{
			Name = "ShrimpoHead",
			AssetId = 115787898809301
		},
		{
			Name = "Soulvester",
			AssetId = 92535715618451
		},
		{
			Name = "SproutHair",
			AssetId = 18773889831
		},
		{
			Name = "SproutScarf",
			AssetId = 18773846035
		},
		{
			Name = "Sprouts_Head",
			AssetId = 116633986393518
		},
		{
			Name = "Squirms_Head",
			AssetId = 88397015244407
		},
		{
			Name = "Squirms_Neck",
			AssetId = 97650188439982
		},
		{
			Name = "Teagans_Head",
			AssetId = 93682509155744
		},
		{
			Name = "Tishas_Head",
			AssetId = 88593702760459
		},
		{
			Name = "Toodles_Head",
			AssetId = 75692252211426
		},
		{
			Name = "VeeHead",
			AssetId = 18774346841
		},
		{
			Name = "VeeMic",
			AssetId = 18773631613
		},
		{
			Name = "Vees_Antennae",
			AssetId = 98063449865917
		},
		{
			Name = "Vees_Bow_tie",
			AssetId = 122481973678259
		},
		{
			Name = "Yatta",
			AssetId = 125192800417760
		},
		{
			Name = "Yatta_2",
			AssetId = 102029823247309
		}
	}
}

function UGCCatalog.Resolve()
	local result = {}
	local v = {}

	local function add(name, assetId)
		if assetId and not v[assetId] then
			v[assetId] = true
			table.insert(result, {
				Name = name,
				AssetId = assetId
			})
		end
	end

	local namesByAssetId = {}

	for _, v2 in ipairs(UGCCatalog.Default) do
		namesByAssetId[v2.AssetId] = v2.Name
	end

	local attribute = ReplicatedStorage:GetAttribute(UGCCatalog.ATTRIBUTE_NAME)

	if type(attribute) == "string" and attribute ~= "" then
		for k in attribute:gmatch("%d+") do
			local assetId = tonumber(k)
			local name = namesByAssetId[assetId] or "UGC_" .. k

			if not assetId or v[assetId] then
				continue
			end

			v[assetId] = true
			table.insert(result, {
				Name = name,
				AssetId = assetId
			})
		end
	end

	for _, v2 in ipairs(UGCCatalog.Default) do
		local name = v2.Name
		local assetId = v2.AssetId

		if not assetId or v[assetId] then
			continue
		end

		v[assetId] = true
		table.insert(result, {
			Name = name,
			AssetId = assetId
		})
	end

	local merchList = ReplicatedStorage:FindFirstChild("MerchList")

	if not merchList then
		return result
	end

	for _, stringValue in ipairs(merchList:GetChildren()) do
		if not stringValue:IsA("StringValue") then
			continue
		end

		local name = stringValue.Name
		local assetId = tonumber(stringValue.Value)

		if not assetId or v[assetId] then
			continue
		end

		v[assetId] = true
		table.insert(result, {
			Name = name,
			AssetId = assetId
		})
	end

	return result
end

function UGCCatalog.GetChangedSignal()
	return ReplicatedStorage:GetAttributeChangedSignal(UGCCatalog.ATTRIBUTE_NAME)
end

return UGCCatalog