local ReplicatedStorage = game:GetService("ReplicatedStorage")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

require(ReplicatedStorage.Common.MarketplaceService)
require(ReplicatedStorage.Common.Utils)
require(ReplicatedStorage.Packages.Replion)