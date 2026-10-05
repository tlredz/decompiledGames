local MimeMakeup = {}
MimeMakeup.MonsterTrinket = true
MimeMakeup.GeneratorText = "This time, they can't hear you…"
MimeMakeup.GeneratorSound = "rbxassetid://105784755732269"
MimeMakeup.Name = "Mime Makeup"
MimeMakeup.Icon = "rbxassetid://79449792220001"
MimeMakeup.Rarity = "Rare"
MimeMakeup.Main = false
MimeMakeup.Description = "When failing a skillcheck the user will not alert the Twisted to their location."
MimeMakeup.TrinketType = "Passive"
MimeMakeup.Cost = 250
MimeMakeup.Requirement1 = { "Coin", 250 }

function MimeMakeup.ApplyTrinket(_, _) end

function MimeMakeup.RemoveTrinket(_) end

function MimeMakeup.TriggerSkillCheckFailEvent(_, _, _)
	return true
end

return MimeMakeup