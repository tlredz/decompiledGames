local value = script:WaitForChild("Target").Value
assert(value and value:IsA("ModuleScript"), "ControllerRunner requires a ModuleScript target")
local bindableFunction = Instance.new("BindableFunction")
bindableFunction.Name = "Invoke"
bindableFunction.Parent = script
script:SetAttribute("Ready", true)

while script:GetAttribute("BeginLoad") ~= true do
	script:GetAttributeChangedSignal("BeginLoad"):Wait()
end

local success, result = pcall(require, value)

if success then
	function bindableFunction.OnInvoke(p: string, flag: boolean)
		if type(result) ~= "table" then
			return false, true, nil
		end

		local v = result[p]

		if type(v) ~= "function" then
			return false, true, nil
		end

		if flag then
			task.spawn(function()
				debug.setmemorycategory(value.Name)
				v(result)
			end)
			return true, true, nil
		end

		local success2, result2 = pcall(v, result)
		return true, success2, result2
	end

	script:SetAttribute("Loaded", true)
else
	script:SetAttribute("LoadError", (tostring(result)))
	script:SetAttribute("Loaded", false)
end