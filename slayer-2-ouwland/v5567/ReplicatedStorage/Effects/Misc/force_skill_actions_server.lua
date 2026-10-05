local Skill_Controller = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Controllers"):WaitForChild("Skill_Controller"))
return function(p, p2, p3, p4, ...)
	if p ~= nil and p2 ~= nil then
		if p2 == "Cancel" then
			Skill_Controller.ForceCancel(p, p3, p4)
		elseif p2 == "Hold" then
			Skill_Controller.Attempt_Hold(p)
		elseif p2 == "UnHold" then
			Skill_Controller.StopHold(p, p3, p4)
		elseif p2 == "Counter" then
			Skill_Controller.Counter(p, p3, p4, ...)
		elseif p2 == "Toggle" then
			Skill_Controller.Toggle(p, p3, p4, ...)
		end
	end
end