//
//  HabitTests.swift
//  IntentTests
//
//  Created by Santiago Garcia Santos on 18/11/2022.
//

import XCTest
@testable import Intent

final class HabitTests: XCTestCase {
    
    var dataManager: DataManager!

    override func setUp() {
        super.setUp()
        dataManager = DataManager(.inMemory)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Score_Single_Day() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date()
        ]
        habit.startDate_ = Date()
        XCTAssertEqual(0.1, habit.score)
    }
    
    func test_Score_Perfect_10() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*9),
            Date().addingTimeInterval(-60*60*24*8),
            Date().addingTimeInterval(-60*60*24*7),
            Date().addingTimeInterval(-60*60*24*6),
            Date().addingTimeInterval(-60*60*24*5),
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*3),
            Date().addingTimeInterval(-60*60*24*2),
            Date().addingTimeInterval(-60*60*24*1),
            Date()
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*9)
        XCTAssertEqual(1.0, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Zero() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = []
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*9)
        XCTAssertEqual(0.0, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Decline() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*6),
            Date().addingTimeInterval(-60*60*24*5),
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*3),
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*6)
        XCTAssertEqual(0.0, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Incomplete_Today() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*10),
            Date().addingTimeInterval(-60*60*24*9),
            Date().addingTimeInterval(-60*60*24*8),
            Date().addingTimeInterval(-60*60*24*7),
            Date().addingTimeInterval(-60*60*24*6),
            Date().addingTimeInterval(-60*60*24*5),
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*3),
            Date().addingTimeInterval(-60*60*24*2),
            Date().addingTimeInterval(-60*60*24*1),
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*10)
        XCTAssertEqual(1.0, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Jagged_Recovery() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*7),
            Date().addingTimeInterval(-60*60*24*5),
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*2),
            Date().addingTimeInterval(-60*60*24*1),
            Date()
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*10)
        XCTAssertEqual(0.3, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Jagged_Decline() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*19), //0.1
            Date().addingTimeInterval(-60*60*24*18), //0.2
            Date().addingTimeInterval(-60*60*24*17), //0.3
            Date().addingTimeInterval(-60*60*24*16), //0.4
            Date().addingTimeInterval(-60*60*24*15), //0.5
            Date().addingTimeInterval(-60*60*24*14), //0.6
            Date().addingTimeInterval(-60*60*24*13), //0.7
            Date().addingTimeInterval(-60*60*24*12), //0.8
            Date().addingTimeInterval(-60*60*24*11), //0.9
            Date().addingTimeInterval(-60*60*24*10), //1.0
            // Date().addingTimeInterval(-60*60*24*9), //0.8
            Date().addingTimeInterval(-60*60*24*8), //0.9
            Date().addingTimeInterval(-60*60*24*7), //1.0
            // Date().addingTimeInterval(-60*60*24*6), //0.8
            // Date().addingTimeInterval(-60*60*24*5), //0.6
            Date().addingTimeInterval(-60*60*24*4), //0.7
            // Date().addingTimeInterval(-60*60*24*3), //0.5
            Date().addingTimeInterval(-60*60*24*2), //0.6
            // Date().addingTimeInterval(-60*60*24*1), //0.4
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*19)
        XCTAssertEqual(20, Calendar.current.numberOfDaysInclusive(habit.startDate, and: Date()))
        XCTAssertEqual(0.4, habit.score, accuracy: 0.00001)
    }
    
    func test_Score_Jagged_Longer() {
        let habit = Habit(context: dataManager.container.viewContext)
        habit.id = UUID()
        habit.title_ = "Test Habit"
        habit.completedDates_ = [
            Date().addingTimeInterval(-60*60*24*29), //0.1
            Date().addingTimeInterval(-60*60*24*28), //0.2
            Date().addingTimeInterval(-60*60*24*27), //0.3
            Date().addingTimeInterval(-60*60*24*26), //0.4
            Date().addingTimeInterval(-60*60*24*25), //0.5
            Date().addingTimeInterval(-60*60*24*24), //0.6
            Date().addingTimeInterval(-60*60*24*23), //0.7
            Date().addingTimeInterval(-60*60*24*22), //0.8
            Date().addingTimeInterval(-60*60*24*21), //0.9
            Date().addingTimeInterval(-60*60*24*20), //1.0
            //Date().addingTimeInterval(-60*60*24*19), //0.8
            Date().addingTimeInterval(-60*60*24*18), //0.9
            //Date().addingTimeInterval(-60*60*24*17), //0.7
            Date().addingTimeInterval(-60*60*24*16), //0.8
            //Date().addingTimeInterval(-60*60*24*15), //0.6
            Date().addingTimeInterval(-60*60*24*14), //0.7
            Date().addingTimeInterval(-60*60*24*13), //0.8
            Date().addingTimeInterval(-60*60*24*12), //0.9
            Date().addingTimeInterval(-60*60*24*11), //1.0
            //Date().addingTimeInterval(-60*60*24*10), //0.8
            Date().addingTimeInterval(-60*60*24*9), //0.9
            Date().addingTimeInterval(-60*60*24*8), //1.0
            Date().addingTimeInterval(-60*60*24*7), //1.0
            // Date().addingTimeInterval(-60*60*24*6), //0.8
            // Date().addingTimeInterval(-60*60*24*5), //0.6
            Date().addingTimeInterval(-60*60*24*4), //0.7
            // Date().addingTimeInterval(-60*60*24*3), //0.5
            Date().addingTimeInterval(-60*60*24*2), //0.6
            // Date().addingTimeInterval(-60*60*24*1), //0.4
            // Date()
        ]
        habit.startDate_ = Date().addingTimeInterval(-60*60*24*29)
        var habits = try? dataManager.container.viewContext.fetch(Habit.fetchRequest())
        print(habits)
        var score = habit.score
        XCTAssertEqual(30, Calendar.current.numberOfDaysInclusive(habit.startDate, and: Date()))
        XCTAssertEqual(0.4, score, accuracy: 0.00001)
    }
    
//    func test_Score_Super_Long() {
//
//        let habit = Habit(context: dataManager.container.viewContext)
//        habit.id = UUID()
//        habit.title_ = "Test Habit"
//        habit.startDate_ = Date().addingTimeInterval(-TimeInterval(60*60*24*(19)))
//
//        var expected: Double = 0.0
//
//        for i in stride(from: 19, through: 0, by: -1) {
//            if Int.random(in: 1...5) != 5 {
//                expected = min(1.0, expected + 0.1)
//                habit.completedDates.append(Date().addingTimeInterval(-TimeInterval(60*60*24*(i))))
//            } else {
//                if i != 0 {
//                    expected = max(0.0, expected - 0.1)
//                }
//            }
//        }
//
//        XCTAssertEqual(expected, habit.score, accuracy: 0.00001)
//
//    }
    
}
