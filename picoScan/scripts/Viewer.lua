Viewer = {}
Viewer.MinX, Viewer.MaxX = -10000, 10000
Viewer.MinY, Viewer.MaxY = -10000, 10000
Viewer.EnableBounds = true

-- Default Graph Decoration
Viewer.Decoration = View.GraphDecoration.create()
Viewer.Decoration:setAxisColor(0,0,0)
Viewer.Decoration:setAspectRatio('FIT')
Viewer.Decoration:setAxisVisible(true)
-- Viewer.Decoration:setAxisWidth()
Viewer.Decoration:setBackgroundColor(255,255,255)
Viewer.Decoration:setBackgroundVisible(true)
-- Viewer.Decoration:setDrawSize(20.0)
Viewer.Decoration:setDynamicSizing(false)
Viewer.Decoration:setGraphColor(0,255,0)
-- Viewer.Decoration:setGridColor()
Viewer.Decoration:setGridVisible(true)
-- Viewer.Decoration:setIndexCoordinates()
Viewer.Decoration:setLabelColor(0,0,0)
-- Viewer.Decoration:setLabelSize()
Viewer.Decoration:setLabels("X", "Y")
Viewer.Decoration:setLabelsVisible(true)
-- Viewer.Decoration:setPolarPlot()
Viewer.Decoration:setTitle("Title")
if Viewer.EnableBounds then 
  Viewer.Decoration:setXBounds(Viewer.MinX, Viewer.MaxX)
  Viewer.Decoration:setYBounds(Viewer.MinY, Viewer.MaxY)
end

-- UI Viewers
-- Viewer.ViewerProfiles = View.create('ViewerProfiles')
-- Viewer.ViewerPointClouds = View.create('ViewerPointClouds')
Viewer.ViewerPoints = View.create('ViewerPoints')

-- Changeable cubic area filter
local function containsPoint(table, pointX)
  for _, point in pairs(table) do
    if point:getX() == pointX:getX() and point:getY() == pointX:getY() then
      return true
    end
  end
  return false
end
Viewer.CAFPoints = {}
Viewer.CAFLineSegments = {}
Viewer.ViewerPoints:register("OnPointer", "HandleOnPointer")
function HandleOnPointer(iconicId, pointerActionType, pointerType, position)
  if pointerType ~= 'PRIMARY' then return end
  if pointerActionType ~= 'UP' then return end
  if not containsPoint(Viewer.CAFPoints, position) then table.insert(Viewer.CAFPoints, position) end
  if #Viewer.CAFPoints == 1 then
    Viewer.CAFLineSegments = {}
  else
    local newLineSegment = Shape.createLineSegment(position, Viewer.LatestCAFPoint)
    table.insert(Viewer.CAFLineSegments, newLineSegment)
    if #Viewer.CAFPoints > 4 then Viewer.CAFPoints = {} -- This shouldn't happen
    elseif #Viewer.CAFPoints == 4 then
      local lastLineSegment = Shape.createLineSegment(position, Viewer.CAFPoints[1])
      table.insert(Viewer.CAFLineSegments, lastLineSegment)
      ChangeCubicAreaFilter()
      Viewer.CAFPoints = {}
    end
  end
  Viewer.LatestCAFPoint = position
end

function ChangeCubicAreaFilter()
  -- Find min and max values
  local firstPoint = Viewer.CAFPoints[1]
  local minX, maxX, minY, maxY = firstPoint:getX(), firstPoint:getX(), firstPoint:getY(), firstPoint:getY()
  for key, point in pairs(Viewer.CAFPoints) do
    local x, y = point:getX(), point:getY()
    if x < minX then minX = x end
    if x > maxX then maxX = x end
    if y < minY then minY = y end
    if y > maxY then maxY = y end
  end

  -- Cubic area filter is a square
  Scanner.CubicAreaFilter:setXRange(minX, maxX)
  Scanner.CubicAreaFilter:setYRange(minY, maxY)
  Scanner.CubicAreaFilter:setEnabled(true)

  -- Show cubic area filter vertices on the page
  local points = Point.create({minX, maxX, maxX, minX}, {maxY, maxY, minY, minY})
  local vertexA, vertexB, vertexC, vertexD = table.unpack(points)
  Script.notifyEvent("UpdateVertexADisplay", vertexA:toString())
  Script.notifyEvent("UpdateVertexBDisplay", vertexB:toString())
  Script.notifyEvent("UpdateVertexCDisplay", vertexC:toString())
  Script.notifyEvent("UpdateVertexDDisplay", vertexD:toString())

  -- Square line segments for a nice presentation
  Viewer.CAFLineSegments = {}
  local lastVertex
  local squaredLineSegment
  for key, vertex in pairs(points) do -- We know there are four vertices/keys
    if key == 1 then
      lastVertex = vertex
    else
      squaredLineSegment = Shape.createLineSegment(vertex, lastVertex)
      table.insert(Viewer.CAFLineSegments, squaredLineSegment)
      lastVertex = vertex
    end
    if key == 4 then
      squaredLineSegment = Shape.createLineSegment(vertex, points[1])
      table.insert(Viewer.CAFLineSegments, squaredLineSegment)
    end
  end
end


Script.serveEvent('picoScan.UpdateVertexADisplay', 'UpdateVertexADisplay')
Script.serveEvent('picoScan.UpdateVertexBDisplay', 'UpdateVertexBDisplay')
Script.serveEvent('picoScan.UpdateVertexCDisplay', 'UpdateVertexCDisplay')
Script.serveEvent('picoScan.UpdateVertexDDisplay', 'UpdateVertexDDisplay')


