local module = require("@game/ReplicatedStorage/Omni")
local guilds = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds")
local create = guilds:WaitForChild("Main"):WaitForChild("Create")
local guildName = create:WaitForChild("GuildName")
local guildDescription = create:WaitForChild("GuildDescription")
local guildLogo = create:WaitForChild("GuildLogo")
local preview = create:WaitForChild("Preview")
local price = create:WaitForChild("Price")
local buttons = create:WaitForChild("Buttons")
local randomIcon = module.Shared.Guilds.GetRandomIcon()
local Create = {
	GetIcon = function()
		local text = guildLogo.TextBox.Text

		if text == "" then
			return randomIcon
		end

		return module.Shared.Guilds.NormalizeIcon(text) or randomIcon
	end
}

function Create.RefreshPreview()
	local icon = Create.GetIcon()
	preview.GuildIcon.Image = icon
	local text = guildName.TextBox.Text
	local text2 = guildDescription.TextBox.Text
	preview.Info.GuildName.Text = (text == "" or not text) and "Guild Name" or text
	preview.Info.GuildDesc.Text = (text2 == "" or not text2) and "Guild Description" or text2
	preview.Info.GuildLeader.Text = "By: @" .. module.Instance.Name
	preview.Info.GuildMembers.Text = `1/{module.Shared.Guilds.BaseMaxMembers} Members`
end

function Create.RefreshLimits()
	guildName.Limit.Text = `{#guildName.TextBox.Text}/{module.Shared.Guilds.NameMaxLength}`
	guildDescription.Limit.Text = `{#guildDescription.TextBox.Text}/{module.Shared.Guilds.DescriptionMaxLength}`
end

function Create.RefreshLogoValidation()
	local text = guildLogo.TextBox.Text

	if text == "" then
		guildLogo.SuccessIcon.Visible = false
		guildLogo.ErrorIcon.Visible = false
	else
		local visible = module.Shared.Guilds.NormalizeIcon(text) ~= nil
		guildLogo.SuccessIcon.Visible = visible
		guildLogo.ErrorIcon.Visible = not visible
	end
end

function Create.Refresh()
	Create.RefreshLimits()
	Create.RefreshLogoValidation()
	Create.RefreshPreview()
end

function Create.Reset()
	guildName.TextBox.Text = ""
	guildDescription.TextBox.Text = ""
	guildLogo.TextBox.Text = ""
	randomIcon = module.Shared.Guilds.GetRandomIcon()
	price.Icon.Image = module.Shared.Perks["Free Gems"].Icon
	price.Amount.Text = `{module.Utils.Number:Format(module.Shared.Guilds.CreateCostGems)} Gems`
	Create.Refresh()
end

function Create.Create()
	local v = guildName.TextBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
	local text = guildDescription.TextBox.Text

	if #v == 0 or #v > module.Shared.Guilds.NameMaxLength or #text > module.Shared.Guilds.DescriptionMaxLength then
		return
	end

	local icon = Create.GetIcon()
	module.Signal:Fire("General", "Guilds", "Create", v, text, icon)
end

function Create.Init()
	guildName.TextBox:GetPropertyChangedSignal("Text"):Connect(Create.Refresh)
	guildDescription.TextBox:GetPropertyChangedSignal("Text"):Connect(Create.Refresh)
	guildLogo.TextBox:GetPropertyChangedSignal("Text"):Connect(Create.Refresh)
	module.Button:Create(buttons.Create.Main, "Small"):BindFunction("Click", Create.Create)
	module.Frame:OnFrameOpened(guilds, function()
		Create.Reset()
	end)
end

return Create