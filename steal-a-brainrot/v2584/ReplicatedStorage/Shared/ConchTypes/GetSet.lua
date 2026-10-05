local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Mutations)
return Conch.register_type("Get & Set", Conch.args.enum_new({ "get", "set" }))