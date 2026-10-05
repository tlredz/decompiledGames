local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local Signal = require(ReplicatedStorage.Modules.Signal)
local v = { "FreecamEnabled", "ArcadeCanPlayAllMaps" }
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedClass.new(), object)
	self.BannedPlayersChanged = Signal.new()
	self.BannedPlayers = {}
	self:_Init()
	return self
end

function object.ServerKick(_, p)
	ReplicatedStorage.Remotes.PrivateServer.KickPlayer:FireServer(p)
end

function object.ServerBan(_, p)
	ReplicatedStorage.Remotes.PrivateServer.BanPlayer:FireServer(p)
end

function object:_ObjectAdded(p)
	if CONSTANTS.IS_PRIVATE_HUB_SERVER then
		return
	end

	task.defer(p.Destroy, p)
end

function object:_SetBannedPlayers(bannedPlayers)
	self.BannedPlayers = bannedPlayers
	self.BannedPlayersChanged:Fire()
end

function object:_FetchBannedPlayers()
	if not CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId) then
		return
	end

	local success, result = pcall(
		ReplicatedStorage.Remotes.PrivateServer.FetchBannedPlayers.InvokeServer,
		ReplicatedStorage.Remotes.PrivateServer.FetchBannedPlayers
	)

	if not success then
		return
	end

	self:_SetBannedPlayers(result)
end

function object:_Setup()
	for _, v2 in pairs(v) do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v3 = v2

		local function update()
			self:SetReplicate(v3, workspace:GetAttribute(v3))
		end

		workspace:GetAttributeChangedSignal(v2):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

function object:_Init()
	ReplicatedStorage.Remotes.PrivateServer.ReplicateBannedPlayers.OnClientEvent:Connect(function(p)
		self:_SetBannedPlayers(p)
	end)
	CollectionService:GetInstanceAddedSignal("LobbyPrivateServerOnly"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v2 in pairs(CollectionService:GetTagged("LobbyPrivateServerOnly")) do
		task.defer(self._ObjectAdded, self, v2)
	end

	self:_Setup()
	task.defer(self._FetchBannedPlayers, self)
end

return object._new()