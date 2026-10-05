local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
require(ReplicatedStorage.packages.Net)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local parent = script.Parent
local visible2 = true
local flag = false
local v2 = nil
DataController.PlayerDataReplicator:Observe({ "Valentides", "AcceptingDuos" }, function(visible)
	visible2 = visible

	if flag then
		parent.Visible = visible
	end
end)

local function UpdateButtonInfo()
	flag = true
	parent.Visible = visible2

	if v2 then
		parent.Icon.Image = v2.Thumbnail or ""
		parent.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		parent.DisplayName.Text = v2.DisplayName
	else
		parent.Icon.Image = "rbxassetid://139336345163796"
		parent.Icon.ImageColor3 = Color3.fromRGB(255, 167, 255)
		parent.DisplayName.Text = "Add Duo"
	end
end

local v3 = 0
DataController.PlayerDataReplicator:Observe({ "Valentides", "Duo" }, function(p)
	local now = os.clock()
	v3 = now

	if p then
		local playerByUserId = Players:GetPlayerByUserId(p)

		if playerByUserId then
			v2 = {
				Username = playerByUserId.Name,
				DisplayName = playerByUserId.DisplayName,
				Thumbnail = `rbxthumb://type=AvatarHeadShot&id={p}&w=180&h=180`
			}
		else
			local v4 = nil

			while true do
				local success, result = pcall(function()
					v4 = UserService:GetUserInfosByUserIdsAsync({ p })[1]
				end)

				if not (success or result:find("HTTP 429")) then
					warn((`Failed to load duo info: {result}`))
					break
				end

				if not success then
					task.wait(15)
				end

				if v4 ~= nil or v3 ~= now then
					break
				end
			end

			if v3 ~= now then
				return
			end

			if v4 then
				v2 = {
					Username = v4.Username,
					DisplayName = v4.DisplayName,
					Thumbnail = `rbxthumb://type=AvatarHeadShot&id={p}&w=180&h=180`
				}
			else
				v2 = {
					Username = "???",
					DisplayName = "???",
					Thumbnail = `rbxthumb://type=AvatarHeadShot&id={p}&w=180&h=180`
				}
			end
		end
	else
		v2 = nil
	end

	UpdateButtonInfo()
end)
parent.MouseButton1Click:Connect(function()
	parent.Parent.Parent.ValentidesDuo.Visible = not parent.Parent.Parent.ValentidesDuo.Visible
end)