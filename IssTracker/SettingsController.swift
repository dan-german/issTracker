import UIKit
import ActionSheetPicker_3_0
import Mixpanel

class SettingsController: UITableViewController {
    
    
    //MARK: - UI
    
    var allowNotificationsSwitch = SwitchCell()
    var visibleOnlySwitch = SwitchCell()
    var minutePickerCell = MinutesPickerCell()
    
    //MARK: - Properties
    
    var minutePickerTitle = "5 Minutes"
    var minuteArray = [["1 Minute", "2 Minutes", "5 Minutes", "10 Minutes", "15 Minutes", "30 Minutes"]]
    var minuteArrayIndex = 2
    
    //MARK: - Keys
    
    let notificationsSwitchKey = "notificationsSwitch"
    let visibleSwitchKey = "visibleSwitch"
    let visibleOnlyEventKey = "Notify Visible Only"
    let notificationsEventKey = "Notifications"
    
    let defaults = UserDefaults.standard
    
    //MARK: -
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.title = "Settings"
        tableView.allowsSelection = false
        
        allowNotificationsSwitch.label.text = "Notifications"
        visibleOnlySwitch.label.text = "Notify Only When Visible"
        
        allowNotificationsSwitch.enableSwitch.addTarget(self, action: #selector(HandleAllowNotifications), for: .valueChanged)
        visibleOnlySwitch.enableSwitch.addTarget(self, action: #selector(HandleNotifyVisibleOnly), for: .valueChanged)
        minutePickerCell.Button.addTarget(self, action: #selector(HandleMinutePickerButton), for: .touchUpInside)
        
        allowNotificationsSwitch.enableSwitch.isOn = defaults.bool(forKey: notificationsSwitchKey)
        visibleOnlySwitch.enableSwitch.isOn = defaults.bool(forKey: "visibleSwitch")
        minutePickerCell.label.text = "Notification Time"
        
        minuteArrayIndex = defaults.integer(forKey: "minuteArrayIndex")
        minutePickerCell.Button.setTitle(minuteArray[0][minuteArrayIndex], for: .normal)
        
        HandleNotifyVisibleOnly()
        HandleAllowNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
  
    }
    
    //MARK: - Table View Data Source Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch section {
        case 0: return 3
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.section {
        case 0: switch indexPath.row {
        case 0: return allowNotificationsSwitch
        case 1: return visibleOnlySwitch
        case 2: return minutePickerCell
        default: return allowNotificationsSwitch
            }
        default: return allowNotificationsSwitch
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        switch section {
        case 0: return "NOTIFICATIONS"
        default: return ""
        }
    }
    
    //MARK: -
    
    @objc private func HandleAllowNotifications(){
        
        
        if allowNotificationsSwitch.enableSwitch.isOn {
            
            visibleOnlySwitch.enableSwitch.isEnabled = true
            defaults.set(true, forKey: notificationsSwitchKey)
            visibleOnlySwitch.label.textColor = .black
            
            minutePickerCell.label.textColor = .black
            minutePickerCell.Button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
            NotificationCenter.default.post(name: Notification.Name("AllowNotificationsOn"), object: nil)
            Mixpanel.mainInstance().track(event: notificationsEventKey, properties: ["Enabled":"True"])
            
        } else {
            
            visibleOnlySwitch.enableSwitch.isEnabled = false
            defaults.set(false, forKey: notificationsSwitchKey)
            visibleOnlySwitch.label.textColor = UIColor(white: 0.5, alpha: 0.7)
            minutePickerCell.Button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.4), for: .normal)
            minutePickerCell.label.textColor = UIColor(white: 0.5, alpha: 0.7)
            NotificationCenter.default.post(name: Notification.Name("AllowNotificationsOff"), object: nil)
            Mixpanel.mainInstance().track(event: notificationsEventKey, properties: ["Enabled":"False"])
        }
    }
    
    @objc private func HandleNotifyVisibleOnly(){
        if visibleOnlySwitch.enableSwitch.isOn {
            defaults.set(true, forKey: visibleSwitchKey)
            NotificationCenter.default.post(name: Notification.Name("VisibleOnlyOn"), object: nil)
            Mixpanel.mainInstance().track(event: visibleOnlyEventKey, properties: ["Enabled":"False"])
        } else {
            defaults.set(false, forKey: visibleSwitchKey)
            NotificationCenter.default.post(name: Notification.Name("VisibleOnlyOff"), object: nil)
            Mixpanel.mainInstance().track(event: visibleOnlyEventKey, properties: ["Enabled":"True"])
        }
    }
    
    @objc private func HandleMinutePickerButton(){
        
        
        if allowNotificationsSwitch.enableSwitch.isOn {
            
            ActionSheetMultipleStringPicker.show(withTitle: "", rows:
                [["1 Minute", "2 Minutes", "5 Minutes", "10 Minutes", "15 Minutes", "30 Minutes"]]
                , initialSelection: [minuteArrayIndex], doneBlock: {
                    picker, indexes, values in
                    
                    var indexString = String(describing: indexes!)
                    let string2 = indexString.replacingOccurrences(of: "[", with: "")
                    indexString = string2.replacingOccurrences(of: "]", with: "")
                    let indexInt = Int(indexString)
                    
                    let title = self.minuteArray[0][indexInt!]
                    self.minutePickerCell.Button.setTitle(title, for: .normal)
                    
                    self.defaults.set(indexInt!, forKey: "minuteArrayIndex")
                    
                    Mixpanel.mainInstance().track(event: "Notification Time", properties: ["Minutes" : title])
                    
                    return
                    
            }, cancel: { ActionMultipleStringCancelBlock in return }, origin: self.minutePickerCell)
        } else {
            return 
        }
    }
}

