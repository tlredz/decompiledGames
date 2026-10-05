local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
FX:WaitForChild("Dough")
require(ReplicatedStorage.Util)
local Strand = require(ReplicatedStorage.EffectContainer.Dough.Util.Strand)
return function(data)
	local method = data.Method or "Create"
	local core = data.Core
	local scale = data.Scale or 1
	local root = data.Root
	local ID = data.ID

	if method == "Create" then
		Strand.new(core, scale, nil, root, ID)
		return
	end

	local v = Strand.get(ID) or Strand.get(root)

	if not v then
		return
	end

	if method == "Destroy" then
		v:Destroy(data.Duration)
	elseif method == "Fire" then
		v:fire(nil, data.Duration, true)
	elseif method == "Resize" or method == "Scale" then
		v:scale(scale)
	end
end