local stack = {}

do 
   local s = {}
   s.__index = s
   
   function s.pop(s)
      local top = s[#s]
      table.remove(s)
      return top
   end

   function s.push(s, item) table.insert(s, item) end
   function s.top(s) return s[#s] end
   function s.empty(s) return #s < 1 end

   setmetatable(stack, { 
      __call = function() 
         return setmetatable({}, s) 
      end })
end

return stack
