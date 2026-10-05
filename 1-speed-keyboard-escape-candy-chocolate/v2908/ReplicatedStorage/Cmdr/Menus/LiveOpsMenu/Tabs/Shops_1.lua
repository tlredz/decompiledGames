local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local Lib = require(script.Parent.Parent.Lib)
require(script.Parent.Parent.Types)
return {
	DisplayName = "Shops",
	Permission = "cui.liveops.shops",
	Order = 10,
	Setup = function(object, _)
		if not RunService:IsClient() then
			return
		end

		local NotificationSystem = require(ReplicatedStorage.NotificationSystem)
		local scope = "Server"
		local mode = "normal"
		local count = 0
		local flag = false
		local v3 = object:AddField(function(object2)
			object2:SetText("Shop APIs"):SetValue("Loading..."):SetEnabled(false)
		end)
		local v4 = object:AddField(function(object2)
			object2:SetText("Details"):SetValue(""):SetEnabled(false)
		end)
		object:AddSplit(function(p)
			p.LeftComponents:AddDropdown(function(object2)
				object2:SetText("Scope"):SetChoiceList({ "Server", "Global" }):SetSelected(scope):SetOnChanged(function(p2)
					scope = p2
				end)
			end)
			p.RightComponents:AddDropdown(function(object2)
				object2:SetText("Item mode"):SetChoiceList({ "normal", "mythic", "secret" }):SetSelected(mode):SetOnChanged(function(p2)
					mode = p2
				end)
			end)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function Render(p)
			v3:SetValue(p.Shops.Status)
			v4:SetValue(p.Shops.Detail)
		end

		local function Refresh()
			if flag or not Lib.GetSnapshot then
				return
			end

			count += 1
			local v5 = count
			Lib.GetSnapshot:Fire({}):andThen(function(p)
				if flag or v5 ~= count or not p then
					return
				end

				Render(p) -- equivalent call inferred; original call site unknown
			end):catch(function(p)
				if flag or v5 ~= count then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps refresh failed: {tostring(p)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		local function Act(p)
			if flag or not Lib.ExecuteAction then
				return
			end

			Lib.ExecuteAction:Fire(p):andThen(function(data)
				if flag or not data then
					return
				end

				Render(data.Snapshot) -- equivalent call inferred; original call site unknown
				local message = data.Message
				local v6

				if data.Ok then
					v6 = Color3.fromRGB(100, 255, 100)
				else
					v6 = Color3.fromRGB(255, 100, 100)
				end

				NotificationSystem:ShowGeneralNotification(message, v6, 4)

				if data.Ok then
					task.delay(0.5, Refresh)
				end
			end):catch(function(p2)
				if flag then
					return
				end

				NotificationSystem:ShowGeneralNotification(
					`LiveOps action failed: {tostring(p2)}`,
					Color3.fromRGB(255, 100, 100),
					4
				)
			end)
		end

		object:AddSplit(function(p)
			p.LeftComponents:AddButton(function(object2)
				object2:SetButtonText("Restock item shop"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					Act({
						System = "ItemShop",
						Action = "restock",
						Scope = scope,
						Mode = mode
					})
				end)
			end)
			p.RightComponents:AddButton(function(object2)
				object2:SetButtonText("Restock summer shop"):SetYSize(22):SetEnabledPermission("cui.liveops.manage"):DoNeedConfirmation(true):SetButtonCallback(function()
					Act({
						System = "SummerShop",
						Action = "restock"
					})
				end)
			end)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("Refresh shop APIs"):SetYSize(22):SetEnabledPermission("cui.liveops.shops"):SetButtonCallback(Refresh)
		end)
		v3:GetUI().Destroying:Connect(function()
			flag = true
			count += 1
		end)
		Refresh()
	end
}