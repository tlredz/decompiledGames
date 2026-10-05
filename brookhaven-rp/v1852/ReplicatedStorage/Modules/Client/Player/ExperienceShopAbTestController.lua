local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)

-- equivalent calls inferred from this helper; original call sites unknown
local function setExperienceShopEnabled(flag: boolean)
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.ExperienceShop, flag)
	end)
end

return {
	FrameworkStart = function()
		ABTest.GetExperimentVariable("in-experience-shop", "enabled"):andThen(function(flag: boolean)
			setExperienceShopEnabled(flag) -- equivalent call inferred; original call site unknown
		end):timeout(10):catch(function(p)
			LogService:Error("ExperienceShopAbTestController: Failed to fetch experiment variable", p)
			setExperienceShopEnabled(false) -- equivalent call inferred; original call site unknown
		end)
	end
}