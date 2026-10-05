local RunService = game:GetService("RunService")
local Restrictions = {
	ATTRIBUTE = "Restricted",
	RANKED = "Ranked",
	TRADING = "Trading"
}
Restrictions.ALL = { Restrictions.RANKED, Restrictions.TRADING }

function Restrictions.Has(instance, p: string)
	if RunService:IsServer() then
		local lastTime = os.clock()

		while instance:GetAttribute(Restrictions.ATTRIBUTE) == nil and instance.Parent ~= nil and os.clock() - lastTime < 10 do
			task.wait(0.1)
		end
	end

	local attribute = instance:GetAttribute(Restrictions.ATTRIBUTE)

	if typeof(attribute) == "string" then
		return table.find(string.split(attribute, ","), p) ~= nil
	end

	if RunService:IsServer() then
		return false
	end

	return nil
end

return Restrictions