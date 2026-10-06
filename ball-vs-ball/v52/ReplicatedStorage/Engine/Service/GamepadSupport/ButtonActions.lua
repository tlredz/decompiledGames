local parentModule = require(script.Parent)
local ButtonActivation = require(script.Parent.ButtonActivation)
local ButtonActions = {}
local v = {}
local v2 = nil
local v3 = nil

function ButtonActions.SetOnBound(p)
	v3 = p
end

function ButtonActions.SetGamepadPolicy(p)
	v2 = p
end

function ButtonActions.Has(p)
	return v[p] ~= nil
end

function ButtonActions.Invoke(p, p2)
	local v4 = v[p]

	if not v4 or v4.busy or not parentModule.CanActivate(p) or ButtonActivation.IsGamepadButton(p2) and v2 and not v2(p) then
		return false
	end

	if not ButtonActivation.Try(p2) then
		return false
	end

	v4.busy = true
	local success, result = pcall(v4.callback, p2)
	v4.busy = false

	if not success then
		warn("[ButtonActions] " .. tostring(result))
	end

	return success
end

function ButtonActions:Bind(callback)
	assert(self:IsA("GuiButton"), "ButtonActions requires GuiButton")
	assert(not v[self], "Button already bound: " .. self:GetFullName())
	self.Selectable = true
	local v4 = {
		callback = callback,
		busy = false
	}
	v[self] = v4
	local activatedConnection = self.Activated:Connect(function(p2)
		ButtonActions.Invoke(self, p2)
	end)
	local destroyingConnection = nil
	local connection = {
		Connected = true
	}

	function connection.Disconnect(_)
		if v[self] ~= v4 then
			return
		end

		connection.Connected = false
		v[self] = nil
		activatedConnection:Disconnect()

		if destroyingConnection then
			destroyingConnection:Disconnect()
		end
	end

	destroyingConnection = self.Destroying:Connect(function()
		connection:Disconnect()
	end)

	if v3 then
		v3(self)
	end

	return connection
end

return ButtonActions