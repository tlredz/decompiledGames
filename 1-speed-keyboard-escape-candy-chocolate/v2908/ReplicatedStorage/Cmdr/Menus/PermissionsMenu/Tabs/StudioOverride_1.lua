local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
require(ReplicatedStorage.CUI)
require(ReplicatedStorage.Cmdr.Menus.PermissionsMenu.Types)

local function ClearComponents(object)
	for _, v in object:GetAll() do
		v:Destroy()
	end
end

local function GetSelectedPermissions(items)
	local result = {}

	for k, item in items do
		if item then
			table.insert(result, k)
		end
	end

	table.sort(result)
	return result
end

local StudioOverride = {}
StudioOverride.DisplayName = "Studio Override"
StudioOverride.Permission = "cui.permissions"
StudioOverride.Order = 30

function StudioOverride.IsAvailable()
	return RunService:IsStudio()
end

function StudioOverride.Setup(object, _)
	if not RunService:IsStudio() then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local allPermissions = AdminPermissions.getAllPermissions()
	local v = {}

	for _, v2 in AdminPermissions.getPermissions(localPlayer.UserId) do
		v[v2] = true
	end

	local v2 = ""

	local function fn() end

	local v3 = nil
	object:AddTitle(function(object2)
		object2:SetTitle("Temporary Studio permissions")
	end)
	object:AddText(function(object2)
		object2:SetText("Select the exact grants to use for this Studio session, then apply the override."):SetTextColor(Color3.fromRGB(
			255,
			190,
			90
		)):SetAutoResize(true)
	end)
	object:AddField(function(object2)
		object2:SetTextVisible(false):SetPlaceholder("Search permissions..."):SetValue(""):SetOnChangedRaw(function(value)
			v2 = string.lower(value)
			fn()
		end)
	end)
	local v4 = object:AddField(function(object2)
		object2:SetTextVisible(false):SetValue("Selected: 0"):SetEnabled(false)
	end)
	local v5 = object:AddField(function(object2)
		object2:SetTextVisible(false):SetValue("Using hardcoded permissions"):SetEnabled(false)
	end)
	local v6 = object:AddList(function(object2)
		object2:SetSizeY(260)
	end)

	fn = function()
		local scroll = v6:GetScroll()

		for _, v7 in v6.Components:GetAll() do
			v7:Destroy()
		end

		local selectedPermissions = GetSelectedPermissions(v)
		v4:SetValue((`Selected: {#selectedPermissions} / {#allPermissions}`))
		v3:SetValue(table.concat(selectedPermissions, "\n"))
		local count = 0

		for _, allPermission in allPermissions do
			if not (v2 == "" or string.find(allPermission, v2, 1, true)) then
				continue
			end

			count += 1
			local v8 = allPermission
			v6.Components:AddCheckbox(function(object2)
				object2:SetText(v8):SetValue(v[v8] == true):SetOnChanged(function(p)
					v[v8] = p and true or nil
					local selectedPermissions2 = GetSelectedPermissions(v)
					v4:SetValue((`Selected: {#selectedPermissions2} / {#allPermissions}`))
					v3:SetValue(table.concat(selectedPermissions2, "\n"))
				end)
			end)
		end

		if count == 0 then
			v6.Components:AddText(function(object2)
				object2:SetText("No permissions match the current search."):SetTextColor(Color3.fromRGB(150, 150, 150))
			end)
		end

		v6:SetScroll(scroll)
	end

	object:AddSplit(function(p)
		p.LeftComponents:AddButton(function(object2)
			object2:SetButtonText("Select all"):SetButtonCallback(function()
				for _, allPermission in allPermissions do
					v[allPermission] = true
				end

				fn()
			end)
		end)
		p.RightComponents:AddButton(function(object2)
			object2:SetButtonText("Clear all"):SetButtonCallback(function()
				table.clear(v)
				fn()
			end)
		end)
	end)
	object:AddSplit(function(p)
		p.LeftComponents:AddButton(function(object2)
			object2:SetButtonText("Apply override"):SetButtonCallback(function()
				local selectedPermissions = GetSelectedPermissions(v)
				v5:SetValue("Applying...")
				AdminPermissions.setStudioPermissions(selectedPermissions):andThen(function(p2, value)
					v5:SetValue(not p2 and (value or "Override failed") or `Override active ({#selectedPermissions} grants)`)
				end):catch(function(p2)
					v5:SetValue((`Override failed: {p2}`))
				end)
			end)
		end)
		p.RightComponents:AddButton(function(object2)
			object2:SetButtonText("Restore hardcoded"):SetButtonCallback(function()
				v5:SetValue("Restoring...")
				AdminPermissions.setStudioPermissions(nil):andThen(function(p2, value)
					if p2 then
						table.clear(v)

						for _, v7 in AdminPermissions.getPermissions(localPlayer.UserId) do
							v[v7] = true
						end

						fn()
					end

					v5:SetValue(p2 and "Using hardcoded permissions" or value or "Restore failed")
				end):catch(function(p2)
					v5:SetValue((`Restore failed: {p2}`))
				end)
			end)
		end)
	end)
	v3 = object:AddField(function(object2)
		object2:SetTextVisible(false):SetDoSelectAllOnFocus(true):SetPlaceholder("No override permissions selected."):SetValue("")
	end)
	fn()
end

return StudioOverride