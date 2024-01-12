state("HavenPark") { }

startup
{
    vars.Unity = Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Unity.LoadSceneManager = true;

    settings.Add("start", true, "Automatically Start Timer on New Game");
    settings.Add("cutscene", true, "Automatically Split on Cutscenes");
    settings.Add("campsite", false, "Automatically Split on Campsite Discovered");
    settings.Add("demo", true, "Automatically Split on Demo Completion");
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.CampStateDiscoveredOffset = mono["CampState"]["discovered"];

        vars.Helper["stage"] = mono.Make<int>("Game", "instance", "state", "stage");
        vars.Helper["lastSaveTime"] = mono.MakeString("Game", "instance", "state", "lastSaveTime");
        vars.Helper["playtime"] = mono.Make<float>("Game", "instance", "state", "playtime");

        vars.Helper["campsPtrs"] = mono.MakeList<IntPtr>("Game", "instance", "state", "camps");

        vars.Helper["currentCinematic"] = mono.Make<long>("Game", "instance", "currentCinematic");

        vars.Helper["demoOpen"] = mono.Make<bool>("Game", "instance", "refs", "demo", "windowEndDemo", "open");

        return true;
    });
    current.lastSaveTime = "2022-01-27T10:08:57.8341707Z";
    current.camps = 0;
    current.demoOpen = false;
}

update
{
    List<IntPtr> campsPtrs = current.campsPtrs;
    current.camps = campsPtrs.Count(ptr => vars.Helper.Read<bool>(ptr + vars.CampStateDiscoveredOffset));
}

start
{
    return settings["start"] && current.lastSaveTime != old.lastSaveTime && current.stage == 0 && current.playtime < 0.5;
}

split
{
    return (settings["cutscene"] && current.stage > 0 && old.currentCinematic == 0 && current.currentCinematic != 0) ||
           (settings["campsite"] && current.camps > old.camps) ||
           (settings["demo"] && !old.demoOpen && current.demoOpen);
}

isLoading
{
    return vars.Unity.IsLoading;
}
