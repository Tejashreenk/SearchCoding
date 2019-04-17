//
//  CodingExerciseTests.swift
//  CodingExerciseTests
//
//  Created by Kaya Thomas on 6/29/18.
//  Copyright © 2018 slack. All rights reserved.
//

import XCTest
@testable import CodingExercise

class CodingExerciseTests: XCTestCase {
    
    var systemUnderTest: AutocompleteViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let dataProvider = UserSearchResultDataProvider(slackAPI: SlackApi.shared)
        let viewModel = AutocompleteViewModel(dataProvider: dataProvider)
        
         systemUnderTest = AutocompleteViewController(viewModel: viewModel)


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSearchBar(){
        
        XCTAssert(systemUnderTest.conforms(to: UITextFieldDelegate.self))
        XCTAssertTrue(self.systemUnderTest.responds(to: (#selector(systemUnderTest.textFieldDidChange(textField:)))))
        
    }
    
    func testTableView(){
        
        XCTAssert(systemUnderTest.conforms(to: UITableViewDelegate.self))
        XCTAssert(systemUnderTest.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(self.systemUnderTest.responds(to: (#selector(systemUnderTest.tableView(_:numberOfRowsInSection:)))))
        XCTAssertTrue(self.systemUnderTest.responds(to: (#selector(systemUnderTest.tableView(_:cellForRowAt:)))))
        
    }
    
    
}
