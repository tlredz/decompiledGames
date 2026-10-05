local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v2 = require3(ReplicatedStorage2.Shared.Statable)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local console = Players.LocalPlayer.PlayerGui:WaitForChild("ModerationHistory").Console
local list = console.List
local close = console.Close
local template = list.UIListLayout.Template
local state = v2.State({})
local ModerationHistoryController = {}

local function formatTimestamp(timestamp)
	if typeof(timestamp) == "number" then
		return os.date("%m/%d/%Y\n%H:%M:%S", timestamp)
	end

	if typeof(timestamp) == "string" then
		local match, v4, v5, v6, v7, v8 = timestamp:match("(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)")

		if match then
			return string.format(
				"%s/%s/%s\n%s:%s:%s",
				v4 or "00",
				v5 or "00",
				match or "0000",
				v6 or "00",
				v7 or "00",
				v8 or "00"
			)
		end
	end

	return "Unknown"
end

function ModerationHistoryController:Start()
	v3:Connect("Conch/ModLogs/View", function(p: number, p2: string)
		local v4, v5 = self:Open(p, p2)
		v3:RemoteEvent("Conch/ModLogs/View/Response"):FireServer(v4, p2, v5)
	end)
	xpcall(function()
		v2.Computed(function(callback)
			local v4 = callback(state)

			if not (v4 and v4.Logs) then
				return nil
			end

			self:Clear()
			local text = "Safe"

			if #v4.Logs > 0 then
				console.NoLogs.Visible = false
				text = v4.Logs[1].Type == "Banned" and "Banned" or "Unbanned"

				for k, log in v4.Logs do
					local clone = template:Clone()
					clone.Name = "Entry_" .. k
					local moderator

					if typeof(log.Moderator) == "string" and log.Moderator ~= "Unknown" then
						moderator = log.Moderator
					else
						moderator = nil
					end

					local moderator2

					if typeof(log.Moderator) == "number" then
						moderator2 = log.Moderator
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

					if moderator2 then
						local v6 = clone
						pcall(function()
							v6.ProfileImage.Image = Players:GetUserThumbnailAsync(
								moderator2,
								Enum.ThumbnailType.HeadShot,
								Enum.ThumbnailSize.Size100x100
							)
						end)
					end

					clone.User.TextLabel.Text = moderator or "Unknown"
					clone.Date.TextLabel.Text = formatTimestamp(log.Timestamp)
					clone.Action.TextLabel.Text = log.Type or "Unknown"
					clone.Reason.TextLabel.Text = log.Reason or ""
					clone.Length.TextLabel.Text = log.Length or "Permanent"
					clone.Parent = list
				end
			else
				console.NoLogs.Visible = true
			end

			console.Username.Text = v4.Name
			console.Status.Text = text
			local status = console.Status
			local textColor

			if text == "Banned" then
				textColor = Color3.fromRGB(255, 89, 89)
			else
				textColor = Color3.fromRGB(93, 255, 98)
			end

			status.TextColor3 = textColor
			return nil
		end)
	end, warn)
	close.Activated:Connect(self.Close)
end

function ModerationHistoryController:Open(userId: number, value: string?)
	local v4, logs = v3:Invoke("ModLogs/Get", userId)

	if not (v4 and logs) then
		return false, logs
	end

	state:Set({
		UserId = userId,
		Name = value or "Unknown",
		Logs = logs
	})

	if not v:IsOpen("ModerationHistory") then
		v:Open("ModerationHistory")
	end

	return true
end

function ModerationHistoryController:Clear()
	for _, frame in list:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function ModerationHistoryController.Close()
	v:Close("ModerationHistory")
	ModerationHistoryController:Clear()
end

return ModerationHistoryController