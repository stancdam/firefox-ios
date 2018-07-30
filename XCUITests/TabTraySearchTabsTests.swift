import XCTest

let firstURL = "mozilla.org"
let secondURL = "mozilla.org/en-US/book"
let fullFirstURL = "https://www.mozilla.org/en-US/"

class TabTraySearchTabsTests: BaseTestCase {

    func testSearchTabs() {
        // Open two tabs and go to tab tray
        navigator.openURL(firstURL)
        waitUntilPageLoad()
        navigator.openNewURL(urlString: secondURL )
        navigator.goto(TabTray)

        // Search no matches
        waitforExistence(app.textFields["Search Tabs"])
        XCTAssertTrue(app.textFields["Search Tabs"].exists)
        searchTabs(tabTitleOrUrl: "foo")

        // Search by title one match
        XCTAssertEqual(app.collectionViews.cells.count, 0)
        app.buttons["close medium"].tap()
        searchTabs(tabTitleOrUrl: "Internet")
        XCTAssertEqual(app.collectionViews.cells.count, 1)

        // Search by url two matches
        app.buttons["close medium"].tap()
        searchTabs(tabTitleOrUrl: "mozilla")
        XCTAssertEqual(app.collectionViews.cells.count, 2)
    }

    private func searchTabs(tabTitleOrUrl: String) {
        waitforExistence(app.textFields["Search Tabs"])
        app.textFields["Search Tabs"].tap()
        app.textFields["Search Tabs"].typeText(tabTitleOrUrl)
    }

    func testSearchTabsPrivateMode() {
        navigator.performAction(Action.TogglePrivateMode)
        // Open two tabs to check that the search works
        navigator.openNewURL(urlString: firstURL)
        waitUntilPageLoad()
        navigator.openNewURL(urlString: secondURL)
        navigator.goto(TabTray)
        searchTabs(tabTitleOrUrl: "internet")
        XCTAssertEqual(app.collectionViews.cells.count, 1)
    }

    func testDragAndDropTabToSearchTabField() {
        navigator.openURL(firstURL)
        navigator.goto(TabTray)
        waitforExistence(app.textFields["Search Tabs"])
        app.collectionViews.cells["Internet for people, not profit — Mozilla"].press(forDuration: 2, thenDragTo: app.textFields["Search Tabs"])
        waitForValueContains(app.textFields["Search Tabs"], value: "mozilla.org")
        let searchValue = app.textFields["Search Tabs"].value
        XCTAssertEqual(searchValue as! String, fullFirstURL)
    }

    func testSearchFieldClearedAfterVisingWebsite() {
        navigator.openURL(firstURL)
        navigator.goto(TabTray)
        searchTabs(tabTitleOrUrl: "mozilla")
        app.collectionViews.cells["Internet for people, not profit — Mozilla"].tap()
        navigator.nowAt(BrowserTab)
        navigator.goto(TabTray)
        let searchValue = app.textFields["Search Tabs"].value
        XCTAssertEqual(searchValue as! String, "Search Tabs")
    }
}
