using System.Diagnostics;
using System.Management;

namespace AutoManagerProcess;

public class Worker() : BackgroundService
{
    private readonly ILogger<Worker> _logger;

    private readonly IConfiguration _config;

    private ManagementEventWatcher? _watcher;

    public Worker(ILogger<Worker> logger) : this()
    {
        _logger = logger;

        string directoryPath = AppDomain.CurrentDomain.BaseDirectory;

        var builder = new ConfigurationBuilder()
            .SetBasePath(directoryPath)
            .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
            .Build();
        _config = builder;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                stoppingToken.ThrowIfCancellationRequested();

                if (_logger.IsEnabled(LogLevel.Information))
                {
                    _logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
                }

                if (_watcher == null)
                {
                    string processName = _config["ProcessName"] ?? "DNF.exe";
                    string queryStr =
                        $"SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA 'Win32_Process' AND TargetInstance.Name = '{processName}'";

                    var query = new WqlEventQuery(queryStr);
                    var scope = new ManagementScope("\\\\.\\root\\cimv2");
                    _watcher = new ManagementEventWatcher(scope, query);
                    _watcher.EventArrived += async (sender, e) =>
                    {
                        AutoStart();

                        int delay = _config.GetSection("Delay").Get<Int32>();
                        if (delay <= 0)
                            delay = 60;

                        //延时执行
                        await Task.Delay(TimeSpan.FromSeconds(delay), stoppingToken);

                        KillProcess();

                    };

                    _watcher.Start();
                }

                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
            }

        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            stoppingToken = new CancellationToken();
        }
        catch (Exception e)
        {
            _logger.LogError(e, "{Message}", e.Message);
            Environment.Exit(1);
        }
        finally
        {
            _watcher?.Stop();
            _watcher?.Dispose();
        }
    }

    private void AutoStart()
    {
        var processList = _config.GetSection("AutoStart").Get<List<string>>();

        if (processList == null)
        {
            _logger.LogWarning("No process to start");
            return;
        }

        foreach (var processName in processList)
        {
            if (!File.Exists(processName))
            {
                _logger.LogWarning("cannot find this file {process}",processName);
                continue;
            }
            var tmp = Path.GetFileNameWithoutExtension(processName);
            //判断是否存在
            _logger.LogInformation("current process {tmp}", tmp);
            var isExist = Process.GetProcessesByName(tmp).Length > 0;
            if (isExist)
            {
                _logger.LogInformation("process is ready exist");
                continue;
            }
                
            //启动该程序
            try
            {
                using (Process process = new Process())
                {
                    process.StartInfo.FileName = processName;
                    process.StartInfo.UseShellExecute = true;
                    process.StartInfo.CreateNoWindow = false;
                    process.Start();
                }

                _logger.LogInformation("Process {ProcessName} has been ran", processName);
            }
            catch (Exception e)
            {
                _logger.LogError(e, "Failed to start {ProcessName}", processName);
            }
        }
    }

    private void KillProcess()
    {
        var processList = _config.GetSection("ProcessList").Get<List<string>>() ??
                          ["GameLoader.exe", "TXPlatform.exe", "ace-loader.exe"];
        foreach (var processName in processList)
        {
            var ps = Process.GetProcessesByName(Path.GetFileNameWithoutExtension(processName));
            // ace-loader有两个
            foreach (var process in ps)
            {
                process.Kill();
                _logger.LogInformation("Process {ProcessName} has been killed", process.ProcessName);
            }
        }
    }
}
