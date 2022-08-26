//
//  CEReminderController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-28.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import EventKit
import UIKit

class CEReminderController: NSObject {
    static let reminderTitle: String = "Coffee"
    static let userInfoTitle: String = "title"
    static let userInfoDescription: String = "description"

    var delegate: CEReminderControllerDelegate?
    var eventStore: EKEventStore
    var viewModel: CEEntryDetailViewModel

    init(viewModel: CEEntryDetailViewModel) {
        self.viewModel = viewModel
        eventStore = EKEventStore()
        super.init()
    }

    private func getCoffeeCalendar() -> EKCalendar? {
        let calendars = self.eventStore.calendars(for: .reminder)
        let filtered = calendars.filter { (calendar) -> Bool in
            calendar.title == CEReminderController.reminderTitle
        }
        if let first = filtered.first {
            return first
        } else {
            let calendar = EKCalendar(for: .reminder, eventStore: eventStore)
            calendar.title = CEReminderController.reminderTitle
            calendar.source = eventStore.defaultCalendarForNewReminders()?.source
            do {
                try eventStore.saveCalendar(calendar, commit: true)
                return calendar
            } catch {
                return nil
            }
        }
    }

    func reminderIntervalSheetInfo() -> [CEReminderInterval: String] {
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let dayName = dateFormatter.string(from: date as Date)

        let dayNumber = NSCalendar.current.component(.weekday, from: date as Date)
        var whichWeek = "This"
        var enumWeek: CEReminderInterval = .ThisWeekend
        if dayNumber == 1 || dayNumber == 6 || dayNumber == 7 {
            whichWeek = "Next"
            enumWeek = .NextWeekend
        }

        return [.Tomorrow: "Tomorrow", enumWeek: "\(whichWeek) Weekend", .NextWeekThisDay: "Next \(dayName)"]
    }

    func createReminderWithInterval(interval: CEReminderInterval) {
        eventStore = EKEventStore()
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            if granted {
                self._createReminderWithInterval(interval: interval)
            } else {
                self.delegate?.reminderController(reminderController: self, couldNotCreateReminderWithError: .CouldNotAccessReminders)
            }
        }
    }

    private func _createReminderWithInterval(interval: CEReminderInterval) -> NSError? {
        if let calendar = getCoffeeCalendar() {
            // add the reminder
            let reminder = EKReminder.init(eventStore: eventStore)
            reminder.title = "Coffee with \(viewModel.truth.fullName)"
            reminder.calendar = calendar
            let reminderDateComponents = dateComponentsFromInterval(interval: interval)
            let reminderDate = NSCalendar.current.date(from: reminderDateComponents)
            let alarm = EKAlarm(absoluteDate: reminderDate!)
            reminder.alarms = [alarm]
            reminder.dueDateComponents = reminderDateComponents
            do {
                try eventStore.save(reminder, commit: true)
                delegate?.reminderController(reminderController: self, didCreateReminder: reminder, inCalendar: calendar, withInterval: interval)
                return nil
            } catch {
                delegate?.reminderController(reminderController: self, couldNotCreateReminderWithError: .CouldNotCreateReminder)
                return errorFromError(error: .CouldNotCreateReminder)
            }
        } else {
            delegate?.reminderController(reminderController: self, couldNotCreateReminderWithError: .CouldNotCreateReminderList)
            return errorFromError(error: .CouldNotCreateReminderList)
        }
    }

    private func dateComponentsFromInterval(interval: CEReminderInterval) -> DateComponents {
        let calendar = Calendar.current
        var date = Date()
        var components = DateComponents()

        switch interval {
        case .NextWeekend:
            components.weekOfYear = 1
            date = calendar.date(byAdding: components, to: date)!
            date = calendar.date(bySetting: .day, value: 7, of: date)!
        case .ThisWeekend:
            date = calendar.date(bySetting: .day, value: 7, of: date)!
        case .NextWeekThisDay:
            components.weekOfYear = 1
            date = calendar.date(byAdding: components, to: date)!
        case .Tomorrow:
            components.weekday = 1
            date = calendar.date(byAdding: components, to: date)!
        }
        date = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date)!
        components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute, .second], from: date)
        return components
    }

    private func errorFromError(error: CEReminderError) -> NSError {
        var userInfo = [String: Any]()

        switch(error) {
        case .CouldNotCreateReminder:
            userInfo[CEReminderController.userInfoTitle] = "Can't Create Reminder" as Any
            userInfo[CEReminderController.userInfoDescription] = "I couldn't create the reminder." as Any
        case .CouldNotCreateReminderList:
            userInfo[CEReminderController.userInfoTitle] = "Can't Create Reminder List" as Any
            userInfo[CEReminderController.userInfoDescription] = "I couldn't create the \(CEReminderController.reminderTitle) reminder list." as Any
        case .CouldNotAccessReminders:
            userInfo[CEReminderController.userInfoTitle] = "Can't Access Reminders" as Any
            userInfo[CEReminderController.userInfoDescription] = "You have denied access to create reminders. Please enable access in Settings under Privacy." as Any
        }
        let error = NSError(domain: self.description, code: error.hashValue, userInfo: userInfo)
        return error
    }
}

enum CEReminderInterval {
    case Tomorrow
    case ThisWeekend
    case NextWeekend
    case NextWeekThisDay
}

enum CEReminderError {
    case CouldNotAccessReminders
    case CouldNotCreateReminderList
    case CouldNotCreateReminder
}

protocol CEReminderControllerDelegate {
    func reminderController(reminderController: CEReminderController, didCreateReminder reminder: EKReminder, inCalendar calendar: EKCalendar, withInterval interval: CEReminderInterval)
    func reminderController(reminderController: CEReminderController, couldNotCreateReminderWithError reminderError: CEReminderError)
}
