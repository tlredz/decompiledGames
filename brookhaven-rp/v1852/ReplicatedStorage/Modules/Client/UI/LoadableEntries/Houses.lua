local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local NewEstatesSurfacingAbTestController = require(ReplicatedStorage.Modules.Client.Houses.ABTests.NewEstatesSurfacingAbTestController)
local Houses = {}
local v = {
	[4] = "001_Mansion",
	[6] = "016_Mansion",
	[7] = "044_House",
	[9] = "015_Mansion",
	[12] = "014_Mansion",
	[19] = "002_Mansion",
	[26] = "003_Mansion",
	[33] = "004_Mansion",
	[40] = "005_Mansion",
	[47] = "006_Mansion",
	[54] = "007_Mansion",
	[61] = "008_Mansion",
	[68] = "009_Mansion",
	[75] = "010_Mansion",
	[82] = "011_Mansion",
	[89] = "012_Mansion",
	[92] = "013_Mansion"
}
Houses.Entries = {
	{
		Name = "106_House",
		Icon = "rbxassetid://97923673071902",
		Filter = "Home"
	},
	{
		Name = "105_House",
		Icon = "rbxassetid://116481039646192",
		Filter = "Work",
		IsSelected = true,
		IsRobuxPass = true,
		Item = "MilitaryBundle"
	},
	{
		Name = "104_House",
		Icon = "rbxassetid://78034793358471",
		CornerIcon = "rbxassetid://132804664310432",
		Filter = "Home"
	},
	{
		Name = "102_House",
		Icon = "rbxassetid://99962864939003",
		Filter = "Home"
	},
	{
		Name = "103_House",
		Icon = "rbxassetid://140525718082039",
		Filter = "Home",
		Item = "LavenderHousePaid",
		IsPremium = true
	},
	{
		Name = "016_Mansion",
		Icon = "rbxassetid://121644522415376",
		Item = "FuturisticMansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Name = "101_House",
		Icon = "rbxassetid://121277623746710",
		Filter = "Home"
	},
	{
		Name = "098_House",
		Item = "Summer2026PaidHouse"
	},
	{
		Name = "099_House",
		Item = "Summer2026FreeHouse"
	},
	{
		Name = "100_House",
		Icon = "rbxassetid://93250724611592",
		Filter = "Home"
	},
	{
		Name = "015_Mansion",
		Icon = "rbxassetid://137162281719740",
		Item = "CastleMansion",
		Filter = "Special",
		IsEstateSurfacingOnly = true
	},
	{
		Name = "096_House",
		Icon = "rbxassetid://93595855171764",
		Filter = "Home"
	},
	{
		Name = "097_House",
		Icon = "rbxassetid://93161885612693",
		IsPremium = true,
		Filter = "Home",
		Item = "ModernHousePaid"
	},
	{
		Name = "094_House",
		Icon = "rbxassetid://136588578234230",
		Filter = "Home"
	},
	{
		Name = "093_House",
		Item = "Easter2026PaidHouse"
	},
	{
		Icon = "rbxassetid://14101340329",
		Filter = "Home",
		Name = "045_House"
	},
	{
		Icon = "rbxassetid://13884837181",
		Filter = "Home",
		Name = "044_House"
	},
	{
		Icon = "rbxassetid://14475274161",
		IsPremium = true,
		Filter = "Home",
		Name = "047_House"
	},
	{
		Name = "060_House",
		Item = "HouseAndMotorcycleHome"
	},
	{
		Icon = "rbxassetid://14475270736",
		IsSelected = true,
		Filter = "Work",
		Name = "046_House"
	},
	{
		Icon = "rbxassetid://6636125455",
		Filter = "Home",
		Name = "024_House"
	},
	{
		Name = "095_House",
		Icon = "rbxassetid://113237378018276",
		Filter = "Home",
		CornerIcon = "rbxassetid://83709397299167",
		Item = "MinionsHouse"
	},
	{
		Icon = "rbxassetid://12851247314",
		Filter = "Home",
		Name = "040_House"
	},
	{
		Icon = "rbxassetid://7882556216",
		Filter = "Home",
		Name = "032_House"
	},
	{
		Icon = "rbxassetid://11956400373",
		IsPremium = true,
		Filter = "Home",
		Name = "038_House"
	},
	{
		Icon = "rbxassetid://9483190213",
		IsSelected = true,
		Filter = "Work",
		Name = "037_House"
	},
	{
		Icon = "rbxassetid://14976671327",
		Filter = "Home",
		Name = "048_House"
	},
	{
		Icon = "rbxassetid://17588695266",
		IsPremium = true,
		Filter = "Home",
		Name = "054_House"
	},
	{
		Icon = "rbxassetid://17283625400",
		IsSelected = true,
		Filter = "Special",
		Name = "053_House"
	},
	{
		Icon = "rbxassetid://135364038419978",
		IsSelected = true,
		Filter = "Work",
		Name = "057_House"
	},
	{
		Icon = "rbxassetid://4602417295",
		Filter = "Home",
		Name = "001_House"
	},
	{
		Icon = "rbxassetid://4770774093",
		IsPremium = true,
		Filter = "Special",
		Name = "003_House"
	},
	{
		Icon = "rbxassetid://13106511231",
		IsSelected = true,
		Filter = "Special",
		Name = "041_House"
	},
	{
		Icon = "rbxassetid://17588700304",
		Filter = "Home",
		Name = "055_House"
	},
	{
		Icon = "rbxassetid://13831765221",
		IsPremium = true,
		Filter = "Home",
		Name = "043_House"
	},
	{
		Icon = "rbxassetid://8988926737",
		IsSelected = true,
		Filter = "Special",
		Name = "036_House"
	},
	{
		Icon = "rbxassetid://6840773713",
		Filter = "Home",
		Name = "025_House"
	},
	{
		Icon = "rbxassetid://6044271250",
		Filter = "Home",
		Name = "013_House"
	},
	{
		Icon = "rbxassetid://6433142072",
		IsPremium = true,
		Filter = "Home",
		Name = "020_House"
	},
	{
		Icon = "rbxassetid://11954619204",
		IsSelected = true,
		Filter = "Special",
		Name = "039_House"
	},
	{
		Icon = "rbxassetid://13461153676",
		IsSelected = true,
		Filter = "Home",
		Name = "042_House"
	},
	{
		Icon = "rbxassetid://7272900849",
		Filter = "Home",
		Name = "029_House"
	},
	{
		Icon = "rbxassetid://8205114563",
		Filter = "Home",
		Name = "006_House"
	},
	{
		Icon = "rbxassetid://8594010186",
		IsSelected = true,
		Filter = "Home",
		Name = "035_House"
	},
	{
		Icon = "rbxassetid://6299844557",
		Filter = "Home",
		Name = "017_House"
	},
	{
		Icon = "rbxassetid://4826264542",
		IsPremium = true,
		Filter = "Home",
		Name = "008_House"
	},
	{
		Icon = "rbxassetid://8205148481",
		Filter = "Home",
		Name = "010_House"
	},
	{
		Icon = "rbxassetid://7135902616",
		IsSelected = true,
		Filter = "Special",
		Name = "028_House"
	},
	{
		Icon = "rbxassetid://16356953827",
		IsSelected = true,
		Filter = "Work",
		Name = "050_House"
	},
	{
		Icon = "rbxassetid://6606160381",
		IsPremium = true,
		Filter = "Home",
		Name = "022_House"
	},
	{
		Icon = "rbxassetid://4602417542",
		Filter = "Home",
		Name = "002_House"
	},
	{
		Icon = "rbxassetid://4826264115",
		Filter = "Special",
		Name = "007_House"
	},
	{
		Icon = "rbxassetid://6299844458",
		IsPremium = true,
		Filter = "Home",
		Name = "018_House"
	},
	{
		Icon = "rbxassetid://8307446087",
		IsSelected = true,
		Filter = "Work",
		Name = "034_House"
	},
	{
		Icon = "rbxassetid://15343411665",
		IsSelected = true,
		Filter = "Special",
		Name = "049_House"
	},
	{
		Icon = "rbxassetid://6164895570",
		Filter = "Home",
		Name = "015_House"
	},
	{
		Icon = "rbxassetid://8205155235",
		Filter = "Home",
		Name = "005_House"
	},
	{
		Icon = "rbxassetid://5705306511",
		IsPremium = true,
		Filter = "Home",
		Name = "009_House"
	},
	{
		Icon = "rbxassetid://6606160530",
		IsSelected = true,
		Filter = "Special",
		Name = "023_House"
	},
	{
		Icon = "rbxassetid://5916803588",
		Filter = "Home",
		Name = "012_House"
	},
	{
		Icon = "rbxassetid://8205191336",
		IsPremium = true,
		Filter = "Home",
		Name = "004_House"
	},
	{
		Icon = "rbxassetid://6840774286",
		IsSelected = true,
		Filter = "Special",
		Name = "026_House"
	},
	{
		Icon = "rbxassetid://7397407973",
		IsSelected = true,
		Filter = "Work",
		Name = "031_House"
	},
	{
		Icon = "rbxassetid://7272900784",
		IsPremium = true,
		Filter = "Home",
		Name = "030_House"
	},
	{
		Icon = "rbxassetid://16527452677",
		IsSelected = true,
		Filter = "Work",
		Name = "051_House"
	},
	{
		Icon = "rbxassetid://6164895388",
		Filter = "Home",
		Name = "016_House"
	},
	{
		Icon = "rbxassetid://6997854486",
		IsSelected = true,
		Filter = "Home",
		Name = "027_House"
	},
	{
		Icon = "rbxassetid://7882554335",
		IsPremium = true,
		Filter = "Home",
		Name = "033_House"
	},
	{
		Icon = "rbxassetid://6531446459",
		Filter = "Home",
		Name = "021_House"
	},
	{
		Icon = "rbxassetid://17093611240",
		IsSelected = true,
		Filter = "Special",
		Name = "052_House"
	},
	{
		Icon = "rbxassetid://18878221689",
		IsSelected = true,
		Filter = "Special",
		Name = "056_House"
	},
	{
		Icon = "rbxassetid://6044271389",
		IsPremium = true,
		Filter = "Home",
		Name = "014_House"
	},
	{
		Icon = "rbxassetid://5905253921",
		IsPremium = true,
		Filter = "Home",
		Name = "011_House"
	},
	{
		Icon = "rbxassetid://6433141812",
		Filter = "Home",
		Name = "019_House"
	},
	{
		Icon = "rbxassetid://77081544883083",
		Filter = "Home",
		Name = "058_House"
	},
	{
		Icon = "rbxassetid://76945666848362",
		IsSelected = true,
		Filter = "Special",
		Name = "059_House"
	},
	{
		Icon = "rbxassetid://75660695107600",
		IsSelected = true,
		Filter = "Work",
		Name = "061_House"
	},
	{
		Icon = "rbxassetid://95863110183944",
		Filter = "Home",
		Name = "062_House"
	},
	{
		Icon = "rbxassetid://107796696231338",
		Filter = "Special",
		Name = "063_House"
	},
	{
		Icon = "rbxassetid://83019527158949",
		Filter = "Home",
		Name = "064_House"
	},
	{
		Icon = "rbxassetid://133671943426982",
		Filter = "Special",
		IsSelected = true,
		Name = "065_House",
		CornerIcon = "rbxassetid://125759309353396",
		RequirementBehaviorData = {
			Behavior = "Summer2025Purchasables",
			Arguments = { "TreeHouse" }
		}
	},
	{
		Icon = "rbxassetid://106530633967469",
		Filter = "Special",
		IsSelected = true,
		Name = "066_House"
	},
	{
		Icon = "rbxassetid://131895219628399",
		Name = "067_House",
		Filter = "Home",
		IsPremium = true
	},
	{
		Icon = "rbxassetid://140411939271135",
		Filter = "Home",
		Name = "068_House"
	},
	{
		Icon = "rbxassetid://134929469234543",
		Filter = "Home",
		Name = "069_House"
	},
	{
		Icon = "rbxassetid://139986667755450",
		IsPremium = true,
		Name = "070_House",
		Filter = "Home"
	},
	{
		Icon = "rbxassetid://100269568154895",
		Filter = "Work",
		IsSelected = true,
		Name = "071_House"
	},
	{
		Icon = "rbxassetid://134587947254807",
		Filter = "Home",
		Name = "072_House"
	},
	{
		Icon = "rbxassetid://100874311270494",
		Filter = "Home",
		IsPremium = true,
		Name = "073_House"
	},
	{
		Icon = "rbxassetid://75805027214933",
		Filter = "Home",
		Name = "074_House"
	},
	{
		Icon = "rbxassetid://124014452265124",
		IsPremium = false,
		Name = "076_House",
		Filter = "Gamepass",
		Item = "076_House",
		CornerIcon = "rbxassetid://107168567392776"
	},
	{
		Icon = "rbxassetid://110140411813136",
		Item = "Halloween2025FreeHouse",
		Filter = "Home",
		Name = "077_House"
	},
	{
		Icon = "rbxassetid://127639321693613",
		IsCategory = true,
		CategoryDisclaimer = "Brought to you by NBCU",
		Filter = "Home",
		Name = "WickedIntegrationCategory",
		CornerIcon = "rbxassetid://77726165481399"
	},
	{
		Icon = "rbxassetid://109103842308567",
		Name = "078_House",
		CornerIcon = "rbxassetid://77726165481399",
		Category = "WickedIntegrationCategory"
	},
	{
		Icon = "rbxassetid://116077263271251",
		Name = "079_House",
		CornerIcon = "rbxassetid://77726165481399",
		Category = "WickedIntegrationCategory"
	},
	{
		Name = "081_House",
		Item = "ContemporaryHousePaid"
	},
	{
		Name = "082_House",
		Item = "ContemporaryHouseFree"
	},
	{
		Item = "083_House",
		Name = "083_House"
	},
	{
		Name = "084_House",
		Item = "084_House"
	},
	{
		Name = "085_House",
		Icon = "rbxassetid://116070858337598",
		Filter = "Home"
	},
	{
		Name = "086_House",
		Item = "DutchFarmhousePaid",
		IsPremium = true
	},
	{
		Name = "087_House",
		Item = "DutchFarmhouseFree"
	},
	{
		Icon = "rbxassetid://99236302831403",
		Name = "080_House",
		CornerIcon = "rbxassetid://77726165481399",
		Category = "WickedIntegrationCategory"
	},
	{
		Name = "088_House",
		Item = "Olympics2026_OlympicVillaHouse"
	},
	{
		Name = "089_House",
		Item = "SuburbanHousePaid",
		IsPremium = true
	},
	{
		Name = "090_House",
		Icon = "rbxassetid://85211733624159"
	},
	{
		Icon = "rbxassetid://98213741059518",
		Name = "091_House",
		Filter = "Home"
	},
	{
		Name = "092_House",
		Item = "Easter2026FreeHouse"
	},
	{
		Name = "001_Mansion",
		Icon = "rbxassetid://10897956727",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Name = "014_Mansion",
		Icon = "rbxassetid://86191076891352",
		Item = "RoseGoldMansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://10897956490",
		IsSelected = true,
		Name = "002_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://11107864934",
		Name = "003_Mansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://11765627931",
		Name = "004_Mansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://12805013135",
		IsSelected = true,
		Name = "005_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://13770312308",
		IsSelected = true,
		Name = "006_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://14684332067",
		Name = "007_Mansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://16808127700",
		Name = "008_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://97277054221868",
		IsSelected = true,
		Name = "009_Mansion",
		Filter = "Special",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://98647855600924",
		IsSelected = true,
		Name = "010_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://132405990975582",
		IsSelected = true,
		Name = "011_Mansion",
		Filter = "Work",
		IsEstateSurfacingOnly = true
	},
	{
		Icon = "rbxassetid://114575988103391",
		Name = "012_Mansion",
		Filter = "Home",
		IsEstateSurfacingOnly = true
	},
	{
		Name = "013_Mansion",
		Item = "CherryBlossomMansion",
		Icon = "rbxassetid://123051532816486",
		IsEstateSurfacingOnly = true
	},
	{
		Name = "075_House",
		Item = "EmptyPlot",
		Icon = "rbxassetid://76440510365007",
		Filter = "Home"
	}
}

