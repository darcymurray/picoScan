CAF = {}
CAF.minX, CAF.maxX, CAF.minY, CAF.maxY = -8000, 8000, -8000, 8000
CAF.Points = {}
CAF.LineSegments = {}

function ContainsPoint(table, pointX)
  for _, point in pairs(table) do
    if point:getX() == pointX:getX() and point:getY() == pointX:getY() then
      return true
    end
  end
  return false
end

function CAF.HandleOnPointer(iconicId, pointerActionType, pointerType, position)
  if pointerType ~= 'PRIMARY' then return end
  if pointerActionType ~= 'UP' then return end
  if not ContainsPoint(CAF.Points, position) then
    table.insert(CAF.Points, position)
  end
  if #CAF.Points == 1 then
    CAF.LineSegments = {}
  else
    local newLineSegment = Shape.createLineSegment(position, CAF.LatestPoint)
    table.insert(CAF.LineSegments, newLineSegment)
    if #CAF.Points > 4 then CAF.Points = {}
    elseif #CAF.Points == 4 then
      local lastLineSegment = Shape.createLineSegment(position, CAF.Points[1])
      table.insert(CAF.LineSegments, lastLineSegment)
      ChangeCubicAreaFilter()
      CAF.Points = {}
    end
  end
  CAF.LatestPoint = position
end

function ChangeCubicAreaFilter()
  -- Find min and max values
  local firstPoint = CAF.Points[1]
  CAF.minX, CAF.maxX, CAF.minY, CAF.maxY = firstPoint:getX(), firstPoint:getX(), firstPoint:getY(), firstPoint:getY()
  for key, point in pairs(CAF.Points) do
    local x, y = point:getX(), point:getY()
    if x < CAF.minX then CAF.minX = x end
    if x > CAF.maxX then CAF.maxX = x end
    if y < CAF.minY then CAF.minY = y end
    if y > CAF.maxY then CAF.maxY = y end
  end

  Scanner.CubicAreaFilter:setXRange(CAF.minX, CAF.maxX)
  Scanner.CubicAreaFilter:setYRange(CAF.minY, CAF.maxY)
  Scanner.CubicAreaFilter:setEnabled(true)

  -- Show cubic area filter vertices on the page
  local points = Point.create({CAF.minX, CAF.maxX, CAF.maxX, CAF.minX}, {CAF.maxY, CAF.maxY, CAF.minY, CAF.minY})
  local vertexA, vertexB, vertexC, vertexD = table.unpack(points)
  Script.notifyEvent("UpdateVertexADisplay", vertexA:toString())
  Script.notifyEvent("UpdateVertexBDisplay", vertexB:toString())
  Script.notifyEvent("UpdateVertexCDisplay", vertexC:toString())
  Script.notifyEvent("UpdateVertexDDisplay", vertexD:toString())

  -- Square line segments for a nice presentation
  CAF.LineSegments = {}
  local lastVertex
  local squaredLineSegment
  for key, vertex in pairs(points) do -- We know there are four vertices/keys
    if key == 1 then
      lastVertex = vertex
    else
      squaredLineSegment = Shape.createLineSegment(vertex, lastVertex)
      table.insert(CAF.LineSegments, squaredLineSegment)
      lastVertex = vertex
    end
    if key == 4 then
      squaredLineSegment = Shape.createLineSegment(vertex, points[1])
      table.insert(CAF.LineSegments, squaredLineSegment)
    end
  end
end

