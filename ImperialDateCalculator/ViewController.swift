import Cocoa

class OnlyIntFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            return true
        }
        
        return Int(partialString) != nil
    }
}

class OnlyIntRFormatter: NumberFormatter {
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            return true
        }
        
        if partialString == "-" {
            return true
        }
        
        return Int(partialString) != nil
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var Logo: NSImageView!
    
    @IBOutlet weak var G2IYearField: NSTextField!
    @IBOutlet weak var G2IMonthMenu: NSPopUpButton!
    @IBOutlet weak var G2IDayField: NSTextField!
    @IBOutlet weak var G2IHourField: NSTextField!
    @IBOutlet weak var G2IConvertButton: NSButton!
    @IBOutlet weak var G2IResultField: NSTextField!
    
    @IBOutlet weak var I2GCheckNumberField: NSTextField!
    @IBOutlet weak var I2GYearFractionField: NSTextField!
    @IBOutlet weak var I2GYearField: NSTextField!
    @IBOutlet weak var I2GMilleniumField: NSTextField!
    @IBOutlet weak var I2GResultField: NSTextField!
    
    let MakrConstant = 0.11407955
    
    // initiatlisation du formatteur de champ texte
    let formatter = OnlyIntFormatter()
    let formatterR = OnlyIntRFormatter()
    
    var months = ["January",
                  "February",
                  "March",
                  "April",
                  "May",
                  "June",
                  "July",
                  "August",
                  "September",
                  "October" ,
                  "November",
                  "December"]
    
    var calendar: [String : Int] = ["January"   : 31,
                                    "February"  : 28,
                                    "March"     : 31,
                                    "April"     : 30,
                                    "May"       : 31,
                                    "June"      : 30,
                                    "July"      : 31,
                                    "August"    : 31,
                                    "September" : 30,
                                    "October"   : 31,
                                    "November"  : 30,
                                    "December"  : 31]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prevent resizing
        preferredContentSize = view.frame.size
        
        self.G2IYearField.stringValue = "40000"
        self.G2IHourField.stringValue = "00"
        self.G2IDayField.stringValue = "01"
        
        self.G2IYearField.formatter = formatterR
        self.G2IHourField.formatter = formatter
        self.G2IDayField.formatter = formatter
        
        self.I2GCheckNumberField.stringValue = "0"
        self.I2GYearFractionField.stringValue = "000"
        self.I2GYearField.stringValue = "000"
        self.I2GMilleniumField.stringValue = "41"
        
        self.I2GCheckNumberField.formatter = formatter
        self.I2GYearFractionField.formatter = formatter
        self.I2GYearField.formatter = formatter
        self.I2GMilleniumField.formatter = formatterR
        
        for month in months {
            self.G2IMonthMenu.addItem(withTitle: month)
        }
    }
    
    @IBAction func I2GActionCovertButton(_ sender: Any) {
        
        let checkNumber = Int(self.I2GCheckNumberField.stringValue)!
        let yearFraction = Double(self.I2GYearFractionField.stringValue)!
        let Imperialyear = Int(self.I2GYearField.stringValue)!
        let millenium = Int(self.I2GMilleniumField.stringValue)!
        
        self.I2GResultField.stringValue = self.ConvertI2G(checkNumber: checkNumber, yearFraction: yearFraction, Imperialyear: Imperialyear, millenium: millenium)
    }
    
    @IBAction func G2IActionCovertButton(_ sender: Any) {
        
        let year  = Int(self.G2IYearField.stringValue)!
        let month = self.G2IMonthMenu.titleOfSelectedItem!
        let day   = Int(self.G2IDayField.stringValue)!
        let time  = Int(self.G2IHourField.stringValue)!
        
        if(self.IsBissextile(year: year)) {
            self.calendar["February"] = 29
        } else {
            self.calendar["February"] = 28
        }
        
        self.G2IResultField.stringValue = self.ConvertG2I(time: time, day: day, month: month, year: year)
    }
    
    func IsBissextile(year: Int) -> Bool {
        if(year == 2000) {
            return true
        }
        if(year % 4 != 0) || ((year % 100 == 0) && (year % 400 != 0)) {
            return false
        }
        return true
    }
    
    func dayNumber(day: Int, month: String) -> Int {
        var count = 0
        
        for m in months {
            if m == month {
                count += day - 1
                break
            } else {
                count += self.calendar[m]!
            }
        }
        return count
    }
    
    func ConvertG2I(time: Int, day: Int, month: String, year: Int) -> String {
        
        let correctedDay = (day > self.calendar[month]! ? calendar[month] : day)!
        let dayNumber = Double(self.dayNumber(day: correctedDay, month: month))
        let yearFraction = Int(((dayNumber * 24) + Double(time)) * self.MakrConstant)
        let millenium = year >= 0 ? Int(year / 1000) + 1 : Int(year / 1000) - 1
        let correctedYear = year % 1000
        
        let imperialDate = "0" + String(format: "%03d", yearFraction) + String(format: "%03d", correctedYear) + "M" + String(millenium)
        
        return String(imperialDate)
    }
    
    func DateFromFraction(dayNumber: Int) -> (String, String, Bool) {
        var count = dayNumber
        var Gmonth: String = "January"
        var yearup = false
        
        for month in 0..<12 {
            if((count - self.calendar[months[month]]!) > 0) {
                count -= self.calendar[months[month]]!
                Gmonth = months[(month + 1) % 12]
                yearup = month == 11 ? true : false
            }
            if((count - self.calendar[months[month]]!) <= 0) {
                return (Gmonth, String(count), yearup)
                }
        }
        return (Gmonth, String(count), yearup)
    }
    
    func ConvertI2G(checkNumber: Int, yearFraction: Double, Imperialyear: Int, millenium: Int) -> String {
        
        let correctedYearFraction = yearFraction / self.MakrConstant / 24
        var roundedYearFraction = correctedYearFraction
        roundedYearFraction.round()
        let dayNumber = Int(roundedYearFraction) + 1
        let hourFraction = (roundedYearFraction - correctedYearFraction) * 24
        
        let hour = Int(floor(hourFraction))
        let minutes = Int((hourFraction - Double(hour)) * 60)
        let (month, day, yearup) = DateFromFraction(dayNumber: dayNumber)
        let year = Imperialyear + (1000 * (millenium - 1)) + (yearup ? 1 : 0)
        
        return String(month) + " " + String(day) + ", " + String(year) + "  " + String(format: "%02d", hour) + ":" + String(format: "%02d", minutes) + " GMT"
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

