local lab = {}

function sweep(segments)

   local T = {}
   local Q = { unpack(segments) }
   table.sort(Q, function(a,b) return a[1] < b[1] end)

   while #events > 0 do
      if segment_start then
         a,b = neighbours(T, s)
         if a and crossing(a, s) then
            insert(Q, crossing(a,s))
         end
         if b and crossing(b, s) then
            insert(Q, crossing(b,s))
         end
      end

      if segment_end then
         remove(T, s)
         a,b = neighbours(T, s)
         if a and b and crossing(a, b) then
            insert(Q, crossing(a,b))
         end
      end

      if segment_cross then
         
      end
   end

end

function btree(root)
   local bt = { value = root }
   function bt.insert(node, val)
      if not node then
         node = { value = val }
      elseif val <= node.value then
         bt.insert(node.left, val)
      elseif val > bt.value then
         bt.insert(node.right, val)
      end
   end
   function bt.inorder(node, val)
      if node then
         bt.inorder(node.left)
         print(node.value)
         bt.inorder(node.right)
      end
   end
   return bt
end

function lab.load()
   range = v2(-100, 100)
   segments = rand.segments(range, range, 30)
   for _,seg in ipairs(segments) do 
      seg.style = "line"
      seg.color = graph.c.blue
   end
end

function lab.update()
end

function lab.draw()
   graph.graph { title = "Losowe odcinki w przedziale "..range, unpack(segments) }
end

return lab
