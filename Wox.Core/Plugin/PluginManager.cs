﻿using System.Diagnostics;
using Wox.Core.Plugin.Store;
using Wox.Core.Utils;
using Wox.Plugin;

namespace Wox.Core.Plugin;

/// <summary>
///     The entry for managing Wox plugins
/// </summary>
public static class PluginManager
{
    private static readonly List<PluginInstance> PluginInstances = new();

    static PluginManager()
    {
        PluginLoader.PluginLoaded += pluginInstance => { Task.Run(async () => { await OnPluginLoaded(pluginInstance); }); };
    }

    public static List<PluginInstance> GetAllPlugins()
    {
        return PluginInstances;
    }

    private static async Task OnPluginLoaded(PluginInstance pluginInstance)
    {
        try
        {
            //we need to add instance first, so plugin can invoke api method in init method
            //otherwise it will throw "Failed to find plugin instance for request" exception
            PluginInstances.Add(pluginInstance);

            Logger.Debug($"[{pluginInstance.Metadata.Name}] Start to init plugin ");
            pluginInstance.InitStartTimestamp = Stopwatch.GetTimestamp();
            await pluginInstance.Plugin.Init(new PluginInitContext(pluginInstance.API));
            pluginInstance.InitFinishedTimestamp = Stopwatch.GetTimestamp();

            Logger.Info($"[{pluginInstance.Metadata.Name}] Plugin load cost {pluginInstance.LoadTime} ms,  init cost {pluginInstance.InitTime} ms");
        }
        catch (Exception e)
        {
            e.Data.Add(nameof(pluginInstance.Metadata.Id), pluginInstance.Metadata.Id);
            e.Data.Add(nameof(pluginInstance.Metadata.Name), pluginInstance.Metadata.Name);
            e.Data.Add(nameof(pluginInstance.Metadata.Website), pluginInstance.Metadata.Website);
            Logger.Error($"{pluginInstance.Metadata.Name} Fail to init plugin", e);
            UnloadPlugin(pluginInstance, "failed to init");
            //TODO: need someway to nicely tell user this plugin failed to load
        }
    }

    public static async Task Load()
    {
        await PluginLoader.Load();
        await PluginStoreManager.Load();
    }

    public static void UnloadPlugin(PluginInstance plugin, string reason)
    {
        try
        {
            plugin.Host.UnloadPlugin(plugin.Metadata);
            PluginInstances.Remove(plugin);
            Logger.Info($"{plugin.Metadata.Name} plugin was unloaded because {reason}");
        }
        catch (Exception e)
        {
            Logger.Error($"Couldn't unload plugin {plugin.Metadata.Name}", e);
        }
    }

    public static async Task<List<PluginQueryResult>> QueryForPlugin(PluginInstance plugin, Query query)
    {
        Logger.Debug($"[{plugin.Metadata.Name}] start query: {query}");
        if (plugin.CommonSetting.Disabled) return new List<PluginQueryResult>();

        var validGlobalQuery = plugin.TriggerKeywords.Contains("*") && string.IsNullOrEmpty(query.TriggerKeyword);
        var validNonGlobalQuery = plugin.Metadata.TriggerKeywords.Contains(query.TriggerKeyword ?? string.Empty);
        if (!validGlobalQuery && !validNonGlobalQuery) return new List<PluginQueryResult>();

        try
        {
            var results = await plugin.Plugin.Query(query);
            return results.Select(r => new PluginQueryResult
            {
                Result = r,
                AssociatedQuery = query,
                Plugin = plugin
            }).ToList();
        }
        catch (Exception e)
        {
            Logger.Error($"plugin {plugin.Metadata.Name} query ({query}) failed:", e);
            return new List<PluginQueryResult>();
        }
    }
}