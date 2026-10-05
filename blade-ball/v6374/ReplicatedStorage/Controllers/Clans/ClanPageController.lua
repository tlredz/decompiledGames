local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Controllers.Clans.ClanController)
local v4 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v5 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local clans = Players.LocalPlayer.PlayerGui:WaitForChild("Clans")
local _ = {
	[true] = {
		Color = Color3.fromRGB(107, 73, 21),
		Image = "http://www.roblox.com/asset/?id=15355247561",
		Hover = "rbxassetid://15418459265"
	},
	[false] = {
		Color = Color3.fromRGB(34, 66, 144),
		Image = "http://www.roblox.com/asset/?id=15355248717",
		Hover = "rbxassetid://15418457229"
	}
}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = v.new()
local v12 = v.new()
local v13 = v.new()
local v14 = v.new()
local v15 = v.new()
local v16 = v.new()
local ClanPageController = {
	ClanGUI = clans,
	RegisterSectionPermission = function(self, p: string, p2: string)
		v9[p] = p2
		v15:Fire(p, p2)
	end,
	RegisterPagePermission = function(self, p: string, p2: string)
		v10[p] = p2
		v14:Fire(p, p2)
	end
}

function ClanPageController.RegisterPage(_, p: string, p2, p3: string?)
	if v7[p] then
		warn((`Attempted to register clan page "{p}", which already exists... overwriting`))
	end

	v7[p] = p2

	if p3 then
		ClanPageController:RegisterPagePermission(p, p3)
	end
end

function ClanPageController.RegisterSection(_, p: string, p2: string, p3: string?)
	v8[p] = p2
	v6[p2] = true

	if p3 then
		ClanPageController:RegisterSectionPermission(p, p3)
	end
end

function ClanPageController:GetRegisteredPage(p: string)
	return v7[p]
end

function ClanPageController.GetRegisteredSection(_, p: string)
	return v8[p]
end

function ClanPageController:Open()
	v2:Open("Clans")
end

function ClanPageController:Close()
	v2:Close("Clans")
end

function ClanPageController:OpenPage(currentPage: string)
	local v17 = v7[currentPage]

	if not v17 then
		return warn((`No Register Page Exists for: {currentPage}`))
	end

	if self._currentPage == currentPage then
		return
	end

	if self._currentPage then
		local registeredPage = ClanPageController:GetRegisteredPage(self._currentPage)

		if registeredPage then
			registeredPage.Visible = false
		end

		v12:Fire(self._currentPage)

		if self._currentPage == currentPage then
			self._currentPage = nil
			return
		end
	end

	v17.Visible = true
	self._currentPage = currentPage
	v11:Fire(currentPage)
end

function ClanPageController:ClosePage(p2: string)
	if p2 or not self._currentPage then
		local registeredPage = ClanPageController:GetRegisteredPage(p2)

		if not registeredPage then
			return
		end

		if self._currentPage == p2 then
			registeredPage.Visible = false
			self._currentPage = nil
			v12:Fire(p2)
		end
	else
		local registeredPage = ClanPageController:GetRegisteredPage(self._currentPage)

		if registeredPage then
			registeredPage.Visible = false
		end

		v12:Fire(self._currentPage)
		self._currentPage = nil
	end
end

function ClanPageController.OpenClanPointShop(_)
	ClanPageController:OpenPage("ClanPointsShop")
end

function ClanPageController:OpenSection(currentSection: string)
	local v17 = v8[currentSection]

	if not v17 then
		return warn((`No Registered Section: {currentSection}`))
	end

	if self._currentSection == currentSection then
		return
	end

	self._currentSection = currentSection
	ClanPageController:OpenPage(v17)
	v13:Fire(currentSection)
end

function ClanPageController.OpenDefaultSection(_)
	ClanPageController:OpenSection("Create")
end

function ClanPageController.OnPageOpen(_, p: string, callback)
	return v11:Connect(function(p2: string)
		if p2 ~= p then
			return
		end

		callback(true)
	end)
end

function ClanPageController.OnPageClose(_, p: string, callback)
	return v12:Connect(function(p2: string)
		if p2 ~= p then
			return
		end

		callback(false)
	end)
end

function ClanPageController.OnPermissionChange(_, callback)
	return v16:Connect(function(p: string)
		callback(p)
	end)
end

function ClanPageController:IsOpen(p2: string)
	local _currentPage = self._currentPage

	if _currentPage then
		return _currentPage == p2
	end

	return false
end

function ClanPageController:Start()
	self._isClanMember = v3.CurrentClanId ~= nil

	local function updateClanPage()
		if v3:IsVersion(v3.Versions.old) then
			if self._isClanMember then
				if self._currentPage and v10[self._currentPage] ~= "Member" then
					ClanPageController:OpenPage("Overview")
				end
			elseif self._currentPage and v10[self._currentPage] ~= "Clanless" then
				ClanPageController:OpenPage("Create")
			end
		elseif self._currentPage then
			self:ClosePage(self._currentPage)
		end
	end

	v3:BindToVersion(v3.Versions.old, updateClanPage)
	v3.ClanUpdated:Connect(function(p)
		self._isClanMember = p ~= nil
		updateClanPage()
	end)
	v2:OnGuiOpen("Clans", function()
		if not v3:IsVersion(v3.Versions.old) then
			return
		end

		v4:Hide("ClanPage")
		v5(Enum.CoreGuiType.PlayerList, false)
		clans.Black.Visible = true

		if v3.CurrentClanId then
			ClanPageController:OpenPage("Overview")
		else
			ClanPageController:OpenPage("Create")
		end
	end)
	v2:OnGuiClose("Clans", function()
		if not v3:IsVersion(v3.Versions.old) then
			return
		end

		v4:Show("ClanPage")
		v5(Enum.CoreGuiType.PlayerList, true)
		clans.Black.Visible = false
	end)
end

return ClanPageController