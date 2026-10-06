local ReplicatedStorage = game:GetService("ReplicatedStorage")
local serverFunctions = ReplicatedStorage:WaitForChild("StudioLiteFolder"):WaitForChild("ServerFunctions")
local parent = script.Parent
local nearShareTextLabel = parent.Parent:WaitForChild("NearShareTextLabel")
local deleteButton = parent.Parent:WaitForChild("DeleteButton")
local parent2 = parent.Parent.Parent
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local shareWithFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui"):WaitForChild("ShareWithFrame")
local scrollingFrame = shareWithFrame:WaitForChild("ScrollingFrame")
local shareWithTemplateTextButton = shareWithFrame:WaitForChild("ShareWithTemplateTextButton")
local connections = {}
local count = 0

function DialogOk(text, text2)
	_G.DialogAnswer = "?"
	local dialogOkFrame = localPlayer:WaitForChild("PlayerGui"):WaitForChild("StudioGui", 9):WaitForChild("DialogOkFrame")
	local okTextLabel = dialogOkFrame:WaitForChild("OkTextLabel")
	okTextLabel.Text = text
	local okTextButton = dialogOkFrame:WaitForChild("OkTextButton")
	okTextButton.Text = text2
	dialogOkFrame.Visible = true

	while _G.DialogAnswer == "?" do
		task.wait(0.2)
	end
end

local PolicyService = game:GetService("PolicyService")
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
end)
local v = false

if success then
	v = result.AreAdsAllowed and true or v
else
	warn("PolicyService error: " .. result)
end

parent.Activated:Connect(function()
	if parent.Text == "Share" then
		if not v then
			DialogOk("Roblox Policy: Your account must be 13+ to share unpublished/unmoderated content.", "Ok")
			return
		end

		if shareWithFrame.Visible then
			shareWithFrame.Visible = false
			return
		end

		for _, child in pairs(scrollingFrame:GetChildren()) do
			if child.ClassName == "TextButton" then
				child:Destroy()
			end
		end

		shareWithFrame.Visible = true
		local userId = localPlayer.UserId
		local v2 = userId < 0 and 1121973131 or userId

		for i = 1, count do
			if connections[i] then
				connections[i]:Disconnect()
			end
		end

		connections = {}
		count = 0
		local success2, result2 = pcall(function()
			return Players:GetFriendsAsync(v2)
		end)

		if success2 then
			local success3, friendsOnline = pcall(localPlayer.GetFriendsOnline, localPlayer, 200)
			local v3 = {}

			if success3 then
				for _, v4 in pairs(friendsOnline) do
					v3[v4.VisitorId] = 1
				end
			end

			while true do
				local currentPage = result2:GetCurrentPage()

				for _, v4 in pairs(currentPage) do
					local v5 = v3[v4.Id] and " 🎮 " or ""
					local clone = shareWithTemplateTextButton:Clone()

					if v4.Username == v4.DisplayName then
						clone.Name = v5 .. v4.Username:upper()
						clone.Text = v5 .. "@" .. v4.Username
					else
						clone.Name = v5 .. v4.DisplayName:upper()
						clone.Text = v5 .. v4.DisplayName .. "@" .. v4.Username
					end

					local userIdValue = clone:WaitForChild("UserIdValue")
					userIdValue.Value = v4.Id
					clone.Parent = scrollingFrame
					clone.Visible = true
					count += 1
					local v6 = v4
					connections[count] = clone.Activated:Connect(function()
						shareWithFrame.Visible = false
						parent.Visible = false
						nearShareTextLabel.Text = "Sharing..."
						deleteButton.Visible = false
						serverFunctions:InvokeServer("ShareWith", v6.Id, parent2.Name:match("%a*(%d+)"))
						parent.Text = "Unshare"
						nearShareTextLabel.Text = "Shared with " .. clone.Text
						parent.Visible = true
					end)
				end

				if result2.IsFinished then
					break
				end

				task.wait()
				result2:AdvanceToNextPageAsync()
			end
		end
	elseif parent.Text == "Unshare" then
		parent.Visible = false
		parent.Text = "Share"
		nearShareTextLabel.Text = "Unsharing..."
		serverFunctions:InvokeServer("Unshare", (parent2.Name:match("%a*(%d+)")))
		nearShareTextLabel.Text = ""
		parent.Visible = true
		deleteButton.Visible = true
	elseif parent.Text == "Decline" then
		local match, v2 = parent2.Name:match("%a*(%d+)_(%d+)")
		parent2:Destroy()
		serverFunctions:InvokeServer("Decline", match, v2)
	end
end)