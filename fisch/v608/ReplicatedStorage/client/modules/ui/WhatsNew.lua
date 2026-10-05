local Players = game:GetService("Players")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local LocalizationService = game:GetService("LocalizationService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules")
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local DataController = require(legacyControllers.DataController)
local module = require("@self/UpdateClasses")
local hud = Players.LocalPlayer.PlayerGui:WaitForChild("hud")
local whatsNew = hud.safezone.WhatsNew
local listContents = whatsNew.versionList.listContents
local versionDetails = whatsNew.versionDetails
local detailContents = versionDetails.detailContents
local navigate = versionDetails.options.Navigate
local changelogs = hud.safezone.changelogs
local color = Color3.new(0, 0, 0)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.fromRGB(83, 189, 255)
local color4 = Color3.fromRGB(255, 60, 79)
local remoteFunction = Net:RemoteFunction("Changelogs/RequestGuide", -1)
local remoteFunction2 = Net:RemoteFunction("Changelogs/GetDetails", -1)
local remoteFunction3 = Net:RemoteFunction("Changelogs/GetList", -1)
local remoteEvent = Net:RemoteEvent("Changelogs/ShowSide", -1)
local remoteEvent2 = Net:RemoteEvent("Changelogs/MarkSeen", -1)
local remoteEvent3 = Net:RemoteEvent("Changelogs/OpenNewspaper", -1)
local WhatsNew = {}

local function clearList(instance)
	for _, guiObject in instance:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

WhatsNew.versionEntries = {}
WhatsNew.indicators = {}
WhatsNew.selected = nil
WhatsNew.loading = nil
WhatsNew.versionSummary = {}
WhatsNew.mainTrove = Trove.new()
WhatsNew.versionTroves = {}

local function apply_bold(value: string)
	return (`<b><font color='#f8fffe'>{string.sub(value, 2, -2)}</font></b>`)
end

local function apply_italic(value: string)
	return (`<i>{string.sub(value, 2, -2)}</i>`)
end

local function apply_bold_italic(value: string)
	return (`<b><i><font color='#f8fffe'>{string.sub(value, 2, -2)}</font></i></b>`)
end

local function apply_underline(value: string)
	return (`<u>{string.sub(value, 2, -2)}</u>`)
end

