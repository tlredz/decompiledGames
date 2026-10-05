game:GetService("ReplicatedStorage")
local ContainerManager = {
	New = function(_, page)
		return {
			Page = page,
			Containers = {},
			Items = {}
		}
	end,
	AddContainer = function(self, p, container)
		table.insert(p.Containers, {
			Amount = 0,
			Container = container
		})
	end,
	Show = function(_, p)
		for _, item in p.Items do
			item.Visible = true
		end
	end,
	Hide = function(_, p)
		for _, item in p.Items do
			item.Visible = false
		end
	end,
	GetCurrentContainer = function(self, p)
		return p.Containers[1]
	end
}

function ContainerManager:InsertToContainer(data, p2)
	local currentContainer = ContainerManager:GetCurrentContainer(data)

	if currentContainer then
		p2.Parent = currentContainer.Container
		currentContainer.Amount += 1

		if currentContainer.Amount >= 2 then
			table.remove(data.Containers, 1)
		end
	else
		local clone = self.QuestTileTemplate:Clone()
		table.insert(data.Items, clone)
		clone.Parent = data.Page
		ContainerManager:AddContainer(data, clone:FindFirstChild("Container"))
		ContainerManager:InsertToContainer(data, p2)
	end
end

return ContainerManager