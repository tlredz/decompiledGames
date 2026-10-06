local module = require("@game/ReplicatedStorage/Omni")
local notifications = module.Shared.Notifications
local Card = require(script.Parent.Card)
local Chat = require(script.Parent.Chat)
local admin = module.Assets.Interface.Templates.Notifications.Admin
local clones = {}
local v = {}
local v2 = {}
local v3 = nil
local v4 = false
local Admin = {}

function Admin.Pump()
	if v3 or v4 or #clones == 0 then
		return
	end

	local v5 = table.remove(clones, 1)
	local v6 = {
		Instance = admin:Clone()
	}
	v3 = v6
	v6.Instance.Name = "AdminNotification_" .. v5.ID
	v6.Instance.Position = UDim2.fromScale(0, 0)
	local main = v6.Instance.Main
	main.UserName.Text = "@" .. v5.UserInfo.UserName
	main.UserName.RichText = false
	main.Message.Text = v5.Message
	main.Message.RichText = false
	main.Message.TextColor3 = Color3.new(1, 1, 1)
	main.Message.UIGradient.Color = ColorSequence.new(module.Utils.Colors:Lighten(v5.Color, 0.5), v5.Color)
	main.Icon.Image = ""

	function v6.OnCleanup()
		if v6.ThumbnailThread then
			task.cancel(v6.ThumbnailThread)
			v6.ThumbnailThread = nil
		end
	end

	function v6.OnDestroyed()
		if v3 == v6 then
			v3 = nil
		end

		Admin.Pump()
	end

	Card.Attach(v6, "Admin", v5.Time)
	v6.ThumbnailThread = task.defer(function()
		local success, result = pcall(function()
			return module.Services.Players:GetUserThumbnailAsync(
				v5.UserInfo.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
		end)
		v6.ThumbnailThread = nil

		if v6.Destroyed then
			return
		end

		if success then
			main.Icon.Image = result
		end
	end)
	Chat.Create({
		Message = "[ADMIN] " .. v5.Message,
		Color = v5.Color
	})
end

function Admin.Create(data)
	if typeof(data) ~= "table" or not notifications.IsMessage(data.Message) then
		return
	end

	if typeof(data.ID) ~= "string" or #data.ID == 0 or #data.ID > 64 then
		return
	end

	if typeof(data.Color) ~= "Color3" or not notifications.IsFinite(data.Time) then
		return
	end

	if typeof(data.UserInfo) ~= "table" or not notifications.IsFinite(data.UserInfo.UserId) then
		return
	end

	if typeof(data.UserInfo.UserName) ~= "string" then
		return
	end

	local now = os.clock()

	while #v2 > 0 do
		local v5 = v2[1]

		if #v2 < notifications.MaximumSeenAnnouncements and now - v5.Time <= notifications.AnnouncementLifetime then
			break
		end

		v[v5.ID] = nil
		table.remove(v2, 1)
	end

	if v[data.ID] then
		return
	end

	v[data.ID] = true
	table.insert(v2, {
		ID = data.ID,
		Time = now
	})
	local clone = table.clone(data)
	clone.UserInfo = table.clone(clone.UserInfo)
	clone.Time = math.clamp(clone.Time, 3, 30)

	if #clones >= notifications.MaximumPendingAdmins then
		table.remove(clones, 1)
	end

	table.insert(clones, clone)
	Admin.Pump()
end

function Admin.Destroy()
	v4 = true
	table.clear(clones)
	table.clear(v)
	table.clear(v2)

	if v3 then
		Card.Destroy(v3)
	end

	v4 = false
end

return Admin