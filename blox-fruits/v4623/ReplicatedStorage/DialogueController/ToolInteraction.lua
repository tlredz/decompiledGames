local Players = game:GetService("Players")
local Legacy = require(script.Parent.Legacy)
require(script.Parent.Types)
local object = setmetatable({}, {
	__mode = "k"
})
return {
	start = function(data, instance, converted, value: number?)
		local character = Players.LocalPlayer.Character
		local v = object[instance]

		if instance.Parent ~= character or not character or data.getActiveDialogue() or v and (v.busy or os.clock() < v.readyAt) then
			return nil
		end

		local v2 = {
			busy = true,
			readyAt = 1e999
		}
		object[instance] = v2

		if Legacy.is(converted) then
			converted = Legacy.convert(converted)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function closeOwnedDialogue()
			local activeDialogue = data.getActiveDialogue()

			if activeDialogue and activeDialogue._dialogue == converted then
				data.close()
			end
		end

		local unequippedConnection = instance.Unequipped:Connect(closeOwnedDialogue)
		local destroyingConnection = instance.Destroying:Connect(closeOwnedDialogue)
		local success, result = pcall(function()
			local v3 = data.start(converted)

			while v3 and data.getActiveDialogue() == v3 do
				task.wait()
			end

			return v3
		end)
		unequippedConnection:Disconnect()
		destroyingConnection:Disconnect()
		v2.busy = false
		v2.readyAt = os.clock() + math.max(value or 0, 0)

		if not success then
			closeOwnedDialogue() -- equivalent call inferred; original call site unknown
			error(result, 0)
		end

		return result
	end
}