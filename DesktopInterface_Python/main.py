from kivy.app import App
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.uix.tabbedpanel import TabbedPanel, TabbedPanelItem
from kivy.uix.slider import Slider
from kivy.uix.label import Label
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy.uix.scrollview import ScrollView
from kivy.clock import Clock
from bleak import BleakClient, discover
from kivy.uix.dropdown import DropDown



class MyDropDown(DropDown):
    pass


class MyTabbedPanel(TabbedPanel):
    def __init__(self, **kwargs):
        super(MyTabbedPanel, self).__init__(**kwargs)
        self.do_default_tab = False

        # Create Main Tab - placeholders for glove connection strength and diagram
        mainTab = TabbedPanelItem(text='Main')
        mainLayout = BoxLayout(orientation='vertical', padding=10)
        gloveDiagram = Label(text='Glove Diagram Placeholder')
        connectionLabel = Label(text='Connection Strength: Placeholder')
        mainLayout.add_widget(gloveDiagram)
        mainLayout.add_widget(connectionLabel)
        mainTab.add_widget(mainLayout)


        ## set the selected notification percentage to "not set"
        self.selectedPercentage = "Not Set"
        settingsTab = TabbedPanelItem(text='Settings')
        settingsLayout = BoxLayout(orientation='vertical', padding=10, spacing=10)


        ## Initialize dropdown menud
        self.dropdown = MyDropDown()
        self.dropdownButton = Button(text='Select Battery Notification Threshold', size_hint=(0.5, None), height=44, pos_hint={'top': 0.9})
        self.dropdownButton.bind(on_release=self.dropdown.open)
        ## Bind values to buttons in the dropdown menu

        self.dropdown.bind(on_select=lambda instance, x: setattr(self.dropdownButton, \
                                'text', f'Battery Notification Threshold: {x}'))
        ## Three options for a notification threshold - when do you want to be notified?
        for percentage in ["5", "15", "90"]:
            btn = Button(text=f'{percentage}%', size_hint_y=None, height=44)
            btn.bind(on_release=lambda btn: self.dropdown.select(btn.text))
            self.dropdown.add_widget(btn)


        settingsLayout.add_widget(self.dropdownButton)

        self.dropdown.bind(on_select=self.update_selectedPercentage)

        self.batteryLevelLabel = Label(text='Battery Level: --%') ## Will default to this before battery level is selected
        settingsLayout.add_widget(self.batteryLevelLabel)

        settingsTab.add_widget(settingsLayout)

        self.add_widget(mainTab)
        self.add_widget(settingsTab)

    def update_selectedPercentage(self, instance, x):
        self.selectedPercentage = x
        setattr(self.dropdownButton, 'text', f'Battery Notification Threshold: {x}')



    def write_selectedPercentage_to_file(self, dt): ## Key part of inter-process comms - Swift helper application and this both need to
                                                    ## read to and write from the same files (acting as buffers)
        if self.selectedPercentage != "Not Set":    ## One file for battery level of system, and one that tells system when to
            try:                                    ## notify user
                percentageValue = int(self.selectedPercentage.rstrip('%'))
                print("selected percentage number:", percentageValue)
                self.selectedPercentage_number = percentageValue
                fileName = "selected_battery_threshold.txt"
                with open(fileName, "w") as file:
                    file.write(f"{percentageValue}")
                            ## write to file
            except ValueError:      ## ERROR HANDLING
                print("Error: Could not convert selected percentage to an integer.")
        else:
            print("No percentage selected.")

    def start(self):
        ## Schedule the update_battery_label to be called every 5 seconds
        ## update battery label every 5 seconds
        Clock.schedule_interval(self.update_battery_label, 5)
        Clock.schedule_interval(self.write_selectedPercentage_to_file, 5) ## write to file every 5 sconds



    def update_battery_label(self, battery_level):  ## read the current battery level from device file every five seconds
        try:
            with open("/Users/furquaansyed/Desktop/Senior Design/DesktopInterface/BatteryLevelll.txt", "r") as file:
                battery_level = file.read().strip()

                self.batteryLevelLabel.text = f'Battery Level: {battery_level}%'
        except IOError:
            print("Could not read file: /Users/furquaansyed/Desktop/Senior Design/DesktopInterface/BatteryLevelll.txt")


class MyApp(App):

    def build(self):
        self.panel = MyTabbedPanel()
        return self.panel

    def on_start(self):

        #Clock.schedule_interval(self.root.update_battery_label, 5)

        self.panel.start()



if __name__ == '__main__':
    MyApp().run()





