local modules={}
for _,c in next,{"draw","update","mousepressed","mousereleased","keypressed","keyreleased","focus"} do
	love[c]=function(...)
		for i=1,#modules do
			local f=modules[i][c]
			if f then
				f(...)
			end
		end
	end
end
return function(m)
	modules[#modules+1]=m
	return m
end
