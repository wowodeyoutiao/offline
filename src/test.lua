local f = {
	e = {
		g = 22
	}
}
local t = {}
for k,v in pairs(f) do
	t[k] = v
end
for k,v in pairs(t) do
	for k1,v1 in pairs(v) do
		print(k1, v1)
	end
end
