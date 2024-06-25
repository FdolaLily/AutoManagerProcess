using AutoManagerProcess;
using Serilog;


var builder = Host.CreateApplicationBuilder(args);

if (!builder.Environment.IsDevelopment())
{
    builder.Services.AddSerilog(c =>
    {
        c.WriteTo
            .File(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "log.txt")
                , fileSizeLimitBytes: 10480
                , rollOnFileSizeLimit: true)
            .ReadFrom.Configuration(builder.Configuration);
    });
}


builder.Services.AddWindowsService(o =>
{
    o.ServiceName = "Auto Manager Process";
});
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
