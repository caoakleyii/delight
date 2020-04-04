function table.merge(dest, source, options)
	if not source then
		return dest
	end

	for k, v in pairs(source) do
		if type(v) == "table" and type(dest[k]) == "table" then
			-- don't overwrite one table with another
			-- instead merge them recurisvely
			table.merge(dest[k], v, options)
		else
			local continue = false
			if options and options.ignore_empty_strings and v == "" then
				continue = true
			end
			if not continue then
				dest[k] = v
			end
		end
	end

	return dest

end

function table.invert(t)
    local u = { }
    for k, v in pairs(t) do u[v] = k end
    return u
end