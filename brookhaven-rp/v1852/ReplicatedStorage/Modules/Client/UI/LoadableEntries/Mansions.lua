local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local Mansions = {
	Entries = {
		{
			Name = "016_Mansion",
			Icon = "rbxassetid://121644522415376",
			Item = "FuturisticMansion",
			Filter = "Home"
		},
		{
			Name = "015_Mansion",
			Icon = "rbxassetid://137162281719740",
			Item = "CastleMansion",
			Filter = "Special"
		},
		{
			Name = "014_Mansion",
			Icon = "rbxassetid://86191076891352",
			Item = "RoseGoldMansion",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://10897956727",
			Name = "001_Mansion",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://10897956490",
			IsSelected = true,
			Name = "002_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://11107864934",
			Name = "003_Mansion",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://11765627931",
			Name = "004_Mansion",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://12805013135",
			IsSelected = true,
			Name = "005_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://13770312308",
			IsSelected = true,
			Name = "006_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://14684332067",
			Name = "007_Mansion",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://16808127700",
			Name = "008_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://97277054221868",
			IsSelected = true,
			Name = "009_Mansion",
			Filter = "Special"
		},
		{
			Icon = "rbxassetid://98647855600924",
			IsSelected = true,
			Name = "010_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://132405990975582",
			IsSelected = true,
			Name = "011_Mansion",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://114575988103391",
			Name = "012_Mansion",
			Filter = "Home"
		},
		{
			Name = "013_Mansion",
			Item = "CherryBlossomMansion",
			Icon = "rbxassetid://123051532816486"
		}
	},
	Setup = function(instance, data)
		instance.Name = data.Name
		local icon = instance.Icon

		if data.Icon ~= nil then
			icon.Image = data.Icon
		end

		local silver = instance.Silver

		if data.IsPremium then
			silver.Visible = true
		else
			silver:Destroy()
		end

		local VIP = instance.VIP

		if data.IsVIP then
			VIP.Visible = true
		else
			VIP:Destroy()
		end

		local penthouse = instance.Penthouse

		if data.IsPenthouse then
			penthouse.Visible = true
		else
			penthouse:Destroy()
		end

		local robuxPass = instance:FindFirstChild("RobuxPass")
		local highlightEffect = instance:FindFirstChild("HighlightEffect")
		robuxPass:Destroy()
		highlightEffect:Destroy()
		local selected = instance:FindFirstChild("Selected")
		local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

		if PlayerFlag.IsEnabled("hide-selected") or not data.IsSelected then
			if not selected.Visible then
				selected:Destroy()
			end
		else
			selected.Visible = true
		end

		local cornerIcon = instance:FindFirstChild("CornerIcon")

		if data.CornerIcon then
			cornerIcon.Image = data.CornerIcon
			cornerIcon.Visible = true
		elseif not cornerIcon.Visible then
			cornerIcon:Destroy()
		end
	end,
	IsGamepass = function(_)
		return true
	end
}

function Mansions.FilterEntryValues(data)
	local entries = {}

	for _, entry in Mansions.Entries do
		if not (data.BreadcrumbsFilter == nil or data.BreadcrumbsFilter(entry)) then
			continue
		end

		if data.CurrentCategory == nil then
			if data.CategoryFilter == nil and data.GamepassFilter == nil and entry.Category ~= nil or data.GamepassFilter ~= nil and not data.GamepassFilter(entry) or data.CategoryFilter ~= nil and not data.CategoryFilter(entry) then
				continue
			end
		elseif entry.Category ~= data.CurrentCategory then
			continue
		end

		table.insert(entries, entry)
	end

	return entries
end

function Mansions.GetFilters()
	return {
		Home = true,
		Work = true,
		Special = true
	}
end

function Mansions.GetRenderContext()
	return ItemRenderer.HOUSES_CONTEXT
end

return Mansions