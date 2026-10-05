local RunService = game:GetService("RunService")
local heartbeat = RunService.Heartbeat
return {
	typeWrite = function(p, value, p2)
		p.Visible = true
		p.AutoLocalize = false
		local text = value:gsub("<br%s*/>", "\n")
		text:gsub("<[^<>]->", "")
		p.MaxVisibleGraphemes = 0
		p.Text = text
		local total = 0
		local total2 = 0
		local count = #text
		local v2 = count / 3

		if p2 then
			task.spawn(function()
				while p.MaxVisibleGraphemes <= count do
					total2 += heartbeat:Wait()
					total += math.ceil(total2 / v2 * count)
					p.MaxVisibleGraphemes = total
				end
			end)
		end
	end
}