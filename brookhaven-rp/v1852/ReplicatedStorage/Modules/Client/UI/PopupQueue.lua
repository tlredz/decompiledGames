local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local IntroController = require(ReplicatedStorage.Modules.Client.UI.IntroController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PopupQueue = {}
local v = {}
local v2 = {}
local v3 = false
local flag = false

local function isBlocked()
	local success, result = pcall(function()
		for k, v4 in v2 do
			for k2, _ in v4 do
				if PanelController.IsOpen(k, k2) then
					return true
				end
			end
		end

		return #PanelController.GetOpenPanelsByGroup("ShopFlow") > 0
	end)

	if success then
		return result
	end

	warn(result)
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function drain()
	if flag then
		return
	end

	flag = true
	pcall(function()
		task.wait(0.4)

		if #v ~= 0 then
			local success, result = pcall(function()
				for k, v4 in v2 do
					for k2, _ in v4 do
						if PanelController.IsOpen(k, k2) then
							return true
						end
					end
				end

				return #PanelController.GetOpenPanelsByGroup("ShopFlow") > 0
			end)

			if not success then
				warn(result)
				result = true
			end

			if not result then
				local v4 = v[#v]
				table.remove(v, #v)
				local v5 = v4[1]
				local v6 = v4[2]
				v2[v5][v6](table.unpack(v4, 3))
				PanelController.OpenPanelByContext(v5, v6)
			end
		end
	end)
	flag = false
end

function PopupQueue.FrameworkInit() end

function PopupQueue.FrameworkStart()
	IntroController.OnPlayButtonPressed:Connect(function()
		task.wait(0.4)
		v3 = true
		drain() -- equivalent call inferred; original call site unknown
	end)

	if IntroController.HasPassedIntro() then
		v3 = true
		task.spawn(drain)
	end

	PanelController.OnPanelClosed:Connect(function(p: string, p2: string)
		if #v == 0 or not PanelController.IsInGroup("ShopFlow", p, p2) or #PanelController.GetOpenPanelsByGroup("ShopFlow") > 0 then
			return
		end

		task.spawn(drain)
	end)
end

function PopupQueue.Dispatch(p: string, p2: string, ...)
	if v2[p] == nil or v2[p][p2] == nil then
		error("Unknown panel context and name: " .. p .. ", " .. p2)
		return
	end

	if v3 and not flag then
		local success, result = pcall(function()
			for k, v4 in v2 do
				for k2, _ in v4 do
					if PanelController.IsOpen(k, k2) then
						return true
					end
				end
			end

			return #PanelController.GetOpenPanelsByGroup("ShopFlow") > 0
		end)

		if not success then
			warn(result)
			result = true
		end

		if not result then
			v2[p][p2](...)
			PanelController.OpenPanelByContext(p, p2)
			return
		end
	end

	table.insert(v, { p, p2, table.unpack({ ... }) })
end

function PopupQueue.RegisterHandler(p: string, p2: string, callback)
	local v4 = PanelController.WaitForPanel(p, p2)

	if v2[p] == nil then
		v2[p] = {}
	end

	v2[p][p2] = callback
	v4:RegisterListener(PopupQueue, Panel.Events.Closing, drain)
end

return PopupQueue