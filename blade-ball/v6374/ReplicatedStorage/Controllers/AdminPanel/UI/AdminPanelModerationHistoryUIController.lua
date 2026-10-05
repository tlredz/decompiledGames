local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local actions = require3(ReplicatedStorage2.Shared.AdminPanel).Actions
local v2 = require3(ReplicatedStorage2.Controllers.AdminPanel.AdminPanelUIController)
local scrollingFrame = v2.AdminPanelUI.Window.Content.Pages.ModerationHistory.Console.ScrollingFrame
local template = scrollingFrame.UIListLayout.Template

local function observeReplionPath(object, p, callback)
	callback(object:Get(p), nil)
	return (object:OnDataChange(function()
		callback(object:Get(p), nil)
	end))
end

local function formatTimestamp(timestamp)
	if typeof(timestamp) == "number" then
		return os.date("%m/%d/%Y\n%H:%M:%S", timestamp)
	end

	if typeof(timestamp) == "string" then
		local match, v3, v4, v5, v6, v7 = timestamp:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")

		if match then
			return string.format("%s/%s/%s\n%s:%s:%s", v3, v4, match, v5, v6, v7)
		end
	end

	return "Unknown"
end

return {
	Start = function(_)
		v2.LoadUserAction.Signal:Connect(function(p)
			local state = v.State({})
			local userTrove = v2.UserTrove
			local replion = p.Replion

			local function fn(p2)
				if not p2 then
					if typeof(actions.Moderation.SyncBanHistory) == "function" then
						state:Set(actions.Moderation.SyncBanHistory() or {})
					else
						state:Set(actions.Moderation.SyncBanHistory:Call() or {})
					end
				end
			end

			fn(replion:Get("Data.ModerationHistorySynced"), nil)
			local v3 = "Data.ModerationHistorySynced"
			userTrove:Add((replion:OnDataChange(function()
				fn(replion:Get(v3), nil)
			end)))
			v.Computed(function(callback)
				local v4 = callback(state)

				for _, frame in scrollingFrame:GetChildren() do
					if frame:IsA("Frame") then
						frame:Destroy()
					end
				end

				for k, v5 in v4 do
					local clone = template:Clone()
					clone.Name = "Entry_" .. k
					local moderator

					if typeof(v5.Moderator) == "string" and v5.Moderator ~= "Unknown" then
						moderator = v5.Moderator
					else
						moderator = nil
					end

					local moderator2

					if typeof(v5.Moderator) == "number" then
						moderator2 = v5.Moderator
					else
						moderator2 = nil
					end

					if moderator2 then
						pcall(function()
							moderator = Players:GetNameFromUserIdAsync(moderator2)
						end)
					elseif moderator then
						pcall(function()
							moderator2 = Players:GetUserIdFromNameAsync(moderator)
						end)
					end

					if moderator then
						clone.User.TextLabel.Text = moderator or "Unknown"
					end

					if moderator2 then
						local v6 = clone
						pcall(function()
							v6.ProfileImage.Icon.Image = Players:GetUserThumbnailAsync(
								moderator2,
								Enum.ThumbnailType.HeadShot,
								Enum.ThumbnailSize.Size48x48
							)
						end)
					end

					clone.Date.TextLabel.Text = formatTimestamp(v5.Timestamp)
					clone.Action.TextLabel.Text = v5.Type or "Unknown"
					clone.Reason.TextLabel.Text = v5.Reason or ""
					clone.Length.TextLabel.Text = v5.Length or "Permanent"
					clone.Parent = scrollingFrame
				end
			end)
		end)
	end
}