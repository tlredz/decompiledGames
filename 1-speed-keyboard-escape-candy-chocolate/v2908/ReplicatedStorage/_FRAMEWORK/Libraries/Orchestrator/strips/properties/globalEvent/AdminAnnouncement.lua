local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.Parent.types.Save)
require(script.Parent.Parent.Parent.Parent.types.Strip)
local dataTemplate = {
	text = "Announcement",
	senderName = "BBNO$",
	senderUserId = 1516108345,
	isOwner = false,
	adminRole = "None",
	duration = -1
}

local function announce(data, duration: number)
	local v2 = {
		text = data.text,
		senderName = data.senderName,
		senderUserId = 0,
		isOwner = 0,
		adminRole = 0,
		Duration = 0
	}
	local senderUserId

	if data.senderUserId > 0 then
		senderUserId = data.senderUserId
	end

	v2.senderUserId = senderUserId
	v2.isOwner = data.isOwner
	local adminRole

	if not (data.adminRole == "" or data.adminRole == "None") then
		adminRole = data.adminRole
	end

	v2.adminRole = adminRole
	v2.Duration = duration

	for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
		if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
			bindableEvent:Fire(v2)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDuration(data, keyframe, keyframe2)
	if data.duration >= 0 then
		return data.duration
	end

	if keyframe2 == nil then
		return 6
	end

	return keyframe2.timeSeconds - keyframe.timeSeconds + 1
end

local AdminAnnouncement = {}
AdminAnnouncement.stripType = "property"
AdminAnnouncement.playbackMode = "custom"
AdminAnnouncement.propertyName = "Admin Announcement"
AdminAnnouncement.context = "client"
AdminAnnouncement.catchUpPolicies = { "skip" }
AdminAnnouncement.dataTemplate = dataTemplate
AdminAnnouncement.supportsGlobal = true

function AdminAnnouncement.buildEditor(p, state, _)
	p.Components:AddField(function(object)
		object:SetText("Message"):SetValue(state.text):SetOnChangedUnfocus(function(text: string)
			state.text = text
		end)
	end)
	p.Components:AddField(function(object)
		object:SetText("Sender Name"):SetValue(state.senderName):SetOnChangedUnfocus(function(senderName: string)
			state.senderName = senderName
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Sender User ID"):SetValue(state.senderUserId):SetNumberFilter(0):SetOnChangedUnfocus(function(p2: number)
			state.senderUserId = math.floor(p2)
		end)
	end)
	p.Components:AddCheckbox(function(object)
		object:SetText("Owner Badge"):SetValue(state.isOwner):SetOnChanged(function(isOwner: boolean)
			state.isOwner = isOwner
		end)
	end)
	p.Components:AddField(function(object)
		object:SetText("Admin Role"):SetValue(state.adminRole):SetOnChangedUnfocus(function(adminRole: string)
			state.adminRole = adminRole
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Duration (-1 = Next Keyframe)"):SetValue(state.duration):SetNumberFilter(-1, 60):SetOnChangedUnfocus(function(duration: number)
			state.duration = duration
		end)
	end)
end

function AdminAnnouncement.supports(_)
	return false
end

function AdminAnnouncement.capture(_, _)
	return table.clone(dataTemplate)
end

function AdminAnnouncement.createRuntime(p, callback)
	local v2 = false
	local v3 = false
	return {
		attach = function(_, _, p2)
			if not p2.isGlobal then
				callback("Admin Announcement only supports the global event track.")
				return false
			end

			v2 = true
			v3 = p2.timeSeconds == 0
			return true
		end,
		update = function(_, data)
			if v2 and RunService:IsRunning() and not data.isCatchUp and not data.isSeeking and data.timeSeconds > data.previousTimeSeconds then
				for k, keyframe in p.keyframes do
					if not ((keyframe.timeSeconds > data.previousTimeSeconds or v3 and keyframe.timeSeconds == data.previousTimeSeconds) and keyframe.timeSeconds <= data.timeSeconds) then
						continue
					end

					local data2 = keyframe.data
					local duration = getDuration(data2, keyframe, p.keyframes[k + 1]) -- equivalent call inferred; original call site unknown
					announce(data2, duration)
				end

				v3 = false
			end
		end,
		detach = function(_, _: string, _: boolean)
			v2 = false
			v3 = false
		end,
		destroy = function(_, _: string, _: boolean)
			v2 = false
			v3 = false
		end
	}
end

return AdminAnnouncement