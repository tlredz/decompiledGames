local parent = script.Parent
local packages = parent.Parent.Packages
local Trove = require(packages.Trove)
require(parent.Signal)
require(packages.Promise)
return Trove