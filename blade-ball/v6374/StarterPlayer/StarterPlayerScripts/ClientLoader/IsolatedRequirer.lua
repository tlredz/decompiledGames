while not script.Target.Value do
	script.Target.Changed:Wait()
end

local value = script.Target.Value
require(value)
script:SetAttribute("Loaded", true)