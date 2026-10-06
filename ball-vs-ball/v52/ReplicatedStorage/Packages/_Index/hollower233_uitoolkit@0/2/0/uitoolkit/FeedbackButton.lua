local SocialService = game:GetService("SocialService")
local TopbarPlus = require(script.Parent.Parent:WaitForChild("TopbarPlus"))
local v = nil
return {
	Init = function()
		if v then
			return v
		end

		v = TopbarPlus.new():align("Left"):oneClick():setImageScale(0.65):setImage(91033953850956)
		v:bindEvent("selected", function()
			v:lock()
			local success, result = pcall(function()
				SocialService:PromptFeedbackSubmissionAsync()
			end)

			if success then
				v:destroy()
				print("反馈提示结束")
			else
				v:unlock()
				warn((`反馈失败: {result}`))
			end
		end)
		return v
	end
}