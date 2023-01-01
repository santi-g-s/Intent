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
    
    //MARK: - Reading Properties
    
    func test_ReadingProperties_Title() {
        let habit = Habit(context: dataManager.viewContext)
        habit.title = "Hello"
        XCTAssertEqual("Hello", habit.title)
    }
    
    func test_ReadingProperties_Title_Nil() {
        let habit = Habit(context: dataManager.viewContext)
        XCTAssertEqual("Unknown", habit.title)
    }
    
    func test_ReadingProperties_CompletedDates() {
        let habit = Habit(context: dataManager.viewContext)
        let date1 = Date()
        let date2 = Date().addingTimeInterval(-60*60*24)
        habit.completedDates = [date1, date2]
        
        let expected = [date1, date2]
        XCTAssertEqual(expected, habit.completedDates)
    }
    
    func test_ReadingProperties_StartDate() {
        let habit = Habit(context: dataManager.viewContext)
        let date = Date()
        habit.startDate = Date()
        XCTAssertEqual(date, habit.startDate)
    }
    
    func test_ReadingProperties_RequiredCount() {
        let habit = Habit(context: dataManager.viewContext)
        habit.requiredCount = 3
        XCTAssertEqual(3, habit.requiredCount)
    }
    
    func test_ReadingProperties_Status_Req1Complete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.requiredCount = 1
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_ReadingProperties_Status_Req1Incomplete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.requiredCount = 1
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
    }
    
    func test_ReadingProperties_Status_ReqMultiple() {
        let habit = Habit(context: dataManager.viewContext)
        habit.requiredCount = 3
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.pending(1), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.pending(2), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_ReadingProperties_Status_PrevDates() {
        let habit = Habit(context: dataManager.viewContext)
        habit.requiredCount = 3
        habit.completedDates.append(Date().addingTimeInterval(-60*60*24))
        habit.completedDates.append(Date().addingTimeInterval(-60*60*24*2))
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.pending(1), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.pending(2), habit.status)
        habit.completedDates.append(Date())
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
//    func test_ReadingProperties_DateStartedDescription_Today() {
//        let habit = Habit(context: dataManager.viewContext)
//        habit.startDate = Date()
//        XCTAssertEqual("Started today", habit.dateStartedDescription)
//    }
//
//    func test_ReadingProperties_DateStartedDescription_OneDay() {
//        let habit = Habit(context: dataManager.viewContext)
//        habit.startDate = Date().addingTimeInterval(-60*60*24)
//        XCTAssertEqual("Started 1 day ago", habit.dateStartedDescription)
//    }
//
//    func test_ReadingProperties_DateStartedDescription_MultipleDays() {
//        let habit = Habit(context: dataManager.viewContext)
//        habit.startDate = Date().addingTimeInterval(-60*60*24*10)
//        XCTAssertEqual("Started 10 days ago", habit.dateStartedDescription)
//    }
    
    //MARK: - Object methods
    
    func test_Complete_FromEmptyReq1() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.title = "Test task"
        habit.requiredCount = 1
        habit.timePeriod = .daily
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_Complete_FromEmptyReq3() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.title = "Test task"
        habit.requiredCount = 3
        habit.timePeriod = .daily
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(1), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(2), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_Complete_PrevDatesReq3() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.title = "Test task"
        habit.requiredCount = 3
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*1),
            Date().addingTimeInterval(-60*60*24*2),
            Date().addingTimeInterval(-60*60*24*3),
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*5)
        ]
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(1), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(2), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_CalculateScore_0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.requiredCount = 1
        habit.timePeriod = .daily
        XCTAssertEqual(0, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Prev() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*(24)*1*10)
        habit.requiredCount = 3
        habit.timePeriod = .daily
        habit.completedDates = [
                Date().addingTimeInterval(-60*60*(24)*1*10),// 10 days ago
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*3),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*2),
                Date().addingTimeInterval(-60*60*(24)*1*1),
                Date().addingTimeInterval(-60*60*(24)*1*1),
                Date().addingTimeInterval(-60*60*(24)*1*1)
            ]
        XCTAssertEqual(0.3, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Complete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.requiredCount = 1
        habit.completedDates = [Date()]
        habit.timePeriod = .daily
        XCTAssertEqual(0.1, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*4)
        habit.requiredCount = 1
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*4),
            Date().addingTimeInterval(-60*60*24*3),
            Date().addingTimeInterval(-60*60*24*2),
            Date().addingTimeInterval(-60*60*24*1),
            Date().addingTimeInterval(-60*60*24*0),
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Reduce() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*3)
        habit.requiredCount = 1
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*3), //1
            Date().addingTimeInterval(-60*60*24*2), //2
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }
    
    
    func test_CalculateScore_Jagged0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*5)
        habit.requiredCount = 1
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*5),//1
            Date().addingTimeInterval(-60*60*24*4),//2
            //0
            Date().addingTimeInterval(-60*60*24*2), //1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_PartiallyComplete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*5)
        habit.requiredCount = 2
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*5),//1
            Date().addingTimeInterval(-60*60*24*5),//1
            Date().addingTimeInterval(-60*60*24*4),//2
            Date().addingTimeInterval(-60*60*24*4),//2
            Date().addingTimeInterval(-60*60*24*3),
            Date().addingTimeInterval(-60*60*24*2),//1
            Date().addingTimeInterval(-60*60*24*2),//1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }
    
    func testCalculateScore_Jagged5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*10)
        habit.requiredCount = 1
        habit.timePeriod = .daily
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*10),//1
            Date().addingTimeInterval(-60*60*24*9),//2
            //0
            Date().addingTimeInterval(-60*60*24*7),//1
            Date().addingTimeInterval(-60*60*24*6),//2
            Date().addingTimeInterval(-60*60*24*5),//3
            //1
            Date().addingTimeInterval(-60*60*24*3),//2
            Date().addingTimeInterval(-60*60*24*2),//3
            Date().addingTimeInterval(-60*60*24*1),//4
            Date().addingTimeInterval(-60*60*24*0),//5
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_Complete_Weekly_FromEmptyReq1() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.title = "Test task"
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }
    
    func test_Complete_Weekly_FromEmptyReq3() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.title = "Test task"
        habit.requiredCount = 3
        habit.timePeriod = .weekly
        XCTAssertEqual(HabitStatus.pending(0), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(1), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.pending(2), habit.status)
        habit.complete()
        XCTAssertEqual(HabitStatus.complete, habit.status)
    }


    func test_CalculateScore_Weekly_0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        XCTAssertEqual(0, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Weekly_Complete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().startOfWeek()
        habit.requiredCount = 1
        habit.completedDates = [Date().startOfWeek()]
        habit.timePeriod = .weekly
        XCTAssertEqual(0.1, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Weekly_CompleteReq3() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().startOfWeek()
        habit.requiredCount = 3
        habit.completedDates = [Date().startOfWeek(), Calendar.current.date(byAdding: .day, value: 4, to: Date().startOfWeek())!, Calendar.current.date(byAdding: .day, value: 6, to: Date().startOfWeek())!]
        habit.timePeriod = .weekly
        XCTAssertEqual(0.1, habit.calculateScore(), accuracy: 0.001)
    }
    

    func test_CalculateScore_Weekly_5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*4)
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*4),
            Date().addingTimeInterval(-60*60*24*7*3),
            Date().addingTimeInterval(-60*60*24*7*2),
            Date().addingTimeInterval(-60*60*24*7*1),
            Date().addingTimeInterval(-60*60*24*7*0),
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Weekly_5Re2() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*4)
        habit.requiredCount = 2
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*4),
            Date().addingTimeInterval(-60*60*24*7*4).startOfWeek(),
            Date().addingTimeInterval(-60*60*24*7*3),
            Date().addingTimeInterval(-60*60*24*7*3).startOfWeek(),
            Date().addingTimeInterval(-60*60*24*7*2),
            Date().addingTimeInterval(-60*60*24*7*2).startOfWeek(),
            Date().addingTimeInterval(-60*60*24*7*1),
            Date().addingTimeInterval(-60*60*24*7*1).startOfWeek(),
            Date().startOfWeek(),
            Date().startOfWeek(),
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Weekly_2Re2() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*4)
        habit.requiredCount = 2
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*4),
            Date().addingTimeInterval(-60*60*24*7*4).startOfWeek(),
            Date().addingTimeInterval(-60*60*24*7*3),
            Date().addingTimeInterval(-60*60*24*7*3).startOfWeek(),
            Date().addingTimeInterval(-60*60*24*7*2),
            Date().addingTimeInterval(-60*60*24*7*2).startOfWeek(),
            Date().startOfWeek(),
            Date().startOfWeek(),
        ]
        XCTAssertEqual(0.2, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Weekly_Reduce() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*3)
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*3), //1
            Date().addingTimeInterval(-60*60*24*7*2), //2
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }


    func test_CalculateScore_Weekly_Jagged0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*5)
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*5),//1
            Date().addingTimeInterval(-60*60*24*7*4),//2
            //0
            Date().addingTimeInterval(-60*60*24*7*2), //1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }

    func testCalculateScore_Weekly_Jagged5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*7*10)
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*10),//1
            Date().addingTimeInterval(-60*60*24*7*9),//2
            //0
            Date().addingTimeInterval(-60*60*24*7*7),//1
            Date().addingTimeInterval(-60*60*24*7*6),//2
            Date().addingTimeInterval(-60*60*24*7*5),//3
            //1
            Date().addingTimeInterval(-60*60*24*7*3),//2
            Date().addingTimeInterval(-60*60*24*7*2),//3
            Date().addingTimeInterval(-60*60*24*7*1),//4
            Date().addingTimeInterval(-60*60*24*7*0),//5
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Weekly_PartiallyComplete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().addingTimeInterval(-60*60*24*5)
        habit.requiredCount = 2
        habit.timePeriod = .weekly
        habit.completedDates = [
            Date().addingTimeInterval(-60*60*24*7*5),//1
            Date().addingTimeInterval(-60*60*24*7*5),//1
            Date().addingTimeInterval(-60*60*24*7*4),//2
            Date().addingTimeInterval(-60*60*24*7*4),//2
            Date().addingTimeInterval(-60*60*24*7*3),//0
            Date().addingTimeInterval(-60*60*24*7*2), //1
            Date().addingTimeInterval(-60*60*24*7*2), //1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Monthly_0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date()
        habit.requiredCount = 1
        habit.timePeriod = .monthly
        XCTAssertEqual(0, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_Complete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().beginning(of: .month)!
        habit.requiredCount = 1
        habit.completedDates = [Date().beginning(of: .month)!]
        habit.timePeriod = .monthly
        XCTAssertEqual(0.1, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_CompleteReq3() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Date().startOfWeek()
        habit.requiredCount = 3
        habit.completedDates = [
            Date().beginning(of: .month)!,
            Calendar.current.date(byAdding: .day, value: 4, to: Date().beginning(of: .month)!)!,
            Calendar.current.date(byAdding: .day, value: 4, to: Date().beginning(of: .month)!)!
        ]
        habit.timePeriod = .monthly
        XCTAssertEqual(0.1, habit.calculateScore(), accuracy: 0.001)
    }


    func test_CalculateScore_Monthly_5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -4, to: Date())!
        habit.requiredCount = 1
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            Date().beginning(of: .month)!,
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_5Re2() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -4, to: Date())!
        habit.requiredCount = 2
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            Date().beginning(of: .month)!,
            Date()
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_2Re2() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -4, to: Date())!
        habit.requiredCount = 2
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            Date().beginning(of: .month)!,
            Date()
        ]
        XCTAssertEqual(0.2, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_Reduce() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        habit.requiredCount = 1
        habit.timePeriod = .weekly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!, //1
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!, //2
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }

    func test_CalculateScore_Monthly_Jagged0() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -5, to: Date())!
        habit.requiredCount = 1
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -5, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,//2
            //0
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!, //1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }

    func testCalculateScore_Monthly_Jagged5() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -10, to: Date())!
        habit.requiredCount = 1
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -10, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -9, to: Date())!,//2
            //0
            Calendar.current.date(byAdding: .month, value: -7, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -6, to: Date())!,//2
            Calendar.current.date(byAdding: .month, value: -5, to: Date())!,//3
            //1
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,//2
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,//3
            Calendar.current.date(byAdding: .month, value: -1, to: Date())!,//4
            Date().beginning(of: .month)!,//5
        ]
        XCTAssertEqual(0.5, habit.calculateScore(), accuracy: 0.001)
    }
    
    func test_CalculateScore_Monthly_PartiallyComplete() {
        let habit = Habit(context: dataManager.viewContext)
        habit.startDate = Calendar.current.date(byAdding: .month, value: -5, to: Date())!
        habit.requiredCount = 2
        habit.timePeriod = .monthly
        habit.completedDates = [
            Calendar.current.date(byAdding: .month, value: -5, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -5, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,//2
            Calendar.current.date(byAdding: .month, value: -4, to: Date())!,//2
            Calendar.current.date(byAdding: .month, value: -3, to: Date())!,//0
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,//1
            Calendar.current.date(byAdding: .month, value: -2, to: Date())!,//1
            //0
        ]
        XCTAssertEqual(0.0, habit.calculateScore(), accuracy: 0.001)
    }
    
}
