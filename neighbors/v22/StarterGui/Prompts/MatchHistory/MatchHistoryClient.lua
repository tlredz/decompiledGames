game:GetService("Players")
local localPlayer = game.Players.LocalPlayer
local Network = require(game.ReplicatedStorage.Modules.Network)
local Date = require(game.ReplicatedStorage.Modules.Date)
local UI = require(game.ReplicatedStorage.Modules.UI)
local sample = script:WaitForChild("Sample")
local items = script.Parent:WaitForChild("Items")
local busy = script.Parent:WaitForChild("Busy")
local empty = script.Parent:WaitForChild("Empty")
local close = script.Parent:WaitForChild("Close")
local v = {}

local function clear_old_entries()
	for _, frame in items:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function get_avatar_decal(userId)
	local success, result, _ = pcall(function()
		return game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
	end)
	return success and result or ""
end

local function format_duration(p)
	local v2 = math.floor(p / 3600)
	local v3 = math.floor(p / 60 - v2 * 60)

	if v2 < 10 then
		v2 = "0" .. v2 or v2
	end

	if v3 < 10 then
		v3 = "0" .. v3 or v3
	end

	return v2 .. ":" .. v3
end

local function update()
	clear_old_entries()
	busy.Visible = true
	empty.Visible = false
	v = Network:invoke("FetchMatchHistory") or v
	table.sort(v, function(a, b)
		return a.Time > b.Time
	end)
	empty.Visible = #v == 0

	for k, v2 in v do
		local clone = sample:Clone()
		clone.LayoutOrder = k
		clone.Player.Title.Text = string.format(
			"<b>%s</b>  <font transparency = \"0.5\">%s</font>",
			v2.Display,
			Date:FormatDate(v2.Time)
		)
		clone.Player.Username.Text = "@" .. v2.Username
		local duration = clone.Duration
		local duration2 = v2.Duration
		local v3 = math.floor(duration2 / 3600)
		local v4 = math.floor(duration2 / 60 - v3 * 60)

		if v3 < 10 then
			v3 = "0" .. v3 or v3
		end

		if v4 < 10 then
			v4 = "0" .. v4 or v4
		end

		duration.Text = v3 .. ":" .. v4
		local icon = clone.Icon
		icon.Image = get_avatar_decal(v2.UserId)
		local reconnect = clone.Reconnect
		reconnect.Visible = os.time() - v2.Time < 1800 and v2.Username ~= localPlayer.Name and v2.Username ~= localPlayer:GetAttribute("MatchTarget")
		clone.Reconnect.Visible = false

		if clone.Reconnect.Visible then
			local v6 = v2
			clone.Reconnect.MouseButton1Click:Connect(function()
				Network:fire("JoinPlayerFromMatchHistory", v6.Time)
			end)
			UI:Bind(clone.Reconnect)
			UI:AddShadowOnHover(clone.Reconnect)
		end

		clone.Parent = items
	end

	items.CanvasSize = UDim2.new(0, 0, 0, #v * (sample.Size.Y.Offset + items.UIListLayout.Padding.Offset) + 20)
	busy.Visible = false
end

if UI:GetDeviceType() == "Mobile" then
	script.Parent.Size = UDim2.fromOffset(250, 200)
end

script.Parent:GetPropertyChangedSignal("Visible"):connect(function()
	if script.Parent.Visible then
		update()
	end
end)
close.MouseButton1Click:connect(function()
	script.Parent.Visible = false
end)
UI:Bind(close)