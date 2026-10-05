local Chat = game:GetService("Chat")
Chat.BubbleChatEnabled = true
Chat:SetBubbleChatSettings({
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	TextColor3 = Color3.fromRGB(250, 250, 250),
	LocalPlayerStudsOffset = vector.create(0, 0.6, 0)
})

local function checkTopbarEnabled()
	local v, v2 = xpcall(function()
		local StarterGui = game:GetService("StarterGui")
		return StarterGui:GetCore("TopbarEnabled")
	end, function(_)
		return true
	end)
	return v and v2
end

function shared.ResetButton(p)
	task.spawn(function()
		repeat
			local v = pcall(function()
				local StarterGui = game:GetService("StarterGui")
				StarterGui:SetCore("ResetButtonCallback", p and true or false)
			end)

			if not v then
				task.wait(0.5)
			end
		until v
	end)
end

function shared:SetCore(no, justbackpack)
	if not shared.BackpackVisibility then
		return
	end

	local currenttopbar = shared.currenttopbar

	if currenttopbar and currenttopbar.b == self and currenttopbar.no == no and currenttopbar.justbackpack == justbackpack then
		return
	end

	if not justbackpack then
		for i = 0, 6 do
			if i == no then
				continue
			end

			if i == 2 then
				game.StarterGui:SetCoreGuiEnabled(2, false)
			else
				game.StarterGui:SetCoreGuiEnabled(i, self)
			end
		end
	end

	game.StarterGui:SetCoreGuiEnabled(2, false)
	shared.BackpackVisibility(self)

	if not shared.isconsole and shared.settopbar then
		shared.settopbar(self, false)
	end

	shared.currenttopbar = {
		b = self,
		no = no,
		justbackpack = justbackpack
	}
end