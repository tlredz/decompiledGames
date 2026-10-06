local Lighting = game:GetService("Lighting")
local v = {
	Ambient = {
		kind = "Color3"
	},
	OutdoorAmbient = {
		kind = "Color3"
	},
	EnvironmentDiffuseScale = {
		kind = "number",
		min = 0,
		max = 1
	},
	EnvironmentSpecularScale = {
		kind = "number",
		min = 0,
		max = 1
	},
	Brightness = {
		kind = "number",
		min = 0,
		max = 10
	},
	ClockTime = {
		kind = "number",
		min = 0,
		max = 24
	},
	ExposureCompensation = {
		kind = "number",
		min = -5,
		max = 5
	}
}
local v2 = {
	SunRaysEffect = "SunRaysEnabled",
	DepthOfFieldEffect = "DepthOfFieldEnabled"
}
return {
	Start = function()
		local configuration = Lighting:FindFirstChild("限定礼包灯光")

		if not (configuration and configuration:IsA("Configuration")) then
			warn("[ShowcaseLighting] 缺少 Lighting.限定礼包灯光")
			return function() end
		end

		local v3 = Lighting
		local v4 = {}
		local LightingsByAtmosphere = {}
		local enabledsByAtmosphere = {}
		local flag = false
		local connections = {}

		for k in v do
			v4[k] = v3[k]
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function track(atmosphere)
			if atmosphere:IsA("Atmosphere") then
				if not LightingsByAtmosphere[atmosphere] then
					LightingsByAtmosphere[atmosphere] = Lighting
				end
			elseif v2[atmosphere.ClassName] and enabledsByAtmosphere[atmosphere] == nil then
				enabledsByAtmosphere[atmosphere] = atmosphere.Enabled
			end
		end

		for _, child in Lighting:GetChildren() do
			track(child) -- equivalent call inferred; original call site unknown
		end

		local function apply()
			if flag then
				return
			end

			for attributeName, v5 in v do
				local attribute = configuration:GetAttribute(attributeName)
				local v6 = typeof(attribute) == v5.kind

				if v6 and typeof(attribute) == "number" then
					if attribute == attribute and v5.min <= attribute then
						v6 = attribute <= v5.max
					else
						v6 = false
					end
				end

				local v7 = v3

				if not v6 then
					attribute = v4[attributeName]
				end

				v7[attributeName] = attribute
			end

			for k, enabled in enabledsByAtmosphere do
				if not k.Parent then
					continue
				end

				local attribute = configuration:GetAttribute(v2[k.ClassName])

				if typeof(attribute) == "boolean" then
					enabled = attribute
				end

				k.Enabled = enabled
			end

			local atmosphereEnabled = configuration:GetAttribute("AtmosphereEnabled") ~= false

			for k, parent in LightingsByAtmosphere do
				if not (k.Parent == Lighting or k.Parent == configuration) then
					continue
				end

				if not atmosphereEnabled then
					parent = configuration
				end

				if k.Parent ~= parent then
					k.Parent = parent
				end
			end
		end

		table.insert(connections, configuration.AttributeChanged:Connect(apply))
		table.insert(connections, Lighting.ChildAdded:Connect(function(child)
			track(child) -- equivalent call inferred; original call site unknown
			apply()
		end))
		apply()
		return function()
			if flag then
				return
			end

			flag = true

			for _, connection in connections do
				connection:Disconnect()
			end

			for k, v5 in v4 do
				v3[k] = v5
			end

			for k, enabled in enabledsByAtmosphere do
				if k.Parent then
					k.Enabled = enabled
				end
			end

			for k, parent in LightingsByAtmosphere do
				if k.Parent == configuration then
					k.Parent = parent
				end
			end
		end
	end
}