local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local DialogPage = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"):WaitForChild("DialogPage"))
local object = setmetatable({}, DialogPage)
object.__index = object

function object._new()
	local self = setmetatable(DialogPage.new(script.Name), object)
	self:_Init()
	return self
end

function object:Open(...)
	DialogPage.Open(self, ...)
	task.defer(self._FetchDialog, self, ReplicatedStorage.Remotes.Misc.FetchDialogAprilFools)
end

function object:_Init() end

return object._new()