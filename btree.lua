local function btree(lt)
   local bt = { value = math.huge }
   local lt = lt or (function(p,q) return p < q end)
   local gt = function(p,q) return lt(q,p) end
   local eq = not (lt or gt)

   function bt.empty(node)
      return not node or (node == bt and not (node.left or node.right))
   end

   function bt.find(node, val)
      if not node or bt.empty(node) then return false end
      if eq(val, node.value) then return node end
      return bt.find(node.left, val) or bt.find(node.right, val)
   end

   function bt.insert(node, val)
      if not node then
         node = { value = val }
      elseif lt(val, node.value) or bt.empty(node) then
         node.left = bt.insert(node.left, val) 
         node.left.parent = node
      elseif gt(val, node.value) then
         node.right = bt.insert(node.right, val) 
         node.right.parent = node
      end
      return node
   end

   function bt.replace(node, with)
      if node.parent then
         if node == node.parent.left then 
            node.parent.left = with
         end
         if node == node.parent.right then 
            node.parent.right = with 
         end
      end
      if with then with.parent = node.parent end
   end

   function bt.remove(node, val)
      if not node or bt.empty(node) then return end

      if lt(val, node.value) then
         bt.remove(node.left, val)
         return
      elseif gt(val, node.value) then
         bt.remove(node.right, val)
         return
      end

      if node.left and node.right then
         local next = bt.next(node)
         node.value = next.value
         bt.remove(node.right, node.value)
      elseif node.left then 
         bt.replace(node, node.left)
      elseif node.right then 
         bt.replace(node, node.right)
      else 
         bt.replace(node, nil)
      end
   end

   function bt.pop(node)
      if bt.empty(node) then return nil end

      local min = bt.min(node).value
      bt.remove(node, min)
      return min
   end

   function bt.min(node)
      return node.left and bt.min(node.left) or node
   end

   function bt.max(node)
      return node.right and bt.max(node.right) or node
   end

   function bt.next(node)
      if node.right then 
         return bt.min(node.right)
      end

      while node.parent and node == node.parent.right do
         node = node.parent
      end
      return node.parent
   end

   function bt.inorder(node, f)
      local iter = bt.min(node)
      repeat
         f(iter.value)
         iter = bt.next(iter)
      until not iter
   end

   function bt.print(node)
      io.write("( ")
      io.write(" "..node.value.." ")
      if node.left then bt.print(node.left) else io.write("()") end
      if node.right then bt.print(node.right) else io.write("()") end
      io.write(" )")
   end

   return bt
end

function test(n)
   math.randomseed(os.time())
   t = btree() 
   for i = 1,n do 
      local v = math.random()
      print(i,v) 
      t:insert(v) 
   end

   i = 0
   repeat
      i = i + 1
      print(i, " pop: "..t:pop())
   until t:empty() 
end

return btree
