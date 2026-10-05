local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local module = require("@self/app")
local module2 = require("./roblox_packages/conch")
local module3 = require("@self/plugin_api")
local module4 = require("@self/runtime_plugin_api")
local module5 = require("@self/state")
local module6 = require("@self/theme")
local module7 = require("@self/api_version")
local module8 = require("./roblox_packages/vide")
local flag = false
local opened = module5.opened
local focused = module5.focused

local function mount()
	if flag then
		return
	end

	flag = true
	return module8.mount(module, Players.LocalPlayer:WaitForChild("PlayerGui"))
end

local function bind_to(p)
	if not flag then
		flag = true
		module8.mount(module, Players.LocalPlayer:WaitForChild("PlayerGui"))
	end

	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode ~= p and input.UserInputType ~= p then
			return
		end

		opened(not opened())
		focused(opened())
	end)
end

module3.expose(module7, "alicesays_hallo/conch-ui", module4)
return {
	alignment = module5.alignment,
	theme = module6,
	focused = module5.focused,
	app = module,
	mount = mount,
	opened = opened,
	bind_to = bind_to,
	conch = module2
}