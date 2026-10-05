local HttpService = game:GetService("HttpService")
return function()
	local jSONDecode = HttpService:JSONDecode(script.Parent.Parent:WaitForChild("Configuration").Value)
	local v = {}

	if jSONDecode.Output and jSONDecode.Output.SuppressWarnings then
		for _, suppressWarning in jSONDecode.Output.SuppressWarnings do
			v[string.lower(suppressWarning)] = true
		end
	end

	if v.all then
		return
	end

	for _, v2 in {
		{
			Key = "MissingNexusVRBackpackEnabled",
			Message = "The configuration entry Extra.NexusVRBackpackEnabled is missing (defaults to true).",
			Condition = function()
				return jSONDecode.Extra == nil or jSONDecode.Extra.NexusVRBackpackEnabled == nil
			end
		},
		{
			Key = "MissingAllowClientToOutputLoadedMessage",
			Message = "The configuration entry Extra.AllowClientToOutputLoadedMessage is missing (defaults to true).",
			Condition = function()
				return jSONDecode.Output == nil or jSONDecode.Output.AllowClientToOutputLoadedMessage == nil
			end
		},
		{
			Key = "MissingDisableHeadLocked",
			Message = "The configuration entry Camera.DisableHeadLocked is missing (defaults to true).",
			Condition = function()
				return jSONDecode.Camera == nil or jSONDecode.Camera.DisableHeadLocked == nil
			end
		}
	} do
		if v[string.lower(v2.Key)] or not v2.Condition() then
			continue
		end

		warn(v2.Message)
		warn((`\tThis warning can be disabled by adding "{v2.Key}" or "All" to Output.SuppressWarnings in the configuration of Nexus VR Character Model.`))
	end
end