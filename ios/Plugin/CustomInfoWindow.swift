  import UIKit
  import Capacitor
  import GoogleMaps

  class CustomInfoWindow: UIView {
      
      var titleLabel: UILabel!
      var snippetTextView: UITextView!
      
      var markerId: String?
      var mapId: String?
      var customMapViewEvents: CustomMapViewEvents?
      var callbackId: String?
      
      // Configuration flags
      private var isSnippetHTML: Bool = false
      private var snippetHeightConstraint: NSLayoutConstraint?
      
      // Offset properties
      var offsetX: CGFloat = 0
      var offsetY: CGFloat = -10 // Default: 10 points above marker
      
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
          
          // CRITICAL: Disable autoresizing mask constraints for the main view
          self.translatesAutoresizingMaskIntoConstraints = false
          
          // Create title label
          titleLabel = UILabel()
          titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
          titleLabel.textColor = UIColor.black
          titleLabel.numberOfLines = 1
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          addSubview(titleLabel)
          
          // Create snippet text view
          snippetTextView = UITextView()
          snippetTextView.font = UIFont.systemFont(ofSize: 14)
          snippetTextView.textColor = UIColor.gray
          snippetTextView.isEditable = false
          snippetTextView.isScrollEnabled = false
          snippetTextView.backgroundColor = UIColor.clear
          snippetTextView.textContainer.lineFragmentPadding = 0
          snippetTextView.textContainerInset = UIEdgeInsets.zero
          snippetTextView.textContainer.maximumNumberOfLines = 0
          snippetTextView.textContainer.lineBreakMode = .byWordWrapping
          snippetTextView.translatesAutoresizingMaskIntoConstraints = false
          addSubview(snippetTextView)
          
          setupConstraints()
      }
      
      private func setupConstraints() {
          // Create height constraint for snippet text view
          snippetHeightConstraint = snippetTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
          
          // Create width constraint with lower priority
          let widthConstraint = widthAnchor.constraint(equalToConstant: 250)
          widthConstraint.priority = UILayoutPriority(999) // High but not required
          
          NSLayoutConstraint.activate([
              // Title label constraints
              titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
              titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
              titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
              
              // Snippet text view constraints
              snippetTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
              snippetTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
              snippetTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
              snippetTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
              snippetHeightConstraint!,
              
              // Width constraint with lower priority
              widthConstraint
          ])
          
          // Let the content determine the size - no fixed frame
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
                  
                  // Handle snippet content (HTML or plain text)
                  let snippetContent = infoWindow["snippet"] as? String ?? marker.snippet ?? "No Description"
                  
                  // Check if snippet is HTML
                  if let snippetHTML = infoWindow["isSnippetHTML"] as? Bool {
                      isSnippetHTML = snippetHTML
                  }
                  
                  if isSnippetHTML {
                      setHTMLSnippet(snippetContent)
                  } else {
                      snippetTextView.text = snippetContent
                  }
                  
                  // Remove debug background
                  snippetTextView.backgroundColor = UIColor.clear
                  
                  // Update layout after setting content
                  updateLayoutForContent()
                  
                  // Customize colors and sizes if provided
                  if let titleColor = infoWindow["titleColor"] as? String {
                      titleLabel.textColor = self.safeColorFromHex(titleColor) ?? UIColor.black
                  }
                  
                  if let snippetColor = infoWindow["snippetColor"] as? String {
                      snippetTextView.textColor = self.safeColorFromHex(snippetColor) ?? UIColor.gray
                  }
                  
                  if let backgroundColor = infoWindow["backgroundColor"] as? String {
                      self.backgroundColor = self.safeColorFromHex(backgroundColor) ?? UIColor.white
                  }
                  
                  // Set text sizes if provided
                  if let titleSize = infoWindow["titleSize"] as? CGFloat {
                      titleLabel.font = UIFont.boldSystemFont(ofSize: titleSize)
                  }
                  
                  if let snippetSize = infoWindow["snippetSize"] as? CGFloat {
                      if isSnippetHTML {
                          // For HTML content, we'll update the font in the attributed string
                          updateHTMLFontSize(snippetSize)
                      } else {
                          snippetTextView.font = UIFont.systemFont(ofSize: snippetSize)
                      }
                  }
                  
                  // Set offset if provided
                  if let offsetXValue = infoWindow["offsetX"] as? CGFloat {
                      offsetX = offsetXValue
                  }
                  
                  if let offsetYValue = infoWindow["offsetY"] as? CGFloat {
                      offsetY = offsetYValue
                  }
              } else {
                  // Fallback to default marker title/snippet
                  titleLabel.text = marker.title ?? "No Title"
                  snippetTextView.text = marker.snippet ?? "No Description"
              }
          }
      }
      
      private func updateLayoutForContent() {
          // Force the text view to calculate its content size with flexible width
          let maxSize = CGSize(width: 226, height: CGFloat.greatestFiniteMagnitude) // 250 - 24 (padding)
          let textSize = snippetTextView.sizeThatFits(maxSize)
          
          // Update the height constraint
          let newHeight = max(textSize.height, 20)
          snippetHeightConstraint?.constant = newHeight
          
          // Update the text view height constraint if needed
          snippetTextView.invalidateIntrinsicContentSize()
          
          // Force layout update
          setNeedsLayout()
          layoutIfNeeded()
      }
      
      // HTML parsing method
      private func setHTMLSnippet(_ htmlString: String) {
          guard let data = htmlString.data(using: .utf8) else {
              snippetTextView.text = htmlString
              return
          }
          
          do {
              let attributedString = try NSAttributedString(
                  data: data,
                  options: [
                      .documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue
                  ],
                  documentAttributes: nil
              )
              
              // Apply the base font and color to the attributed string
              let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
              let range = NSRange(location: 0, length: mutableAttributedString.length)
              
              // Set default font and color
              mutableAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: range)
              mutableAttributedString.addAttribute(.foregroundColor, value: snippetTextView.textColor ?? UIColor.gray, range: range)
              
              snippetTextView.attributedText = mutableAttributedString
              
              // Force layout update to ensure proper sizing
              snippetTextView.sizeToFit()
              snippetTextView.layoutIfNeeded()
              
          } catch {
              // Fallback to plain text if HTML parsing fails
              snippetTextView.text = htmlString
          }
          
          // Ensure layout is updated after setting HTML content
          DispatchQueue.main.async {
              self.updateLayoutForContent()
          }
      }
      
      // Update font size for HTML content
      private func updateHTMLFontSize(_ fontSize: CGFloat) {
          guard let attributedText = snippetTextView.attributedText else { return }
          
          let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
          let range = NSRange(location: 0, length: mutableAttributedString.length)
          
          // Update font size while preserving other attributes
          mutableAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: range)
          
          snippetTextView.attributedText = mutableAttributedString
          
          // Update layout after font change
          DispatchQueue.main.async {
              self.updateLayoutForContent()
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
  } 