local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "HotKeyDisplay"
})

function v.Start(p)
	local hotKey = p.Instance:GetAttribute("HotKey")

	if not hotKey then
		warn("No HotKey attribute found for HotKeyDisplay", p.Instance:GetFullName())
		return
	end

	local v2 = Enum.KeyCode[hotKey]

	if v2 then
		p.Instance.Text = UserInputService:GetStringForKeyCode(v2)
	else
		warn((`Hotkey {hotKey} does not exist`))
	end
end

return v