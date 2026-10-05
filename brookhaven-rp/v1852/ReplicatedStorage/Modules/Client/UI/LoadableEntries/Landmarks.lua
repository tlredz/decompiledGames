local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemRenderer = require(ReplicatedStorage.Modules.Client.Item.ItemRenderer)
local Landmarks = {
	Entries = {
		{
			Icon = "rbxassetid://73292718385763",
			Name = "001_Landmark",
			Filter = "Work"
		},
		{
			Icon = "rbxassetid://117484642204581",
			Name = "002_Landmark",
			Filter = "Work",
			IsRobuxPass = true,
			RobuxPassIcon = "rbxassetid://98278396216277",
			Item = "PrisonLandmark"
		}
	},
	Setup = function(instance, data)
		instance.Name = data.Name
		instance.Icon.Image = data.Icon
		local selected = instance:FindFirstChild("Selected")
		local PlayerFlag = require(ReplicatedStorage.Modules.Client.PlayerFlags.PlayerFlag)

		if PlayerFlag.IsEnabled("hide-selected") or not data.IsSelected then
			selected:Destroy()
		else
			selected.Visible = true
		end

		local robuxPass = instance:FindFirstChild("RobuxPass")

		if data.IsRobuxPass then
			robuxPass.Visible = true

			if data.RobuxPassIcon ~= nil then
				robuxPass.Image = data.RobuxPassIcon
			end
		else
			robuxPass:Destroy()
		end

		instance:FindFirstChild("Silver"):Destroy()
	end,
	IsGamepass = function(p)
		return p.IsRobuxPass == true
	end
}

function Landmarks.FilterEntryValues(data)
	local entries = {}

	for _, entry in Landmarks.Entries do
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

function Landmarks.GetRenderContext()
	return ItemRenderer.HOUSES_CONTEXT
end

return Landmarks