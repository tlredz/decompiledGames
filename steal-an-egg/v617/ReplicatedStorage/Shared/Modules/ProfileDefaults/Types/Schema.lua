local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SchemaFields = require(script.Parent.SchemaFields)
local t = require(ReplicatedStorage.Packages.t)
return t.interface(SchemaFields)