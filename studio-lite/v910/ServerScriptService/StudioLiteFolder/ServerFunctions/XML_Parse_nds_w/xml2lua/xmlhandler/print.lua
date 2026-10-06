local Print = {}

function Print.starttag(_, p, _, _)
	print("Start    : " .. p.name .. "\n")

	if p.attrs then
		for k, attr in pairs(p.attrs) do
			print(string.format(" + %s='%s'\n", k, attr))
		end
	end
end

function Print.endtag(_, p, _, _)
	print("End      : " .. p.name .. "\n")
end

function Print.text(_, p, _, _)
	print("Text     : " .. p .. "\n")
end

function Print.cdata(_, p, _, _)
	print("CDATA    : " .. p .. "\n")
end

function Print.comment(_, p, _, _)
	print("Comment  : " .. p .. "\n")
end

function Print.dtd(_, p, _, _)
	print("DTD      : " .. p.name .. "\n")

	if p.attrs then
		for k, attr in pairs(p.attrs) do
			print(string.format(" + %s='%s'\n", k, attr))
		end
	end
end

function Print.pi(_, p, _, _)
	print("PI       : " .. p.name .. "\n")

	if p.attrs then
		for k, attr in pairs(p.attrs) do
			print(string.format(" + %s='%s'\n", k, attr))
		end
	end
end

function Print.decl(_, p, _, _)
	print("XML Decl : " .. p.name .. "\n")

	if p.attrs then
		for k, attr in pairs(p.attrs) do
			print(string.format(" + %s='%s'\n", k, attr))
		end
	end
end

return Print