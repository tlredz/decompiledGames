local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local module = require("./app")
local module2 = require("../roblox_packages/conch")
local module3 = require("./state")
local module4 = require("../roblox_packages/vide")
local flag = false
local opened = module3.opened
local focused = module3.focused

local function mount()
	if flag then
		return
	end

	flag = true
	return module4.mount(module, Players.LocalPlayer:WaitForChild("PlayerGui"))
end

local function bind_to(p)
	if not flag then
		flag = true
		module4.mount(module, Players.LocalPlayer:WaitForChild("PlayerGui"))
	end

	ContextActionService:BindAction("Trigger Conch", function(_, p2)
		if p2 == Enum.UserInputState.Begin then
			opened(not opened())
			focused(opened())
		end
	end, false, p)
end

return {
	app = module,
	mount = mount,
	opened = opened,
	focused = focused,
	bind_to = bind_to,
	conch = module2
}