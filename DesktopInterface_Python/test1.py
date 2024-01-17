with open("/Users/furquaansyed/Desktop/Senior Design/DesktopInterface/BatteryLevelll.txt", "r") as file:
    battery_level = file.read().strip()
    print(battery_level)