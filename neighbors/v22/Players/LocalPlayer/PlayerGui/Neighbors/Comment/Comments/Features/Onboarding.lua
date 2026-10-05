local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Helper = require(ReplicatedStorage.Modules.Helper)
local Stats = require(ReplicatedStorage.Modules.Stats)
local Network = require(ReplicatedStorage.Modules.Network)
local frame = script:FindFirstAncestorOfClass("Frame")
local v = nil
Stats.Onboarding.FirstComment = false
Stats.Onboarding.FreeComments = 0
frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if v then
		v:Destroy()
		v = nil
	end

	if frame.Visible then
		if Stats.Onboarding.FirstComment then
			frame.Corner.Create.Blink.Visible = false
		else
			v = Helper:AddArrow(frame.Corner.Create)
			v:SetOffset(Vector2.new(-8, 0))
			v.Janitor:Add(frame.AddComment:GetPropertyChangedSignal("Visible"):Connect(function()
				local visible = frame.AddComment.Visible
				v:SetEnabled(not visible)
				frame.Corner.Create.Blink.Visible = not visible
			end))
			frame.Corner.Create.Blink.Visible = true
		end
	end
end)
Network:listen("Onboarding/FirstComment", function(firstComment: boolean)
	Stats.Onboarding.FirstComment = firstComment
end)
Network:listen("Onboarding/UpdateFreeComments", function(freeComments: number)
	Stats.Onboarding.FreeComments = freeComments
end)
return nil