local function passesStandardFilters(entry, breadcrumbsFilter, currentCategory: string?, categoryFilter, gamepassFilter)
	if breadcrumbsFilter ~= nil and not breadcrumbsFilter(entry) then
		return false
	end

	if currentCategory == nil then
		if categoryFilter == nil and gamepassFilter == nil and entry.Category ~= nil or gamepassFilter ~= nil and not gamepassFilter(entry) or categoryFilter ~= nil and not categoryFilter(entry) then
			return false
		end
	elseif entry.Category ~= currentCategory then
		return false
	end

	return true
end

function Houses.BuildSurfacingOrder(items)
	local v2 = {}

	for _, item in items do
		v2[item.Name] = item
	end

	local v3 = {}

	for _, item in items do
		if item.IsEstateSurfacingOnly ~= true and item.Name ~= "044_House" then
			table.insert(v3, item)
		end
	end

	local result = {}

	for i = 1, 92 do
		local v4 = v[i]

		if v4 == nil then
			if #v3 > 0 then
				table.insert(result, table.remove(v3, 1))
			end
		else
			local v5 = v2[v4]

			if v5 ~= nil then
				table.insert(result, v5)
			end
		end
	end

	for _, v4 in v3 do
		table.insert(result, v4)
	end

	return result
end

function Houses.FilterEntryValues(data)
	local entries = {}

	for _, entry in Houses.Entries do
		if passesStandardFilters(
			entry,
			data.BreadcrumbsFilter,
			data.CurrentCategory,
			data.CategoryFilter,
			data.GamepassFilter
		) then
			table.insert(entries, entry)
		end
	end

	if NewEstatesSurfacingAbTestController.IsReady() and NewEstatesSurfacingAbTestController.IsSurfacingEnabled() then
		return Houses.BuildSurfacingOrder(entries)
	end

	local result = {}

	for _, v2 in entries do
		if v2.IsEstateSurfacingOnly ~= true then
			table.insert(result, v2)
		end
	end

	return result
