local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.packages.Signal)
require(ReplicatedStorage.shared.modules.Hook)
require(ReplicatedStorage.shared.modules.fishing.FishInstance.Types)
require(ReplicatedStorage.shared.modules.fishing.BiteTypes)
require(ReplicatedStorage.shared.modules.CustomTweens.Types)
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing"):WaitForChild("customharpoons"):WaitForChild("default")
return {}