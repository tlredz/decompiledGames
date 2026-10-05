local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local easterEvent = Players.LocalPlayer.PlayerGui:WaitForChild("EasterEvent")
local v4 = {}
local v5 = v.new()
local v6 = v.new()
v.new()
local EasterPageController = {
	EasterGUI = easterEvent,
	RegisterPage = function(_, p: string, p2)
		if v4[p] then
			warn((`Attempted to register Easter page "{p}", which already exists... overwriting`))
		end

		v4[p] = p2
	end,
	GetRegisteredPage = function(self, p: string)
		return v4[p]
	end,
	Open = function(self)
		v2:Open("EasterEvent")
	end,
	Close = function(self)
		v2:Close("EasterEvent")
	end
}

function EasterPageController:OpenPage(currentPage: string)
	local v7 = v4[currentPage]

	if not v7 then
		return warn((`No Register Page Exists for: {currentPage}`))
	end

	if self._currentPage == currentPage then
		return
	end

	if self._currentPage then
		local registeredPage = EasterPageController:GetRegisteredPage(self._currentPage)

		if registeredPage then
			registeredPage.Visible = false
		end

		v6:Fire(self._currentPage)

		if self._currentPage == currentPage then
			self._currentPage = nil
			return
		end
	end

	v7.Visible = true
	self._currentPage = currentPage
	v5:Fire(currentPage)
end

function EasterPageController:ClosePage(p2: string)
	if p2 or not self._currentPage then
		local registeredPage = EasterPageController:GetRegisteredPage(p2)

		if not registeredPage then
			return
		end

		if self._currentPage == p2 then
			registeredPage.Visible = false
			self._currentPage = nil
			v6:Fire(p2)
		end
	else
		local registeredPage = EasterPageController:GetRegisteredPage(self._currentPage)

		if registeredPage then
			registeredPage.Visible = false
		end

		v6:Fire(self._currentPage)
		self._currentPage = nil
	end
end

function EasterPageController.OnPageOpen(_, p: string, callback)
	return v5:Connect(function(p2: string)
		if p2 ~= p then
			return
		end

		callback(true)
	end)
end

function EasterPageController.OnPageClose(_, p: string, callback)
	return v6:Connect(function(p2: string)
		if p2 ~= p then
			return
		end

		callback(false)
	end)
end

function EasterPageController:IsOpen(p2: string)
	local _currentPage = self._currentPage

	if _currentPage then
		return _currentPage == p2
	end

	return false
end

function EasterPageController.Start(_)
	v2:OnGuiOpen("EasterEvent", function()
		v3:Hide("EasterPage")
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	end)
	v2:OnGuiClose("EasterEvent", function()
		v3:Show("EasterPage")
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	end)
end

return EasterPageController