local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Apartments = {
	Entries = {
		{
			Icon = "rbxassetid://7056774047",
			Name = "0001_Apartment",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://7056774128",
			IsPenthouse = true,
			Name = "0002_Apartment",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://7062527907",
			Name = "0003_Apartment",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://8562032780",
			IsSelected = true,
			Name = "0005_Apartment",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://7208762947",
			IsPenthouse = true,
			Name = "0004_Apartment",
			Filter = "Special"
		},
		{
			Icon = "rbxassetid://8989000182",
			IsPenthouse = true,
			Name = "0006_Apartment",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://14818026139",
			IsSelected = true,
			Name = "0007_Apartment",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://132928404313128",
			IsSelected = true,
			Name = "0008_Apartment",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://130567241366573",
			IsPenthouse = true,
			IsSelected = true,
			Name = "0009_Apartment",
			Filter = "Work"
		}
	},
	Setup = function(instance, data)
		instance.Name = data.Name
		instance.Icon.Image = data.Icon
		local penthouse = instance.Penthouse

		if data.IsPenthouse then
			penthouse.Visible = true
		else
			penthouse:Destroy()
		end

		local selected = instance:FindFirstChild("Selected")
		local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

		if PlayerFlag.IsEnabled("hide-selected") and data.IsSelected then
			selected.Visible = true
		else
			selected:Destroy()
		end

		local VIP = instance.VIP

		if data.IsVIP then
			VIP.Visible = true
		else
			VIP:Destroy()
		end

		local silver = instance.Silver

		if data.IsPremium then
			silver.Visible = true
		else
			silver:Destroy()
		end

		local robuxPass = instance:FindFirstChild("RobuxPass")
		local highlightEffect = instance:FindFirstChild("HighlightEffect")
		robuxPass:Destroy()
		highlightEffect:Destroy()
		local cornerIcon = instance:FindFirstChild("CornerIcon")

		if data.CornerIcon then
			cornerIcon.Image = data.CornerIcon
			cornerIcon.Visible = true
		elseif not cornerIcon.Visible then
			cornerIcon:Destroy()
		end
	end,
	IsGamepass = function(p)
		return p.IsPenthouse
	end
}

function Apartments.FilterEntryValues(data)
	local entries = {}

	for _, entry in Apartments.Entries do
		if not (data.BreadcrumbsFilter == nil or data.BreadcrumbsFilter(entry)) then
			continue
		end

		if data.CurrentCategory == nil then
			if data.GamepassFilter ~= nil and not data.GamepassFilter(entry) or data.CategoryFilter ~= nil and not data.CategoryFilter(entry) then
				continue
			end
		elseif entry.Filter ~= data.CurrentCategory then
			continue
		end

		table.insert(entries, entry)
	end

	return entries
end

return Apartments