end

function Houses:Setup(data)
	self.Name = data.Name

	if data.Icon ~= nil then
		self.Icon.Image = data.Icon
	end

	local silver = self.Silver

	if data.IsPremium then
		silver.Visible = true
	else
		silver:Destroy()
	end

	local penthouse = self.Penthouse

	if data.IsPenthouse then
		penthouse.Visible = true
	else
		penthouse:Destroy()
	end

	local VIP = self.VIP

	if data.IsVIP then
		VIP.Visible = true
	else
		VIP:Destroy()
	end

	self:FindFirstChild("HighlightEffect"):Destroy()
	local selected = self:FindFirstChild("Selected")
	local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

	if PlayerFlag.IsEnabled("hide-selected") or not data.IsSelected then
		if not selected.Visible then
			selected:Destroy()
		end
	else
		selected.Visible = true
	end

	local cornerIcon = self:FindFirstChild("CornerIcon")

	if data.IsEstateSurfacingOnly == true then
		self:SetAttribute("IsEstateEntry", true)
		cornerIcon.Image = "rbxthumb://type=Asset&id=10839391754&w=150&h=150"
		cornerIcon.Visible = true
	elseif data.CornerIcon then
		cornerIcon.Image = data.CornerIcon
		cornerIcon.Visible = true
	elseif not cornerIcon.Visible then
		cornerIcon:Destroy()
	end
end

function Houses.IsGamepass(data)
	if data.IsEstateSurfacingOnly == true then
		return true
	end

	return data.IsPremium == true or data.Filter == "Gamepass" or data.IsRobuxPass == true
end

function Houses.GetRenderContext()
	return ItemRenderer.HOUSES_CONTEXT
end

return Houses