local lab = {}

local function plot(x) 
   autorun = false
   coroutine.yield(x) 
end
local function autoplot(x) 
   autorun = true
   coroutine.yield(x) 
end
local function as_lines(x)
   for _,s in ipairs(x) do
      s.style = "line"
      s.color = { 0.5, 0.5, 0.5 }
   end
end

function y_monotonic(shape)
   assert(#shape >= 3)

   side = (shape[1].y < shape[2].y) and "left" or "right"
   swaps = 0
   res = { left = {}, right = {} }
   for i = 2,#shape do
      if side == "left" and shape[i-1].y > shape[i].y then
         swaps = swaps + 1
         side = "right"
      elseif side == "right" and shape[i-1].y < shape[i].y then
         swaps = swaps + 1
         side = "left"
      end
      table.insert(res[side], shape[i])
   end
   return swaps <= 2, res.left, res.right
end

function intersecting(p, q)
   if p == q then return false end
   local a,b,c,d = p[1],p[2],q[1],q[2]
   return orient(a, b, c) ~= orient(a, b, d) 
      and orient(c, d, a) ~= orient(c, d, b) 
end

function inside(shape, segment)
   for i = 2,#shape do
      if intersecting({ shape[i-1], shape[i] }, segment) then return true end
   end
   if intersecting({ shape[1], shape[#shape] }, segment) then return true end
   return false
end

function triangulate_monotonic(shape, left, right)

   table.sort(shape, function(p,q) 
      if p.y == q.y then 
         return p.x < q.x 
      else 
         return p.y < q.y 
      end 
   end)
   local diagonals = {}
   local S = stack()
   local point

   S:push(shape[1])
   S:push(shape[2])

   for i = 3,#shape-1 do
      if ( left[shape[i]] and right[S:top()] )
         or ( right[shape[i]] and left[S:top()] ) 
      then -- if on different sides
         while S:top() do
            point = S:pop()
            if S:top() then -- if not last point on stack
               table.insert(diagonals, { point, shape[i] }) 
            end
         end
         S:push(point)
         S:push(shape[i])
      else -- if on the same side
         S:pop()
         while S:top() and inside(shape, { S:top(), shape[i] }) do
            table.insert(diagonals, { point, shape[i] }) 
            point = S:pop()
         end
         S:push(point)
         S:push(shape[i])
      end
   end

   S:pop()
   while #S > 1 do
      table.insert(diagonals, { S:pop(), shape[#shape] })
   end

   return diagonals
end

function lab.load()
   monotonic = "Narysuj wielokąt"
   state = "main"
   shape = {}
   left, right = {}, {}
   lab.update()
end

function lab.update(input)
   if input == "click" and mouse_position.x > ui_width + 10 then
      if state == "main" and #shape == 0 then
         state = "drawing"
         monotonic = "Narysuj wielokąt"
      end
      if state == "drawing" then
         snapped = false
         snap_mouse(shape[1])
         snap_mouse(shape[#shape])
      end
      if snapped then
         -- end drawing
         state = "main"
         result, left, right = y_monotonic(shape)
         monotonic = result and "TAK" or "NIE"
      else
         table.insert(shape, mouse_position)
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
   if state == "drawing" then
      snapped = false
      snap_mouse(shape[1])
      snap_mouse(shape[#shape])
   end
end

function lab.draw()
   ui_width, _ = UI.draw { x = 10, y = 10,
      UI.label { "y-monotoniczny:  " },
      UI.label { monotonic },
      UI.label { "" },
      UI.button( "Reset", function() shape = {} end ),
      UI.button( "Triangulacja", function() 
         state = "triangulate" 
         diagonals = triangulate_monotonic(shape, left, right) 
      end ),
   }
   love.graphics.setColor(0,0,0)
   love.graphics.line(ui_width + 20, 0, ui_width + 20, 2000)

   draw_polygon(shape)
   if state == "drawing" then draw_red_point(mouse_position) end
end

function draw_red_point(p)
   local ps = love.graphics.getPointSize()
   love.graphics.setPointSize(10)
   love.graphics.points({{ p.x, p.y, .8,0,0,1 }})
   love.graphics.setPointSize(ps)
end

function draw_polygon(polygon)
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
      love.graphics.setColor(.8,.8,.8)
   else
      love.graphics.setColor(1,0,0) 
   end
   love.graphics.setLineWidth(2)
   if #shape > 4 then love.graphics.polygon("line", shape) end
   love.graphics.setColor(0,0,0)
   love.graphics.setPointSize(6)
   love.graphics.points(shape)

   love.graphics.setLineWidth(lw)
   love.graphics.setPointSize(ps)
   love.graphics.setColor(r,g,b,a)
end

return lab
