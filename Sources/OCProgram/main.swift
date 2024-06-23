//
//  main.swift
//  OCProgram
//
//  Created by Noah Le Ru on 1/01/24.
//

import Foundation
import OCGUI

// Struct for each item on menu.
struct Menu{
    // Name of item.
    let name: String
    // Price of item.
    let price: Double
    // Veganity of item.
    let vegan: Bool
    // File name of item image.
    let image: String

}

// Application to show menu with cart.
class MenuApp : OCApp{
    // Menu and Cart items and trackers.
    var MenuArray: [Menu] = []
    var CartArray: [Menu] = []
    var cartAmount: Int = 0
    var selectedMenuIndex: Int? = nil

    // GUI.
    let menuListView = OCListView()
    let menuView = OCVBox(controls: [])
    let cartListView = OCListView()
    var cartButton = OCButton(text: "Add to Cart")
    var cartView = OCVBox(controls: [OCLabel(text: "Cart[0]")])
    let removeButton = OCButton(text: "Remove")
    let finaliseButton = OCButton(text: "Finalise")
    let bottomHbox = OCHBox(controls: [])

    // When user clicks on list view item, load appropraite item into menuView.
    func onMenuListChange(
        listView: any OCControlChangeable,
        selectedItem: OCListItem
    ) {
    if let itemIndex = self.MenuArray.firstIndex(where: {
        $0.name == selectedItem.text}){
        
        // Set up selected item.
        self.selectedMenuIndex = itemIndex
        let item = self.MenuArray[itemIndex]

        // Clear out the existing recipe view.
        self.menuView.empty()
        
        // Populated menu view with respective veganity.
        if item.vegan {
            self.menuView.append(control:
            OCLabel(text: "\(item.name) V $\(item.price)")
            )
        } else {
            self.menuView.append(control:
            OCLabel(text: "\(item.name) $\(item.price)")
            )
        }
        // Populate menu view with image.
        self.menuView.append(control: OCImageView(filename: "\(item.image)"))

        // If less than 5 items in cart populate menu view with add cart button.
        // Else message saying max 5 items.
        if cartAmount < 5 {
            self.menuView.append(control: cartButton)
        } else {
            self.menuView.append(control: OCLabel(text: "Max 5 items in cart."))
        }
        }
    
    }

    // Function to populate cart with default values.
    func populateCart(){
        self.cartView.append(control: OCLabel(text: "Cart[\(cartAmount)]"))
        self.cartView.append(control: cartListView)
        self.cartView.append(control: OCHBox(controls: [removeButton, finaliseButton]))
    }

    // When this button is clicked, update cart with this item.
    func onAddCartClick(button: any OCControlClickable){
        // Only if space left in the cart. Else display max message.
        if cartAmount < 5 {
            // Update cart amount and update info for cartlistview and cartArray
            self.cartAmount += 1
            self.cartView.empty()
            self.cartListView.empty()
            self.CartArray.append(self.MenuArray[selectedMenuIndex!])
            for item in CartArray {
                self.cartListView.append(item: "\(item.name)  $\(item.price)")
            }
            // Populate cartview with updated info.
            populateCart()
        } else {
            self.menuView.empty()
            self.menuView.append(control: OCLabel(text: "Max 5 items in cart."))
        }

        }

    // When this button is clicked remove latest item from cart.
    func onRemoveButtonClick(button: any OCControlClickable) {
        // Check if cart is empty. If is don't let user remove item.
        if cartAmount > 0{
            // Remove from cartArray, update cart info and repopulate.
            self.CartArray.removeLast()
            self.cartAmount -= 1
            self.cartListView.empty()
            for item in CartArray {
                self.cartListView.append(item: "\(item.name)  $\(item.price)")
            }
            self.cartView.empty()
            populateCart()
        }
    }

    // When this button is cliked get sum of all items in cart and display it.
    func onFinaliseButtonClick(button: any OCControlClickable) {
        self.cartView.empty()
        if cartAmount > 0 {
            // Total variable to be added with each price.
            var total = 0.0
            for item in CartArray{
                total += item.price
            }
            // Populate cart view with different new info.
            // And remove ability to add to cart.
            self.cartView.append(control: OCHBox(controls: [cartListView]))
            self.cartView.append(control: OCLabel(text: "Total: $\(total)"))
            self.cartView.append(control: OCLabel(text: "Your order is now being proccesed by our cafeteria!"))
            self.cartButton.enabled = false
        } else {
            populateCart()
            self.cartView.append(control: OCLabel(text: "Add something to the cart first."))
        }

    }

    override open func main(app: any OCAppDelegate) -> OCControl {
        // Read menu from file.
        guard let text: String = try? String(contentsOfFile: "items.txt") else {
            print("No such file.")
            exit(0)
        }

        // Seperate into lines and loop through each while adding respective data to menu array.
        let lines = text.components(separatedBy: "\n")
        for line in lines[1...] {
            let words = line.components(separatedBy: ",")
            // Ensure right number of components otherwise something wrong with line.
            guard words.count == 4, let price = Double(words[1]), let vegan = Bool(words[2]), let image = String?(words[3]) else {
                print("No item data found")
                continue // Continue the for loop.
            }
            MenuArray.append(Menu(name: words[0], price: price, vegan: vegan, image: image))
        }

        // Populate list view with names.
        for item in MenuArray {
            self.menuListView.append(item: "\(item.name)")
        }

        // Set all event listeners for each click/change.
        self.menuListView.onChange(self.onMenuListChange)
        self.cartButton.onClick(self.onAddCartClick)
        self.removeButton.onClick(self.onRemoveButtonClick)
        self.finaliseButton.onClick(self.onFinaliseButtonClick)
        
        // Return total layout of GUI.
        return OCHBox(controls: [
            menuListView, menuView, cartView
        ])
    }
}

MenuApp().start()