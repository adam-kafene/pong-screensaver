import ScreenSaver
import Cocoa

class PongScreensaverView: ScreenSaverView {
    
    enum PuckType: Int {
        case classicBall = 0
        case ufo = 1
        case corgi = 2
    }
    
    // Shared container for multi-screen sync and user configuration
    private let sharedDefaults = ScreenSaverDefaults(forModuleWithName: "com.example.PongScreensaver")
    
    private var currentPuck: PuckType = .corgi
    private var ufoImage: NSImage?
    private var corgiImage: NSImage?
    
    // Lazy UI configuration sheet container
    private var settingsController: PongSettingsController?
    
    // Scaled positioning variables
    private var puckPosition = CGPoint.zero
    private var puckVelocity = CGPoint.zero
    private var puckSize: CGFloat = 0.0
    private var paddleWidth: CGFloat = 0.0
    private let paddlePadding: CGFloat = 40.0
    private var paddleHeight: CGFloat = 0.0
    
    private var leftPaddleY: CGFloat = 0.0
    private var rightPaddleY: CGFloat = 0.0
    private var paddleSpeed: CGFloat = 0.0
    
    private func setupGame() {
        self.animationTimeInterval = 1.0 / 60.0
        
        // Dynamically scale parameters to look perfect on any screen size
        puckSize = max(30.0, bounds.height * 0.05)
        paddleWidth = max(15.0, bounds.width * 0.01)
        paddleHeight = max(80.0, bounds.height * 0.15)
        paddleSpeed = bounds.height * 0.012
        
        puckVelocity = CGPoint(x: bounds.width * 0.008, y: bounds.height * 0.008)
        puckPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        leftPaddleY = bounds.midY
        rightPaddleY = bounds.midY
        
        // Pre-cache icons securely to keep memory passes instant
        ufoImage = NSImage(named: "ufo_icon")
        corgiImage = NSImage(named: "corgi_icon")
        
        loadSavedConfiguration()
    }
    
    func loadSavedConfiguration() {
        if let savedSkin = sharedDefaults?.integer(forKey: "SelectedPuckSkin"),
           let type = PuckType(rawValue: savedSkin) {
            self.currentPuck = type
        }
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupGame()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGame()
    }
    
    override var hasConfigureSheet: Bool { return true }
    
    override var configureSheet: NSWindow? {
        if settingsController == nil {
            settingsController = PongSettingsController(parentSaver: self)
        }
        _ = settingsController?.window
        return settingsController?.window
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        loadSavedConfiguration() // Live update skins if changed in settings panel
        
        if isMasterScreen() {
            puckPosition.x += puckVelocity.x
            puckPosition.y += puckVelocity.y
            
            // Boundary collisions
            if puckPosition.y <= 0 || puckPosition.y >= bounds.height - puckSize {
                puckVelocity.y *= -1
            }
            
            // Paddle Tracking Math
            let targetLeftY = puckPosition.y + (puckSize / 2)
            leftPaddleY += (targetLeftY > leftPaddleY) ? min(paddleSpeed, targetLeftY - leftPaddleY) : -min(paddleSpeed, leftPaddleY - targetLeftY)
            
            let targetRightY = puckPosition.y + (puckSize / 2)
            rightPaddleY += (targetRightY > rightPaddleY) ? min(paddleSpeed, targetRightY - rightPaddleY) : -min(paddleSpeed, rightPaddleY - targetRightY)
            
            leftPaddleY = max(paddleHeight/2, min(bounds.height - paddleHeight/2, leftPaddleY))
            rightPaddleY = max(paddleHeight/2, min(bounds.height - paddleHeight/2, rightPaddleY))
            
            // Physics Hitboxes
            let leftPaddleRect = CGRect(x: paddlePadding, y: leftPaddleY - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
            let rightPaddleRect = CGRect(x: bounds.width - paddlePadding - paddleWidth, y: rightPaddleY - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
            let puckRect = CGRect(origin: puckPosition, size: CGSize(width: puckSize, height: puckSize))
            
            if (puckRect.intersects(leftPaddleRect) && puckVelocity.x < 0) || 
               (puckRect.intersects(rightPaddleRect) && puckVelocity.x > 0) {
                puckVelocity.x *= -1
            }
            
            if puckPosition.x < 0 || puckPosition.x > bounds.width {
                puckPosition = CGPoint(x: bounds.midX, y: bounds.midY)
                puckVelocity.x *= -1 
            }
            
            // Sync positions relative to screen dimensions across instances
            sharedDefaults?.set(puckPosition.x / bounds.width, forKey: "NormalizedPuckX")
            sharedDefaults?.set(puckPosition.y / bounds.height, forKey: "NormalizedPuckY")
            sharedDefaults?.synchronize()
        } else {
            let normX = sharedDefaults?.double(forKey: "NormalizedPuckX") ?? 0.5
            let normY = sharedDefaults?.double(forKey: "NormalizedPuckY") ?? 0.5
            puckPosition = CGPoint(x: CGFloat(normX) * bounds.width, y: CGFloat(normY) * bounds.height)
        }
        
        setNeedsDisplay(bounds)
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        NSColor.black.set()
        rect.fill() // Erases everything cleanly to prevent trails
        
        drawClassicPaddle(xPosition: paddlePadding, yCenter: leftPaddleY)
        drawClassicPaddle(xPosition: bounds.width - paddlePadding - paddleWidth, yCenter: rightPaddleY)
        
        drawCustomPuck()
    }
    
    private func drawCustomPuck() {
        let puckRect = CGRect(origin: puckPosition, size: CGSize(width: puckSize, height: puckSize))
        
        switch currentPuck {
        case .classicBall:
            NSColor.white.set()
            NSBezierPath(ovalIn: puckRect).fill()
        case .ufo:
            if let ufo = ufoImage { ufo.draw(in: puckRect) }
            else { drawFallbackShape(color: .systemGreen, in: puckRect) }
        case .corgi:
            if let corgi = corgiImage { corgi.draw(in: puckRect) }
            else { drawFallbackShape(color: .systemOrange, in: puckRect) }
        }
    }
    
    private func drawClassicPaddle(xPosition: CGFloat, yCenter: CGFloat) {
        NSColor.white.set()
        let paddleRect = CGRect(x: xPosition, y: yCenter - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
        NSBezierPath(rect: paddleRect).fill()
    }
    
    private func drawFallbackShape(color: NSColor, in rect: CGRect) {
        color.set()
        NSBezierPath(rect: rect).fill()
    }
    
    private func isMasterScreen() -> Bool {
        return self.frame.origin == CGPoint.zero
    }
}
