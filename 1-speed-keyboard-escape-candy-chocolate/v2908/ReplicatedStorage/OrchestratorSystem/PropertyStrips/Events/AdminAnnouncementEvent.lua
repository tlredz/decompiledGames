local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
require(script.Parent.Parent.Parent.OrchestratorState)

local function ValidateCommand(value)
	if type(value) ~= "table" then
		return false, "Admin announcements must contain a command table."
	end

	if type(value.Text) ~= "string" or value.Text == "" then
		return false, "Admin announcement text must be a non-empty string."
	end

	if #value.Text > 300 then
		return false, "Admin announcement text cannot exceed 300 bytes."
	end

	if value.SenderName ~= nil and type(value.SenderName) ~= "string" then
		return false, "Admin announcement sender name must be a string."
	end

	if value.SenderUserId ~= nil and (type(value.SenderUserId) ~= "number" or value.SenderUserId ~= value.SenderUserId or math.abs(value.SenderUserId) == 1e999 or value.SenderUserId < 0 or value.SenderUserId % 1 ~= 0) then
		return false, "Admin announcement sender user ID must be a non-negative integer."
	end

	if value.IsOwner ~= nil and type(value.IsOwner) ~= "boolean" then
		return false, "Admin announcement owner flag must be a boolean."
	end

	if value.AdminRole ~= nil and type(value.AdminRole) ~= "string" then
		return false, "Admin announcement role must be a string."
	end

	if value.Duration == nil or type(value.Duration) == "number" and value.Duration == value.Duration and math.abs(value.Duration) ~= 1e999 and (value.Duration == -1 or not (value.Duration < 0.1 or value.Duration > 60)) then
		return true, nil
	end

	return false, "Admin announcement duration must be -1 (automatic) or between 0.1 and 60 seconds."
end

local AdminAnnouncementEvent = {}
AdminAnnouncementEvent.Type = "AdminAnnouncementEvent"
AdminAnnouncementEvent.DisplayName = "Admin Announcement"
AdminAnnouncementEvent.GlobalEvent = true
AdminAnnouncementEvent.CreateInitialKeyframe = false
AdminAnnouncementEvent.HasKeyframeEasing = false
AdminAnnouncementEvent.EditableProperties = {
	{
		Path = { "Value", "Text" },
		DisplayName = "Message",
		ValueType = "string",
		Default = "Announcement"
	},
	{
		Path = { "Value", "SenderName" },
		DisplayName = "Sender Name",
		ValueType = "string",
		Default = "BBNO$"
	},
	{
		Path = { "Value", "SenderUserId" },
		DisplayName = "Sender User ID",
		ValueType = "number",
		Default = 1516108345,
		Min = 0,
		Step = 1
	},
	{
		Path = { "Value", "IsOwner" },
		DisplayName = "Owner Badge",
		ValueType = "boolean",
		Default = false
	},
	{
		Path = { "Value", "AdminRole" },
		DisplayName = "Admin Role",
		ValueType = "string",
		Default = "None"
	},
	{
		Path = { "Value", "Duration" },
		DisplayName = "Duration (-1 = Auto)",
		ValueType = "number",
		Default = -1,
		Min = -1,
		Max = 60,
		Step = 0.1
	}
}

function AdminAnnouncementEvent.Supports(p)
	return p == game
end

function AdminAnnouncementEvent.ValidateKeyframe(p)
	return ValidateCommand(p.Value)
end

function AdminAnnouncementEvent.Capture(_)
	return {
		Text = "This Is Message",
		SenderName = "BBNO$",
		SenderUserId = 1516108345,
		IsOwner = false,
		AdminRole = "None",
		Duration = -1
	}
end

function AdminAnnouncementEvent.Evaluate(data)
	if not RunService:IsRunning() or data.IsServer or data.IsSeeking or data.TimePosition <= data.PreviousTimePosition then
		return
	end

	for k, keyframe in data.Strip.Keyframes do
		local v

		if keyframe.Time <= data.TimePosition then
			if keyframe.Time > data.PreviousTimePosition then
				v = true
			elseif keyframe.Time == 0 then
				v = data.PreviousTimePosition == 0
			else
				v = false
			end
		else
			v = false
		end

		if not v then
			continue
		end

		local value = keyframe.Value
		local keyframe2 = data.Strip.Keyframes[k + 1]
		local duration

		if value.Duration == -1 then
			duration = not keyframe2 and 6 or keyframe2.Time - keyframe.Time + 1
		else
			duration = value.Duration
		end

		local v2 = {
			text = value.Text,
			senderName = value.SenderName,
			senderUserId = 0,
			isOwner = 0,
			adminRole = 0,
			Duration = 0
		}
		local senderUserId

		if value.SenderUserId and value.SenderUserId > 0 then
			senderUserId = value.SenderUserId
		end

		v2.senderUserId = senderUserId
		v2.isOwner = value.IsOwner == true
		local adminRole

		if value.AdminRole ~= "" then
			adminRole = value.AdminRole
		end

		v2.adminRole = adminRole
		v2.Duration = duration

		for _, bindableEvent in CollectionService:GetTagged("AdminAnnounceListener") do
			if bindableEvent:IsA("BindableEvent") and bindableEvent:IsDescendantOf(game) then
				bindableEvent:Fire(v2)
			end
		end
	end
end

return AdminAnnouncementEvent