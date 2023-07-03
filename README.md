# ReNavigation

ReNavigation is a navigation framework providing a comprehensive Router that performs all iOS navigation functions easily.

# Origin

The motivation behind this project was to spin-off a great navigation solution from [ReMVVMExtUIKit](https://github.com/ReMVVM/ReMVVMExtUIKit) framework made by [ReMVVM](https://github.com/ReMVVM) organization ([dgrzeszczak](https://github.com/dgrzeszczak), [gjurzak](https://github.com/gjurzak), [jwolansk](https://github.com/jwolansk)). The original solution was a part of a larger ReMVVM framework and was tightly coupled with its Redux Application State.
This project is a standalone navigation framework that can be used alongside ReMVVM or any other architecture. 

# Usage

On app launch you initialize the ReNavigation with UIWindow and UIStateConfig. Then you can access the Router by using a property wrapper.
Using the router is as simple as calling navigation methods:

```
- showOnRoot(loader: ReNavigation.Loader,
             animated: Bool = true,
             navigationBarHidden: Bool = true)
             
- show<Item: NavigationItem>(on item: Item,
                             loader: ReNavigation.Loader,
                             animated: Bool = true,
                             navigationBarHidden: Bool = true,
                             resetStack: Bool = false)
- push(loader: ReNavigation.Loader,
       pop: PopMode? = nil,
       animated: Bool = true)

- pop(mode: PopMode = .pop(1),
      animated: Bool = true)
      
- showModal(loader: ReNavigation.Loader,
            animated: Bool = true,
            withNavigationController: Bool = true,
            presentationStyle: UIModalPresentationStyle = .fullScreen,
            preferredCornerRadius: CGFloat? = nil)
            
- dismissModal(dismissAllViews: Bool = false,
               animated: Bool = true)
 ```
 
 # Example
```
var uiTabBarConfig: NavigationConfig.TabBarItems<NavigationTab> = { tabBar, items in
    items
        .forEach {
            $0.uiTabBarItem.title = $0.item.title
            $0.uiTabBarItem.image = $0.item.iconImage
            $0.uiTabBarItem.selectedImage = $0.item.iconImageActive
        }
    return TabBarItemsResult()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    @ReNavigation.Router private var router

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let appWindow = window ?? UIWindow(frame: UIScreen.main.bounds)
        let tabConfig = try! NavigationConfig(NavigationTab.uiTabBarConfig,
                                              for: [NavigationTab.todo, .stack, .profile])
        let uiStateConfig = UIStateConfig(initialController: LaunchScreen.instantiateInitialViewController(),
                                          navigationController: EXNavigationController.init,
                                          navigationConfigs: [tabConfig],
                                          navigationBarHidden: false)

        appWindow.makeKeyAndVisible()
        ReNavigation.initialize(for: appWindow, uiConfig: uiStateConfig)
        
        router.showOnRoot(view: ContentView())
        return true
    }
}
```



