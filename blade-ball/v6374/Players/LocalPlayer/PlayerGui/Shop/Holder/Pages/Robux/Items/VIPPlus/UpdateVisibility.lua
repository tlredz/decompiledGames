local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local Replion = require(ReplicatedStorage.Packages.Replion)
local v = Replion.Client:WaitReplion("Data")

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	script.Parent.Visible = v:Get("Subscriptions.VIPPlus.Active")
end

v:OnChange("Subscriptions.VIPPlus.Active", update)
update() -- equivalent call inferred; original call site unknown