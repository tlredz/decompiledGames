local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AutoOpenModalConfig = require(ReplicatedStorage.FeatureConfigs.AutoOpenModalConfig)
local Config = require(ReplicatedStorage.Config)
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local galaxy2Welcome = AutoOpenModalConfig.Ids.Galaxy2Welcome
local uDim = UDim2.new(0.7, 0, 0.7, 0)

local function bindClientWelcome()
	local AutoOpenModalSystem = require(ReplicatedStorage.UISystems.AutoOpenModalSystem)
	local InfoModalUISystem = require(ReplicatedStorage.UISystems.InfoModalUISystem)
	AutoOpenModalSystem.Bind(galaxy2Welcome, {
		openWithContent = function()
			InfoModalUISystem:Open("Galaxy 2 is finally here!", [[
This is a whole new world with new mechanics! 

Here, you start from scratch. Your stats from Galaxy 1 are safe there, but they don't transfer over. <b>The only things you keep are your items, treadmills and your Ascends!</b>

<font color="rgb(255, 200, 50)"><b>Yes! You can ascend in Galaxy 1 World 3 now!</b></font>
Ascend to get an exclusive item and a Multiplier that works across all Galaxies!

<font color="rgb(255, 50, 50)"><b><i>Warning... it is extremely hard to do! Who will manage to achieve it?</i></b></font>

<font size="14"><i>(Don't worry, Galaxy 1 will still receive updates!)</i></font>]], uDim)
		end
	})
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsClient() and Config.WORLD == 4 then
			bindClientWelcome()
		end
	end
})
return {}