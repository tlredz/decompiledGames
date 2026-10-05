local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Mutations)
return Conch.register_type("Manage options", Conch.args.enum_new({ "add", "remove", "list" }))