-- Diagnostics 
Diagnostics = {}
Diagnostics.View = View.create('ViewerDiagnostics')
Diagnostics.AppMonitor = Monitor.App.create("picoScan")
Diagnostics.CPUMonitor = Monitor.CPU.create()
Diagnostics.MemoryMonitor = Monitor.Memory.create()
Diagnostics.NetworkMonitor = Monitor.Network.create('ETH1')
-- Diagnostics.TempMonitor = Monitor.Temperature.create('CPU')
Diagnostics.DiagnosticsDisplayInterval = -1
Diagnostics.DetailedCPUtable = { {"CoreNum", "CoreUsage"} }
Diagnostics.DetailedCPULoad = {}

function Diagnostics.InitOrUpdateCPULoadTable(detailedCPULoad)
  if Diagnostics.DiagnosticsDisplayInterval == -1 then 
    for core, usage in pairs(detailedCPULoad) do -- Init
      table.insert(Diagnostics.DetailedCPUtable, { tostring(core), string.format("%.2f", usage or 0) })
    end
    Diagnostics.DiagnosticsDisplayInterval = Diagnostics.DiagnosticsDisplayInterval + 1
  else
    for core, usage in pairs(detailedCPULoad) do -- Update
      Diagnostics.DetailedCPUtable[core + 1][2] = string.format("%.2f", usage or 0)
    end
  end
end

function Diagnostics.UpdateDiagnosticsDisplay()
  local appMemoryBytes = Diagnostics.AppMonitor:getMemoryUsage()
  local appDataBytes, appDataCapacity, appDataUsage = Diagnostics.AppMonitor:getPrivateDataUsage()
  local appState, appAdditionalInfo = Diagnostics.AppMonitor:getStatusInfo()
  local overallCPULoad, detailedCPULoad = Diagnostics.CPUMonitor:getLoad()
  Diagnostics.InitOrUpdateCPULoadTable(detailedCPULoad)
  local table = UiUtils.generateDynamicTableJsonString(Diagnostics.DetailedCPUtable)
  local memoryBytes, memoryCapacity, memoryUsage = Diagnostics.MemoryMonitor:getUsage()
  -- local sentBytesPerSec, receivedBytesPerSec = Diagnostics.NetworkMonitor:getLoad() -- Seems to be significantly slower than every other call (~25ms on SIM2500)
  -- local temperatureCPU = Diagnostics.TempMonitor:get()

  Script.notifyEvent('UpdateAppMemoryUsedBytesDisplay', string.format("%.2f", appMemoryBytes / 1000000 or 0))
  Script.notifyEvent('UpdateAppDataUsedBytesDisplay', string.format("%.2f", appDataBytes / 1000000 or 0))
  Script.notifyEvent('UpdateAppDataCapacityDisplay', string.format("%.2f", appDataCapacity / 1000000 or 0))
  Script.notifyEvent('UpdateAppDataUsageDisplay', string.format("%.2f", appDataUsage or 0))
  Script.notifyEvent('UpdateAppStateDisplay', appState or "N/A")
  Script.notifyEvent('UpdateAppAdditionalInfoDisplay', appAdditionalInfo or "N/A")
  Script.notifyEvent('UpdateOverallCPULoadDisplay', string.format("%.2f", overallCPULoad or 0))
  Script.notifyEvent('UpdateDetailedCPULoadDisplay', table)
  Script.notifyEvent('UpdateMemoryUsedBytesDisplay', string.format("%.2f", memoryBytes / 1000000 or 0))
  Script.notifyEvent('UpdateMemoryCapacityDisplay', string.format("%.2f", memoryCapacity / 1000000 or 0))
  Script.notifyEvent('UpdateMemoryUsageDisplay', string.format("%.2f", memoryUsage or 0))
  -- Script.notifyEvent('UpdateSentBytesPerSecDisplay', string.format("%.2f", sentBytesPerSec / 1000000))
  -- Script.notifyEvent('UpdateReceivedBytesPerSecDisplay', string.format("%.2f", receivedBytesPerSec / 1000000))
  Script.notifyEvent('UpdateTemperatureDisplay', string.format("%.0f", temperatureCPU or 0))
end
Diagnostics.View:register("OnConnect", Diagnostics.UpdateDiagnosticsDisplay)

Script.serveEvent('picoScan.UpdateAppMemoryUsedBytesDisplay', 'UpdateAppMemoryUsedBytesDisplay')
Script.serveEvent('picoScan.UpdateAppDataUsedBytesDisplay', 'UpdateAppDataUsedBytesDisplay')
Script.serveEvent('picoScan.UpdateAppDataCapacityDisplay', 'UpdateAppDataCapacityDisplay')
Script.serveEvent('picoScan.UpdateAppDataUsageDisplay', 'UpdateAppDataUsageDisplay')
Script.serveEvent('picoScan.UpdateAppStateDisplay', 'UpdateAppStateDisplay')
Script.serveEvent('picoScan.UpdateAppAdditionalInfoDisplay', 'UpdateAppAdditionalInfoDisplay')
Script.serveEvent('picoScan.UpdateOverallCPULoadDisplay', 'UpdateOverallCPULoadDisplay')
Script.serveEvent('picoScan.UpdateDetailedCPULoadDisplay', 'UpdateDetailedCPULoadDisplay')
Script.serveEvent('picoScan.UpdateMemoryUsedBytesDisplay', 'UpdateMemoryUsedBytesDisplay')
Script.serveEvent('picoScan.UpdateMemoryCapacityDisplay', 'UpdateMemoryCapacityDisplay')
Script.serveEvent('picoScan.UpdateMemoryUsageDisplay', 'UpdateMemoryUsageDisplay')
Script.serveEvent('picoScan.UpdateSentBytesPerSecDisplay', 'UpdateSentBytesPerSecDisplay')
Script.serveEvent('picoScan.UpdateReceivedBytesPerSecDisplay', 'UpdateReceivedBytesPerSecDisplay')
Script.serveEvent('picoScan.UpdateTemperatureDisplay', 'UpdateTemperatureDisplay')
Diagnostics.UpdateDiagnosticsDisplay()