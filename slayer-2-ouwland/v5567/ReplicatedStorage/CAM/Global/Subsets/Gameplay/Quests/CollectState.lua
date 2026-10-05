local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
return {
	forTask = function(p: string, p2: string)
		return {
			Tasks = {
				[p2] = {
					Do = function(p3, _, object)
						local requiredItem = Quests.Holder[p].TaskSpecs[p2].RequiredItem
						local itemBag = Utility.ItemBag(Utility.GetData(p3), requiredItem)

						-- equivalent calls inferred from this helper; original call sites unknown
						local function nudge()
							SignalEvent.ToServer("QuestProgress", p, p2)
						end

						local function watchAmount(p4)
							if p4.Name ~= "Amount" then
								return
							end

							object:Connect(p4.Changed, nudge)
							nudge() -- equivalent call inferred; original call site unknown
						end

						-- equivalent calls inferred from this helper; original call sites unknown
						local function watchEntry(child)
							if child.Name ~= requiredItem then
								return
							end

							object:Connect(child.ChildAdded, watchAmount)
							local amount = child:FindFirstChild("Amount")

							if amount ~= nil then
								object:Connect(amount.Changed, nudge)
							end

							nudge() -- equivalent call inferred; original call site unknown
						end

						object:Connect(itemBag.ChildAdded, watchEntry)
						local child = itemBag:FindFirstChild(requiredItem)

						if child ~= nil then
							watchEntry(child) -- equivalent call inferred; original call site unknown
						end
					end
				}
			}
		}
	end
}