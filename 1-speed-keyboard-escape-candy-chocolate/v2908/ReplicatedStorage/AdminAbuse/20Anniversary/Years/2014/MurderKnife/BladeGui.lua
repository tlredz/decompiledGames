local parent = script.Parent

function OnButton1Down(p)
	if parent.Enabled then
	end

	p.Icon = "http://www.roblox.com/asset/?id=54019936"

	while not parent.Enabled do
		parent.Changed:wait()
	end

	if parent.Enabled then
		p.Icon = "http://www.roblox.com/asset/?id=54019936"
	end
end

function OnEquipped(p)
	if p == nil then
		return
	end

	p.Icon = "http://www.roblox.com/asset/?id=54019936"
	p.Button1Down:connect(function()
		OnButton1Down(p)
	end)
end

parent.Equipped:connect(OnEquipped)