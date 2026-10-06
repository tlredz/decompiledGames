local module = require("@game/ReplicatedStorage/Omni")
local Controller = require(script.Parent.Parent.Controller)
local edit = module.Interface:WaitForChild("Frames"):WaitForChild("Guilds"):WaitForChild("Main"):WaitForChild("Edit")
local guildDescription = edit:WaitForChild("GuildDescription")
local guildLogo = edit:WaitForChild("GuildLogo")
local preview = edit:WaitForChild("Preview")
local buttons = edit:WaitForChild("Buttons")
local v = false
local Edit = {
	GetIcon = function(p)
		local text = guildLogo.TextBox.Text
		local icon = p and p.Icon or ""

		if text == "" then
			return icon
		end

		return module.Shared.Guilds.NormalizeIcon(text) or icon
	end
}

function Edit.RefreshPreview()
	local viewingGuildData = Controller.ViewingGuildData
	preview.GuildIcon.Image = Edit.GetIcon(viewingGuildData)
	local text = guildDescription.TextBox.Text
	preview.Info.GuildDesc.Text = (text == "" or not text) and "Guild Description" or text

	if not viewingGuildData then
		return
	end

	local count = 0
	local v2 = "Unknown"

	for k, member in viewingGuildData.Members do
		count += 1

		if tostring(viewingGuildData.OwnerId) == k then
			v2 = member.UserName and "@" .. member.UserName or member.NickName or v2
		end
	end

	preview.Info.GuildName.Text = viewingGuildData.Name
	preview.Info.GuildLeader.Text = "By: " .. v2
	preview.Info.GuildMembers.Text = `{count}/{viewingGuildData.MaxMembers} Members`
end

function Edit.RefreshLimits()
	guildDescription.Limit.Text = `{#guildDescription.TextBox.Text}/{module.Shared.Guilds.DescriptionMaxLength}`
end

function Edit.RefreshLogoValidation()
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

function Edit.Refresh()
	Edit.RefreshLimits()
	Edit.RefreshLogoValidation()
	Edit.RefreshPreview()
end

function Edit.Fill()
	local viewingGuildData = Controller.ViewingGuildData
	v = viewingGuildData ~= nil
	guildDescription.TextBox.Text = viewingGuildData and viewingGuildData.Description or ""
	guildLogo.TextBox.Text = ""
	Edit.Refresh()
end

function Edit.Apply()
	local viewingGuildData = Controller.ViewingGuildData

	if not (viewingGuildData and Controller.CanEditGuild()) then
		return
	end

	local text = guildDescription.TextBox.Text
	local text2 = guildLogo.TextBox.Text

	if #text > module.Shared.Guilds.DescriptionMaxLength or text2 ~= "" and not module.Shared.Guilds.NormalizeIcon(text2) then
		return
	end

	local v2 = text ~= viewingGuildData.Description
	local v3 = Edit.GetIcon(viewingGuildData) ~= viewingGuildData.Icon

	if v2 or v3 then
		module.Signal:Fire("General", "Guilds", "Edit", text, text2)
	end
end

function Edit.Init()
	guildDescription.TextBox:GetPropertyChangedSignal("Text"):Connect(Edit.Refresh)
	guildLogo.TextBox:GetPropertyChangedSignal("Text"):Connect(Edit.Refresh)
	module.Button:Create(buttons.Apply.Main, "Small"):BindFunction("Click", Edit.Apply)
	Controller.TabChanged:Connect(function(p)
		if p ~= "Edit" then
			return
		end

		Edit.Fill()
	end)
	Controller.GuildDataChanged:Connect(function()
		if Controller.CurrentTab ~= "Edit" then
			return
		end

		if v then
			Edit.RefreshPreview()
		else
			Edit.Fill()
		end
	end)
end

return Edit