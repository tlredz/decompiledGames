local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ConnectionQualityConfig = require(game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game"):WaitForChild("ConnectionQualityConfig"))
local serverBrowser = localPlayer:WaitForChild("PlayerGui"):WaitForChild("ServerBrowser")
local panel = serverBrowser:WaitForChild("Panel")
local v = 0
local thread = nil
local v2 = true
local connections = {}

local function visible()
	local visible2 = v2

	if visible2 then
		if script.Parent == nil or localPlayer.Parent == nil or localPlayer:GetAttribute("ServerBrowserOpen") ~= true then
			visible2 = false
		else
			visible2 = serverBrowser.Enabled and panel.Visible
		end
	end

	return visible2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearWarning()
	v = 0
	localPlayer:SetAttribute("HighPingWarning", false)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stop()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	clearWarning() -- equivalent call inferred; original call site unknown
end

local fn

fn = function()
	thread = task.delay(ConnectionQualityConfig.PingSampleSeconds, function()
		thread = nil
		local visible2 = v2

		if visible2 then
			if script.Parent == nil or localPlayer.Parent == nil or localPlayer:GetAttribute("ServerBrowserOpen") ~= true then
				visible2 = false
			else
				visible2 = serverBrowser.Enabled and panel.Visible
			end
		end

		if visible2 then
			local success, result = pcall(function()
				return localPlayer:GetNetworkPing() * 1000
			end)

			if success and type(result) == "number" and result == result and result ~= 1e999 and not (result < ConnectionQualityConfig.HighPingMs) then
				v = math.min(ConnectionQualityConfig.HighPingSamples, v + 1)
				localPlayer:SetAttribute("HighPingWarning", v >= ConnectionQualityConfig.HighPingSamples)
			else
				clearWarning() -- equivalent call inferred; original call site unknown
			end

			local visible3 = v2

			if visible3 then
				if script.Parent == nil or localPlayer.Parent == nil or localPlayer:GetAttribute("ServerBrowserOpen") ~= true then
					visible3 = false
				else
					visible3 = serverBrowser.Enabled and panel.Visible
				end
			end

			if visible3 then
				fn()
				return
			end

			clearWarning() -- equivalent call inferred; original call site unknown
		else
			clearWarning() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSampling()
	local visible2 = v2

	if visible2 then
		if script.Parent == nil or localPlayer.Parent == nil or localPlayer:GetAttribute("ServerBrowserOpen") ~= true then
			visible2 = false
		else
			visible2 = serverBrowser.Enabled and panel.Visible
		end
	end

	if visible2 then
		if not thread then
			clearWarning() -- equivalent call inferred; original call site unknown
			fn()
		end
	else
		stop() -- equivalent call inferred; original call site unknown
	end
end

table.insert(connections, localPlayer:GetAttributeChangedSignal("ServerBrowserOpen"):Connect(updateSampling))
table.insert(connections, serverBrowser:GetPropertyChangedSignal("Enabled"):Connect(updateSampling))
table.insert(connections, panel:GetPropertyChangedSignal("Visible"):Connect(updateSampling))
script.Destroying:Connect(function()
	v2 = false
	stop() -- equivalent call inferred; original call site unknown

	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end)
clearWarning() -- equivalent call inferred; original call site unknown
updateSampling() -- equivalent call inferred; original call site unknown