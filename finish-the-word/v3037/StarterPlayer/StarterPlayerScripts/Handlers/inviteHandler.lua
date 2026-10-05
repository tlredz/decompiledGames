local import = _G.import("event")
local import2 = _G.import("romodel")
_G.import("dictUtil")
local import3 = _G.import("modelUtil")
local import4 = _G.import("configuration")
local inviteFriendPopup = _G.import("viewImports"):get("inviteFriendPopup").InviteFriendPopup
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local INVITE_POPUP_INTERVAL = import4.INVITE.INVITE_POPUP_INTERVAL

local function checkInvitePopup(_, p)
	if p.InvitePopupCount >= 3 then
		return
	end

	p.InvitePopupCount += 1
	local v = {}

	for _, v2 in ipairs(game.Players:GetPlayers()) do
		v[v2.UserId] = true
	end

	local v2 = {}

	for _, v3 in ipairs(localPlayer:GetFriendsOnline()) do
		if not v[v3.VisitorId] then
			table.insert(v2, v3)
		end
	end

	if #v2 == 0 then
		p.InvitePopupCount -= 1
		return
	end

	local v3 = v2[math.random(#v2)]
	import2.mount(import2.make(inviteFriendPopup, {
		UserId = v3.VisitorId,
		Username = v3.UserName
	}), playerGui)
end

local function dataLoaded(p, p2)
	import3.getAttribute(workspace, "Mode"):andThen(function(p3)
		if p3 ~= "NORMAL" then
			return
		end

		while true do
			task.spawn(checkInvitePopup, p, p2)
			task.wait(INVITE_POPUP_INTERVAL)
		end
	end)
end

return {
	Priority = 1,
	Run = function()
		import.connect("dataLoaded", dataLoaded)
	end
}