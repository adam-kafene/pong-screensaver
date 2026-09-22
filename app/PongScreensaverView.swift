import ScreenSaver
import Cocoa

@objc(PongScreensaverView)
class PongScreensaverView: ScreenSaverView {
    
    enum PuckType: Int {
        case classicBall = 0
        case ufo = 1
        case corgi = 2
    }
    
    private let sharedDefaults = ScreenSaverDefaults(forModuleWithName: PongDefaults.moduleName)
    
    private var currentPuck: PuckType = .corgi
    private var ufoImage: NSImage?
    private var corgiImage: NSImage?
    
    // UI configuration sheet controller
    private var settingsController: PongSettingsController?
    
    // Dynamic dimensions & positions
    private var puckPosition = CGPoint.zero
    private var puckVelocity = CGPoint.zero
    private var puckSize: CGFloat = 30.0
    private var paddleWidth: CGFloat = 15.0
    private let paddlePadding: CGFloat = 40.0
    private var paddleHeight: CGFloat = 90.0
    
    private var leftPaddleY: CGFloat = 0.0
    private var rightPaddleY: CGFloat = 0.0
    private var paddleSpeed: CGFloat = 0.0
    
    override var isOpaque: Bool { return true }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupGame()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGame()
    }
    
    private func setupGame() {
        self.animationTimeInterval = 1.0 / 60.0
        
        let bundle = Bundle(for: PongScreensaverView.self)
        ufoImage = bundle.image(forResource: "ufo_icon")
        corgiImage = bundle.image(forResource: "corgi_icon")
        
        loadSavedConfiguration()
        updateDimensions()
    }
    
    func loadSavedConfiguration() {
        if let savedSkin = sharedDefaults?.integer(forKey: PongDefaults.selectedPuckSkin),
           let type = PuckType(rawValue: savedSkin) {
            self.currentPuck = type
        }
    }
    
    private func updateDimensions() {
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        puckSize = max(24.0, bounds.height * 0.045)
        paddleWidth = max(14.0, bounds.width * 0.012)
        paddleHeight = max(70.0, bounds.height * 0.16)
        paddleSpeed = max(4.0, bounds.height * 0.012)
        
        if leftPaddleY == 0 { leftPaddleY = bounds.midY }
        if rightPaddleY == 0 { rightPaddleY = bounds.midY }
        
        leftPaddleY = max(paddleHeight / 2, min(bounds.height - paddleHeight / 2, leftPaddleY))
        rightPaddleY = max(paddleHeight / 2, min(bounds.height - paddleHeight / 2, rightPaddleY))
        
        if puckPosition == .zero || puckVelocity == .zero {
            resetPuck()
        }
    }
    
    private func resetPuck() {
        puckPosition = CGPoint(x: bounds.midX - (puckSize / 2), y: bounds.midY - (puckSize / 2))
        let speedX = max(4.0, bounds.width * 0.006)
        let speedY = max(3.0, bounds.height * 0.005)
        let dirX: CGFloat = Bool.random() ? 1.0 : -1.0
        let dirY: CGFloat = Bool.random() ? 1.0 : -1.0
        puckVelocity = CGPoint(x: speedX * dirX, y: speedY * dirY)
    }
    
    override func startAnimation() {
        super.startAnimation()
        updateDimensions()
        loadSavedConfiguration()
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        super.setFrameSize(newSize)
        updateDimensions()
    }
    
    override var hasConfigureSheet: Bool { return true }
    
    override var configureSheet: NSWindow? {
        if settingsController == nil {
            settingsController = PongSettingsController(parentSaver: self)
        }
        return settingsController?.window
    }
    
    override func animateOneFrame() {
        super.animateOneFrame()
        
        guard bounds.width > 0 && bounds.height > 0 else { return }
        
        puckPosition.x += puckVelocity.x
        puckPosition.y += puckVelocity.y
        
        // Top and bottom boundary collisions with clamping
        if puckPosition.y <= 0 {
            puckPosition.y = 0
            puckVelocity.y = abs(puckVelocity.y)
        } else if puckPosition.y >= bounds.height - puckSize {
            puckPosition.y = bounds.height - puckSize
            puckVelocity.y = -abs(puckVelocity.y)
        }
        
        // Paddle Tracking
        let targetLeftY = puckPosition.y + (puckSize / 2)
        let leftDelta = targetLeftY - leftPaddleY
        leftPaddleY += max(-paddleSpeed, min(paddleSpeed, leftDelta))
        leftPaddleY = max(paddleHeight / 2, min(bounds.height - paddleHeight / 2, leftPaddleY))
        
        let targetRightY = puckPosition.y + (puckSize / 2)
        let rightDelta = targetRightY - rightPaddleY
        rightPaddleY += max(-paddleSpeed, min(paddleSpeed, rightDelta))
        rightPaddleY = max(paddleHeight / 2, min(bounds.height - paddleHeight / 2, rightPaddleY))
        
        // Paddle Collisions
        let leftPaddleRect = CGRect(x: paddlePadding, y: leftPaddleY - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
        let rightPaddleRect = CGRect(x: bounds.width - paddlePadding - paddleWidth, y: rightPaddleY - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
        let puckRect = CGRect(origin: puckPosition, size: CGSize(width: puckSize, height: puckSize))
        
        if puckRect.intersects(leftPaddleRect) && puckVelocity.x < 0 {
            puckPosition.x = leftPaddleRect.maxX
            puckVelocity.x = abs(puckVelocity.x)
            let hitOffset = (puckPosition.y + (puckSize / 2) - leftPaddleY) / (paddleHeight / 2)
            puckVelocity.y += hitOffset * (bounds.height * 0.003)
        } else if puckRect.intersects(rightPaddleRect) && puckVelocity.x > 0 {
            puckPosition.x = rightPaddleRect.minX - puckSize
            puckVelocity.x = -abs(puckVelocity.x)
            let hitOffset = (puckPosition.y + (puckSize / 2) - rightPaddleY) / (paddleHeight / 2)
            puckVelocity.y += hitOffset * (bounds.height * 0.003)
        }
        
        // Offscreen reset
        if puckPosition.x < -puckSize || puckPosition.x > bounds.width {
            resetPuck()
        }
        
        setNeedsDisplay(bounds)
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        NSColor.black.set()
        bounds.fill()
        
        drawCenterDivider()
        drawClassicPaddle(xPosition: paddlePadding, yCenter: leftPaddleY)
        drawClassicPaddle(xPosition: bounds.width - paddlePadding - paddleWidth, yCenter: rightPaddleY)
        drawCustomPuck()
    }
    
    private func drawCenterDivider() {
        let dividerColor = NSColor(white: 1.0, alpha: 0.15)
        dividerColor.set()
        
        let segmentHeight: CGFloat = 16.0
        let gap: CGFloat = 12.0
        let totalStep = segmentHeight + gap
        let x = (bounds.width - 2.0) / 2.0
        
        var y: CGFloat = gap / 2.0
        while y < bounds.height {
            let segRect = CGRect(x: x, y: y, width: 2.0, height: min(segmentHeight, bounds.height - y))
            NSBezierPath(rect: segRect).fill()
            y += totalStep
        }
    }
    
    private func drawCustomPuck() {
        let puckRect = CGRect(origin: puckPosition, size: CGSize(width: puckSize, height: puckSize))
        
        switch currentPuck {
        case .classicBall:
            NSColor.white.set()
            NSBezierPath(ovalIn: puckRect).fill()
            
        case .ufo:
            if let ufo = ufoImage {
                ufo.draw(in: puckRect)
            } else {
                drawUFOFallback(in: puckRect)
            }
            
        case .corgi:
            if let corgi = corgiImage {
                corgi.draw(in: puckRect)
            } else {
                drawCorgiFallback(in: puckRect)
            }
        }
    }
    
    private func drawUFOFallback(in rect: CGRect) {
        // Saucer dome
        let domeRect = CGRect(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.35, width: rect.width * 0.5, height: rect.height * 0.5)
        NSColor.systemTeal.set()
        NSBezierPath(ovalIn: domeRect).fill()
        
        // Saucer base disk
        let diskRect = CGRect(x: rect.minX, y: rect.minY + rect.height * 0.15, width: rect.width, height: rect.height * 0.45)
        NSColor.systemGreen.set()
        NSBezierPath(ovalIn: diskRect).fill()
    }
    
    private func drawCorgiFallback(in rect: CGRect) {
        // Head
        NSColor(calibratedRed: 0.92, green: 0.58, blue: 0.24, alpha: 1.0).set()
        let headRect = CGRect(x: rect.minX + rect.width * 0.1, y: rect.minY + rect.height * 0.1, width: rect.width * 0.8, height: rect.height * 0.8)
        NSBezierPath(ovalIn: headRect).fill()
        
        // Left Ear
        let leftEar = NSBezierPath()
        leftEar.move(to: CGPoint(x: rect.minX + rect.width * 0.15, y: rect.minY + rect.height * 0.65))
        leftEar.line(to: CGPoint(x: rect.minX + rect.width * 0.05, y: rect.maxY))
        leftEar.line(to: CGPoint(x: rect.minX + rect.width * 0.4, y: rect.minY + rect.height * 0.75))
        leftEar.close()
        leftEar.fill()
        
        // Right Ear
        let rightEar = NSBezierPath()
        rightEar.move(to: CGPoint(x: rect.minX + rect.width * 0.6, y: rect.minY + rect.height * 0.75))
        rightEar.line(to: CGPoint(x: rect.maxX - rect.width * 0.05, y: rect.maxY))
        rightEar.line(to: CGPoint(x: rect.maxX - rect.width * 0.15, y: rect.minY + rect.height * 0.65))
        rightEar.close()
        rightEar.fill()
        
        // Nose
        NSColor.black.set()
        let noseRect = CGRect(x: rect.midX - rect.width * 0.08, y: rect.minY + rect.height * 0.25, width: rect.width * 0.16, height: rect.height * 0.12)
        NSBezierPath(ovalIn: noseRect).fill()
    }
    
    private func drawClassicPaddle(xPosition: CGFloat, yCenter: CGFloat) {
        NSColor.white.set()
        let paddleRect = CGRect(x: xPosition, y: yCenter - (paddleHeight / 2), width: paddleWidth, height: paddleHeight)
        let path = NSBezierPath(roundedRect: paddleRect, xRadius: paddleWidth / 4, yRadius: paddleWidth / 4)
        path.fill()
    }
}
