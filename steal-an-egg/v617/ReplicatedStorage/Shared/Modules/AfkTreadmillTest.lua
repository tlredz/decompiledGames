local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ABTests = require(ReplicatedStorage.UserGenerated.ABTests)
local v = {
	TestName = "AfkTreadmillTest",
	AttributeKey = "AfkTreadmill.Group",
	Groups = table.freeze({
		Control = "Control",
		Variant = "Variant"
	})
}

function v.GetGroupAsync(p)
	if ABTests.GetAttributeAsync(p, v.AttributeKey, v.Groups.Control) == v.Groups.Variant then
		return v.Groups.Variant
	end

	return v.Groups.Control
end

function v.IsVariantAsync(p)
	return v.GetGroupAsync(p) == v.Groups.Variant
end

return table.freeze(v)