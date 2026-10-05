local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.UserGenerated.Concurrency.Bindable)
return table.freeze({
	UpdateRemote = script:WaitForChild("Update"),
	NullValue = script
})