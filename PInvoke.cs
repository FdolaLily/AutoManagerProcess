using System.Runtime.InteropServices;

namespace AutoManagerProcess
{
    public static class PInvoke
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern uint WTSGetActiveConsoleSessionId();

        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern bool CreateProcessAsUser(
            IntPtr hToken,
            string lpApplicationName,
            string lpCommandLine,
            IntPtr lpProcessAttributes,
            IntPtr lpThreadAttributes,
            bool bInheritHandles,
            uint dwCreationFlags,
            IntPtr lpEnvironment,
            string lpCurrentDirectory,
            [In] ref STARTUPINFO lpStartupInfo,
            out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        public static extern bool WTSQueryUserToken(uint SessionId, out IntPtr phToken);
     

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool DuplicateTokenEx(
            IntPtr hExistingToken,
            uint dwDesiredAccess,
            IntPtr lpTokenAttributes,
            int ImpersonationLevel,
            int TokenType,
            out IntPtr phNewToken);

        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool AdjustTokenPrivileges(
            IntPtr TokenHandle,
            bool DisableAllPrivileges,
            ref TOKEN_PRIVILEGES NewState,
            uint BufferLength,
            IntPtr PreviousState,
            IntPtr ReturnLength);


        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern bool LookupPrivilegeValue(string lpSystemName, string lpName, ref PInvoke.LUID lpLuid);


        [StructLayout(LayoutKind.Sequential)]
        public struct STARTUPINFO
        {
            public uint cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public uint dwX;
            public uint dwY;
            public uint dwXSize;
            public uint dwYSize;
            public uint dwXCountChars;
            public uint dwYCountChars;
            public uint dwFillAttribute;
            public uint dwFlags;
            public ushort wShowWindow;
            public ushort cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public uint dwProcessId;
            public uint dwThreadId;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct LUID
        {
            public uint LowPart;
            public int HighPart;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct LUID_AND_ATTRIBUTES
        {
            public LUID Luid;
            public uint Attributes;
        }

        [StructLayout(LayoutKind.Sequential)]
        public struct TOKEN_PRIVILEGES
        {
            public uint PrivilegeCount;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 1)]
            public LUID_AND_ATTRIBUTES[] Privileges;
        }

        private const uint SE_PRIVILEGE_ENABLED = 0x00000002;
        private const string SE_ASSIGNPRIMARYTOKEN_NAME = "SeAssignPrimaryTokenPrivilege";
        private const string SE_INCREASE_QUOTA_NAME = "SeIncreaseQuotaPrivilege";


        public static void StartInteractiveProcess(string applicationPath, ILogger logger)
        {

            uint sessionId = WTSGetActiveConsoleSessionId();
            if (sessionId == 0xFFFFFFFF)
            {
                logger.LogError("No active session found.");
                return;
            }

            if (!WTSQueryUserToken(sessionId, out IntPtr userToken))
            {
                logger.LogError("Could not get user token.");
                return;
            }

            IntPtr duplicatedToken = IntPtr.Zero;
            if (!DuplicateTokenEx(userToken, 0xF01FF, IntPtr.Zero, 2, 1, out duplicatedToken))
            {
                logger.LogError("Could not duplicate token.");
                return;
            }

            SetPrivilege(duplicatedToken, SE_ASSIGNPRIMARYTOKEN_NAME, true);
            SetPrivilege(duplicatedToken, SE_INCREASE_QUOTA_NAME, true);

            STARTUPINFO startupInfo = new STARTUPINFO();
            PROCESS_INFORMATION processInfo = new PROCESS_INFORMATION();

            bool result = CreateProcessAsUser(
                duplicatedToken,
                null,
                applicationPath,
                IntPtr.Zero,
                IntPtr.Zero,
                false,
                0,
                IntPtr.Zero,
                null,
                ref startupInfo,
                out processInfo);

            if (!result)
            {
                logger.LogError("Could not create process.");
            }
        }

        private static void SetPrivilege(IntPtr token, string privilege, bool enable)
        {
            LUID luid = new LUID();
            if (!LookupPrivilegeValue(null, privilege, ref luid))
            {
                throw new Exception("Could not lookup privilege value.");
            }

            TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES
            {
                PrivilegeCount = 1,
                Privileges = new LUID_AND_ATTRIBUTES[1]
            };
            tp.Privileges[0].Luid = luid;
            tp.Privileges[0].Attributes = enable ? SE_PRIVILEGE_ENABLED : 0;

            if (!AdjustTokenPrivileges(token, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero))
            {
                throw new Exception("Could not adjust token privileges.");
            }
        }


        public static void SetIoPriority(int processId , ILogger logger)
        {
            IntPtr hProcess = OpenProcess(ProcessAccessFlags.SetInformation, false, processId);
            if (hProcess == IntPtr.Zero)
            {
                logger.LogError("cannot open process");
                return;
            }

            try
            {
                bool result = SetPriorityClass(hProcess, (uint)IoPriority.VeryLow);
                if (!result)
                {
                    logger.LogError("无法设置I/O优先级");
                }
                logger.LogInformation("设置I/0优先级成功");
            }
            finally
            {
                CloseHandle(hProcess);
            }
        }

        public static void SetEfficiencyMode(int processId, ILogger logger)
        {
            IntPtr hProcess = OpenProcess(ProcessAccessFlags.SetInformation, false, processId);
            if (hProcess == IntPtr.Zero)
            {
                logger.LogError("cannot open process");
                return;
            }

            PROCESS_POWER_THROTTLING_STATE state = new PROCESS_POWER_THROTTLING_STATE
            {
                Version = PROCESS_POWER_THROTTLING_CURRENT_VERSION,
                ControlMask = PROCESS_POWER_THROTTLING_EXECUTION_SPEED,
                StateMask =  PROCESS_POWER_THROTTLING_EXECUTION_SPEED 
            };

            try
            {
                bool result = SetProcessInformation(hProcess, PROCESS_INFORMATION_CLASS.ProcessPowerThrottling, ref state, (uint)Marshal.SizeOf(state));
                if (!result)
                {
                    Console.WriteLine("无法设置效率模式");
                }
                logger.LogInformation("设置效率模式成功");
            }
            finally
            {
                CloseHandle(hProcess);
            }
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr OpenProcess(ProcessAccessFlags processAccess, bool bInheritHandle, int processId);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool SetPriorityClass(IntPtr hProcess, uint dwPriorityClass);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool SetProcessInformation(IntPtr hProcess, PROCESS_INFORMATION_CLASS processInformationClass, ref PROCESS_POWER_THROTTLING_STATE processInformation, uint processInformationSize);

        [StructLayout(LayoutKind.Sequential)]
        struct PROCESS_POWER_THROTTLING_STATE
        {
            public uint Version;
            public uint ControlMask;
            public uint StateMask;
        }

        enum PROCESS_INFORMATION_CLASS
        {
            ProcessMemoryPriority,
            ProcessPowerThrottling
        }

        const uint PROCESS_POWER_THROTTLING_CURRENT_VERSION = 1;
        const uint PROCESS_POWER_THROTTLING_EXECUTION_SPEED = 0x1;

        enum IoPriority
        {
            VeryLow = 0x00000001 // 低优先级
        }

        [Flags]
        enum ProcessAccessFlags : uint
        {
            SetInformation = 0x0200
        }
    }
}
