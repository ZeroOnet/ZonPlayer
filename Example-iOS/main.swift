import UIKit

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(Dummy.self)
)

class Dummy: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        class Root: UIViewController {
            override func viewDidLoad() {
                super.viewDidLoad()
                view.backgroundColor = .white

                let label = UILabel(frame: view.bounds)
                label.textAlignment = .center
                label.text = "I'm a template."
                view.addSubview(label)
            }
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = Root()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
