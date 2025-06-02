import UIKit
import Capacitor
import GoogleMaps

class CustomInfoWindow: UIView {
    
    var titleLabel: UILabel!
    var snippetLabel: UILabel!
    var actionButton: UIButton!
    
    var markerId: String?
    var mapId: String?
    var customMapViewEvents: CustomMapViewEvents?
    var callbackId: String?
    
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
    
    func configure(with marker: GMSMarker, mapId: String, customMapViewEvents: CustomMapViewEvents?, callbackId: String?) {
        self.mapId = mapId
        self.customMapViewEvents = customMapViewEvents
        self.callbackId = callbackId
        
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
                    titleLabel.textColor = self.safeColorFromHex(titleColor) ?? UIColor.black
                }
                
                if let snippetColor = infoWindow["snippetColor"] as? String {
                    snippetLabel.textColor = self.safeColorFromHex(snippetColor) ?? UIColor.gray
                }
                
                if let buttonColor = infoWindow["buttonColor"] as? String {
                    actionButton.backgroundColor = self.safeColorFromHex(buttonColor) ?? UIColor.systemBlue
                }
                
                if let backgroundColor = infoWindow["backgroundColor"] as? String {
                    self.backgroundColor = self.safeColorFromHex(backgroundColor) ?? UIColor.white
                }
            } else {
                // Fallback to default marker title/snippet
                titleLabel.text = marker.title ?? "No Title"
                snippetLabel.text = marker.snippet ?? "No Description"
                actionButton.isHidden = true
            }
        }
    }
    
    // Safe color parsing method to avoid assertion failures
    private func safeColorFromHex(_ hexString: String) -> UIColor? {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove # prefix if present
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        
        // Ensure we have exactly 6 characters
        guard hex.count == 6 else {
            return nil
        }
        
        // Convert to UInt32
        var rgbValue: UInt32 = 0
        guard Scanner(string: hex).scanHexInt32(&rgbValue) else {
            return nil
        }
        
        // Extract RGB components
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    @objc private func actionButtonTapped() {
        guard let markerId = markerId,
              let mapId = mapId,
              let customMapViewEvents = customMapViewEvents,
              let callbackId = callbackId else { return }
        
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