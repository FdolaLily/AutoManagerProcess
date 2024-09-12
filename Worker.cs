using System.Diagnostics;
using System.Management;

namespace AutoManagerProcess;

public class Worker() : BackgroundService
{
    //WIN11����Ч��ģʽ

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
                    var token = stoppingToken;
                    _watcher.EventArrived += async (sender, e) =>
                    {
                        AutoStart();

                        int delay = _config.GetSection("Delay").Get<Int32>();
                        if (delay <= 0)
                            delay = 60;

                        //��ʱִ��
                        await Task.Delay(TimeSpan.FromSeconds(delay), token);

                        KillProcess();

                        LimitSGuard();

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

    private void LimitSGuard()
    {
        var limitList = _config.GetSection("LimitList").Get<List<string>>()
            ?? ["SGuard64.exe", "SGuardSvc64.exe"];
        foreach (var processName in limitList)
        {
            var ps = Process.GetProcessesByName(Path.GetFileNameWithoutExtension(processName));

            foreach (var process in ps)
            {
                //���ý������ȼ�Ϊ��� �п�������������²��ȶ�
                //process.PriorityClass = ProcessPriorityClass.Idle;

                //�����׺���Ϊ���һ��CPU
                SetLastCpuAffinity(process);

                //����I/0���ȼ�Ϊ���
                if (IsGreaterWindows8()) PInvoke.SetIoPriority(process.Id, _logger);


                //bool efficiencyMode = _config.GetSection("EfficiencyMode").Get<bool>();
                //����ΪЧ��ģʽ �п��ܵ��²��ȶ�
                //if (IsGreaterWindows11() && efficiencyMode) PInvoke.SetEfficiencyMode(process.Id, _logger);

            }
        }
    }

    private void SetLastCpuAffinity(Process process)
    {
        //��ȡ��ǰ���̵�CPU�׺�������
        var affinityMask = process.ProcessorAffinity;
        //��ȡ�������е�CPU�б�
        var cpuCount = Environment.ProcessorCount;
        var allowedCpus = Enumerable.Range(0, cpuCount)
            .Where(cpu => (affinityMask.ToInt64() & (1L << cpu)) != 0)
            .ToList();

        if (allowedCpus.Count <= 0) return;

        var newAffinityMask = (IntPtr)(1L << allowedCpus.Last());
        process.ProcessorAffinity = newAffinityMask;
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
                _logger.LogWarning("cannot find this file {process}", processName);
                continue;
            }
            var tmp = Path.GetFileNameWithoutExtension(processName);
            //�ж��Ƿ����
            _logger.LogInformation("current process {tmp}", tmp);
            var isExist = Process.GetProcessesByName(tmp).Length > 0;
            if (isExist)
            {
                _logger.LogInformation("process is ready exist");
                continue;
            }

            //�����ó���
            try
            {
                PInvoke.StartInteractiveProcess(processName, _logger);

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
        var processList = _config.GetSection("KillList").Get<List<string>>() ??
                          ["GameLoader.exe", "TXPlatform.exe", "ace-loader.exe"];
        try
        {
            foreach (var processName in processList)
            {
                var ps = Process.GetProcessesByName(Path.GetFileNameWithoutExtension(processName));
                // ͬ�����̿����ж��
                foreach (var process in ps)
                {
                    _logger.LogInformation($"Current ProcessName {processName}");
                    process.Kill();
                    _logger.LogInformation($"Process {process.ProcessName} has been killed");
                }
            }
        }
        catch (Exception e)
        {
            _logger.LogError($"KillProcess Error :{e.Message}");
        }
        
    }

    private bool IsGreaterWindows11()
    {
        return IsWindowsVersionOrGreater(10, 0, 22000);
    }

    private bool IsGreaterWindows8()
    {
        return IsWindowsVersionOrGreater(6, 2, 0);
    }


    private bool IsWindowsVersionOrGreater(int major, int minor, int build)
    {
        var osVersion = Environment.OSVersion.Version;
        return (osVersion.Major > major) ||
               (osVersion.Major == major && osVersion.Minor > minor) ||
               (osVersion.Major == major && osVersion.Minor == minor && osVersion.Build >= build);
    }
}

