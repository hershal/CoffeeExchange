//
//  CEReminderController.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-04-28.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation
import EventKit

class CEReminderController: NSObject {
    static let reminderTitle = "Coffee"
    static let userInfoTitle = "title"
    static let userInfoDescription = "description"

    var delegate: CEReminderControllerDelegate?
    var eventStore: EKEventStore
    var viewModel: CEEntryDetailViewModel

    init(viewModel: CEEntryDetailViewModel) {
        self.viewModel = viewModel
        eventStore = EKEventStore()
        super.init()
    }

    private func getCoffeeCalendar() -> EKCalendar? {
        let calendars = self.eventStore.calendarsForEntityType(.Reminder)
        let filtered = calendars.filter { (calendar) -> Bool in
            calendar.title == CEReminderController.reminderTitle
        }
        if let first = filtered.first {
            return first
        } else {
            let calendar = EKCalendar(forEntityType: .Reminder, eventStore: eventStore)
            calendar.title = CEReminderController.reminderTitle
            calendar.source = eventStore.defaultCalendarForNewReminders().source
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let dayName = dateFormatter.stringFromDate(date)

        let dayNumber = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
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
        eventStore.requestAccessToEntityType(.Reminder) { (granted, error) in
            if granted {
                self._createReminderWithInterval(interval)
            } else {
                self.delegate?.reminderController(self, couldNotCreateReminderWithError: .CouldNotAccessReminders)
            }
        }
    }

    private func _createReminderWithInterval(interval: CEReminderInterval) {
        if let calendar = getCoffeeCalendar() {
            // add the reminder
            let reminder = EKReminder.init(eventStore: eventStore)
            reminder.title = "Coffee with \(viewModel.truth.fullName)"
            reminder.calendar = calendar
            let reminderDate = dateComponentsFromInterval(interval)
            let alarm = EKAlarm(absoluteDate: reminderDate)
            reminder.alarms = [alarm]
            do {
                try eventStore.saveReminder(reminder, commit: true)
                delegate?.reminderController(self, didCreateReminder: reminder, inCalendar: calendar, withInterval: interval)
            } catch {
                delegate?.reminderController(self, couldNotCreateReminderWithError: .CouldNotCreateReminder)
            }
        } else {
            delegate?.reminderController(self, couldNotCreateReminderWithError: .CouldNotCreateReminderList)
        }
    }

    private func dateComponentsFromInterval(interval: CEReminderInterval) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        var date = NSDate()
        let components = NSDateComponents()

        switch interval {
        case .NextWeekend:
            components.weekOfYear = 1
            date = calendar.dateByAddingComponents(components, toDate: date, options: [])!
            date = calendar.dateBySettingUnit(.Day, value: 7, ofDate: date, options: [])!
        case .ThisWeekend:
            date = calendar.dateBySettingUnit(.Day, value: 7, ofDate: date, options: [])!
        case .NextWeekThisDay:
            components.weekOfYear = 1
        case .Tomorrow:
            components.weekday = 1
            date = calendar.dateByAddingComponents(components, toDate: date, options: [])!
        }
        date = calendar.dateBySettingHour(9, minute: 0, second: 0, ofDate: date, options: [])!
        return date
    }

    func errorFromError(error: CEReminderError) -> NSError {
        var userInfo = [NSObject: AnyObject]()

        switch(error) {
        case .CouldNotCreateReminder:
            userInfo[CEReminderController.userInfoTitle] = "Can't Create Reminder"
            userInfo[CEReminderController.userInfoDescription] = "I couldn't create the reminder."
        case .CouldNotCreateReminderList:
            userInfo[CEReminderController.userInfoTitle] = "Can't Create Reminder List"
            userInfo[CEReminderController.userInfoDescription] = "I couldn't create the \(CEReminderController.reminderTitle) reminder list."
        case .CouldNotAccessReminders:
            userInfo[CEReminderController.userInfoTitle] = "Can't Access Reminders"
            userInfo[CEReminderController.userInfoDescription] = "You have denied access to create reminders. Please enable access in Settings under Privacy."
        }
        let nsError = NSError(domain: self.description, code: error.hashValue, userInfo: userInfo)
        return nsError
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
