local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local version = ReplicatedStorage:WaitForChild("world"):WaitForChild("version")
local title = script.Parent.title

local function update()
	local parts = version.Value:split(".")
	local v = {}

	for i = 1, math.max(#parts, 4) do
		table.insert(v, parts[i] or 0)
	end

	table.insert(v, game.PlaceVersion)
	title.Text = `{table.concat(v, ".")} - {Players.LocalPlayer.UserId}`
end

version.Changed:Connect(update)
version:GetAttributeChangedSignal("ConfigVersion"):Connect(update)
update()