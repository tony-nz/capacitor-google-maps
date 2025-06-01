import UIKit
import Capacitor
import GoogleMaps

class CustomInfoWindow: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snippetLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var markerId: String?
    var mapId: String?
    var customMapViewEvents: CustomMapViewEvents?
    var customMapView: CustomMapView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Create the view programmatically
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4
        
        // Create title label
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor.black
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        // Create snippet label
        snippetLabel = UILabel()
        snippetLabel.font = UIFont.systemFont(ofSize: 14)
        snippetLabel.textColor = UIColor.gray
        snippetLabel.numberOfLines = 2
        snippetLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(snippetLabel)
        
        // Create action button
        actionButton = UIButton(type: .system)
        actionButton.setTitle("Action", for: .normal)
        actionButton.backgroundColor = UIColor.systemBlue
        actionButton.setTitleColor(UIColor.white, for: .normal)
        actionButton.layer.cornerRadius = 4
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        addSubview(actionButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            // Snippet label constraints
            snippetLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            snippetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            snippetLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            // Action button constraints
            actionButton.topAnchor.constraint(equalTo: snippetLabel.bottomAnchor, constant: 8),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            actionButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Overall width constraint
            widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configure(with marker: GMSMarker, mapId: String, customMapViewEvents: CustomMapViewEvents?, customMapView: CustomMapView?) {
        self.mapId = mapId
        self.customMapViewEvents = customMapViewEvents
        self.customMapView = customMapView
        
        // Extract marker data
        if let userData = marker.userData as? JSObject {
            self.markerId = userData["markerId"] as? String
            
            // Get custom info window data if available
            if let metadata = userData["metadata"] as? JSObject,
               let infoWindow = metadata["infoWindow"] as? JSObject {
                
                titleLabel.text = infoWindow["title"] as? String ?? marker.title ?? "No Title"
                snippetLabel.text = infoWindow["snippet"] as? String ?? marker.snippet ?? "No Description"
                
                if let buttonText = infoWindow["buttonText"] as? String {
                    actionButton.setTitle(buttonText, for: .normal)
                    actionButton.isHidden = false
                } else {
                    actionButton.isHidden = true
                }
                
                // Customize colors if provided
                if let titleColor = infoWindow["titleColor"] as? String {
                    titleLabel.textColor = UIColor(hexString: titleColor) ?? UIColor.black
                }
                
                if let snippetColor = infoWindow["snippetColor"] as? String {
                    snippetLabel.textColor = UIColor(hexString: snippetColor) ?? UIColor.gray
                }
                
                if let buttonColor = infoWindow["buttonColor"] as? String {
                    actionButton.backgroundColor = UIColor(hexString: buttonColor) ?? UIColor.systemBlue
                }
                
                if let backgroundColor = infoWindow["backgroundColor"] as? String {
                    self.backgroundColor = UIColor(hexString: backgroundColor) ?? UIColor.white
                }
            } else {
                // Fallback to default marker title/snippet
                titleLabel.text = marker.title ?? "No Title"
                snippetLabel.text = marker.snippet ?? "No Description"
                actionButton.isHidden = true
            }
        }
    }
    
    @objc private func actionButtonTapped() {
        guard let markerId = markerId,
              let mapId = mapId,
              let customMapViewEvents = customMapViewEvents,
              let customMapView = customMapView,
              let callbackId = customMapView.savedCallbackIdForDidTapCustomInfoWindowAction else { return }
        
        // Trigger custom info window button tap event
        let result: PluginCallResultData = [
            "marker": [
                "mapId": mapId,
                "markerId": markerId
            ],
            "action": "buttonTap"
        ]
        
        // Use the proper callback system
        customMapViewEvents.resultForCallbackId(callbackId: callbackId, result: result)
    }
}

// Extension to create UIColor from hex string
extension UIColor {
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
} 