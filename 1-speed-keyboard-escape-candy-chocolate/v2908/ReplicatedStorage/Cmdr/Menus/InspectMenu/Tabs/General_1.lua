local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminRemote = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminRemote)
require(ReplicatedStorage.CUI)
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local ProfileAccess = require(script.Parent.Parent.ProfileAccess)
require(ReplicatedStorage.Cmdr.Menus.InspectMenu.Types)

local function FormatDuration(p: number)
	return (`{math.floor(p / 86400)}d {math.floor(p % 86400 / 3600)}h {math.floor(p % 3600 / 60)}m {math.floor(p % 60)}s`)
end

local clientEvent = AdminRemote.RegisterClientEvent(
	`Inspect_{script.Name}_GetGeneral`,
	"cui.inspect.general",
	false,
	function(_, p)
		local v = ProfileAccess.Read(p.UserId)
		local userId = tostring(p.UserId)
		local displayName = userId
		local accountAge = 0
		local localPlayer = ProfileAccess.GetLocalPlayer(p.UserId)

		if localPlayer then
			userId = localPlayer.Name
			displayName = localPlayer.DisplayName
			accountAge = localPlayer.AccountAge
		else
			pcall(function()
				userId = Players:GetNameFromUserIdAsync(p.UserId)
				displayName = userId
			end)
		end

		local data = v.Data or {}
		local v2 = {
			Ok = v.Ok,
			Message = v.Message,
			Username = userId,
			DisplayName = displayName,
			Role = ProfileAccess.GetRole(p.UserId),
			Presence = ProfileAccess.GetPresence(v),
			FirstJoin = tonumber(data.firstJoin) or 0,
			LastUpdate = v.LastUpdate,
			TimePlayed = tonumber(data.timePlayed) or 0,
			AccountAge = accountAge,
			DataVersion = tonumber(data.DataVersion) or 0,
			PurchaseCount = type(data.PurchaseHistory) == "table" and #data.PurchaseHistory or 0,
			ItemCount = type(data.Items) == "table" and #data.Items or 0,
			EquippedItemCount = type(data.EquippedItems) == "table" and #data.EquippedItems or 0,
			Level = tonumber(data.Level) or 0,
			Wins = tonumber(data.Wins) or 0,
			Rebirths = tonumber(data.Rebirths) or 0,
			JobId = 0
		}
		local jobId

		if v.IsOnlineElsewhere then
			jobId = v.ServerJobId
		end

		v2.JobId = jobId
		return v2
	end
)
return {
	DisplayName = "General",
	Permission = "cui.inspect.general",
	Order = 0,
	Setup = function(object, data)
		local v = nil
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil
		local v8 = nil
		local v9 = nil
		local v10 = nil
		object:AddSplit(function(object2)
			object2:SetLeftSizeAbsolute(66)
			v = object2.LeftComponents:AddImage(function(object3)
				object3:SetHeight(66):SetPaddingScale(0.08)
			end)
			v2 = object2.RightComponents:AddField(function(object3)
				object3:SetText("UserId"):SetValue((tostring(data.UserId))):SetEnabled(false)
			end)
			v3 = object2.RightComponents:AddField(function(object3)
				object3:SetText("Username"):SetValue("Loading..."):SetEnabled(false)
			end)
			v4 = object2.RightComponents:AddField(function(object3)
				object3:SetText("Display name"):SetValue("Loading..."):SetEnabled(false)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Information")
		end)
		object:AddSplit(function(p)
			v6 = p.LeftComponents:AddTime(function(object2)
				object2:SetText("First joined"):SetTime(0):SetEnabled(false)
			end)
			v8 = p.RightComponents:AddField(function(object2)
				object2:SetText("Time played"):SetValue("Loading..."):SetEnabled(false)
			end)
			v7 = p.LeftComponents:AddTime(function(object2)
				object2:SetText("Last Data Save"):SetTime(0):SetEnabled(false)
			end)
			v9 = p.RightComponents:AddField(function(object2)
				object2:SetText("Roblox account age"):SetValue("Loading..."):SetEnabled(false)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Saved profile")
		end)
		local v11 = object:AddField(function(object2)
			object2:SetText("Progression"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v12 = object:AddField(function(object2)
			object2:SetText("Inventory summary"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v13 = object:AddField(function(object2)
			object2:SetText("Data version"):SetValue("Loading..."):SetEnabled(false)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Others")
		end)
		object:AddSplit(function(p)
			v10 = p.LeftComponents:AddField(function(object2)
				object2:SetText("Presence"):SetValue("Loading..."):SetEnabled(false)
			end)
			v5 = p.RightComponents:AddField(function(object2)
				object2:SetText("Admin role"):SetValue("Loading..."):SetEnabled(false)
			end)
		end)
		local v14 = object:AddField(function(object2)
			object2:SetText("Server JobId"):SetValue("Unavailable while offline"):SetEnabled(false)
		end)

		local function Refresh()
			if RunService:IsServer() or not clientEvent then
				return
			end

			clientEvent:Fire({
				UserId = data.UserId
			}):andThen(function(data2)
				v2:SetValue((tostring(data.UserId)))
				v3:SetValue((`@{data2.Username}`))
				v4:SetValue(data2.DisplayName)
				v10:SetValue(data2.Presence)
				v5:SetValue(data2.Role)
				local color = Color3.fromRGB(255, 100, 100)

				if data2.Presence == "In Server" then
					color = Color3.fromRGB(100, 255, 100)
				elseif data2.Presence == "Another Server" then
					color = Color3.fromRGB(255, 255, 100)
				end

				data.Window:SetIndicatorColor(color)
				v6:SetTime(data2.FirstJoin)
				v7:SetTime(data2.LastUpdate)
				local v15 = v8
				local timePlayed = data2.TimePlayed
				v15:SetValue((`{math.floor(timePlayed / 86400)}d {math.floor(timePlayed % 86400 / 3600)}h {math.floor(timePlayed % 3600 / 60)}m {math.floor(timePlayed % 60)}s`))
				v9:SetValue(not (data2.AccountAge > 0) and "Unavailable while offline" or `{data2.AccountAge} days`)

				if data2.Ok then
					v11:SetValue((`Level {data2.Level} | {Numbers.formatNumber(data2.Wins)} Wins | {data2.Rebirths} Rebirths`))
					v12:SetValue((`{data2.ItemCount} stored | {data2.EquippedItemCount} equipped | {data2.PurchaseCount} purchases`))
					v13:SetValue((tostring(data2.DataVersion)))
				else
					v11:SetValue(data2.Message)
					v12:SetValue("No profile data available")
					v13:SetValue("Unknown")
				end

				v14:SetValue(data2.JobId or "Not in another server")
			end):catch(function()
				data.Window:SetIndicatorColor(Color3.fromRGB(255, 100, 100))
			end)
		end

		object:AddButton(function(object2)
			object2:SetButtonText("Refresh information"):SetEnabledPermission("cui.inspect.general"):SetButtonCallback(Refresh)
		end)

		if RunService:IsClient() then
			task.spawn(function()
				local success, userThumbnailAsync = pcall(
					Players.GetUserThumbnailAsync,
					Players,
					data.UserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)

				if success then
					v:SetImage(userThumbnailAsync)
				end
			end)
			data.PresenceChanged:Connect(Refresh)
		end

		Refresh()
	end
}