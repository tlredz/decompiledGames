local currentCamera = workspace.CurrentCamera
local Hiarchee = require(script:WaitForChild("Hiarchee"))
local v = {
	Equipped_Hirearchy = "",
	Updated = script.Updated
}
local enabledsByName = {}
local tostring2 = tostring
local v2 = false
return (setmetatable(v, {
	__index = function(_, p, p2)
		if p2 == nil then
			return enabledsByName[p] or false
		end
	end,
	__newindex = function(_, p, enabled)
		for k, v3 in Hiarchee do
			if v3.Name == tostring2(p) then
				Hiarchee[k].Enabled = enabled
			end

			enabledsByName[v3.Name] = v3.Enabled
		end

		local name = ""

		for _, v4 in Hiarchee do
			if v4.Enabled ~= true then
				continue
			end

			name = v4.Name
			break
		end

		if v.Equipped_Hirearchy ~= name then
			v.Equipped_Hirearchy = name
			script.Updated:Fire(name)
		end

		local v4 = #name > 0

		if v4 ~= v2 then
			if v4 == true then
				currentCamera.CameraType = Enum.CameraType.Scriptable
			else
				currentCamera.CameraType = Enum.CameraType.Custom

				if game.Players.LocalPlayer.Character ~= nil and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
					currentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
				end
			end

			v2 = v4
		end
	end
}))