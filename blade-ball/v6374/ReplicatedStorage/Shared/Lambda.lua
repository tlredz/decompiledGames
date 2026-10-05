local Math = require(script.Math)
local Record = require(script.Record)
local Chain = require(script.Chain)
local Map = require(script.Map)
local Merge = require(script.Merge)
return (Merge({
	Chain = Chain,
	Map = Map,
	Merge = Merge,
	Math = Math
}, Record))