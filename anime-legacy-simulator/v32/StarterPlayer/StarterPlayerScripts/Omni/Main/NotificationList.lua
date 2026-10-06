local module = require("@game/ReplicatedStorage/Omni")
local v = {
	Text = 1,
	Gamemode = 2,
	Admin = 3,
	Drop = 4
}
local v2 = {}
local count = 0
local NotificationList = {
	Sort = function()
		local v3 = {}

		for k, v4 in v2 do
			table.insert(v3, {
				Object = k,
				Priority = v4.Priority,
				Sequence = v4.Sequence
			})
		end

		table.sort(v3, function(a, b)
			if a.Priority == b.Priority then
				return a.Sequence < b.Sequence
			end

			return a.Priority < b.Priority
		end)

		for k, v4 in v3 do
			v4.Object.LayoutOrder = k
		end
	end
}

function NotificationList.Remove(p)
	local v3 = v2[p]

	if not v3 then
		return
	end

	v2[p] = nil
	v3.Connection:Disconnect()
	NotificationList.Sort()

	if not next(v2) then
		count = 0
	end
end

function NotificationList:Add(p: string)
	if v2[self] or not v[p] then
		return
	end

	count += 1
	v2[self] = {
		Priority = v[p],
		Sequence = count,
		Connection = self.Destroying:Connect(function()
			NotificationList.Remove(self)
		end)
	}
	local list = module.Instance.PlayerGui.Notifications.List
	list.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotificationList.Sort()
	self.Parent = list
	self.Visible = true
end

function NotificationList.Destroy()
	for k in v2 do
		NotificationList.Remove(k)
	end
end

return NotificationList