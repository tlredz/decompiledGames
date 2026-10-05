local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AnnouncementView = require(script.AnnouncementView)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
require(script.Types)
local remo = require(ReplicatedStorage.Packages.remo)
local isServer = RunService:IsServer()
local FabAdminAnnouncement = {
	logger = LoggerManager.createLogger(script.Name, {
		feature = script:GetFullName()
	}),
	remotes = remo.createRemotes({
		show = remo.remote()
	})
}
local v = nil
local v2 = {}

function checkAnnouncement(p)
	if type(p.text) == "string" and string.match(p.text, "%S") ~= nil then
		return true, ""
	end

	return false, "FabAdminAnnouncement requires non-empty text."
end

function showLocally(p)
	local v3 = v

	if v3 then
		v3.show(p)
	else
		table.insert(v2, p)
	end
end

function FabAdminAnnouncement.announce(p)
	local v3, v4 = checkAnnouncement(p)

	if not v3 then
		error(v4)
	elseif isServer then
		FabAdminAnnouncement.remotes.show:fireAll(p)
	else
		showLocally(p)
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if not isServer then
			FabAdminAnnouncement.remotes.show:connect(showLocally)
		end
	end,
	OnUIInit = function()
		if not isServer then
			local v3 = AnnouncementView.mount(Players.LocalPlayer.PlayerGui)
			v = v3

			for _, v4 in v2 do
				v3.show(v4)
			end

			table.clear(v2)
		end
	end
})
return FabAdminAnnouncement