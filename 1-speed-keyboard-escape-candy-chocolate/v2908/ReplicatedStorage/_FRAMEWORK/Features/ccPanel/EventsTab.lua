local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CUI)
local Config = require(script.Parent.Config)
local Remotes = require(script.Parent.Remotes)
require(script.Parent.Types)
return {
	build = function(object, data)
		local fn
		local namesByLabel = {}

		local function report(p)
			data.report(p, true)
			fn()
		end

		local v = object:AddText(function(object2)
			object2:SetText("")
		end)
		local v2 = object:AddBox(function() end)
		local v3 = v2.Components:AddDropdown(function(object2)
			object2:SetTextVisible(false)
		end)
		local v4 = v2.Components:AddNumberField(function(object2)
			object2:SetText("Minutes (0 = default)"):SetNumberFilter(0, Config.MAX_EVENT_MINUTES):SetValue(0)
		end)
		v2.Components:AddButton(function(object2)
			object2:SetButtonText("▶ Start on this server"):SetButtonCallback(function()
				local value = v3:GetValue()
				local v5 = namesByLabel[value]

				if v5 == nil then
					data.setStatus("Pick an event first", true)
					return
				end

				local v6 = math.clamp(math.floor(v4:GetValue() or 0), 0, Config.MAX_EVENT_MINUTES)
				data.setStatus(string.format("Starting %s...", value), false)
				Remotes.startEvent:request(v5, v6):andThen(report):catch(data.reportError)
			end)
		end)
		object:AddTitle(function(object2)
			object2:SetTitle("Running here")
		end)
		local v5 = object:AddList(function(object2)
			object2:SetSizeY(Config.EVENT_LIST_HEIGHT)
		end)
		object:AddButton(function(object2)
			object2:SetButtonText("↺ Refresh"):SetButtonCallback(function()
				fn()
			end)
		end)

		local function renderActive(data2)
			for _, v6 in v5.Components:GetAll() do
				v6:Destroy()
			end

			if #data2.active == 0 then
				v5.Components:AddText(function(object2)
					object2:SetText("Nothing running")
				end)
			end

			for _, v6 in data2.active do
				local v7 = v6
				v5.Components:AddSplit(function(object2)
					object2:SetRightSizeAbsolute(80)
					object2.LeftComponents:AddText(function(object3)
						local v8

						if v7.isGlobal then
							v8 = v7.label .. "  [global]"
						else
							v8 = v7.label
						end

						object3:SetText(v8)
					end)
					object2.RightComponents:AddButton(function(object3)
						object3:SetButtonText("■ Stop"):SetYSize(Config.LIST_ROW_HEIGHT):SetButtonCallback(function()
							Remotes.stopEvent:request(v7.name):andThen(report):catch(data.reportError)
						end)
						object3:SetEnabled(data2.canLaunch and not v7.isGlobal)
					end)
				end)
			end
		end

		local function render(data2)
			table.clear(namesByLabel)
			local labels = {}

			for _, event in data2.events do
				table.insert(labels, event.label)
				namesByLabel[event.label] = event.name
			end

			local value = v3:GetValue()
			v3:SetChoiceList(labels)

			if namesByLabel[value] == nil then
				v3:SetSelectedToFirst()
			end

			local v6 = v:SetText(data2.canLaunch and "You host this server: events only run here" or data2.reason)
			local v7

			if data2.canLaunch then
				v7 = Config.SUCCESS_COLOR
			else
				v7 = Config.ERROR_COLOR
			end

			v6:SetTextColor(v7)
			v2:SetVisible(data2.canLaunch)
			renderActive(data2)
		end

		fn = function()
			Remotes.getEventState:request():andThen(render):catch(data.reportError)
		end

		return {
			refresh = fn,
			tick = function() end
		}
	end
}