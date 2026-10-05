local CollectionService = game:GetService("CollectionService")
local parent = script.Parent
local v = nil

for _, v3 in ipairs(CollectionService:GetTagged("SecretTalk")) do
	if not v3:IsDescendantOf(parent) then
		continue
	end

	v = v3
	break
end

local v3 = v or parent:FindFirstChild("SecretTalk", true)

if v3 then
	v3.Text = ""

	for i = 1, 56 do
		v3.Text = string.sub("Hey mate ! Don't cheat at this game, alright? Have fun !", 1, i)
		task.wait(0.017857142857142856)
	end

	task.wait(4)
else
	task.wait(5)
end

parent:Destroy()