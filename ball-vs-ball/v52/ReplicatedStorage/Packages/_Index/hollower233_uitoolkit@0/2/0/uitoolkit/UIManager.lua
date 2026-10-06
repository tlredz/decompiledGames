local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local function checkResetOnSpawn()
	for _, screenGui in StarterGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and screenGui.ResetOnSpawn then
			warn(("[UIToolkit.UIManager] %s 的 ResetOnSpawn 未关闭"):format(screenGui.Name))
		end
	end
end

return {
	Init = function(instance, options)
		local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		local v = {}

		for _, childName in options or {} do
			playerGui:WaitForChild(childName)
		end

		checkResetOnSpawn()

		for _, moduleScript in instance:GetChildren() do
			if not moduleScript:IsA("ModuleScript") then
				continue
			end

			local success, result = pcall(require, moduleScript)

			if success then
				v[moduleScript.Name] = result
			else
				warn(("[UIToolkit.UIManager] require %s 失败: %s"):format(moduleScript.Name, (tostring(result))))
			end
		end

		for k, v2 in v do
			if not (type(v2) == "table" and v2.Init) then
				continue
			end

			local success, result = pcall(v2.Init)

			if not success then
				warn(("[UIToolkit.UIManager] %s.Init() 出错: %s"):format(k, (tostring(result))))
			end
		end

		return {
			Get = function(p: string)
				return v[p]
			end,
			SetScreenGuiEnabled = function(childName: string, enabled: boolean)
				local screenGui = playerGui:FindFirstChild(childName)

				if screenGui and screenGui:IsA("ScreenGui") then
					screenGui.Enabled = enabled
					return true
				end

				warn(("[UIToolkit.UIManager] 找不到 ScreenGui: %s"):format(childName))
				return false
			end
		}
	end
}