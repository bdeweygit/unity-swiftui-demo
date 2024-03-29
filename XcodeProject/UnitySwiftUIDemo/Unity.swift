//
//  Unity.swift
//  UnitySwiftUIDemo
//
//  Created by Benjamin Dewey on 12/24/23.
//

import UnityFramework

class Unity: SetsNativeState {
    /* UnityFramework's principal class is implemented as a singleton
       so we will do the same. Singleton init is lazy and thread safe. */
    static let shared = Unity()
    private let framework: UnityFramework

    private init() {
        // Load framework and get the singleton instance
        let bundle = Bundle(path: "\(Bundle.main.bundlePath)/Frameworks/UnityFramework.framework")!
        bundle.load()
        self.framework = bundle.principalClass!.getInstance()!

        // Set header for framework's CrashReporter; is this needed?
        let machineHeader = UnsafeMutablePointer<MachHeader>.allocate(capacity: 1)
        machineHeader.pointee = _mh_execute_header
        self.framework.setExecuteHeader(machineHeader)

        // Set bundle containing framework's data folder
        self.framework.setDataBundleId("com.unity3d.framework")

        /* Register as the native state setter. Note we have disabled the
           Thread Performance Checker in the UnitySwiftUIDemo scheme or else the mere
           presence of this line will instigate a crash before our code executes when
           running from Xcode. The Unity-iPhone scheme also has the Thread Performance
           Checker disabled by default, perhaps for the same reason. See forum discussion:
           forum.unity.com/threads/unity-2021-3-6f1-xcode-14-ios-16-problem-unityframework-crash-before-main.1338284/ */
        RegisterNativeStateSetter(self)

        // Start the player
        self.framework.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)

        // Unity claims the key window so let user interactions passthrough to our window
        self.framework.appController().window.isUserInteractionEnabled = false
    }

    var view: UIView { self.framework.appController().rootView }

    /* When a Unity script calls the NativeState plugin's OnSetNativeState function this
       closure will be set to a C function pointer that was marshaled from a corresponding
       C# delegate. See section on using delegates: docs.unity3d.com/Manual/PluginsForIOS.html */
    var setNativeState: SetNativeStateCallback? {
        didSet {
            if let setNativeState = self.setNativeState {
                /* We can now send state to Unity. We should assume
                   Unity needs it immediately, so send the current state now. */
                // TODO: ContentView state bindings?
                "#ffffff".withCString({ spotlight in
                    let nativeState = NativeState(scale: 1, visible: true, spotlight: spotlight, textureWidth: 0, textureHeight: 0, texture: nil)
                    setNativeState(nativeState)
                })
            }
        }
    }
}
