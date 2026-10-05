local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextService")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.Packages.Freeze)
local v4 = require3(script.Parent.Parent.ClanController)
local v5 = require3(script.Parent.Parent.Utils)
require3(ReplicatedStorage2.Shared.ClansData)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v6 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v7 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v8 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local clans = Players.LocalPlayer.PlayerGui.Clans
local pages = clans.Pages
local maid = v.new()
local v9 = {}
local pageStackChanged = v2.new()
local ClanPagesController = {}
ClanPagesController.ClanGui = clans
ClanPagesController.PageStackChanged = pageStackChanged

function ClanPagesController.PushPage(_, p)
	v9 = v3.List.push(v9, p)
	pageStackChanged:Fire(v9)
end

function ClanPagesController.PopPage(_)
	v9 = v3.List.pop(v9)
	pageStackChanged:Fire(v9)
end

function ClanPagesController.RemovePage(_, p)
	local index = table.find(v9, p)

	if not index then
		return
	end

	v9 = v3.List.remove(v9, index)
	pageStackChanged:Fire(v9)
end

function ClanPagesController:SetPage(p)
	if #v9 == 1 and v9[1] == p then
		return
	end

	v9 = { p }
	pageStackChanged:Fire(v9)
end

function ClanPagesController.IsOpen(_, p)
	return table.find(v9, p) ~= nil
end

function ClanPagesController.IsLastPage(_, p)
	return v9[#v9] == p
end

function ClanPagesController:Open()
	v6:Open("Clans")
end

function ClanPagesController:Close()
	v6:Close("Clans")
end

function ClanPagesController.Init(_) end

function ClanPagesController:Start()
	local function updateHUDState()
		local v11 = v4.CurrentClanId ~= nil
		local isVersion = v4:IsVersion(v4.Versions.new)

		if v11 then
			self:SetPage("Overview")
		else
			self:SetPage("NoClan")
		end

		if isVersion then
			for _, button in clans.HUDButtons:GetChildren() do
				if not button:IsA("GuiButton") then
					continue
				end

				local child = clans.Pages:FindFirstChild(button.Name)

				if child then
					local v12 = child
					maid:Add(button.Activated:Connect(function()
						self:SetPage(v12.Name)
					end))
				else
					button.Visible = false
				end
			end

			clans.Overview.Visible = false
			maid:Add(clans.Overview:GetPropertyChangedSignal("Visible"):Connect(function()
				clans.Overview.Visible = false
			end))
		else
			maid:Clean()
		end

		clans.HUDButtons.Visible = isVersion and v11
		clans.Pages.Visible = isVersion
		clans.Close.Visible = isVersion
	end

	v4:BindToVersion(v4.Versions.new, updateHUDState)
	v4.ClanUpdated:Connect(updateHUDState)
	v6:OnGuiOpen("Clans", function()
		if not v4:IsVersion(v4.Versions.new) then
			return
		end

		v8:Hide("ClanPage")
		v7(Enum.CoreGuiType.PlayerList, false)
		clans.Black.Visible = true
	end)
	v6:OnGuiClose("Clans", function()
		if not v4:IsVersion(v4.Versions.new) then
			return
		end

		v8:Show("ClanPage")
		v7(Enum.CoreGuiType.PlayerList, true)
		clans.Black.Visible = false
	end)
	pageStackChanged:Connect(function()
		for _, guiObject in pages:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local index = table.find(v9, guiObject.Name)
			local visible = index ~= nil
			local sinkInput = guiObject:FindFirstChild("SinkInput")

			if sinkInput then
				sinkInput.Visible = index == #v9
			end

			local child = clans.HUDButtons:FindFirstChild(guiObject.Name)

			if child then
				v5.setButtonImages(child, visible)
			end

			guiObject.Visible = visible
			guiObject.ZIndex = not index and 1 or index + 1
		end
	end)
end

return ClanPagesController