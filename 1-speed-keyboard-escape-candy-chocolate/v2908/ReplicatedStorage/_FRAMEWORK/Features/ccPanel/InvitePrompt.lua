local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CUI = require(ReplicatedStorage.CUI)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {}
local v2 = nil
local v3 = false
local v4 = 0
local v5 = nil
local v6 = nil
local InvitePrompt = {}

local function showNext(p: number)
	v2 = nil
	v4 = 0

	while v2 == nil and #v > 0 do
		local v7 = table.remove(v, 1)

		if p < v7.expiresAt then
			v2 = v7
		end
	end

	local v7 = v2
	local window = InvitePrompt.getWindow()

	if not v7 then
		window:SetVisible(false)
		return
	end

	v5:SetText(string.format("<b>%s</b> invites you to their World %d.", v7.fromName, v7.worldIndex))
	window:SetVisible(true)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showError(message: string)
	v6:SetText(string.format("✗ %s", message)):SetTextColor(Config.ERROR_COLOR)
	v4 = os.clock() + 2
end

local function respond(flag: boolean)
	local v7 = v2

	if v7 and not v3 then
		v3 = true
		Remotes.respondInvite:request(v7.inviteId, flag):andThen(function(p)
			v3 = false

			if p.success then
				showNext(os.clock())
				return
			end

			showError(p.message) -- equivalent call inferred; original call site unknown
		end):catch(function(p)
			v3 = false
			logger:warn(string.format("invite response failed: %s", (tostring(p))))
			showNext(os.clock())
		end)
	end
end

local function build(object)
	object:SetTitle(Config.INVITE_WINDOW_ID):SetCloseButtonVisible(false)
	v5 = object.Components:AddText(function(object2)
		object2:SetRichTextEnabled(true):SetAutoResize(true)
	end)
	v6 = object.Components:AddText(function(object2)
		object2:SetTextColor(Config.STATUS_COLOR)
	end)
	object.Components:AddSplit(function(p)
		p.LeftComponents:AddButton(function(object2)
			object2:SetButtonText("Accept"):SetButtonColor(Config.SUCCESS_COLOR):SetButtonCallback(function()
				respond(true)
			end)
		end)
		p.RightComponents:AddButton(function(object2)
			object2:SetButtonText("Decline"):SetButtonColor(Config.DANGER_COLOR):SetButtonCallback(function()
				respond(false)
			end)
		end)
	end)
	object:SetPositionWithAnchor(object:GetScreenSize().X / 2, Config.INVITE_WINDOW_TOP, Vector2.new(0.5, 0))
end

function InvitePrompt.getWindow()
	return CUI.GetWindow(Config.INVITE_WINDOW_ID, Config.INVITE_WINDOW_WIDTH, build)
end

function InvitePrompt.enqueue(data)
	table.insert(v, {
		inviteId = data.inviteId,
		fromName = data.fromName,
		worldIndex = data.worldIndex,
		expiresAt = os.clock() + data.expiresIn
	})

	if v2 == nil then
		showNext(os.clock())
	end
end

function InvitePrompt.tick(p: number)
	local v7 = v2

	if v7 and not v3 then
		if v4 > 0 then
			if v4 <= p then
				showNext(p)
			end
		elseif v7.expiresAt <= p then
			showNext(p)
		else
			v6:SetText(string.format("Expires in %ds", (math.ceil(v7.expiresAt - p)))):SetTextColor(Config.STATUS_COLOR)
		end
	end
end

return InvitePrompt