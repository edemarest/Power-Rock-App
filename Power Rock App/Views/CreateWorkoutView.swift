import UIKit

protocol CreateWorkoutViewDelegate: AnyObject {
    func didTapCreateWorkoutBackButton()
    func didTapPublishButton(workout: Workout)
    func didTapUploadWorkoutImage()
    func didTapAddSet()
}

struct Workout {
    var title: String
    var coverPhoto: UIImage
    var selectedMembers: [String]
    var difficulty: Int
    var sets: [String] // Placeholder for sets, adjust based on actual structure
}

class CreateWorkoutView: UIView {
    
    // Delegate
    weak var delegate: CreateWorkoutViewDelegate?
    
    // Data Storage
    private var workoutTitle: String = ""
    private var selectedMembers: [String] = []
    private var difficulty: Int = 0
    private var sets: [String] = []
    
    // UI Elements
    private let backButton = UIButton(type: .system)
    private let publishButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()
    
    let coverPhotoImageView = UIImageView()
    private let uploadImageButton = UIButton(type: .system)
    private let workoutNameTextField = UITextField()
    
    private let membersLabel = UILabel()
    private var memberButtons: [UIButton] = []
    private let difficultyLabel = UILabel()
    private var difficultyButtons: [UIButton] = []
    
    private let addSetLabel = UILabel()
    private let addSetButton = UIButton(type: .system)
    private let setsTableView = UITableView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        backgroundColor = .white
        
        // Navigation Bar
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        addSubview(backButton)
        
        navTitleLabel.text = "Create Workout"
        navTitleLabel.textAlignment = .center
        navTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(navTitleLabel)
        
        publishButton.setTitle("Publish", for: .normal)
        publishButton.setTitleColor(.systemBlue, for: .normal)
        addSubview(publishButton)
        
        // Cover Photo
        coverPhotoImageView.image = UIImage(named: "Default_Profile_Picture.png")
        coverPhotoImageView.contentMode = .scaleAspectFit
        coverPhotoImageView.backgroundColor = .lightGray
        coverPhotoImageView.layer.cornerRadius = 10
        coverPhotoImageView.clipsToBounds = true
        addSubview(coverPhotoImageView)
        
        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.setTitleColor(.systemBlue, for: .normal)
        addSubview(uploadImageButton)
        
        // Workout Name
        workoutNameTextField.placeholder = "Workout Name"
        workoutNameTextField.borderStyle = .roundedRect
        addSubview(workoutNameTextField)
        
        // Members Section
        membersLabel.text = "Select Members:"
        membersLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(membersLabel)
        
        // Members Buttons (example placeholders, adjust dynamically)
        ["Member1", "Member2", "Member3"].forEach { member in
            let button = UIButton(type: .system)
            button.setTitle(member, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            button.layer.cornerRadius = 5
            button.addTarget(self, action: #selector(toggleMemberSelection(_:)), for: .touchUpInside)
            memberButtons.append(button)
            addSubview(button)
        }
        
        // Difficulty Level
        difficultyLabel.text = "Select Difficulty:"
        difficultyLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(difficultyLabel)
        
        for i in 1...5 {
            let button = UIButton(type: .system)
            button.setTitle("\(i)", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 5
            button.tag = i
            button.addTarget(self, action: #selector(selectDifficulty(_:)), for: .touchUpInside)
            difficultyButtons.append(button)
            addSubview(button)
        }
        
        // Add Set Section
        addSetLabel.text = "Add Set:"
        addSetLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(addSetLabel)
        
        addSetButton.setTitle("+", for: .normal)
        addSetButton.setTitleColor(.white, for: .normal)
        addSetButton.backgroundColor = .systemBlue
        addSetButton.layer.cornerRadius = 20
        addSubview(addSetButton)
        
        // Sets Table View
        setsTableView.backgroundColor = .white
        setsTableView.separatorStyle = .none
        setsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SetCell")
        addSubview(setsTableView)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        let padding: CGFloat = 16
        
        // Navigation Bar
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        
        coverPhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        workoutNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        membersLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSetLabel.translatesAutoresizingMaskIntoConstraints = false
        addSetButton.translatesAutoresizingMaskIntoConstraints = false
        setsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            navTitleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            navTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            publishButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            publishButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            
            // Cover Photo and Workout Name
            coverPhotoImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: padding),
            coverPhotoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            coverPhotoImageView.widthAnchor.constraint(equalToConstant: 120),
            coverPhotoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            uploadImageButton.topAnchor.constraint(equalTo: coverPhotoImageView.bottomAnchor, constant: 8),
            uploadImageButton.centerXAnchor.constraint(equalTo: coverPhotoImageView.centerXAnchor),
            
            workoutNameTextField.topAnchor.constraint(equalTo: coverPhotoImageView.topAnchor),
            workoutNameTextField.leadingAnchor.constraint(equalTo: coverPhotoImageView.trailingAnchor, constant: padding),
            workoutNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            workoutNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Members Section
            membersLabel.topAnchor.constraint(equalTo: workoutNameTextField.bottomAnchor, constant: padding),
            membersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            // Example Member Buttons (adjust positions dynamically)
            difficultyLabel.topAnchor.constraint(equalTo: membersLabel.bottomAnchor, constant: padding),
            difficultyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            // Add Set Section
            addSetLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: padding),
            addSetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            
            addSetButton.centerYAnchor.constraint(equalTo: addSetLabel.centerYAnchor),
            addSetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            addSetButton.widthAnchor.constraint(equalToConstant: 40),
            addSetButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Sets Table View
            setsTableView.topAnchor.constraint(equalTo: addSetLabel.bottomAnchor, constant: padding),
            setsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            setsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            setsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapCreateWorkoutBackButton), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(didTapPublish), for: .touchUpInside)
        uploadImageButton.addTarget(self, action: #selector(didTapUploadWorkoutImage), for: .touchUpInside)
        addSetButton.addTarget(self, action: #selector(didTapAddSet), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func didTapCreateWorkoutBackButton() {
        delegate?.didTapCreateWorkoutBackButton()
    }
    
    @objc private func didTapPublish() {
        guard let title = workoutNameTextField.text, !title.isEmpty else {
            print("Workout title is required")
            return
        }
        
        let workout = Workout(title: title, coverPhoto: coverPhotoImageView.image ?? UIImage(named: "Default_Profile_Picture.png")!, selectedMembers: selectedMembers, difficulty: difficulty, sets: sets)
        delegate?.didTapPublishButton(workout: workout)
    }
    
    @objc private func didTapUploadWorkoutImage() {
        delegate?.didTapUploadWorkoutImage()
    }
    
    @objc private func didTapAddSet() {
        delegate?.didTapAddSet()
    }
    
    
    
    @objc private func toggleMemberSelection(_ sender: UIButton) {
        guard let member = sender.title(for: .normal) else { return }
        
        if selectedMembers.contains(member) {
            selectedMembers.removeAll { $0 == member }
            sender.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        } else {
            selectedMembers.append(member)
            sender.backgroundColor = .systemOrange
        }
    }
    
    @objc private func selectDifficulty(_ sender: UIButton) {
        difficulty = sender.tag
        for button in difficultyButtons {
            button.backgroundColor = button.tag <= difficulty ? .systemOrange : .lightGray
        }
    }
}
