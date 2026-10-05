local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._connections = {}
	self:_Init()
	return self
end

function class:_ObjectRemoved(p2)
	if self._connections[p2] then
		self._connections[p2]:Disconnect()
		self._connections[p2] = nil
	end
end

function class:_ObjectAdded(instance)
	self:_ObjectRemoved(instance)
	self._connections[instance] = instance.Triggered:Connect(function()
		wait(0.06)
		Pages.PageSystem:OpenPage(instance:GetAttribute("PageName"), true)
		local shopViewBundleName = instance:GetAttribute("ShopViewBundleName")
		local shopViewShopEntryName = instance:GetAttribute("ShopViewShopEntryName")

		if shopViewBundleName then
			local v

			if #shopViewBundleName >= 9 and string.sub(shopViewBundleName, 1, 9) == "keybundle" then
				v = true
			elseif #shopViewBundleName >= 19 then
				v = string.sub(shopViewBundleName, 1, 19) == "eventcurrencybundle"
			else
				v = false
			end

			Pages.PageSystem:WaitForPage("Shop"):SetPage(v and "Currency" or "Bundles")
			Pages.PageSystem:WaitForPage("Shop"):InspectBundle(shopViewBundleName)
		elseif shopViewShopEntryName then
			Pages.PageSystem:WaitForPage("Shop"):SetPage("Home")
			Pages.PageSystem:WaitForPage("Shop"):InspectShopEntry(shopViewShopEntryName)
		end

		local shopViewPage = instance:GetAttribute("ShopViewPage")

		if shopViewPage then
			Pages.PageSystem:WaitForPage("Shop"):SetPage(shopViewPage)
		end

		local dialogLobbyNPCName = instance:GetAttribute("DialogLobbyNPCName")

		if dialogLobbyNPCName then
			Pages.PageSystem:WaitForPage("DialogLobby"):SetNPCName(dialogLobbyNPCName)
		end

		local matchmakingScrollTo = instance:GetAttribute("MatchmakingScrollTo")

		if matchmakingScrollTo then
			Pages.PageSystem:WaitForPage("Matchmaking"):ScrollTo(matchmakingScrollTo, 0.25)
		end

		local inspectUGC = instance:GetAttribute("InspectUGC")

		if inspectUGC then
			Pages.PageSystem:WaitForPage("UGCShop"):Buy(inspectUGC)
		end

		local tasksScrollTo = instance:GetAttribute("TasksScrollTo")

		if tasksScrollTo then
			Pages.PageSystem:WaitForPage("Tasks"):ScrollTo(tasksScrollTo, 0.25)
		end
	end)
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("LobbyOpenPagePrompt"):Connect(function(p)
		self:_ObjectAdded(p)
	end)
	CollectionService:GetInstanceRemovedSignal("LobbyOpenPagePrompt"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyOpenPagePrompt")) do
		task.spawn(self._ObjectAdded, self, v)
	end
end

return class._new()