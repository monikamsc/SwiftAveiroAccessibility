import UIKit

class MuffinListViewController: UIViewController {

    private let muffins = [(name: "Lemon Meringue Muffin", level: 3, image: Constants.Images.lemonMuffin),
                           (name: "Mascarpone Berry Muffin", level: 2, image: Constants.Images.blueberryMuffin),
                           (name: "Caramel & Chocolate Muffin", level: 1, image: Constants.Images.chocolateMuffin)]

    private let overlay = UIView()

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }

    @IBAction func showMuffinPreview(_ sender: UIButton) {
        overlay.frame = view.frame

        let shade = UIView(frame: view.frame)
        shade.backgroundColor = .black
        shade.alpha = 0.7

        let infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
        infoLabel.textColor = .white
        infoLabel.text = "Some useful quick preview"
        infoLabel.textAlignment = .center
        infoLabel.center = view.center

        overlay.addSubview(shade)
        overlay.addSubview(infoLabel)
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                            action: #selector(closeMuffinPreview)))
        view.addSubview(overlay)
    }

    @objc private func closeMuffinPreview(recognizer: UITapGestureRecognizer) {
        overlay.subviews.forEach{ subview in
            subview.removeFromSuperview()
        }
        overlay.removeFromSuperview()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: MuffinDetailsViewController.self),
            let index = tableView.indexPathForSelectedRow?.row {
            let detailsVC = segue.destination as! MuffinDetailsViewController

            detailsVC.muffinName = muffins[index].name
            detailsVC.muffinIcon = muffins[index].image
            detailsVC.difficultyLevel = muffins[index].level
        }
    }

    @IBAction func done(_ segue: UIStoryboardSegue) {}
}

extension MuffinListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetails", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MuffinListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MuffinCell") as? MuffinCell else {
                return UITableViewCell()
        }

        cell.configure(withName: muffins[indexPath.row].name,
                       level: muffins[indexPath.row].level,
                       image: muffins[indexPath.row].image,
                       tag: indexPath.row)

        return cell
    }
}
