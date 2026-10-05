local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RicherTextLabelProd = require(script.RicherTextLabelProd)
local vide = require(ReplicatedStorage.Packages.vide)
local root = vide.root
local localPlayer = Players.LocalPlayer
return {
	init = function()
		local v = {}

		local function setupRicherTextLabel(instance)
			local v2 = {}
			local v3 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function create()
				v2[2] = root(function()
					RicherTextLabelProd(instance)
				end)
			end

			local function checkConstruct()
				local v4 = instance:IsDescendantOf(localPlayer) or instance:IsDescendantOf(workspace)

				if v4 and not v3 then
					v3 = true
					create() -- equivalent call inferred; original call site unknown
				elseif not v4 and v3 then
					v3 = false
					v2[2]()
					v2[2] = nil
				end
			end

			local v4 = instance:IsDescendantOf(localPlayer) or instance:IsDescendantOf(workspace)

			if v4 and not v3 then
				v3 = true
				v2[2] = root(function()
					RicherTextLabelProd(instance)
				end)
			elseif not v4 and v3 then
				v3 = false
				v2[2]()
				v2[2] = nil
			end

			v2[1] = instance.AncestryChanged:Connect(checkConstruct)
			v[instance] = v2
		end

		local function destructRicherTextLabel(p)
			local v2 = v[p]

			if v2 then
				v2[1]:Disconnect()

				if v2[2] then
					v2[2]()
					v2[2] = nil
				end

				v[p] = nil
			end
		end

		for _, v2 in CollectionService:GetTagged("RicherText") do
			setupRicherTextLabel(v2)
		end

		CollectionService:GetInstanceAddedSignal("RicherText"):Connect(setupRicherTextLabel)
		CollectionService:GetInstanceRemovedSignal("RicherText"):Connect(destructRicherTextLabel)
	end
}