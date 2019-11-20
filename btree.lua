local function btree(lt)
   local bt = {}
   local lt = lt or (function(p,q) return p < q end)
   local gt = function(p,q) return lt(q,p) end
   local eq = not (lt or gt)

   function bt.empty(node)
      return not (node and node.value)
   end

   function bt.find(node, val)
      if not node then return false end
      if eq(val, node.value) then return node end

      return bt.find(node.left, val) or bt.find(node.right, val)
   end

   function bt.insert(node, val)
      if not node then
         node = { value = val }
      elseif not node.value then
         node.value = val
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
      if node.parent then
         if node == node.parent.left then node.parent.left = with end
         if node == node.parent.right then node.parent.right = with end
      end
      if with then
         with.parent = node.parent
      end
   end

   function bt.remove(node, val)
      if not node then return end

      if lt(val, node.value) then
         bt.remove(node.left, val)
      elseif gt(val, node.value) then
         bt.remove(node.right, val)

      elseif node.left and node.right then
         local next = bt.min(node.right)
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

   function bt.min(node)
      return node.left and bt.min(node.left) or node
   end

   function bt.pop_min(node)
      local m = bt.min(node)
      if m.right then
         m.parent.left = m.right
      else
         m.parent.left = nil
      end
      return m
   end

   function bt.inorder_next(_, node)
      local val = node.value
      if node.right then 
         node = bt.min(node.right)
         return node, val 
      end

      while node.parent and node == node.parent.right do
         node = node.parent
      end
      return node.parent, val 
   end

   function bt.inorder(node)
      return bt.inorder_next, nil, bt.min(node)
   end

   return bt
end

return btree
