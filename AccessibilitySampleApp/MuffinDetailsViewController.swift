import UIKit

class MuffinDetailsViewController: UIViewController {
    var muffinName: String?
    var muffinIcon: UIImage?
    var difficultyLevel: Int?

    @IBOutlet weak var muffinDetailsContainerView: UIView!
    @IBOutlet weak var recipeContainerView: UIView!

    @IBOutlet private weak var backButton: UIButton!

    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = muffinName
            titleLabel.font = UIFont(name: "Cochin-Bold", size: 30.0)!
        }
    }

    @IBOutlet private weak var muffinImage: UIImageView! {
        didSet {
            muffinImage.image = muffinIcon
            muffinImage.clipsToBounds = true
            muffinImage.layer.cornerRadius = muffinImage.frame.size.width/2
        }
    }

    @IBOutlet weak var detailsHeaderLabel: UILabel!
    @IBOutlet weak var difficultyTitleLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel! {
        didSet {
            if let difficultyLevel = difficultyLevel {
                var difficulty = ""
                for _ in 0..<difficultyLevel {
                    difficulty.append("🧁")
                }
                difficultyLabel.text = difficulty
            }
        }
    }

    @IBOutlet weak var authorTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    @IBOutlet weak var recipeHeaderLabel: UILabel!
    @IBOutlet weak var recipeLabel: UILabel! {
        didSet {
            recipeLabel.font = UIFont(name: "Cochin-Italic", size: 15.0)!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addImportantButton()
    }

    private func addImportantButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.addSubview(button)
    }
}
