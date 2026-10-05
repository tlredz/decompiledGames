return function(p, p2, items)
	local collisionHits = {}
	local collisions = {}

	for _, item in items do
		local collisions2 = item:GetCollisions(p2, p.Radius)

		if #collisions2 > 0 then
			table.insert(collisionHits, item:GetObject())
		end

		for _, collision in collisions2 do
			table.insert(collisions, collision)
		end
	end

	for _, v2 in collisions do
		p2 = v2.ClosestPoint + v2.Normal * p.Radius
	end

	p.CollisionsData = collisions
	p.CollisionHits = collisionHits
	return p2
end