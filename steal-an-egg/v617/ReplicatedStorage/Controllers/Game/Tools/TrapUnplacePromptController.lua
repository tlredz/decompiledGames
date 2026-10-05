local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local localPlayer = Players.LocalPlayer
local UNPLACE_PROMPT = Constants.TAGS_MAP.Traps.UNPLACE_PROMPT
local v = {}
return {
	Start = function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanupPromptConnections(p)
			local v2 = v[p]

			if not v2 then
				return
			end

			local owner = v2.Owner

			if owner then
				owner:Disconnect()
			end

			local active = v2.Active

			if active then
				active:Disconnect()
			end

			v[p] = nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePromptEnabled(p)
			local parent = p.Parent

			if not (parent and parent:IsA("BasePart")) then
				p.Enabled = false
				return
			end

			local owner = parent:GetAttribute("Owner")
			local trapActive = parent:GetAttribute("TrapActive")
			p.Enabled = owner == localPlayer.Name and trapActive ~= true
		end

		local function bindPromptConnections(p)
			cleanupPromptConnections(p) -- equivalent call inferred; original call site unknown
			local parent = p.Parent

			if parent and parent:IsA("BasePart") then
				v[p] = {
					Owner = parent:GetAttributeChangedSignal("Owner"):Connect(function()
						updatePromptEnabled(p) -- equivalent call inferred; original call site unknown
					end),
					Active = parent:GetAttributeChangedSignal("TrapActive"):Connect(function()
						updatePromptEnabled(p) -- equivalent call inferred; original call site unknown
					end)
				}
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshPrompt(p)
			bindPromptConnections(p)
			updatePromptEnabled(p) -- equivalent call inferred; original call site unknown
		end

		local function trackPrompt(proximityPrompt)
			refreshPrompt(proximityPrompt) -- equivalent call inferred; original call site unknown
			proximityPrompt.AncestryChanged:Connect(function(_, parent)
				if parent then
					refreshPrompt(proximityPrompt) -- equivalent call inferred; original call site unknown
				else
					cleanupPromptConnections(proximityPrompt) -- equivalent call inferred; original call site unknown
				end
			end)
			proximityPrompt.Destroying:Connect(function()
				cleanupPromptConnections(proximityPrompt) -- equivalent call inferred; original call site unknown
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onPromptAdded(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return
			end

			trackPrompt(proximityPrompt)
		end

		local function onPromptRemoved(proximityPrompt)
			if not proximityPrompt:IsA("ProximityPrompt") then
				return
			end

			cleanupPromptConnections(proximityPrompt) -- equivalent call inferred; original call site unknown
		end

		for _, v2 in ipairs(CollectionService:GetTagged(UNPLACE_PROMPT)) do
			onPromptAdded(v2) -- equivalent call inferred; original call site unknown
		end

		CollectionService:GetInstanceAddedSignal(UNPLACE_PROMPT):Connect(onPromptAdded)
		CollectionService:GetInstanceRemovedSignal(UNPLACE_PROMPT):Connect(onPromptRemoved)
	end
}