Scanner = {}

Scanner.EnableCAF = false
Scanner.CubicAreaFilter = Scan.CubicAreaFilter.create()

Scanner.Fitter = Point.ShapeFitter.create()
Scanner.Fitter:setFitMode('LEASTSQUARES')
Scanner.LineSegment = {}
Scanner.ObjectLengthList = {}

Scanner.Transformer = Scan.Transform.create()
-- Transformer:setAlphaBetaGamma()
-- Transformer:setPosition()
-- Transformer:setYawPitchRoll()

Scanner.ScanProvider = Scan.Provider.RemoteScanner.create()
Scanner.ScanProvider:setIPAddress('192.168.1.100')
Scanner.ScanProvider:setSensorType('LMSX00')
-- Scan handler (Scan is 2D Polar)
function Scanner.HandleOnNewScan(scan)
  -- Apply cubic area filter
  if Scanner.EnableCAF then scan = Scanner.CubicAreaFilter:filter(scan) end

  -- Scan -> Point Cloud (3D Cartesian) -> 2D Cartesian
  local pointCloud = Scanner.Transformer:transformToPointCloud(scan)
  Scanner.X, Scanner.Y, _, _ = pointCloud:toVector()
  if #Scanner.X < 2 or #Scanner.Y < 2 then return end
  Viewer.ViewerPoints:addGraph(Scanner.Y, Scanner.X, Viewer.PointDecoration)

  -- Cubic area filter points/lines
  if Scanner.EnableCAF then
    Viewer.ViewerPoints:addPoint(CAF.Points, Viewer.CAFDecoration)
    for _, CAFLineSegment in pairs(CAF.LineSegments) do
      Viewer.ViewerPoints:addShape(CAFLineSegment, Viewer.CAFLineSegmentDecoration)
    end
  end

  -- Line fitter
  if Scanner.LineSegment ~= {} then
    Viewer.ViewerPoints:addShape(Scanner.LineSegment, Viewer.LineSegmentDecoration)
    Viewer.ViewerPoints:addPoint({Scanner.LSP1, Scanner.LSP2, Scanner.LSCentre}, Viewer.LineSegmentPointDecoration)
  end

  if Scanner.LinesToFit > 0 then
    Scanner.LinesToFit = Scanner.LinesToFit - 1
    Scanner.GetOnlySegmentLength()
  end

  Viewer.ViewerPoints:present()
end
Scanner.ScanProvider:register( 'OnNewScan', Scanner.HandleOnNewScan )

-- Cubic area filter
function Scanner.OnCAFButtonChange(change)
  Scanner.EnableCAF = change
  Scanner.CubicAreaFilter:setEnabled(change)

  if change == true then
    Viewer.ViewerPoints:register('OnPointer', CAF.HandleOnPointer)
  else
    CAF.minX, CAF.maxX, CAF.minY, CAF.maxY = Viewer.MinX, Viewer.MaxX, Viewer.MinY, Viewer.MaxY
    CAF.Points = {}
    CAF.LineSegments = {}
    Viewer.ViewerPoints:deregister('OnPointer', CAF.HandleOnPointer)
  end

  Scanner.CubicAreaFilter:setXRange(CAF.minX, CAF.maxX)
  Scanner.CubicAreaFilter:setYRange(CAF.minY, CAF.maxY)

  Script.notifyEvent("UpdateCAFEnabledDisplay", Scanner.EnableCAF)
  Script.notifyEvent("UpdateVertexADisplay", tostring(minX))
  Script.notifyEvent("UpdateVertexBDisplay", tostring(maxX))
  Script.notifyEvent("UpdateVertexCDisplay", tostring(minY))
  Script.notifyEvent("UpdateVertexDDisplay", tostring(maxY))
end
Script.notifyEvent("UpdateCAFEnabledDisplay", Scanner.EnableCAF)
Script.serveFunction("picoScan.OnCAFButtonChange", Scanner.OnCAFButtonChange)

-- Line fitting
function AnalyseLineSegment(lineSegment)
  local p1, p2 = lineSegment:getLineParameters()
  local centre = Point.create((p1:getX() + p2:getX()) / 2, (p1:getY() + p2:getY()) / 2)
  return p1, p2, centre
end

function CalculateRadialDistances(p1, p2, centre)
  local p1D = math.sqrt(p1:getX()^2 + p1:getY()^2)
  local p2D = math.sqrt(p2:getX()^2 + p2:getY()^2)
  local centreD = math.sqrt(centre:getX()^2 + centre:getY()^2)
  return p1D, p2D, centreD
end

function Scanner.OnFitLineSubmit()
  -- Line fitting and radial distances
  local points = Point.create(Scanner.X, Scanner.Y)
  Scanner.LineSegment, _ = Scanner.Fitter:fitLine(points)
  Scanner.LSP1, Scanner.LSP2, Scanner.LSCentre = AnalyseLineSegment(Scanner.LineSegment)
  local length = math.abs(Scanner.LSP1:getY() - Scanner.LSP2:getY())
  local p1D, p2D, centreD = CalculateRadialDistances(Scanner.LSP1, Scanner.LSP2, Scanner.LSCentre)

  -- Notify Events
  Script.notifyEvent('UpdatePoint1Display', Scanner.LSP1:toString())
  Script.notifyEvent('UpdatePoint2Display', Scanner.LSP2:toString())
  Script.notifyEvent('UpdateCentrePointDisplay', Scanner.LSCentre:toString())
  Script.notifyEvent('UpdateLengthDisplay', tostring(length))
  Script.notifyEvent('Updatep1DistanceFromOriginDisplay', string.format('%.0f', tostring(p1D)))
  Script.notifyEvent('Updatep2DistanceFromOriginDisplay', string.format('%.0f', tostring(p2D)))
  Script.notifyEvent('UpdateDistanceFromOriginDisplay', string.format('%.0f', tostring(centreD)))
end
Script.serveFunction("picoScan.OnFitLineSubmit", Scanner.OnFitLineSubmit)

Scanner.LinesToFit = 0
function Scanner.OnFitManyLinesSubmit()
  Scanner.LinesToFit = 500
  Scanner.ObjectLengthList = {}
end
Script.serveFunction("picoScan.OnFitManyLinesSubmit", Scanner.OnFitManyLinesSubmit)

function Scanner.GetOnlySegmentLength()
  local points = Point.create(Scanner.X, Scanner.Y)
  Scanner.LineSegment, _ = Scanner.Fitter:fitLine(points)
  Scanner.LSP1, Scanner.LSP2, _ = AnalyseLineSegment(Scanner.LineSegment)
  Scanner.ObjectLength = math.abs(Scanner.LSP1:getX() - Scanner.LSP2:getX())
  -- Scanner.ObjectLength = math.abs(Scanner.LSP1:getY() - Scanner.LSP2:getY())
  table.insert(Scanner.ObjectLengthList, Scanner.ObjectLength)

  if Scanner.LinesToFit == 0 then
    local sum = 0
    local count = #Scanner.ObjectLengthList
    for i = 1, count do
        sum = sum + Scanner.ObjectLengthList[i]
    end
    local result = sum / count
    Script.notifyEvent("UpdateLineAvgDisplay", tostring(result))
  end
end

