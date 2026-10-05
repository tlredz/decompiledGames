local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DialogPage = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"):WaitForChild("DialogPage"))
local object = setmetatable({}, DialogPage)
object.__index = object

function object._new()
	local self = setmetatable(DialogPage.new(script.Name), object)
	self._npc_name = nil
	self:_Init()
	return self
end

function object:SetNPCName(npc_name)
	self._npc_name = npc_name
	self:_UpdateFetch()
end

function object:_UpdateFetch()
	if not self._npc_name then
		return
	end

	task.defer(self._FetchDialog, self, ReplicatedStorage.Remotes.Misc.FetchDialogLobby, self._npc_name)
end

function object:_Init()
	self:HookDialogActionKey("OpenCreditsPage", function()
		self.OpenPage:Fire("Credits")
	end)
end

return object._new()