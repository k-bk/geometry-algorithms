local lab = {}

function categorize_points(shape)
   local cat = {}
   local n = #shape
   for i = 1, #shape do
      local first, middle, last = shape[(i-2)%n+1], shape[i], shape[i%n+1]

      if first.y > middle.y and last.y > middle.y then
         if orient(first, middle, last) == 1 then
            cat[middle] = { { 102/255,153/255,1 }, "dzielący" }
         else
            cat[middle] = { { 0,204/255,0 }, "początkowy" }
         end
      elseif first.y < middle.y and last.y < middle.y then
         if orient(first, middle, last) == 1 then
            cat[middle] = { { 51/255,51/255,153/255 }, "łączący" }
         else
            cat[middle] = { { 1,0,0 }, "końcowy" }
         end
      else
         cat[middle] = { { 102/255,51/255,0 }, "prawidłowy" }
      end
   end
   return cat
end

function y_monotone(shape)
   assert(#shape >= 3)

   local swaps = 0
   local res = { left = stack(), right = stack() }

   local top = array_min(shape, function(p,q) return p.y < q.y end)
   array_rotate_left(shape, top - 1)

   local n = #shape
   local side = "left"
   for i = 1,n do
      res[side][shape[i]] = true
      if side == "left" and shape[i].y > shape[i%n + 1].y then
         swaps = swaps + 1
         side = "right"
      elseif side == "right" and shape[i].y < shape[i%n + 1].y then
         swaps = swaps + 1
         side = "left"
      end
   end

   return swaps <= 2, res.left, res.right
end

function triangulate_monotone(shape, left, right)

   -- sort the shape, shape[1] is the point on top
   local sorted = {}
   local i,j = 1,#shape
   while i <= j do
      if shape[i].y < shape[j].y then
         table.insert(sorted, shape[i])
         i = i + 1
      else
         table.insert(sorted, shape[j])
         j = j - 1
      end
   end

   shape = sorted
   local diagonals = {}
   local S = stack()
   local point

   S:push(shape[1])
   S:push(shape[2])
   coroutine.yield(S, diagonals, "Włóż dwa pierwsze wierzchołki na stos")

   for i = 3,#shape do
      if ( left[shape[i]] and right[S:top()] )
      or ( right[shape[i]] and left[S:top()] ) 
      then -- if on different sides
         coroutine.yield(S, diagonals, 
            "Wierzchołek ("..point_label[shape[i]]..") na innym łańcuchu")
         while #S >= 2 do
            point = S:pop()
            table.insert(diagonals, { point, shape[i] }) 
         end
         S:pop()
         S:push(point)
         S:push(shape[i])
      else -- if on the same side
         coroutine.yield(S, diagonals, 
            "Wierzchołek ("..point_label[shape[i]]..") na tym samym łańcuchu")
         local first = shape[i] 
         local middle = S:pop()
         local last = S:pop() 
         print("check same side")
         while last and middle do
            print(point_label[first], point_label[middle], point_label[last], orient(first, middle, last))
            if ( left[middle] and orient(first, middle, last) == 1 )
            or ( right[middle] and orient(first, middle, last) == -1 )
            then
               coroutine.yield(S, diagonals, 
                  "Czy krawędź ("..point_label[first]..point_label[last]..") jest wewnątrz: Tak")
               table.insert(diagonals, { first, last }) 
            else
               coroutine.yield(S, diagonals, 
                  "Czy krawędź ("..point_label[first]..point_label[last]..") jest wewnątrz: Nie")
               S:push(last)
               break
            end
            middle = last
            last = S:pop()
         end
         S:push(middle)
         S:push(first)
      end
   end

   --[[
   S:pop()
   while S:top() do
      local point = S:pop()
      table.insert(diagonals, { point, shape[#shape] }) 
      coroutine.yield(S, diagonals, "Ostatni wierzchołek")
   end
   --]]

   while true do
      coroutine.yield(S, diagonals, "Koniec triangulacji")
   end
end

function lab.load()
   point_label = {}
   monotone_label = "Narysuj wielokąt"
   state = "main"
   shape = {}
   left, right = {}, {}
   lab.update()
end

function lab.update(input)
   if input == "click" and mouse_position.x > ui_width + 10 then
      if state == "main" and #shape == 0 then
         state = "drawing"
         monotone_label = "Narysuj wielokąt"
      end
      if state == "drawing" then
         snapped = false
         snap_mouse(shape[1])
         snap_mouse(shape[#shape])
      end
      if snapped then
         -- end drawing
         state = "main"
         monotone, left, right = y_monotone(shape)
         monotone_label = monotone and "TAK" or "NIE"
         categories = categorize_points(shape)
      else
         table.insert(shape, mouse_position)
         local base = string.byte("A") - 1
         point_label[mouse_position] = string.char(base + #shape)
      end
   end
end

function snap_mouse(point)
   if point and (point - mouse_position):len() < 15 then
      snapped = true
      mouse_position = point
   end
end

function lab.mousemoved()
   snapped = false
   if state == "main" then
      for _,point in ipairs(shape) do
         snap_mouse(point)
      end
   end
   if state == "drawing" then
      snap_mouse(shape[1])
      snap_mouse(shape[#shape])
   end
end

function lab.draw()
   ui_width, _ = UI.draw { x = 10, y = 10,
      UI.label { "y-monotoniczny:  " },
      UI.label { monotone_label },
      UI.label {""},
      UI.button { "Reset", on_click = function() 
         algorithm = nil
         monotone = false
         monotone_label = "Narysuj wielokąt"
         diagonals = {}
         shape = {} 
      end },
      monotone and UI.button { algorithm and "Dalej" or "Triangulacja", on_click = function() 
         if not algorithm then
            state = "main" 
            algorithm = coroutine.wrap(function() return triangulate_monotone(shape, left, right) end)
         end
         S, diagonals, algorithm_label = algorithm()
         stack_label = "_"
         for _,v in ipairs(S) do
            stack_label = stack_label.." -> "..point_label[v]
         end
      end } or UI.label{""},
   }
   UI.draw { x = ui_width + 30, y = 10,
      UI.label { "Triangulacja: "..(algorithm_label or "wprowadź wielokąt") },
      UI.label { "Stos: "..(stack_label or "pusty") },
   }
   love.graphics.setColor(.7,.7,.7)
   love.graphics.line(ui_width + 20, 0, ui_width + 20, 2000)

   draw_polygon(shape, {.8,.8,.8})
   if diagonals then
      love.graphics.setColor( { .5,0,0 } )
      for _,d in ipairs(diagonals) do
         love.graphics.line(d[1].x, d[1].y, d[2].x, d[2].y)
      end
   end
   if state == "main" then
      for _,point in ipairs(shape) do
         if categories[point] then
            local color = categories[point][1]
            love.graphics.setColor(color)
            love.graphics.circle("fill", point.x, point.y, 5)
            love.graphics.setColor(0,0,0)
            love.graphics.circle("line", point.x, point.y, 5)
         end
      end
   end
   if state == "main" and snapped and categories[mouse_position] then
      love.graphics.printf(categories[mouse_position], font_body, 
         mouse_position.x - 100, mouse_position.y - 40, 200, "center")
   end
   if state == "drawing" then draw_red_point(mouse_position) end
end

function draw_red_point(p)
   local ps = love.graphics.getPointSize()
   love.graphics.setPointSize(10)
   love.graphics.points({{ p.x, p.y, 1,0,0 }})
   love.graphics.setPointSize(ps)
end

function draw_polygon(polygon, color)
   local r,g,b,a = love.graphics.getColor()
   local ps = love.graphics.getPointSize()
   local lw = love.graphics.getLineWidth()
   local shape = {}

   for _,point in ipairs(polygon) do
      table.insert(shape, point.x)
      table.insert(shape, point.y)
   end

   if state == "drawing" and mouse_position.x > ui_width + 10 then
      table.insert(shape, mouse_position.x)
      table.insert(shape, mouse_position.y)
   end

   if state == "drawing" then 
      love.graphics.setColor(.6,.6,.6)
   else
      love.graphics.setColor(color or {1,0,0}) 
   end
   love.graphics.setLineWidth(2)
   if #shape > 4 then love.graphics.polygon("line", shape) end
   love.graphics.setColor(0,0,0)
   love.graphics.setPointSize(6)
   love.graphics.points(shape)

   for _,point in ipairs(polygon) do
      local letter = point_label[point]
      if letter then
         love.graphics.print(letter, point.x - 12, point.y - 22)
      end
   end

   love.graphics.setLineWidth(lw)
   love.graphics.setPointSize(ps)
   love.graphics.setColor(r,g,b,a)
end

return lab
