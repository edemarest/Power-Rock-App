import UIKit

struct UIHelper {
    
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
    
    static func configureButtonWithIcon(
        _ button: UIButton,
        title: String,
        font: UIFont,
        iconName: String,
        backgroundColor: UIColor = .white,
        textColor: UIColor = .black,
        cornerRadius: CGFloat = 25
    ) {
        // Set button properties
        button.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = font
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        
        // Set button image
        if let iconImage = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(iconImage, for: .normal)
            button.tintColor = textColor // Ensures the icon matches the text color
        }
        
        // Adjust title and image layout
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    }
    
    
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
    
    static func configureTextField(
        _ textField: UITextField,
        placeholder: String,
        font: UIFont,
        backgroundColor: UIColor = .black,
        textColor: UIColor = .white,
        borderColor: UIColor = .white,
        cornerRadius: CGFloat = 8,
        padding: CGFloat = 10
    ) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor.cgColor
        textField.textColor = textColor
        textField.font = font
        textField.layer.cornerRadius = cornerRadius
        textField.backgroundColor = backgroundColor
        textField.setLeftPadding(padding)
    }
    
    static func createTagLabel(
        with text: String,
        font: UIFont,
        backgroundColor: UIColor = .white,
        textColor: UIColor = .black,
        cornerRadius: CGFloat = 10,
        target: Any?,
        action: Selector
    ) -> UIView {
        // Create a container view
        let container = UIView()
        container.backgroundColor = backgroundColor
        container.layer.cornerRadius = cornerRadius
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the label
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the "X" button
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("X", for: .normal)
        removeButton.setTitleColor(.black, for: .normal)
        removeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        removeButton.backgroundColor = .clear
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.addTarget(target, action: action, for: .touchUpInside)
        
        // Add label and button to the container
        container.addSubview(label)
        container.addSubview(removeButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            removeButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            removeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            removeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        // Set a fixed height for the container
        container.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return container
    }
    
    static func configureTableView(_ tableView: UITableView) {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
    }
    // Gradient colors for difficulty levels
    static func gradientForDifficulty(difficulty: Int) -> CAGradientLayer? {
        let colors: [CGColor]

        switch difficulty {
        case 1:
            // Darker light green gradient
            colors = [UIColor(red: 0.4, green: 0.6, blue: 0.4, alpha: 1).cgColor, // Darker green
                      UIColor(red: 0.5, green: 0.7, blue: 0.5, alpha: 1).cgColor] // Slightly muted green
        case 2:
            // Darker yellowish green gradient
            colors = [UIColor(red: 0.4, green: 0.5, blue: 0.2, alpha: 1).cgColor, // Olive green
                      UIColor(red: 0.5, green: 0.6, blue: 0.3, alpha: 1).cgColor] // Muted yellow-green
        case 3:
            // Darker yellowish orange gradient
            colors = [UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1).cgColor, // Dark mustard yellow
                      UIColor(red: 0.7, green: 0.3, blue: 0.1, alpha: 1).cgColor] // Deep orange
        case 4:
            // Darker orangish red gradient
            colors = [UIColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1).cgColor, // Burnt orange
                      UIColor(red: 0.7, green: 0.2, blue: 0.1, alpha: 1).cgColor] // Deep orange-red
        case 5:
            // Darker deep red gradient
            colors = [UIColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 1).cgColor, // Crimson red
                      UIColor(red: 0.6, green: 0.2, blue: 0.1, alpha: 1).cgColor] // Deep red-orange
        default:
            return nil
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5) // Horizontal gradient
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
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
