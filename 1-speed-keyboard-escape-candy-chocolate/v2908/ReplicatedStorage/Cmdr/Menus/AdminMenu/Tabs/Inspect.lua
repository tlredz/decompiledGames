local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.AdminMenu.Types)
return {
	DisplayName = "Inspect",
	Permission = "cui.admin.inspect",
	Order = 30,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local v = ""

		local function onPlayerAdded() end

		local v2 = ""

		-- equivalent calls inferred from this helper; original call sites unknown
		local function OpenInspect(p: number)
			local InspectMenu = require(ReplicatedStorage.Cmdr.Menus.InspectMenu)
			InspectMenu.Open(p)
		end

		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("search players..."):SetValue(""):SetOnChangedRaw(function(value)
				v2 = string.lower(value)
				onPlayerAdded()
			end)
		end)
		local v3 = object:AddList(function(object2)
			object2:SetSizeY(210)
		end)

		onPlayerAdded = function()
			for _, v4 in v3.Components:GetAll() do
				v4:Destroy()
			end

			local players = Players:GetPlayers()
			table.sort(players, function(a, b)
				return string.lower(a.Name) < string.lower(b.Name)
			end)

			for _, player in players do
				local v4 = string.lower((`{player.Name}_{player.UserId}`))

				if not (v2 == "" or string.find(v4, v2, 1, true)) then
					continue
				end

				local v5 = player
				v3.Components:AddButton(function(object2)
					object2:SetButtonText((`{v5.Name}_{v5.UserId}`)):SetYSize(22):SetEnabledPermission("cui.admin.inspect"):SetButtonCallback(function()
						OpenInspect(v5.UserId) -- equivalent call inferred; original call site unknown
					end)
				end)
			end
		end

		object:AddSplit(function(object2)
			object2:SetLeftSizePercent(0.75)
			object2.LeftComponents:AddField(function(object3)
				object3:SetTextVisible(false):SetPlaceholder("username or userid... (support players in other server / disconnected)"):SetOnChangedRaw(function(p)
					v = p
				end)
			end)
			object2.RightComponents:AddButton(function(object3)
				object3:SetButtonText("Inspect"):SetYSize(22):SetEnabledPermission("cui.admin.inspect"):SetButtonCallback(function()
					local v4 = string.match(v, "^%s*(.-)%s*$") or ""

					if string.sub(v4, 1, 1) == "@" then
						v4 = string.sub(v4, 2)
					end

					if v4 == "" then
						return
					end

					local userIdFromNameAsync = tonumber(v4)

					if not userIdFromNameAsync then
						local success
						success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, v4)

						if not success then
							NotificationSystem:ShowGeneralNotification(
								`Player not found: {v4}`,
								Color3.fromRGB(255, 100, 100),
								4
							)
							return
						end
					end

					if userIdFromNameAsync and userIdFromNameAsync > 0 then
						OpenInspect(math.floor(userIdFromNameAsync)) -- equivalent call inferred; original call site unknown
					end
				end)
			end)
		end)
		local playerAddedConnection = Players.PlayerAdded:Connect(onPlayerAdded)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function()
			task.defer(onPlayerAdded)
		end)
		v3:GetUI().Destroying:Connect(function()
			playerAddedConnection:Disconnect()
			playerRemovingConnection:Disconnect()
		end)
		onPlayerAdded()
	end
}