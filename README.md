# Making Apps Accessible

This is a sample project to work on during the accessibility workshop.

Below you can find full workshop content.

## Checkpoint 1
### Setup a VoiceOver shortcut

  - Go to *Settings → General → Accessibility*
  - Scroll down to the very bottom → *Accessibility Shortcut*
  - Choose *VoiceOver*
  - You can now **turn VoiceOver on and off** by quickly **triple-clicking the Home button** (or **Side button** on iPhone X & above)

## Checkpoint 2
### Learn VoiceOver basic gestures
- **Single-tap** anywhere on the screen and VoiceOver will speak aloud the item that you're tapping on.
    
  **Drag your finger** over the screen and VoiceOver tells you what’s there.
- **Flick left and right** to move from one element to the next.
- **Double-tap** on the screen to select a focused item.
- **Use 3 fingers** to scroll through a page.
- **Triple-tap with 3 fingers** to toggle curtain.
- **Twist 2 fingers on the screen** (like you're turning a dial) to turn on rotor.
- _[iPhones w/o home button]_ **Slide one finger up from the bottom of the screen until you feel the click & lift your finger** to return to the Home screen.
  
## Checkpoint 3
### Check out the Clock app
Using VoiceOver, explore the Clock app. Try to add a new Alarm.

## Checkpoint 4
### Get *AccessibilitySampleApp*, build it and explore (without VoiceOver)

[Workshop Project Repo](https://github.com/monikamsc/SwiftAveiroAccessibility/)

  - Download / clone the project
  - Select a Team in Project settings & change Bundle Identifier
  - Run on your iPhone

## Checkpoint 5
### Explore the app via VoiceOver
  - Triple-tap Home/Side button to activate VoiceOver.
  - Flick through the `MuffinListViewController` screen.
  - Set focus on one of the cells and double tap to select it.
  - Flick through the `MuffinDetailsViewController` screen.
 
_What could work better?_

## Checkpoint 6
### Fixing the `MuffinDetailsViewController` screen

**1. Visual hierarchy**
> After entering a new screen, focus should be set to a Back/Close button.

Remove `addImportantButton()` from `viewDidLoad`.

**2. Accessibility labels**
> Short and descriptive name for UI controls.

Add a label to the Back button.
```swift
@IBOutlet private weak var backButton: UIButton! {
    didSet {
        backButton.accessibilityLabel = "Back"
    }
}
```

**3. Accessibility elements**
> Navigating through the screen should be logical and should not slow down the user.

Group UI controls so that you create:
 - two accessibility elements for `muffinDetailsContainerView`: a `difficultyElement` and a `authorElement`,
 - a `recipeElement` for a `recipeContainerView`.

```swift
private func setupAccessibility() {
    let difficultyElement = UIAccessibilityElement(accessibilityContainer: muffinDetailsContainerView)
    difficultyElement.accessibilityLabel = "\(difficultyTitleLabel.text!), \(difficultyLevel!)"
    difficultyElement.accessibilityFrameInContainerSpace = difficultyTitleLabel.frame.union(difficultyLabel.frame)

    let authorElement = UIAccessibilityElement(accessibilityContainer: muffinDetailsContainerView)
    authorElement.accessibilityLabel = "\(authorTitleLabel.text!), \(authorLabel.text!)"
    authorElement.accessibilityFrameInContainerSpace = authorTitleLabel.frame.union(authorLabel.frame)

    muffinDetailsContainerView.accessibilityElements = [difficultyElement, authorElement]

    let recipeElement = UIAccessibilityElement(accessibilityContainer: recipeContainerView)
    recipeElement.accessibilityLabel = "\(recipeHeaderLabel.text!), \(recipeLabel.text!)"
    recipeElement.accessibilityFrameInContainerSpace = recipeHeaderLabel.frame.union(recipeLabel.frame)

    recipeContainerView.accessibilityElements = [recipeElement]
}
```
Call `setupAccessibility()` from `viewDidLoad`.

## Checkpoint 7
### Fixing the `MuffinListViewController` screen

**1. Modal views & accessibility hints**
>Using a modal overlay view should be marked so that the elements underneath are not accessible.

Set the overlay preview as a modal view. Go to the `showMuffinPreview(_ sender:)` function and add:
```swift
overlay.accessibilityViewIsModal = true
```
Add a hint to the label instructing the user to close the preview:
```swift
infoLabel.accessibilityHint = "Double tap to close"
```
Inform VoiceOver that there was a new screen presented. At the end of the same function, add:
```swift
UIAccessibility.post(notification: .screenChanged, argument: nil)
```

**2. Navigating cells in a table view**
>Detailed contents of a custom cell should not slow down navigating through a table view.

Go to the *MuffinCell.swift* and set `isAccessibilityElement` property of a cell to `true`, so that the whole cell is treated as an accessibility element by VoiceOve. Go to `awakeFromNib()` and add:
```swift
isAccessibilityElement = true
```
Set the `accessibilityLabel` and `accessibilityHint` of the cell. In the `configure(withName: level: image: tag:)` function
```swift
accessibilityLabel = nameLabel.text
accessibilityHint = difficultyLabel.text
```
>Hints are optional and can be disabled by the user. Keep them short and informative — they slow down the navigation a lot.

**3. Custom actions**
>Don't strip the VoiceOver user of any functionality.

Go to the _MuffinListViewController.swift_ and add a custom action to the cell that will show a preview. In a `tableView(_: cellForRowAt:) -> UITableViewCell` function, add:
```swift
let showPreview = UIAccessibilityCustomAction(name: "ShowPreview",
            target: self,
            selector: #selector(showMuffinPreview(_:)))
cell.accessibilityCustomActions = [showPreview]
```

## Checkpoint 8
### Adding a *custom* custom action

If we want to let the user add a muffin recipe to favorites using VoiceOver, we need to know which cell was the custom action called from. Create a subclass of `UIAccessibilityCustomAction` that will have an `indexPath` property.
```swift
class MuffinAccessibilityCustomAction: UIAccessibilityCustomAction {
    let indexPath: IndexPath

    init(name: String, indexPath: IndexPath, target: Any, selector: Selector) {
        self.indexPath = indexPath
        super.init(name: name, target: target, selector: selector)
    }
}
```
We will create a `favoriteAccessibilityCustomAction`, but its name can't be static — if the muffin is not yet starred, it should be read _"Add to favorites"_. However, if the muffin is already starred, it should be read: _"Remove from favorites"_. So every time we update the custom action, we will overwrite the `accessibilityCustomActions` property of the cell. Go to the _MuffinCell.swift_ and add:
```swift
var previewAccessibilityCustomAction: UIAccessibilityCustomAction? {
    didSet {
        if let preview = previewAccessibilityCustomAction,
            let favorite = favoriteAccessibilityCustomAction {
        self.accessibilityCustomActions = [preview,
                                           favorite]
        }
    }
}

var favoriteAccessibilityCustomAction: MuffinAccessibilityCustomAction? {
    didSet {
        if let preview = previewAccessibilityCustomAction,
            let favorite = favoriteAccessibilityCustomAction {
            self.accessibilityCustomActions = [preview,
                                               favorite]
        }
    }
}
```
Now go to the `MuffinListViewController` and, instead of code from **Checkpoint 7 point 3** inside the `tableView(_: cellForRowAt:) -> UITableViewCell` function, let's do:
```swift
let showPreview = UIAccessibilityCustomAction(
    name: "ShowPreview",
    target: self,
    selector: #selector(showMuffinPreview(_:)))
cell.previewAccessibilityCustomAction = showPreview

let favorite = MuffinAccessibilityCustomAction(
    name: "Add to favorites",
    indexPath: indexPath,
    target: self,
    selector: #selector(toggleFavorite))
cell.favoriteAccessibilityCustomAction = favorite
```
and below let's add a function:
```swift
@objc private func toggleFavorite(_ sender: MuffinAccessibilityCustomAction) -> Bool {
    let cell = tableView.cellForRow(at: sender.indexPath) as! MuffinCell
    cell.toggleFavorite()

    sender.name = cell.isFavorite ? "Remove from favorites" : "Add to favorites"
    cell.favoriteAccessibilityCustomAction = sender
    
    return true
}
```

## Checkpoint 9
### Supporting larger text
Larger text can be set under _Settings → General → Accessibility → Larger Text_

**1. Larger text for system font**
* **Storyboard:** choose _Muffins overview_ label and in the Attributes inspector, set the Font to _Headline_ and tick _Automatically Adjusts Font_.
* **Programmatically:** go to _MuffinCell.swift_ and do:
    ```swift
    @IBOutlet weak var difficultyLabel: UILabel! {
        didSet {
            difficultyLabel.font = .preferredFont(forTextStyle: .caption1)
            difficultyLabel.adjustsFontForContentSizeCategory = true
        }
    }
    ```

**2. Larger text for custom font**

Let's add an `UIFont`'s extension with a method returning a custom font ready to support accessibility larger text:
```swift
extension UIFont {
    static func dynamicFont(_ name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            fatalError("Failed to load the \(name) font.")
        }
        return UIFontMetrics.default.scaledFont(for: font)
    }
}
```
and in the _MuffinCell.swift_, let's change the `nameLabel` so that it uses our custom font properly:
```swift
@IBOutlet weak var nameLabel: UILabel! {
    didSet {
        nameLabel.font = .dynamicFont("Cochin", size: 18)
        nameLabel.adjustsFontForContentSizeCategory = true
    }
}
```
