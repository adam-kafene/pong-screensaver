\import Cocoa
import ScreenSaver

class PongSettingsController: NSWindowController {
    
    @IBOutlet weak var skinPopUpButton: NSPopUpButton!
    
    private let sharedDefaults = ScreenSaverDefaults(forModuleWithName: "com.example.PongScreensaver")
    private weak var parentSaverView: PongScreensaverView?
    
    convenience init(parentSaver: PongScreensaverView) {
        self.init(windowNibName: NSNib.Name("PongSettingsView"))
        self.parentSaverView = parentSaver
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        skinPopUpButton.removeAllItems()
        skinPopUpButton.addItems(withTitles: ["Classic Ball", "UFO Spacecraft", "Corgi Puppy"])
        
        let savedSkin = sharedDefaults?.integer(forKey: "SelectedPuckSkin") ?? 0
        skinPopUpButton.selectItem(at: savedSkin)
    }
    
    @IBAction func performSaveSelection(_ sender: NSButton) {
        let selectedIndex = skinPopUpButton.indexOfSelectedItem
        sharedDefaults?.set(selectedIndex, forKey: "SelectedPuckSkin")
        sharedDefaults?.synchronize()
        
        parentSaverView?.loadSavedConfiguration()
        
        if let window = self.window {
            window.sheetParent?.endSheet(window, returnCode: .OK)
        }
    }
    
    @IBAction func performCancelAction(_ sender: NSButton) {
        if let window = self.window {
            window.sheetParent?.endSheet(window, returnCode: .cancel)
        }
    }
}
