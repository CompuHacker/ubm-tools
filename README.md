# UBM-Tools
Batch files for executing specific tests from the UserBenchmark suite, with offline results analysis, and JSON export.

# ☑ System Requirements:
We aim to work from Microsoft® Windows™ 7 to 10. Windows 7 and Windows 10 22H2 were tested.

# ⏩ Getting Started
**Download and install UserBenchmark** (tested on 3.05 as of April 24, 2025).

Place `run_ubm_jsondebug_admin.bat`, `ubm_menu.bat`, and `ubm_monitor.bat` in `"C:\Users\[your username]\Desktop\ubm-tools"`, or even **`"C:\Users\[your username]\Desktop\"`**, or even in `"%APPDATA%\UserBenchmark\App\RunEngine\"`.

Instead of running UserBenchmark, **run `ubm_menu.bat`**. If you see a series of toggle switches, e.g. `[OFF  ]` and `[   ON]`, UserBenchmark is installed in the expected location. If you see `[ERROR]`, something has gone wrong and your favorite LLM can fix the issue.

# Instructions
`ubm_menu.bat` allows you to disable and re-enable specific tests by renaming the underlying executables, then launching an offline test. You can, in this way, disable specific benchmarks and still receive online results, by running UserBenchmark from the Start Menu after disabling some benchmarks in the menu.

`run_ubm_jsondebug_admin.bat` will run an offline test and save the results to a JSON File. It is intended that you start it from the menu, but you can also run it by itself. This script makes assumptions about roughly how long certain benchmarks will take, in real-world, wall-clock seconds, before it starts writing JSON to the disk. If your tests take longer and we try to write before the JSON is made available at the end of the tests, adjust the values in the file; pop it open in Notepad and Ctrl-F `:: --- Estimate expected benchmark duration ---`, then bump up the values for specific tests, or the initial value. It's useful to refine these values if you're doing fast, iterative overclocking cycles.

`ubm_monitor.bat` will display the 16 latest results saved on the Desktop. You can also start it from `ubm_menu.bat`. You can launch it separately with the arguments, `/d0`, `/d1`, ..., `/d5` to get Disk benchmark results for a specific disk, as the results for only one are shown.

# 📊 Analysis
`ubm_chart.bat` is a derivative of `ubm_monitor.bat` and attempts to graphically chart the results. It is broken, and it's up to you and/or your favorite LLM to fix it.

# 📂 Output Location
`run_ubm_jsondebug_admin.bat` will attempt to save benchmark results to your Desktop; which it defines as `"%APPDATA%\..\..\Desktop\"`. If your Desktop isn't there, your favorite LLM can fix the issue.

`<timestamp>-<hostname>.json`

e.g.

`1714082394-GAMINGRIG.json`

A number of temporary files are created in `%TEMP%`.

# ⚠️ Disclaimer
This project is not affiliated with UserBenchmark.com or any related personages.

Use at your own risk; UBM executables are closed-source and may change behavior upon reinstall.

# 🧼💬 Why This Exists
UserBenchmark was, or is, very useful for comparative bench-marking and overclocking, but the (relatively) recent addition of the gamified CAPTCHA makes it very difficult to use repeatedly; or even once; and especially not under controlled conditions. `strings UserBenchMarkRunEngine.exe` revealed the existence of `jsondebug` mode, which will execute the UserBenchmark suite, CAPTCHA-free, locally, without involving UserBenchmark's servers. Consequently, online analysis, interpretation, comparison, component identification, and social integration is not available, yet, in UBM-Tools. Feel free to write your own front-end.

# Earlier Versions
Earlier versions will also work as the suite and logic are largely unchanged, but some earlier versions used a dynamic unpacking procedure instead of installing the benchmark suite, so you'll need to extract and arrange the executables yourself. Run and terminate early to grab these; or **extract from `UserBenchmark.exe`** (historic) **with 7-Zip**; **move `\Media` to `\RunEngine`** (or place all files into the same folder); and **re-point the scripts to the `\RunEngine` folder.** In this way, you could observe changes to the suite, if they exist, over time.

# Windows 7
UserBenchmark's new GUI is apparently not compatible with Windows 7. However, you can still run benchmarks in jsondebug mode on Windows 7. This mode bypasses the GUI, running the tests and exporting results to JSON without requiring the graphical interface.

# 📜 License
WTFPL: Just do what the fuck you want to!
