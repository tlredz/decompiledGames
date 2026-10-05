local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
require(ReplicatedStorage.Packages.Signal)
return {
	Cast = function(p)
		return p
	end
}