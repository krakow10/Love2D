--Objects
local metatable={
	__index=function(self,index)
		return self.Data[index] or self.Children[index]
	end,
	__newindex=function(self,index,value)
		--
	end,
	__tostring=function(self)
		return self.Name
	end
}
function new(class)
	--
end

