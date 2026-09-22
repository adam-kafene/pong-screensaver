import Cocoa
import ScreenSaver

struct PongDefaults {
    static let moduleName = "com.example.PongScreensaver"
    static let selectedPuckSkin = "SelectedPuckSkin"
}

class PongSettingsController: NSWindowController {
    
    @IBOutlet weak var skinPopUpButton: NSPopUpButton!
    
    private let sharedDefaults = ScreenSaverDefaults(forModuleWithName: PongDefaults.moduleName)
    private weak var parentSaverView: PongScreensaverView?
    
    convenience init(parentSaver: PongScreensaverView) {
        self.init(window: nil)
        self.parentSaverView = parentSaver
        
        let bundle = Bundle(for: PongSettingsController.self)
        var topLevelObjects: NSArray?
        bundle.loadNibNamed(NSNib.Name("PongSettingsView"), owner: self, topLevelObjects: &topLevelObjects)
        
        setupUI()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        guard let skinPopUpButton = skinPopUpButton else { return }
        skinPopUpButton.removeAllItems()
        skinPopUpButton.addItems(withTitles: ["Classic Ball", "UFO Spacecraft", "Corgi Puppy"])
        
        let savedSkin = sharedDefaults?.integer(forKey: PongDefaults.selectedPuckSkin) ?? 0
        if savedSkin >= 0 && savedSkin < skinPopUpButton.numberOfItems {
            skinPopUpButton.selectItem(at: savedSkin)
        }
    }
    
    @IBAction func performSaveSelection(_ sender: NSButton) {
        guard let skinPopUpButton = skinPopUpButton else { return }
        let selectedIndex = skinPopUpButton.indexOfSelectedItem
        sharedDefaults?.set(selectedIndex, forKey: PongDefaults.selectedPuckSkin)
        sharedDefaults?.synchronize()
        
        parentSaverView?.loadSavedConfiguration()
        closeSheet(with: .OK)
    }
    
    @IBAction func performCancelAction(_ sender: NSButton) {
        closeSheet(with: .cancel)
    }
    
    private func closeSheet(with returnCode: NSApplication.ModalResponse) {
        guard let window = self.window else { return }
        if let parent = window.sheetParent {
            parent.endSheet(window, returnCode: returnCode)
        } else {
            window.close()
        }
    }
}
