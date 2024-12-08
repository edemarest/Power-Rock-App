import UIKit

/**
 `SetTableViewCell` custom table view cell displaying a set of exercises, allowing completion tracking and marking the set as completed.
 */
class SetTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    weak var delegate: SetTableViewCellDelegate?
    private var exercises: [(name: String, reps: Int, isChecked: Bool)] = []
    private var isCompleted = false
    private var setIndex: Int = 0
    private let titleLabel = UILabel()
    private let innerTableView = UITableView()
    private let completeButton = UIButton()
    private var innerTableHeightConstraint: NSLayoutConstraint!

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        innerTableView.dataSource = self
        innerTableView.delegate = self
        innerTableView.register(ExerciseRowCell.self, forCellReuseIdentifier: "ExerciseRowCell")
        innerTableView.translatesAutoresizingMaskIntoConstraints = false
        innerTableView.isScrollEnabled = false
        contentView.addSubview(innerTableView)

        innerTableHeightConstraint = innerTableView.heightAnchor.constraint(equalToConstant: 0)
        innerTableHeightConstraint.isActive = true

        completeButton.setTitle("Complete", for: .normal)
        completeButton.backgroundColor = .gray
        completeButton.layer.cornerRadius = 10
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.isEnabled = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.addTarget(self, action: #selector(didCompleteSet), for: .touchUpInside)
        contentView.addSubview(completeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            innerTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            innerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            innerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            completeButton.topAnchor.constraint(equalTo: innerTableView.bottomAnchor, constant: 16),
            completeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Configuration
    func configure(with set: LiveSet, delegate: SetTableViewCellDelegate, index: Int, isCompleted: Bool = false) {
        self.delegate = delegate
        self.setIndex = index
        self.isCompleted = isCompleted

        if isCompleted {
            transformToCompletedCell()
        } else {
            titleLabel.text = "Set \(index + 1)"
            self.exercises = set.exercises.map { ($0.name, $0.reps, $0.isChecked) }
            innerTableView.reloadData()
            updateInnerTableHeight()
            completeButton.isHidden = false
            innerTableView.isHidden = false
            contentView.backgroundColor = .white
        }
    }

    private func updateInnerTableHeight() {
        let rowHeight: CGFloat = 44
        innerTableHeightConstraint.constant = rowHeight * CGFloat(exercises.count)
        layoutIfNeeded()
    }

    private func transformToCompletedCell() {
        isCompleted = true
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        titleLabel.text = "✅ Set \(setIndex + 1) Completed"
        innerTableView.isHidden = true
        completeButton.isHidden = true
        innerTableHeightConstraint.constant = 0
        layoutIfNeeded()
    }

    @objc private func didCompleteSet() {
        transformToCompletedCell()
        delegate?.didCompleteSet(at: setIndex)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let exercise = exercises[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseRowCell", for: indexPath) as! ExerciseRowCell
        cell.configure(exerciseName: exercise.name, reps: exercise.reps, isChecked: exercise.isChecked)
        cell.onCheckboxToggle = { [weak self] isChecked in
            guard let self = self, !self.isCompleted else { return }
            self.exercises[indexPath.row].isChecked = isChecked
            self.checkCompletion()
        }
        return cell
    }

    private func checkCompletion() {
        let allChecked = exercises.allSatisfy { $0.isChecked }
        completeButton.isEnabled = allChecked
        completeButton.backgroundColor = allChecked ? .orange : .gray
    }
}
