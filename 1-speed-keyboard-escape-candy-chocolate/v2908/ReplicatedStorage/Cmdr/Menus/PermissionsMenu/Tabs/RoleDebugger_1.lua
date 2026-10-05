local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.PermissionsMenu.Types)

local function ClearComponents(object)
	for _, v in object:GetAll() do
		v:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FindGrant(items, allPermission: string)
	for _, item in items do
		if AdminPermissions.permissionGrants(item, allPermission) then
			return item
		end
	end

	return nil
end

return {
	DisplayName = "Role Debugger",
	Permission = "cui.permissions",
	Order = 10,
	Setup = function(object, _)
		local config = AdminPermissions.getConfig()
		local v = {}
		local v2 = ""
		local v3 = "all"
		local v4 = nil
		local v5 = nil

		local function fn() end

		local v6

		if config then
			for k in config.ROLES do
				table.insert(v, k)
			end

			table.sort(v, function(a, b)
				local priority = config.ROLES[a].Priority
				local priority2 = config.ROLES[b].Priority

				if priority == priority2 then
					return a < b
				end

				return priority2 < priority
			end)
			local localPlayer = Players.LocalPlayer

			if localPlayer then
				v6 = AdminPermissions.getRole(localPlayer.UserId)
			else
				v6 = nil
			end

			if not (v6 and config.ROLES[v6]) then
				v6 = v[1]
			end
		else
			v6 = nil
		end

		object:AddTitle(function(object2)
			object2:SetTitle("Inspect permissions by role")
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				local v7 = not (#v > 0) and { "No roles" } or v
				object2:SetText("Role"):SetChoiceList(v7):SetSelected(v6 or v7[1]):SetOnChanged(function(p2)
					if not (config and config.ROLES[p2]) then
						p2 = nil
					end

					v6 = p2
					fn()
				end)
			end)
			p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Results"):SetChoiceList({ "All", "Granted", "Denied" }):SetSelected("All"):SetOnChanged(function(value)
					v3 = string.lower(value)
					fn()
				end)
			end)
		end)
		object:AddField(function(object2)
			object2:SetTextVisible(false):SetPlaceholder("Search permissions or grant sources..."):SetValue(""):SetOnChangedRaw(function(value)
				v2 = string.lower(value)
				fn()
			end)
		end)
		object:AddSplit(function(p)
			v4 = p.LeftComponents:AddField(function(object2)
				object2:SetTextVisible(false):SetValue("Assigned users: 0"):SetEnabled(false)
			end)
			v5 = p.RightComponents:AddField(function(object2)
				object2:SetTextVisible(false):SetValue("Rank: 0"):SetEnabled(false)
			end)
		end)
		local v7 = object:AddField(function(object2)
			object2:SetTextVisible(false):SetValue("Effective: 0 / 0"):SetEnabled(false)
		end)
		local v8 = object:AddText(function(object2)
			object2:SetText("Assigned UserIds: none"):SetTextColor(Color3.fromRGB(165, 175, 190)):SetAutoResize(true)
		end)
		local v9 = object:AddText(function(object2)
			object2:SetText("Configured grants: none"):SetTextColor(Color3.fromRGB(165, 175, 190)):SetAutoResize(true)
		end)
		local v10 = object:AddList(function(object2)
			object2:SetSizeY(245)
		end)

		fn = function()
			for _, v11 in v10.Components:GetAll() do
				v11:Destroy()
			end

			local v11 = v6
			local v12

			if config and v11 then
				v12 = config.ROLES[v11]
			end

			if v11 and v12 then
				local v13 = not config and {} or config.PERMISSIONS[v11] or {}
				local v14 = {}

				for _, userId in v12.UserIds do
					table.insert(v14, (tostring(userId)))
				end

				v4:SetValue((`Assigned users: {#v12.UserIds}`))
				v5:SetValue((`Rank: {v12.Priority}`))
				v8:SetText((`Assigned UserIds: {not (#v14 > 0) and "none" or table.concat(v14, ", ")}`))
				v9:SetText((`Configured grants: {not (#v13 > 0) and "none" or table.concat(v13, ", ")}`))
				local allPermissions = AdminPermissions.getAllPermissions()
				local count = 0
				local v15 = {}

				for _, allPermission in allPermissions do
					local grant = FindGrant(v13, allPermission) -- equivalent call inferred; original call site unknown

					if grant then
						count += 1
					end

					if not ((v3 ~= "granted" or grant) and (v3 ~= "denied" or not grant)) then
						continue
					end

					if not (v2 == "" or string.find(allPermission, v2, 1, true) or grant and string.find(
						string.lower(grant),
						v2,
						1,
						true
					)) then
						continue
					end

					table.insert(v15, {
						Permission = allPermission,
						Grant = grant
					})
				end

				v7:SetValue((`Effective: {count} / {#allPermissions} | Showing: {#v15}`))
				v10.Components:AddTitle(function(object2)
					object2:SetTitle((`Permission results ({#v15})`))
				end)

				if #v15 == 0 then
					v10.Components:AddText(function(object2)
						object2:SetText(#allPermissions == 0 and "No permissions are available." or "No permissions match the current filters."):SetTextColor(Color3.fromRGB(
							150,
							150,
							150
						))
					end)
					return
				end

				for k, v16 in v15 do
					local v17 = v16
					local v18 = k
					v10.Components:AddText(function(object2)
						local grant = v17.Grant
						local v19 = not grant and "no matching grant" or string.lower(grant) == v17.Permission and "exact" or `via {grant}`
						local v20 = object2:SetText((`{grant and "[GRANTED]" or "[DENIED]"} {v17.Permission} - {v19}`)):SetTextXAlignment(Enum.TextXAlignment.Left)
						local v21

						if grant then
							v21 = Color3.fromRGB(105, 220, 135)
						else
							v21 = Color3.fromRGB(220, 115, 115)
						end

						v20:SetTextColor(v21):SetBackgroundColor(Color3.fromRGB(38, 43, 52)):SetBackgroundTransparency(v18 % 2 == 0 and 0.88 or 0.97)
					end)
				end
			else
				v4:SetValue("Assigned users: 0")
				v5:SetValue("Rank: 0")
				v7:SetValue("Effective: 0 / 0")
				v8:SetText("Assigned UserIds: none")
				v9:SetText("Configured grants: none")
				v10.Components:AddText(function(object2)
					object2:SetText("No role configuration is available."):SetTextColor(Color3.fromRGB(255, 170, 90))
				end)
			end
		end

		fn()
	end
}