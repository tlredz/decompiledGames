local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local catalogGui = playerGui:WaitForChild("CatalogGui")
local v = {
	GamepassStoreGui = true,
	ScreenGui = true,
	PreferencesGui = true,
	SaveOutfitShortcutGui = true,
	BackgroundPreviewGui = true,
	LeaderboardGui = true,
	UGCClaimGui = true,
	CommunityGui = true,
	WearingGui = true
}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateOne(p)
	if catalogGui.Enabled then
		if v3[p] == nil then
			v3[p] = p.Enabled
		end

		p.Enabled = false
	elseif v3[p] ~= nil then
		local enabled = v3[p]
		v3[p] = nil
		p.Enabled = enabled
	end
end

local function track(screenGui)
	if not screenGui:IsA("ScreenGui") or not v[screenGui.Name] or v2[screenGui] then
		return
	end

	v2[screenGui] = true
	screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if catalogGui.Enabled and screenGui.Enabled then
			screenGui.Enabled = false
		end
	end)
	updateOne(screenGui) -- equivalent call inferred; original call site unknown
end

catalogGui:GetPropertyChangedSignal("Enabled"):Connect(function()
	for k in pairs(v2) do
		if k.Parent then
			updateOne(k) -- equivalent call inferred; original call site unknown
		else
			v2[k] = nil
			v3[k] = nil
		end
	end
end)
playerGui.ChildAdded:Connect(track)

for _, child in ipairs(playerGui:GetChildren()) do
	track(child)
end