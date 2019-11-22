local function btree(lt)
   local bt = { value = "root" }
   local lt = 
   function(p,q) 
      if p == "root" then return false end 
      if q == "root" then return true end
      if lt then return lt(p,q) else return p < q end 
   end
   local gt = function(p,q) return lt(q,p) end
   local eq = function(p,q) return not (lt(p,q) or lt(q,p)) end

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
      elseif lt(val, node.value) then
         node.left = bt.insert(node.left, val) 
         node.left.parent = node
      elseif gt(val, node.value) then
         node.right = bt.insert(node.right, val) 
         node.right.parent = node
      end
      return node
   end

   function bt.replace(node, with)
      if node == node.parent.left then 
         node.parent.left = with
      end
      if node == node.parent.right then 
         node.parent.right = with 
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

   function bt.prev(node)
      if node.left then 
         return bt.max(node.left)
      end

      while node.parent and node == node.parent.left do
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
   function y_order(s, x)
      local a,b = s[1],s[2]
      print("ord", a, b)
      local t = (x - b[1]) / (a[1] - b[1])
      return a[2]*t + b[2]*(1 - t)
   end

   math.randomseed(os.time())
   t = btree(function(p,q) 
      print(p,q)
      return y_order(p, L) < y_order(q, L)
   end)
   for i = 1,n do 
      local v = { v2(math.random(), math.random()), v2(math.random(), math.random()) }
      t:insert(v) 
   end

   i = 0
   repeat
      i = i + 1
      print(i, " pop: "..t:pop()[1])
   until t:empty() 
end

return btree
