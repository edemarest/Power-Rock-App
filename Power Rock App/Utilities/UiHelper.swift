import UIKit

struct UIHelper {
    
    // Gradient layer from orange to red
    static let orangeToRedGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.orange.cgColor,
            UIColor.red.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }()
    
    
    
    // Configure a text field with consistent styling
    static func createStyledTextField(
        placeholder: String,
        font: UIFont = UIFont.systemFont(ofSize: 16),
        backgroundColor: UIColor = .darkGray,
        textColor: UIColor = .white,
        placeholderColor: UIColor = .gray,
        cornerRadius: CGFloat = 5
    ) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = backgroundColor
        textField.textColor = textColor
        textField.font = font
        textField.layer.cornerRadius = cornerRadius
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
        return textField
    }
    
    // Configure a button with custom styling
    static func configureButton(
        _ button: UIButton,
        title: String,
        font: UIFont,
        backgroundColor: UIColor = .white,
        textColor: UIColor = .black,
        cornerRadius: CGFloat = 25
    ) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = cornerRadius
    }
    
    // Configure a label with consistent styling
    static func configureLabel(
        _ label: UILabel,
        text: String,
        font: UIFont,
        textColor: UIColor = .white
    ) {
        label.text = text
        label.font = font
        label.textColor = textColor
    }
    
    // Create a tag label with a removable button
        static func createTagLabel(
            with text: String,
            font: UIFont,
            backgroundColor: UIColor = .white,
            textColor: UIColor = .black,
            cornerRadius: CGFloat = 10,
            target: Any?,
            action: Selector
        ) -> UIView {
            let container = UIView()
            container.backgroundColor = backgroundColor
            container.layer.cornerRadius = cornerRadius
            container.clipsToBounds = true
            
            let label = UILabel()
            label.text = text
            label.font = font
            label.textColor = textColor
            label.backgroundColor = .clear
            label.textAlignment = .center
            
            let removeButton = UIButton(type: .system)
            removeButton.setTitle("X", for: .normal)
            removeButton.setTitleColor(.black, for: .normal)
            removeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            removeButton.backgroundColor = .clear
            removeButton.addTarget(target, action: action, for: .touchUpInside)
            
            container.addSubview(label)
            container.addSubview(removeButton)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            removeButton.translatesAutoresizingMaskIntoConstraints = false
            // Do not set container.translatesAutoresizingMaskIntoConstraints = false here
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
                
                removeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
                removeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                removeButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
            
            return container
        }
    
    // Configure a button with an icon
    static func configureButtonWithIcon(
        _ button: UIButton,
        title: String,
        font: UIFont,
        iconName: String,
        backgroundColor: UIColor = .white,
        textColor: UIColor = .black,
        cornerRadius: CGFloat = 25
    ) {
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = font
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        
        if let iconImage = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(iconImage, for: .normal)
            button.tintColor = textColor
        }
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    // Configure a table view with default settings
    static func configureTableView(_ tableView: UITableView) {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
    }
    
    // Return color for difficulty level
    static func colorForDifficulty(difficulty: Int) -> UIColor {
        switch difficulty {
        case 1:
            return UIColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1.0) // Light green
        case 2:
            return UIColor(red: 0.8, green: 1.0, blue: 0.4, alpha: 1.0) // Yellowish-green
        case 3:
            return UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0) // Light orange
        case 4:
            return UIColor(red: 1.0, green: 0.4, blue: 0.2, alpha: 1.0) // Red-orange
        case 5:
            return UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0) // Light red
        default:
            return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) // Light gray
        }
    }
}

// MARK: - UITextField Extension
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

// MARK: - CAGradientLayer Extension
extension CAGradientLayer {
    func toImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
