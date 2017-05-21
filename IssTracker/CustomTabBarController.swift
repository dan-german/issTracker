import UIKit

class CustomTabBarController: UITabBarController {
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        let settingsController = SettingsController.init(style: .grouped)
        let scheduleController = ScheduleController.init(style: .grouped)
        
        viewControllers = [createNavControllerButton(title: "Map", imageName: "map_icon", vc: MapController()), createNavControllerButton(title: "Schedule", imageName: "schedule_icon", vc: scheduleController), createNavControllerButton(title: "Settings", imageName: "settings_icon", vc: settingsController)]
    }
    
    private func createNavControllerButton(title: String, imageName: String, vc: UIViewController) -> UINavigationController {
        
        let viewController = vc
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        navController.tabBarItem.selectedImage = UIImage(named: imageName + "_filled")
        
        return navController
    }
}
