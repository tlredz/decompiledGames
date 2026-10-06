local module = require("@game/ReplicatedStorage/Omni")
module.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds")
local Overlay = {}
Overlay.__index = Overlay

function Overlay.Setup(data)
	local value = data.Scope:Value(nil)
	local value2 = data.Scope:Value(nil)
	local value3 = data.Scope:Value(nil)

	local function Refresh()
		local state = data.Scope.peek(data.State)

		if (data.Scope.peek(data.Hidden) == true and "Closed" or state) == "Opened" then
			value:set(data.Originals.Size)
			value2:set(UDim2.fromScale(0.5, -0.132))
			value3:set(UDim2.fromScale(0.981, 1))
			data.Instance.Visible = true
		else
			value:set(0)
			value2:set(UDim2.fromScale(0.5, -0.075))
			value3:set(UDim2.fromScale(0.5, 1))
			task.delay(0.25, function()
				local state2 = data.Scope.peek(data.State)

				if (data.Scope.peek(data.Hidden) == true and "Closed" or state2) == "Closed" then
					data.Instance.Visible = false
				end
			end)
		end
	end

	data.Scope:Observer(data.State):onBind(Refresh)
	data.Scope:Observer(data.Hidden):onBind(Refresh)
	local header = data.Instance:FindFirstChild("Header")

	if header then
		local down = header:FindFirstChild("Down")

		if down then
			data.Scope:Hydrate(down)({
				Size = data.Scope:Spring(value3, 5, 1)
			})
		end

		data.Scope:Hydrate(header)({
			Position = data.Scope:Spring(value2, 5, 1)
		})
	end

	data.Scope:Hydrate(data.UIScale)({
		Scale = data.Scope:Spring(value, 40, 1)
	})
end

function Overlay:Destroy()
	for k, connection in self.Connections do
		if connection.Disconnect then
			connection:Disconnect()
		elseif connection.Destroy then
			connection:Destroy()
		end

		self.Connections[k] = nil
	end

	self.Scope:doCleanup()
end

return Overlay