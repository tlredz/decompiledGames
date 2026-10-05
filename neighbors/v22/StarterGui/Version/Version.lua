local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("InsertService")
local v = {
	[true] = "Server is up to date",
	[false] = "Server is NOT up to date"
}
local v2 = {
	[true] = Color3.fromRGB(0, 255, 0),
	[false] = Color3.fromRGB(255, 0, 0)
}
local Server = require(ReplicatedStorage.Modules.Server)

if Server:IsTestServer() then
	local _ = game.PlaceId
	local frame = script.Parent:WaitForChild("Frame")
	local warning = frame:WaitForChild("Warning")
	local textLabel = frame:WaitForChild("TextLabel")
	local placeVersion = game.PlaceVersion
	frame.Visible = true

	while task.wait(1) do
		local cachedPlaceVersion = workspace:GetAttribute("CachedPlaceVersion")
		local currentPlaceVersion = workspace:GetAttribute("CurrentPlaceVersion")

		if not (cachedPlaceVersion and currentPlaceVersion) then
			continue
		end

		textLabel.Text = `{v[cachedPlaceVersion == currentPlaceVersion]} (v{placeVersion})`
		textLabel.TextColor3 = v2[cachedPlaceVersion == currentPlaceVersion]
		frame.BackgroundColor3 = textLabel.TextColor3
		warning.Visible = cachedPlaceVersion ~= currentPlaceVersion
	end
else
	task.defer(function()
		script.Parent:Destroy()
	end)
	script.Enabled = false
end