local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local TableUtil = require(packages.TableUtil)
local module = require("../LocalDataState")

-- equivalent calls inferred from this helper; original call sites unknown
local function areAllRunesPlaced(p)
	if not (p and p.Runes and p.Runes.Placed) then
		return false
	end

	local keys = TableUtil.Keys(p.Runes.Placed)

	if keys then
		return #keys == 5
	end

	return false
end

local v = Component.new({
	Tag = "JungleDeleteOnAllPlaced",
	Ancestors = { Workspace }
})

function v:Construct()
	local flag = false
	self.DataObserver = module:observe(function(p)
		if flag then
			return
		end

		if self.Instance and self.Instance:IsDescendantOf(Workspace) then
			-- equivalent call inferred; original call site unknown
			if not areAllRunesPlaced(p) then
				return
			end

			if self.Instance then
				flag = true
				self.Instance:Destroy()

				if self.DataObserver then
					self.DataObserver()
					self.DataObserver = nil
				end
			end
		elseif self.DataObserver then
			self.DataObserver()
			self.DataObserver = nil
		end
	end, true)
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

return v