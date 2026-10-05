local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local FabAdminAnnouncement = require(ReplicatedStorage._FRAMEWORK.Features.Specials.FabAdminAnnouncement)
require(script.Parent.Parent.Parent.Parent.types.Property)
require(script.Parent.Parent.Parent.Parent.types.Save)
require(script.Parent.Parent.Parent.Parent.types.Strip)
local dataTemplate = {
	text = "The concert begins in five minutes. Get ready!",
	duration = -1,
	typewriterDuration = 0.125
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getDuration(data, keyframe, keyframe2)
	if data.duration >= 0 then
		return data.duration
	end

	if keyframe2 == nil then
		return 6
	end

	return keyframe2.timeSeconds - keyframe.timeSeconds + 0.1
end

local FabAdminAnnouncement_2 = {}
FabAdminAnnouncement_2.stripType = "property"
FabAdminAnnouncement_2.playbackMode = "custom"
FabAdminAnnouncement_2.propertyName = "Fab Admin Announcement"
FabAdminAnnouncement_2.context = "client"
FabAdminAnnouncement_2.catchUpPolicies = { "skip" }
FabAdminAnnouncement_2.dataTemplate = dataTemplate
FabAdminAnnouncement_2.supportsGlobal = true

function FabAdminAnnouncement_2.buildEditor(p, state, _)
	p.Components:AddField(function(object)
		object:SetText("Message"):SetValue(state.text):SetOnChangedUnfocus(function(text: string)
			state.text = text
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Duration (-1 = Next Keyframe)"):SetValue(state.duration):SetNumberFilter(-1, 60):SetOnChangedUnfocus(function(duration: number)
			state.duration = duration
		end)
	end)
	p.Components:AddNumberField(function(object)
		object:SetText("Typewriter Duration"):SetValue(state.typewriterDuration):SetNumberFilter(0):SetOnChangedUnfocus(function(typewriterDuration: number)
			state.typewriterDuration = typewriterDuration
		end)
	end)
end

function FabAdminAnnouncement_2.supports(_)
	return false
end

function FabAdminAnnouncement_2.capture(_, _)
	return table.clone(dataTemplate)
end

function FabAdminAnnouncement_2.createRuntime(p, callback)
	local v2 = false
	local v3 = false
	return {
		attach = function(_, _, p2)
			if not p2.isGlobal then
				callback("Fab Admin Announcement only supports the global event track.")
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
					local announce = FabAdminAnnouncement.announce
					local v4 = {
						text = data2.text,
						duration = 0,
						typewriterDuration = 0
					}
					local duration = getDuration(data2, keyframe, p.keyframes[k + 1]) -- equivalent call inferred; original call site unknown
					v4.duration = duration
					v4.typewriterDuration = data2.typewriterDuration
					announce(v4)
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

return FabAdminAnnouncement_2