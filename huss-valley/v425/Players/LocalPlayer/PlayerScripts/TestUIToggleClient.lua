if game.PlaceId ~= 130574217370467 then
	return
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	StudioAbilityTests = true,
	HitboxComparison = true,
	HitReplayStatus = true,
	StudioCheatTest = true
}
local v2 = {}
local connections = {}
local testUIHidden = localPlayer:GetAttribute("TestUIHidden") == true

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(p, p2)
	if testUIHidden then
		if p.Enabled then
			p2.restore = true
			p.Enabled = false
		end
	else
		p.Enabled = p2.restore
	end
end

local function track(screenGui)
	if not screenGui:IsA("ScreenGui") or v2[screenGui] or not v[screenGui.Name] and screenGui:GetAttribute("TestOnlyUI") ~= true then
		return
	end

	local v3 = {
		restore = screenGui.Enabled
	}

	if testUIHidden then
		v3.restore = true
	end

	v2[screenGui] = v3
	v3.changed = screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if testUIHidden and screenGui.Enabled then
			v3.restore = true
			screenGui.Enabled = false
		end
	end)
	v3.destroyed = screenGui.Destroying:Connect(function()
		v3.changed:Disconnect()
		v2[screenGui] = nil
	end)
	apply(screenGui, v3) -- equivalent call inferred; original call site unknown
end

table.insert(connections, playerGui.ChildAdded:Connect(track))

for _, child in playerGui:GetChildren() do
	track(child)
end

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or UserInputService:GetFocusedTextBox() or input.KeyCode ~= Enum.KeyCode.F6 then
		return
	end

	local v3 = not testUIHidden

	if v3 then
		for k, v4 in v2 do
			v4.restore = k.Enabled
		end
	end

	testUIHidden = v3
	localPlayer:SetAttribute("TestUIHidden", testUIHidden)

	for k, v4 in v2 do
		apply(k, v4) -- equivalent call inferred; original call site unknown
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	testUIHidden = false
	localPlayer:SetAttribute("TestUIHidden", nil)

	for k, v3 in v2 do
		v3.changed:Disconnect()
		v3.destroyed:Disconnect()

		if k.Parent then
			k.Enabled = v3.restore
		end
	end
end)