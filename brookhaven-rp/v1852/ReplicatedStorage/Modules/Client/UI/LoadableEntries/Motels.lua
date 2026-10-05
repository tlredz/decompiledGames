local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Motels = {
	Entries = {
		{
			Icon = "rbxassetid://127835471783700",
			Name = "001_Motel",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://81784087676049",
			Name = "002_Motel",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://90020639554707",
			Name = "003_Motel",
			Filter = "Home"
		},
		{
			Icon = "rbxassetid://125068163151373",
			IsSelected = true,
			Name = "004_Motel",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://127250310456946",
			Name = "005_Motel",
			Filter = "Special"
		},
		{
			Icon = "rbxassetid://102256039211340",
			IsVIP = true,
			Name = "006_Motel",
			Filter = "Home"
		}
	},
	Setup = function(instance, data)
		instance.Name = data.Name
		instance.Icon.Image = data.Icon
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

		local silver = instance.Silver

		if data.IsPremium then
			silver.Visible = true
		else
			silver:Destroy()
		end

		local selected = instance:FindFirstChild("Selected")
		local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

		if PlayerFlag.IsEnabled("hide-selected") or not data.IsSelected then
			if not selected.Visible then
				selected:Destroy()
			end
		else
			selected.Visible = true
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
		return p.IsVIP
	end
}

function Motels.FilterEntryValues(data)
	local entries = {}

	for _, entry in Motels.Entries do
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

return Motels