function WhatsNew.loadMarkdown(value: string, parent, textSize: number)
	debug.profilebegin("Changelogs.loadMarkdown")
	local frozen = table.freeze({
		["\0"] = "**",
		["\1"] = "***",
		["\2"] = "__"
	})
	local color5 = Color3.fromRGB(248, 255, 254)
	local color6 = Color3.fromRGB(161, 161, 161)
	local color7 = Color3.fromRGB(217, 223, 222)
	local v = textSize // 3.5
	local parts = value:gsub("__", "\2"):gsub("%*%*%*", "\1"):gsub("%*%*", "\0"):split("\n")

	for i, part in ipairs(parts) do
		local match, v2 = part:match("^(%s*)[-*•◦]%s+(.*)$")
		local v3 = v2 or part
		local v4 = 0

		if match == nil then
			local match2, v5 = v3:match("^(#+)%s+(.+)$")

			if match2 == nil or v5 == nil then
				local match3 = v3:match("^%-#%s+(.+)$")

				if match3 ~= nil then
					v3 = match3
					v4 = -1
				end
			else
				v4 = #match2
				v3 = v5
			end
		end

		local text = v3:gsub("%b\2\2", apply_underline):gsub("%b\1\1", apply_bold_italic):gsub("%b\0\0", apply_bold):gsub(
			"%b**",
			apply_italic
		):gsub(
			"[\0\1\2]",
			frozen
		)

		if match == nil then
			local clone = script.textline:Clone()

			if v4 > 0 then
				local fontFace = clone.FontFace
				fontFace.Bold = true
				clone.FontFace = fontFace
				clone.TextColor3 = color5
				clone.TextSize = textSize + math.max(3 - v4, 0) * v
			elseif v4 == -1 then
				clone.TextColor3 = color6
				clone.TextSize = textSize // 1.5
			elseif textSize < 20 then
				clone.TextColor3 = color7
			end

			clone.Text = text
			clone.LayoutOrder = i + 3
			clone.Parent = parent
		else
			local clone = script.listitem:Clone()
			clone.bullet.Text = match:gsub("  ", "\t") .. (#match > 0 and "◦  " or "•  ")
			clone.bullet.TextSize = textSize
			clone.itemcontent.Text = text
			clone.itemcontent.TextSize = textSize
			clone.LayoutOrder = i + 3

			if textSize < 20 then
				clone.bullet.TextColor3 = color7
				clone.itemcontent.TextColor3 = color7
			end

			clone.Parent = parent
		end
	end

	debug.profileend()
end

function WhatsNew.openDetails(data)
	remoteEvent2:FireServer(data.Version)
	local v = module[data.Class] or module[1]
	WhatsNew.selected = data.Version
	local header = detailContents.header
	header.versionTitle.versionTitle.Text = data.Title
	header.Image = data.BackgroundImage or ""
	detailContents.headerDivider.Visible = header.Image == ""

	for _, guiObject in detailContents.changelogs:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	WhatsNew.loadMarkdown(data.Content, detailContents.changelogs, 21)
	local quickDetails = detailContents.header.quickDetails
	local typeInfo = quickDetails.typeInfo
	typeInfo.typeIcon.Image = v.Icon
	typeInfo.typeName.Text = v.Name
	quickDetails.releaseDate.typeName.Text = data.Release:FormatLocalTime("LL", LocalizationService.RobloxLocaleId)
	quickDetails.versionNum.typeName.Text = `Version {data.Version}`
	local lerped = v.Color:Lerp(color2, 0.5)
	typeInfo.typeIcon.UIGradient.Color = ColorSequence.new(lerped, color2)
	typeInfo.typeName.UIGradient.Color = ColorSequence.new(lerped, color2)
	navigate.Visible = data.NavTag ~= nil or data.NavZone ~= nil

	if navigate.Visible then
		if data.Expires and data.Expires.UnixTimestamp < workspace:GetServerTimeNow() then
			navigate.Label.Text = "Event Ended"
			navigate.Label.TextColor3 = color4
			navigate.ImageColor3 = color4
			navigate.UIStroke.Color = color4
			navigate.Interactable = false
		else
			navigate.Label.Text = "Guide Me"
			navigate.Label.TextColor3 = color3
			navigate.ImageColor3 = color3
			navigate.UIStroke.Color = color3
			navigate.Interactable = true
		end
	end
end

function WhatsNew.loadDetails(loading: string)
	if WhatsNew.loading and WhatsNew.versionEntries[WhatsNew.loading] then
		WhatsNew.versionEntries[WhatsNew.loading].BackgroundColor3 = WhatsNew.versionEntries[WhatsNew.loading]:GetAttribute("BaseColor"):Lerp(
			color,
			0.65
		)
	end

	if WhatsNew.versionEntries[loading] then
		WhatsNew.versionEntries[loading].BackgroundColor3 = WhatsNew.versionEntries[loading]:GetAttribute("BaseColor")
	end

	if WhatsNew.loading == loading then
		return
	end

	WhatsNew.loading = loading
	detailContents.Visible = false
	versionDetails.options.Visible = false
	versionDetails.empty.Visible = true
	local v = remoteFunction2:InvokeServer(loading)

	if WhatsNew.loading == loading then
		detailContents.Visible = true
		versionDetails.options.Visible = true
		versionDetails.empty.Visible = false
		WhatsNew.openDetails(v)
	end
end

function WhatsNew.addVersion(data)
	local maid = Trove.new()
	local v = module[data.Class] or module[1]
	local parts = data.Version:split(".")
	local v2 = 0

	for i = 1, 5 do
		if parts[i] and parts[i] ~= "0" then
			if i > 2 then
				v2 = (i - 2) * 0.05
			end
		else
			parts[i] = "9999"
		end
	end

	local name = string.format(
		"%04d.%04d.%04d.%04d.%04d",
		9999 - (tonumber(parts[1]) or 0),
		9999 - (tonumber(parts[2]) or 0),
		9999 - (tonumber(parts[3]) or 0),
		9999 - (tonumber(parts[4]) or 0),
		9999 - (tonumber(parts[5]) or 0)
	)
	local clone = script.version:Clone()
	clone.Name = name
	clone.Size = UDim2.fromScale(1 - v2, 0)
	local color5 = v.Color
	clone.leftBorder.BackgroundColor3 = color5
	clone.BackgroundColor3 = color5:Lerp(color, 0.65)
	clone:SetAttribute("BaseColor", color5)
	local typeInfo = clone.questInfo.quickDetails.typeInfo
	local lerped = v.Color:Lerp(color2, 0.5)
	typeInfo.typeIcon.UIGradient.Color = ColorSequence.new(lerped, color2)
	typeInfo.typeName.UIGradient.Color = ColorSequence.new(lerped, color2)

	if data.Class <= 3 then
		clone.questInfo.versionTitle.TextSize = 21
	end

	if v2 > 0 then
		clone.questInfo.quickDetails.Visible = false
		clone.questInfo.versionTitle.TextSize = 18
	end

	typeInfo.typeName.Text = v.Name
	clone.questInfo.versionTitle.Text = data.Title
	maid:Add(DataController.PlayerDataReplicator:Observe({ "Changelogs", data.Version, "Seen" }, function(p)
		clone.indicator.Visible = p == nil
	end))
	clone.Parent = listContents
	maid:Add(clone)
	WhatsNew.versionTroves[data.Version] = maid
	WhatsNew.versionEntries[data.Version] = clone
	maid:Add(function()
		if WhatsNew.versionEntries[data.Version] == clone then
			WhatsNew.versionEntries[data.Version] = nil
		end
	end)
	maid:Add(clone.Activated:Connect(function()
		WhatsNew.loadDetails(data.Version)
	end))
	maid:Add(clone.MouseEnter:Connect(function()
		clone.arrow:TweenPosition(UDim2.new(1, 2, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	end))
	maid:Add(clone.MouseLeave:Connect(function()
		clone.arrow:TweenPosition(UDim2.new(1, -5, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
	end))
	return clone
end

function WhatsNew.unloadVersions()
	WhatsNew.mainTrove:Clean()

	for _, versionTrove in WhatsNew.versionTroves do
		versionTrove:Clean()
	end

	table.clear(WhatsNew.versionTroves)
end

function WhatsNew.startNavigate()
	if not WhatsNew.selected then
		return
	end

	local v, v2 = remoteFunction:InvokeServer(WhatsNew.selected)

	if not v then
		ReplicatedStorage.events.anno_localthought:Fire(v2)
		return
	end

	whatsNew.Visible = false
	ReplicatedStorage.events.anno_localthought:Fire("Follow the green star to reach the update content!")
end

function WhatsNew.loadVersions()
	WhatsNew.unloadVersions()
	DataController.PlayerDataReplicator:WaitForLoaded()

	if #WhatsNew.versionSummary == 0 then
		detailContents.Visible = false
		versionDetails.options.Visible = false
		versionDetails.empty.Visible = true
		WhatsNew.versionSummary = remoteFunction3:InvokeServer()
	end

	for _, v in WhatsNew.versionSummary do
		WhatsNew.addVersion(v)
	end

	WhatsNew.mainTrove:Add(versionDetails.options.Track.Activated:Connect(function()
		whatsNew.Visible = false
	end))
	WhatsNew.mainTrove:Add(navigate.Activated:Connect(WhatsNew.startNavigate))

	if not (WhatsNew.selected and WhatsNew.versionEntries[WhatsNew.selected]) then
		WhatsNew.loadDetails(WhatsNew.selected or WhatsNew.versionSummary[1].Version)
	end

	local guiInset, v = GuiService:GetGuiInset()
	local v2 = v + Vector2.new(0, 90)
	whatsNew.Size = UDim2.new(0.85, -guiInset.X - v2.X, 1, -guiInset.Y - v2.Y)
	whatsNew.Position = UDim2.new(0.5, guiInset.X / 2 - v2.X / 2, 0.5, guiInset.Y / 2 - v2.Y / 2)
end

local version = nil

function WhatsNew.showSide(data)
	version = data.Version

	for _, guiObject in changelogs.scroll.changesContent:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	WhatsNew.loadMarkdown(data.Content, changelogs.scroll.changesContent, hud.AbsoluteSize.Y > 750 and 18 or 14)
	changelogs.actions.guide.Visible = data.NavZone ~= nil or data.NavTag ~= nil
	changelogs.title.Image = data.BackgroundImage or ""
	changelogs.actions.dismiss.label.Text = "Dismiss"
	changelogs.Visible = true
end

function WhatsNew.init()
	whatsNew:GetPropertyChangedSignal("Visible"):Connect(function()
		if whatsNew.Visible then
			WhatsNew.loadVersions()
		else
			WhatsNew.unloadVersions()
		end
	end)
	remoteEvent.OnClientEvent:Connect(WhatsNew.showSide)
	local flag = false
	local flag2 = false
	changelogs.actions.dismiss.Activated:Connect(function()
		if flag2 or not version then
			return
		end

		if flag or not changelogs.actions.guide.Visible then
			remoteEvent2:FireServer(version, false)
			changelogs.Visible = false
			flag = false
		else
			changelogs.actions.dismiss.label.Text = "Are you sure?"
			flag = true
			flag2 = true
			task.wait(1)
			flag2 = false
		end
	end)
	changelogs.actions.guide.Activated:Connect(function()
		if not version then
			return
		end

		local v, v2 = remoteFunction:InvokeServer(version)

		if not v then
			ReplicatedStorage.events.anno_localthought:Fire(v2)
			return
		end

		remoteEvent2:FireServer(version, true)
		changelogs.Visible = false
		ReplicatedStorage.events.anno_localthought:Fire("Follow the green star to reach the update content!")
	end)
	remoteEvent3.OnClientEvent:Connect(function()
		whatsNew.Visible = true
	end)
end

return WhatsNew