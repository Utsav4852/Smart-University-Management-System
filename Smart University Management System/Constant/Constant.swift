//
//  Constant.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-21.
//

import UIKit

let welcomeArr = ["Hi", "Hello"]

func resizedImageWith(image: UIImage, targetSize: CGSize) -> UIImage {
    let imageSize = image.size
    let newWidth  = targetSize.width  / image.size.width
    let newHeight = targetSize.height / image.size.height
    var newSize: CGSize
    if(newWidth > newHeight) {
        newSize = CGSize(width: imageSize.width * newHeight, height: imageSize.height * newHeight)
    } else {
        newSize = CGSize(width: imageSize.width * newWidth,  height: imageSize.height * newWidth)
    }
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func getSeason() -> String {
    let currentDate = Date()
    let calender = Calendar.current
    var compo = calender.dateComponents([.year], from: currentDate)
    let fallStart = changeDate(hour: 00, minute: 00, day: 1, month: 9)
    let fallEnd = changeDate(hour: 23, minute: 59, day: 31, month: 12)
    if fallStart <= currentDate && currentDate <= fallEnd {
        return "Fall \(compo.year!)"
    }
    let winterStart = changeDate(hour: 00, minute: 00, day: 1, month: 1)
    let winterEnd = changeDate(hour: 23, minute: 59, day: 30, month: 4)
    if winterStart <= currentDate && currentDate <= winterEnd {
        return "Winter \(compo.year!)"
    }
    let ssStart = changeDate(hour: 00, minute: 00, day: 1, month: 5)
    let ssEnd = changeDate(hour: 23, minute: 59, day: 31, month: 8)
    if ssStart <= currentDate && currentDate <= ssEnd {
        return "SS \(compo.year!)"
    }
    return ""
}

func getSeasonStartDate() -> Date {
    let currentDate = Date()
    let calender = Calendar.current
    var compo = calender.dateComponents([.year], from: currentDate)
    let fallStart = changeDate(hour: 00, minute: 00, day: 1, month: 9)
    let fallEnd = changeDate(hour: 23, minute: 59, day: 31, month: 12)
    if fallStart <= currentDate && currentDate <= fallEnd {
        return fallStart
    }
    let winterStart = changeDate(hour: 00, minute: 00, day: 1, month: 1)
    let winterEnd = changeDate(hour: 23, minute: 59, day: 30, month: 4)
    if winterStart <= currentDate && currentDate <= winterEnd {
        return winterStart
    }
    let ssStart = changeDate(hour: 00, minute: 00, day: 1, month: 5)
    let ssEnd = changeDate(hour: 23, minute: 59, day: 31, month: 8)
    if ssStart <= currentDate && currentDate <= ssEnd {
        return ssStart
    }
    return Date()
}

func changeDate(hour:Int, minute:Int, day:Int, month:Int) -> Date {
    let calender = Calendar.current
    var compo = calender.dateComponents([.day, .month, .year, .minute, .hour], from: Date())
    compo.hour = hour
    compo.minute = minute
    compo.day = day
    compo.month = month
    let date = calender.date(from: compo)
    return date!
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}
