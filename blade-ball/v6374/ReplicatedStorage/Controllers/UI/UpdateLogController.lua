local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Shared.UpdateLogs)
local v5 = require3(ReplicatedStorage2.Controllers.UI.TopBarController)
local updateLog = Players.LocalPlayer.PlayerGui:WaitForChild("UpdateLog")
local content = updateLog.Main.Content
local clone = content.ScrollingFrame.Template:Clone()
local name = updateLog.Name
local flag = false
local remoteEvent = v2:RemoteEvent("ViewedUpdateLog")
local UpdateLogController = {}

function UpdateLogController:Render()
	if flag then
		return
	end

	flag = true
	local v6 = v4[1]
	local scrollingFrame = content.ScrollingFrame
	local info = content.Info
	info.Thumbnail.Icon.Image = v6.Thumbnail or "rbxassetid://16123339130"
	info.Description.Text = v6.SubDescription or v6.Description or ""
	info.SubtextLabel.Text = v6.Subtext or ""

	for i = 1, 3 do
		local child = info.ItemIcons:FindFirstChild((`Item{i}`))

		if not child then
			continue
		end

		local itemIcon = v6.ItemIcons[i]
		child.Visible = itemIcon ~= nil and #itemIcon > 0
		child.Icon.Image = itemIcon or ""
	end

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for k, v7 in v4 do
		if k > 5 then
			break
		end

		local clone2 = clone:Clone()
		clone2.Name = k
		clone2.LayoutOrder = k
		clone2.Description.Text = string.gsub(v7.Description, "\t", "")
		clone2.Header.Title.Text = v7.Title
		local v8 = math.floor(workspace:GetServerTimeNow() - v7.Date.UnixTimestamp)
		local text

		if v8 <= 86400 then
			text = "Today"
		elseif v8 < 691200 then
			text = `{v8 // 86400}d ago`
		else
			text = `{math.round(v8 / 604800)}w ago`
		end

		clone2.Header.Date.Text = text

		if #v7.Description > 150 then
			clone2.Size += UDim2.new(0, 0, 0.3, 0)
			clone2.Header.Size += UDim2.new(0, 0, -0.1, 0)
			clone2.Description.Size += UDim2.new(0, 0, 0.06, 0)
		end

		clone2.Parent = scrollingFrame
	end
end

function UpdateLogController:Start()
	local v6 = v5:Create("UpdateLog"):setImage(16132663525):setLabel("NEWS"):setCaption("View the update log!"):setOrder(0)
	v5:AddDropdown("Extra", v6)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		remoteEvent:FireServer()
		v3:Close(name)
	end

	content.Close.Activated:Connect(function()
		close() -- equivalent call inferred; original call site unknown
	end)
	v6.toggled:Connect(function(_, p)
		if p ~= "User" then
			return
		end

		if not v3:IsOpen(name) then
			v3:Open(name)
			return
		end

		close() -- equivalent call inferred; original call site unknown
	end)
	v3:OnGuiClose(name, function()
		v6:deselect()
	end)
	v3:OnGuiOpen(name, function()
		v6:clearNotices()
		v6:select()
	end)
	self:Render()
	local v7 = v.Client:WaitReplion("Data")

	if v7:GetExpect("SessionCount") > 1 and v7:GetExpect("TotalStats.Wins") >= 1 and not v7:Get({
		"ViewedUpdateLogs",
		(tostring(v4[1].Date.UnixTimestamp))
	}) then
		v6:notify()
	end
end

return UpdateLogController